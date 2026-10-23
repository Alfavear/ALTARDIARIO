content = open('lib/data/models/debate_reply.dart', 'r', encoding='utf-8').read()

# Add oculto field to the class
old_class = """class DebateReply {
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
  });"""

new_class = """class DebateReply {
  final String id;
  final String debateId;
  final String userId;
  final String userName;
  final String texto;
  final DateTime fecha;
  final int upvotes;
  final List<String> votedBy;
  final String? parentId;
  final bool oculto;

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
    this.oculto = false,
  });"""

content = content.replace(old_class, new_class, 1)

# Update fromMap
old_frommap = """factory DebateReply.fromMap(Map<String, dynamic> map) => DebateReply(
        id: map['id'] ?? '',
        debateId: map['debateId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        texto: map['texto'] ?? '',
        fecha: map['fecha'] != null
            ? (map['fecha'] is String
                ? DateTime.parse(map['fecha'])
                : (map['fecha'] as dynamic).toDate())
            : DateTime.now(),
        upvotes: map['upvotes'] ?? 0,
        votedBy:
            map['votedBy'] != null ? List<String>.from(map['votedBy']) : [],
        parentId: map['parentId'] as String?,
      );"""

new_frommap = """factory DebateReply.fromMap(Map<String, dynamic> map) => DebateReply(
        id: map['id'] ?? '',
        debateId: map['debateId'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? 'Anónimo',
        texto: map['texto'] ?? '',
        fecha: map['fecha'] != null
            ? (map['fecha'] is String
                ? DateTime.parse(map['fecha'])
                : (map['fecha'] as dynamic).toDate())
            : DateTime.now(),
        upvotes: map['upvotes'] ?? 0,
        votedBy:
            map['votedBy'] != null ? List<String>.from(map['votedBy']) : [],
        parentId: map['parentId'] as String?,
        oculto: map['oculto'] ?? false,
      );"""

content = content.replace(old_frommap, new_frommap, 1)

# Update toMap
old_tomap = """Map<String, dynamic> toMap() => {
        'debateId': debateId,
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'upvotes': upvotes,
        'votedBy': votedBy,
        if (parentId != null) 'parentId': parentId,
      };"""

new_tomap = """Map<String, dynamic> toMap() => {
        'debateId': debateId,
        'userId': userId,
        'userName': userName,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'upvotes': upvotes,
        'votedBy': votedBy,
        if (parentId != null) 'parentId': parentId,
        'oculto': oculto,
      };"""

content = content.replace(old_tomap, new_tomap, 1)

with open('lib/data/models/debate_reply.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('DebateReply updated successfully')