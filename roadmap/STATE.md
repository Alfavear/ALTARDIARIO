# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 5 · **Fase actual:** 1 · **Progreso global:** █████░░░░░░░░░░░░░░░ 5/21 (24%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | █████████░░░░░░░░░░░ 5/11 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/5 |
| 4. Producto | ░░░░░░░░░░░░░░░░░░░░ 0/3 |

**En curso:** —
**Siguiente:** T-018 · Privacidad: migrar email/fcmToken a private/account y ventana de compatibilidad con clientes antiguos (P0, M)

**Conteo:** backlog=15 · ready=0 · in_progress=0 · review=0 · done=5 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos
## Ciclo 3 — 2026-10-20T23:57:23.037Z
- **Tarea:** T-003 · Arreglar tests existentes que rompan por las nuevas dependencias/lints
- **Resultado:** done
- **Rama/commit:** auto/T-003-tests-verdes @ 886fb4e
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR CON CAMBIOS (0 bloqueantes; las 2 comprobaciones por caso sugeridas se ejecutaron y pasan)

Verificacion no-op de T-003: la premisa era obsoleta y NO habia ningun test roto. flutter test 108/108 en verde, flutter analyze limpio y el gate de formato de CI que faltaba por demostrar tambien pasa ('Formatted 80 files (0 changed)'). Criterio 2 demostrado a nivel de caso y de archivo contra main: 108 declaraciones test/testWidgets en main y 108 en HEAD, 14 eliminadas y 14 anadidas (solo reflow de formato), 7 expect eliminadas y 7 anadidas, 0 archivos de test borrados y 0 coincidencias de skip/markTestSkipped/@Skip en test/. scripts/check.sh --fast: format 0 changed, analyze 'No issues found!', '00:12 +108: All tests passed!', 'Todo en verde' (exit 0). Sin cambios de codigo ni CHANGELOG: no hay cambio funcional. Reviewer: APROBAR CON CAMBIOS, 0 bloqueantes. Se cierra T-003 con evidencia y se desbloquean T-004, T-005, T-006, T-007 y T-008.

**Problemas:**
…

## Ciclo 4 — 2026-10-21T00:43:38.664Z
- **Tarea:** T-014 · Chat: sendMessage no debe reenviar participantIds en chats existentes y la UI no debe perder el texto si falla
- **Resultado:** done
- **Rama/commit:** auto/T-014-chat-sendmessage @ 2ea3366
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR (revisión manual del diff tras timeout del ciclo; 0 bloqueantes)

sendMessage ahora distingue creación de chat (participantIds + participantNames, exactamente 2) de envío a chat existente (solo lastUpdate/lastMessage/lastSenderId). La UI dejó de pasar participantes, hace await con try/catch, conserva el texto si falla y ofrece REINTENTAR; el guard _isSending evita dobles envíos. Se añadió un constructor opcional FirestoreService({firestore}) para inyectar FakeFirebaseFirestore en tests. check.sh --fast: 122/122 tests, analyze limpio.

**Problemas:**
…

## Ciclo 5 — 2026-10-21T02:36:45.758Z
- **Tarea:** T-015 · Reglas: allowlist de campos actualizables en /chats y rechazar create con participantes duplicados
- **Resultado:** done
- **Rama/commit:** auto/T-015-rules-chats-allowlist @ 1469b62
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR (diff revisado a mano: allowlist exacta, duplicados denegados y ningun write legitimo de sendMessage bloqueado)

El update de /chats ahora exige changedKeys().hasOnly(['participantIds','lastMessage','lastSenderId','lastUpdate','participantNames']) y el create rechaza participantIds duplicados con participantIds.toSet().size() == 2. Verificado contra el codigo de la app: sendMessage escribe solo lastUpdate/lastMessage/lastSenderId en el update y participantIds/participantNames en el create, asi que ninguna escritura legitima queda bloqueada. Suite de reglas 30/30 (2 tests nuevos) y 123/123 tests de Dart. Se registro ademas en el backlog el trabajo que la auditoria dejo fuera: migracion de privacidad (bloquea el PR #21), bloqueo de usuarios, paginacion por cursor y flujo de eliminacion de cuenta.

**Problemas:**
…
