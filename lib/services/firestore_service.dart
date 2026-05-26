import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/reflexion.dart';

/// Servicio para manejar el feed social con Firestore.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reflexionesCollection =>
      _firestore.collection('reflexiones');

  Stream<List<Reflexion>> reflexionesStream() {
    return _reflexionesCollection
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Reflexion.fromMap({
                'id': doc.id,
                ...data,
              });
            }).toList());
  }

  Future<void> publicarReflexion(Reflexion reflexion) async {
    await _reflexionesCollection.doc(reflexion.id).set(reflexion.toMap());
  }
}
