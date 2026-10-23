content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()

# Replace all remaining occurrences
content = content.replace(
    'final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosProvider);',
    'final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosActualProvider);',
    10
)

content = content.replace(
    'final blockedAsync = ref.watch(usuariosBloqueadosProvider);',
    'final AsyncValue<List<String>> blockedAsync = ref.watch(usuariosBloqueadosActualProvider);',
    10
)

with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed remaining provider calls')