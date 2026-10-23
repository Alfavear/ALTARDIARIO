import 'package:altar_diario/data/models/note.dart';
import 'package:altar_diario/features/biblioteca/data/exportador_biblioteca.dart';
import 'package:flutter_test/flutter_test.dart';

Note nota({
  String id = 'n1',
  String title = 'Gratitud',
  String content = 'Gracias por hoy',
  DateTime? updatedAt,
}) {
  final fecha = updatedAt ?? DateTime(2026, 10, 1);
  return Note(
    id: id,
    title: title,
    content: content,
    createdAt: fecha,
    updatedAt: fecha,
  );
}

void main() {
  test('exporta la biblioteca en texto con título y contenido', () {
    final texto = exportarBiblioteca(
      [nota()],
      ahora: DateTime(2026, 10, 22),
    );

    expect(texto, contains('# Mi biblioteca — AltarDiario'));
    expect(texto, contains('Exportado el 22/10/2026'));
    expect(texto, contains('## Gratitud'));
    expect(texto, contains('Gracias por hoy'));
  });

  test('una biblioteca vacía lo dice sin fallar', () {
    final texto = exportarBiblioteca(const [], ahora: DateTime(2026, 10, 22));

    expect(texto, contains('_No hay notas todavía._'));
  });

  test('ordena de la nota más reciente a la más antigua', () {
    final texto = exportarBiblioteca(
      [
        nota(id: 'vieja', title: 'Vieja', updatedAt: DateTime(2026, 9, 1)),
        nota(id: 'nueva', title: 'Nueva', updatedAt: DateTime(2026, 10, 20)),
      ],
      ahora: DateTime(2026, 10, 22),
    );

    expect(
      texto.indexOf('## Nueva') < texto.indexOf('## Vieja'),
      isTrue,
      reason: 'la más reciente va primero',
    );
  });

  test('sin título usa "Sin título" y no deja secciones vacías', () {
    final texto = exportarBiblioteca(
      [nota(title: '   ', content: '   ')],
      ahora: DateTime(2026, 10, 22),
    );

    expect(texto, contains('## Sin título'));
    expect(texto.split('## Sin título').length, 2);
  });
}
