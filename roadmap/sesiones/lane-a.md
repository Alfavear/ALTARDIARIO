# Sesión lane-a (carril A: core y seguridad)

- **rol**: ingeniero de arquitectura y core (carril A). Entrega por PR; nunca toca `main`.
- **worktree**: `C:\Users\ALVEAR\.local\share\opencode\worktree\60cd09\roadmap-t018`
- **rama activa**: `auto/T-006-limpieza` (limpieza del PR #58, según BANDEJA: carril A usa `auto/T-XXX-*`)
- **rama de respaldo**: `lane-a/T-006` (`5d3adca`) — implementación completa de T-006 antes del #58
- **PR**: #56 (`chore/t-053-cierre`) abierto a la espera de merge ajeno + PR de limpieza (este)
- **validado en**: `50bf397` (`origin/main`)
- **último latido**: `2026-10-23T16:56Z`
- **siguiente paso**: tras merge de la limpieza → **T-040** (helper `noPrivateFields`). T-041 la tiene el Orquestador (no duplicar).
- **bloqueos**: ninguno propio. Ver `BLOQUEANTES.md` (índice compuesto de oración pendiente).

## Normas de esta sesión

- No se ejecuta `git checkout main`, `git merge main`, `git reset --hard` ni
  `git push origin main`. Se parte de `origin/main` y se entrega por PR.
- Ámbito: `lib/core/`, contratos de `lib/data/`, `lib/features/**`,
  `firestore.rules`, `functions/` y migraciones de carpetas.
- Gate antes de cada commit: `scripts/check.sh --fast` + `node scripts/fast-lint.mjs`.

## En curso

- [x] T-006 planificado en `docs/planes/T-006-migracion-oracion.md`.
- [x] Migración completa implementada en `lane-a/T-006` (colisión con #58, ver abajo).
- [x] Limpieza del #58 en `auto/T-006-limpieza`: pantalla huérfana borrada,
      providers duplicados eliminados, `FirestoreService` delega, 11 tests.
- [x] `LISTO_PARA_MERGE` reportado en `roadmap/sesiones/BLOQUEANTES.md`.
- [ ] Esperar merge; después T-040.

## Colisión T-006 (2026-10-23, resuelta por limpieza)

El PR **#58** (`auto/T-006-migracion-oracion`, mergeado a las 11:18Z) migró
oración en paralelo a esta sesión y marcó T-006 `done`, dejando en `main`:
pantalla legacy huérfana (503 líneas sin importadores), providers duplicados en
`app_providers.dart` (la declaración local tapaba el `export`), sin tests y con
`FirestoreService` como implementación real. El PR de limpieza `auto/T-006-limpieza`
corrige los cuatro puntos con la implementación ya validada de esta sesión
(137 líneas + 3 widgets, 11 tests, delegación real, un solo `pageSize`).

## Hallazgos reportados al Orquestador (BLOQUEANTES.md)

1. Falta el índice compuesto de `peticiones_oracion` (`respondida` + `fecha`):
   el filtro de oración falla en producción (`failed-precondition`).
2. `RefreshIndicator` de oración refresca `peticionesStreamProvider` mientras
   la vista escucha `peticionesFiltradasProvider`.
3. `apoyarPeticion` no es idempotente; estado de error en crudo (`Error: $err`).

## Pendiente de otros

- #56: cierre de T-053, listo para merge.
- T-041: la toma el Orquestador; esta sesión no la duplica.
- #29/#30/#47/#50 y pila Dependabot: sin cambios.

