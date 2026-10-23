content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

# Fix peticionesStreamProvider
old1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>( """

new1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return Stream.value([]);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<PeticionOracion>>>( """

# Fix debatesStreamProvider
old2 = """debatesStreamProvider =
    StreamProvider.family<List<Debate>, String?>((ref, libroId) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<Debate>>>( """

new2 = """debatesStreamProvider =
    StreamProvider.family<List<Debate>, String?>((ref, libroId) {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return Stream.value([]);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<Debate>>>( """

# Fix debateRepliesStreamProvider
old3 = """debateRepliesStreamProvider =
    StreamProvider.family<List<DebateReply>, String>((ref, debateId) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<DebateReply>>>("""

new3 = """debateRepliesStreamProvider =
    StreamProvider.family<List<DebateReply>, String>((ref, debateId) {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return Stream.value([]);
  final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<DebateReply>>>("""

content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()
content = content.replace(old1, new1, 1)
content = content.replace(old2, new2, 1)
content = content.replace(old3, new3, 1)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed all providers with UID null checks')