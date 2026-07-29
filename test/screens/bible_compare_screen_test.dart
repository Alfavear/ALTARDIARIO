import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:altar_diario/presentation/screens/bible_compare_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BibleCompareScreen', () {
    testWidgets('renderiza correctamente el comparador de versiones con pasaje y pestañas', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BibleCompareScreen(pasaje: 'Salmos 23:1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comparar Versiones'), findsOneWidget);
      expect(find.text('Salmos 23:1'), findsOneWidget);
      expect(find.text('Vista Paralela'), findsOneWidget);
      expect(find.text('Versículo por Versículo'), findsOneWidget);
    });

    testWidgets('cambia de pestaña a Versículo por Versículo', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BibleCompareScreen(pasaje: 'Juan 3:16'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final tabVerse = find.text('Versículo por Versículo');
      expect(tabVerse, findsOneWidget);
      await tester.tap(tabVerse);
      await tester.pumpAndSettle();

      expect(find.text('Juan 3:16'), findsOneWidget);
    });
  });
}
