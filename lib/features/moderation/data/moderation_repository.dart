import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio para la feature de moderación.
/// Encapsula el acceso a FirestoreService para reportar contenido.
class ModerationRepository {
  ModerationRepository(this._firestore);

  final FirestoreService _firestore;

  /// Envía un reporte para revisión por la función de moderación.
  Future<void> reportarContenido({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    if (_firestore.firestore == null) {
      throw StateError('Firestore no está disponible para enviar el reporte.');
    }
    await _firestore.firestore!.collection('reports').add({
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
