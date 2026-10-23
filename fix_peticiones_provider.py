content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

old = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<List<PeticionOracion>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
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
        .watch(firestoreServiceProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) =>"""

new = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
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
        .watch(firestoreServiceProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) =>"""

content = content.replace(old, new, 1)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('peticionesStreamProvider updated successfully')