# Skill: Firebase + Firestore (AltarDiario)

## Configuración del Proyecto
- **Project ID**: `altardiario-ec25f`
- **Auth**: Anónimo, Google, Apple (habilitados en Console)
- **Firestore**: Modo test + reglas en `firestore.rules`, índices en `firestore.indexes.json`
- **Storage**: Habilitado para avatares/fotos
- **Functions**: Preparado para futuras features

## Patrones de Servicio (`lib/data/services/firestore_service.dart`)

### Inicialización Resiliente
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _available = true;

  FirestoreService() {
    try { _firestore.settings = const Settings(persistenceEnabled: true); }
    catch (_) { _available = false; }
  }

  // Guardar TODOS los métodos
  if (!_available) return Stream.value([]);
  if (!_available) return Future.value();
```

### Streams (Tiempo Real)
```dart
Stream<List<Reflexion>> reflexionesStream() {
  if (!_available) return Stream.value([]);
  return _firestore
      .collection('reflexiones')
      .orderBy('fecha', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => Reflexion.fromFirestore(d)).toList())
      .handleError((_) => []);
}
```

### Escrituras (Upserts con merge)
```dart
Future<void> publicarReflexion(Reflexion r) async {
  if (!_available) return;
  await _firestore.collection('reflexiones').doc(r.id).set(r.toMap(), SetOptions(merge: true));
}

Future<void> toggleLike(String reflexionId, String userId) async {
  if (!_available) return;
  final ref = _firestore.collection('reflexiones').doc(reflexionId);
  await _firestore.runTransaction((tx) async {
    final snap = await tx.get(ref);
    if (!snap.exists) return;
    final data = snap.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }
    tx.update(ref, {'likedBy': likedBy, 'likesCount': likedBy.length});
  });
}
```

### Modelos Firestore
```dart
// En modelo: factory fromFirestore(DocumentSnapshot) y toMap()
factory Reflexion.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  return Reflexion(
    id: doc.id,
    userId: data['userId'] ?? '',
    texto: data['texto'] ?? '',
    fecha: (data['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    likedBy: List<String>.from(data['likedBy'] ?? []),
    reactions: Map<String, String>.from(data['reactions'] ?? {}),
    // ...
  );
}
```

## Reglas Críticas (`firestore.rules`)
- `request.auth != null` en todo
- Dueño del doc: `request.auth.uid == resource.data.userId`
- Chats: `request.auth.uid in resource.data.participants`
- Validar campos requeridos en `create`

## Índices Requeridos (`firestore.indexes.json`)
```json
{
  "collectionGroup": "reflexiones",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "userId", "order": "ASCENDING" },
    { "fieldPath": "fecha", "order": "DESCENDING" }
  ]
}
```

## Providers Relacionados (en `app_providers.dart`)
```dart
final firestoreServiceProvider = Provider((ref) => FirestoreService());
final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) => ref.watch(firestoreServiceProvider).reflexionesStream());
final userReflexionesProvider = StreamProvider.family<List<Reflexion>, String>((ref, uid) => ref.watch(firestoreServiceProvider).getUserReflexiones(uid));
```

## Comandos Útiles
```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
flutterfire configure --project=altardiario-ec25f
```