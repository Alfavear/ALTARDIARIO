import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/models/bible_models.dart';

void main() {
  group('BibleVersion', () {
    test('crea versión correctamente', () {
      final v = BibleVersion(id: 'rv1909', name: 'Reina Valera 1909', lang: 'es');
      expect(v.id, 'rv1909');
      expect(v.name, 'Reina Valera 1909');
      expect(v.lang, 'es');
      expect(v.offline, true);
    });

    test('offline se puede personalizar', () {
      final v = BibleVersion(id: 'nvi', name: 'NVI', lang: 'es', offline: false);
      expect(v.offline, false);
    });
  });

  group('BibleVerse', () {
    test('fromMap crea instancia correctamente', () {
      final v = BibleVerse.fromMap({
        'version': 'rv1909',
        'book_id': 19,
        'book_name': 'Salmos',
        'chapter': 1,
        'verse': 1,
        'text': 'Bienaventurado el varón...',
      });
      expect(v.version, 'rv1909');
      expect(v.bookId, 19);
      expect(v.bookName, 'Salmos');
      expect(v.chapter, 1);
      expect(v.verse, 1);
      expect(v.text, 'Bienaventurado el varón...');
    });

    test('reference devuelve formato correcto', () {
      final v = BibleVerse.fromMap({
        'version': 'rv1909',
        'book_id': 1,
        'book_name': 'Génesis',
        'chapter': 1,
        'verse': 1,
        'text': 'En el principio...',
      });
      expect(v.reference, 'Génesis 1:1');
    });

    test('anchor devuelve formato correcto', () {
      final v = BibleVerse.fromMap({
        'version': 'rv1909',
        'book_id': 1,
        'book_name': 'Génesis',
        'chapter': 1,
        'verse': 1,
        'text': 'En el principio...',
      });
      expect(v.anchor, 'rv1909:1:1:1');
    });

    test('toMap produce el mapa correcto', () {
      final v = BibleVerse(
        version: 'rv1909',
        bookId: 19,
        bookName: 'Salmos',
        chapter: 1,
        verse: 1,
        text: 'Texto de prueba',
      );
      final map = v.toMap();
      expect(map['version'], 'rv1909');
      expect(map['book_id'], 19);
      expect(map['book_name'], 'Salmos');
      expect(map['chapter'], 1);
      expect(map['verse'], 1);
      expect(map['text'], 'Texto de prueba');
    });
  });

  group('BiblePassage', () {
    test('hasText es true cuando hay versículos', () {
      final p = BiblePassage(
        reference: 'Salmos 1',
        verses: [
          BibleVerse(
            version: 'rv1909', bookId: 19,
            bookName: 'Salmos', chapter: 1,
            verse: 1, text: 'Texto',
          ),
        ],
      );
      expect(p.hasText, true);
    });

    test('hasText es false cuando no hay versículos', () {
      final p = BiblePassage(
        reference: 'Salmos 1',
        verses: [],
      );
      expect(p.hasText, false);
    });
  });

  group('BibleChapterAnchor', () {
    test('key devuelve formato correcto', () {
      final a = BibleChapterAnchor(version: 'rv1909', bookId: 19, chapter: 1);
      expect(a.key, 'rv1909:19:1');
    });
  });

  group('BibleHighlight', () {
    final now = DateTime(2026, 6, 6);

    test('contains detecta versículos dentro del rango', () {
      final h = BibleHighlight(
        id: 'hl_001', userId: 'u1',
        version: 'rv1909', bookId: 19, chapter: 1,
        verseStart: 1, verseEnd: 3,
        colorHex: '#FFF59D', createdAt: now, updatedAt: now,
        syncStatus: 'synced',
      );
      final inside = BibleVerse(
        version: 'rv1909', bookId: 19,
        bookName: 'Salmos', chapter: 1,
        verse: 2, text: 'Texto',
      );
      final outside = BibleVerse(
        version: 'rv1909', bookId: 19,
        bookName: 'Salmos', chapter: 1,
        verse: 5, text: 'Texto',
      );
      expect(h.contains(inside), true);
      expect(h.contains(outside), false);
    });

    test('toFirestoreMap produce campos camelCase', () {
      final h = BibleHighlight(
        id: 'hl_001', userId: 'u1',
        version: 'rv1909', bookId: 19, chapter: 1,
        verseStart: 1, verseEnd: 2,
        colorHex: '#FFF59D', createdAt: now, updatedAt: now,
        syncStatus: 'synced',
      );
      final map = h.toFirestoreMap();
      expect(map['version'], 'rv1909');
      expect(map['bookId'], 19);
      expect(map['verseStart'], 1);
      expect(map.containsKey('createdAt'), true);
    });
  });

  group('BibleNote', () {
    final now = DateTime(2026, 6, 6);

    test('reference devuelve formato correcto', () {
      final n = BibleNote(
        id: 'note_001', userId: 'u1',
        version: 'rv1909', bookId: 19, bookName: 'Salmos',
        chapter: 1, verse: 2,
        body: 'Nota de prueba',
        createdAt: now, updatedAt: now,
        syncStatus: 'local',
      );
      expect(n.reference, 'Salmos 1:2');
    });
  });
}
