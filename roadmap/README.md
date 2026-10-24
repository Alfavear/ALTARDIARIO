# roadmap/

| Archivo | Quién escribe | Qué es |
|---|---|---|
| `tasks.yaml` | MCP (`add_task`, `start_task`, `complete_task`…) o la Integradora | Backlog ejecutable con criterios de aceptación. Dice **qué** hay que hacer, no quién lo hace |
| `BITACORA.md` | MCP (`log_cycle`) | Qué hizo cada ciclo, resultado, problemas y decisiones |
| `STATE.md` | MCP (autogenerado) | Resumen legible: fase, progreso, tarea en curso |
| `audits/` | sesión auditora | Informes de auditoría; sus hallazgos se convierten en tareas |
| `archive/` | nadie | Ficheros de coordinación manual retirados (histórico) |

**Estado real de las tareas** (quién trabaja en qué, PR, checks): `node scripts/board.mjs`.
Cruza `tasks.yaml` con los PRs de GitHub y avisa de desfases. Marco de trabajo: `docs/FLUJO.md`.
