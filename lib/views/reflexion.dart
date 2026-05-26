import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Reflexion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Reflexion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuario Anónimo',
      texto: data['texto'] ?? '',
      pasajeDia: data['pasajeDia'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'texto': texto,
      'pasajeDia': pasajeDia,
      'fecha': Timestamp.fromDate(fecha),
      'likes': likes,
    };
  }
}