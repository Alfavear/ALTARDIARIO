---
name: feature-scaffold
description: Estructura exacta para crear o migrar una feature a lib/features/<nombre>/ (ADR-0001). Usar al crear pantallas, providers o repositorios nuevos.
---

# Feature scaffold

Toda feature nueva vive en una carpeta propia. Objetivo: que un agente pueda
cargar en contexto SOLO la feature que toca.

```
lib/features/<feature>/
  data/
    <feature>_repository.dart      # Acceso a Firestore/SQLite SOLO de esta feature
    models/                        # Modelos específicos (los compartidos siguen en lib/data/models)
  providers/
    <feature>_providers.dart       # Providers Riverpod de la feature
  presentation/
    screens/
      <feature>_screen.dart        # Pantalla(s). Máx 400 líneas.
    widgets/
      <widget>.dart                # Widgets privados que superen 150 líneas
test/features/<feature>/
  <feature>_repository_test.dart   # con fake_cloud_firestore
  <feature>_providers_test.dart
  <feature>_screen_test.dart
```

## Repositorio
```dart
class OracionRepository {
  OracionRepository(this._db);
  final FirebaseFirestore _db;

  static const pageSize = 30;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('peticiones_oracion');

  Stream<List<PeticionOracion>> watchRecientes() => _col
      .orderBy('fecha', descending: true)
      .limit(pageSize)                       // SIEMPRE limit
      .snapshots()
      .map((s) => s.docs.map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()})).toList());

  Future<void> amen(String id) => _col.doc(id).update({'oracionesCount': FieldValue.increment(1)});
}
```
Recibe `FirebaseFirestore` por constructor (inyectable → testeable con `FakeFirebaseFirestore`).
El guard `_available` vive en el provider que construye el repo, no en cada método.

## Providers
```dart
final oracionRepositoryProvider = Provider<OracionRepository?>((ref) {
  final db = ref.watch(firestoreInstanceProvider); // null si Firebase no inicializó
  return db == null ? null : OracionRepository(db);
});

final peticionesRecientesProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final repo = ref.watch(oracionRepositoryProvider);
  return repo?.watchRecientes() ?? Stream.value(const []);
});
```

## Pantalla
- `ConsumerWidget`. Primera línea de `build`: `final isGuest = ref.watch(isGuestUserProvider);`.
- `AsyncValue.when(...)` con estados de carga (shimmer) y error visibles.
- Sin lógica de negocio: delega al notifier/repositorio.

## Test del repositorio
```dart
void main() {
  late FakeFirebaseFirestore db;
  late OracionRepository repo;
  setUp(() { db = FakeFirebaseFirestore(); repo = OracionRepository(db); });

  test('amen incrementa oracionesCount en 1', () async {
    await db.collection('peticiones_oracion').doc('p').set({'oracionesCount': 0});
    await repo.amen('p');
    expect((await db.collection('peticiones_oracion').doc('p').get())['oracionesCount'], 1);
  });
}
```

## Checklist al terminar
- [ ] Ningún archivo > 400 líneas
- [ ] Toda consulta con `.limit()`
- [ ] Si otro usuario escribe en la colección → regla + test de reglas
- [ ] `export` de compatibilidad en `app_providers.dart` si algo legacy lo importaba
