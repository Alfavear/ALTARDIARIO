class Debate {
  final String id;
  final String titulo;
  final String contenido;
  final String userId;
  final String userName;
  final String libroId;
  final String libroNombre;
  final DateTime fecha;
  final int upvotes;
  final List<String> votedBy;
  final int replyCount;

  Debate({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.userId,
    required this.userName,
    this.libroId = '',
    this.libroNombre = '',
    required this.fecha,
    this.upvotes = 0,
    this.votedBy = const [],
    this.replyCount = 0,
  });

  factory Debate.fromMap(Map<String, dynamic> map) => Debate(
        id: map['id'] ?? '',
        titulo: map['titulo'] ?? '',
        contenido: map['contenido'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        libroId: map['libroId'] ?? '',
        libroNombre: map['libroNombre'] ?? '',
        fecha: map['fecha'] != null
            ? (map['fecha'] is String
                ? DateTime.parse(map['fecha'])
                : (map['fecha'] as dynamic).toDate())
            : DateTime.now(),
        upvotes: map['upvotes'] ?? 0,
        votedBy: map['votedBy'] != null
            ? List<String>.from(map['votedBy'])
            : [],
        replyCount: map['replyCount'] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'contenido': contenido,
        'userId': userId,
        'userName': userName,
        'libroId': libroId,
        'libroNombre': libroNombre,
        'fecha': fecha.toIso8601String(),
        'upvotes': upvotes,
        'votedBy': votedBy,
        'replyCount': replyCount,
      };

  bool hasVoted(String userId) => votedBy.contains(userId);
}
