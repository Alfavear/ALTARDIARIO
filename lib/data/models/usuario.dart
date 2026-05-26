import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String fotoUrl;
  final List<String> siguiendo; // IDs de usuarios a los que sigue
  final List<String> seguidores; // IDs de usuarios que le siguen

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoUrl = '',
    this.siguiendo = const [],
    this.seguidores = const [],
  });

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      siguiendo: List<String>.from(data['siguiendo'] ?? []),
      seguidores: List<String>.from(data['seguidores'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'email': email,
    'fotoUrl': fotoUrl,
    'siguiendo': siguiendo,
    'seguidores': seguidores,
  };
}