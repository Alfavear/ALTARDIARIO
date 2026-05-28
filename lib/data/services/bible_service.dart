import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/bible_models.dart';

class ParsedPassage {
  final String reference;
  final int bookId;
  final String bookName;
  final int chapterStart;
  final int? verseStart;
  final int? chapterEnd;
  final int? verseEnd;

  const ParsedPassage({
    required this.reference,
    required this.bookId,
    required this.bookName,
    required this.chapterStart,
    required this.verseStart,
    required this.chapterEnd,
    required this.verseEnd,
  });
}

class BibleService {
  static const List<BibleVersion> availableVersions = [
    BibleVersion(id: 'rv1909', name: 'Reina Valera 1909', lang: 'es'),
  ];

  static const String _seedAsset = 'assets/bible/es_rv1909_seed.json';
  static const String _databaseName = 'altar_diario_bible.db';
  static const int _databaseVersion = 1;

  static const Map<String, int> _bookMap = {
    'genesis': 1,
    'génesis': 1,
    'exodo': 2,
    'éxodo': 2,
    'levitico': 3,
    'levítico': 3,
    'numeros': 4,
    'números': 4,
    'deuteronomio': 5,
    'josue': 6,
    'josué': 6,
    'jueces': 7,
    'rut': 8,
    '1 samuel': 9,
    '2 samuel': 10,
    '1 reyes': 11,
    '2 reyes': 12,
    '1 cronicas': 13,
    '1 crónicas': 13,
    '2 cronicas': 14,
    '2 crónicas': 14,
    'esdras': 15,
    'nehemias': 16,
    'nehemías': 16,
    'ester': 17,
    'job': 18,
    'salmo': 19,
    'salmos': 19,
    'proverbios': 20,
    'eclesiastes': 21,
    'eclesiastés': 21,
    'cantares': 22,
    'isaias': 23,
    'isaías': 23,
    'jeremias': 24,
    'jeremías': 24,
    'lamentaciones': 25,
    'ezequiel': 26,
    'daniel': 27,
    'oseas': 28,
    'joel': 29,
    'amos': 30,
    'amós': 30,
    'abdias': 31,
    'abdías': 31,
    'jonas': 32,
    'jonás': 32,
    'miqueas': 33,
    'nahum': 34,
    'nahúm': 34,
    'habacuc': 35,
    'sofonias': 36,
    'sofonías': 36,
    'hageo': 37,
    'zacarias': 38,
    'zacarías': 38,
    'malaquias': 39,
    'malaquías': 39,
    'mateo': 40,
    'marcos': 41,
    'lucas': 42,
    'juan': 43,
    'jn': 43,
    'hechos': 44,
    'romanos': 45,
    '1 corintios': 46,
    '2 corintios': 47,
    'galatas': 48,
    'gálatas': 48,
    'efesios': 49,
    'filipenses': 50,
    'colosenses': 51,
    '1 tesalonicenses': 52,
    '2 tesalonicenses': 53,
    '1 timoteo': 54,
    '2 timoteo': 55,
    'tito': 56,
    'filemon': 57,
    'filemón': 57,
    'hebreos': 58,
    'santiago': 59,
    '1 pedro': 60,
    '2 pedro': 61,
    '1 juan': 62,
    '2 juan': 63,
    '3 juan': 64,
    'judas': 65,
    'apocalipsis': 66,
  };

  static final RegExp _passageRegex = RegExp(
    r'^(.+?)\s+(\d+)(?::(\d+))?(?:\s*[-–—]\s*(?:(\d+):)?(\d+))?$',
    caseSensitive: false,
  );

  Database? _database;

