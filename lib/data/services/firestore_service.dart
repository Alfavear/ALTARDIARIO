import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reflexion.dart';
import '../models/peticion_oracion.dart';
import '../models/usuario.dart';
import '../models/message.dart';

/// Servicio centralizado para todas las operaciones con Firestore.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Colecciones ──────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _reflexiones =>
      _firestore.collection('reflexiones');

  CollectionReference<Map<String, dynamic>> get _peticiones =>
      _firestore.collection('peticiones_oracion');

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore.collection('usuarios');

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  // ── Reflexiones ──────────────────────────────────────────────────────────

  Stream<List<Reflexion>> reflexionesStream() {
    return _reflexiones
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> publicarReflexion(Reflexion reflexion) async {
    await _reflexiones.add(reflexion.toMap());
  }

  Future<void> toggleLike(String reflexionId, int currentLikes) async {
    await _reflexiones
        .doc(reflexionId)
        .update({'likes': currentLikes + 1});
  }

  // ── Usuarios ─────────────────────────────────────────────────────────────

  Stream<Usuario?> getUsuario(String uid) {
    return _usuarios
        .doc(uid)
        .snapshots()
        .map((d) => d.exists ? Usuario.fromMap({'id': d.id, ...d.data()!}) : null);
  }

  Future<void> crearOActualizarUsuario(Usuario usuario) async {
    await _usuarios.doc(usuario.id).set(usuario.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleFollow(
      String currentUserId, String targetUserId, bool isFollowing) async {
    final currentDoc = _usuarios.doc(currentUserId);
    final targetDoc = _usuarios.doc(targetUserId);

    if (isFollowing) {
      await currentDoc
          .update({'siguiendo': FieldValue.arrayRemove([targetUserId])});
      await targetDoc
          .update({'seguidores': FieldValue.arrayRemove([currentUserId])});
    } else {
      await currentDoc
          .update({'siguiendo': FieldValue.arrayUnion([targetUserId])});
      await targetDoc
          .update({'seguidores': FieldValue.arrayUnion([currentUserId])});
    }
  }

  /// Sincroniza el progreso local de lectura en la nube.
  Future<void> syncProgress(
      String userId, List<String> completedDates, int maxStreak) async {
    await _usuarios.doc(userId).set({
      'progresoLectura': completedDates,
      'maxStreak': maxStreak,
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ── Peticiones de Oración ────────────────────────────────────────────────

  Stream<List<PeticionOracion>> peticionesStream() {
    return _peticiones
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> crearPeticionOracion(PeticionOracion peticion) async {
    await _peticiones.add(peticion.toMap());
  }

  Future<void> apoyarPeticion(String peticionId) async {
    await _peticiones
        .doc(peticionId)
        .update({'oracionesCount': FieldValue.increment(1)});
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  Stream<List<Message>> getMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => Message.fromMap({'id': d.id, ...d.data()})).toList());
  }

  Future<void> sendMessage(
      String chatId, String senderId, String text) async {
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).set(
        {'lastUpdate': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }
}
