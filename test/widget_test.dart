// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/main.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Configuramos valores iniciales para SharedPreferences en el test
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);

    // Construimos la app con el override necesario
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(storageService),
        ],
        child: const AltarDiarioApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
