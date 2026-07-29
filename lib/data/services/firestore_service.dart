import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reflexion.dart';
import '../models/comment.dart';
import '../models/debate.dart';
import '../models/debate_reply.dart';
import '../models/peticion_oracion.dart';
import '../models/usuario.dart';
import '../models/message.dart';
import '../models/bible_models.dart';
import '../models/note.dart';

class FirestoreService {
  final FirebaseFirestore? _firestore;

  FirestoreService() : _firestore = _initFirestore();

  static FirebaseFirestore? _initFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  bool get _available => _firestore != null;

  FirebaseFirestore? get firestore => _firestore;

  CollectionReference<Map<String, dynamic>> get _reflexiones =>
      _firestore!.collection('reflexiones');

  CollectionReference<Map<String, dynamic>> get _peticiones =>
      _firestore!.collection('peticiones_oracion');

  CollectionReference<Map<String, dynamic>> get _usuarios =>
      _firestore!.collection('usuarios');

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore!.collection('chats');

  CollectionReference<Map<String, dynamic>> _bibleHighlights(String userId) =>
      _usuarios.doc(userId).collection('bible_highlights');

  CollectionReference<Map<String, dynamic>> get _debates =>
      _firestore!.collection('debates');

  CollectionReference<Map<String, dynamic>> _debateReplies(String debateId) =>
      _debates.doc(debateId).collection('respuestas');

  CollectionReference<Map<String, dynamic>> _bibleNotes(String userId) =>
      _usuarios.doc(userId).collection('bible_notes');

  // ── Reflexiones ──────────────────────────────────────────────────────────

  Stream<List<Reflexion>> reflexionesStream() {
    if (!_available) return Stream.value([]);
    return _reflexiones.orderBy('fecha', descending: true).snapshots().map(
        (s) => s.docs
            .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
            .toList()).handleError((_) => <Reflexion>[]);
  }

