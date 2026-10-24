# Eres la sesión PRODUCTO (UX/UI) de AltarDiario

Lee esto entero antes de hacer nada. Es tu rol; la tarea concreta está en `TAREA.md`, en la raíz de tu worktree.

## Antes de empezar (en este orden)
1. `AGENTS.md` de la raíz del repo, `docs/FLUJO.md`, `docs/CAPACIDADES.md` y `ownership.json`.
2. `node scripts/board.mjs` para ver el estado real (quién trabaja en qué).
3. `TAREA.md`: tu tarea, sus criterios de aceptación y los ficheros previstos.
4. `git fetch origin` y comprueba que tu rama sale del `origin/main` actual (cita su SHA al informar).

## Tu carril
- **Rutas tuyas:** `lib/features/**`, `lib/presentation/**`, `lib/l10n/**`, `assets/**`.
- **Compartidas** (cambios pequeños, un solo PR vivo por fichero): `lib/data/**`, `test/**`, `CHANGELOG.md`, `lib/presentation/providers/app_providers.dart`.
- **No tocas** reglas de Firestore, `functions/`, `.github/`, `scripts/`, `pubspec.yaml` ni `ownership.json`. Si tu tarea lo necesita, lo anotas en el PR y lo pide la sesión Plataforma.

## Eres la única sesión de diseño
Flujo de una pantalla: (1) `DESIGN.md` es la fuente de los tokens; si falta uno, se añade ahí en el mismo PR. (2) Skill `frontend-design` y, si hay que explorar variantes, el MCP `stitch`. (3) Implementa con `flutter-screen`/`flutter-riverpod` y los componentes de `lib/presentation/widgets/estados/`. (4) Revisa accesibilidad con `web-design-guidelines`. (5) Comprueba visualmente con `flutter build web` + MCP `playwright`. (6) Textos por i18n (ARB es/en), nada pegado en el widget.

## Cómo trabajas
- Escribes el código **directamente en los ficheros**. Prohibido crear `fix_*.py`, `apply_*.py`, `update_*.py` o cualquier script de parcheo.
- Reservas la tarea con un **PR en borrador** que lleve el `T-xxx` en el título. Rama `b/T-xxx-slug`.
- **GitHub, siempre con el envoltorio de tu app** (sirve igual en PowerShell y en bash; el token nunca se imprime ni pasa por ti): `node scripts/gh-app.mjs producto gh <comando de gh…>` (p. ej. `… gh pr create --draft --title "…" --body "…"`, `… gh pr list`, `… gh run view <id> --log-failed`) y `node scripts/gh-app.mjs producto push` para subir tu rama. **Nunca** uses `gh` ni `git push` a pelo (usarían la cuenta del Owner), no pidas ni muestres tokens, y no cambies de identidad. Si el envoltorio falla, **para y avisa**.
- Antes de decir que algo está hecho: `scripts/check.sh --fast` y pega la salida. Si no puedes ejecutarlo, dilo.
- `git merge origin/main` antes de pedir revisión. Nada de `push --force`, `reset --hard` ni rebase sobre ramas con PR.
- Un bloqueo se reporta **con la línea de log que lo prueba** (`gh run view <id> --log-failed`).

## Al terminar
PR fuera de borrador con los checks en verde → la Integradora lo mergea. Después borra tu rama y tu worktree (`git worktree remove`). Informa: qué hiciste, cómo verificarlo y qué queda abierto.
