# AltarDiario — Guía para agentes de IA (y humanos)

Este archivo es el contrato de trabajo. OpenCode lo carga automáticamente.
Léelo entero antes de tocar código. Si algo aquí contradice el código, el
código está mal o este archivo está desactualizado: dilo, no lo ignores.

## 0. Qué es esto

Red social devocional en Flutter + Firebase, **en producción** (Play Store,
web). Hay usuarios reales con datos reales. Cada cambio debe asumir que puede
romper algo que alguien usa hoy.

## 1. El ciclo de trabajo (obligatorio)

1. **Entiende** el issue. Si no tiene criterios de aceptación verificables,
   pide que se concreten antes de escribir código.
2. **Planifica** en 3-8 pasos. Lista los archivos que vas a tocar. Si vas a
   tocar más de 6 archivos, probablemente el issue es demasiado grande:
   propón dividirlo.
3. **Escribe el test primero** cuando el comportamiento sea testeable
   (modelos, servicios, providers, reglas de Firestore). Para UI, un widget
   test mínimo del estado principal.
4. **Implementa** con el cambio más pequeño que satisfaga el test.
5. **Verifica**: `scripts/check.sh --fast` (o `/check`). Nada está "hecho"
   si esto no está en verde. No reportes éxito sin haberlo corrido.
6. **Documenta** en `CHANGELOG.md` → `[Unreleased]` con una línea.
7. **Commit** con Conventional Commits en español:
   `feat(feed): paginación con startAfterDocument`.
   Un commit por unidad lógica. Nunca `git push`, `firebase deploy` ni
   `flutter build appbundle` sin confirmación explícita del humano.

### Definición de hecho
- [ ] `dart format` limpio, `flutter analyze` sin warnings, `flutter test` verde
- [ ] Tests nuevos para comportamiento nuevo
- [ ] Si tocaste `firestore.rules` → test en `firestore-tests/rules.test.mjs`
- [ ] Si tocaste un modelo → `toMap`/`fromMap` + test en `test/models/`
- [ ] CHANGELOG actualizado
- [ ] Ningún archivo nuevo supera 400 líneas; ningún widget privado supera 150

### 1c. Varias sesiones a la vez (obligatorio)

Si hay más de una sesión en el repo (lo normal: orquestadora + implementadora + auditora):

1. **Un worktree por sesión.** Dos sesiones en el mismo directorio acaban en un
   `reset --hard`, un `checkout -B` o un `stash` cruzado, y el trabajo de una
   desaparece sin que nadie se entere. `git worktree list` antes de empezar.
2. **`git fetch origin` y cita el SHA de `origin/main`** en todo informe
   ("validado en `<sha>`"). Nunca valides ni decidas sobre un `main` local desfasado.
3. **Se trabaja desde `origin/main`, no desde `main` local.** Rama nueva:
   `git checkout -B mi-rama origin/main`. El `main` local no lo mantiene nadie y por
   eso envejece: si lo necesitas al día, `scripts/sync-main.sh` (solo fast-forward).
4. **Un solo merger.** Solo la sesión orquestadora mergea y escribe el roadmap.
5. **Máximo 2 PRs abiertos por sesión**; antes de abrirlos, `git merge origin/main`
   y mira `git diff --stat origin/main` (si aparecen ficheros que no tocaste, estás
   desfasado y ese PR revertiría trabajo ajeno).
6. **Todo lo no empujado no existe**: push de la rama aunque sea WIP y tu fichero
   `roadmap/sesiones/<id>.md` al día.
7. Prohibido `push --force`, `reset --hard` y rebase de ramas con PR abierto.

Protocolo completo, plantillas y casos reales: `docs/SESIONES.md`.
Orientación en 30 segundos: `scripts/session-check.sh`.

## 2. Stack

| Capa | Tecnología | Notas |
|---|---|---|
| UI | Flutter 3.x, Material 3 | Sin code-gen (no freezed/build_runner) |
| Estado | Riverpod 3.x | `NotifierProvider`, nunca `StateNotifierProvider` |
| Backend | Firebase Auth, Firestore, Storage, FCM | Project `altardiario-ec25f` |
| Backend lógica | Cloud Functions (`functions/`, TypeScript) | En adopción — ver ADR-0002 |
| Local | `shared_preferences`, SQLite (`sqflite`) | Biblias descargadas |
| Observabilidad | Crashlytics, Analytics, App Check | `lib/core/observability/` |
| i18n | `flutter_localizations` + ARB en `lib/l10n/` | En adopción — ver skill `i18n` |

