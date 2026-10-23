import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../data/models/peticion_oracion.dart';

/// Acceso a Firestore de la feature de oración (ADR-0001).
///
/// Durante la migración, `FirestoreService` delega en este repositorio para
/// conservar su API pública. Cuando el servicio desaparezca, este será el
/// único punto de acceso a `peticiones_oracion`.
class OracionRepository {
  OracionRepository(this._db);

  final FirebaseFirestore _db;

  /// Tamaño de página del listado. Sin límite, cada apertura de la pantalla
  /// leería la colección entera (coste y latencia lineales con las peticiones).
  static const int pageSize = 100;

  CollectionReference<Map<String, dynamic>> get _peticiones =>
      _db.collection('peticiones_oracion');

  Stream<List<PeticionOracion>> watchRecientes() {
    return _peticiones
        .orderBy('fecha', descending: true)
        .limit(pageSize)
        .snapshots()
        .map((s) => s.docs
            .map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> crear(PeticionOracion peticion) =>
      _peticiones.add(peticion.toMap());

  Future<void> amen(String peticionId) => _peticiones
      .doc(peticionId)
      .update({'oracionesCount': FieldValue.increment(1)});

  /// Peticiones filtradas por estado. Si [respondida] es null, no filtra.
  Stream<List<PeticionOracion>> watchFiltrado({bool? respondida}) {
    Query<Map<String, dynamic>> query =
        _peticiones.orderBy('fecha', descending: true).limit(pageSize);

    if (respondida != null) {
      query = query.where('respondida', isEqualTo: respondida);
    }

    return query.snapshots().map((s) => s.docs
        .map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()}))
        .toList());
  }

  Future<void> marcarComoRespondida(String peticionId, String userId) async {
    final docRef = _peticiones.doc(peticionId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    if (data['userId'] != userId) {
      throw StateError(
          'Solo el autor puede marcar la petición como respondida');
    }

    await docRef.update({
      'respondida': true,
      'fechaRespondida': FieldValue.serverTimestamp(),
    });
  }
}
