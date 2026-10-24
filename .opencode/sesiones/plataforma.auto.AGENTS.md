# Ciclo autónomo — carril PLATAFORMA (seguridad e infraestructura) de AltarDiario

Trabajas **sin supervisión humana**, dentro de un ciclo que ejecuta un supervisor (`scripts/ciclo.mjs`). Nadie va a contestarte: no pidas visto bueno ni hagas preguntas; decide con los criterios de `TAREA.md` y, si algo no se puede resolver, escríbelo en el fichero de salida de tu fase y termina.

## Tu carril
- **Tuyas:** `firestore.rules`, `firestore.indexes.json`, `firestore-tests/`, `functions/`, `.github/`, `scripts/`, `tools/`, `lib/core/`, `pubspec.yaml`/`pubspec.lock`, `android/`, `ios/`, `web/`.
- **Prohibido tocar:** `lib/features/**` y `lib/presentation/**` (es de Producto), `ownership.json`, `opencode.jsonc`, `.opencode/`.
- Los PRs sobre `firestore.rules`, `firestore-tests/`, `.github/` y `pubspec.yaml` los aprueba el Owner de forma asíncrona: el supervisor los abre igualmente.

## Reglas que no se negocian
- **No existe GitHub para ti**: no uses `gh`, `git push`, `git remote`, tokens ni claves. El supervisor empuja y abre el PR cuando tus cambios pasen las puertas.
- Escribe el código **directamente en los ficheros**. Prohibido crear `fix_*.py`, `apply_*.py`, `update_*.py` u otros scripts de parcheo.
- **Verifica los hechos antes de afirmarlos**: que un fichero existe, qué dice `package.json` (scripts y lockfile), qué ramas o jobs existen, qué reglas hay. Cita el comando. No inventes IDs de tareas, ficheros ni APIs.
- Cambios de reglas: usa el agente `rules-auditor`, escribe el test en `firestore-tests/` y ejecuta `scripts/rules_test.sh` (emulador, puerto 8080).
- En CI, los `npm ci` exigen `package-lock.json`: comprueba que existe antes de usarlo.
- Cambios pequeños y concentrados (el supervisor rechaza más de 25 ficheros o 900 líneas).
- Antes de terminar, ejecuta las comprobaciones relevantes y arregla lo que falle.
- Commits locales con mensaje convencional que incluya el ID de la tarea. No toques `main`.
- Despliegues, secrets y claves son del Owner: no los cambies ni los leas.

## Qué te pide el supervisor en cada fase
Te lo dice el mensaje de cada fase (planificar, revisar, implementar o reparar). Sigue exactamente el fichero de salida que te indique.

## Entorno (Windows + PowerShell)
- **Flutter y Dart SÍ están instalados y en el PATH**: ejecuta `flutter --version` y `dart --version` directamente. **No concluyas que falta un SDK sin ejecutar eso.**
- En PowerShell, `where` es un alias de `Where-Object` y **no imprime nada**: para localizar un ejecutable usa `Get-Command flutter` o `where.exe flutter`. `which` tampoco existe.
- `git`, `node`, `npm`, `gh` y `bash` (Git Bash) también están disponibles.
- El hook `pre-commit` ejecuta `flutter analyze`: si falla, **arréglalo**; no uses `--no-verify` para saltarlo. Si crees que el hook no puede funcionar, demuéstralo con la salida del comando antes de proponerlo.
