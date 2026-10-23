content = open('lib/data/models/reflexion.dart', 'r', encoding='utf-8').read()

# Add oculto field to class fields
old_fields = """  final List<String> tags;"""

new_fields = """  final List<String> tags;
  final bool oculto;"""

content = content.replace(old_fields, new_fields, 1)

# Add oculto to constructor
old_constructor = """    this.tags = const [],\n  });"""

new_constructor = """    this.tags = const [],\n    this.oculto = false,\n  });"""

content = content.replace(old_constructor, new_constructor, 1)

# Add oculto to fromMap
old_frommap = """        tags: map['tags'] != null ? List<String>.from(map['tags']) : [],\n      );"""

new_frommap = """        tags: map['tags'] != null ? List<String>.from(map['tags']) : [],\n        oculto: map['oculto'] ?? false,\n      );"""

content = content.replace(old_frommap, new_frommap, 1)

# Add oculto to toMap
old_tomap = """        'tags': tags,\n      };"""

new_tomap = """        'tags': tags,\n        'oculto': oculto,\n      };"""

content = content.replace(old_tomap, new_tomap, 1)

# Add oculto to copyWith
old_copywith = """    List<String>? tags,\n  }) {"""

new_copywith = """    List<String>? tags,\n    bool? oculto,\n  }) {"""

content = content.replace(old_copywith, new_copywith, 1)

old_copywith_body = """      tags: tags ?? this.tags,\n    );"""

new_copywith_body = """      tags: tags ?? this.tags,\n      oculto: oculto ?? this.oculto,\n    );"""

content = content.replace(old_copywith_body, new_copywith_body, 1)

open('lib/data/models/reflexion.dart', 'w', encoding='utf-8').write(content)
print('Done')