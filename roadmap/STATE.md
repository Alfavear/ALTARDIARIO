# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 9 · **Fase actual:** 1 · **Progreso global:** ███████░░░░░░░░░░░░░ 17/47 (36%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | ██████████░░░░░░░░░░ 13/26 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ███░░░░░░░░░░░░░░░░░ 1/8 |
| 4. Producto | █████░░░░░░░░░░░░░░░ 3/11 |

**En curso:** —
**Siguiente:** T-041 · Privacidad: documento privado con allowlist de campos, tipos y tamanos (P1, S)

**Conteo:** backlog=29 · ready=0 · in_progress=0 · review=0 · done=17 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos
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

## Ciclo 9 — 2026-10-23T02:22:27.129Z
- **Tarea:** T-028, T-033, T-036, T-038 · Reflexion guiada, biblioteca personal, eventos sin datos y indice de chats
- **Resultado:** mergeado en main (PRs #35, #37, #40, #39)
- **Rama/commit:** auto/T-028-reflexion-guiada, auto/T-033-biblioteca-personal, auto/T-036-eventos-producto, fix/lane-b-11-chats-indice @ 4471a39, 3586e4b, 227604e, 6faec67
- **check.sh:** ✅ verde
- **Reviewer:** CI 4/4 en cada PR. Se encontraron y corrigieron dos fallos de integracion que los tests no cubrian: reports no permitia targetType comentario y firestore.indexes.json era invalido (rompia el deploy de main).

Segunda tanda de merges. Ademas del codigo de cada tarea: (1) #38 necesitaba tests y una regla que no existia (targetType comentario) y se resolvio en su propia rama; (2) el indice de chats se subio con JSON invalido y tumbo el deploy de main, detectado al verificar los workflows y corregido en #44 con un test que valida el fichero en cada PR; (3) se detecto el desajuste entre los limites de las reglas y los topes del cliente (T-047).

**Problemas:**
…
