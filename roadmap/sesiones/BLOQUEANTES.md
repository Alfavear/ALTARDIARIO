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

### T-006-limpieza — carril-a

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T17:05:00Z

**Descripción:**
LISTO_PARA_MERGE del PR **#66** (rama `auto/T-006-limpieza`, SHA `09a5309`, base `origin/main` @ `50bf397`). Limpieza de la deuda que dejó el PR #58 en `main`: pantalla legacy huérfana de 503 líneas (0 importadores), copia intermedia de 307 líneas, providers duplicados en `app_providers.dart` (la declaración local tapaba el `export`), `FirestoreService` sin delegar y 0 tests de la feature. Con el PR: pantalla de 137 líneas + 3 widgets, solo `export`, delegación real con un único `pageSize`, y 11 tests nuevos.

**Impacto:**
Mientras no se integre, `main` lleva ~810 líneas de código muerto/duplicado en oración y la feature no tiene tests.

**Propuesta (opcional):**
Squash/merge directo: `check.sh --fast` verde (179 tests, analyze limpio, format limpio) y `fast-lint.mjs` verde. T-006 ya está `done` por #58; este PR es follow-up de limpieza y no toca `roadmap/tasks.yaml`. Si prefieres tarea nueva para el registro, créala tú al integrar (o dime y la doy de alta del MCP).

---

### indice-oracion-filtro — carril-a

**Tipo:** pregunta
**Urgencia:** alta
**Fecha:** 2026-10-23T17:05:00Z

**Descripción:**
`firestore.indexes.json` no tiene entrada para `peticiones_oracion`. La consulta del filtro de B18 (`where('respondida') + orderBy('fecha desc')`) necesita un índice compuesto; sin él, tocar "Pendientes" o "Respondidas" en la pantalla de oración falla en producción con `failed-precondition` (la lista sin filtro sí funciona, porque no aplica el `where`).

**Impacto:**
Función de la release actual rota en producción para los usuarios que usen el filtro.

**Propuesta (opcional):**
Añadir a `firestore.indexes.json` el compuesto `peticiones_oracion` (`respondida` ASC, `fecha` DESC) y desplegar índices (deploy = decisión humana). El cambio de reglas/índices es de carril B o lo tomo yo en la siguiente tarea si me la asignas; el deploy lo hace quien integre.

---

### reparto-T-040-T-041 — carril-a

**Tipo:** pregunta
**Urgencia:** media
**Fecha:** 2026-10-23T17:05:00Z

**Descripción:**
El broadcast dice que el Orquestador va a tomar T-041. Para evitar otra colisión como la de T-006 (#58 vs esta sesión), propongo reparto explícito: **T-041 para el Orquestador; T-040 (helper `noPrivateFields()`) para carril-a**, empezando cuando se libere un slot de PR (ahora tengo #56 y #66 abiertos, máximo alcanzado).

**Impacto:**
Sin confirmación, hay riesgo de trabajo duplicado en la pila de privacidad.

**Propuesta (opcional):**
Confirma en esta entrada "T-040 para carril-a" y yo la marco `in_progress` a mi nombre al empezar. Si prefieres lo contrario, borra esta propuesta y toma T-040 tú.

---
---

## Entradas resueltas

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
