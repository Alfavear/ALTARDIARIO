import 'dart:convert';
import 'package:http/http.dart' as http;

class BibleVersion {
  final String id;
  final String name;
  final String lang;

  const BibleVersion({required this.id, required this.name, required this.lang});
}

class BibleService {
  static const List<BibleVersion> availableVersions = [
    BibleVersion(id: 'rvr1960', name: 'Reina Valera 1960', lang: 'es'),
    BibleVersion(id: 'nvi', name: 'Nueva Versión Int.', lang: 'es'),
    BibleVersion(id: 'kjv', name: 'King James Version', lang: 'en'),
  ];

  static const Map<String, int> _bookMap = {
    'génesis': 1, 'éxodo': 2, 'levítico': 3, 'números': 4, 'deuteronomio': 5,
    'josué': 6, 'jueces': 7, 'rut': 8, '1 samuel': 9, '2 samuel': 10,
    '1 reyes': 11, '2 reyes': 12, '1 crónicas': 13, '2 crónicas': 14,
    'esdras': 15, 'nehemías': 16, 'ester': 17, 'job': 18, 'salmo': 19, 'salmos': 19,
    'proverbios': 20, 'eclesiastés': 21, 'cantares': 22, 'isaías': 23,
    'jeremías': 24, 'lamentaciones': 25, 'ezequiel': 26, 'daniel': 27,
    'oseas': 28, 'joel': 29, 'amós': 30, 'abdías': 31, 'jonás': 32,
    'miqueas': 33, 'nahúm': 34, 'habacuc': 35, 'sofonías': 36, 'hageo': 37,
    'zacarías': 38, 'malaquías': 39, 'mateo': 40, 'marcos': 41, 'lucas': 42,
    'juan': 43, 'hechos': 44, 'romanos': 45, '1 corintios': 46, '2 corintios': 47,
    'gálatas': 48, 'efesios': 49, 'filipenses': 50, 'colosenses': 51,
    '1 tesalonicenses': 52, '2 tesalonicenses': 53, '1 timoteo': 54,
    '2 timoteo': 55, 'tito': 56, 'filemón': 57, 'hebreos': 58, 'santiago': 59,
    '1 pedro': 60, '2 pedro': 61, '1 juan': 62, '2 juan': 63, '3 juan': 64,
    'judas': 65, 'apocalipsis': 66
  };

  /// Expresión regular para capturar el formato de los pasajes:
  /// Grupo 1: Nombre del libro
  /// Grupo 2: Capítulo de inicio
  /// Grupo 3: Versículo de inicio (opcional)
  /// Grupo 4: Capítulo o versículo final (opcional)
  static final RegExp _passageRegex = RegExp(r'^(.+?)\s+(\d+)(?::(\d+))?(?:[–—\-]\s*(\d+))?$');

  /// Obtiene el texto de los pasajes.
  Future<List<Map<String, String>>> getPassageText(String query, {String version = 'rvr1960'}) async {
    final List<Map<String, String>> results = [];
    final passages = query.split(';');
    final translation = version.toUpperCase();

    for (var passage in passages) {
      final trimmedPassage = passage.trim();
      
      final match = _passageRegex.firstMatch(trimmedPassage);

      if (match != null) {
        final bookName = match.group(1)!;
        final chStart = int.parse(match.group(2)!);
        final vStart = match.group(3) != null ? int.parse(match.group(3)!) : null;
        final end = match.group(4) != null ? int.parse(match.group(4)!) : null;

        final bookId = _mapBookToId(bookName);
        if (bookId == -1) {
          results.add({'reference': trimmedPassage, 'text': 'Libro "$bookName" no reconocido.'});
          continue;
        }

        String content = '';
        try {
          if (vStart == null) {
            // Escenario A: Rango de capítulos (o uno solo)
            final chEnd = end ?? chStart;
            for (int ch = chStart; ch <= chEnd; ch++) {
              final chapterData = await _fetchChapter(translation, bookId, ch);
              if (chapterData != null) {
                content += (content.isEmpty ? '' : '\n\n') + 'Capítulo $ch:\n$chapterData';
              }
            }
          } else {
            // Escenario B: Rango de versículos en un capítulo específico
            final vEnd = end ?? vStart;
            final url = Uri.parse('https://bolls.life/get-chapter/$translation/$bookId/$chStart/');
            final response = await http.get(url);
            
            if (response.statusCode == 200) {
              final List<dynamic> verses = json.decode(response.body);
              final filteredText = verses
                  .where((v) => v['verse'] >= vStart && v['verse'] <= vEnd)
                  .map((v) => '${v['verse']} ${v['text']}')
                  .join(' ');
              content = filteredText;
            }
          }
          
          results.add({
            'reference': trimmedPassage,
            'text': content.isNotEmpty ? content : 'No se pudo cargar el contenido.',
          });
        } catch (e) {
          results.add({'reference': trimmedPassage, 'text': 'Error de conexión con el servidor.'});
        }
      } else {
        results.add({'reference': trimmedPassage, 'text': 'Formato de pasaje no soportado.'});
      }
    }
    return results;
  }

  Future<String?> _fetchChapter(String trans, int book, int ch) async {
    try {
      final url = Uri.parse('https://bolls.life/get-chapter/$trans/$book/$ch/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> verses = json.decode(response.body);
        return verses.map((v) => '${v['verse']} ${v['text']}').join(' ');
      }
    } catch (_) {}
    return null;
  }

  /// Obtiene los nombres de los libros en orden.
  List<String> getBookNames() {
    final sortedBooks = _bookMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sortedBooks.map((e) => e.key[0].toUpperCase() + e.key.substring(1)).toList();
  }

  /// Devuelve el ID del libro basado en su nombre.
  int _mapBookToId(String name) {
    return _bookMap[name.toLowerCase()] ?? -1;
  }

  /// Mapea un ID de libro de vuelta a su nombre común (Capitalizado).
  String getBookNameFromId(int id) {
    try {
      final name = _bookMap.entries.firstWhere((e) => e.value == id).key;
      return name[0].toUpperCase() + name.substring(1);
    } catch (_) {
      return "Libro $id";
    }
  }
}