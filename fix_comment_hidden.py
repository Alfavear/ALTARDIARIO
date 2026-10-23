content = """class Comment {
  final String id;
  final String reflexionId;
  final String userId;
  final String userName;
  final String userFotoUrl;
  final String texto;
  final DateTime fecha;
  final int likes;
  final List<String> likedBy;
  final bool oculto;

  Comment({
    required this.id,
    required this.reflexionId,
    required this.userId,
    required this.userName,
    this.userFotoUrl = '',
    required this.texto,
    required this.fecha,
    this.likes = 0,
    this.likedBy = const [],
    this.oculto = false,
  });

  factory Comment.fromMap(Map<String, dynamic> map) => Comment(
        id: map['id'] ?? '',
        reflexionId: map['reflexionId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userFotoUrl: map['userFotoUrl'] ?? '',
        texto: map['texto'] ?? '',
        fecha: map['fecha'] != null
            ? DateTime.parse(map['fecha'])
            : DateTime.now(),
        likes: map['likes'] ?? 0,
        likedBy:
            map['likedBy'] != null ? List<String>.from(map['likedBy']) : [],
        oculto: map['oculto'] ?? false,
      );

  Map<String, dynamic> toMap() => {
        'reflexionId': reflexionId,
        'userId': userId,
        'userName': userName,
        'userFotoUrl': userFotoUrl,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
        'oculto': oculto,
      };

  bool isLikedBy(String userId) => likedBy.contains(userId);
}"""

open('lib/data/models/comment.dart', 'w', encoding='utf-8').write(content)
print('Done')