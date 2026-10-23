import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/features/oracion/data/oracion_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OracionRepository', () {
    late FakeFirebaseFirestore fake;
    late OracionRepository repo;

    setUp(() {
      fake = FakeFirebaseFirestore();
      repo = OracionRepository(fake);
    });

    test('watchRecientes ordena por fecha descendente', () async {
      final coleccion = fake.collection('peticiones_oracion');
      await coleccion.doc('antigua').set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Antigua',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
      });
      await coleccion.doc('reciente').set({
        'userId': 'u2',
        'userName': 'Bea',
        'motivo': 'Reciente',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 3, 1)),
      });

      final peticiones = await repo.watchRecientes().first;

      expect(peticiones.map((p) => p.id), ['reciente', 'antigua']);
      expect(peticiones.first.motivo, 'Reciente');
    });

    test('watchRecientes se corta en pageSize', () async {
      final batch = fake.batch();
      final coleccion = fake.collection('peticiones_oracion');
      final base = DateTime.utc(2026, 1, 1);
      for (var i = 0; i < OracionRepository.pageSize + 20; i++) {
        batch.set(coleccion.doc('p$i'), {
          'userId': 'u1',
          'userName': 'Ana',
          'motivo': 'Petición $i',
          'fecha': Timestamp.fromDate(base.add(Duration(days: i))),
        });
      }
      await batch.commit();

      final peticiones = await repo.watchRecientes().first;

      expect(peticiones, hasLength(OracionRepository.pageSize));
    });

    test('crear guarda todos los campos de la petición', () async {
      final peticion = PeticionOracion(
        id: '',
        userId: 'u1',
        userName: 'Ana',
        motivo: 'Orad por mi familia',
        fecha: DateTime.utc(2026, 2, 10),
      );

      await repo.crear(peticion);

      final docs = await fake.collection('peticiones_oracion').get();
      expect(docs.docs, hasLength(1));
      final data = docs.docs.single.data();
      expect(data['userId'], 'u1');
      expect(data['userName'], 'Ana');
      expect(data['motivo'], 'Orad por mi familia');
      expect(data['oracionesCount'], 0);
      expect((data['fecha'] as Timestamp).toDate().toUtc(),
          DateTime.utc(2026, 2, 10));
      expect(data.containsKey('id'), isFalse);
    });

    test('amen incrementa oracionesCount en uno', () async {
      final ref = fake.collection('peticiones_oracion').doc('plim');
      await ref.set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Necesito oración',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 5)),
        'oracionesCount': 2,
      });

      await repo.amen('plim');

      final data = (await ref.get()).data()!;
      expect(data['oracionesCount'], 3);
    });

    test('watchFiltrado devuelve solo las respondidas cuando se pide',
        () async {
      final coleccion = fake.collection('peticiones_oracion');
      await coleccion.doc('pendiente').set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Pendiente',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
        'respondida': false,
      });
      await coleccion.doc('respondida').set({
        'userId': 'u2',
        'userName': 'Bea',
        'motivo': 'Respondida',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
        'respondida': true,
      });

      final respondidas = await repo.watchFiltrado(respondida: true).first;

      expect(respondidas.map((p) => p.id), ['respondida']);
    });

    test('watchFiltrado sin filtro devuelve todas', () async {
      final coleccion = fake.collection('peticiones_oracion');
      await coleccion.doc('pendiente').set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Pendiente',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
        'respondida': false,
      });
      await coleccion.doc('respondida').set({
        'userId': 'u2',
        'userName': 'Bea',
        'motivo': 'Respondida',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
        'respondida': true,
      });

      final todas = await repo.watchFiltrado().first;

      expect(todas, hasLength(2));
    });

    test('marcarComoRespondida marca la petición del autor', () async {
      final ref = fake.collection('peticiones_oracion').doc('plim');
      await ref.set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Necesito oración',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 5)),
        'respondida': false,
      });

      await repo.marcarComoRespondida('plim', 'u1');

      final data = (await ref.get()).data()!;
      expect(data['respondida'], isTrue);
      expect(data['fechaRespondida'], isNotNull);
    });

    test('marcarComoRespondida rechaza a quien no es el autor', () async {
      final ref = fake.collection('peticiones_oracion').doc('plim');
      await ref.set({
        'userId': 'u1',
        'userName': 'Ana',
        'motivo': 'Necesito oración',
        'fecha': Timestamp.fromDate(DateTime.utc(2026, 1, 5)),
        'respondida': false,
      });

      await expectLater(
        repo.marcarComoRespondida('plim', 'u2'),
        throwsStateError,
      );

      final data = (await ref.get()).data()!;
      expect(data['respondida'], isFalse);
    });
  });
}
