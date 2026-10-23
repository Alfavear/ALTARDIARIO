content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

# Fix debatesStreamProvider
old = """debatesStreamProvider =
    StreamProvider.family<List<Debate>, String?>((ref, libroId) {
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<Debate>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .debatesStream(libroId: libroId)
          .map((debates) {
        return debates.where((d) {
          final isBlocked = blockedIds.contains(d.userId);
          final isHidden = d.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .debatesStream(libroId: libroId)
        .map((d) => d.where((d) => d.oculto != true).toList()),
    error: (_, __) => ref
        .watch(firestoreServiceProvider)
        .debatesStream(libroId: libroId)
        .map((d) => d.where((d) => d.oculto != true).toList()),
  );
});"""

new = """debatesStreamProvider =
    StreamProvider.family<List<Debate>, String?>((ref, libroId) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<Debate>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .debatesStream(libroId: libroId)
          .map((debates) {
        return debates.where((d) {
          final isBlocked = blockedIds.contains(d.userId);
          final isHidden = d.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .debatesStream(libroId: libroId)
        .map((d) => d.where((d) => d.oculto != true).toList()),
    error: (_, __) => ref
        .watch(firestoreServiceProvider)
        .debatesStream(libroId: libroId)
        .map((d) => d.where((d) => d.oculto != true).toList()),
  );
});"""

content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()
content = content.replace(old, new, 1)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed debatesStreamProvider')