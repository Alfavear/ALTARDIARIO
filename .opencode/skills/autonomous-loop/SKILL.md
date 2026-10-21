---
name: autonomous-loop
description: "Protocolo del ciclo autónomo de AltarDiario: cómo el orquestador elige, ejecuta, verifica, revisa y registra UNA tarea por ciclo usando el MCP roadmap; criterios de parada y qué nunca automatizar. Leer antes de /cycle o /loop."
---

# Ciclo autónomo

## Qué es
Un bucle en el que la app **se construye y mejora sola** dentro de límites:
cada ciclo toma la siguiente tarea del roadmap, la implementa, se verifica con
las mismas puertas que la CI, se autorrevisa, se corrige, y deja constancia en
la bitácora. El humano revisa PRs y toma las decisiones que el sistema marca
como bloqueadas. Nunca se despliega ni se publica sin humano.

## Piezas
| Pieza | Rol |
|---|---|
| `roadmap/tasks.yaml` | backlog ejecutable (estado, prioridad, dependencias, criterios) |
| `roadmap/BITACORA.md` | memoria entre ciclos, append-only |
| `roadmap/STATE.md` | panel autogenerado |
| `roadmap/audits/` | informes del auditor |
| MCP `roadmap` | única vía de escritura al roadmap/bitácora |
| `orchestrator` | ejecuta el ciclo |
| `planner` → `implementer` → `tester` → `reviewer` → `fixer` | pipeline por tarea |
| `auditor` (+ `rules-auditor`) | genera trabajo nuevo cada 5 ciclos o si el backlog se vacía |
| `scripts/check.sh` | puerta de calidad (= CI) |
| `scripts/loop.sh N` | corre N ciclos seguidos sin intervención |

## Un ciclo, paso a paso
```
get_state → next_task → rama auto/<id> → start_task
  → planner (plan ≤ 6 archivos, si no split_task)
  → implementer → tester
  → check.sh  ──falla──▶ fixer (≤2) ──sigue──▶ block_task + wip commit
  → reviewer ──🔴──▶ fixer (1) → check.sh
  → commit + CHANGELOG → complete_task(evidence real, sha)
→ log_cycle (siempre, incluso si falló)
```

## Selección de tarea (`next_task`)
1. Si hay una `in_progress`, esa (continuar).
2. Si no: `ready`/`backlog` con dependencias `done`, esfuerzo ≠ L, ordenadas
   por prioridad (P0 > P3), luego `ready` antes que `backlog`, luego S < M.
3. Las L nunca se ejecutan: se dividen con `split_task`.

## Criterios de parada del bucle (`scripts/loop.sh`)
- Se alcanzó N ciclos.
- Dos ciclos seguidos `failed` en la misma tarea (la tarea queda `blocked`).
- `next_task` devuelve null tras una auditoría (backlog vacío de verdad).
- `check.sh` falla en `main`/rama base antes de empezar (entorno roto).
- Variable `LOOP_STOP=1` o archivo `roadmap/STOP` presente.

## Qué NUNCA hace el bucle
- `git push`, merge a `main`, deploy de Firebase, builds de tienda, release.
- Cambiar `firebase_options.dart`, secretos, workflows de CI.
- Bajar reglas de seguridad o borrar/skip tests.
- Decidir producto: nuevas features fuera del roadmap van como tarea
  `backlog` propuesta por el auditor con `source: audit`, y las prioriza un
  humano (o se quedan P3).

## Evidencia
`complete_task` rechaza evidencia < 20 caracteres. La evidencia válida es la
salida literal de `scripts/check.sh` (o de los tests que corrieron) más el
veredicto del reviewer. "Implementado correctamente" NO es evidencia.

## Bitácora: qué escribir
Honesto y útil para el siguiente ciclo (que no tiene memoria del chat):
qué se hizo, qué no, por qué, qué decisión se tomó y qué se dejó para después.
Problemas de entorno (Flutter no disponible, emulador no arranca) van en
`problems` para que el humano los vea.

## Cómo lo usa un humano
```bash
scripts/loop.sh 3          # 3 ciclos, deja ramas auto/T-xxx listas para PR
node tools/roadmap-mcp/cli.mjs state     # ver dónde va
git branch --list 'auto/*' # ramas producidas
# revisar, abrir PRs, mergear; las tareas blocked piden decisión tuya
```
Para orientarlo: edita prioridades en `tasks.yaml` (el MCP valida) o
añade tareas con criterios verificables. Si el sistema se equivoca
repetidamente en algo, la corrección va a `AGENTS.md` o a la skill
correspondiente, no al chat.
