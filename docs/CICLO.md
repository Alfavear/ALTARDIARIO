# Ciclo autónomo (trabajo desatendido)

> Plataforma y Producto trabajan solas, en bucle, sin que nadie abra ni cierre sesiones.
> Complementa `docs/FLUJO.md` (carriles), `docs/CAPACIDADES.md` (herramientas) y `docs/SESIONES_ARRANQUE.md`
> (modo con persona delante). El código está en `scripts/ciclo.mjs`; la configuración, en `scripts/ciclo.config.json`.

## Idea

Un **supervisor por carril** (un script de Node, no un modelo) repite sin parar:

```
elegir tarea libre → worktree nuevo → PLAN (modelo) → REVISIÓN independiente (otro modelo)
   → IMPLEMENTAR (modelo) → PUERTAS (script) → push + PR + auto-merge (script) → limpiar → siguiente
```

El **modelo nunca ve GitHub, tokens ni claves**: edita código y hace commits locales. Todo lo demás lo hace el script.
Cada ciclo es una sesión nueva con el contexto limpio, así que no hay nada que cerrar a mano.

| Qué | Quién |
|---|---|
| Elegir la tarea, crear el worktree, ejecutar las puertas, empujar y abrir el PR | **supervisor** (determinista) |
| Planificar, implementar y reparar | modelo del carril (`ciclo.config.json`) |
| Revisar el plan contra el repo real | **otro** modelo (`modeloRevisa`), con orden de no fiarse del plan |
| **Auditar el repo y reponer el roadmap** | la **sesión auditora**, que lanza el supervisor cuando a un carril le quedan pocas tareas libres |
| Mergear | **GitHub** (auto-merge al pasar los checks obligatorios) |
| Rutas protegidas (`humanRequired`) | **el Owner, de forma asíncrona**: el ciclo no se detiene, pasa a otra tarea |
| Cerrar la tarea en `tasks.yaml` | la Integradora (o la Action que la sustituya), al mergear |

## Qué tarea elige

La primera de `roadmap/tasks.yaml` que cumpla **todo**: estado `backlog`/`ready`; dependencias hechas; esfuerzo S o M; sus
`files` pertenecen **solo a su carril** (`ownership.json`); no está reservada (ningún PR, rama remota ni worktree con su ID);
no está en `excluirTareas`; y **ninguno de sus ficheros está ya en juego** en otra tarea reservada y sin terminar.
Orden: prioridad P0→P3, luego S antes que M. Una tarea sin `files` no se elige (no se sabe de qué carril es).

## La sesión auditora (reponer el roadmap solo)

Cuando a un carril le quedan **`umbralTareasLibres` (2) o menos** tareas libres, el supervisor lanza una **sesión auditora** (un `opencode run`
más, con su propia configuración en `.opencode/sesiones/auditora.jsonc` y su rol en `auditora.auto.AGENTS.md`) *antes* de seguir con el trabajo:

1. **Audita** el repo (roadmap existente, bitácora, documentos de producto, código, tests, seguridad, CI) y escribe `AUDITORIA.md` (hallazgos con evidencia)
   y `PROPUESTAS.json` (tareas nuevas). **No edita código ni `tasks.yaml`.**
2. **Otro modelo revisa** las propuestas contra el repo real (evidencia, duplicados, un solo carril, criterios verificables).
3. El **supervisor valida** (determinista) y descarta lo que no cumpla: título ≥ 15 caracteres, tipo válido, esfuerzo S o M, ≥ 2 criterios de aceptación,
   rutas existentes, **un solo carril**, sin workflows, sin duplicar una tarea existente (similitud ≥ 60 %), máximo `maxTareasNuevas` (8) y prioridad **limitada a P2**.
4. Aplica las válidas con `addTask` (que valida `tasks.yaml`), añade el informe a `roadmap/audits/` y abre un PR `i/T-000-auditoria-AAAAMMDD`
   con la app **Integradora** y auto-merge (solo toca `roadmap/**`, no es ruta protegida).

Salvaguardas: **enfriamiento** de `enfriamientoHoras` (12) entre auditorías, **LOCK** para que dos supervisores no auditen a la vez, y cualquier fallo de la
auditoría no cuenta como fallo del ciclo de trabajo (solo deja constancia y espera al siguiente enfriamiento). Forzarla o probarla sin publicar:
`node scripts/ciclo.mjs plataforma --auditar --prueba --una`.

## Papeles

