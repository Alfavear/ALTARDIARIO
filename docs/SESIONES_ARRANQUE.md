# Arranque de las tres sesiones

> Usa **sesiones nuevas** (contexto limpio), una por carril. No reutilices las anteriores: arrastran hábitos del
> marco antiguo (parchear con scripts `fix_*.py`, editar `BANDEJA`/`ESTADO-*` a mano, declarar bloqueos sin leer el log).
> Marco completo: `docs/FLUJO.md`. Este documento solo dice cómo empezar.

## Antes de abrir ninguna sesión (una vez, por una persona)

```bash
git clone https://github.com/system-technology/ALTARDIARIO.git && cd ALTARDIARIO
scripts/bootstrap.sh                     # dependencias, hooks versionados, MCP del roadmap
node scripts/board.mjs                   # estado real: debe salir sin "Desfase"
```

Comprueba que existen las claves `~/.altardiario-keys/{integradora,plataforma,producto}.pem` (fuera del repo).

## Crear el espacio de una sesión

```bash
scripts/nueva-sesion.sh producto T-054 borrado-de-cuenta   # integradora | plataforma | producto
```

Crea la carpeta de la sesión con su configuración de skills/MCPs/plugins, un worktree desde `origin/main` y la identidad de Git de su app.
Abre OpenCode **en el worktree**. La primera vez, haz la prueba de humo de `docs/CAPACIDADES.md`.

## Preámbulo común (primer mensaje de cada sesión)

```text
Trabajas en AltarDiario (Flutter + Firebase). Lee en este orden y no empieces antes de terminar:
1. AGENTS.md  2. docs/FLUJO.md  3. ownership.json  4. node scripts/board.mjs

Tu identidad: la GitHub App de tu sesión. Para cualquier operación contra GitHub usa
  GH_TOKEN=$(node scripts/gh-app-token.mjs <tu-sesion>) gh ...
y comprueba que el token NO está vacío antes de usarlo (si está vacío, gh cae a la cuenta del Owner).

Reglas: un worktree propio desde origin/main (cita su SHA); rama <carril>/T-xxx-slug; PR en borrador con T-xxx
en el título como reserva; sin scripts de parcheo en el repo; sin push --force/reset --hard/rebase en ramas con PR;
un bloqueo se reporta con la línea de log que lo prueba; al integrarte borras tu rama y tu worktree.
Antes de declarar algo hecho, ejecuta scripts/check.sh --fast y pega la salida. Si no puedes, dilo.
```

## Sesión 1 — Integradora (`i/…`, app `altardiario-integradora`)

```text
Eres la sesión INTEGRADORA. Tus rutas: roadmap/**, docs/**, AGENTS.md. No implementas funcionalidades.
Tu trabajo: (1) cada ciclo, node scripts/board.mjs y actúa sobre el desfase; (2) mergea PRs con los checks
en verde y sin rutas humanRequired (esas las aprueba el Owner: avísale con el enlace); (3) mantén tasks.yaml solo
por el MCP (complete_task con evidencia = PR mergeado); (4) si un PR cruza carriles, pídele que se divida o
pon la etiqueta override-lane solo con motivo escrito; (5) lee el log de CI antes de declarar ningún bloqueo.
Primera tarea: revisar los PRs abiertos y el board; no hay nada reservado todavía.
```

## Sesión 2 — Plataforma (`a/…`, app `altardiario-plataforma`)

```text
Eres la sesión PLATAFORMA. Tus rutas: firestore.rules, firestore-tests/, functions/, .github/, scripts/, tools/,
lib/core/, pubspec, android/ios/web, .opencode/, opencode.jsonc. No tocas lib/features ni lib/presentation.
Tus PRs sobre rutas humanRequired necesitan la aprobación del Owner: ábrelos pronto y en borrador.
Cola sugerida (por prioridad): T-055 (cerrar la regla transitoria email/fcmToken; la migración con --apply
la ejecuta el Owner con credenciales de producción), T-057 (CI para functions), T-061 (hidden → oculto en datos).
Usa el agente rules-auditor para cualquier cambio de reglas y corre scripts/rules_test.sh (emulador) antes de pushear.
```

