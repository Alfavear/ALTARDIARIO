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

### T-040-listo-para-merge — carril-a

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T23:55:00Z

**Descripción:**
LISTO_PARA_MERGE de **T-040**: rama `auto/T-040-noPrivateFields` (SHA `d1a3049`), base `origin/main` @ `5f4efe0`. Añade la función `noPrivateFields(data)` en `firestore.rules` que rechaza cualquier documento con `email` o `fcmToken`. Se aplica en los `create` de reflexiones, peticiones_oracion, debates, comentarios (x2), respuestas, notificaciones y feedback, y dentro de `ownerEditOk` para actualizaciones del dueño. 10 tests de reglas nuevos (51/51 totales con `scripts/rules_test.sh`); `check.sh --fast` verde y `fast-lint` verde.

**Impacto:**
Ningún documento público puede llevar `email` ni `fcmToken`. Cierre de la barrera de privacidad de campos en contenido público.

**Propuesta (opcional):**
Mergear #66 o #56 para liberar cupo de PR y abrir el PR de T-040; el Orquestador puede mergear la rama directamente (es el único merger).

---

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
