content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

old = """debateRepliesStreamProvider =
    StreamProvider.family<List<DebateReply>, String>((ref, debateId) {
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<DebateReply>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .debateRepliesStream(debateId)
          .map((replies) {
        return replies.where((r) {
          final isBlocked = blockedIds.contains(r.userId);
          final isHidden = r.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .debateRepliesStream(debateId)
        .map((r) => r.where((r) => r.oculto != true).toList()),
    error: (_, __) => ref
        .watch(firestoreServiceProvider)
        .debateRepliesStream(debateId)
        .map((r) => r.where((r) => r.oculto != true).toList()),
  );
});"""

new = """debateRepliesStreamProvider =
    StreamProvider.family<List<DebateReply>, String>((ref, debateId) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<DebateReply>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(firestoreServiceProvider)
          .debateRepliesStream(debateId)
          .map((replies) {
        return replies.where((r) {
          final isBlocked = blockedIds.contains(r.userId);
          final isHidden = r.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(firestoreServiceProvider)
        .debateRepliesStream(debateId)
        .map((r) => r.where((r) => r.oculto != true).toList()),
    error: (_, __) => ref
        .watch(firestoreServiceProvider)
        .debateRepliesStream(debateId)
        .map((r) => r.where((r) => r.oculto != true).toList()),
  );
});"""

content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()
content = content.replace(old, new, 1)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed debateRepliesStreamProvider')