import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/models/usuario.dart';

void main() {
  group('Usuario', () {
    test('fromMap crea instancia correctamente', () {
      final u = Usuario.fromMap({
        'id': 'user_001',
        'nombre': 'María García',
        'email': 'maria@ejemplo.com',
        'fotoUrl': 'https://ejemplo.com/foto.jpg',
        'siguiendo': ['user_002'],
        'seguidores': ['user_003', 'user_004'],
      });
      expect(u.id, 'user_001');
      expect(u.nombre, 'María García');
      expect(u.email, 'maria@ejemplo.com');
      expect(u.fotoUrl, 'https://ejemplo.com/foto.jpg');
      expect(u.siguiendo, ['user_002']);
      expect(u.seguidores, ['user_003', 'user_004']);
    });

    test('fromMap maneja valores nulos', () {
      final u = Usuario.fromMap({});
      expect(u.id, '');
      expect(u.nombre, '');
      expect(u.email, '');
      expect(u.fotoUrl, '');
      expect(u.siguiendo, []);
      expect(u.seguidores, []);
    });

    test('toMap produce el mapa correcto', () {
      final u = Usuario(
        id: 'user_001',
        nombre: 'Carlos López',
        email: 'carlos@ejemplo.com',
        fotoUrl: '',
        siguiendo: [],
        seguidores: [],
      );
      final map = u.toMap();
      expect(map['nombre'], 'Carlos López');
      expect(map['email'], 'carlos@ejemplo.com');
      expect(map.containsKey('siguiendo'), true);
      expect(map.containsKey('seguidores'), true);
    });

    test('crea usuario sin fotoUrl', () {
      final u = Usuario(
        id: 'user_001',
        nombre: 'Ana',
        email: 'ana@ejemplo.com',
      );
      expect(u.fotoUrl, '');
    });

    test('crea usuario con listas vacías por defecto', () {
      final u = Usuario(
        id: 'user_001',
        nombre: 'Luis',
        email: 'luis@ejemplo.com',
      );
      expect(u.siguiendo, []);
      expect(u.seguidores, []);
    });
  });
}
