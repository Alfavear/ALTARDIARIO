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
}
