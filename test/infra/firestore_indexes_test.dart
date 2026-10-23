import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Un `firestore.indexes.json` inválido no rompe los tests ni el analyze: solo
/// rompe el deploy de `main` (y con él las reglas y los índices de producción).
/// Este test lo caza antes de mergear.
void main() {
  test('firestore.indexes.json es válido y define el índice de chats', () {
    final file = File('firestore.indexes.json');
    expect(file.existsSync(), isTrue, reason: 'falta firestore.indexes.json');

    final texto = file.readAsStringSync();
    expect(
      texto.startsWith('\uFEFF'),
      isFalse,
      reason: 'firebase-tools no acepta un fichero con BOM',
    );

    final doc = jsonDecode(texto) as Map<String, dynamic>;
    final indexes = (doc['indexes'] as List).cast<Map<String, dynamic>>();
    expect(indexes, isNotEmpty);

    // La lista de chats consulta `participantIds` (array-contains) ordenando por
    // `lastUpdate` descendente: sin este índice, Firestore devuelve
    // failed-precondition y la lista de chats queda vacía.
    final chats =
        indexes.where((i) => i['collectionGroup'] == 'chats').toList();
    expect(
      chats,
      hasLength(1),
      reason: 'la lista de chats necesita su índice compuesto',
    );
    final campos =
        (chats.single['fields'] as List).cast<Map<String, dynamic>>();
    expect(campos, hasLength(2));
    expect(campos[0]['fieldPath'], 'participantIds');
    expect(
      campos[0]['arrayConfig'],
      'CONTAINS',
      reason: 'un campo array usa arrayConfig, no order',
    );
    expect(campos[1]['fieldPath'], 'lastUpdate');
    expect(campos[1]['order'], 'DESCENDING');

    // Índice para consulta de grupo en comentarios (búsqueda por documentId en rutaDeComentario).
    final comentarios =
        indexes.where((i) => i['collectionGroup'] == 'comentarios').toList();
    expect(
      comentarios,
      hasLength(1),
      reason: 'la consulta de grupo de comentarios necesita su índice',
    );
    final camposComentarios =
        (comentarios.single['fields'] as List).cast<Map<String, dynamic>>();
    expect(camposComentarios, hasLength(1));
    expect(camposComentarios[0]['fieldPath'], '__name__');
    expect(camposComentarios[0]['order'], 'ASCENDING');

    // Forma mínima que exige firebase-tools en todos los índices.
    for (final index in indexes) {
      expect(index['collectionGroup'], isA<String>());
      if (index['collectionGroup'] == 'comentarios') {
        expect(index['queryScope'], 'COLLECTION_GROUP');
      } else {
        expect(index['queryScope'], 'COLLECTION');
      }
      expect(index['fields'], isA<List>());
    }
  });
}
