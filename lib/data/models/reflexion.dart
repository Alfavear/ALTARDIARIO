class Reflexion {
  final String id;
  final String userId;
  final String userName;
  final String texto;
  final String pasajeDia;
  final DateTime fecha;
  final int likes;

  Reflexion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.texto,
    required this.pasajeDia,
    required this.fecha,
    this.likes = 0,
  });

  factory Reflexion.fromMap(Map<String, dynamic> map) => Reflexion(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        texto: map['texto'] ?? '',
        pasajeDia: map['pasajeDia'] ?? '',
        fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
        likes: map['likes'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'pasajeDia': pasajeDia,
        'fecha': fecha.toIso8601String(),
        'likes': likes,
      };
}
