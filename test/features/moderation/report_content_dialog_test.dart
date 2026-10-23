import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/features/moderation/presentation/report_content_dialog.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockFirestoreService extends FirestoreService {
  final reportes = <Map<String, String>>[];
  bool falla = false;

  @override
  Future<void> reportarContenido({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    if (falla) throw StateError('sin conexión');
    reportes.add({
      'reporterId': reporterId,
      'targetType': targetType,
      'targetId': targetId,
      'reason': reason,
    });
  }
}

Future<void> _abrirDialogo(
    WidgetTester tester, _MockFirestoreService mock) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        firestoreServiceProvider.overrideWithValue(mock),
        effectiveUserUidProvider.overrideWithValue('uid-1'),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const ReportContentDialog(
                    targetType: 'reflexion',
                    targetId: 'r1',
                    targetTitle: 'Una reflexión',
                    targetAuthor: 'Ana',
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no deja enviar sin motivo y no llama al servicio',
      (tester) async {
    final mock = _MockFirestoreService();
    await _abrirDialogo(tester, mock);

    final boton = find.widgetWithText(FilledButton, 'Enviar reporte');
    expect(tester.widget<FilledButton>(boton).onPressed, isNull);
    expect(mock.reportes, isEmpty);
  });

  testWidgets('envía el motivo elegido y avisa al usuario', (tester) async {
    final mock = _MockFirestoreService();
    await _abrirDialogo(tester, mock);

    await tester.tap(find.text('Spam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar reporte'));
    await tester.pumpAndSettle();

    expect(mock.reportes, hasLength(1));
    expect(mock.reportes.single, {
      'reporterId': 'uid-1',
      'targetType': 'reflexion',
      'targetId': 'r1',
      'reason': 'Spam',
    });
    expect(find.text('Gracias. Revisaremos tu reporte.'), findsOneWidget);
  });

  testWidgets('si el envío falla lo dice y deja reintentar', (tester) async {
    final mock = _MockFirestoreService()..falla = true;
    await _abrirDialogo(tester, mock);

    await tester.tap(find.text('Acoso o intimidación'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar reporte'));
    await tester.pumpAndSettle();

    expect(
      find.text('No se pudo enviar el reporte. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(mock.reportes, isEmpty);

    // El diálogo sigue abierto: se puede reintentar.
    expect(find.text('Enviar reporte'), findsOneWidget);
  });

  testWidgets('con "Otro" exige el motivo y recorta espacios', (tester) async {
    final mock = _MockFirestoreService();
    await _abrirDialogo(tester, mock);

    await tester.tap(find.text('Otro'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar reporte'));
    await tester.pumpAndSettle();

    expect(
      find.text('Escribe el motivo o elige una de las opciones.'),
      findsOneWidget,
    );
    expect(mock.reportes, isEmpty);

    await tester.enterText(find.byType(TextField), '  Un motivo  ');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar reporte'));
    await tester.pumpAndSettle();

    expect(mock.reportes.single['reason'], 'Un motivo');
  });
}
