/// Modelo de datos para la lectura de un día específico del plan.
class LecturaDia {
  /// Clave de fecha en formato "MM-dd" (ej: "01-15" para 15 de Enero).
  final String fechaClave;

  /// Texto de los pasajes bíblicos a leer (ej: "Génesis 1–3; Juan 1–2").
  final String pasajes;

  /// Si la lectura de este día fue completada por el usuario.
  bool completada;

  LecturaDia({
    required this.fechaClave,
    required this.pasajes,
    this.completada = false,
  });

  /// Obtiene el número de mes (1-12) desde la fecha clave.
  int get mes => int.parse(fechaClave.split('-')[0]);

  /// Obtiene el número de día (1-31) desde la fecha clave.
  int get dia => int.parse(fechaClave.split('-')[1]);

  /// Genera un DateTime para este día en el año dado.
  DateTime toDateTime(int anio) => DateTime(anio, mes, dia);

  @override
  String toString() => 'LecturaDia($fechaClave: $pasajes, completada: $completada)';
}
