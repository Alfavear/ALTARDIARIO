import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/main.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';

Widget createTestApp(StorageService storageService) {
  return ProviderScope(
    overrides: [
      storageProvider.overrideWithValue(storageService),
    ],
    child: const AltarDiarioApp(),
  );
}

void main() {
  Future<void> pumpAndClearTimer(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 3000));
  }

  testWidgets('App muestra SplashScreen en inicio', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    await tester.pumpWidget(createTestApp(storageService));

    expect(find.text('altarDiario'), findsOneWidget);
    expect(find.text('Tu hábito diario con Dios'), findsOneWidget);

    await pumpAndClearTimer(tester);
  });

  testWidgets('App usa MaterialApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    await tester.pumpWidget(createTestApp(storageService));

    expect(find.byType(MaterialApp), findsOneWidget);

    await pumpAndClearTimer(tester);
  });
}
