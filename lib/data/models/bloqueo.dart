import 'package:cloud_firestore/cloud_firestore.dart';

/// Registro de un bloqueo de usuario: `uid` bloqueó a `blockedUid`.
/// Se guarda en `usuarios/{uid}/blocked/{blockedUid}`.
class Bloqueo {
  final String uid;
  final String blockedUid;
  final DateTime fecha;

  Bloqueo({
    required this.uid,
    required this.blockedUid,
    required this.fecha,
  });

  factory Bloqueo.fromFirestore(DocumentSnapshot doc) {
    final Map data = doc.data() as Map<String, dynamic>;
    return Bloqueo(
      uid: data['uid'] ?? '',
      blockedUid: data['blockedUid'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
    );
  }

  factory Bloqueo.fromMap(Map<String, dynamic> data) {
    return Bloqueo(
      uid: data['uid'] ?? '',
      blockedUid: data['blockedUid'] ?? '',
      fecha: data['fecha'] != null
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'blockedUid': blockedUid,
        'fecha': Timestamp.fromDate(fecha),
      };
}
