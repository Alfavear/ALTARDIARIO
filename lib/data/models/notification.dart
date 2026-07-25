import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, String> data;
  final String? actorId;
  final String? actorName;
  final String? actorFotoUrl;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.actorId,
    this.actorName,
    this.actorFotoUrl,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: Map<String, String>.from(map['data'] ?? {}),
      actorId: map['actorId'],
      actorName: map['actorName'],
      actorFotoUrl: map['actorFotoUrl'],
      read: map['read'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'actorId': actorId,
      'actorName': actorName,
      'actorFotoUrl': actorFotoUrl,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Verifica si es una notificación de interacción social (para decidir prioridad)
  bool get isSocialInteraction {
    return type == 'new_follower' ||
        type == 'new_comment' ||
        type == 'new_reaction' ||
        type == 'mention';
  }

  /// Verifica si es de oración
  bool get isPrayer {
    return type == 'new_prayer';
  }

  /// Verifica si es de debate
  bool get isDebate {
    return type == 'debate_reply';
  }
}