content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

# Fix reflexionesStreamProvider
old1 = """final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<Reflexion>>>( """

new1 = """final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<Reflexion>>>( """

content = content.replace(old1, new1, 1)

# Fix peticionesStreamProvider
old2 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>( """

new2 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<PeticionOracion>>>( """

content = content.replace(
    'final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider);\n  return blockedAsync.when<Stream<List<Reflexion>>>(',
    'final uid = ref.watch(effectiveUserUidProvider);\n  final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider(uid));\n  return blockedAsync.when<Stream<List<Reflexion>>>(',
    1
)

content = content.replace(
    'final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider);\n  return blockedAsync.when<Stream<List<PeticionOracion>>>( ',
    'final uid = ref.watch(effectiveUserUidProvider);\n  final AsyncValue<List<String>> blockedAsync =\n      ref.watch(usuariosBloqueadosProvider(uid));\n  return blockedAsync.when<Stream<List<PeticionOracion>>>( ',
    1
)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed peticionesStreamProvider and reflexionesStreamProvider')