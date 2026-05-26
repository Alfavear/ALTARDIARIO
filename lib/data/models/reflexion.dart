class Reflexion {
  final String id;
  final String usuarioId;
  final String texto;
  final DateTime fecha;
  final List<String> likes;
  final List<String> comentarios;

  Reflexion({
    required this.id,
    required this.usuarioId,
    required this.texto,
    required this.fecha,
    this.likes = const [],
    this.comentarios = const [],
  });

  factory Reflexion.fromMap(Map<String, dynamic> map) => Reflexion(
        id: map['id'],
        usuarioId: map['usuarioId'],
        texto: map['texto'],
        fecha: DateTime.parse(map['fecha']),
        likes: List<String>.from(map['likes'] ?? []),
        comentarios: List<String>.from(map['comentarios'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuarioId': usuarioId,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'likes': likes,
        'comentarios': comentarios,
      };
}
