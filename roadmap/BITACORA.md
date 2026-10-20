# Bitácora de ciclos autónomos

Append-only. Cada ciclo añade una entrada al final vía MCP `log_cycle`.
Formato fijo para que sea parseable: no editar entradas anteriores.

Para el historial humano anterior a este sistema, ver `../BITACORA.md`.

---
## Ciclo 1 — 2026-10-20T23:06:14.124Z
- **Tarea:** T-001 · Ejecutar flutter pub get y resolver conflictos de versiones de la rama de andamiaje
- **Resultado:** done
- **Rama/commit:** auto/T-001-pub-get-versiones 
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR CON CAMBIOS (0 bloqueantes)

Verificacion de toolchain y resolucion de dependencias del andamiaje. Resultado: NO habia ningun conflicto de versiones. El pubspec.lock versionado ya contenia una resolucion completa y coherente con el toolchain local (Flutter 3.44.1 / Dart 3.12.1), y las cinco sospechas del planner resultaron falsos positivos: intl 0.20.2 coincide con lo que pinnea flutter_localizations; un solo riverpod 3.2.1 en todo el arbol (nada pide 2.x); firebase_auth_mocks 0.14.2 y fake_cloud_firestore 3.1.0 encajan con firebase_auth 5.7.0 y cloud_firestore 5.6.12; google_sign_in sigue en 6.3.0 (el codigo usa API v6); toda la ola Firebase comparte _flutterfire_internals 1.3.59. `flutter pub get` termino con exit 0 sin tocar pubspec.yaml ni pubspec.lock. `flutter analyze --no-pub` dio 'No issues found!' (0 errors, 0 warnings, 0 infos). `scripts/check.sh --fast` en verde con 108/108 tests. Cierre sin cambios de codigo. Se crearon T-012 (ruido de reformateo del MCP en tasks.yaml) y T-013 (bug cosmetico en 'Ultimos ciclos' de STATE.md) a partir de hallazgos de la revision.

