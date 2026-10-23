import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/presentation/screens/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('biblioteca: privacidad visible y exportación bajo demanda',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = StorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: NotesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('solo en este dispositivo'),
      findsOneWidget,
      reason: 'el usuario debe saber que sus notas son locales',
    );
    expect(find.byTooltip('Exportar mi biblioteca'), findsOneWidget);

    await tester.tap(find.byTooltip('Exportar mi biblioteca'));
    await tester.pumpAndSettle();

    expect(find.text('Exportar mi biblioteca'), findsOneWidget);
    expect(find.textContaining('no envía tus notas'), findsOneWidget);
  });
}
