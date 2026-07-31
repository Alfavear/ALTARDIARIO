import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/models/bible_dictionary_term.dart';
import 'package:altar_diario/data/services/bible_dictionary_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BibleDictionaryTerm Model', () {
    test('toMap y fromMap deben serializar y deserializar correctamente', () {
      final term = const BibleDictionaryTerm(
        id: 'selah',
        palabra: 'Selah',
        origen: 'Hebreo: סֶלָה',
        significado: 'Pausa para meditar',
        definicion: 'Pausa contemplativa en los Salmos.',
        pasajes: ['Salmos 3:2', 'Salmos 46:7'],
        categoria: 'Término Hebreo',
      );

      final map = term.toMap();
      final from = BibleDictionaryTerm.fromMap(map);

      expect(from.id, 'selah');
      expect(from.palabra, 'Selah');
      expect(from.origen, 'Hebreo: סֶלָה');
      expect(from.significado, 'Pausa para meditar');
      expect(from.pasajes.length, 2);
      expect(from.categoria, 'Término Hebreo');
    });

    test('fromMap maneja campos nulos con valores por defecto', () {
      final from = BibleDictionaryTerm.fromMap({});

      expect(from.id, '');
      expect(from.palabra, '');
      expect(from.origen, '');
      expect(from.significado, '');
      expect(from.definicion, '');
      expect(from.pasajes, isEmpty);
      expect(from.categoria, 'General');
    });
  });

  group('BibleDictionaryService', () {
    test('Singleton mantiene la misma instancia', () {
      final s1 = BibleDictionaryService();
      final s2 = BibleDictionaryService();
      expect(identical(s1, s2), isTrue);
    });
  });
}
