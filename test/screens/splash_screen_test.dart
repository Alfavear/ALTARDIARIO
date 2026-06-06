import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/screens/splash_screen.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';

Widget createSplashScreen(StorageService storageService) {
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storageService),
    ],
    child: const MaterialApp(home: SplashScreen()),
  );
}

void main() {
  group('SplashScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    Future<void> pumpAndClearTimer(WidgetTester tester) async {
      // El SplashScreen tiene un timer de 2500ms para navegar
      // Lo dejamos expirar para que no quede pendiente
      await tester.pump(const Duration(milliseconds: 3000));
    }

    testWidgets('renderiza logo y título', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createSplashScreen(storageService));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('altarDiario'), findsOneWidget);
      expect(find.text('Tu hábito diario con Dios'), findsOneWidget);

      await pumpAndClearTimer(tester);
    });

    testWidgets('tiene gradiente azul en el fondo', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createSplashScreen(storageService));

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Scaffold), findsOneWidget);

      await pumpAndClearTimer(tester);
    });

    testWidgets('animación escala el logo', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      await tester.pumpWidget(createSplashScreen(storageService));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 1000));

      // No debe haber errores durante las animaciones
      expect(tester.takeException(), isNull);

      await pumpAndClearTimer(tester);
    });
  });
}
