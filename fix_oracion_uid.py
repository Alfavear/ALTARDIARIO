content = open('lib/features/oracion/providers/oracion_providers.dart', 'r', encoding='utf-8').read()

# Fix first occurrence (peticionesStreamProvider)
old1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>("""

new1 = """final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<PeticionOracion>>>( """

content = content.replace(old1, new1, 1)

# Fix second occurrence (peticionesFiltradasProvider)
old2 = """final peticionesFiltradasProvider =
    StreamProvider<List<PeticionOracion>>((ref) {
  final filtro = ref.watch(peticionesFiltroProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>("""

new2 = """final peticionesFiltradasProvider =
    StreamProvider<List<PeticionOracion>>((ref) {
  final filtro = ref.watch(peticionesFiltroProvider);
  final uid = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosProvider(uid));
  return blockedAsync.when<Stream<List<PeticionOracion>>>("""

content = open('lib/features/oracion/providers/oracion_providers.dart', 'r', encoding='utf-8').read()
content = content.replace(old1, new1, 1)
content = content.replace(old2, new2, 1)

with open('lib/features/oracion/providers/oracion_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed oracion_providers UID')