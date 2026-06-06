class BibleVersion {
  final String id;
  final String name;
  final String lang;
  final bool offline;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.lang,
    this.offline = true,
  });
}

class BibleVerse {
  final String version;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const BibleVerse({
    required this.version,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromMap(Map<String, Object?> map) {
    return BibleVerse(
      version: map['version'] as String,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'version': version,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  String get reference => '$bookName $chapter:$verse';
  String get anchor => '$version:$bookId:$chapter:$verse';
}

class BiblePassage {
  final String reference;
  final List<BibleVerse> verses;
  final String? message;

  const BiblePassage({
    required this.reference,
    required this.verses,
    this.message,
  });

  bool get hasText => verses.isNotEmpty;
}

class BibleChapterAnchor {
  final String version;
  final int bookId;
  final int chapter;

  const BibleChapterAnchor({
    required this.version,
    required this.bookId,
    required this.chapter,
  });

  String get key => '$version:$bookId:$chapter';
}

class BibleHighlight {
  final String id;
  final String? userId;
  final String version;
  final int bookId;
  final int chapter;
  final int verseStart;
  final int verseEnd;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const BibleHighlight({
    required this.id,
    required this.userId,
    required this.version,
    required this.bookId,
    required this.chapter,
    required this.verseStart,
    required this.verseEnd,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  factory BibleHighlight.fromMap(Map<String, Object?> map) {
    return BibleHighlight(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      version: map['version'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verseStart: map['verse_start'] as int,
      verseEnd: map['verse_end'] as int,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncStatus: map['sync_status'] as String,
    );
  }

  factory BibleHighlight.fromFirestoreMap({
    required String id,
    required String userId,
    required Map<String, dynamic> map,
  }) {
    final createdAt = _readDate(map['createdAt']);
    final updatedAt = _readDate(map['updatedAt']);

    return BibleHighlight(
      id: id,
      userId: userId,
      version: map['version'] as String,
      bookId: map['bookId'] as int,
      chapter: map['chapter'] as int,
      verseStart: map['verseStart'] as int,
      verseEnd: map['verseEnd'] as int,
      colorHex: map['colorHex'] as String,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: 'synced',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'version': version,
      'book_id': bookId,
      'chapter': chapter,
      'verse_start': verseStart,
      'verse_end': verseEnd,
      'color_hex': colorHex,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
    };
  }

  Map<String, Object?> toFirestoreMap() {
    return {
      'version': version,
      'bookId': bookId,
      'chapter': chapter,
      'verseStart': verseStart,
      'verseEnd': verseEnd,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool contains(BibleVerse verse) {
    return version == verse.version &&
        bookId == verse.bookId &&
        chapter == verse.chapter &&
        verse.verse >= verseStart &&
        verse.verse <= verseEnd;
  }

  String get anchor => '$version:$bookId:$chapter';
}

class BibleNote {
  final String id;
  final String? userId;
  final String version;
  final int bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;

  const BibleNote({
    required this.id,
    required this.userId,
    required this.version,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
  });

  factory BibleNote.fromMap(Map<String, Object?> map) {
    return BibleNote(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      version: map['version'] as String,
      bookId: map['book_id'] as int,
      bookName: map['book_name'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      body: map['body'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncStatus: map['sync_status'] as String,
    );
  }

  factory BibleNote.fromFirestoreMap({
    required String id,
    required String userId,
    required Map<String, dynamic> map,
  }) {
    final createdAt = _readDate(map['createdAt']);
    final updatedAt = _readDate(map['updatedAt']);

    return BibleNote(
      id: id,
      userId: userId,
      version: map['version'] as String,
      bookId: map['bookId'] as int,
      bookName: map['bookName'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      body: map['body'] as String,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncStatus: 'synced',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'version': version,
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'body': body,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_status': syncStatus,
    };
  }

  Map<String, Object?> toFirestoreMap() {
    return {
      'version': version,
      'bookId': bookId,
      'bookName': bookName,
      'chapter': chapter,
      'verse': verse,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get reference => '$bookName $chapter:$verse';
  String get anchor => '$version:$bookId:$chapter';
}

DateTime _readDate(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

  final dynamic maybeTimestamp = value;
  try {
    return maybeTimestamp.toDate() as DateTime;
  } catch (_) {
    return DateTime.now();
  }
}
