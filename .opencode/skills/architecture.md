# AltarDiario Architecture Patterns

## Project Structure
```
lib/
  main.dart                      # Entry point, Firebase init, ProviderScope
  firebase_options.dart          # Auto-generated Firebase config
  core/
    theme/app_theme.dart         # Design system (colors, gradients, text styles)
    services/notification_service.dart  # Local notifications (flutter_local_notifications)
  data/
    models/                      # Domain models (Spanish names, immutable)
      usuario.dart
      reflexion.dart
      comment.dart
      peticion_oracion.dart
      message.dart
      debate.dart
      debate_reply.dart
      lectura_dia.dart
      bible_models.dart
      note.dart
    services/
      auth_service.dart          # Firebase Auth (anon, Google, Apple, Demo)
      bible_service.dart         # Bible versions (SQLite native, memory web)
      firestore_service.dart     # ALL Firestore CRUD + streams
      storage_service.dart       # SharedPreferences (local progress, streaks, focus mode)
  presentation/
    providers/
      app_providers.dart         # ALL Riverpod providers (single file)
    screens/                     # Screen widgets (ConsumerWidget/ConsumerStatefulWidget)
    widgets/                     # Shared widgets (currently empty)
```

## Model Patterns (CRITICAL)
- **All fields `final`**, prefer `const` constructors
- **Spanish names** for domain models: `Usuario`, `Reflexion`, `PeticionOracion`
- **English names** for technical models: `BibleVerse`, `StorageService`
- **Required methods**:
  ```dart
  // Local storage
  Map<String, dynamic> toMap();
  factory Modelo.fromMap(Map<String, dynamic> map);
  
  // Firestore
  Map<String, dynamic> toMap();  // same name, different return for Firestore
  factory Modelo.fromFirestore(DocumentSnapshot doc);
  ```
- **Null safety**: `??` with defaults in factories, NEVER `as` casting
- **NO `copyWith`** unless explicitly needed

## Service Patterns (CRITICAL)
```dart
// Graceful Firebase init
class FirestoreService {
  final FirebaseFirestore _firestore;
  bool _available = true;
  
  FirestoreService() : _firestore = FirebaseFirestore.instance {
    try { _firestore.settings = const Settings(persistenceEnabled: true); }
    catch (_) { _available = false; }
  }
  
  // Guard ALL methods
  Stream<List<Reflexion>> reflexionesStream() {
    if (!_available) return Stream.value([]);
    return _firestore.collection('reflexiones').snapshots()
      .map((s) => s.docs.map((d) => Reflexion.fromFirestore(d)).toList())
      .handleError((_) => []);  // Never crash stream
  }
  
  // Writes return Future<void>, use FieldValue
  Future<void> toggleLike(String reflexionId, String userId) async {
    if (!_available) return;
    await _firestore.runTransaction((txn) async { ... });
  }
  
  // Upserts with merge
  Future<void> upsertUsuario(Usuario u) async {
    if (!_available) return;
    await _firestore.collection('usuarios').doc(u.id).set(u.toMap(), SetOptions(merge: true));
  }
}
```

## Riverpod Provider Patterns (ALL in app_providers.dart)
```dart
// Singletons
final storageProvider = Provider<StorageService>((ref) => StorageService());
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(authServiceProvider).authStateChanges);

// Parameterized streams
final userReflexionesProvider = StreamProvider.family<List<Reflexion>, String>((ref, uid) {
  return ref.watch(firestoreServiceProvider).userReflexionesStream(uid);
});

// Future providers for one-shot queries
final sugerenciasAmistadProvider = FutureProvider<List<Usuario>>((ref) async {
  return ref.watch(firestoreServiceProvider).getSugerenciasAmistad(ref.watch(effectiveUserUidProvider)!);
});

// Notifier for mutable local state
final focusModeProvider = NotifierProvider<FocusModeNotifier, bool>(FocusModeNotifier.new);

// Computed providers
final effectiveUserUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).whenData((u) => u?.uid).value ?? ref.watch(localUidProvider);
});
```

## Widget Patterns
- **Default**: `ConsumerWidget` (stateless, Riverpod-aware)
- **Mutable state**: `ConsumerStatefulWidget` + `ConsumerState`
- **NEVER** plain `StatefulWidget` (except `MainNavigationView` for tab index)
- **Private widgets**: `const _WidgetName({super.key, required ...})` at bottom of same file
- **Async rendering**: `asyncValue.when(data: (), loading: (), error: ())`
- **Navigation**: `Navigator.of(context).push(MaterialPageRoute(...))` — no GoRouter, no named routes

## Firebase Collections Structure
```
usuarios/{uid}
  nombre, email, fotoUrl, bio, fechaCreacion
  siguiendo: string[], seguidores: string[]
  progresoLectura: string[] (yyyy-MM-dd), maxStreak: int

reflexiones/{id}
  userId, userName, userFotoUrl, texto, pasajeDia, fecha, tags[]
  likedBy: string[], commentCount: int, reactions: map<userId, emoji>

reflexiones/{id}/comentarios/{cid}
  reflexionId, userId, userName, userFotoUrl, texto, fecha, likes, likedBy[]

peticiones/{id}
  userId, userName, texto, fecha, oracionesCount, category?

chats/{chatId}
  participantIds[], participantNames{}, lastMessage, lastSenderId, lastUpdate

chats/{chatId}/messages/{mid}
  senderId, texto, timestamp

debates/{id}
  userId, userName, titulo, contenido, libroId?, libroNombre?, fecha, votos, replyCount, votantes{}

debates/{id}/respuestas/{rid}
  userId, userName, contenido, fecha, votos, votantes{}
```

## Critical Rules
- **NEVER** commit `.env` (API keys)
- **NEVER** rename files without updating ALL imports
- **ALWAYS** guard Firebase code with `if (!_available) return ...`
- **ALWAYS** add both `toMap()` and `factory fromMap()` to new models
- **ALWAYS** add tests for new models (unit) and screens (widget test)
- **NO code generation** (no freezed, json_serializable, build_runner)