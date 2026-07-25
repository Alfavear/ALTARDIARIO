class DebateReply {
  final String id;
  final String debateId;
  final String userId;
  final String userName;
  final String texto;
  final DateTime fecha;
  final int upvotes;
  final List<String> votedBy;
  final String? parentId;

  DebateReply({
    required this.id,
    required this.debateId,
    required this.userId,
    required this.userName,
    required this.texto,
    required this.fecha,
    this.upvotes = 0,
    this.votedBy = const [],
    this.parentId,
  });

  factory DebateReply.fromMap(Map<String, dynamic> map) => DebateReply(
        id: map['id'] ?? '',
        debateId: map['debateId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        texto: map['texto'] ?? '',
        fecha: map['fecha'] != null
            ? DateTime.parse(map['fecha'])
            : DateTime.now(),
        upvotes: map['upvotes'] ?? 0,
        votedBy: map['votedBy'] != null
            ? List<String>.from(map['votedBy'])
            : [],
        parentId: map['parentId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'debateId': debateId,
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'upvotes': upvotes,
        'votedBy': votedBy,
        if (parentId != null) 'parentId': parentId,
      };

  bool hasVoted(String userId) => votedBy.contains(userId);
}