  Future<List<BiblePassage>> getPassageText(
    String query, {
    String version = 'rv1909',
  }) async {
    final db = await _db;
    final passages =
        query.split(';').map((p) => p.trim()).where((p) => p.isNotEmpty);
    final results = <BiblePassage>[];

    for (final passage in passages) {
      final parsed = parsePassage(passage);
      if (parsed == null) {
        results.add(BiblePassage(
          reference: passage,
          verses: const [],
          message: 'Formato de pasaje no soportado.',
        ));
        continue;
      }

      final rows = await _queryPassage(db, parsed, version);
      results.add(BiblePassage(
        reference: passage,
        verses: rows.map(BibleVerse.fromMap).toList(),
        message: rows.isEmpty
            ? 'Este pasaje aún no está disponible en la Biblia offline incluida.'
            : null,
      ));
    }

    return results.toList();
  }

  Future<List<BibleHighlight>> getHighlightsForPassages(
    List<BiblePassage> passages, {
    String? userId,
  }) async {
    final db = await _db;
    final anchors = _chapterAnchors(passages);
    if (anchors.isEmpty) return const [];

    final highlights = <BibleHighlight>[];
    for (final anchor in anchors) {
      final rows = await db.query(
        'bible_highlights',
        where:
            'version = ? AND book_id = ? AND chapter = ? AND (user_id = ? OR user_id IS NULL)',
        whereArgs: [anchor.version, anchor.bookId, anchor.chapter, userId],
        orderBy: 'updated_at DESC',
      );
      highlights.addAll(rows.map(BibleHighlight.fromMap));
    }
    return highlights;
  }

