import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reflexion.dart';
import '../models/peticion_oracion.dart';
import '../models/usuario.dart';
import '../models/message.dart';
import '../models/bible_models.dart';

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

  // ── Usuarios ─────────────────────────────────────────────────────────────

  Stream<Usuario?> getUsuario(String uid) {
    if (!_available) return Stream.value(null);
    return _usuarios.doc(uid).snapshots().map(
        (d) => d.exists ? Usuario.fromMap({'id': d.id, ...d.data()!}) : null);
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
      await currentDoc.update({
        'siguiendo': FieldValue.arrayRemove([targetUserId])
      });
      await targetDoc.update({
        'seguidores': FieldValue.arrayRemove([currentUserId])
      });
    } else {
      await currentDoc.update({
        'siguiendo': FieldValue.arrayUnion([targetUserId])
      });
      await targetDoc.update({
        'seguidores': FieldValue.arrayUnion([currentUserId])
      });
    }
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
