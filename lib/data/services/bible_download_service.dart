import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/bible_models.dart';

class AvailableTranslation {
  final String slug;
  final String name;
  final String language;
  final bool isDownloaded;

  const AvailableTranslation({
    required this.slug,
    required this.name,
    required this.language,
    this.isDownloaded = false,
  });
}

class BibleDownloadService {
  static const String _baseUrl = 'https://bolls.life';
  static const String _databaseName = 'altar_diario_bible.db';
  static const int _batchSize = 1000;

  // Mapa de ID de versión → slug de API (bolls.life es sensible a mayúsculas)
  static const Map<String, String> _apiSlugs = {
    'rv1960': 'RV1960',
    'rv1909': 'RV1909',
  };

  String _apiSlug(String versionId) => _apiSlugs[versionId] ?? versionId;

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    if (kIsWeb) throw UnsupportedError('Downloads not supported on web');
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, _databaseName),
      readOnly: false,
    );
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<List<AvailableTranslation>> fetchAvailableTranslations() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/static/bolls/app/views/languages.json'),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener traducciones: ${response.statusCode}');
    }

    final downloadedIds = await getDownloadedVersionIds();

    final data = jsonDecode(response.body) as List<dynamic>;
    final translations = <AvailableTranslation>[];
    for (final langGroup in data) {
      final language = langGroup['language'] as String;
      for (final t in langGroup['translations'] as List<dynamic>) {
        final slug = t['short_name'] as String;
        translations.add(AvailableTranslation(
          slug: slug,
          name: t['full_name'] as String,
          language: language,
          isDownloaded: downloadedIds.contains(slug),
        ));
      }
    }
    return translations;
  }

  Future<Set<String>> getDownloadedVersionIds() async {
    if (kIsWeb) return {};
    try {
      final db = await _db;
      final rows = await db.rawQuery(
        'SELECT DISTINCT version FROM bible_verses',
      );
      return rows.map((r) => r['version'] as String).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<List<BibleVersion>> getDownloadedVersions() async {
    if (kIsWeb) return [];
    try {
      final db = await _db;
      final rows = await db.rawQuery(
        'SELECT DISTINCT version FROM bible_verses',
      );
      final versions = <BibleVersion>[];
      for (final row in rows) {
        final id = row['version'] as String;
        final name = _versionName(id) ?? id;
        versions.add(BibleVersion(id: id, name: name, lang: ''));
      }
      return versions;
    } catch (_) {
      return [];
    }
  }

  Future<Map<int, String>> _fetchBookNames(String versionId) async {
    final apiSlug = _apiSlug(versionId);
    final response = await http.get(
      Uri.parse('$_baseUrl/get-books/$apiSlug/'),
    );
    if (response.statusCode != 200) return {};

    final books = jsonDecode(response.body) as List<dynamic>;
    return {
      for (final b in books)
        b['bookid'] as int: b['name'] as String,
    };
  }

  Future<void> downloadVersion(
    String versionId, {
    void Function(int current, int total)? onProgress,
  }) async {
    if (kIsWeb) throw UnsupportedError('Downloads not supported on web');

    final apiSlug = _apiSlug(versionId);
    final bookNames = await _fetchBookNames(versionId);
    if (bookNames.isEmpty) {
      throw Exception('No se pudieron obtener los libros de esta versión');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/static/translations/$apiSlug.json'),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Error al descargar: ${response.statusCode}',
      );
    }

    final verses = jsonDecode(response.body) as List<dynamic>;
    final total = verses.length;

    final db = await _db;
    final batch = db.batch();
    var count = 0;

    for (final v in verses) {
      final verse = v as Map<String, dynamic>;

      final bookId = verse['book'] as int;
      final bookName = bookNames[bookId] ?? 'Book $bookId';

      batch.insert(
        'bible_verses',
        {
          'version': versionId,
          'book_id': bookId,
          'book_name': bookName,
          'chapter': verse['chapter'] as int,
          'verse': verse['verse'] as int,
          'text': _stripHtml(verse['text'] as String),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      count++;
      if (count % _batchSize == 0 || count == total) {
        await batch.commit(noResult: true);
        onProgress?.call(count, total);
      }
    }
  }

  Future<void> deleteVersion(String slug) async {
    if (kIsWeb) throw UnsupportedError('Not supported on web');
    final db = await _db;
    await db.delete(
      'bible_verses',
      where: 'version = ?',
      whereArgs: [slug],
    );
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String? _versionName(String slug) {
    const names = {
      'RV1960': 'Reina-Valera 1960',
      'RV2004': 'Reina Valera Gómez 2004',
      'BTX3': 'La Biblia Textual 3ra Edicion',
      'PDT': 'Palabra de Dios para Todos',
      'NVI': 'Nueva Versión Internacional',
      'NTV': 'Nueva Traducción Viviente',
      'LBLA': 'La Biblia de las Américas',
      'KJV': 'King James Version',
      'NKJV': 'New King James Version',
      'NIV': 'New International Version',
      'NIV2011': 'New International Version 2011',
      'ESV': 'English Standard Version',
      'NASB': 'New American Standard Bible',
      'YLT': "Young's Literal Translation",
      'WEB': 'World English Bible',
      'RV1909': 'Reina Valera 1909',
    };
    return names[slug];
  }
}
