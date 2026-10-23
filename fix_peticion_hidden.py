content = open('lib/data/models/peticion_oracion.dart', 'r', encoding='utf-8').read()

# Add oculto field to class fields
old_fields = """  final DateTime? fechaRespondida;"""

new_fields = """  final DateTime? fechaRespondida;
  final bool oculto;"""

content = content.replace(old_fields, new_fields, 1)

# Add oculto to constructor
old_constructor = """    this.fechaRespondida,\n  });"""

new_constructor = """    this.fechaRespondida,\n    this.oculto = false,\n  });"""

content = content.replace(old_constructor, new_constructor, 1)

# Add oculto to fromFirestore
old_fromfirestore = """        fechaRespondida: data['fechaRespondida'] != null\n          ? (data['fechaRespondida'] as Timestamp).toDate()\n          : null,\n    );"""

new_fromfirestore = """        fechaRespondida: data['fechaRespondida'] != null\n          ? (data['fechaRespondida'] as Timestamp).toDate()\n          : null,\n        oculto: data['oculto'] ?? false,\n    );"""

content = content.replace(old_fromfirestore, new_fromfirestore, 1)

# Add oculto to fromMap
old_frommap = """        fechaRespondida: data['fechaRespondida'] != null\n          ? (data['fechaRespondida'] as Timestamp).toDate()\n          : null,\n    );"""

new_frommap = """        fechaRespondida: data['fechaRespondida'] != null\n          ? (data['fechaRespondida'] as Timestamp).toDate()\n          : null,\n        oculto: data['oculto'] ?? false,\n    );"""

# We need to be careful - there are two occurrences. Let's replace the second one (fromMap)
content = content.replace(old_frommap, new_frommap, 1)

# Add oculto to toMap
old_tomap = """      'fechaRespondida':\n          fechaRespondida != null ? Timestamp.fromDate(fechaRespondida!) : null,\n    };"""

new_tomap = """      'fechaRespondida':\n          fechaRespondida != null ? Timestamp.fromDate(fechaRespondida!) : null,\n      'oculto': oculto,\n    };"""

content = content.replace(old_tomap, new_tomap, 1)

open('lib/data/models/peticion_oracion.dart', 'w', encoding='utf-8').write(content)
print('Done')