# Directrices para sesiones concurrentes

> **Léelo antes de tocar nada.** Esto no es teoría: cada regla de aquí existe porque
> se rompió algo en este repositorio. Los casos reales están al final, en §9.
>
> Aplica a **todas** las sesiones: orquestadora, implementadoras, auditoras, y a
> cualquier humano con un checkout abierto.

## 0. Las tres reglas que evitan perder trabajo

1. **Un worktree por sesión.** Dos sesiones en el mismo directorio acaban en un
   `git reset`, un `checkout -B` o un `stash` cruzado, y el trabajo de una desaparece
   sin que nadie se entere. Si vas a trabajar, `git worktree add` con tu nombre.
2. **Lo que no está empujado no existe.** Push de tu rama aunque sea un WIP
   (`wip/mi-rama`). Una rama en el remoto se recupera; un stash local, no.
3. **Nunca `push --force`, `reset --hard` ni rebase de una rama con PR abierto.**
   Reescribe SHA que otras sesiones están citando y tira los checks que ya corrieron.

## 1. Arranque (30 segundos, antes de leer código)

```bash
scripts/session-check.sh
```

Ese script te dice en qué worktree estás, en qué rama, **cuántos commits vas por
detrás de `origin/main`**, qué otros worktrees existen y qué PRs hay abiertos.

Si sales desfasado, **primero**:

```bash
git fetch origin && git merge origin/main
```

Y cita siempre el SHA contra el que trabajas:

```bash
git rev-parse --short origin/main    # p. ej. 410a6f7
```

Todo informe, PR o auditoría lleva **"validado en `<sha>`"**. Un informe sin SHA no
se acepta: no se puede saber qué código describía.

### 1.1 El `main` local no se mantiene, y no hace falta

Hoy **nadie lo actualizaba**. Llegó a estar **99 commits por detrás y 5 por delante**
(commits propios que solo existían en ese `main` local). Un `main` local desfasado es
una trampa: una auditoría lo leyó y reportó cuatro "bloqueantes" que ya estaban
arreglados en `origin/main`.

Regla: **se trabaja siempre desde `origin/main`**, nunca desde el `main` local.

```bash
# rama nueva
git checkout -B mi-rama origin/main

# rama que ya existe
git fetch origin && git merge origin/main

# si quieres el main local al día solo para leerlo
scripts/sync-main.sh
```

`scripts/sync-main.sh` **solo hace fast-forward**. Si el `main` local divergió, se
niega a tocarlo y te dice cómo rescatar los commits (son trabajo que no está en el
remoto: borrarlos es perderlo).

**Prohibido commitear en `main`.** Si descubres commits en un `main` local, rescátalos
a una rama y empújalos antes de seguir:

```bash
git branch rescate/main-local-$(date +%Y%m%d-%H%M) main
git push -u origin rescate/main-local-$(date +%Y%m%d-%H%M)
git branch -f main origin/main
```

## 2. Roles: quién puede qué

| Rol | Puede | No puede |
|---|---|---|
| **Orquestadora (A)** | Mergear a `main`, escribir el roadmap, resolver conflictos, tocar `ci.yml` y `scripts/` | Mergear sin los 4 checks en verde |
| **Implementadora (B)** | Rama + PR del carril que tenga asignado | Mergear, escribir el roadmap, deployar, tocar ficheros de A |
| **Auditora** | Leer, ejecutar tests, abrir issues/comentarios con evidencia | Escribir código, commitear, crear tareas |

**Un solo merger.** Si dos sesiones mergean a la vez se pisan los checks y cada merge
invalida al otro: media hora perdida por merge, garantizado.

**Máximo recomendado: 3 sesiones** (una de cada). Si necesitas una cuarta, que sea
sobre un conjunto de ficheros que nadie más toque, y anótalo en §5.

## 3. Propiedad de ficheros

La tabla viva está en `roadmap/BANDEJA.md` (§"Reparto de ficheros"). Regla corta:

- Si el fichero **no es tuyo**, no lo editas: pides el cambio en un comentario o creas
  una tarea. La excepción es resolver un conflicto en **tu propia rama**, y ahí se
  toma la versión de `main`.
- Si dos carriles necesitan el mismo fichero, **el cambio es del carril B** (reglas y
  cliente compartido) y A espera. Está en la bandeja, no lo reinventes.
- `.github/workflows/**`, `scripts/**`, `roadmap/**` y `AGENTS.md` son de A. Un cambio
  de CI hecho desde otra sesión se revierte, no se negocia en caliente.

## 4. Flujo de un cambio

1. `git fetch origin && git merge origin/main` (o rama nueva desde `origin/main`).
2. Rama con nombre honesto: `fix/…`, `feat/…`, `test/…`, `chore/…`.
3. Test primero si el comportamiento es testeable.
4. `scripts/check.sh --fast`; si tocaste reglas, `scripts/rules_test.sh`.
5. Una línea en `CHANGELOG.md` → `[Unreleased]`.
6. `git push` + PR que diga: **qué**, **por qué**, **evidencia** (salida de check.sh),
   **riesgos** y **qué NO cubre**.
7. **Máximo 2 PRs abiertos por sesión.** El tercero se queda en rama sin PR.
8. Antes de abrir el PR, comprueba el diff: `git diff --stat origin/main`. Si aparecen
   ficheros que no has tocado, estás desfasado y ese PR **revertiría** trabajo ajeno.

## 5. Registro de sesiones (sin ficheros compartidos)

