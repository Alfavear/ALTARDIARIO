import '../../../data/models/note.dart';

/// Genera el texto de exportación de la biblioteca personal.
///
/// Es una función pura: no escribe ficheros, no llama a la red y no envía nada
/// a terceros. La exportación solo existe cuando el usuario la pide y decide
/// qué hacer con el texto resultante.
String exportarBiblioteca(List<Note> notas, {DateTime? ahora}) {
  final fecha = ahora ?? DateTime.now();
  final buffer = StringBuffer()
    ..writeln('# Mi biblioteca — AltarDiario')
    ..writeln('Exportado el ${fecha.day}/${fecha.month}/${fecha.year}')
    ..writeln();

  if (notas.isEmpty) {
    buffer.writeln('_No hay notas todavía._');
    return buffer.toString();
  }

  final ordenadas = [...notas]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  for (final nota in ordenadas) {
    final titulo = nota.title.trim();
    buffer.writeln('## ${titulo.isEmpty ? 'Sin título' : titulo}');
    final contenido = nota.content.trim();
    if (contenido.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(contenido);
    }
    buffer.writeln();
  }
  return buffer.toString();
}