  Future<void> upsertSyncedHighlights(List<BibleHighlight> highlights) async {
    if (highlights.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final highlight in highlights) {
      batch.insert(
        'bible_highlights',
        highlight.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<BibleNote>> getNotesForPassages(
    List<BiblePassage> passages, {
    String? userId,
  }) async {
    final db = await _db;
    final anchors = _chapterAnchors(passages);
    if (anchors.isEmpty) return const [];

    final notes = <BibleNote>[];
    for (final anchor in anchors) {
      final rows = await db.query(
        'bible_notes',
        where:
            'version = ? AND book_id = ? AND chapter = ? AND (user_id = ? OR user_id IS NULL)',
        whereArgs: [anchor.version, anchor.bookId, anchor.chapter, userId],
        orderBy: 'updated_at DESC',
      );
      notes.addAll(rows.map(BibleNote.fromMap));
    }
    return notes;
  }

  Future<void> upsertSyncedNotes(List<BibleNote> notes) async {
    if (notes.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final note in notes) {
      batch.insert(
        'bible_notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<BibleHighlight> saveHighlight({
    required BibleVerse verse,
    required String colorHex,
    String? userId,
  }) async {
    final now = DateTime.now();
    final highlight = BibleHighlight(
      id: _localId('highlight'),
      userId: userId,
      version: verse.version,
      bookId: verse.bookId,
      chapter: verse.chapter,
      verseStart: verse.verse,
      verseEnd: verse.verse,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
      syncStatus: userId == null ? 'local' : 'pending',
    );
    final db = await _db;
    await db.delete(
      'bible_highlights',
      where:
          'version = ? AND book_id = ? AND chapter = ? AND verse_start <= ? AND verse_end >= ? AND (user_id = ? OR user_id IS NULL)',
      whereArgs: [
        verse.version,
        verse.bookId,
        verse.chapter,
        verse.verse,
        verse.verse,
        userId,
      ],
    );
    await db.insert(
      'bible_highlights',
      highlight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return highlight;
  }

  Future<void> deleteHighlight(String highlightId) async {
    final db = await _db;
    await db.delete(
      'bible_highlights',
      where: 'id = ?',
      whereArgs: [highlightId],
    );
  }

  Future<BibleNote> saveNote({
    required BibleVerse verse,
    required String body,
    String? userId,
    BibleNote? existingNote,
  }) async {
    final now = DateTime.now();
    final note = BibleNote(
      id: existingNote?.id ?? _localId('note'),
      userId: userId,
      version: verse.version,
      bookId: verse.bookId,
      bookName: verse.bookName,
      chapter: verse.chapter,
      verse: verse.verse,
      body: body.trim(),
      createdAt: existingNote?.createdAt ?? now,
      updatedAt: now,
      syncStatus: userId == null ? 'local' : 'pending',
    );
    final db = await _db;
    await db.insert(
      'bible_notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return note;
  }

  Future<void> deleteNote(String noteId) async {
    final db = await _db;
    await db.delete(
      'bible_notes',
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  Future<void> markHighlightSynced(String highlightId) async {
    final db = await _db;
    await db.update(
      'bible_highlights',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [highlightId],
    );
  }

  Future<void> markNoteSynced(String noteId) async {
    final db = await _db;
    await db.update(
      'bible_notes',
      {'sync_status': 'synced'},
      where: 'id = ?',
      whereArgs: [noteId],
    );
  }

  ParsedPassage? parsePassage(String raw) {
    final match = _passageRegex.firstMatch(raw.trim());
    if (match == null) return null;

    final bookName = match.group(1)!.trim();
    final bookId = _mapBookToId(bookName);
    if (bookId == -1) return null;

    final chapterStart = int.parse(match.group(2)!);
    final verseStart =
        match.group(3) == null ? null : int.parse(match.group(3)!);
    final endChapterOrVerse =
        match.group(4) == null ? null : int.parse(match.group(4)!);
    final endVerse = match.group(5) == null ? null : int.parse(match.group(5)!);

    return ParsedPassage(
      reference: raw.trim(),
      bookId: bookId,
      bookName: getBookNameFromId(bookId),
      chapterStart: chapterStart,
      verseStart: verseStart,
      chapterEnd: verseStart == null ? endVerse : endChapterOrVerse,
      verseEnd: verseStart == null ? null : endVerse,
    );
  }

  List<String> getBookNames() {
    final seen = <int>{};
    final books = _bookMap.entries
        .where((entry) => seen.add(entry.value))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return books.map((entry) => getBookNameFromId(entry.value)).toList();
  }

  List<BibleChapterAnchor> getChapterAnchors(List<BiblePassage> passages) {
    return _chapterAnchors(passages);
  }

  String getBookNameFromId(int id) {
    const names = {
      1: 'Génesis',
      2: 'Éxodo',
      3: 'Levítico',
      4: 'Números',
      5: 'Deuteronomio',
      6: 'Josué',
      7: 'Jueces',
      8: 'Rut',
      9: '1 Samuel',
      10: '2 Samuel',
      11: '1 Reyes',
      12: '2 Reyes',
      13: '1 Crónicas',
      14: '2 Crónicas',
      15: 'Esdras',
      16: 'Nehemías',
      17: 'Ester',
      18: 'Job',
      19: 'Salmos',
      20: 'Proverbios',
      21: 'Eclesiastés',
      22: 'Cantares',
      23: 'Isaías',
      24: 'Jeremías',
      25: 'Lamentaciones',
      26: 'Ezequiel',
      27: 'Daniel',
      28: 'Oseas',
      29: 'Joel',
      30: 'Amós',
      31: 'Abdías',
      32: 'Jonás',
      33: 'Miqueas',
      34: 'Nahúm',
      35: 'Habacuc',
      36: 'Sofonías',
      37: 'Hageo',
      38: 'Zacarías',
      39: 'Malaquías',
      40: 'Mateo',
      41: 'Marcos',
      42: 'Lucas',
      43: 'Juan',
      44: 'Hechos',
      45: 'Romanos',
      46: '1 Corintios',
      47: '2 Corintios',
      48: 'Gálatas',
      49: 'Efesios',
      50: 'Filipenses',
      51: 'Colosenses',
      52: '1 Tesalonicenses',
      53: '2 Tesalonicenses',
      54: '1 Timoteo',
      55: '2 Timoteo',
      56: 'Tito',
      57: 'Filemón',
      58: 'Hebreos',
      59: 'Santiago',
      60: '1 Pedro',
      61: '2 Pedro',
      62: '1 Juan',
      63: '2 Juan',
      64: '3 Juan',
      65: 'Judas',
      66: 'Apocalipsis',
    };
    return names[id] ?? 'Libro $id';
  }

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      p.join(dbPath, _databaseName),
      version: _databaseVersion,
      onCreate: _createSchema,
      onOpen: _seedIfNeeded,
    );
    return _database!;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bible_verses (
        version TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        PRIMARY KEY (version, book_id, chapter, verse)
      )
    ''');
    await db.execute('''
      CREATE TABLE bible_highlights (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        version TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        chapter INTEGER NOT NULL,
        verse_start INTEGER NOT NULL,
        verse_end INTEGER NOT NULL,
        color_hex TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE bible_notes (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        version TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        book_name TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        body TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        sync_status TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_bible_highlights_anchor ON bible_highlights(version, book_id, chapter)',
    );
    await db.execute(
      'CREATE INDEX idx_bible_notes_anchor ON bible_notes(version, book_id, chapter, verse)',
    );
  }

  Future<void> _seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM bible_verses'),
    );
    if ((count ?? 0) > 0) return;

    final rawJson = await rootBundle.loadString(_seedAsset);
    final data = jsonDecode(rawJson) as Map<String, dynamic>;
    final version = data['version'] as String;
    final batch = db.batch();

    for (final book in data['books'] as List<dynamic>) {
      final bookMap = book as Map<String, dynamic>;
      final bookId = bookMap['id'] as int;
      final bookName = bookMap['name'] as String;
      for (final chapter in bookMap['chapters'] as List<dynamic>) {
        final chapterMap = chapter as Map<String, dynamic>;
        final chapterNumber = chapterMap['number'] as int;
        for (final verse in chapterMap['verses'] as List<dynamic>) {
          final verseMap = verse as Map<String, dynamic>;
          batch.insert(
            'bible_verses',
            BibleVerse(
              version: version,
              bookId: bookId,
              bookName: bookName,
              chapter: chapterNumber,
              verse: verseMap['number'] as int,
              text: verseMap['text'] as String,
            ).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }

    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> _queryPassage(
    Database db,
    ParsedPassage passage,
    String version,
  ) {
    if (passage.verseStart == null) {
      return db.query(
        'bible_verses',
        where: 'version = ? AND book_id = ? AND chapter BETWEEN ? AND ?',
        whereArgs: [
          version,
          passage.bookId,
          passage.chapterStart,
          passage.chapterEnd ?? passage.chapterStart,
        ],
        orderBy: 'chapter ASC, verse ASC',
      );
    }

    if (passage.chapterEnd != null && passage.verseEnd != null) {
      return db.query(
        'bible_verses',
        where: '''
          version = ? AND book_id = ? AND (
            (chapter = ? AND verse >= ?) OR
            (chapter > ? AND chapter < ?) OR
            (chapter = ? AND verse <= ?)
          )
        ''',
        whereArgs: [
          version,
          passage.bookId,
          passage.chapterStart,
          passage.verseStart,
          passage.chapterStart,
          passage.chapterEnd,
          passage.chapterEnd,
          passage.verseEnd,
        ],
        orderBy: 'chapter ASC, verse ASC',
      );
    }

    return db.query(
      'bible_verses',
      where:
          'version = ? AND book_id = ? AND chapter = ? AND verse BETWEEN ? AND ?',
      whereArgs: [
        version,
        passage.bookId,
        passage.chapterStart,
        passage.verseStart,
        passage.verseEnd ?? passage.verseStart,
      ],
      orderBy: 'verse ASC',
    );
  }

  int _mapBookToId(String name) {
    final normalized =
        name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return _bookMap[normalized] ?? -1;
  }

  List<BibleChapterAnchor> _chapterAnchors(
    List<BiblePassage> passages,
  ) {
    final seen = <String>{};
    final anchors = <BibleChapterAnchor>[];
    for (final passage in passages) {
      for (final verse in passage.verses) {
        final key = '${verse.version}:${verse.bookId}:${verse.chapter}';
        if (seen.add(key)) {
          anchors.add(BibleChapterAnchor(
            version: verse.version,
            bookId: verse.bookId,
            chapter: verse.chapter,
          ));
        }
      }
    }
    return anchors;
  }

  String _localId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}
