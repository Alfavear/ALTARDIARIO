import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/services/bible_service.dart';

void main() {
  group('BibleService', () {
    group('parsePassage', () {
      test('parsea pasaje simple: "Salmos 1"', () {
        final result = BibleService().parsePassage('Salmos 1');
        expect(result, isNotNull);
        expect(result!.bookId, 19);
        expect(result.bookName, 'Salmos');
        expect(result.chapterStart, 1);
        expect(result.verseStart, isNull);
        expect(result.chapterEnd, isNull);
        expect(result.verseEnd, isNull);
      });

      test('parsea pasaje con versículo: "Juan 3:16"', () {
        final result = BibleService().parsePassage('Juan 3:16');
        expect(result, isNotNull);
        expect(result!.bookId, 43);
        expect(result.chapterStart, 3);
        expect(result.verseStart, 16);
      });

      test('parsea rango de versículos: "Salmos 1:1-3"', () {
        final result = BibleService().parsePassage('Salmos 1:1-3');
        expect(result, isNotNull);
        expect(result!.bookId, 19);
        expect(result.chapterStart, 1);
        expect(result.verseStart, 1);
        expect(result.verseEnd, 3);
      });

      test('parsea rango entre capítulos: "Isaías 9:1-10:4"', () {
        final result = BibleService().parsePassage('Isaías 9:1-10:4');
        expect(result, isNotNull);
        expect(result!.bookId, 23);
        expect(result.chapterStart, 9);
        expect(result.verseStart, 1);
        expect(result.chapterEnd, 10);
        expect(result.verseEnd, 4);
      });

      test('parsea rango de capítulos: "Romanos 1-3"', () {
        final result = BibleService().parsePassage('Romanos 1-3');
        expect(result, isNotNull);
        expect(result!.bookId, 45);
        expect(result.chapterStart, 1);
        expect(result.verseStart, isNull);
        expect(result.chapterEnd, 3);
      });

      test('rechaza entrada vacía', () {
        expect(BibleService().parsePassage(''), isNull);
      });

      test('rechaza texto sin libro válido', () {
        expect(BibleService().parsePassage('LibroFalso 1'), isNull);
      });
    });

    group('getBookNameFromId', () {
      test('devuelve nombre correcto para IDs conocidos', () {
        expect(BibleService().getBookNameFromId(1), 'Génesis');
        expect(BibleService().getBookNameFromId(19), 'Salmos');
        expect(BibleService().getBookNameFromId(40), 'Mateo');
        expect(BibleService().getBookNameFromId(66), 'Apocalipsis');
      });

      test('devuelve fallback para ID desconocido', () {
        expect(BibleService().getBookNameFromId(99), 'Libro 99');
      });
    });

    group('getBookNames', () {
      test('devuelve 66 libros', () {
        final names = BibleService().getBookNames();
        expect(names.length, 66);
      });

      test('primer libro es Génesis', () {
        final names = BibleService().getBookNames();
        expect(names.first, 'Génesis');
      });

      test('último libro es Apocalipsis', () {
        final names = BibleService().getBookNames();
        expect(names.last, 'Apocalipsis');
      });
    });

    group('_mapBookToId (indirecto via parsePassage)', () {
      test('reconoce variantes con acentos', () {
        expect(BibleService().parsePassage('Éxodo 1')?.bookId, 2);
        expect(BibleService().parsePassage('Gálatas 1')?.bookId, 48);
        expect(BibleService().parsePassage('Eclesiastés 1')?.bookId, 21);
      });

      test('reconoce abreviaturas', () {
        expect(BibleService().parsePassage('Jn 3:16')?.bookId, 43);
      });

      test('reconoce números como prefijo', () {
        expect(BibleService().parsePassage('1 Samuel 1')?.bookId, 9);
        expect(BibleService().parsePassage('2 Reyes 1')?.bookId, 12);
      });
    });

    group('getChapterAnchors', () {
      test('extrae anchors de pasajes', () {
        final service = BibleService();
        final anchors = service.getChapterAnchors([]);
        expect(anchors, isEmpty);
      });
    });
  });
}
