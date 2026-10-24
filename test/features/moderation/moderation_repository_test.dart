import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/features/moderation/data/moderation_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fake;
  late ModerationRepository repo;

  setUp(() {
    fake = FakeFirebaseFirestore();
    repo = ModerationRepository(FirestoreService(firestore: fake));
  });

  test('guarda el reporte en la colección reports', () async {
    await repo.reportarContenido(
      reporterId: 'u1',
      targetType: 'reflexion',
      targetId: 'r1',
      reason: 'Spam',
    );

    final reports = await fake.collection('reports').get();
    expect(reports.docs, hasLength(1));
    final data = reports.docs.single.data();
    expect(data['reporterId'], 'u1');
    expect(data['targetType'], 'reflexion');
    expect(data['targetId'], 'r1');
    expect(data['reason'], 'Spam');
    expect(data['createdAt'], isNotNull);
  });

  test('sin Firestore disponible lanza StateError y no escribe nada', () async {
    final repoSinFirebase = ModerationRepository(FirestoreService());

    await expectLater(
      repoSinFirebase.reportarContenido(
        reporterId: 'u1',
        targetType: 'reflexion',
        targetId: 'r1',
        reason: 'Spam',
      ),
      throwsStateError,
    );
  });
}
