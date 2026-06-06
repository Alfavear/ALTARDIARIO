class Reflexion {
  final String id;
  final String userId;
  final String userName;
  final String texto;
  final String pasajeDia;
  final DateTime fecha;
  final int likes;
  final List<String> likedBy;

  Reflexion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.texto,
    required this.pasajeDia,
    required this.fecha,
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Reflexion.fromMap(Map<String, dynamic> map) => Reflexion(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        texto: map['texto'] ?? '',
        pasajeDia: map['pasajeDia'] ?? '',
        fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
        likes: map['likes'] ?? 0,
        likedBy: map['likedBy'] != null ? List<String>.from(map['likedBy']) : [],
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'pasajeDia': pasajeDia,
        'fecha': fecha.toIso8601String(),
        'likes': likes,
        'likedBy': likedBy,
      };

  bool isLikedBy(String userId) => likedBy.contains(userId);

  Reflexion copyWith({
    String? id,
    String? userId,
    String? userName,
    String? texto,
    String? pasajeDia,
    DateTime? fecha,
    int? likes,
    List<String>? likedBy,
  }) {
    return Reflexion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      texto: texto ?? this.texto,
      pasajeDia: pasajeDia ?? this.pasajeDia,
      fecha: fecha ?? this.fecha,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
