---
description: Migra una feature legacy a lib/features/<nombre>/ (usage — /migrate-feature oracion)
---
Migra la feature `$ARGUMENTS` de la estructura legacy (`lib/presentation/screens/*`,
`lib/presentation/providers/app_providers.dart`, `lib/data/services/firestore_service.dart`)
a `lib/features/$ARGUMENTS/` siguiendo ADR-0001 y la skill `feature-scaffold`:

1. Inventario: lista pantallas, widgets, providers, modelos y métodos de
   `FirestoreService` que pertenecen a esta feature. Muéstramelo.
2. Crea `lib/features/$ARGUMENTS/{data,providers,presentation/screens,presentation/widgets}`.
3. Mueve (no copies) los archivos. Extrae de `FirestoreService` un
   `<Feature>Repository` con SOLO los métodos de esta feature; `FirestoreService`
   delega en él temporalmente para no romper otros llamadores.
4. Mueve los providers a `lib/features/$ARGUMENTS/providers/` y deja en
   `app_providers.dart` un `export` para compatibilidad.
5. Mueve los tests a `test/features/$ARGUMENTS/`.
6. Parte archivos > 400 líneas en widgets propios.
7. `scripts/check.sh --fast` en verde. Sin cambios de comportamiento: este PR
   es SOLO refactor. Si encuentras un bug, anótalo en el CHANGELOG como
   "pendiente" y no lo arregles aquí.
