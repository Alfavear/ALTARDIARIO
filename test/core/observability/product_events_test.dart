import 'package:altar_diario/core/observability/product_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanitizarParametros', () {
    test('descarta textos libres: un correo o un motivo nunca salen', () {
      final limpio = sanitizarParametros({
        'origen': 'mi correo es ana@example.com',
        'categoria': 'me insultó en el chat',
      });

      expect(limpio, isEmpty);
    });

    test('descarta tokens y claves que no están permitidas', () {
      final limpio = sanitizarParametros({
        'fcmToken': 'abcdef1234567890abcdef',
        'email': 'ana@example.com',
        'texto': 'contenido de una reflexión',
        'motivo': 'texto libre del reporte',
      });

      expect(limpio, isEmpty);
    });

    test('conserva números y booleanos (métricas)', () {
      final limpio = sanitizarParametros({
        'racha': 7,
        'total_lecturas': 120,
        'tiene_pasaje': true,
        'exito': false,
      });

      expect(limpio, {
        'racha': 7,
        'total_lecturas': 120,
        'tiene_pasaje': true,
        'exito': false,
      });
    });

    test('conserva solo cadenas de la lista cerrada', () {
      final limpio = sanitizarParametros({
        'origen': 'lectura',
        'tipo': 'comentario',
        'pantalla': 'cualquier cosa escrita por el usuario',
      });

      expect(limpio, {'origen': 'lectura', 'tipo': 'comentario'});
    });

    test('un payload con datos personales y métricas deja solo las métricas',
        () {
      final limpio = sanitizarParametros({
        'racha': 3,
        'email': 'ana@example.com',
        'fcmToken': 'token-secreto',
        'texto': 'mi diario íntimo',
      });

      expect(limpio, {'racha': 3});
    });

    test('null o vacío no rompe', () {
      expect(sanitizarParametros(null), isEmpty);
      expect(sanitizarParametros(const {}), isEmpty);
    });
  });

  test('los nombres de evento son snake_case y sin datos', () {
    for (final evento in EventoProducto.values) {
      expect(
        RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(evento.nombre),
        isTrue,
        reason: '${evento.nombre} debe ser snake_case',
      );
      expect(evento.nombre.length, lessThanOrEqualTo(40));
    }
  });
}
