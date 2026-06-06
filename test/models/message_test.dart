import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:altar_diario/data/models/message.dart';

void main() {
  group('Message', () {
    final now = DateTime(2026, 6, 6, 10, 30, 0);

    test('fromMap crea instancia correctamente', () {
      final msg = Message.fromMap({
        'id': 'msg_001',
        'senderId': 'user_001',
        'text': '¡Hola! ¿Cómo estás?',
        'timestamp': Timestamp.fromDate(now),
      });
      expect(msg.id, 'msg_001');
      expect(msg.senderId, 'user_001');
      expect(msg.text, '¡Hola! ¿Cómo estás?');
      expect(msg.timestamp, now);
    });

    test('fromMap maneja valores nulos', () {
      final msg = Message.fromMap({});
      expect(msg.id, '');
      expect(msg.senderId, '');
      expect(msg.text, '');
    });

    test('toMap produce el mapa correcto', () {
      final msg = Message(
        id: 'msg_001',
        senderId: 'user_001',
        text: 'Mensaje de prueba',
        timestamp: now,
      );
      final map = msg.toMap();
      expect(map['senderId'], 'user_001');
      expect(map['text'], 'Mensaje de prueba');
      expect(map['timestamp'], isA<Timestamp>());
    });
  });
}
