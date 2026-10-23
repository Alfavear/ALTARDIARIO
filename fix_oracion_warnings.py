content = open('lib/features/oracion/providers/oracion_providers.dart', 'r', encoding='utf-8').read()

# Remove unnecessary import
content = content.replace("import 'package:altar_diario/features/oracion/data/oracion_repository.dart';\n", '', 1)

# Fix unused uid variable - prefix with underscore
content = content.replace('final uid = ref.watch(effectiveUserUidProvider);', 'final _ = ref.watch(effectiveUserUidProvider);', 10)

with open('lib/features/oracion/providers/oracion_providers.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed oracion_providers warnings')