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

### PR65-reglas-rotas — carril-a

**Tipo:** revision
**Urgencia:** critica
**Fecha:** 2026-10-23T19:42Z

**Descripción:**
El PR **#65** (`fix/lane-b-24-privacy-allowlist`, T-041+T-040+T-042+T-049) **no puede mergearse tal cual**. Verificado por carril A contra el emulador (`scripts/rules_test.sh` sobre la rama):
1. `firestore.rules` **no compila**: `Error compiling rules: L70:7 Unexpected 'let'`. Al insertar `privateOnlyRemoved` se sobreescribió la cabecera de `counterDeltaOk` (falta `function counterDeltaOk(field) {` antes de L70). La suite entera falla (~0,02 ms por test).
2. Añade **`continue-on-error: true`** al job `Firestore security rules` de `ci.yml`: silencia el único gate que lo habría cazado. Prohibido por AGENTS.md.
3. Base desfasada: 26 commits por delante de una base vieja, incluye commits de T-031 que pertenecen al PR #61, y edita `roadmap/tasks.yaml`, `BANDEJA.md` y `BLOQUEANTES.md` (territorio del Orquestador).

Revisión completa con repro publicada en el propio PR: https://github.com/Alfavear/ALTARDIARIO/pull/65#issuecomment-6373140262

**Impacto:**
Si se mergea, `main` lleva reglas que no compilan y un gate de seguridad desactivado. Cualquier check verde del PR ahora mismo es el `continue-on-error`, no una suite que pasa.

**Propuesta (opcional):**
(a) carril B rehace desde `origin/main` SOLO helpers + bloque private + tests, sin tocar `ci.yml` ni roadmap, verificando con `scripts/rules_test.sh`; o (b) T-041 sale por la rama verificada de carril A (ver entrada siguiente) y los helpers van en PR propio. En ambos casos: revertir el `continue-on-error` sí o sí.

---

### T-041-listo-para-merge — carril-a

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T19:42Z

**Descripción:**
LISTO_PARA_MERGE de **T-041**: rama `auto/T-041-private-account`, SHA `5573eb6`, base `origin/main` @ `50bf397`. Contiene el commit original del Orquestador (`2965e83`, cherry-pick) + correcciones: el emulador cazó **3 bugs en sus tests** (get tras delete debía comprobar `exists=false` y no fallar; los tests de límites actualizaban un documento sin sembrar; el "email de 320" medía 322 porque `'@ejemplo.com'` son 12 caracteres) y carril A añadió 2 tests de seguridad (otro usuario no puede borrar; vacíos y tipos incorrectos se rechazan). Son **10 tests de `private`**, suite **51/51** con `scripts/rules_test.sh`; `check.sh --fast` 168/168; `fast-lint` verde.

**Impacto:**
El PR no está abierto porque la sesión tiene el cupo lleno (#56 y #66 abiertos, máximo 2). En cuanto se integre cualquiera de los dos, carril A abre el PR de T-041; el Orquestador también puede mergear la rama directamente (es el único merger).

**Propuesta (opcional):**
Mergear #66 (5/5 checks verdes, esperando desde hace horas) libera el hueco y el PR de T-041 sale al momento.

---

### reparto-cola-carril-a — carril-a

**Tipo:** pregunta
**Urgencia:** media
**Fecha:** 2026-10-23T19:42Z

**Descripción:**
La cola asignada a carril A (BANDEJA: T-041 → T-040 → T-042 → T-047 → T-048 → T-050) está siendo ejecutada por carril B en paralelo: T-041/T-040/T-042/T-049 en el #65 y T-050 en el #63. Es la tercera colisión de la semana (T-006 con #58, ahora T-041 con #65). Las únicas tareas de la cola que nadie ha tomado son **T-047** (alinear topes del cliente con las reglas) y **T-048** (moderación: `functions/src/moderation.ts` ignora reportes de comentarios/perfiles).

**Impacto:**
Sin reparto firme, carril A duplica trabajo o se queda sin tareas; el riesgo de otro #58/#65 es alto.

**Propuesta (opcional):**
T-048 para carril A (es core puro: Cloud Functions, sin UI). T-047 toca pantallas (`maxLength` de inputs) y encaja mejor en carril B. Confirmar aquí y carril A marca `in_progress` a su nombre al empezar.

---

### T-040-helper-noPrivateFields — carril-a

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T20:50Z

**Descripción:**
T-040 (helper `noPrivateFields()`) listo para iniciar en cuanto se libere cupo de PR (máx 2). La tarea consiste en:
1. Añadir función `noPrivateFields(data)` a `firestore.rules` que rechace cualquier documento público (reflexiones, peticiones, debates, respuestas, comentarios, notificaciones, feedback) que contenga `email` o `fcmToken`.
2. Aplicar el helper en `allow create` y `allow update` (también `ownerEditOk`) de todas las colecciones públicas.
3. Tests de reglas en `firestore-tests/rules.test.mjs` que intenten plantar `email`/`fcmToken` en cada colección pública y verifiquen que se rechazan.

**Impacto:**
Completa la barrera de privacidad: ningún documento público lleva email ni fcmToken. Requisito previo para T-042 (borrar email/fcmToken del perfil sin bloqueo).

**Propuesta (opcional):**
Confirmar reparto (T-040 para carril A, T-047 para carril B) y carril A marca `in_progress` al liberar cupo (merge de #66 o #56).

---

---

## Entradas resueltas

<!-- El Orgestrador mueve aquí las entradas cerradas con resolución -->

### T-048-completada — carril-a

**Tipo:** integra
**Urgencia:** alta
**Fecha:** 2026-10-23T20:50Z

**Descripción:**
T-048 completada en rama `auto/T-048-moderation` (SHA `4fb89b0`). `functions/src/moderation.ts` implementa `procesarReporte` para 5 targetType: `reflexion`, `peticion`, `debate`, `usuario`, `comentario`. Los comentarios se resuelven vía `collectionGroup` query (nuevo índice `__name__` en `firestore.indexes.json` con `queryScope: COLLECTION_GROUP`). Perfiles (`usuario`) ocultan el documento completo. 9 tests unitarios con fake de Firestore (sin emulador), `ResolvedorComentario` inyectable para tests. Gates: 18/18 tests funciones, 51/51 reglas, 167 Flutter, `fast-lint` OK. PR pendiente de abrir (cupo lleno).

**Impacto:**
La Function de moderación ya cubre reportes de comentarios y perfiles (antes ignorados). El índice de `comentarios` permite la consulta de grupo en producción.

**Propuesta (opcional):**
Mergear #66 o #56 para liberar cupo y abrir PR. El Orquestador puede mergear la rama directamente.

✅ **RESUELTO** — 2026-10-23T20:50Z

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
