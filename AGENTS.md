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
    services/
      notification_service.dart        # Notificaciones locales + FCM push
      community_policy_service.dart    # Normas de la Comunidad (5 reglas)
      gamification_service.dart        # Badges, XP, niveles (16 insignias)
  data/
    models/
      badge.dart                       # Badge: id, name, icon, rarity, criteria, points
      bible_models.dart
      comment.dart
      debate.dart / debate_reply.dart
      lectura_dia.dart
      message.dart
      note.dart
      peticion_oracion.dart
      reflexion.dart
      usuario.dart                     # incluye badges[], totalPuntos, nivel
    services/
      auth_service.dart                # Auth: anónimo, Google, Apple
      bible_service.dart
      bible_download_service.dart
      firestore_service.dart
      storage_service.dart
  presentation/
    providers/
      app_providers.dart               # ÚNICO archivo de providers
    widgets/
      guest_access_restricted_widget.dart  # Pantalla bloqueo para invitados
    screens/                           # Ver SYSTEM.md para lista completa
test/
  models/            # Model unit tests
  services/          # Service unit tests (gamification_flow, community_policy)
  screens/           # Widget tests (feed, home, perfil, bible_compare)
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

### Providers clave de referencia
| Provider | Tipo | Descripción |
|---|---|---|
| `effectiveUserUidProvider` | `Provider<String?>` | UID activo (Firebase > local) |
| `isGuestUserProvider` | `Provider<bool>` | `true` si el usuario es anónimo |
| `userProfileProvider` | `StreamProvider<Usuario?>` | Perfil del usuario actual |
| `userProfileByIdProvider` | `StreamProvider.family<Usuario?, String>` | Perfil de cualquier usuario por UID |
| `isFollowingProvider` | `FutureProvider.family<bool, String>` | ¿Sigo a este usuario? |
| `focusModeProvider` | `NotifierProvider<FocusModeNotifier, bool>` | Modo Enfoque |
| `reflexionesStreamProvider` | `StreamProvider<List<Reflexion>>` | Feed completo |
| `peticionesStreamProvider` | `StreamProvider<List<PeticionOracion>>` | Peticiones de oración |

## Widget Patterns
- Default: `ConsumerWidget` (stateless, Riverpod-aware)
- For mutable state: `ConsumerStatefulWidget` + `ConsumerState`
- **Never** use plain `StatefulWidget` except for MainNavigationView (tab index)
- Private widgets: declare as `const _WidgetName({super.key, required ...})` at bottom of same file
- Async rendering: use `.when(data:, loading:, error:)` on `AsyncValue`
- No GoRouter, no named routes — use `Navigator.of(context).push(MaterialPageRoute(...))`

### Seguridad de Invitados
- Verificar `ref.watch(isGuestUserProvider)` al inicio del `build()` de pantallas sociales
- Si `isGuest == true`: retornar `GuestAccessRestrictedWidget` (widget dedicado en `lib/presentation/widgets/`)
- FABs y botones de acción social: envolver con `if (!isGuest)` antes de renderizar
- **FeedScreen**: invitados no ven FAB publicar, ni pueden seguir/reaccionar/comentar
- **OracionScreen**: pantalla completa reemplazada por `GuestAccessRestrictedWidget`

## Testing Conventions
- `flutter_test` only (no mockito/mocktail)
- Mock SharedPreferences: `SharedPreferences.setMockInitialValues({})` in `setUp()`
- Wrap widgets: `ProviderScope(overrides: [provider.overrideWithValue(...)], child: MaterialApp(...))`
- Model tests: `group('ModelName')` with `test('descripción en español', ...)`
- Use `testWidgets` for widget tests, `test` for unit tests
- **Mock Notifier providers** in tests: override `build()` (NOT constructor `state = value`) — Riverpod 3.x Notifiers throw "Tried to use a notifier in an uninitialized state" if `state` is set in constructor before `build()` runs
- **SIEMPRE** incluir `isGuestUserProvider.overrideWithValue(false)` en `ProviderScope` overrides de pantallas sociales (FeedScreen, OracionScreen, PerfilScreen)
- **SIEMPRE** incluir `userProfileProvider.overrideWith(...)` en tests de pantallas que muestran perfil

## Common Commands
```bash
flutter test                                          # Run all tests
flutter test test/path/to/file.dart                   # Single test file
flutter analyze                                       # Static analysis
flutter build apk --release                           # Android release build
flutter build appbundle --release                     # Play Store App Bundle (.aab)
flutter build web --release                           # Web production build
flutter build ios --release                           # iOS release build
flutter pub run flutter_launcher_icons                # Regenerar íconos de app
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
- ALWAYS check `isGuestUserProvider` in social screens before rendering action buttons
- NEVER add new providers outside of `app_providers.dart`
- NEVER use `StatefulWidget` — use `ConsumerStatefulWidget` instead

## Modo Enfoque
- **Provider**: `FocusModeNotifier` en `app_providers.dart` — persiste en SharedPreferences, al activar cancela notificaciones, al desactivar reprograma recordatorio.
- **Provider name**: `focusModeProvider` (`NotifierProvider<FocusModeNotifier, bool>`).
- **HomeScreen**: PopScope intercepta back button si focusMode activo y devocional no completado. AppBar muestra 🔒. Tarjeta SwitchListTile en el cuerpo con toggle.
- **Navegación**: `_handleNavigate(tab, isCompleted)` en HomeScreen bloquea tabs si focusMode on y !isCompleted.
- **Storage**: `storage_service.dart` — `getFocusMode()`, `setFocusMode(bool)` via `_keyFocusMode`.

## Gamificación
- **Servicio**: `lib/core/services/gamification_service.dart` — 16 insignias en 5 categorías (Rachas, Lectura, Comunidad, Oración, Especiales).
- **XP y Niveles**: 10 niveles (Semilla → Maestro Espiritual). `addPoints(userId, points, firestore)` usa transacción atómica.
- **Evaluación automática**: llamar `evaluarYNotificarBadges(usuario, stats, firestore, storage, context)` al publicar reflexiones o peticiones.
- **UI**: `PerfilScreen` muestra `_LevelProgressCard` (barra XP), `_AchievementsSection` (badges con rareza y estado) y modal completo `_showAllBadgesModal`.
- **Modelo**: `lib/data/models/badge.dart` — campos: `id, name, description, icon, category, rarity, criteria, points, createdAt`.

## Política de Comunidad
- **Servicio**: `lib/core/services/community_policy_service.dart` — lista de 5 normas de uso.
- **Integración**: mostrar `CommunityPolicyService.showPolicyModal(context)` desde PerfilScreen (Configuración) y antes de publicar.
- **Tests**: `test/services/community_policy_service_test.dart`.

## Ícono de la App
- Configurado en `pubspec.yaml` bajo `flutter_launcher_icons` con `assets/logo_app.png`.
- Regenerar con: `flutter pub run flutter_launcher_icons`
- Genera automáticamente todos los tamaños Android (`mipmap-*`) e iOS.
