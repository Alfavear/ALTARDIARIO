import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/data/models/lectura_dia.dart';

void main() {
  group('LecturaDia', () {
    test('crea instancia con valores por defecto', () {
      final l = LecturaDia(
        dia: 1,
        pasajes: 'Génesis 1–3; Juan 1–2',
        fechaClave: '2026-01-01',
      );
      expect(l.dia, 1);
      expect(l.pasajes, 'Génesis 1–3; Juan 1–2');
      expect(l.fechaClave, '2026-01-01');
      expect(l.completada, false);
    });

    test('crea instancia completada', () {
      final l = LecturaDia(
        dia: 100,
        pasajes: 'Salmos 1',
        fechaClave: '2026-04-10',
        completada: true,
      );
      expect(l.dia, 100);
      expect(l.completada, true);
    });

    test('crea instancia con pasaje largo', () {
      final l = LecturaDia(
        dia: 365,
        pasajes: 'Apocalipsis 22',
        fechaClave: '2026-12-31',
      );
      expect(l.dia, 365);
      expect(l.pasajes, 'Apocalipsis 22');
    });
  });
}
