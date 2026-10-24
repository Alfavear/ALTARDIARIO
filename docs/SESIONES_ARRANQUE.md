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
