# 📋 GUIA DEL ORQUESTADOR — Protocolo de interacción

Esta guía le aplica a **todas las sesiones** que no sean la Orquestadora (Carril A, Carril B, etc.).

## 1. Quién es el Orquestador

El Orquestador es la **única sesión autorizada** a:
- Hacer commits sobre `main`
- Hacer `git push origin main`
- Resolver conflictos de integración
- Escribir en `roadmap/tasks.yaml` (marcar tareas como `in_progress`, `done`, `blocked`)
- Ejecutar `scripts/check.sh --fast` antes de integrar cualquier cambio

## 2. Flujo de trabajo para Carril A y Carril B

```
1. Marcar tarea como in_progress en roadmap/tasks.yaml
   (con tu session_id)
   ↓
2. Desarrollar en tu worktree aislado (rama propia)
   ↓
3. Ejecutar scripts/check.sh --fast localmente (si puedes)
   ↓
4. Reportar LISTO_PARA_MERGE al Orquestador
   ↓
5. El Orquestador integra: check.sh --fast → squash/merge a main → push
   ↓
6. El Orquestador marca la tarea como done en roadmap/tasks.yaml
   ↓
7. El Orquestador mueve la siguiente tarea de tu cola a in_progress
```

## 3. Cómo reportar un bloqueante o pregunta

Crea una entrada en `roadmap/sesiones/BLOQUEANTES.md` siguiendo el formato del archivo. El Orgestrador revisa ese archivo continuamente.

**No esperes respuesta sincrónica.** El Orgestrador responderá en el mismo archivo o integrará directamente.

## 4. Reglas duras (no negociables)

| Regla | Descripción |
|-------|-------------|
| ✅ Un solo merger | Solo el Orquestador escribe en `main`. |
| ✅ Un worktree por sesión | Nunca dos sesiones en el mismo directorio. |
| ✅ Máx 2 PRs abiertos por sesión | Antes de abrir PR, haz `git merge origin/main`. |
| ✅ Todo lo no empujado no existe | Push de tu rama aunque sea WIP. |
| ❌ Prohibido `push --force` | Nunca reescribas historia en ramas con PR abierto. |
| ❌ Prohibido `reset --hard` / `rebase` | En ramas con PR abierto. |
| ❌ No trabajes sin marcar `in_progress` | Si no está en `in_progress` a tu nombre, no toques esa tarea. |
| ❌ No esperes confirmación humana | El Orgestrador actúa automáticamente mientras `check.sh --fast` esté en verde. |

## 5. Comandos útiles

```bash
# Ver estado de coordinación
git fetch origin main
git status

# Ver roadmap
node tools/roadmap-mcp/cli.mjs state
node tools/roadmap-mcp/cli.mjs next
node tools/roadmap-mcp/cli.mjs list backlog

# Ver bloqueantes
cat roadmap/sesiones/BLOQUEANTES.md

# Ver BANDEJA (tareas activas y en cola)
cat roadmap/BANDEJA.md
```

## 6. ¿Qué hacer si estás bloqueado?

1. Escribe tu bloqueante en `roadmap/sesiones/BLOQUEANTES.md`.
2. Pasa a la **tarea en cola** de tu carril (si hay una).
3. Si no hay tarea en cola, avisa al Orgestrador para que cargue la siguiente del backlog.

## 7. Contacto

No busques al Orgestrador por chat para preguntas técnicas. Todo pasa por `BLOQUEANTES.md` para dejar rastro de decisiones.