## Sesión 3 — Producto (`b/…`, app `altardiario-producto`)

```text
Eres la sesión PRODUCTO. Tus rutas: lib/features/**, lib/presentation/**, lib/l10n/**, assets/**.
No tocas reglas, workflows ni scripts. Los ficheros compartidos (lib/data/**, app_providers.dart, CHANGELOG)
los puedes tocar pero con cambios pequeños y un solo PR vivo por fichero.
Cola sugerida: T-054 (borrado de cuenta desde la app, P1, requisito de la App Store), T-056 (rehacer la
limpieza de T-006 sobre main, parte de archive/auto/T-006-limpieza), T-059 (adoptar estados asíncronos).
Código escrito directamente en los ficheros: nada de fix_*.py, apply_*.py ni update_*.py.
```

## Cuando una sesión termina

1. PR mergeado → borra tu rama local y tu worktree (`git worktree remove`). El repo ya borra la remota.
2. Si te quedaste a medias: push de la rama como `wip/…` y una nota en el PR en borrador. Lo no empujado no existe.
3. La Integradora cierra la tarea en `tasks.yaml` por el MCP.

## Las tres sesiones en el mismo PC

Mientras compartan máquina (hoy es el caso), se cumplen además estas reglas:

| Recurso compartido | Regla |
|---|---|
| **Carpetas** | Cada sesión tiene su carpeta con **su** `opencode.jsonc` y sus worktrees dentro: `D:\Projects\AltarDiario\sesiones\<sesion>\<T-xxx>-<slug>\`. Se crea con `scripts/nueva-sesion.sh <sesion> <T-xxx> [slug]` y **OpenCode se abre dentro del worktree**. El checkout principal `ALTARDIARIO` queda limpio, en `main`, y nadie trabaja en él. Herramientas de cada sesión: `docs/CAPACIDADES.md`. |
| **Emulador de Firestore** (puerto 8080) | Solo corre **uno** a la vez. Lo usa casi siempre Plataforma (`scripts/rules_test.sh` y el pre-push cuando el diff toca reglas). Producto e Integradora usan `scripts/check.sh --fast`, que no lo necesita. Si otra sesión lo tiene, espera: no cambies puertos a mano. |
| **CPU/RAM** | Los builds (`flutter build`, APK) y la suite completa de `flutter test` son pesados: no los lances los tres a la vez. Para iterar, `flutter test <fichero>`; la suite completa la corre el CI. |
| **Claves de las apps** | Una sola carpeta `C:\Users\ALVEAR\.altardiario-keys\`, legible solo por el usuario. Cada sesión usa **únicamente su** `.pem`. El token se pide por comando (`GH_TOKEN=$(node scripts/gh-app-token.mjs <sesion>) gh …`) y no se exporta a toda la sesión. |
| **Cuenta del Owner** | En esta máquina `gh` cae a la cuenta del Owner si `GH_TOKEN` está vacío. Antes de usar el token comprueba que no lo está. Las sesiones **no** actúan como el Owner. |
| **Identidad en Git** | En cada worktree: `git config user.name "altardiario-<sesion>[bot]"` y `user.email "<app-id>+altardiario-<sesion>[bot]@users.noreply.github.com"` (IDs en `scripts/gh-apps.json`). |
| **Procesos** | Al cerrar una sesión, termina sus procesos (MCPs, emuladores, `flutter`/`dart`). Un proceso colgado bloquea el borrado del worktree. |
| **Hooks** | `core.hooksPath=scripts/hooks` es común a todos los worktrees (lo fija `bootstrap.sh`); no hace falta repetirlo. |
