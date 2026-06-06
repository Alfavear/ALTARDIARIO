import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/screens/anual_view.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';

Widget createAnualView(StorageService storageService) {
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storageService),
    ],
    child: const MaterialApp(home: AnualView()),
  );
}

void main() {
  group('AnualView', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renderiza encabezado de progreso', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createAnualView(storageService));
      await tester.pumpAndSettle();

      expect(find.text('Progreso Anual'), findsOneWidget);
      expect(find.text('0 de 365 lecturas'), findsOneWidget);
    });

    testWidgets('renderiza estadísticas', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createAnualView(storageService));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets); // racha y máx racha inicial
      expect(find.text('365'), findsOneWidget); // pendientes
    });

    testWidgets('renderiza grid de 12 meses', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createAnualView(storageService));
      await tester.pumpAndSettle();

      // Buscar nombres de meses
      expect(find.text('Ene'), findsOneWidget);
      expect(find.text('Dic'), findsOneWidget);
    });

    testWidgets('renderiza circular progress indicator', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createAnualView(storageService));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsAtLeast(1));
    });

    testWidgets('muestra progreso con datos mock', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'completed_dates': ['2026-01-01', '2026-01-02', '2026-01-03'],
      });
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createAnualView(storageService));
      await tester.pumpAndSettle();

      expect(find.text('Progreso Anual'), findsOneWidget);
    });
  });
}
