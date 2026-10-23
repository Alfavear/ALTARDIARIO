content = open('lib/data/models/peticion_oracion.dart', 'r', encoding='utf-8').read()

old = """factory PeticionOracion.fromFirestore(DocumentSnapshot doc) {
    final Map data = doc.data() as Map<String, dynamic>;
    return PeticionOracion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
    );
  }

  factory PeticionOracion.fromMap(Map<String, dynamic> data) {
    return PeticionOracion(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      motivo: data['motivo'] ?? '',
      fecha: data['fecha'] != null
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'motivo': motivo,
      'fecha': Timestamp.fromDate(fecha),
      'oracionesCount': oracionesCount,
      'respondida': respondida,
      'fechaRespondida':
          fechaRespondida != null ? Timestamp.fromDate(fechaRespondida!) : null,
    };
  }
}"""

new = """factory PeticionOracion.fromFirestore(DocumentSnapshot doc) {
    final Map data = doc.data() as Map<String, dynamic>;
    return PeticionOracion(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
      oculto: data['oculto'] ?? false,
    );
  }

  factory PeticionOracion.fromMap(Map<String, dynamic> data) {
    return PeticionOracion(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      motivo: data['motivo'] ?? '',
      fecha: data['fecha'] != null
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
      oculto: data['oculto'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'motivo': motivo,
      'fecha': Timestamp.fromDate(fecha),
      'oracionesCount': oracionesCount,
      'respondida': respondida,
      'fechaRespondida':
          fechaRespondida != null ? Timestamp.fromDate(fechaRespondida!) : null,
      'oculto': oculto,
    };
  }
}"""

content = content.replace(old, new, 1)

with open('lib/data/models/peticion_oracion.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('PeticionOracion updated successfully')