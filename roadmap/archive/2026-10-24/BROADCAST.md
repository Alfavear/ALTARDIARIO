# 📢 COMUNICADO DE ORQUESTACIÓN: PROTOCOLO ACTIVO (TRUNK-BASED)

- **Orquestador Activo:** Sesión Orquestadora (Merge Authority).
- **Única rama de integración:** origin/main.
- **Última actualización:** 2026-10-23T23:30:00Z

## Reglas obligatorias para TODAS las sesiones
1. PROHIBIDO hacer push o merge a main directamente. Solo el Orquestador integra en main.
2. PROHIBIDO trabajar en tareas sin marcarlas primero como `in_progress` y con tu `session_id` en `roadmap/tasks.yaml`.
3. Si tu rama tiene commits basados en un commit de main con más de 2 ciclos de antigüedad, debes abortar y sincronizar con `origin/main` antes de continuar.
4. Los worktrees huérfanos o sin latido en las últimas 4 horas serán podados automáticamente.

## Protocolo de Sincronización de `main` Local
Al cerrar cada tarea `T-xxx`:
1. Asegura `scripts/check.sh --fast` en verde.
2. Integra el cambio y haz `git push origin main`.
3. Sincroniza de inmediato el puntero de la rama `main` local: `git push . origin/main:main`
4. Actualiza `roadmap/sesiones/orquestadora.md` con el nuevo SHA validado de `main`.

## Espacios de Coordinación

| Archivo | Propósito |
|---------|-----------|
| `roadmap/sesiones/BLOQUEANTES.md` | **Tus bloqueantes y preguntas van aquí.** El Orgestrador responde y resuelve. |
| `roadmap/sesiones/GUIA_ORQUESTADOR.md` | Protocolo completo de interacción con el Orgestrador. |
| `roadmap/sesiones/PROMPT_SESIONES.md` | Prompt listo para copiar y pegar en tu sesión. |
| `roadmap/sesiones/orquestadora.md` | Estado de la sesión Orgestrador (SHA validado, siguiente paso). |
| `roadmap/BANDEJA.md` | Tareas activas y en cola por carril (A y B). |

## Siguiente tarea elegible (según roadmap/tasks.yaml)
**T-041** · Privacidad: documento privado con allowlist de campos, tipos y tamaños (P1, S)
