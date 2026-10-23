content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

# Fix reflexionesStreamProvider
old = """final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<List<Reflexion>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .reflexionesStream()
          .map((reflexiones) {
        return reflexiones.where((r) {
          final isBlocked = blockedIds.contains(r.userId);
          final isHidden = r.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .reflexionesStream()
        .map((r) => r.where((r) => r.oculto != true).toList()),
    error: (_, __) =>"""

new = """final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<Reflexion>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .reflexionesStream()
          .map((reflexiones) {
        return reflexiones.where((r) {
          final isBlocked = blockedIds.contains(r.userId);
          final isHidden = r.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .reflexionesStream()
        .map((r) => r.where((r) => r.oculto != true).toList()),
    error: (_, __) =>"""

content = content.replace(old, new, 1)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('reflexionesStreamProvider updated successfully')