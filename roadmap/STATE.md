# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 6 · **Fase actual:** 1 · **Progreso global:** ███░░░░░░░░░░░░░░░░░ 6/45 (13%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | █████░░░░░░░░░░░░░░░ 6/24 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/8 |
| 4. Producto | ░░░░░░░░░░░░░░░░░░░░ 0/11 |

**En curso:** —
**Siguiente:** T-038 · Chats: indice compuesto para la lista de chats (participantIds + lastUpdate) (P1, S)

**Conteo:** backlog=38 · ready=0 · in_progress=0 · review=0 · done=6 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos

**Problemas:**
- En un worktree nuevo `flutter pub get` falla: Windows sin symlinks (Developer Mode desactivado) y "Building with plugins requires symlink support". Se resolvio copiando .dart_tool/package_config.json del workspace principal y parcheando el rootUri al worktree; con eso `scripts/check.sh` corre entero. Sin ese apano, ningun worktree limpio puede pasar la puerta.
- El workspace principal lo tiene Codex ocupado con cambios sin commitear, por eso este ciclo corre en un worktree aislado sobre origin/main.

**Decisiones:**
- La allowlist de /chats incluye participantNames porque asi lo fija el criterio de aceptacion, aunque la app solo lo escribe en el create.
- No se restringe el create con hasOnly: T-015 pedia allowlist de update y rechazo de duplicados. Ampliarlo se deja como tarea aparte para no crecer el alcance.
- No se tocan /usuarios ni /reports: el stack de auditoria (#21 privacidad, #22 moderacion) modifica el mismo archivo; T-015 se limita a /chats para minimizar conflictos.
- El plan de auditoria no estaba en el backlog: sus secciones 2 a 5 se registran ahora como tareas con source=audit, sin duplicar T-004, T-006, T-007 ni T-008.

**Siguiente:** Siguiente elegible: T-017 (markAllNotificationsAsRead: no commitear un batch vacio) y T-018 (migracion de privacidad, P0) que desbloquea el PR #21. T-004 esta en curso en el PR #22 de la auditoria. Pendiente humano: mergear el stack de auditoria (#21/#22) cuando la migracion este lista, y revisar el resto de trabajo de Codex (restos sin commitear que debilitaban la allowlist de /reports ya restaurados en el commit de relevo 0ebf7cb).

---
## ## Ciclo 6 — 2026-10-21T02:58:42.091Z
- **Tarea:** T-018 · Privacidad: migrar email/fcmToken a private/account y ventana de compatibilidad con clientes antiguos
- **Resultado:** done
- **Rama/commit:** auto/T-018-migracion-privacidad @ abddd55
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR la parte de migracion; la parte de reglas y la ventana de compatibilidad quedan para el PR #21 y para decision humana

Herramienta administrativa de migracion: logica pura (planMigracion, 6 tests) + script admin por lotes con --apply explicito (npm run migrate:private-account). Mueve email/fcmToken de usuarios/{uid} a usuarios/{uid}/private/account; si el documento privado ya tiene el campo gana el privado (no se pisa el token de FCM mas reciente) y el campo publico se borra siempre. Es idempotente. Se documento en docs/SECURITY.md el orden de operaciones (app nueva -> migrar -> endurecer reglas -> repetir hasta 0). Ademas se integro el roadmap funcional de Codex (docs/PRODUCT_EVOLUTION_ROADMAP.md) como tareas: 16 unidades nuevas, y se registraron los hallazgos de los tres revisores (indice de chats, noPrivateFields, allowlist del doc privado, deadlock de limpieza del token, topes de tamano, job de functions en CI).

**Problemas:**
- En un worktree nuevo `flutter pub get` falla: Windows sin symlinks (Developer Mode desactivado). Workaround: copiar .dart_tool/package_config.json del workspace principal y parchear el rootUri al worktree. Sin eso, scripts/check.sh no arranca en worktrees limpios.
- La parte de REGLAS de la privacidad (noPrivateFields, privateOnlyRemoved, allowlist del documento privado y sus tests) NO va en esta rama: el fichero firestore.rules del PR #21 esta basado en un commit anterior a T-015 y mergearlo tal cual revertiria T-015. Hay que portar los cambios sobre el fichero actual.
- La ventana de compatibilidad con los clientes antiguos es una decision de producto, no tecnica. La auditoria recomienda la opcion A: subir config/app_info.minVersion (el dialogo bloqueante ya existe en update_service.dart) para forzar la actualizacion, luego migrar, y solo despues endurecer las reglas. Con las reglas endurecidas sin mas, el alta de cuenta de las versiones publicadas se rompe.
- functions/ no corre en CI: su script de test usaba node --test lib/**/*.test.js, que con bash sin globstar solo cubre un nivel y se saltaba gamification.test.js. Corregido en esta rama (node --test lib); el job de CI queda como tarea.

**Decisiones:**
- La herramienta vive en functions/src/migration/ y NO se exporta desde index.ts: no se despliega como Cloud Function, se ejecuta a mano con la cuenta de servicio.
- Nunca escribe sin --apply: por defecto solo genera informe.
- Gana el documento privado: la migracion no pisa un valor privado ya existente.
- Las reglas de privacidad no se tocan en esta rama para no colisionar con el PR #21 y con T-015; su especificacion queda en los hallazgos de rules-auditor.
- El roadmap funcional de Codex entra como tareas del backlog (source: audit docs/PRODUCT_EVOLUTION_ROADMAP.md) y el documento se incorpora con cherry-pick, sin duplicar T-004, T-006, T-007 ni T-008.

**Siguiente:** Pendiente inmediato: revision humana y merge del PR #23 (T-015, 4/4 checks) y del PR de T-018. En paralelo, la otra sesion corrige el stack de Codex (#21 privacidad, #22 moderacion) con los hallazgos de los tres revisores. Desbloqueo del stack: decision humana sobre la ventana de compatibilidad (Opcion A: minVersion) y ejecutar la migracion en produccion. Siguiente elegible del backlog: T-038 (indice de chats: la lista de chats falla en produccion con FAILED_PRECONDITION) y T-039 (noPrivateFields en contenido publico).

---

