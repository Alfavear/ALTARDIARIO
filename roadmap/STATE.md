# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 8 · **Fase actual:** 1 · **Progreso global:** ██████░░░░░░░░░░░░░░ 13/47 (28%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | █████████░░░░░░░░░░░ 12/26 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/8 |
| 4. Producto | ██░░░░░░░░░░░░░░░░░░ 1/11 |

**En curso:** —
**Siguiente:** T-038 · Chats: indice compuesto para la lista de chats (participantIds + lastUpdate) (P1, S)

**Conteo:** backlog=33 · ready=0 · in_progress=0 · review=0 · done=13 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos
## Ciclo 6 — 2026-10-21T02:58:42.091Z
- **Tarea:** T-018 · Privacidad: migrar email/fcmToken a private/account y ventana de compatibilidad con clientes antiguos
- **Resultado:** done
- **Rama/commit:** auto/T-018-migracion-privacidad @ abddd55
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR la parte de migracion; la parte de reglas y la ventana de compatibilidad quedan para el PR #21 y para decision humana

Herramienta administrativa de migracion: logica pura (planMigracion, 6 tests) + script admin por lotes con --apply explicito (npm run migrate:private-account). Mueve email/fcmToken de usuarios/{uid} a usuarios/{uid}/private/account; si el documento privado ya tiene el campo gana el privado (no se pisa el token de FCM mas reciente) y el campo publico se borra siempre. Es idempotente. Se documento en docs/SECURITY.md el orden de operaciones (app nueva -> migrar -> endurecer reglas -> repetir hasta 0). Ademas se integro el roadmap funcional de Codex (docs/PRODUCT_EVOLUTION_ROADMAP.md) como tareas: 16 unidades nuevas, y se registraron los hallazgos de los tres revisores (indice de chats, noPrivateFields, allowlist del doc privado, deadlock de limpieza del token, topes de tamano, job de functions en CI).

**Problemas:**
…

## Ciclo 7 — 2026-10-23T00:52:11.900Z
- **Tarea:** T-012, T-013, T-046 y T-027 · Roadmap sin reformateo, STATE.md, SIGPIPE de loop.sh e Inicio "Hoy"
- **Resultado:** done
- **Rama/commit:** auto/T-013-estado-roadmap (PR #28) y auto/T-027-inicio-hoy @ 1f85a74 y 8357e8c
- **check.sh:** ✅ verde
- **Reviewer:** pendiente (PR del Inicio en revision)

El MCP del roadmap ya no puede reformatear tasks.yaml en masa: dos tests de regresion lo impiden y el fichero canonico se mantiene byte a byte. STATE.md deja de duplicar encabezados de ciclo. loop.sh sale con 0. La tarjeta de Inicio se extrae a dos widgets con los cuatro estados (cargando, sin conexion, pendiente, completado), se abre con un toque y ofrece la siguiente lectura del plan.

**Problemas:**
…

## Ciclo 8 — 2026-10-23T01:35:57.115Z
- **Tarea:** T-019, T-044, T-022 · Bloqueo de usuarios, limites en reglas y filtrado de bloqueados
- **Resultado:** mergeado en main (PRs #31, #32, #33; #34 T-027 en la misma tanda)
- **Rama/commit:** fix/lane-b-06-tamano-limites, fix/lane-b-07-bloquear-usuarios, fix/lane-b-08-filtrar-bloqueados, auto/T-027-inicio-hoy @ 068f2db, fa7d0a4, 90ea33c, c0aa2b3
- **check.sh:** ✅ verde
- **Reviewer:** CI 4/4 en cada PR. Conflictos resueltos a mano: CHANGELOG (#31), firestore_service duplicado + llave perdida (#33, #36).

Tanda de merges de la noche. La otra sesion (carril B) produce rama+PR y esta sesion mergea. Se resolvieron conflictos en serie sin reescribir historia y se detecto que el auto-merge de #36 rompia el fichero (metodos duplicados y una llave sin cerrar): corregido antes de pushear.

**Problemas:**
…
