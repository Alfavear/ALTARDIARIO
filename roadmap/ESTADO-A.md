# Estado del carril A (orquestadora)

> Lo escribe **solo** la orquestadora. El carril B lo lee con:
> `git fetch origin ops/estado && git show origin/ops/estado:roadmap/ESTADO-A.md`

## Nuevo: directrices para todas las sesiones

Ya están en `main` (`docs/SESIONES.md`, PR #51). Resumen de lo que te afecta:

1. **Un worktree por sesión.** No trabajes en el mismo directorio que otra sesión.
2. **Máximo 2 PRs abiertos por sesión.** Antes de abrir uno: `git fetch origin && git merge origin/main`
   y comprueba `git diff --stat origin/main` (si salen ficheros que no tocaste, estás desfasado).
3. **Cita el SHA de `origin/main`** en todo informe: "validado en `<sha>`".
4. **Se trabaja desde `origin/main`**, nunca desde un `main` local (hoy estaba 99 commits atrás).
5. **Nunca `push --force`, `reset --hard`, ni rebase de una rama con PR abierto.**
6. **Lo no empujado no existe**: push de la rama aunque sea WIP y tu fichero en `roadmap/sesiones/`.

Orientación en 30 segundos: `scripts/session-check.sh`.
Alinear el `main` local: `scripts/sync-main.sh` (solo fast-forward).

## Tarea en curso

- **id**: — (entre tandas)
- **qué**: T-037 y después T-035
- **rama**: —
- **PR**: —

## Terminado esta noche (merges a `main`)

| PR | tarea | verificación |
|---|---|---|
| #31 | T-044 límites de tamaño en reglas | 35/35 reglas, desplegado |
| #32 | T-019 | CI 4/4 |
| #33 | T-022 | CI 4/4 |
| #34 | T-027 | CI 4/4 |
| #35 | T-028 | CI 4/4 |
| #36 | T-023 | CI 4/4 |
| #37 | T-033 | CI 4/4 |
| #38 | T-024 | CI 4/4 |
| #39 | T-038 | CI 4/4 |
| #40 | T-036 | CI 4/4 |
| #43 | T-005 | CI 4/4 |
| #45 | T-017 | CI 4/4 |
| #44 | arreglo del índice de Firestore (deploy en rojo) | deploy verde tras merge |
| #48 | CI: job APK con filtro y caché | 6 s en PRs de Dart/UI |
| #41 | cierre del ciclo 9 (7 tareas) | roadmap validado |
| #42 | reportar peticiones y debates (B12) | 157/157 + reglas |
| #49 | `reflexion_publicada` al publicar | 156/156 |
| #51 | directrices de sesiones + T-050..T-053 | 168/168 |

`main` en `dfb6ca9`.

## Tareas nuevas (auditoría de privacidad)

- **T-050** (P1) — un bloqueado sin foto desaparece del diálogo y no se puede desbloquear.
- **T-051** (P2) — estados de carga/error del diálogo y overflow con texto grande.
- **T-052** (P2) — filtros de bloqueo: badge sin filtrar, `actorId` nulo descartado, límites antes del filtro, código muerto.
- **T-053** (P2) — bloqueo real: quien te bloqueó no puede seguir escribiéndote (reglas + tests).
- **T-048** (P1, pendiente) — la Function de moderación ignora `comentario` y `usuario`.
- **T-049** (P2, pendiente) — `reports` sin `keys().hasOnly`.

## Decisiones pendientes del humano

| qué | estado |
|---|---|
| #46 grafo de conocimiento: `OPENAI_API_KEY`, `contents: write`, `push --force` en el workflow | esperando decisión |
| #29/#30 privacidad: publicar app → subir `minVersion` → migración a 0 | esperando despliegue |
| #47 paginación por cursor | rebase sobre `main`, tests y consumidores |
| #50 design system | revisar que no duplique `DESIGN.md` ni reescriba `AGENTS.md` |
