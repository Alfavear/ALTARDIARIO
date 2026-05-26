class PeticionOracion {
  final String id;
  final String usuarioId;
  final String texto;
  final DateTime fecha;
  final List<String> oradoPor;

  PeticionOracion({
    required this.id,
    required this.usuarioId,
    required this.texto,
    required this.fecha,
    this.oradoPor = const [],
  });

  factory PeticionOracion.fromMap(Map<String, dynamic> map) => PeticionOracion(
        id: map['id'],
        usuarioId: map['usuarioId'],
        texto: map['texto'],
        fecha: DateTime.parse(map['fecha']),
        oradoPor: List<String>.from(map['oradoPor'] ?? []),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuarioId': usuarioId,
        'texto': texto,
        'fecha': fecha.toIso8601String(),
        'oradoPor': oradoPor,
      };
}
