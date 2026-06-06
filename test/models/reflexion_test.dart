import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/models/reflexion.dart';

void main() {
  group('Reflexion', () {
    final baseMap = {
      'id': 'ref_001',
      'userId': 'user_001',
      'userName': 'Juan Pérez',
      'texto': 'Dios me habló hoy sobre la paciencia...',
      'pasajeDia': 'Salmos 1; Proverbios 1',
      'fecha': '2026-06-06T10:00:00.000',
      'likes': 5,
      'likedBy': ['user_002', 'user_003'],
    };

    test('fromMap crea instancia correctamente', () {
      final r = Reflexion.fromMap(baseMap);
      expect(r.id, 'ref_001');
      expect(r.userId, 'user_001');
      expect(r.userName, 'Juan Pérez');
      expect(r.texto, 'Dios me habló hoy sobre la paciencia...');
      expect(r.pasajeDia, 'Salmos 1; Proverbios 1');
      expect(r.fecha, DateTime(2026, 6, 6, 10, 0, 0));
      expect(r.likes, 5);
      expect(r.likedBy, ['user_002', 'user_003']);
    });

    test('fromMap maneja valores nulos', () {
      final r = Reflexion.fromMap({});
      expect(r.id, '');
      expect(r.userId, '');
      expect(r.userName, 'Anónimo');
      expect(r.texto, '');
      expect(r.pasajeDia, '');
      expect(r.likes, 0);
      expect(r.likedBy, []);
    });

    test('fromMap maneja likedBy nulo', () {
      final map = {...baseMap};
      map.remove('likedBy');
      final r = Reflexion.fromMap(map);
      expect(r.likedBy, []);
    });

    test('toMap produce el mapa correcto', () {
      final r = Reflexion.fromMap(baseMap);
      final map = r.toMap();
      expect(map['userId'], 'user_001');
      expect(map['userName'], 'Juan Pérez');
      expect(map['texto'], 'Dios me habló hoy sobre la paciencia...');
      expect(map['pasajeDia'], 'Salmos 1; Proverbios 1');
      expect(map['likes'], 5);
      expect(map['likedBy'], ['user_002', 'user_003']);
      expect(map.containsKey('fecha'), true);
    });

    test('isLikedBy devuelve true si userId está en likedBy', () {
      final r = Reflexion.fromMap(baseMap);
      expect(r.isLikedBy('user_002'), true);
      expect(r.isLikedBy('user_004'), false);
    });

    test('isLikedBy maneja userId vacío', () {
      final r = Reflexion.fromMap(baseMap);
      expect(r.isLikedBy(''), false);
    });

    test('copyWith crea copia con campos modificados', () {
      final r = Reflexion.fromMap(baseMap);
      final copy = r.copyWith(likes: 10, likedBy: ['user_004']);
      expect(copy.id, 'ref_001');
      expect(copy.likes, 10);
      expect(copy.likedBy, ['user_004']);
      expect(copy.texto, r.texto);
    });

    test('copyWith mantiene campos no modificados', () {
      final r = Reflexion.fromMap(baseMap);
      final copy = r.copyWith(texto: 'Nuevo texto');
      expect(copy.userId, 'user_001');
      expect(copy.likes, 5);
    });
  });
}