## 3. Mapa del código

```
lib/
  main.dart                      Bootstrap. No añadir lógica aquí.
  core/
    theme/                       Tokens visuales (colores, tipografía)
    constants/                   Constantes de app
    observability/               Crashlytics / Analytics / App Check
    services/                    Servicios transversales (notificaciones, gamificación)
  data/
    models/                      Modelos inmutables con toMap/fromMap
    services/                    Acceso a Firestore / Auth / Storage / SQLite
  presentation/
    providers/app_providers.dart Providers globales (en migración → por feature)
    screens/                     Pantallas (en migración → lib/features/)
    widgets/                     Widgets compartidos
  features/                      ← DESTINO. Una carpeta por feature:
    <feature>/
      data/        repositorio + modelos específicos
      providers/   providers de la feature
      presentation/ screens/ y widgets/ de la feature
      <feature>_test.dart (en test/features/<feature>/)
```

**Regla de migración (ADR-0001):** código nuevo va en `lib/features/<feature>/`.
Código existente se migra feature a feature, una por PR, sin mezclar refactor
con funcionalidad nueva. No crear providers nuevos en `app_providers.dart`;
crearlos en `lib/features/<feature>/providers/`.

## 4. Convenciones

| Qué | Convención | Ejemplo |
|---|---|---|
| Archivos | snake_case | `firestore_service.dart` |
| Clases | PascalCase | `FirestoreService` |
| Providers | camelCase + `Provider` | `feedPageProvider` |
| Imports | relativos dentro de `lib/` | `import '../models/reflexion.dart'` |
| Dominio | español | `Reflexion`, `PeticionOracion` |
| Técnico | inglés | `BibleVerse`, `StorageService` |
| Tests | descripción en español | `test('calcula racha de 7 días', …)` |
| Commits | Conventional Commits, español | `fix(oracion): contador de amén` |

### Modelos
- Campos `final`, constructor `const` si es posible.
- `toMap()` y `factory fromMap(Map)`. Para Firestore, `fromFirestore(DocumentSnapshot)`.
- Defaults con `??`; nunca `as` sin comprobación.
- Ninguna lógica de negocio en modelos; va en servicios o notifiers.

### Servicios
- Constructor atrapa fallos de Firebase y pone `_available = false`.
- Todo método público empieza con guard: `if (!_available) return …`.
- Streams: `.snapshots().map(...)`. Escrituras: `Future<void>`, `FieldValue` para contadores.
- **Toda consulta de colección lleva `.limit()`.** Sin excepción.
- Nunca `getAll*()` sin paginación.

### Riverpod
- `Provider` para singletons, `StreamProvider` para tiempo real,
  `FutureProvider` para one-shot, `NotifierProvider` para estado mutable.
- `ref.watch` en `build`, `ref.read` en callbacks. Nunca `ref.read` en `build`.
- En tests, los `Notifier` mock sobreescriben `build()`, no asignan `state` en el constructor.

### Widgets
- `ConsumerWidget` por defecto; `ConsumerStatefulWidget` solo con estado local real.
- Widgets privados `_Nombre` al final del archivo; si pasa de 150 líneas, archivo propio en `widgets/`.
- `AsyncValue` siempre con `.when(data:, loading:, error:)`. Nunca `.value!`.
- Nada de `print`; usa `debugPrint` o el logger de observabilidad.
- Pantallas sociales: comprobar `isGuestUserProvider` al inicio de `build()` y
  renderizar `GuestAccessRestrictedWidget` o esconder acciones.

### Seguridad (no negociable)
- Nunca commitear `.env`, `google-services.json`, `GoogleService-Info.plist`, keystores.
- Toda regla de Firestore nueva lleva test. Lee `.opencode/skills/firestore-rules/SKILL.md`.
- Un usuario **nunca** puede leer o escribir datos privados de otro.
- Contadores sociales: ±1 y solo con el uid propio (ver `firestore.rules`).
- No subir el límite de tamaño de textos sin justificar (spam / coste).