| Quién | Qué hace |
|---|---|
| **Supervisores** (scripts) | Sostienen el bucle, pasan las puertas, publican y lanzan las sesiones por fase, incluida la auditora |
| **Sesiones de OpenCode** (modelos) | Planifican, revisan, implementan, reparan y **auditan**; nunca ven GitHub |
| **GitHub** | Mergea al pasar el CI; Actions mantienen las ramas al día y cierran las tareas |
| **Owner** | Aprueba los PRs de rutas protegidas y decide el producto |
| **Claude (auditora externa)** | **No forma parte del ciclo.** La levanta el Owner cuando necesita una intervención puntual: revisar resultados, diagnosticar, diseñar |

## Salvaguardas

- **Presupuesto:** `maxCiclosDia` (10) por carril; al agotarse espera a mañana.
- **Fallos:** tras `maxFallosSeguidos` (3) **se para** y escribe `PARADO.md`. Para reanudar, borra `parado` en `estado.json`.
- **Freno de emergencia:** crear el fichero `…\sesiones\STOP` (todos los carriles) o `…\sesiones\<carril>-auto\STOP` (uno). Se reanuda borrándolo.
- **PRs abiertos:** no abre más de `maxPrsAbiertos` (2) sin integrar; antes de tarea nueva, **repara sus propios PRs en rojo** (hasta 2 veces por PR; después comenta «necesita revisión humana»).
- **Puertas antes de publicar:** al menos un commit; ≤ 25 ficheros y ≤ 900 líneas; ningún fichero prohibido (`fix_*.py`, `*.apk`, `.pem`, `.env`…);
  sin cruzar de carril (`check-ownership.mjs`); `scripts/check.sh --fast`; si toca reglas, `rules_test.sh`; si toca `functions/`, `npm test`.
  Si fallan, **una ronda de reparación**; si sigue fallando, el ciclo cuenta como fallo y no se publica nada.
- **Plan rechazado dos veces** por el revisor: el ciclo se descarta y cuenta como fallo.
- **Permisos del agente** (`.opencode/sesiones/auto.permisos.jsonc`, fuera de git): sin `gh`, `git push`, `git remote`, `curl`, `firebase deploy`, `rm -rf`,
  sin leer `.pem`/`.env`/`.altardiario-keys` ni editar `ownership.json`/`opencode.jsonc`.
- **Límite de tiempo** por fase (`minutosPorFase`, 25): se mata el proceso con todo su árbol.
- **Nada toca `main` ni su protección**: el supervisor usa la app del carril, que no tiene permiso de administración.

## Cómo se arranca

```powershell
# una vez (checkout en main, limpio, con npm ci hecho en tools\roadmap-mcp)
.\scripts\ciclo-instalar.ps1
Start-ScheduledTask -TaskName AltarDiario-Ciclo-plataforma
Start-ScheduledTask -TaskName AltarDiario-Ciclo-producto
```

Instala dos tareas programadas de Windows (arrancan al iniciar sesión y se relanzan si mueren). **El PC debe estar encendido y con la sesión iniciada.**
Para quitarlas: `.\scripts\ciclo-instalar.ps1 -Quitar`.

Probar sin publicar nada (un ciclo completo, sin push ni PR, conservando el worktree para inspeccionarlo):

```bash
node scripts/ciclo.mjs producto --prueba --una --tarea T-059
node scripts/ciclo.mjs plataforma --elegir          # solo muestra qué tarea tocaría
```

## Cómo se supervisa

```bash
node scripts/ciclo-estado.mjs     # ciclos de hoy, fallos, latido, últimos eventos y PRs
```

Logs: `…\sesiones\<carril>-auto\ciclo.log` (resumen) y `…\logs\<fecha>-<T-xxx>-<fase>.log` (salida completa de cada fase).
Lo que **necesita al humano** llega por GitHub: los PRs sobre rutas protegidas piden tu revisión (aviso de *review requested*)
y un PR que el ciclo no logra arreglar queda comentado como «necesita revisión humana».

## Límites conocidos

- Un ciclo puede producir un PR correcto que **no** es lo que querías: los criterios de aceptación de `tasks.yaml` mandan. Cuanto mejores sean, mejor sale.
- Las tareas **sin `files` o con ficheros de dos carriles** no se eligen: hay que dividirlas o completarlas.
- **Las tareas que tocan `.github/workflows/` no se eligen ni se publican**: una app no puede crear ni modificar workflows (GitHub exige el permiso `workflows`, que no se concede a propósito: un modelo podría añadir un workflow que lea los secrets antes de que nadie lo apruebe). Las hace una persona.
- El carril Plataforma tiene poco backlog propio; cuando no hay tarea libre, espera (`pausaSinTareaSeg`).
- Los modelos son de NVIDIA (`ciclo.config.json`) y están sujetos a los límites de tu cuenta. Si se agotan, los ciclos fallan y el supervisor se para a los 3 fallos.
- **Un PR autónomo sobre rutas protegidas no se integra hasta que lo apruebes.** Con 10 ciclos al día puede acumularse cola.