**Problemas:**
- Los subagentes planner y reviewer NO tienen permiso de shell en este entorno (permission.rejected): no pueden ejecutar comandos. Los comandos de verificacion los ejecuto el orquestador, que si tiene shell. Esto invalida el paso 7 tal como esta escrito si el orquestador no tuviera shell.
- El MCP roadmap reescribe roadmap/tasks.yaml con su propio estilo YAML canonico (comillas en claves de phases, listas inline expandidas): ~106 lineas de diff de formato por cada escritura. Contamina el diff de cada rama auto/* y agrava conflictos con otras ramas que toquen el roadmap. Registrado como T-012.
- El plugin pub informa de 105 paquetes con versiones mas nuevas incompatibles con los constraints actuales. No se actua: subir versiones no es parte de T-001 y romperia la ola Firebase y la API v6 de google_sign_in. Riesgo de deriva tecnica a vigilar.

**Decisiones:**
- No se modifico pubspec.yaml ni pubspec.lock: no habia conflicto que resolver. Cualquier cambio de version habria sido un downgrade/upgrade gratuito con riesgo de regresion en produccion.
- No se delego al implementer ni al tester: la tarea es pura ejecucion de toolchain y no produce codigo; el tester no tenia comportamiento nuevo que cubrir y 'probar que pub get funciona' ya lo hace check.sh.
- Sin entrada en CHANGELOG.md: no hay cambio funcional ni de versiones, solo verificacion. Lo confirmo el reviewer (hallazgo verde). El registro correcto es esta bitacora.
- No se toco environment.sdk (^3.5.0) aunque el lock exige Dart >=3.12: es una decision de politica de toolchain/CI que afecta a quien compile el repo, no al resultado de esta tarea. Dejado como observacion del reviewer.
- Los tests de reglas de Firestore no se ejecutaron (--fast): quedan para T-002, que es la tarea que los cubre.

**Siguiente:** Siguiente elegible: T-002 (P0, security) ejecutar los tests de reglas contra el emulador y corregir fallos. Ojo antes de T-003: su premisa ('arreglar tests que rompan por nuevas dependencias/lints') no se cumple, flutter test da 108/108 y analyze esta limpio; conviene revisarla o reducirla. Pendiente humano: decidir si se sube environment.sdk a ^3.12.0 y si el CI fija Flutter >= 3.44.

---
## Ciclo 2 — 2026-10-20T23:43:59.481Z
- **Tarea:** T-002 · Ejecutar suite de tests de reglas de Firestore contra el emulador y corregir fallos
- **Resultado:** done
- **Rama/commit:** auto/T-002-rules-tests-emulador @ 6c53c2b
- **check.sh:** ✅ verde
- **Reviewer:** APROBAR CON CAMBIOS (0 bloqueantes; 2 asserts sugeridos aplicados y re-verificados)

La suite de reglas ya pasaba 20/20 al empezar, asi que el criterio 1 estaba cubierto sin cambios. El trabajo real fue el criterio 2: inventariar las 34 escrituras de Firestore del cliente (firestore_service.dart mas auth_service y gamification_service) y cruzarlas con firestore.rules y rules.test.mjs. Aparecio un bug real: sendMessage escribe SIEMPRE participantIds con el uid del emisor primero (chat_screen pasa [currentUid, otherUserId]) y la regla de /chats exigia !changedKeys().hasAny(['participantIds']), de modo que el participante que no creo el chat recibia PERMISSION_DENIED en el set previo al mensaje y el mensaje nunca se enviaba. Arreglo en reglas (sin release de app): helper sameMembers() y update de /chats que permite reordenar participantIds solo si el conjunto de miembros es identico y siguen siendo exactamente 2. Se anadieron 8 tests de reglas (foro, peticiones/feedback, perfil con set merge y deleteField, seguir, subcolecciones privadas, notificaciones en batch, regresion del chat): 28/28 en verde. Prueba roja verificada revirtiendo SOLO firestore.rules: el test de regresion cae (27/28, exit 1) y vuelve a verde al restaurarlo. check.sh --fast: 108/108 tests, analyze limpio, Todo en verde. Reviewer: APROBAR CON CAMBIOS, 0 bloqueantes; los 2 asserts que pedia se anadieron (duplicados que solo bloquea size()==2, y rama solo-metadatos). Commit 6c53c2b. NO se ha desplegado nada: las reglas nuevas llegan a produccion cuando un humano mergee a main (deploy-firebase.yml despliega firestore.rules al mergear).

**Problemas:**
- El primer run tras implementar dio 27/28: el test A7 de batch mezclaba instancias de Firestore (writeBatch(as(ALICE)) con doc(as(ALICE))) y lanzaba 'Provided document reference is from a different Firestore instance'. Arreglado guardando una sola instancia. Ademas el assertFails de ese test era un falso verde: pasaba por invalid-argument, no por permission-denied. Ahora comparte instancia y ejercita la regla real.
- Los subagentes (planner, implementer, tester, reviewer) siguen sin shell: no pueden ejecutar tests. Toda la verificacion (rules_test.sh, prueba roja con git stash, check.sh --fast) la hizo el orquestador. Funciona, pero el paso 7 del protocolo depende de que el orquestador tenga shell.
- firestore-tests/rules.test.mjs queda en 422 lineas, por encima del limite de 400 de AGENTS.md. Es deuda previa que este cambio cruza; registrada como T-016 junto con migrar a node --test para no fijar el nombre del archivo en duro.
- Al empezar, ningun test fallaba: la tarea estaba enunciada como 'corregir fallos' y no habia fallos, solo 1 escritura legitima bloqueada por las reglas. Conviene enunciar las tareas de este tipo como auditoria de cobertura, no como arreglo de fallos.
- La relajacion de /chats no tenia allowlist de campos (preexistente): cualquier participante puede sobrescribir lastMessage/lastSenderId/participantNames de un chat existente. Integridad, no confidencialidad. Registrado como T-015.
- T-003 ('arreglar tests existentes que rompan por las nuevas dependencias/lints') tiene la premisa rota: flutter test da 108/108 y analyze esta limpio. Es candidata a que un humano la reduzca o la descarte.

**Decisiones:**
- No se toco codigo Dart de produccion: el arreglo va en firestore.rules para proteger tambien a los usuarios con la app ya instalada, sin esperar a un release. El cambio de cliente (no reenviar participantIds en chats existentes, y no perder el texto si falla el envio) queda como T-014.
- La relajacion es minima y se intento romper: tipos no-lista, duplicados, tercer miembro, quitar a uno y arrays de 1 se deniegan; el unico caso que sameMembers deja pasar con lista distinta es el duplicado y lo cierra size()==2 sobre la lista cruda. Hay test para ese borde.
- Se pasaron de 20 a 28 tests de reglas en vez de solo ejecutar los existentes: el criterio 2 pedia verificar todas las escrituras, y la unica forma barata de que siga siendo cierto es tener test por familia de escritura. Ningun test se borro ni se marco skip.
- CHANGELOG con una linea en [Unreleased] -> Arreglado: hay cambio de semantica de reglas y fix funcional del chat. Una suite verde sin cambios no habria llevado entrada.
- No se despliegan reglas ni se hace push: eso es humano. Se avisa en el cierre de que el merge a main dispara el deploy de firestore.rules.
- Se crearon 4 tareas de seguimiento: T-014 (cliente de chat), T-015 (allowlist en /chats y create sin duplicados), T-016 (partir rules.test.mjs), T-017 (batch vacio en markAllNotificationsAsRead).

**Siguiente:** Siguiente elegible segun el roadmap: T-003 (P0, test), pero su premisa ya no se cumple (108/108 verde, analyze limpio): el siguiente ciclo deberia evaluarla y proponer reducirla/descartarla, no rehacer trabajo. Despues, P1 de la fase 1: T-014 y T-015 salen directamente de este ciclo (cliente de chat y endurecimiento de /chats). Pendiente humano: mergear esta rama a main para que firestore.rules llegue a produccion, y decidir sobre T-003.

---
## Ciclo 3 — 2026-10-20T23:57:23.037Z
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
