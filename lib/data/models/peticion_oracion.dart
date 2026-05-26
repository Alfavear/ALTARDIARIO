import 'package:cloud_firestore/cloud_firestore.dart';

class PeticionOracion {
  final String id;
  final String userId;
  final String userName;
  final String motivo;
  final DateTime fecha;
  final int oracionesCount;

  PeticionOracion({
    required this.id,
    required this.userId,
    required this.userName,
    required this.motivo,
    required this.fecha,
    this.oracionesCount = 0,
  });

  factory PeticionOracion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PeticionOracion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      oracionesCount: data['oracionesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'motivo': motivo,
      'fecha': Timestamp.fromDate(fecha),
      'oracionesCount': oracionesCount,
    };
  }
}