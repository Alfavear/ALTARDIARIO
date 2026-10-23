# 📢 COMUNICADO DE ORQUESTACIÓN: PROTOCOLO ACTIVO (TRUNK-BASED)

- **Orquestador Activo:** Sesión Orquestadora (Merge Authority).
- **Única rama de integración:** origin/main.
- **Reglas obligatorias para TODAS las sesiones:**
  1. PROHIBIDO hacer push o merge a main directamente. Solo el Orquestador integra en main.
  2. PROHIBIDO trabajar en tareas sin marcarlas primero como `in_progress` y con tu `session_id` en `roadmap/tasks.yaml`.
  3. Si tu rama tiene commits basados en un commit de main con más de 2 ciclos de antigüedad, debes abortar y sincronizar con `origin/main` antes de continuar.
  4. Los worktrees huérfanos o sin latido en las últimas 4 horas serán podados automáticamente.

## Protocolo de Sincronización de `main` Local
Al cerrar cada tarea `T-xxx`:
1. Asegura `scripts/check.sh --fast` en verde.
2. Integra el cambio y haz `git push origin main`.
3. Sincroniza de inmediato el puntero de la rama `main` local sin cambiar de directorio:
   `git push . HEAD:main`
4. Actualiza `roadmap/sesiones/orquestadora.md` con el nuevo SHA validado de `main`.