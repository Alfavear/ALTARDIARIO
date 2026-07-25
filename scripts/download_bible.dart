import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

final _baseUrl = 'https://bolls.life';
final _slug = 'RV1960';

Future<void> main() async {
  print('Fetching book names...');
  final booksResp = await http.get(
    Uri.parse('$_baseUrl/get-books/$_slug/'),
  );
  if (booksResp.statusCode != 200) {
    print('Failed to get books: ${booksResp.statusCode}');
    exit(1);
  }
  final booksRaw = jsonDecode(booksResp.body) as List<dynamic>;
  final books = <int, String>{};
  for (final b in booksRaw) {
    books[b['bookid'] as int] = b['name'] as String;
  }
  print('Got ${books.length} books');

  print('Downloading verses...');
  final versesResp = await http.get(
    Uri.parse('$_baseUrl/static/translations/$_slug.json'),
  );
  if (versesResp.statusCode != 200) {
    print('Failed to download: ${versesResp.statusCode}');
    exit(1);
  }
  final verses = jsonDecode(versesResp.body) as List<dynamic>;
  print('Got ${verses.length} verses');

  final bookMap = <int, Map<String, dynamic>>{};
  for (final v in verses) {
    final vMap = v as Map<String, dynamic>;
    final bid = vMap['book'] as int;
    final ch = vMap['chapter'] as int;
    final vs = vMap['verse'] as int;
    var txt = vMap['text'] as String;
    txt = txt.replaceAll(RegExp(r'<[^>]*>'), '');
    txt = txt.replaceAll(RegExp(r'\s+'), ' ').trim();

    bookMap.putIfAbsent(bid, () => {
      'id': bid,
      'name': books[bid] ?? 'Book $bid',
      'chapters': <int, Map<String, dynamic>>{},
    });
    final chapters = bookMap[bid]!['chapters']! as Map<int, Map<String, dynamic>>;
    chapters.putIfAbsent(ch, () => {
      'number': ch,
      'verses': <Map<String, dynamic>>[],
    });
    (chapters[ch]!['verses']! as List<Map<String, dynamic>>).add({
      'number': vs,
      'text': txt,
    });
  }

  final booksList = <Map<String, dynamic>>[];
  for (final bid in bookMap.keys.toList()..sort()) {
    final b = bookMap[bid]!;
    final chapters = b['chapters']! as Map<int, Map<String, dynamic>>;
    final chList = <Map<String, dynamic>>[];
    for (final chNum in chapters.keys.toList()..sort()) {
      chList.add(chapters[chNum]!);
    }
    b['chapters'] = chList;
    booksList.add(b);
  }

  final output = {
    'version': 'rv1960',
    'name': 'Reina-Valera 1960',
    'language': 'es',
    'books': booksList,
  };

  final file = File('assets/bible/es_rv1960_complete.json');
  await file.writeAsString(
    const JsonEncoder.withIndent(null).convert(output),
    encoding: utf8,
  );
  final size = await file.length();
  print('Saved: $size bytes (${(size / 1024 / 1024).toStringAsFixed(1)} MB)');
}
