# 🛑 BLOQUEANTES Y PREGUNTAS — Canal del Orquestador (Gestión Centralizada)

Este archivo es el **único punto de contacto** entre el Orquestador y las sesiones del Carril A y Carril B.

## 📋 Cómo funciona

1. **Cualquier sesión** crea una entrada con su bloqueante/pregunta usando el formato de abajo.
2. **El Orquestador** es el responsable de responder, resolver o asignar el bloqueante a alguien específico.
3. **Las sesiones NO se paran**: mientras hay un bloqueante abierto, pasan a la siguiente tarea en su cola.
4. **El Orgestrador responde** en la misma entrada (debajo de la pregunta) o crea una entrada de resolución.

---

## 📝 Formato de entrada

```
### [ID-bloqueante] Título corto — [sesion-id]

**Tipo:** bloqueo | pregunta | revision | integra
**Urgencia:** baja | media | alta | critica
**Fecha:** 2026-10-23T23:00:00Z
**Tarea afectada:** T-xxx

**Descripción:**
Explica qué necesitas o qué te detiene.

**Impacto:**
Qué no puedes avanzar mientras esto no se resuelva.

**Propuesta (opcional):**
Cómo crees que debería resolverse.

---
```

---

## 🔴 BLOQUEANTES ACTIVOS (Sin resolver)

<!-- El Orgestrador lista aquí las entradas sin resolver -->
<!-- Formato: ### [ID] Título — [sesion] | Estado: abierto | Asignado a: Orquestador -->

Ningún bloqueante activo por ahora.

---

## ✅ BLOQUEANTES RESUELTOS

<!-- El Orgestrador mueve aquí las entradas cerradas con resolución -->
Ningún bloqueante resuelto por ahora.

---

## 🎯 REGLAS PARA LAS SESIONES

| Regla | Descripción |
|-------|-------------|
| 1 | **Un worktree por sesión** — nunca dos sesiones en el mismo directorio |
| 2 | **Máx 2 PRs abiertos por sesión** — antes de abrir PR, `git merge origin/main` |
| 3 | **Todo lo no empujado no existe** — push de tu rama aunque sea WIP |
| 4 | **Prohibido** `push --force`, `reset --hard`, `rebase` en ramas con PR abierto |
| 5 | **No esperes confirmación humana** entre ciclos mientras `check.sh --fast` esté en verde |
| 6 | **Si estás bloqueado**, escribe en este archivo y pasa a la siguiente tarea de tu cola |
| 7 | **El Orgestrador es el único merger** — solo él escribe en `main` y hace `git push origin main` |

---

## 📞 Responsable de bloqueantes

**Orquestador (Sesión Orquestadora)** es el responsable de:
- Responder preguntas técnicas y de arquitectura
- Resolver conflictos de integración
- Marcar tareas como `done` en `roadmap/tasks.yaml` tras merge
- Mover tareas de `cola` → `activa` cuando se completa una
- Hacer `git push origin main` tras verificar `check.sh --fast` en verde

Las sesiones **nunca** deben esperar al Orgestrador para empezar su siguiente tarea: siempre hay una tarea en cola lista para tomar.
