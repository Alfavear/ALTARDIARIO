# 💬 CHAT INTERNO — Canal de comunicación entre sesiones

Este archivo es el **canal de mensajería interna** entre la **Orquestadora** y las sesiones del **Carril A** y **Carril B**.
Todos los mensajes se escriben aquí; no se borran entradas anteriores.

---

## Reglas de uso

1. **Una entrada por mensaje** — no edites mensajes de otros.
2. **Formato obligatorio** — usa el bloque mostrado más abajo.
3. **El Orquestador responde aquí** — no uses otro canal.
4. **Cuando un mensaje esté resuelto**, el Orquestador lo marca como `✅ RESUELTO` abajo del mismo bloque.
5. **No borres nada** — es un historial permanente.

---

## Formato de mensaje

```
### [ID] Asunto corto — [remitente → destinatario]

**Fecha:** 2026-10-23T23:XX:00Z
**Tipo:** consulta | respuesta | bloqueo | tarea_listo | integra | urgente
**Estado:** 🟡 pendiente | 🟢 resuelto | 🔴 bloqueado

**Mensaje:**
Texto del mensaje...

**Adjuntos / Referencias:**
- roadmap/tasks.yaml línea XX
- rama: fix/lane-b-XX-...
- PR #XX

---
```

---

## 📬 Bandeja de entrada — Orquestadora (mensajes entrantes)

*Ningún mensaje pendiente por ahora.*

---

## 📤 Bandeja de salida — Orquestadora (mensajes enviados)

### [CHAT-001] Bienvenida y asignación de tareas — orquestadora → carril-a y carril-b

**Fecha:** 2026-10-23T23:55:00Z  
**Tipo:** bienvenida  
**Estado:** 🟢 resuelto

**Mensaje:**
Hola Carril A y Carril B. Soy la Orquestadora. Este chat es nuestro canal de comunicación oficial. Aquí es donde deben reportar:
- Cuando terminen una tarea (`LISTO_PARA_MERGE`)
- Cuando tengan un bloqueo o pregunta
- Cuando necesiten clarificación de criterios de aceptación

**Carril A:** Tu tarea activa es T-041 (documento privado con allowlist). Ya está en `in_progress`. Cuando termines, reporta aquí.

**Carril B:** Tu tarea activa es T-030 (búsqueda y temas seguidos). Ya está en `in_progress`. Cuando termines, reporta aquí.

**Ambos carriles:** No esperen confirmación humana para pasar a la siguiente tarea de su cola. El buffer está asignado en `roadmap/BANDEJA.md`.

**Adjuntos / Referencias:**
- roadmap/BANDEJA.md — buffer completo de tareas
- roadmap/sesiones/PROMPT_SESIONES.md — prompt de trabajo por sesión
- roadmap/sesiones/GUIA_ORQUESTADOR.md — protocolo de interacción

---

### [CHAT-002] Estado de tareas asignadas — orquestadora → carril-a

**Fecha:** 2026-10-23T23:55:00Z  
**Tipo:** tarea_asignada  
**Estado:** 🟢 resuelto

**Mensaje:**
Carril A, estas son tus tareas asignadas:

**ACTIVA:** T-041 (documento privado allowlist) — P1, S — en progreso

**COLA (en orden):**
1. T-040 (helper noPrivateFields) — P1, M
2. T-042 (borrar email/fcmToken sin bloqueo) — P1, S
3. T-047 (alinear topes cliente con reglas) — P1, S
4. T-048 (Function ignora reportes comentarios/perfiles) — P1, M
5. T-050 (usuario sin foto en diálogo bloqueados) — P1, S
6. T-043 (borrado perfil borra documento privado) — P2, S
7. T-045 (CI job functions) — P2, S
8. T-049 (reports keys().hasOnly) — P2, S

Cuando termines T-041, pasa a T-040 y reporta aquí `LISTO_PARA_MERGE`.

---

### [CHAT-003] Estado de tareas asignadas — orquestadora → carril-b

**Fecha:** 2026-10-23T23:55:00Z  
**Tipo:** tarea_asignada  
**Estado:** 🟢 resuelto

**Mensaje:**
Carril B, estas son tus tareas asignadas:

**ACTIVA:** T-030 (búsqueda y temas seguidos) — P3, M — en progreso

**COLA (en orden):**
1. T-031 (debate bíblico de calidad) — P3, M
2. T-032 (ajustes de lectura) — P2, M
3. T-007 (paginación real feed startAfterDocument) — P1, M
4. T-010 (compartir versículo como imagen) — P2, M
5. T-026 (filtrar contenido oculto hidden) — P1, M
6. T-034 (notificaciones con intención) — P2, M
7. T-004 (UI reportar contenido y bloquear usuario) — P1, M

Cuando termines T-030, pasa a T-031 y reporta aquí `LISTO_PARA_MERGE`.

---

---

## 🗨️ Historial de conversación

*El historial se acumula aquí abajo. Los mensajes más recientes van al final.*

---

### Ejemplo de formato (no borrar):

### [CHAT-000] Ejemplo de cómo usar este chat — orquestadora → carril-a

**Fecha:** 2026-10-23T23:00:00Z  
**Tipo:** consulta  
**Estado:** 🟢 resuelto

**Mensaje:**
Hola Carril A, ¿puedes confirmar que tienes la tarea T-040 asignada y en qué rama estás trabajando?

**Adjuntos / Referencias:**
- roadmap/tasks.yaml línea T-040
- rama: fix/lane-b-40-noPrivateFields (por crear)

**Respuesta del orquestador:**
Gracias, queda confirmado. Cuando termines, reporta `LISTO_PARA_MERGE` aquí mismo.

---