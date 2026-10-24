# 📥 BANDEJA DE INTEGRACIÓN (Orquestador)

Actualizado: 2026-10-23T23:55:00Z
Trunk SHA: `origin/main` @ 50bf397 (post-merge #64)

---

## 🛤️ CARRIL B — UI / Vistas (Sesión: carril-b)

| Estado | Tarea | Prioridad | Esfuerzo | Descripción | Rama |
|--------|-------|-----------|----------|-------------|------|
| **🟢 in_progress** | **T-030 (B19)** | P3 | M | **Búsqueda y temas seguidos en la comunidad** — min chars, debounce, límites, filtrar bloqueados/oculto, sin PII en Analytics | `fix/lane-b-19-busqueda-temas` |
| **🟡 queued** | **T-031 (B20)** | P3 | M | **Debate bíblico de calidad** — etiquetas, respuestas anidadas 1 nivel, reportar/bloquear visibles, índices y paginación | — |
| **🟡 queued** | **T-032 (B21)** | P2 | M | Ajustes de lectura: traducción, tamaño, espaciado, alto contraste | — |
| **🟡 queued** | **T-007** | P1 | M | Paginación real del feed con startAfterDocument e infinite scroll | — |
| **🟡 queued** | **T-010** | P2 | M | Compartir versículo como imagen (WhatsApp/Instagram) | — |
| **🟡 queued** | **T-026** | P1 | M | Filtrar contenido oculto (hidden) en providers y pantallas | — |
| **🟡 queued** | **T-034** | P2 | M | Notificaciones con intención: preferencias por categoría, horario tranquilo | — |
| **🟡 queued** | **T-004** | P1 | M | UI de reportar contenido y bloquear usuario (App Store 1.2) | — |

---

## 🛤️ CARRIL A — Core / Seguridad (Sesión: carril-a / orquestadora)

| Estado | Tarea | Prioridad | Esfuerzo | Descripción | Rama |
|--------|-------|-----------|----------|-------------|------|
| **🟢 in_progress** | **T-041** | P1 | S | **Privacidad: documento privado con allowlist de campos, tipos y tamaños** — `usuarios/{uid}/private/account` solo admite email y fcmToken, email ≤ 320 chars, fcmToken ≤ 4096 chars, tests de reglas | — |
| **🟡 queued** | **T-040** | P1 | M | **Privacidad: helper noPrivateFields() en todo el contenido público** — ningún doc público lleva email/fcmToken, tests de reglas | — |
| **🟡 queued** | **T-042** | P1 | S | Privacidad: permitir borrar email/fcmToken del perfil público sin bloqueo | — |
| **🟡 queued** | **T-047** | P1 | S | Alinear los topes del cliente con los límites de las reglas | — |
| **🟡 queued** | **T-048** | P1 | M | Moderación: la Function ignora los reportes de comentarios y de perfiles | — |
| **🟡 queued** | **T-050** | P1 | S | Bloqueados: un usuario sin foto desaparece del diálogo y no se puede desbloquear | — |
| **🟡 queued** | **T-043** | P2 | S | Privacidad: el borrado del perfil borra también el documento privado | — |
| **🟡 queued** | **T-045** | P2 | S | CI: job de functions y corrección del glob de los tests de functions | — |
| **🟡 queued** | **T-049** | P2 | S | Reglas: reports acepta campos arbitrarios (falta keys().hasOnly) | — |

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
| T-009 | Requiere plan Blaze + decisión humana de desplegar Cloud Functions |

---

## 📋 REGLAS DE OPERACIÓN

1. **Carril B** trabaja en `fix/lane-b-XX-*` branches. Reporta `LISTO_PARA_MERGE` al terminar.
2. **Carril A** trabaja en `auto/T-XXX-*` branches. Reporta `LISTO_PARA_MERGE` al terminar.
3. **Orquestador** integra al recibir `LISTO_PARA_MERGE`:
   - `scripts/check.sh --fast` en verde → squash/merge a main → `git push origin main` → `git push . origin/main:main` → marca `done` en roadmap.
   - Mueve `queued` → `in_progress` y popula nuevo `queued` desde backlog.
4. **Nunca** esperar confirmación humana entre ciclos mientras `check.sh --fast` esté en verde.
5. Los bloqueantes y preguntas van en `roadmap/sesiones/BLOQUEANTES.md`. El Orgestrador los gestiona personalmente.
6. **Ninguna sesión se queda sin trabajo**: siempre hay al menos 7 tareas en cola por carril.
