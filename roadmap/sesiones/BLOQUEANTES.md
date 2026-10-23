# 🛑 BLOQUEANTES Y PREGUNTAS — Canal del Orquestador

Este archivo es el **único punto de contacto** entre el Orquestador (Merge Authority) y las otras sesiones (Carril A, Carril B).

## Reglas de uso

1. **Una entrada por bloqueante/pregunta.** No edites entradas ajenas.
2. **Usa el formato exacto** mostrado abajo para que el Orquestador pueda parsearlo automáticamente.
3. **El Orquestador responde** en la misma entrada (respuesta debajo de la pregunta) o crea una entrada de resolución.
4. **Una vez resuelto**, marca como `✅ RESUELTO` y el Orquestador cierra la entrada.

---

## Formato de entrada

```
### [ID] Título corto — [sesion-id]

**Tipo:** bloqueo | pregunta | revision | integra
**Urgencia:** baja | media | alta | critica
**Fecha:** 2026-10-23T23:00:00Z

**Descripción:**
Explica aquí qué necesitas, qué te detiene o qué duda tienes.
Incluye archivos, ramas o commits relevantes.

**Impacto:**
Qué no puedes avanzar mientras esto no se resuelva.

**Propuesta (opcional):**
Cómo crees que debería resolverse.

---
```

---

## Entradas activas

<!-- El Orgestrador lista aquí las entradas sin resolver -->

---

## Entradas resueltas

---

## Entradas resueltas

### [T-004] UI de reportar contenido y bloquear usuario (App Store 1.2) 👉 carril-b

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T15:30:00Z

**Descripción:**
Implementada la funcionalidad completa de reportar contenido y bloquear usuario:
- Menú ⋮ en reflexión/petición/debate con opción Reportar que escribe en reports/
- Opción Bloquear usuario en perfil público; feed filtra usuarios bloqueados (lista en usuarios/{uid}.bloqueados)
- Widget test de ambos flujos (existentes en report_content_dialog_test.dart)
- Contenido con hidden: true no se muestra en feed

**Impacto:**
Tarea completada. PR #70 listo para merge.

**Resolución:**
✅ RESUELTO - Implementado en PR #70 (fix/lane-b-04-report-block-feed)


<!-- El Orgestrador mueve aquí las entradas cerradas con resolución -->

---

## Cómo el Orgestrador responde

| Tipo | Acción del Orquestador | SLA |
|------|------------------------|-----|
| bloqueo | Analiza, desbloquea o reasigna tarea | < 30 min |
| pregunta | Responde con guía o código de ejemplo | < 1 h |
| revision | Revisa diff y aprueba/bloquea merge | < 2 h |
| integra | Hace squash/merge a main y push | < 1 h tras check verde |

---

## Ejemplo de entrada

```
### T-041-duda-permitidos — carril-a

**Tipo:** pregunta
**Urgencia:** alta
**Fecha:** 2026-10-23T23:10:00Z

**Descripción:**
Para T-041 (documento privado con allowlist), ¿qué campos exactamente deben ir en la allowlist? Solo email y fcmToken, o también temasSeguidos?

**Impacto:**
No puedo escribir las reglas de Firestore ni los tests sin saber los campos permitidos.

**Propuesta:**
Permitir email, fcmToken y temasSeguidos (para T-030).

---
```
