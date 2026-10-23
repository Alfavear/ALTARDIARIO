# Sesión carril A (core y seguridad)

- **rol**: ingeniero de arquitectura y core (carril A). Entrega por PR; nunca toca `main`.
- **worktree**: `C:\Users\ALVEAR\.local\share\opencode\worktree\60cd09\roadmap-t018`
- **rama activa**: `auto/T-048-moderation` (`4fb89b0`, empujada; T-048 completada)
- **rama anterior**: `auto/T-041-private-account` (`b315c71`, T-041 lista, pendiente decisión)
- **PRs abiertos**: #56 (cierre T-053), #66 (limpieza T-006) — cupo lleno (máx 2)
- **validado en**: `50bf397` (`origin/main`)
- **último latido**: `2026-10-23T20:50Z`
- **siguiente paso**: T-040 (helper `noPrivateFields`) cuando se libere cupo de PR.
- **bloqueos**: cupo de PR lleno (2/2). T-041 en `BLOQUEANTES.md` (ver entrada `T-041-listo-para-merge`).

## Normas de esta sesión

- No se ejecuta `git checkout main`, `git merge main`, `git reset --hard` ni `git push origin main`. Se parte de `origin/main` y se entrega por PR.
- Ámbito: `lib/core/`, contratos de `lib/data/`, `lib/features/**`, `firestore.rules`, `functions/` y migraciones de carpetas.
- Gate antes de cada commit: `scripts/check.sh --fast` + `node scripts/fast-lint.mjs`.

## En curso

- [x] T-048 completada: `functions/src/moderation.ts` con 5 targetType, 9 tests, índice `comentarios`.
- [x] T-041 lista en rama `auto/T-041-private-account` (51/51 reglas, 10 tests, `fast-lint` OK).
- [x] `LISTO_PARA_MERGE` reportado en `BLOQUEANTES.md` (entradas `T-041-listo-para-merge`, `PR65-reglas-rotas`, `reparto-cola-carril-a`).
- [ ] T-040: helper `noPrivateFields()` en `firestore.rules` + tests (cuando se libere cupo).

## Hallazgos reportados

- **PR #65 (carril B)**: `firestore.rules` no compila (`L70:7 Unexpected 'let'`), añade `continue-on-error: true` al job de reglas, base desfasada con commits de T-031. Ver entrada `PR65-reglas-rotas` en `BLOQUEANTES.md`.
- **Índice faltante**: `firestore.indexes.json` necesita índice compuesto para `peticiones_oracion` (`respondida` + `fecha desc`) — filtro de oración rota en producción.
- **Colisión de cola**: carril B ejecuta T-040/T-041/T-042/T-049 en paralelo (#65). Propuesto: T-048 para carril A, T-047 para carril B.

## Pendiente de otros

- #56: cierre de T-053, listo para merge.
- #66: limpieza T-006, listo para merge.
- #65: requiere corrección por carril B antes de merge.
- #29/#30/#47/#50 y pila Dependabot: sin cambios.