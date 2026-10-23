content = open('lib/presentation/providers/app_providers.dart', 'r', encoding='utf-8').read()
content = content.replace('ref.watch(usuariosBloqueadosProvider);', 'ref.watch(usuariosBloqueadosActualProvider);', 10)
with open('lib/presentation/providers/app_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed remaining provider call')