import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String fotoUrl;
  final String bio;
  final DateTime fechaCreacion;
  final List<String> siguiendo;
  final List<String> seguidores;
  final bool modoEnfoque;
  final int notifHour;
  final int notifMin;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoUrl = '',
    this.bio = '',
    DateTime? fechaCreacion,
    this.siguiendo = const [],
    this.seguidores = const [],
    this.modoEnfoque = false,
    this.notifHour = 20,
    this.notifMin = 0,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  factory Usuario.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Usuario(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      bio: data['bio'] ?? '',
      fechaCreacion: _readDate(data['fechaCreacion']),
      siguiendo: List<String>.from(data['siguiendo'] ?? []),
      seguidores: List<String>.from(data['seguidores'] ?? []),
      modoEnfoque: data['modoEnfoque'] ?? false,
      notifHour: data['notifHour'] ?? 20,
      notifMin: data['notifMin'] ?? 0,
    );
  }

  factory Usuario.fromMap(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'] ?? '',
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      bio: data['bio'] ?? '',
      fechaCreacion: _readDate(data['fechaCreacion']),
      siguiendo: List<String>.from(data['siguiendo'] ?? []),
      seguidores: List<String>.from(data['seguidores'] ?? []),
      modoEnfoque: data['modoEnfoque'] ?? false,
      notifHour: data['notifHour'] ?? 20,
      notifMin: data['notifMin'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'nombre': nombre,
    'email': email,
    'fotoUrl': fotoUrl,
    'bio': bio,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'siguiendo': siguiendo,
    'seguidores': seguidores,
    'modoEnfoque': modoEnfoque,
    'notifHour': notifHour,
    'notifMin': notifMin,
  };

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}