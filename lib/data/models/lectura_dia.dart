/// Modelo que representa la lectura de un día específico.
class LecturaDia {
  final int dia; // Día del año (1-365)
  final String pasajes;
  final bool completada;
  final String fechaClave; // Formato yyyy-MM-dd para persistencia

  LecturaDia({
    required this.dia,
    required this.pasajes,
    this.completada = false,
    required this.fechaClave,
  });
}