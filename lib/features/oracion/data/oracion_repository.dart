import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Repositorio para la feature de oración.
/// Encapsula el acceso a FirestoreService para peticiones de oración.
class OracionRepository {
  OracionRepository(this._firestore);

  final FirestoreService _firestore;

  /// Stream de todas las peticiones de oración.
  Stream<List<PeticionOracion>> peticionesStream() {
    return _firestore.peticionesStream();
  }

  /// Stream de peticiones filtradas por estado (respondida/pendiente).
  Stream<List<PeticionOracion>> peticionesStreamFiltrado({bool? respondida}) {
    return _firestore.peticionesStreamFiltrado(respondida: respondida);
  }

  /// Crea una nueva petición de oración.
  Future<void> crearPeticionOracion(PeticionOracion peticion) {
    return _firestore.crearPeticionOracion(peticion);
  }

  /// Marca una petición como respondida (solo el autor).
  Future<void> marcarPeticionComoRespondida(String peticionId, String uid) {
    return _firestore.marcarPeticionComoRespondida(peticionId, uid);
  }

  /// Apoya una petición (incrementa oracionesCount).
  Future<void> apoyarPeticion(String peticionId) {
    return _firestore.apoyarPeticion(peticionId);
  }
}

/// Provider del repositorio de oración.
final oracionRepositoryProvider = Provider<OracionRepository>((ref) {
  return OracionRepository(ref.watch(firestoreServiceProvider));
});
