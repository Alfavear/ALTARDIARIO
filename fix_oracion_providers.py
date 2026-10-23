content = open('lib/features/oracion/providers/oracion_providers.dart', 'r', encoding='utf-8').read()

old1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<List<PeticionOracion>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(oracionRepositoryProvider)
          .peticionesStream()
          .map((peticiones) {
        return peticiones.where((p) {
          final isBlocked = blockedIds.contains(p.userId);
          final isHidden = p.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
  );
});"""

new1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(oracionRepositoryProvider)
          .peticionesStream()
          .map((peticiones) {
        return peticiones.where((p) {
          final isBlocked = blockedIds.contains(p.userId);
          final isHidden = p.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
  );
});"""

content = open('lib/features/oracion/providers/oracion_providers.dart', 'r', encoding='utf-8').read()
content = content.replace(
    'return blockedAsync.when<List<PeticionOracion>>(',
    'return blockedAsync.when<Stream<List<PeticionOracion>>>(',
    1
)

with open('lib/features/oracion/providers/oracion_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content.replace(
        'final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {\n  final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider);\n  return blockedAsync.when<List<PeticionOracion>>(\n    data: (blocked) {\n      final blockedIds = blocked.toSet();\n      return ref\n          .watch(oracionRepositoryProvider)\n          .peticionesStream()\n          .map((peticiones) {\n        return peticiones.where((p) {\n          final isBlocked = blockedIds.contains(p.userId);\n          final isHidden = p.oculto == true;\n          return !isBlocked && !isHidden;\n        }).toList();\n      });\n    },\n    loading: () => ref\n        .watch(oracionRepositoryProvider)\n        .peticionesStream()\n        .map((p) => p.where((p) => p.oculto != true).toList()),\n    error: (_, __) => ref\n        .watch(oracionRepositoryProvider)\n        .peticionesStream()\n        .map((p) => p.where((p) => p.oculto != true).toList()),\n  );\n});',
    'final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {\n  final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider);\n  return blockedAsync.when<Stream<List<PeticionOracion>>>(\n    data: (blocked) {\n      final blockedIds = blocked.toSet();\n      return ref\n          .watch(oracionRepositoryProvider)\n          .peticionesStream()\n          .map((peticiones) {\n        return peticiones.where((p) {\n          final isBlocked = blockedIds.contains(p.userId);\n          final isHidden = p.oculto == true;\n          return !isBlocked && !isHidden;\n        }).toList();\n      });\n    },\n    loading: () => ref\n        .watch(oracionRepositoryProvider)\n        .peticionesStream()\n        .map((p) => p.where((p) => p.oculto != true).toList()),\n    error: (_, __) => ref\n        .watch(oracionRepositoryProvider)\n        .peticionesStream()\n        .map((p) => p.where((p) => p.oculto != true).toList()),\n  );\n});',
    1
))

with open('lib/features/oracion/providers/oracion_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('oracion_providers updated successfully')