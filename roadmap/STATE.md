# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 5 · **Fase actual:** 1 · **Progreso global:** █████░░░░░░░░░░░░░░░ 6/22 (27%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | ██████████░░░░░░░░░░ 6/12 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/5 |
| 4. Producto | ░░░░░░░░░░░░░░░░░░░░ 0/3 |

**En curso:** —
**Siguiente:** T-018 · Privacidad: migrar email/fcmToken a private/account y ventana de compatibilidad con clientes antiguos (P0, M)

**Conteo:** backlog=15 · ready=0 · in_progress=0 · review=0 · done=6 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos

sendMessage ahora distingue creación de chat (participantIds + participantNames, exactamente 2) de envío a chat existente (solo lastUpdate/lastMessage/lastSenderId). La UI dejó de pasar participantes, hace await con try/catch, conserva el texto si falla y ofrece REINTENTAR; el guard _isSending evita dobles envíos. Se añadió un constructor opcional FirestoreService({firestore}) para inyectar FakeFirebaseFirestore en tests. check.sh --fast: 122/122 tests, analyze limpio.

**Problemas:**
- El ciclo 4 se interrumpió por el timeout de 40 min del runner durante la fase de revisión; el trabajo quedó sin commitear. Se verificó y cerró manualmente vía MCP.
- Los subagentes planner/implementer/tester/reviewer no tienen shell; el orquestador ejecutó check.sh y las verificaciones.
- scripts/loop.sh sigue terminando con exit 1 por SIGPIPE del `state | head` final; no afecta al ciclo pero confunde.

**Decisiones:**
- No se reescriben participantIds/participantNames en chats existentes: se ignoran aunque el llamador los pase.
- El camino caliente de la UI no hace get() extra: llama sendMessage sin participantes y usa update().
- Se inyecta FirebaseFirestore opcional para tests con fake_cloud_firestore.
- No se tocó firestore.rules en este ciclo; T-015 queda para la allowlist de campos en /chats.

**Siguiente:** Siguiente elegible: T-015 (allowlist de campos en /chats y create sin duplicados) o T-017; revisar/mergear la pila auto/*. Pendiente humano: mergear T-002 a main para desplegar firestore.rules.

---
## ## Ciclo 5 — 2026-10-21T02:36:45.758Z
- **Tarea:** T-015 · Reglas: allowlist de campos actualizables en /chats y rechazar create con participantes duplicados
- **Resultado:** done
- **Rama/commit:** auto/T-015-rules-chats-allowlist @ 1469b62
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR (diff revisado a mano: allowlist exacta, duplicados denegados y ningun write legitimo de sendMessage bloqueado)

El update de /chats ahora exige changedKeys().hasOnly(['participantIds','lastMessage','lastSenderId','lastUpdate','participantNames']) y el create rechaza participantIds duplicados con participantIds.toSet().size() == 2. Verificado contra el codigo de la app: sendMessage escribe solo lastUpdate/lastMessage/lastSenderId en el update y participantIds/participantNames en el create, asi que ninguna escritura legitima queda bloqueada. Suite de reglas 30/30 (2 tests nuevos) y 123/123 tests de Dart. Se registro ademas en el backlog el trabajo que la auditoria dejo fuera: migracion de privacidad (bloquea el PR #21), bloqueo de usuarios, paginacion por cursor y flujo de eliminacion de cuenta.

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

