---
name: flutter-performance
description: Heurísticas para optimización de rendimiento en Flutter, mitigación de jank, control de rebuilds innecesarios en Riverpod y gestión de memoria.
---

# PROTOCOLO DE RENDIMIENTO FLUTTER (ANTI-LAG)

Al implementar o refactorizar código en Flutter:

## 1. Rebuilds y Gestión de Estado (Riverpod)
- Prohibido llamar `ref.watch(provider)` sobre modelos gigantes en métodos `build()` de vistas complejas.
- Usa `ref.watch(provider.select((s) => s.campoEspecifico))` para aislar rebuilds solo cuando cambie el dato necesario.
- Desacopla subárboles costosos en widgets independientes con `Consumer` o `const` constructor para delimitar la invalidación.

## 2. Optimización de Listas y Scroll
- Prohibido anidar `SingleChildScrollView` + `Column` para colecciones dinámicas de más de 5 elementos.
- Emplea siempre `ListView.builder` o `CustomScrollView` con `SliverList.builder`.
- Define `itemExtent` o `prototypeItem` cuando la altura de los elementos sea uniforme para optimizar los cálculos de renderizado.

## 3. Eficiencia en Memoria y Render
- Antepone `const` a constructores, paddings y decoraciones estáticas.
- Limpia de forma obligatoria controladores (`TextEditingController`, `AnimationController`, `ScrollController`) dentro del método `dispose()`.
- Prohíbe operaciones síncronas costosas o decodificación de JSON masivos dentro del hilo principal de UI; usa `compute()` para tareas intensivas.
