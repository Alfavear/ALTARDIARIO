content = open('lib/data/services/firestore_service.dart', 'r', encoding='utf-8').read()

old = """  Future<void> toggleReplyVote(
      String debateId, String replyId, String userId, bool hasVoted) async {
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

  // 🎭 Reacciones"""

new = """  Future<void> toggleReplyVote(
      String debateId, String replyId, String userId, bool hasVoted) async {
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

  /// Oculta una reflexión (moderación).
  Future<void> ocultarReflexion(String reflexionId) async {
    if (!_available) return;
    await _reflexiones.doc(reflexionId).update({'oculto': true});
  }

  /// Oculta una petición de oración (moderación).
  Future<void> ocultarPeticion(String peticionId) async {
    if (!_available) return;
    await _peticiones.doc(peticionId).update({'oculto': true});
  }

  /// Oculta un debate (moderación).
  Future<void> ocultarDebate(String debateId) async {
    if (!_available) return;
    await _debates.doc(debateId).update({'oculto': true});
  }

  /// Oculta un comentario de reflexión (moderación).
  Future<void> ocultarComentario(String reflexionId, String comentarioId) async {
    if (!_available) return;
    await _reflexiones.doc(reflexionId).collection('comentarios').doc(comentarioId).update({'oculto': true});
  }

  /// Oculta una respuesta de debate (moderación).
  Future<void> ocultarRespuestaDebate(String debateId, String respuestaId) async {
    if (!_available) return;
    await _debateReplies(debateId).doc(respuestaId).update({'oculto': true});
  }

  // 🎭 Reacciones"""

if old in content:
    content = content.replace(old, new, 1)
    open('lib/data/services/firestore_service.dart', 'w', encoding='utf-8').write(content)
    print('Done')
else:
    print('Not found')