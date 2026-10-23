# Sesión lane-a

- **rol**: ingeniero de arquitectura y core (carril A). Hasta `2026-10-23T04:00Z`
  esta sesión fue la orquestadora; desde ahora implementa y solo entrega PRs.
- **worktree**: `C:\Users\ALVEAR\.local\share\opencode\worktree\60cd09\roadmap-t018`
- **rama**: `lane-a/T-006`
- **PR**: #56 (`chore/t-053-cierre`) abierto a la espera de merge ajeno; falta abrir el de T-006.
- **validado en**: `d2e1ec0` (`origin/main`, con #54 y #57 dentro)
- **último latido**: `2026-10-23T11:22Z`
- **tarea**: T-006 en `in_progress`, `assigned: lane-a`, ciclo 10.
- **siguiente paso**: abrir PR de T-006 con `[CARRIL A] T-006 LISTO PARA INTEGRACIÓN | SHA: <commit>`.
- **bloqueos**: #54 (oración de B18) y #47 tocan los mismos cuatro ficheros que T-006.

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
- [x] T-006 marcada `in_progress` + `assigned: lane-a`.
- [x] Andamiaje: `OracionRepository` + tests (rojo → verde).
- [x] Migración completa: repositorio con 5 métodos, providers en la feature,
      `FirestoreService` como fachada, pantalla de 137 líneas + 3 widgets,
      `app_providers` reexporta. 11 tests verdes.
- [x] Cierre de T-053 publicado en el PR #56 (a la espera de merge).
- [ ] Abrir PR de T-006 y esperar integración.

## Pendiente de otros (heredado de la etapa orquestadora)

- #54: merge obligatorio antes de mover oración.
- #47: paginación sin tests, sin consumidores y sobre base vieja.
- #50: design system; revisar que no duplique `DESIGN.md`.
- #29/#30: privacidad, tras publicar app → subir `minVersion` → migración a 0.
- #21/#22/#24/#25 y #6–#18: pilas antiguas (Codex y Dependabot).
