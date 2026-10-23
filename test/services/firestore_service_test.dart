import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FirestoreService límites de colecciones', () {
    late FakeFirebaseFirestore fake;
    late FirestoreService service;

    setUp(() {
      fake = FakeFirebaseFirestore();
      service = FirestoreService(firestore: fake);
    });

    test(
      'el stream de peticiones queda acotado a su tamaño de página',
      () async {
        final batch = fake.batch();
        for (var i = 0; i < 120; i++) {
          batch.set(fake.collection('peticiones_oracion').doc('p$i'), {
            'userId': 'u1',
            'motivo': 'Petición $i',
            'fecha': DateTime.utc(2026, 1, i + 1),
          });
        }
        await batch.commit();

        final results = await service.peticionesStream().first;

        expect(results, hasLength(FirestoreService.prayerPageSize));
      },
    );
  });

  group('FirestoreService.sendMessage', () {
    late FakeFirebaseFirestore fake;
    late FirestoreService service;

    setUp(() {
      fake = FakeFirebaseFirestore();
      service = FirestoreService(firestore: fake);
    });

    test('crea el chat con participantes y envía el primer mensaje', () async {
      await service.sendMessage(
        'c1',
        'u1',
        'hola',
        participantIds: ['u1', 'u2'],
        participantNames: {'u1': 'Juan', 'u2': 'María'},
      );

      final chat = (await fake.doc('chats/c1').get()).data()!;
      expect(chat['participantIds'], equals(['u1', 'u2']));
      expect(chat['participantNames'], equals({'u1': 'Juan', 'u2': 'María'}));
      expect(chat['lastMessage'], 'hola');
      expect(chat['lastSenderId'], 'u1');
      expect(chat.containsKey('lastUpdate'), isTrue);

      final messages = await fake.collection('chats/c1/messages').get();
      expect(messages.docs.length, 1);
      expect(messages.docs.single.data()['senderId'], 'u1');
      expect(messages.docs.single.data()['text'], 'hola');
    });

    test(
        'chat existente con participantes pasados: conserva participantIds y '
        'participantNames', () async {
      await fake.doc('chats/c1').set({
        'participantIds': ['u2', 'u1'],
        'participantNames': {'u2': 'María', 'u1': 'Juan'},
      });

      await service.sendMessage(
        'c1',
        'u1',
        'nuevo mensaje',
        participantIds: ['u1', 'u2'],
        participantNames: {'u1': 'Otro Juan', 'u2': 'Otra María'},
      );

      final chat = (await fake.doc('chats/c1').get()).data()!;
      expect(chat['participantIds'], equals(['u2', 'u1']));
      expect(chat['participantNames'], equals({'u2': 'María', 'u1': 'Juan'}));
      expect(chat['lastMessage'], 'nuevo mensaje');
      expect(chat['lastSenderId'], 'u1');
      expect(chat.containsKey('lastUpdate'), isTrue);

      final messages = await fake.collection('chats/c1/messages').get();
      expect(messages.docs.length, 1);
      expect(messages.docs.single.data()['text'], 'nuevo mensaje');
    });

    test(
        'chat existente con participantes pasados no toca participantNames '
        'aunque el chat no los tuviera', () async {
      await fake.doc('chats/c1').set({
        'participantIds': ['u1', 'u2'],
      });

      await service.sendMessage(
        'c1',
        'u1',
        'hola',
        participantIds: ['u9', 'u8'],
      );

      final chat = (await fake.doc('chats/c1').get()).data()!;
      // El chat es el mismo: los participantes que llegan por parámetro se
      // ignoran por completo (ni se reescriben ni se crean de cero).
      expect(chat['participantIds'], equals(['u1', 'u2']));
      expect(chat.containsKey('participantNames'), isFalse);
      expect(chat['lastMessage'], 'hola');
    });

    test(
        'chat existente sin participantes: actualiza solo metadatos y añade el '
        'mensaje', () async {
      await fake.doc('chats/c1').set({
        'participantIds': ['u1', 'u2'],
        'participantNames': {'u1': 'Juan', 'u2': 'María'},
      });

      await service.sendMessage('c1', 'u2', 'sin metadatos');

      final chat = (await fake.doc('chats/c1').get()).data()!;
      expect(chat['participantIds'], equals(['u1', 'u2']));
      expect(chat['participantNames'], equals({'u1': 'Juan', 'u2': 'María'}));
      expect(chat['lastMessage'], 'sin metadatos');
      expect(chat['lastSenderId'], 'u2');

      final messages = await fake.collection('chats/c1/messages').get();
      expect(messages.docs.length, 1);
      expect(messages.docs.single.data()['senderId'], 'u2');
      expect(messages.docs.single.data()['text'], 'sin metadatos');
    });

    test('cada envío añade exactamente un mensaje y actualiza lastSenderId',
        () async {
      await fake.doc('chats/c1').set({
        'participantIds': ['u1', 'u2'],
        'participantNames': {'u1': 'Juan', 'u2': 'María'},
      });

      await service.sendMessage('c1', 'u1', 'primero');
      await service.sendMessage('c1', 'u2', 'segundo');

      final messages = await fake.collection('chats/c1/messages').get();
      expect(messages.docs.length, 2);
      expect(
        messages.docs.map((d) => d.data()['text']).toSet(),
        equals({'primero', 'segundo'}),
      );

      final chat = (await fake.doc('chats/c1').get()).data()!;
      expect(chat['lastMessage'], 'segundo');
      expect(chat['lastSenderId'], 'u2');
      // Dos envíos seguidos no duplican ni reescriben a los participantes.
      expect(chat['participantIds'], equals(['u1', 'u2']));
      expect(chat['participantNames'], equals({'u1': 'Juan', 'u2': 'María'}));
    });

    test('chat inexistente sin participantes no crea documento', () async {
      // Sin participantes se asume chat existente: en Fake, `update` sobre un
      // documento inexistente lanza not-found (en producción, permission-denied
      // por la regla de update). Lo importante es que falle y no invente un
      // chat sin participantIds.
      await expectLater(
        service.sendMessage('nuevo', 'u1', 'hola'),
        throwsA(
          isA<FirebaseException>().having((e) => e.code, 'code', 'not-found'),
        ),
      );

      final doc = await fake.doc('chats/nuevo').get();
      expect(doc.exists, isFalse);

      final messages = await fake.collection('chats/nuevo/messages').get();
      expect(messages.docs, isEmpty);
    });

    test('participantIds con un solo miembro lanza StateError', () async {
      await expectLater(
        service.sendMessage('nuevo', 'u1', 'hola', participantIds: ['u1']),
        throwsA(isA<StateError>()),
      );

      final doc = await fake.doc('chats/nuevo').get();
      expect(doc.exists, isFalse);
    });
  });

  group('FirestoreService.bloqueos', () {
    late FakeFirebaseFirestore fake;
    late FirestoreService service;

    setUp(() {
      fake = FakeFirebaseFirestore();
      service = FirestoreService(firestore: fake);
    });

    test('bloquearUsuario guarda el documento en blocked', () async {
      await service.bloquearUsuario('u1', 'u2');

      final doc = await fake.doc('usuarios/u1/blocked/u2').get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['uid'], 'u1');
      expect(doc.data()?['blockedUid'], 'u2');
    });

    test('bloquearUsuario no se bloquea a sí mismo', () async {
      await service.bloquearUsuario('u1', 'u1');

      final doc = await fake.doc('usuarios/u1/blocked/u1').get();
      expect(doc.exists, isFalse);
    });

    test('desbloquearUsuario borra el documento de blocked', () async {
      await fake.doc('usuarios/u1/blocked/u2').set({
        'uid': 'u1',
        'blockedUid': 'u2',
        'fecha': DateTime.now(),
      });

      await service.desbloquearUsuario('u1', 'u2');

      final doc = await fake.doc('usuarios/u1/blocked/u2').get();
      expect(doc.exists, isFalse);
    });

    test('getUsuariosBloqueados retorna la lista de uids bloqueados', () async {
      await fake.doc('usuarios/u1/blocked/u2').set({
        'uid': 'u1',
        'blockedUid': 'u2',
        'fecha': DateTime.now(),
      });
      await fake.doc('usuarios/u1/blocked/u3').set({
        'uid': 'u1',
        'blockedUid': 'u3',
        'fecha': DateTime.now(),
      });

      final bloqueados = await service.getUsuariosBloqueados('u1').first;
      expect(bloqueados, containsAll(['u2', 'u3']));
      expect(bloqueados, hasLength(2));
    });
  });
}
