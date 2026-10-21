# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 4 · **Fase actual:** 1 · **Progreso global:** █████░░░░░░░░░░░░░░░ 4/17 (24%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | █████████░░░░░░░░░░░ 4/9 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/4 |
| 4. Producto | ░░░░░░░░░░░░░░░░░░░░ 0/2 |

**En curso:** —
**Siguiente:** T-015 · Reglas: allowlist de campos actualizables en /chats y rechazar create con participantes duplicados (P1, S)

**Conteo:** backlog=12 · ready=0 · in_progress=0 · review=0 · done=4 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos
- El criterio 2 ('ningun test borrado ni skip') solo estaba demostrado a nivel de archivo; el reviewer pidio prueba por caso. Se ejecuto: 108 == 108 declaraciones test/testWidgets y 14 eliminadas == 14 anadidas por reflow, sin 'D' en git diff. Queda cubierto.
- Los tests de reglas de Firestore no se ejecutaron en este ciclo (--fast). El arbol de firestore.rules/rules.test.mjs es identico al de 6c53c2b, donde dieron 28/28, porque los unicos commits posteriores tocan roadmap/. No hay corrida unica que demuestre ambos verdes en el mismo proceso.
- integration_test/app_test.dart no lo ejecuta nadie: ni flutter test (solo recorre test/) ni la CI. El '100%' es de test/, no del arranque real con Firebase. Ademas dart format solo cubre lib y test, no integration_test/.
- Fijar la version de Flutter en los 4 workflows (hoy channel: stable sin version) y anadir un job de integration_test requieren editar .github/workflows, que el ciclo autonomo tiene prohibido tocar. Queda como decision humana, no como tarea auto.
- Al arrancar el ciclo, el MCP start_task habia dejado roadmap/STATE.md y roadmap/tasks.yaml modificados en el arbol; no eran cambios de codigo y se commitean con el cierre del ciclo.

**Decisiones:**
- Cerrar T-003 como verificacion no-op con evidencia real en vez de bloquearla: los dos criterios literales se cumplen y la tarea desbloquea cinco tareas de fase 1-3. Se deja escrito en la evidencia '0 tests rotos, 0 cambios de codigo' para que el historial no sugiera un arreglo inexistente.
- No se toco CHANGELOG: no hay cambio funcional, de API ni de versiones; el registro correcto es la evidencia de la tarea y esta bitacora.
- No se delego al implementer ni al tester: no hay comportamiento nuevo que implementar ni tests que anadir; el plan del planner concluyo 'cero archivos modificados' y el unico gate sin evidencia (formato) se ejecuto en el orquestador.
- No se crearon tareas para fijar Flutter en CI ni para integration_test porque ambas exigen editar workflows de CI, prohibido para el ciclo autonomo; se dejan como pendientes humanos en esta entrada.
- El commit asociado a la tarea es 886fb4e (tip de la rama base sobre el que se verifico). La rama auto/T-003-tests-verdes no aporta commits de codigo propios.

**Siguiente:** Siguiente elegible: T-014 (P1, S, bug) - sendMessage no debe reenviar participantIds en chats existentes y la UI no debe perder el texto si falla. Despues T-015 (P1, S, rules allowlist en /chats). Pendiente humano: (1) mergear auto/T-002-rules-tests-emulador para que firestore.rules llegue a produccion; (2) decidir si se fija la version de Flutter en los workflows; (3) decidir si integration_test/app_test.dart se ejecuta en CI o se documenta como manual; (4) valorar reescribir T-003-like tasks como auditorias.

---
## ## Ciclo 4 — 2026-10-21T00:43:38.664Z
- **Tarea:** T-014 · Chat: sendMessage no debe reenviar participantIds en chats existentes y la UI no debe perder el texto si falla
- **Resultado:** done
- **Rama/commit:** auto/T-014-chat-sendmessage @ 2ea3366
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR (revisión manual del diff tras timeout del ciclo; 0 bloqueantes)

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

