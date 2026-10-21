# roadmap/

| Archivo | Quién escribe | Qué es |
|---|---|---|
| `tasks.yaml` | MCP (`add_task`, `start_task`, `complete_task`…) o humano | Backlog ejecutable con criterios de aceptación |
| `BITACORA.md` | MCP (`log_cycle`) | Qué hizo cada ciclo, resultado, problemas, decisiones |
| `STATE.md` | MCP (autogenerado) | Resumen legible: fase, progreso, tarea en curso, últimas entradas |
| `audits/YYYY-MM-DD-<tipo>.md` | agente `auditor` | Informes de auditoría; sus hallazgos se convierten en tareas |

Consultar estado: `node tools/roadmap-mcp/cli.mjs state` o `/roadmap` en OpenCode.
