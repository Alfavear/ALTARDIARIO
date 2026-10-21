import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/features/moderation/presentation/report_user_dialog.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('envía el motivo seleccionado para el usuario reportado',
      (tester) async {
    final service = _RecordingFirestoreService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveUserUidProvider.overrideWithValue('reporter'),
          firestoreServiceProvider.overrideWithValue(service),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ReportUserDialog(userId: 'target', userName: 'María'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(RadioListTile<String>).first);
    await tester.pump();
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();

    expect(service.reporterId, 'reporter');
    expect(service.targetType, 'usuario');
    expect(service.targetId, 'target');
    expect(service.reason, 'Lenguaje ofensivo');
  });
}

class _RecordingFirestoreService extends FirestoreService {
  String? reporterId;
  String? targetType;
  String? targetId;
  String? reason;

  @override
  Future<void> reportarContenido({
    required String reporterId,
    required String targetType,
    required String targetId,
    required String reason,
  }) async {
    this.reporterId = reporterId;
    this.targetType = targetType;
    this.targetId = targetId;
    this.reason = reason;
  }
}
