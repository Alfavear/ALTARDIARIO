# Marco de trabajo con tres sesiones

> Una página. Si algo de `docs/SESIONES.md`, `roadmap/sesiones/*` o `AGENTS.md §1c`
> contradice esto, **manda este documento**. Fundamento: `roadmap/audits/2026-10-24-arquitectura-y-proceso.md`.

## Principio

**Un dato, un dueño. El estado volátil lo guarda GitHub, no los ficheros.**
Quién hace qué = PRs, ramas y checks. `roadmap/tasks.yaml` dice *qué* hay que hacer, no *quién lo hace*.
Para verlo: `node scripts/board.mjs` (cruza `tasks.yaml` con los PRs; no escribe nada).

## Las tres sesiones

| Sesión | Rama | Rutas (`ownership.json`) | Hace | No hace |
|---|---|---|---|---|
| **Integradora** | `i/…` | `roadmap/**`, `docs/**`, `AGENTS.md` | Mergea PRs con checks verdes, vigila el tablero, lee los logs de CI antes de declarar un bloqueo, lanza `/audit` | Implementar funcionalidades |
| **Plataforma** (A) | `a/…` | reglas, `firestore-tests`, `functions`, `.github`, `scripts`, `tools`, `lib/core`, `pubspec`, nativo | Seguridad, CI, infraestructura. Usa `rules-auditor` | Tocar `lib/features` ni `lib/presentation` |
| **Producto** (B) | `b/…` | `lib/features`, `lib/presentation`, `lib/l10n`, `assets` | Funcionalidades y UI. Usa `/cycle` y `/feature` | Tocar reglas, workflows ni scripts |

Compartidas (`lib/data/**`, `test/**`, `CHANGELOG.md`, `app_providers.dart`): las puede tocar cualquiera,
pero **un solo PR vivo por fichero** y cambios pequeños. Si necesitas cambiar un contrato compartido para tu
feature, abre primero ese PR pequeño y espera a que entre.

"Orquestador" ya no se usa para la sesión: el agente `orchestrator` de OpenCode es el pipeline *dentro* de una
sesión (planner → implementer → tester → reviewer → fixer). La sesión que mergea es la **Integradora**.

## Ciclo de una tarea

1. **Reserva**: abre un PR en **borrador** con `T-xxx` en el título y la rama `a|b/T-xxx-slug`. Eso es el claim; si ya
   existe un PR para esa tarea, elige otra.
2. **Trabaja** en tu worktree propio. `git merge origin/main` antes de abrir el PR y de nuevo antes de pedir revisión.
3. **Puertas** (de barata a cara): pre-commit (formato+análisis) → pre-push (tests; emulador de reglas si tocas reglas)
   → CI. Nunca declares algo verde sin haberlo ejecutado; pega la salida.
4. **Revisión**: quita el borrador. El check `Carril y tarea` debe estar sin fallos.
5. **Merge**: lo hace la Integradora, salvo rutas `humanRequired` (reglas, workflows, pubspec…), que exigen revisión
   humana (CODEOWNERS). Tras el merge, el tablero se corrige solo (la tarea aparece `MERGEADA`); el estado `done` del
   YAML lo actualiza la Integradora por el MCP en el siguiente ciclo.

## Bloqueos

Se reportan **con la línea de log que los prueba** (`gh run view <id> --log-failed`). Sin esa línea no es un
bloqueo, es una hipótesis. Preguntas y bloqueos: comentario en el PR de la tarea (queda junto al código).

## Reglas duras

- Un worktree por sesión; el checkout principal queda limpio, sobre `main`.
- Todo trabajo se empuja (rama `wip/…` si hace falta). Lo no empujado no existe.
- Sin `push --force`, `reset --hard` ni `rebase` sobre ramas con PR abierto.
- `--no-verify` solo con motivo escrito en el PR.
- Máx. 2 PRs abiertos por sesión.
- Un PR que toque rutas de otro carril se divide o lleva la etiqueta `override-lane` (la pone la Integradora).

## Herramientas

| Qué | Comando |
|---|---|
| Estado real | `node scripts/board.mjs` |
| ¿Mi PR respeta el carril? | `node scripts/check-ownership.mjs` |
| Higiene (worktrees, ramas, peso) | `scripts/hygiene.sh` (`--apply` solo borra ramas ya mergeadas) |
| Puerta completa | `scripts/check.sh` |
| Instalar hooks | `scripts/bootstrap.sh` (fija `core.hooksPath=scripts/hooks`) |
