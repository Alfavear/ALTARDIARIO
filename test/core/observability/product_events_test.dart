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

  test('reflexion_publicada conserva el nombre pactado con Analytics', () {
    // Si cambia el nombre, los paneles de producto dejan de recibir el evento.
    expect(EventoProducto.reflexionPublicada.nombre, 'reflexion_publicada');
  });

  group('payload de reflexionPublicada', () {
    test('lo que envía la pantalla de publicar sobrevive intacto', () {
      // Mismo mapa que construye publicar_reflexion_screen.dart: sin el texto.
      final limpio = sanitizarParametros({
        'tipo': 'reflexion',
        'longitud_texto': 240,
        'tiene_pasaje': true,
      });

      expect(limpio, {
        'tipo': 'reflexion',
        'longitud_texto': 240,
        'tiene_pasaje': true,
      });
    });

    test('si alguien añade el texto de la reflexión, se descarta', () {
      final conTexto = sanitizarParametros({
        'tipo': 'reflexion',
        'longitud_texto': 240,
        'texto': 'una confesión muy personal',
      });

      expect(conTexto, {'tipo': 'reflexion', 'longitud_texto': 240});
    });
  });
}
