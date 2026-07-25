# Skill: Flutter + Riverpod Development

## Contexto del Proyecto
- **Framework**: Flutter 3.x + Riverpod 3.x (`flutter_riverpod`)
- **Arquitectura**: Clean Architecture modular (`lib/core`, `lib/data`, `lib/presentation`)
- **Estado**: Todos los providers en `lib/presentation/providers/app_providers.dart`
- **Patrones**: `ConsumerWidget`, `ConsumerStatefulWidget`, `NotifierProvider`, `StreamProvider`, `FutureProvider.family`

## Patrones Obligatorios

### Providers
```dart
// En app_providers.dart únicamente
final miProvider = Provider<MiServicio>((ref) => MiServicio());
final miStreamProvider = StreamProvider<List<MiModelo>>((ref) => ref.watch(firestoreServiceProvider).miStream());
final miNotifierProvider = NotifierProvider<MiNotifier, MiEstado>(() => MiNotifier());
```

### Widgets
```dart
// Stateless con Riverpod
class MiWidget extends ConsumerWidget {
  const MiWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(miProvider);
    return data.when(data: (d) => Text(d), loading: () => CircularProgressIndicator(), error: (e, _) => Text('Error: $e'));
  }
}

// Stateful con Riverpod
class MiWidget extends ConsumerStatefulWidget {
  const MiWidget({super.key});
  @override
  ConsumerState<MiWidget> createState() => _MiWidgetState();
}
class _MiWidgetState extends ConsumerState<MiWidget> { ... }
```

### Navegación
```dart
// SOLO Navigator.push + MaterialPageRoute
Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantallaDestino()));
// NO usar GoRouter, named routes, auto_route
```

## Reglas Críticas
- **NUNCA** `StatefulWidget` plano (salvo `MainNavigationView` para tab index)
- **NUNCA** `ref.read` en `build` — usar `ref.watch` o `ref.listen`
- **SIEMPRE** `AsyncValue.when(data:, loading:, error:)` en streams/futures
- Providers **solo** en `app_providers.dart`
- Imports **relativos** (`import '../models/...'`)