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

    // Forma mínima que exige firebase-tools en todos los índices.
    for (final index in indexes) {
      expect(index['collectionGroup'], isA<String>());
      expect(index['queryScope'], 'COLLECTION');
      expect(index['fields'], isA<List>());
    }
  });

  test('cada consulta con where oculto == false tiene su índice compuesto', () {
    // Firestore exige un índice compuesto para «igualdad + orderBy sobre otro campo».
    // Ni fake_cloud_firestore ni el emulador lo comprueban: sin el índice la consulta
    // falla SOLO en producción (failed-precondition) y la pantalla queda en error.
    final doc = jsonDecode(File('firestore.indexes.json').readAsStringSync())
        as Map<String, dynamic>;
    final indexes = (doc['indexes'] as List).cast<Map<String, dynamic>>();

    bool existe(String coleccion, List<String> campos, List<String> orden) {
      return indexes.any((i) {
        if (i['collectionGroup'] != coleccion) return false;
        final f = (i['fields'] as List).cast<Map<String, dynamic>>();
        if (f.length != campos.length) return false;
        for (var k = 0; k < campos.length; k++) {
          if (f[k]['fieldPath'] != campos[k] || f[k]['order'] != orden[k]) {
            return false;
          }
        }
        return true;
      });
    }

    const asc = 'ASCENDING';
    const desc = 'DESCENDING';
    final requeridos = <String, bool>{
      'reflexiones (oculto, fecha↓): feed': existe(
        'reflexiones',
        ['oculto', 'fecha'],
        [asc, desc],
      ),
      'reflexiones (userId, oculto, fecha↓): reflexiones de un usuario': existe(
        'reflexiones',
        ['userId', 'oculto', 'fecha'],
        [asc, asc, desc],
      ),
      'comentarios (oculto, fecha↑)': existe(
        'comentarios',
        ['oculto', 'fecha'],
        [asc, asc],
      ),
      'debates (oculto, fecha↓)': existe(
        'debates',
        ['oculto', 'fecha'],
        [asc, desc],
      ),
      'debates (libroId, oculto, fecha↓): debates de un libro': existe(
        'debates',
        ['libroId', 'oculto', 'fecha'],
        [asc, asc, desc],
      ),
      'respuestas (oculto, fecha↑)': existe(
        'respuestas',
        ['oculto', 'fecha'],
        [asc, asc],
      ),
      'peticiones_oracion (oculto, fecha↓)': existe(
        'peticiones_oracion',
        ['oculto', 'fecha'],
        [asc, desc],
      ),
    };
    final faltan =
        requeridos.entries.where((e) => !e.value).map((e) => e.key).toList();
    expect(faltan, isEmpty, reason: 'faltan índices compuestos: $faltan');
  });
}
