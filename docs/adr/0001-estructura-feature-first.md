# ADR-0001: Estructura feature-first

**Estado:** Aceptada · **Fecha:** 2026-10-19

## Contexto
La estructura actual (`core/`, `data/`, `presentation/`) agrupa por capa. Resultado:
`app_providers.dart` con 95 providers, `firestore_service.dart` con 48 métodos,
pantallas de 1000-2000 líneas. Para un agente de IA, tocar "oración" implica
cargar en contexto código de feed, foro, biblia y perfil. Para un humano, cada
PR genera conflictos en los mismos 3 archivos.

## Decisión
Código nuevo vive en `lib/features/<feature>/{data,providers,presentation}`.
Código existente se migra **una feature por PR, sin cambios de comportamiento**.
`lib/core/` queda para lo verdaderamente transversal (tema, observabilidad,
constantes). `lib/data/models/` conserva los modelos compartidos entre features.

Orden de migración sugerido (de menor a mayor acoplamiento):
`oracion` → `foro` → `notas` → `feed` → `perfil` → `biblia`.

## Consecuencias
- Durante la migración coexisten dos estructuras; `app_providers.dart` mantiene
  `export`s de compatibilidad hasta que no quede nadie importándolo.
- `FirestoreService` se convierte en fachada que delega en repositorios por
  feature, y desaparece al terminar la migración.
- Límite duro: 400 líneas por archivo, 150 por widget privado. La CI no lo
  impone aún; el `reviewer` lo marca 🟡.
