class BibleDictionaryTerm {
  final String id;
  final String palabra;
  final String origen;
  final String significado;
  final String definicion;
  final List<String> pasajes;
  final String categoria;

  const BibleDictionaryTerm({
    required this.id,
    required this.palabra,
    required this.origen,
    required this.significado,
    required this.definicion,
    required this.pasajes,
    required this.categoria,
  });

  factory BibleDictionaryTerm.fromMap(Map<String, dynamic> map) {
    return BibleDictionaryTerm(
      id: map['id'] as String? ?? '',
      palabra: map['palabra'] as String? ?? '',
      origen: map['origen'] as String? ?? '',
      significado: map['significado'] as String? ?? '',
      definicion: map['definicion'] as String? ?? '',
      pasajes: (map['pasajes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      categoria: map['categoria'] as String? ?? 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'palabra': palabra,
      'origen': origen,
      'significado': significado,
      'definicion': definicion,
      'pasajes': pasajes,
      'categoria': categoria,
    };
  }
}
