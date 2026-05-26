import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/reflexion.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtiene el stream de reflexiones ordenadas por fecha
  Stream<List<Reflexion>> getReflexiones() {
    return _db
        .collection('reflexiones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reflexion.fromFirestore(doc)).toList());
  }

  /// Publica una nueva reflexión
  Future<void> publicarReflexion(Reflexion reflexion) async {
    await _db.collection('reflexiones').add(reflexion.toMap());
  }

  /// Lógica para reaccionar (like) a una reflexión
  Future<void> toggleLike(String reflexionId, int currentLikes) async {
    await _db.collection('reflexiones').doc(reflexionId).update({'likes': currentLikes + 1});
  }
}