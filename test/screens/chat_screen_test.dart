import 'dart:async';

import 'package:altar_diario/data/models/message.dart';
import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/presentation/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildChat(FirestoreService service) {
    return ProviderScope(
      overrides: [
        effectiveUserUidProvider.overrideWithValue('u1'),
        firestoreServiceProvider.overrideWithValue(service),
      ],
      child: const MaterialApp(
        home: ChatScreen(
          chatId: 'c1',
          otherUserId: 'u2',
          otherUserName: 'María',
        ),
      ),
    );
  }

  group('ChatScreen envío de mensajes', () {
    testWidgets('limpia el campo cuando el envío tiene éxito', (tester) async {
      final service = _FakeChatService();
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('hola'), findsNothing);
      expect(service.sentTexts, ['hola']);
      // La UI nunca reenvía participantes: el chat ya existe.
      expect(service.participantIdsByCall.single, isNull);
      // El spinner del botón desaparece al terminar el envío.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'conserva el texto y muestra un error reintentable si el envío '
        'falla', (tester) async {
      final service = _FakeChatService(failuresBeforeSuccess: 1);
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('hola'), findsOneWidget);
      expect(find.text('No se pudo enviar el mensaje. Inténtalo de nuevo.'),
          findsOneWidget);
      expect(find.text('REINTENTAR'), findsOneWidget);
      expect(service.sentTexts, isEmpty);
    });

    testWidgets('el SnackBar de error ofrece una acción REINTENTAR accionable',
        (tester) async {
      final service = _FakeChatService(failuresBeforeSuccess: 1);
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      final action = tester.widget<SnackBarAction>(
        find.widgetWithText(SnackBarAction, 'REINTENTAR'),
      );
      expect(action.label, 'REINTENTAR');
      expect(action.onPressed, isNotNull);
    });

    testWidgets('REINTENTAR reenvía el texto y limpia el campo',
        (tester) async {
      final service = _FakeChatService(failuresBeforeSuccess: 1);
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      await tester.tap(find.text('REINTENTAR'));
      await tester.pumpAndSettle();

      expect(service.sendCalls, 2);
      expect(service.sentTexts, ['hola']);
      expect(find.text('hola'), findsNothing);
      expect(find.text('No se pudo enviar el mensaje. Inténtalo de nuevo.'),
          findsNothing);
    });

    testWidgets('no envía texto vacío', (tester) async {
      final service = _FakeChatService();
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(service.sendCalls, 0);
      expect(service.sentTexts, isEmpty);
    });

    testWidgets('el guard _isSending evita el doble envío con dos taps rápidos',
        (tester) async {
      final service = _DeferredChatService();
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      // Sin pump entre taps: el árbol aún no se ha reconstruido, así que el
      // segundo tap entra por el mismo `onTap` y solo lo puede frenar el guard
      // de `_sendMessage`. Con `onSubmitted` pasaría lo mismo.
      await tester.tap(find.byIcon(Icons.send));
      await tester.tap(find.byIcon(Icons.send), warnIfMissed: false);
      // `onSubmitted` no pasa por el `onTap` (que ya sería null tras
      // reconstruir): si estas dos entradas envían algo, es solo el guard de
      // `_sendMessage` el que las frena.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(service.sendCalls, 1);

      // Mientras el envío está en vuelo el botón muestra spinner.
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      service.completeAll();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(service.sendCalls, 1);
      expect(service.sentTexts, ['hola']);
      expect(find.text('hola'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('no borra lo que el usuario escribió mientras se enviaba',
        (tester) async {
      final service = _DeferredChatService();
      await tester.pumpWidget(buildChat(service));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'hola');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'hola mundo');

      service.completeAll();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(service.sentTexts, ['hola']);
      // El primer texto se envió; lo nuevo sigue en el campo.
      expect(find.text('hola mundo'), findsOneWidget);
    });
  });
}

class _FakeChatService extends FirestoreService {
  _FakeChatService({this.failuresBeforeSuccess = 0});

  final int failuresBeforeSuccess;
  int sendCalls = 0;
  final List<String> sentTexts = [];
  final List<List<String>?> participantIdsByCall = [];

  @override
  Stream<List<Message>> getMessages(String chatId) => Stream.value(<Message>[]);

  @override
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String text, {
    List<String>? participantIds,
    Map<String, String>? participantNames,
  }) async {
    sendCalls++;
    participantIdsByCall.add(participantIds);
    if (sendCalls <= failuresBeforeSuccess) {
      throw Exception('offline');
    }
    sentTexts.add(text);
  }
}

/// Deja los envíos "en vuelo" hasta que el test los completa: permite observar
/// los estados intermedios (`_isSending`) sin depender de temporizadores.
class _DeferredChatService extends FirestoreService {
  int sendCalls = 0;
  final List<String> sentTexts = [];
  final List<Completer<void>> _pending = [];

  @override
  Stream<List<Message>> getMessages(String chatId) => Stream.value(<Message>[]);

  @override
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String text, {
    List<String>? participantIds,
    Map<String, String>? participantNames,
  }) {
    sendCalls++;
    sentTexts.add(text);
    final completer = Completer<void>();
    _pending.add(completer);
    return completer.future;
  }

  void completeAll() {
    for (final completer in _pending) {
      if (!completer.isCompleted) completer.complete();
    }
  }
}
