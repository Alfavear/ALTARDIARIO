---
description: Auditoría completa del repo; guarda informe en roadmap/audits y crea tareas en el roadmap
---
Invoca al subagente `auditor` para auditar el repositorio en sus 6
dimensiones ($ARGUMENTS si se indica alguna en particular). Debe guardar el
informe con `roadmap.save_audit` y crear tareas con `roadmap.add_task`.
Luego llama a `roadmap.log_cycle` con `result: audit`. Muéstrame el resumen.
