# Sesión lane-a

- **rol**: ingeniero de arquitectura y core (carril A). Hasta `2026-10-23T04:00Z`
  esta sesión fue la orquestadora; desde ahora implementa y solo entrega PRs.
- **worktree**: `C:\Users\ALVEAR\.local\share\opencode\worktree\60cd09\roadmap-t018`
- **rama**: `lane-a/T-006` (`2090a57`, empujada; **sin PR por conflicto**)
- **PR**: #56 (`chore/t-053-cierre`) abierto a la espera de merge ajeno.
- **validado en**: `d2e1ec0` (`origin/main`); `main` ya va por `62ff61f`
- **último latido**: `2026-10-23T11:30Z`
- **tarea**: T-006 figura `done` en `main` por el PR #58 (ajeno) — ver colisión.
- **siguiente paso**: esperar decisión humana: PR de limpieza sobre `main` o descartar la rama.
- **bloqueos**: decisión humana sobre la colisión de T-006.

## Normas de esta sesión

- No se ejecuta `git checkout main`, `git merge main`, `git reset --hard` ni
  `git push origin main`. Se parte de `origin/main` y se entrega por PR.
- Ámbito: `lib/core/`, contratos de `lib/data/`, `lib/features/**`,
  `firestore.rules`, `functions/` y migraciones de carpetas.
- Prohibido tocar pantallas o widgets que el carril B tenga en `BANDEJA.md`.
- Gate antes de cada commit: `scripts/check.sh --fast` (168 tests + 16 del grafo).
  `scripts/fast-lint.mjs` no existe en el repo; no se inventa.

## En curso

- [x] T-006 planificado en `docs/planes/T-006-migracion-oracion.md`.
- [x] T-006 marcada `in_progress` + `assigned: lane-a` (luego `main` la puso `done`).
- [x] Andamiaje: `OracionRepository` + tests (rojo → verde).
- [x] Migración completa en la rama: repositorio con 5 métodos, providers en la
      feature, `FirestoreService` como fachada, pantalla de 137 líneas + 3 widgets,
      `app_providers` reexporta, 11 tests verdes (`check.sh --fast`: 179).
- [x] Cierre de T-053 publicado en el PR #56 (a la espera de merge).
- [ ] PR de T-006: **no abierto** (ver colisión).

## Colisión T-006 (2026-10-23)

Mientras esta sesión implementaba, el humano mergeó el PR **#58**
(`auto/T-006-migracion-oracion`, `62ff61f`) a las `11:18:35Z` y marcó T-006
`done`. Comparación objetiva con lo que dejó en `main`:

| Punto | #58 en `main` | Rama `lane-a/T-006` |
|---|---|---|
| Pantalla | 307 líneas | 137 líneas + 3 widgets |
| Pantalla vieja `lib/presentation/screens/oracion_screen.dart` | **sigue (huérfana, 503 líneas)** | borrada |
| Providers en `app_providers` | **duplicados**: declaración local + `export` (la local tapa el export) | solo `export` |
| `FirestoreService` | sigue siendo la implementación | fachada que delega en el repositorio |
| Tests de la feature | **ninguno** | 11 (8 repositorio + 3 pantalla) |
| `prayerPageSize` | sigue suelto | derivado de `OracionRepository.pageSize` |

`flutter analyze` no detecta la pantalla huérfana ni los duplicados (son
públicos), así que el CI de #58 no podía cazarlo.

Recomendación: PR de limpieza sobre `main` en rama nueva (sin force-push),
con los 5 puntos de la columna derecha. Requiere tarea nueva o reabrir T-006;
eso lo decide el orquestador, no esta sesión.

## Pendiente de otros (heredado de la etapa orquestadora)

- #54: merge obligatorio antes de mover oración.
- #47: paginación sin tests, sin consumidores y sobre base vieja.
- #50: design system; revisar que no duplique `DESIGN.md`.
- #29/#30: privacidad, tras publicar app → subir `minVersion` → migración a 0.
- #21/#22/#24/#25 y #6–#18: pilas antiguas (Codex y Dependabot).
