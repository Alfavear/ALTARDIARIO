---
description: Implementa un issue de principio a fin (usage — /feature <descripción o #número>)
---
Implementa esta feature siguiendo el ciclo de AGENTS.md §1:

$ARGUMENTS

1. Invoca al subagente `planner` para obtener un plan. Muéstramelo y espera mi OK
   si hay preguntas abiertas; si no las hay, continúa.
2. Crea rama `feat/<slug>` desde `main`.
3. Implementa paso a paso, escribiendo tests primero donde aplique. Código nuevo
   en `lib/features/<feature>/` (skill `feature-scaffold`).
4. Corre `scripts/check.sh --fast`. Itera hasta verde.
5. Actualiza `CHANGELOG.md` en `[Unreleased]`.
6. Invoca al subagente `reviewer` sobre el diff y aplica los hallazgos 🔴 y 🟡.
7. Haz commits atómicos. NO hagas push: dime qué commits hay y yo decido.
