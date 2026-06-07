import 'dart:convert';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromMap(Map<String, dynamic> map) => Note(
        id: map['id'] as String,
        title: map['title'] as String? ?? '',
        content: map['content'] as String? ?? '',
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  static String encodeList(List<Note> notes) =>
      jsonEncode(notes.map((n) => n.toMap()).toList());

  static List<Note> decodeList(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => Note.fromMap(e as Map<String, dynamic>)).toList();
  }
}
