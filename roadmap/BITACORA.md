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
