import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/reflexion.dart';
import '../../data/models/peticion_oracion.dart';
import '../../data/models/usuario.dart';
import '../../data/models/message.dart';

/// Servicio para manejar el feed social con Firestore.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reflexionesCollection =>
      _firestore.collection('reflexiones');

  CollectionReference<Map<String, dynamic>> get _peticionesCollection =>
      _firestore.collection('peticiones_oracion');

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

  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    return _reflexionesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Reflexion.fromMap({'id': d.id, ...d.data()})).toList());
  }

  Future<void> toggleLike(String reflexionId, int currentLikes) async {
    await _reflexionesCollection.doc(reflexionId).update({
      'likes': currentLikes + 1,
    });
  }

  Stream<Usuario?> getUsuario(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots().map((doc) => doc.exists ? Usuario.fromMap(doc.data()!) : null);
  }

  Future<void> crearPeticionOracion(PeticionOracion peticion) async {
    await _peticionesCollection.add(peticion.toMap());
  }

  Future<void> apoyarPeticion(String peticionId) async {
    await _peticionesCollection.doc(peticionId).update({
      'oracionesCount': FieldValue.increment(1),
    });
  }

  Stream<List<PeticionOracion>> peticionesStream() {
    return _peticionesCollection.orderBy('fecha', descending: true).snapshots().map((s) => s.docs.map((d) => PeticionOracion.fromMap({...d.data(), 'id': d.id})).toList());
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots().map((s) => s.docs.map((d) => Message.fromMap(d.data())).toList());
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
