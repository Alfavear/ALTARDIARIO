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
  final List<String> badges;
  final int totalPuntos;
  final int nivel;
  final List<String> progresoLectura;
  final int maxStreak;

  String get displayName {
    var n = nombre.trim();
    if (n.isNotEmpty && n.toLowerCase() != 'anónimo') {
      if (n.endsWith(' (Invitado)')) n = n.substring(0, n.length - 11);
      return n;
    }
    if (email.isNotEmpty && email != 'invitado@altardiario.app') {
      return email.split('@').first;
    }
    return 'Invitado';
  }

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
    this.badges = const [],
    this.totalPuntos = 0,
    this.nivel = 1,
    this.progresoLectura = const [],
    this.maxStreak = 0,
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
      badges: List<String>.from(data['badges'] ?? []),
      totalPuntos: data['totalPuntos'] ?? 0,
      nivel: data['nivel'] ?? 1,
      progresoLectura: List<String>.from(data['progresoLectura'] ?? []),
      maxStreak: data['maxStreak'] ?? 0,
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
      badges: List<String>.from(data['badges'] ?? []),
      totalPuntos: data['totalPuntos'] ?? 0,
      nivel: data['nivel'] ?? 1,
      progresoLectura: List<String>.from(data['progresoLectura'] ?? []),
      maxStreak: data['maxStreak'] ?? 0,
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
    'badges': badges,
    'totalPuntos': totalPuntos,
    'nivel': nivel,
    'progresoLectura': progresoLectura,
    'maxStreak': maxStreak,
  };

  static DateTime _readDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}