  Stream<List<Reflexion>> getUserReflexiones(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
            .toList()).handleError((_) => <Reflexion>[]);
  }

  Future<void> publicarReflexion(Reflexion reflexion) async {
    if (!_available) return;
    await _reflexiones.add(reflexion.toMap());
  }

  Future<void> toggleLike(String reflexionId, String userId, bool isLiked) async {
    if (!_available) return;
    if (isLiked) {
      await _reflexiones.doc(reflexionId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _reflexiones.doc(reflexionId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  Stream<List<Reflexion>> getUserReflexionesWithUid(String userId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
            .toList()).handleError((_) => <Reflexion>[]);
  }

  Future<List<Reflexion>> getUserReflexionesOnce(String userId) async {
    if (!_available) return [];
    final snapshot = await _reflexiones
        .where('userId', isEqualTo: userId)
        .orderBy('fecha', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((d) => Reflexion.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  // ── Comentarios ──────────────────────────────────────────────────────────

  Stream<List<Comment>> comentariosStream(String reflexionId) {
    if (!_available) return Stream.value([]);
    return _reflexiones
        .doc(reflexionId)
        .collection('comentarios')
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Comment.fromMap({'id': d.id, ...d.data()}))
            .toList()).handleError((_) => <Comment>[]);
  }

  Future<void> publicarComentario(Comment comment) async {
    if (!_available) return;
    await _reflexiones
        .doc(comment.reflexionId)
        .collection('comentarios')
        .add(comment.toMap());
    await _reflexiones.doc(comment.reflexionId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<void> toggleCommentLike(
      String reflexionId, String commentId, String userId, bool isLiked) async {
    if (!_available) return;
    if (isLiked) {
      await _reflexiones
          .doc(reflexionId)
          .collection('comentarios')
          .doc(commentId)
          .update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _reflexiones
          .doc(reflexionId)
          .collection('comentarios')
          .doc(commentId)
          .update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // ── Debates Bíblicos ─────────────────────────────────────────────────────

  Stream<List<Debate>> debatesStream({String? libroId}) {
    if (!_available) return Stream.value([]);
    var query = _debates.orderBy('fecha', descending: true) as Query;
    if (libroId != null && libroId.isNotEmpty) {
      query = query.where('libroId', isEqualTo: libroId);
    }
    return query.snapshots().map(
        (s) => s.docs
            .map((d) => Debate.fromMap({'id': d.id, ...d.data() as Map<String, dynamic>}))
            .toList()).handleError((_) => <Debate>[]);
  }

  Future<void> crearDebate(Debate debate) async {
    if (!_available) return;
    await _debates.add(debate.toMap());
  }

  Future<void> toggleDebateVote(
      String debateId, String userId, bool hasVoted) async {
    if (!_available) return;
    if (hasVoted) {
      await _debates.doc(debateId).update({
        'upvotes': FieldValue.increment(-1),
        'votedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _debates.doc(debateId).update({
        'upvotes': FieldValue.increment(1),
        'votedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // ── Respuestas de Debates ────────────────────────────────────────────────

  Stream<List<DebateReply>> debateRepliesStream(String debateId) {
    if (!_available) return Stream.value([]);
    return _debateReplies(debateId)
        .orderBy('fecha', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => DebateReply.fromMap({'id': d.id, ...d.data()}))
            .toList()).handleError((_) => <DebateReply>[]);
  }

  Future<void> crearRespuesta(DebateReply reply) async {
    if (!_available) return;
    await _debateReplies(reply.debateId).add(reply.toMap());
    await _debates.doc(reply.debateId).update({
      'replyCount': FieldValue.increment(1),
    });
  }

  Future<void> toggleReplyVote(String debateId, String replyId,
      String userId, bool hasVoted) async {
    if (!_available) return;
    if (hasVoted) {
      await _debateReplies(debateId).doc(replyId).update({
        'upvotes': FieldValue.increment(-1),
        'votedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      await _debateReplies(debateId).doc(replyId).update({
        'upvotes': FieldValue.increment(1),
        'votedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // ── Reacciones ───────────────────────────────────────────────────────────

  Future<void> toggleReaction(String reflexionId, String userId,
      String? emoji, String? currentEmoji) async {
    if (!_available) return;
    if (currentEmoji == emoji) {
      await _reflexiones.doc(reflexionId).update({
        'reactions.$userId': FieldValue.delete(),
      });
    } else {
      await _reflexiones.doc(reflexionId).update({
        'reactions.$userId': emoji,
      });
    }
  }

  // ── Usuarios ─────────────────────────────────────────────────────────────

  Stream<Usuario?> getUsuario(String uid) {
    if (!_available) return Stream.value(null);
    return _usuarios.doc(uid).snapshots().map(
        (d) => d.exists ? Usuario.fromMap({'id': d.id, ...d.data()!}) : null);
  }

  Future<Usuario?> getUsuarioOnce(String uid) async {
    if (!_available) return null;
    final doc = await _usuarios.doc(uid).get();
    if (!doc.exists) return null;
    return Usuario.fromMap({'id': doc.id, ...doc.data()!});
  }

  Stream<List<Usuario>> getUsuariosStream(List<String> uids) {
    if (!_available) return Stream.value([]);
    if (uids.isEmpty) return Stream.value([]);
    return _usuarios
        .where(FieldPath.documentId, whereIn: uids)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Usuario.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<List<Usuario>> getSiguiendoUsuarios(String uid) async {
    if (!_available) return [];
    final usuario = await getUsuarioOnce(uid);
    if (usuario == null || usuario.siguiendo.isEmpty) return [];
    final snapshot = await _usuarios
        .where(FieldPath.documentId, whereIn: usuario.siguiendo)
        .get();
    return snapshot.docs
        .map((d) => Usuario.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<Usuario>> getAllUsuarios() async {
    if (!_available) return [];
    final snapshot = await _usuarios.limit(100).get();
    return snapshot.docs
        .map((d) => Usuario.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<List<Usuario>> getSeguidoresUsuarios(String uid) async {
    if (!_available) return [];
    final usuario = await getUsuarioOnce(uid);
    if (usuario == null || usuario.seguidores.isEmpty) return [];
    final snapshot = await _usuarios
        .where(FieldPath.documentId, whereIn: usuario.seguidores)
        .get();
    return snapshot.docs
        .map((d) => Usuario.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  /// Obtiene datos de racha (progresoLectura, maxStreak) para una lista de usuarios.
  /// Usado para las rachas entre amigos y el leaderboard.
  Future<Map<String, Map<String, dynamic>>> getStreaksData(
      List<String> uids) async {
    if (!_available || uids.isEmpty) return {};
    final result = <String, Map<String, dynamic>>{};
    final snapshot = await _usuarios
        .where(FieldPath.documentId, whereIn: uids)
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      result[doc.id] = {
        'nombre': data['nombre'] ?? 'Anónimo',
        'fotoUrl': data['fotoUrl'] ?? '',
        'progresoLectura': List<String>.from(data['progresoLectura'] ?? []),
        'maxStreak': data['maxStreak'] ?? 0,
      };
    }
    return result;
  }

  Future<void> crearOActualizarUsuario(Usuario usuario) async {
    if (!_available) return;
    await _usuarios
        .doc(usuario.id)
        .set(usuario.toMap(), SetOptions(merge: true));
  }

  Future<void> toggleFollow(
      String currentUserId, String targetUserId, bool isFollowing) async {
    if (!_available) return;
    final currentDoc = _usuarios.doc(currentUserId);
    final targetDoc = _usuarios.doc(targetUserId);

    if (isFollowing) {
      await currentDoc.set({
        'siguiendo': FieldValue.arrayRemove([targetUserId])
      }, SetOptions(merge: true));
      await targetDoc.set({
        'seguidores': FieldValue.arrayRemove([currentUserId])
      }, SetOptions(merge: true));
    } else {
      await currentDoc.set({
        'siguiendo': FieldValue.arrayUnion([targetUserId])
      }, SetOptions(merge: true));
      await targetDoc.set({
        'seguidores': FieldValue.arrayUnion([currentUserId])
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateUserConfig(String uid, Map<String, dynamic> config) async {
    if (!_available) return;
    await _usuarios.doc(uid).set(config, SetOptions(merge: true));
  }

  Future<void> syncProgress(
      String userId, List<String> completedDates, int maxStreak) async {
    if (!_available) return;
    await _usuarios.doc(userId).set({
      'progresoLectura': completedDates,
      'maxStreak': maxStreak,
      'lastSync': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Guarda el token FCM del usuario para push notifications.
  Future<void> saveFCMToken(String uid, String token) async {
    if (!_available) return;
    await _usuarios.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
  }

  /// Elimina el token FCM del usuario (logout).
  Future<void> clearFCMToken(String uid) async {
    if (!_available) return;
    await _usuarios.doc(uid).set({'fcmToken': FieldValue.delete()}, SetOptions(merge: true));
  }

  /// Crea una notificación en la subcolección del usuario (para Cloud Functions).
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, String>? data,
    String? actorId,
    String? actorName,
    String? actorFotoUrl,
  }) async {
    if (!_available) return;
    await _usuarios.doc(userId).collection('notifications').add({
      'type': type,
      'title': title,
      'body': body,
      'data': data ?? {},
      'actorId': actorId,
      'actorName': actorName,
      'actorFotoUrl': actorFotoUrl ?? '',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream de notificaciones del usuario.
  Stream<List<Map<String, dynamic>>> notificationsStream(String uid) {
    if (!_available) return Stream.value([]);
    return _usuarios
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList())
        .handleError((_) => <Map<String, dynamic>>[]);
  }

  /// Marca una notificación como leída.
  Future<void> markNotificationAsRead(String uid, String notificationId) async {
    if (!_available) return;
    await _usuarios.doc(uid).collection('notifications').doc(notificationId).update({'read': true});
  }

  /// Marca todas las notificaciones como leídas.
  Future<void> markAllNotificationsAsRead(String uid) async {
    if (!_available) return;
    final snapshot = await _usuarios
        .doc(uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .get();
    final batch = _firestore!.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  // ── Biblia: Subrayados y Notas ──────────────────────────────────────────────

  Future<void> syncBibleHighlight(
    String userId,
    BibleHighlight highlight,
  ) async {
    if (!_available) return;
    await _bibleHighlights(userId).doc(highlight.id).set(
          highlight.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }

  Future<List<BibleHighlight>> getBibleHighlightsForAnchors(
    String userId,
    List<BibleChapterAnchor> anchors,
  ) async {
    if (!_available) return [];
    final highlights = <BibleHighlight>[];
    for (final anchor in anchors) {
      final snapshot = await _bibleHighlights(userId)
          .where('version', isEqualTo: anchor.version)
          .where('bookId', isEqualTo: anchor.bookId)
          .where('chapter', isEqualTo: anchor.chapter)
          .get();

      highlights.addAll(snapshot.docs.map((doc) {
        return BibleHighlight.fromFirestoreMap(
          id: doc.id,
          userId: userId,
          map: doc.data(),
        );
      }));
    }
    return highlights;
  }

  Future<void> deleteBibleHighlight(
    String userId,
    String highlightId,
  ) async {
    if (!_available) return;
    await _bibleHighlights(userId).doc(highlightId).delete();
  }

  Future<void> syncBibleNote(String userId, BibleNote note) async {
    if (!_available) return;
    await _bibleNotes(userId).doc(note.id).set(
          note.toFirestoreMap(),
          SetOptions(merge: true),
        );
  }

  Future<List<BibleNote>> getBibleNotesForAnchors(
    String userId,
    List<BibleChapterAnchor> anchors,
  ) async {
    if (!_available) return [];
    final notes = <BibleNote>[];
    for (final anchor in anchors) {
      final snapshot = await _bibleNotes(userId)
          .where('version', isEqualTo: anchor.version)
          .where('bookId', isEqualTo: anchor.bookId)
          .where('chapter', isEqualTo: anchor.chapter)
          .get();

      notes.addAll(snapshot.docs.map((doc) {
        return BibleNote.fromFirestoreMap(
          id: doc.id,
          userId: userId,
          map: doc.data(),
        );
      }));
    }
    return notes;
  }

  Future<void> deleteBibleNote(String userId, String noteId) async {
    if (!_available) return;
    await _bibleNotes(userId).doc(noteId).delete();
  }

  // ── Peticiones de Oración ────────────────────────────────────────────────

  Stream<List<PeticionOracion>> peticionesStream() {
    if (!_available) return Stream.value([]);
    return _peticiones.orderBy('fecha', descending: true).snapshots().map((s) =>
        s.docs
            .map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> crearPeticionOracion(PeticionOracion peticion) async {
    if (!_available) return;
    await _peticiones.add(peticion.toMap());
  }

  Future<void> apoyarPeticion(String peticionId) async {
    if (!_available) return;
    await _peticiones
        .doc(peticionId)
        .update({'oracionesCount': FieldValue.increment(1)});
  }

  // ── Feedback ─────────────────────────────────────────────────────────────

  Future<void> sendFeedback({
    required String userId,
    required String userName,
    required String mensaje,
    int calificacion = 0,
  }) async {
    if (!_available) return;
    await _firestore!.collection('feedback').add({
      'userId': userId,
      'userName': userName,
      'mensaje': mensaje,
      'calificacion': calificacion,
      'fecha': FieldValue.serverTimestamp(),
      'appVersion': '1.0.0',
    });
  }

  // ── Notas generales ──────────────────────────────────────────────────────

  Future<void> syncNote(String userId, Note note) async {
    if (!_available) return;
    await _usuarios
        .doc(userId)
        .collection('notes')
        .doc(note.id)
        .set(note.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteNoteFromFirestore(String userId, String noteId) async {
    if (!_available) return;
    await _usuarios.doc(userId).collection('notes').doc(noteId).delete();
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  Stream<List<Message>> getMessages(String chatId) {
    if (!_available) return Stream.value([]);
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Message.fromMap({'id': d.id, ...d.data()}))
            .toList());
  }

  Future<void> sendMessage(
    String chatId,
    String senderId,
    String text, {
    List<String>? participantIds,
    Map<String, String>? participantNames,
  }) async {
    if (!_available) return;
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await _chats.doc(chatId).set({
      'lastUpdate': FieldValue.serverTimestamp(),
      'lastMessage': text,
      'lastSenderId': senderId,
      if (participantIds != null) 'participantIds': participantIds,
      if (participantNames != null) 'participantNames': participantNames,
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String userId) {
    if (!_available) return Stream.value([]);
    return _chats
        .where('participantIds', arrayContains: userId)
        .orderBy('lastUpdate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