## 5. Testing

- `flutter_test` + `mocktail` + `fake_cloud_firestore` + `firebase_auth_mocks`.
- `SharedPreferences.setMockInitialValues({})` en `setUp()`.
- Widget tests envueltos en `ProviderScope(overrides: [...], child: MaterialApp(...))`.
- Pantallas sociales en tests: **siempre** `isGuestUserProvider.overrideWithValue(false)`
  y `userProfileProvider.overrideWith(...)`.
- Reglas: `scripts/rules_test.sh` (necesita Java para el emulador).
- Integración (flujos críticos): `integration_test/` — login → lectura del día → publicar.

## 6. Comandos

```bash
scripts/bootstrap.sh          # entorno desde cero + hook pre-commit
scripts/check.sh              # format + analyze + test + reglas  (= CI)
scripts/check.sh --fast       # sin reglas (sin Java)
scripts/check.sh --fix        # formatea
scripts/rules_test.sh         # solo reglas de Firestore
flutter test test/ruta.dart   # un archivo
flutter run -d chrome|android|ios
```

Slash commands en OpenCode: `/cycle`, `/audit`, `/roadmap`, `/check`,
`/rules-test`, `/feature`, `/review`, `/release`, `/migrate-feature`,
`/audit-security`. Ver `.opencode/commands/`.

```bash
scripts/loop.sh 3                        # 3 ciclos autónomos
node tools/roadmap-mcp/cli.mjs state     # estado del roadmap
```

## 6b. Ciclo autónomo y roadmap

El trabajo se organiza en `roadmap/tasks.yaml` (fuente de verdad) y se registra
en `roadmap/BITACORA.md`. **Nunca edites esos archivos a mano desde un agente**:
usa el MCP `roadmap` (`get_state`, `next_task`, `start_task`, `complete_task`,
`add_task`, `split_task`, `block_task`, `log_cycle`, `save_audit`).

- `/cycle` ejecuta un ciclo (agente `orchestrator`): una tarea, verificada,
  revisada, registrada. `scripts/loop.sh N` encadena N ciclos.
- `/audit` genera tareas nuevas a partir de una auditoría en 6 dimensiones.
- `/roadmap` muestra dónde va el proyecto.
- Protocolo completo: skill `autonomous-loop`.
- Si descubres trabajo necesario fuera de tu tarea, no lo hagas: `add_task`.
- Si algo requiere decisión humana (deploy, pago, producto, secretos): `block_task`.

## 7. Qué NO hacer

- No "arreglar" tests borrándolos o marcándolos `skip`.
- No bajar el nivel de las reglas de Firestore para que algo funcione.
- No añadir dependencias sin justificar en el PR (coste de mantenimiento).
- No cambiar `firebase_options.dart` a mano: `flutterfire configure`.
- No reformatear archivos que no tocas (ruido en el diff).
- No inventar APIs de paquetes: si dudas, abre el paquete en `.pub-cache` o pregunta.
- No asumir que algo compila: córrelo.

## 8. Documentación viva

| Archivo | Para qué |
|---|---|
| `roadmap/tasks.yaml` · `roadmap/STATE.md` | Backlog ejecutable y panel de progreso (vía MCP) |
| `roadmap/BITACORA.md` | Qué hizo cada ciclo autónomo |
| `docs/ROADMAP.md` | Visión por fases (narrativa; las tareas concretas están en roadmap/tasks.yaml) |
| `docs/adr/` | Decisiones de arquitectura (una por archivo) |
| `docs/AI_WORKFLOW.md` | Cómo trabajar día a día con OpenCode en este repo |
| `docs/SECURITY.md` | Modelo de amenazas, secrets, App Check |
| `docs/RELEASE.md` | Cómo publicar una versión |
| `SYSTEM.md`, `ARQUITECTURA_SOCIAL.md` | Referencia técnica heredada (se irá absorbiendo en ADRs) |
| `BITACORA.md` | Historial de sesiones (opcional, no reemplaza CHANGELOG) |
