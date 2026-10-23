content = open('lib/data/models/peticion_oracion.dart', 'r', encoding='utf-8').read()

# Fix fromFirestore - add oculto
old = """      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'An��nimo',
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
    );"""

new = """      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'An��nimo',
      motivo: data['motivo'] ?? '',
      fecha: (data['fecha'] as Timestamp).toDate(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
      oculto: data['oculto'] ?? false,
    );"""

content = content.replace(old, new, 1)

# Fix fromMap - add oculto
old2 = """      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'An��nimo',
      motivo: data['motivo'] ?? '',
      fecha: data['fecha'] != null
          ? (data['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      oracionesCount: data['oracionesCount'] ?? 0,
      respondida: data['respondida'] ?? false,
      fechaRespondida: data['fechaRespondida'] != null
          ? (data['fechaRespondida'] as Timestamp).toDate()
          : null,
    );"""

new2 = """      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'An��nimo',
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
    );"""

content = content.replace(old2, new2, 1)

open('lib/data/models/peticion_oracion.dart', 'w', encoding='utf-8').write(content)
print('Done')