Cada sesión escribe **su propio** fichero: `roadmap/sesiones/<id>.md`.
Un fichero por sesión significa cero conflictos entre sesiones.

Plantilla mínima (cópiala de `roadmap/sesiones/PLANTILLA.md`):

```markdown
# Sesión <id>
- rol: orquestadora | implementadora | auditora
- worktree: C:\ruta\al\worktree
- rama: feat/mi-rama
- PR: #57
- validado en: 410a6f7
- último latido: 2026-10-23T03:40Z
- siguiente paso: ...
- bloqueos: ...
```

Actualízalo al empezar, cada ~30 min y al terminar. La orquestadora lo agrega para
`ESTADO-A.md` / `ESTADO-B.md`.

## 6. Cuándo parar y escalar

- **Dos sesiones necesitan el mismo fichero** → para. Comenta en el PR y espera; no
  dupliques el trabajo "para ir más rápido" (acaba en `add/add` de un fichero que ya
  existía, como pasó con el diálogo de reportar).
- **Encuentras un fallo grave que no es tuyo** → no lo arregles en caliente: escribe la
  tarea con evidencia y sigue con lo tuyo.
- **Necesitas decisión de producto, dinero, secreto, deploy, tag o `minVersion`** →
  para y escala al humano. Nunca lo decides tú porque "es obvio".
- **El CI tarda más de lo normal o falla por infraestructura** → no lo arregles
  cambiando el workflow sin OK humano.

## 7. Anti-pérdida de trabajo (concreto)

| Situación | Qué hacer | Qué NO hacer |
|---|---|---|
| Vas a cambiar de rama con trabajo sin commitear | `git stash push -m "describe"` **y** commitear en rama WIP | Cambiar de rama a lo bruto |
| Necesitas partir de `main` limpio | `git checkout -B mi-rama origin/main` **en tu worktree** | Hacerlo en el worktree de otra sesión |
| Un PR se quedó obsoleto | `git merge origin/main` en su rama | `rebase` + `push --force` |
| Abandonas una línea de trabajo | push de la rama + nota en tu fichero de sesión | Borrar la rama local y "ya se verá" |
| El worktree se ensució | `git status`, commitear o descartar **solo lo tuyo** | `git reset --hard` a ciegas |
| `main` local desfasado o con commits propios | `scripts/sync-main.sh` (y rescatar a rama si divergió) | Commitear en `main` o hacerle `reset --hard` |

## 8. Auditoría y validación

- Valida **siempre** contra `origin/main`, en un worktree o `checkout` detached:
  ```bash
  git worktree add ../altar-audit-<sha> <sha>
  ```
- Cita el SHA y repítelo si `main` se mueve durante la sesión.
- Distingue lo que **está en `main`** de lo que **está en un PR**: no es lo mismo
  "el botón no existe" que "el botón está en la rama de #42, pendiente de merge".
- Si un hallazgo no se sostiene sobre `origin/main`, no se reporta como bloqueante:
  se reporta como "no se reproduce en `<sha>`".

## 9. Qué pasó el 22-10 (casos reales)

1. **9 PRs abiertos a la vez.** Cada merge dejaba `BEHIND` a los otros ocho y cada uno
   necesitaba `update-branch` + otra ronda de checks. La cola crecía más rápido de lo
   que drenaba. → Regla: máximo 2 PRs por sesión.
2. **Un PR (#47) construido sobre un `main` de hace horas.** Sus 4 checks salían verdes
   pero habría **revertido** el arreglo del índice (`firestore.indexes.json` volvía a
   ser inválido, deploy en rojo) y borrado `product_events.dart`. → Regla: merge de
   `main` antes de abrir, y mirar `git diff --stat origin/main`.
3. **Una auditoría sobre un `main` local 67 commits viejo.** Produjo cuatro
   "bloqueantes" que ya estaban arreglados (diálogo "muerto", allowlist sin
   `comentario`, `maxLength` ausente, "sin tests"). Los dos hallazgos reales quedaron
   enterrados entre los falsos. → Regla: validar contra `origin/main` y citar SHA.
4. **Un commit local sin push (`06a5b52`)** que nadie más podía ver, duplicando trabajo
   que ya estaba en un PR. → Regla: lo no empujado no existe.
5. **Dos PRs creando el mismo fichero nuevo** (`report_content_dialog.dart`): conflicto
   `add/add` y una ronda de resolución manual. → Regla: si tu PR añade un fichero,
   comprueba que no exista ya en `main`.
6. **El `main` local, abandonado.** Nadie lo mantenía: llegó a **99 commits por detrás
   y 5 por delante** (widgets de estados Async, el design system duplicando #50, un
   `tasks.yaml` editado a mano y un intento de T-025 ya obsoleto). Alguien lo leyó y
   auditó como si fuera `main`. → Regla: se trabaja desde `origin/main`; el `main`
   local se alinea con `scripts/sync-main.sh` y lo que tenga se rescata a una rama.

## 10. Checklist de cierre de sesión

- [ ] `git push` de la rama (aunque sea WIP).
- [ ] `roadmap/sesiones/<id>.md` actualizado (rama, PR, SHA, siguiente paso).
- [ ] Si cerraste tareas: evidencia con SHA real en `roadmap/ESTADO-*.md`.
- [ ] Si abriste trabajo que no terminas: comentario en el PR con el estado exacto.
- [ ] Si dejaste un PR en espera: di **por qué** y **qué** falta, no solo "pendiente".
