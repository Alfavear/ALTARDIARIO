# AltarDiario — Project Guide for opencode

## Stack
- **Framework**: Flutter (SDK ^3.5.0)
- **State Management**: Riverpod 3.x (`flutter_riverpod`)
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Local Storage**: `shared_preferences` + SQLite (bible verses)
- **Navigation**: Manual `Navigator.push` + `IndexedStack` bottom nav
- **No code generation**: no freezed, no json_serializable, no build_runner

## Project Structure
```
lib/
  main.dart
  firebase_options.dart
  core/
    theme/app_theme.dart
    services/notification_service.dart
  data/
    models/          # Data models (immutable, hand-written)
    services/        # Auth, Firestore, Bible, Storage services
  presentation/
    providers/       # All Riverpod providers in app_providers.dart
    screens/         # Screen widgets
    widgets/         # Shared widgets
test/
  models/            # Model unit tests
  services/          # Service unit tests
  screens/           # Widget tests
```

## File & Naming Conventions
| What | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `firestore_service.dart` |
| Classes | PascalCase | `FirestoreService` |
| Methods/Vars | camelCase | `getUsuario()`, `_isLoading` |
| Providers | camelCase + `Provider` suffix | `authStateProvider` |
| Imports | Relative paths only | `import '../models/reflexion.dart'` |
| Private | underscore prefix | `_ReflexionCard` |
| Domain models | Spanish | `usuario`, `peticion_oracion` |
| Technical models | English | `BibleVerse`, `StorageService` |

## Model Patterns
- All fields `final`, prefer `const` constructors
- Methods: `toMap()`, `factory fromMap(Map)` for local storage
- For Firestore: `factory fromFirestore(DocumentSnapshot)`, `toMap()` returns `Map<String, dynamic>`
- Null safety: use `??` with defaults in factory methods, never cast with `as`
- No `copyWith` unless explicitly needed

## Service Patterns
- **Graceful Firebase init**: Constructor catches exceptions, sets `_available = false`
- **Guard all methods**: `if (!_available) return Stream.value([])` or early return
- **Stream methods**: return `.snapshots().map(...)` for real-time data
- **Write methods**: return `Future<void>`, use `FieldValue` for increments/arrays
- **Upserts**: use `SetOptions(merge: true)`

## Riverpod Provider Patterns
- All providers in `lib/presentation/providers/app_providers.dart`
- Use `Provider<T>` for singletons, `StreamProvider<T>` for streams
- Use `Provider.family` / `StreamProvider.family` for parameterized providers
- Use `NotifierProvider` for mutable local state (not StateNotifierProvider)
- Use `ref.watch` for reactivity, `ref.read` for one-shot access
- Provider naming: `{feature}Provider`, `{feature}StreamProvider`, `local{Feature}Provider`

## Widget Patterns
- Default: `ConsumerWidget` (stateless, Riverpod-aware)
- For mutable state: `ConsumerStatefulWidget` + `ConsumerState`
- **Never** use plain `StatefulWidget` except for MainNavigationView (tab index)
- Private widgets: declare as `const _WidgetName({super.key, required ...})` at bottom of same file
- Async rendering: use `.when(data:, loading:, error:)` on `AsyncValue`
- No GoRouter, no named routes — use `Navigator.of(context).push(MaterialPageRoute(...))`

## Testing Conventions
- `flutter_test` only (no mockito/mocktail)
- Mock SharedPreferences: `SharedPreferences.setMockInitialValues({})` in `setUp()`
- Wrap widgets: `ProviderScope(overrides: [provider.overrideWithValue(...)], child: MaterialApp(...))`
- Model tests: `group('ModelName')` with `test('descripción en español', ...)`
- Use `testWidgets` for widget tests, `test` for unit tests
- **Mock Notifier providers** in tests: override `build()` (NOT constructor `state = value`) — Riverpod 3.x Notifiers throw "Tried to use a notifier in an uninitialized state" if `state` is set in constructor before `build()` runs
- **Test surface size**: HomeScreen's `_MiniReadingCard` overflows in default test viewport (124px constraint); consider larger `physicalSizeTestValue` or simpler test assertions

## Common Commands
```bash
flutter test                                          # Run all tests
flutter test test/path/to/file.dart                   # Single test file
flutter analyze                                       # Static analysis
flutter build apk --release                           # Android release build
flutter build ios --release                           # iOS release build
flutterfire configure --project=altardiario-ec25f     # Re-configure Firebase
firebase deploy --only firestore:rules                # Deploy Firestore rules
firebase deploy --only firestore:indexes              # Deploy Firestore indexes
```

## Firebase Project
- Project ID: `altardiario-ec25f`
- Auth: Anonymous, Google, Apple enabled
- Firestore: test mode, indexes in `firestore.indexes.json`
- Rules in `firestore.rules`

## Critical Rules
- NEVER commit `.env` (contains API keys)
- NEVER rename files without updating all imports
- ALWAYS guard Firebase-dependent code with `kIsWeb` or availability checks
- ALWAYS add both `toMap()` and `factory fromMap()` to new models
- ALWAYS add tests for new models (unit) and screens (widget test)

## Modo Enfoque
- **Provider**: `FocusModeNotifier` en `app_providers.dart` — persiste en SharedPreferences, al activar cancela notificaciones, al desactivar reprograma recordatorio.
- **Provider name**: `focusModeProvider` (`NotifierProvider<FocusModeNotifier, bool>`).
- **HomeScreen**: PopScope intercepta back button si focusMode activo y devocional no completado. AppBar muestra 🔒. Tarjeta SwitchListTile en el cuerpo con toggle.
- **Navegación**: `_handleNavigate(tab, isCompleted)` en HomeScreen bloquea tabs si focusMode on y !isCompleted.
- **Storage**: `storage_service.dart` — `getFocusMode()`, `setFocusMode(bool)` via `_keyFocusMode`.
