import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/reflexion.dart';
import '../data/models/message.dart';
import '../data/models/usuario.dart';
import '../data/models/peticion_oracion.dart';

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

  /// Obtiene las reflexiones de un usuario específico
  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    return _db
        .collection('reflexiones')
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Reflexion.fromFirestore(doc)).toList());
  }

  /// Obtiene el perfil de un usuario específico
  Stream<Usuario?> getUsuario(String uid) {
    return _db
        .collection('usuarios')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? Usuario.fromFirestore(doc) : null);
  }

  /// Publica una nueva reflexión
  Future<void> publicarReflexion(Reflexion reflexion) async {
    await _db.collection('reflexiones').add(reflexion.toMap());
  }

  /// Lógica para reaccionar (like) a una reflexión
  Future<void> toggleLike(String reflexionId, int currentLikes) async {
    await _db.collection('reflexiones').doc(reflexionId).update({'likes': currentLikes + 1});
  }

  /// Seguir o dejar de seguir a un usuario
  Future<void> toggleFollow(String currentUserId, String targetUserId, bool isFollowing) async {
    final currentUserDoc = _db.collection('usuarios').doc(currentUserId);
    final targetUserDoc = _db.collection('usuarios').doc(targetUserId);

    if (isFollowing) {
      await currentUserDoc.update({'siguiendo': FieldValue.arrayRemove([targetUserId])});
      await targetUserDoc.update({'seguidores': FieldValue.arrayRemove([currentUserId])});
    } else {
      await currentUserDoc.update({'siguiendo': FieldValue.arrayUnion([targetUserId])});
      await targetUserDoc.update({'seguidores': FieldValue.arrayUnion([currentUserId])});
    }
  }

  /// Sincroniza el progreso local con la nube
  Future<void> syncProgress(String userId, List<String> completedDates, int maxStreak) async {
    await _db.collection('usuarios').doc(userId).set({
      'progresoLectura': completedDates,
      'maxStreak': maxStreak,
      'lastSync': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Obtener mensajes de un chat específico
  Stream<List<Message>> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  /// Obtiene el stream de peticiones de oración
  Stream<List<PeticionOracion>> getPeticionesOracion() {
    return _db
        .collection('peticiones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PeticionOracion.fromFirestore(doc)).toList());
  }

  /// Crear una nueva petición de oración
  Future<void> crearPeticionOracion(PeticionOracion peticion) async {
    await _db.collection('peticiones').add(peticion.toMap());
  }

  /// Incrementar el contador de "Amén" / Apoyo en oración
  Future<void> apoyarPeticion(String peticionId) async {
    await _db.collection('peticiones').doc(peticionId).update({
      'oracionesCount': FieldValue.increment(1),
    });
  }

  /// Enviar un mensaje
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final message = Message(
      id: '',
      senderId: senderId,
      text: text,
      timestamp: DateTime.now(),
    );
    await _db.collection('chats').doc(chatId).collection('messages').add(message.toMap());
    await _db.collection('chats').doc(chatId).set({'lastUpdate': Timestamp.now()}, SetOptions(merge: true));
  }
}