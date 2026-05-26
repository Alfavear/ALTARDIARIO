class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String? fotoUrl;
  final List<String> companeros;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.fotoUrl,
    this.companeros = const [],
  });

  factory Usuario.fromMap(Map<String, dynamic> map) => Usuario(
        id: map['id'],
        nombre: map['nombre'],
        email: map['email'],
        fotoUrl: map['fotoUrl'],
        companeros: List<String>.from(map['companeros'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'fotoUrl': fotoUrl,
        'companeros': companeros,
      };
}
