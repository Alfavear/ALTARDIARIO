# 📥 BANDEJA DE INTEGRACIÓN (Orquestador)

Actualizado: 2026-10-23T23:35:00Z
Trunk SHA: `origin/main` @ 969bb1fa (post-merge #59)

---

## 🛤️ CARRIL B — UI / Vistas (Sesión: carril-b)

| Estado | Tarea | Prioridad | Esfuerzo | Descripción | Rama |
|--------|-------|-----------|----------|-------------|------|
| **🟢 in_progress** | **T-030 (B19)** | P3 | M | **Búsqueda y temas seguidos en la comunidad** — min chars, debounce, límites, filtrar bloqueados/oculto, sin PII en Analytics | `fix/lane-b-19-busqueda-temas` |
| **🟡 queued** | **T-031 (B20)** | P3 | M | **Debate bíblico de calidad** — etiquetas, respuestas anidadas 1 nivel, reportar/bloquear visibles, índices y paginación | — |
| **📋 backlog next** | T-032 (B21) | P2 | M | Ajustes de lectura: traducción, tamaño, espaciado, alto contraste | — |
| **📋 backlog next** | T-034 (B22) | P2 | M | Notificaciones con intención: preferencias por categoría, horario tranquilo | — |
| **📋 backlog next** | T-007 | P1 | M | Paginación real del feed con startAfterDocument e infinite scroll | — |
| **📋 backlog next** | T-010 | P2 | M | Compartir versículo como imagen (WhatsApp/Instagram) | — |
| **📋 backlog next** | T-011 | P2 | L | Planes de lectura flexibles (empezar cualquier día, ponerse al día, 7/21 días) | — |

---

## 🛤️ CARRIL A — Core / Seguridad (Sesión: carril-a / orquestadora)

| Estado | Tarea | Prioridad | Esfuerzo | Descripción | Rama |
|--------|-------|-----------|----------|-------------|------|
| **🟢 in_progress** | **T-041** | P1 | S | **Privacidad: documento privado con allowlist de campos, tipos y tamaños** — `usuarios/{uid}/private/account` solo admite email y fcmToken, email ≤ 320 chars, fcmToken ≤ 4096 chars, tests de reglas que intenten escribir role/verified/basura | — |
| **🟡 queued** | **T-040** | P1 | M | **Privacidad: helper noPrivateFields() en todo el contenido público** — ningún doc público lleva email/fcmToken, tests de reglas | — |
| **📋 backlog next** | T-042 | P1 | S | Privacidad: permitir borrar email/fcmToken del perfil público sin bloqueo | — |
| **📋 backlog next** | T-004 | P1 | M | UI de reportar contenido y bloquear usuario (App Store 1.2) | — |
| **📋 backlog next** | T-026 | P1 | M | Filtrar contenido oculto (hidden) en providers y pantallas | — |

---

## ✅ COMPLETADAS (este ciclo)

| Tarea | Resultado | Rama/commit |
|-------|-----------|---------------|
| T-006 | Migración feature oración a lib/features/oracion/ | PR #58 @ 62ff61f |
| T-029 | Oración con seguimiento (estado respondida y filtros) | PR #57 @ d2e1ec0 |
| T-024 | Reportar reflexiones y comentarios | PR #54 @ 6806dc1 |

---

## 🚫 BLOQUEADAS (No asignar hasta decisión externa)

| Tarea | Motivo |
|-------|--------|
| T-009 | Requiere plan Blaze + decisión humana de deploy Cloud Functions |

---

## 📋 REGLAS DE OPERACIÓN

1. **Carril B** trabaja en `fix/lane-b-XX-*` branches. Reporta `LISTO_PARA_MERGE` al terminar.
2. **Carril A** trabaja en `auto/T-XXX-*` branches. Reporta `LISTO_PARA_MERGE` al terminar.
3. **Orquestador** integra al recibir `LISTO_PARA_MERGE`:
   - `scripts/check.sh --fast` en verde → squash/merge a main → `git push origin main` → `git push . origin/main:main` → marca `done` en roadmap.
   - Mueve `queued` → `in_progress` y popula nuevo `queued` desde backlog.
4. **Nunca** esperar confirmación humana entre ciclos mientras `check.sh --fast` esté en verde.
5. Los bloqueantes y preguntas van en `roadmap/sesiones/BLOQUEANTES.md`.
