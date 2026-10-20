# Estado del roadmap (autogenerado — no editar)

**Ciclo:** 3 · **Fase actual:** 1 · **Progreso global:** ████░░░░░░░░░░░░░░░░ 3/17 (18%)

| Fase | Progreso |
|---|---|
| 1. Estabilizar (seguridad, observabilidad, CI) | ███████░░░░░░░░░░░░░ 3/9 |
| 2. Andamiaje IA y tests | ░░░░░░░░░░░░░░░░░░░░ 0/2 |
| 3. Arquitectura feature-first y backend | ░░░░░░░░░░░░░░░░░░░░ 0/4 |
| 4. Producto | ░░░░░░░░░░░░░░░░░░░░ 0/2 |

**En curso:** —
**Siguiente:** T-014 · Chat: sendMessage no debe reenviar participantIds en chats existentes y la UI no debe perder el texto si falla (P1, S)

**Conteo:** backlog=13 · ready=0 · in_progress=0 · review=0 · done=3 · blocked=1 · dropped=0

**Bloqueadas:**
- T-009 Desplegar Cloud Functions de gamificación en paralelo al cliente (ADR-0002 paso 1) — Requiere plan Blaze y decisión humana de desplegar


## Últimos ciclos

**Decisiones:**
- No se toco codigo Dart de produccion: el arreglo va en firestore.rules para proteger tambien a los usuarios con la app ya instalada, sin esperar a un release. El cambio de cliente (no reenviar participantIds en chats existentes, y no perder el texto si falla el envio) queda como T-014.
- La relajacion es minima y se intento romper: tipos no-lista, duplicados, tercer miembro, quitar a uno y arrays de 1 se deniegan; el unico caso que sameMembers deja pasar con lista distinta es el duplicado y lo cierra size()==2 sobre la lista cruda. Hay test para ese borde.
- Se pasaron de 20 a 28 tests de reglas en vez de solo ejecutar los existentes: el criterio 2 pedia verificar todas las escrituras, y la unica forma barata de que siga siendo cierto es tener test por familia de escritura. Ningun test se borro ni se marco skip.
- CHANGELOG con una linea en [Unreleased] -> Arreglado: hay cambio de semantica de reglas y fix funcional del chat. Una suite verde sin cambios no habria llevado entrada.
- No se despliegan reglas ni se hace push: eso es humano. Se avisa en el cierre de que el merge a main dispara el deploy de firestore.rules.
- Se crearon 4 tareas de seguimiento: T-014 (cliente de chat), T-015 (allowlist en /chats y create sin duplicados), T-016 (partir rules.test.mjs), T-017 (batch vacio en markAllNotificationsAsRead).

**Siguiente:** Siguiente elegible segun el roadmap: T-003 (P0, test), pero su premisa ya no se cumple (108/108 verde, analyze limpio): el siguiente ciclo deberia evaluarla y proponer reducirla/descartarla, no rehacer trabajo. Despues, P1 de la fase 1: T-014 y T-015 salen directamente de este ciclo (cliente de chat y endurecimiento de /chats). Pendiente humano: mergear esta rama a main para que firestore.rules llegue a produccion, y decidir sobre T-003.

---
## ## Ciclo 3 — 2026-10-20T23:57:23.037Z
- **Tarea:** T-003 · Arreglar tests existentes que rompan por las nuevas dependencias/lints
- **Resultado:** done
- **Rama/commit:** auto/T-003-tests-verdes @ 886fb4e
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR CON CAMBIOS (0 bloqueantes; las 2 comprobaciones por caso sugeridas se ejecutaron y pasan)

Verificacion no-op de T-003: la premisa era obsoleta y NO habia ningun test roto. flutter test 108/108 en verde, flutter analyze limpio y el gate de formato de CI que faltaba por demostrar tambien pasa ('Formatted 80 files (0 changed)'). Criterio 2 demostrado a nivel de caso y de archivo contra main: 108 declaraciones test/testWidgets en main y 108 en HEAD, 14 eliminadas y 14 anadidas (solo reflow de formato), 7 expect eliminadas y 7 anadidas, 0 archivos de test borrados y 0 coincidencias de skip/markTestSkipped/@Skip en test/. scripts/check.sh --fast: format 0 changed, analyze 'No issues found!', '00:12 +108: All tests passed!', 'Todo en verde' (exit 0). Sin cambios de codigo ni CHANGELOG: no hay cambio funcional. Reviewer: APROBAR CON CAMBIOS, 0 bloqueantes. Se cierra T-003 con evidencia y se desbloquean T-004, T-005, T-006, T-007 y T-008.

**Problemas:**
- T-003 estaba enunciada como 'arreglar tests que rompan' cuando no habia ningun test roto: el criterio 1 ya se cumplia antes de empezar. Conviene reescribir tareas de este tipo como auditoria de estado ('verificar que la suite sigue en verde'), no como arreglo, para que el ciclo no parezca trabajo inexistente.
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

