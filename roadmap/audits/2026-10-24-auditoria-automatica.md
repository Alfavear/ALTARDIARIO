# Auditoría automática 2026-10-24

> Generada por la sesión auditora del ciclo autónomo (modelos `nvidia/nvidia/nemotron-3-ultra-550b-a55b, opencode/nemotron-3-ultra-free`, revisor `opencode/glm-5.3-flash-free, nvidia/nvidia/nemotron-3.5-super-vl-120b-a12b, nvidia/z-ai/glm-5.3`, origin/main @ 3f604ed). tareas totales: 68; libres para el carril plataforma: 0.

## Tareas nuevas
| ID | Prioridad/Esfuerzo | Título |
|---|---|---|
| T-069 | P2/M | Paginación por cursor en peticiones de oración (startAfterDocument) |
| T-070 | P3/M | Filtro 'Por las que oro' en OracionScreen (peticiones donde usuario actual hizo Amén) |

## Propuestas descartadas
- «Cloud Function: notificación opcional a apoyadores cuando petición se »: ruta inexistente: firestore.rules (apoyos create/read)
- «Widget tests para OracionScreen y _PeticionCard (pendiente, respondida»: mezcla carriles o no pertenece a ninguno (divídela en una tarea por carril)
- «Reglas: allowlist explícita para campos respondida/fechaRespondida en »: revisor: Duplica T-066 de roadmap/tasks.yaml (estado backlog): 'Reglas: allowlist explícita para campos respondida/fechaRespondida en peticiones_oracion' con los mismos criterios de aceptación (ownerEditOk con changedKeys().hasOnly(['respondida','fechaRespondida']) y los 2 tests de reglas) y los mismos archivos (firestore.rules, firestore-tests/rules.test.mjs).
- «Índice compuesto Firestore para peticiones_oracion (oculto + respondid»: revisor: Duplica T-065 de roadmap/tasks.yaml (estado backlog): 'Oración: índice compuesto de Firestore para peticiones_oracion' con los mismos criterios (índice collectionGroup='peticiones_oracion' con oculto ASC, fecha DESC, respondida ASC; deploy de índices en CI; test de reglas sin FAILED_PRECONDITION) y los mismos archivos (firestore.indexes.json, firestore-tests/rules.test.mjs).
- «Campo actualizacionAutor en PeticionOracion + UI para autor al marcar »: revisor: No es de un solo carril: toca firestore.rules y firestore-tests/rules.test.mjs (carril a, Plataforma/Seguridad) y lib/presentation/screens/oracion_screen.dart (carril b, Producto), además de lib/data (compartido). Requeriría coordinar dos carriles; dividir en tareas por carril.
- «Tests de reglas para subcolección apoyos y query paginada con respondi»: revisor: Duplica T-068 de roadmap/tasks.yaml (estado backlog): 'Tests de reglas para peticiones_oracion: paginación, actualizaciónAutor, apoyos subcolección' con los mismos 5 tests (query respondida=true+fecha desc+limit+startAfter, autor escribe actualizacionAutor, no-autor no puede escribirla, crear documento en apoyos/{uid} solo con uid propio, trigger de Function oracion_notifications si existe) y los mismos archivos (firestore-tests/rules.test.mjs, functions/src/oracion_notifications.test.ts).


---

# Auditoría Fase 2 — Hábito devocional diario
**Repositorio:** AltarDiario (origin/main @ 3f604ed)
**Fecha:** 2026-10-24

---

## Resumen ejecutivo

Se auditan tres tareas marcadas como `done` en `roadmap/tasks.yaml` correspondientes a la Fase 2 del `PRODUCT_EVOLUTION_ROADMAP.md`:

| Tarea | Título | Estado en tasks.yaml | Resultado real |
|-------|--------|---------------------|----------------|
| T-027 | Inicio "Hoy": lectura pendiente, día completado y sin conexión | ✅ done | **CUMPLE** criterios |
| T-028 | Reflexión guiada y privada por defecto | ✅ done | **CUMPLE** criterios (con observación menor) |
| T-029 | Oración con seguimiento: estado respondida, actualización y filtros del feed | ✅ done | **NO CUMPLE** 3 de 3 criterios |

---

## T-027 — Inicio "Hoy" (lib/presentation/screens/home_screen.dart + widgets)

### Criterios de aceptación del roadmap (§2.1)

| # | Criterio | Código | Test | Veredicto |
|---|----------|--------|------|-----------|
| 1 | En <2 toques se abre la lectura pendiente | `LecturaHoyCard.onAbrir` → `BibleReaderScreen` (1 toque) | `pendiente: muestra el pasaje y se abre con un toque` | ✅ |
| 2 | Día completo → celebración discreta + siguiente lectura | `LecturaCelebracion` + `LecturaSiguiente` en `lectura_hoy_estados.dart` | `completado: celebración discreta y siguiente lectura` | ✅ |
| 3 | Skeleton carga, estado offline, escalado texto accesible | `LecturaSkeleton`, `LecturaAvisoSinConexion`, test `escalaTexto: 2.0` | `cargando`, `sin conexión`, `escala de texto grande` | ✅ |
| 4 | Widget tests pendiente, completado, sin conexión | `test/widgets/lectura_hoy_card_test.dart` (5 tests) | 5 tests pasan | ✅ |

**Evidencia:**
- `lib/presentation/widgets/lectura_hoy_card.dart:56-126` — `InkWell(onTap: onAbrir)` abre en 1 toque
- `lib/presentation/widgets/lectura_hoy_estados.dart:84-168` — `LecturaCelebracion` + `LecturaSiguiente`
- `lib/presentation/widgets/lectura_hoy_estados.dart:12-48` — `LecturaSkeleton`
- `lib/presentation/widgets/lectura_hoy_estados.dart:51-78` — `LecturaAvisoSinConexion`
- `test/widgets/lectura_hoy_card_test.dart:48-123` — 5 widget tests cubriendo los 4 estados

**Conclusión:** T-027 **cumple** todos los criterios. No se requieren tareas nuevas.

---

## T-028 — Reflexión guiada y privada por defecto (lib/presentation/screens/publicar_reflexion_screen.dart)

### Criterios de aceptación del roadmap (§2.2)

| # | Criterio | Código | Test | Veredicto |
|---|----------|--------|------|-----------|
| 1 | Borrador local recuperable tras cerrar app | `BorradorReflexionStore` (SharedPreferences) + `_restaurarBorrador()` | `un borrador guardado muestra "Borrador recuperado" y precarga el texto` | ✅ |
| 2 | Publicar exige confirmación explícita + vista previa | `_confirmarPublicacion()` → `VistaPreviaReflexion` bottom sheet | `"Guardar" abre VistaPreviaReflexion...`, `"Publicar" navega atrás...` | ✅ |
| 3 | Usuario convierte nota en publicación sin copiar | Parámetro `textoInicial` en constructor | `textoInicial precarga el cuerpo sin anunciar borrador recuperado` | ✅ |
| 4 | No se eleva límite texto sin revisar coste/moderación | Límite servidor 5000 chars (regla `reflexiones.texto.size() <= 5000`); cliente **sin contador ni validación previa** | — | ⚠️ **Observación** |

**Evidencia:**
- `lib/features/reflexion/data/borrador_reflexion_store.dart:18-42` — Guardado/recuperación en SharedPreferences
- `lib/presentation/screens/publicar_reflexion_screen.dart:95-113` — `_restaurarBorrador()` muestra SnackBar "Borrador recuperado"
- `lib/presentation/screens/publicar_reflexion_screen.dart:126-141` — `_confirmarPublicacion()` muestra `VistaPreviaReflexion`
- `lib/features/reflexion/presentation/vista_previa_reflexion.dart:90-110` — Botones "Seguir editando" / "Publicar"
- `lib/presentation/screens/publicar_reflexion_screen.dart:18-29` — Constructor acepta `textoInicial`
- `test/screens/publicar_reflexion_screen_test.dart:63-195` — 5 widget tests cubriendo todo el flujo

**Observación (no bloqueante para T-028):** El criterio 4 dice "no se eleva el límite". El límite actual es 5000 chars (regla Firestore) y **no se ha elevado**, por tanto técnicamente se cumple. Sin embargo, **falta validación cliente** (contador, botón deshabilitado >5000) — ya existe tarea `T-067` en backlog para esto.

**Conclusión:** T-028 **cumple** los 4 criterios formales. La validación cliente es mejora separada (T-067).

---

## T-029 — Oración con seguimiento (lib/presentation/screens/oracion_screen.dart)

### Criterios de aceptación del roadmap (§2.3)

| # | Criterio | Código | Test | Veredicto |
|---|----------|--------|------|-----------|
| 1 | Solo autor marca respondida + añade actualización | Cliente: `isAutor` check (`oracion_screen.dart:447-450`). Servidor: `marcarPeticionComoRespondida` valida `userId` | **Sin test de reglas** que verifique que no-autor no puede escribir `respondida`/`fechaRespondida` | ❌ **NO CUMPLE** |
| 2 | Aviso a apoyadores opcional, sin texto sensible en lock-screen | **No existe implementación** (ni Cloud Function, ni FCM, ni preferencia usuario) | — | ❌ **NO CUMPLE** |
| 3 | Consultas con índice, límite y paginación | `.limit(prayerPageSize)` sí; **falta índice compuesto** `oculto`+`respondida`+`fecha`; **falta paginación** (cursor) | **Sin test de reglas** para query con `respondida=true` | ❌ **NO CUMPLE** |

**Evidencia de incumplimientos:**

1. **Solo autor + actualización** (`oracion_screen.dart:472-478` llama a `marcarPeticionComoRespondida` que solo pone `respondida=true` + `fechaRespondida`; **no hay campo `actualizacionAutor`** en modelo ni en escritura):
   - `lib/data/services/firestore_service.dart:802-819` — Solo actualiza `respondida` y `fechaRespondida`
   - `lib/data/models/peticion_oracion.dart` — No tiene campo `actualizacionAutor`
   - `firestore.rules:193-199` — `ownerEditOk()` no prohíbe `respondida`/`fechaRespondida` (no están en `changedKeys().hasAny([...])`), pero **no hay test de reglas** que verifique que un no-autor recibe `permission-denied`

2. **Notificación a apoyadores** — No existe en `functions/src/` ni en cliente. Criterio pide "opcional y sin texto sensible": **implementación ausente**.

3. **Índice, límite, paginación**:
   - `firestore.indexes.json:62-68` — Índice solo `oculto` + `fecha` (falta `respondida`)
   - `lib/data/services/firestore_service.dart:771-786` — `peticionesStreamFiltrado` usa `.where('respondida')` cuando filtro ≠ null → **requiere índice compuesto `oculto`+`respondida`+`fecha` que no existe**
   - Sin paginación (`startAfterDocument`); `prayerPageSize` limita pero no pagina

**Tests faltantes:**
- `test/screens/` — **No existe** `oracion_screen_test.dart` ni `peticion_card_test.dart`
- `firestore-tests/rules.test.mjs` — **No hay tests** para:
  - No-autor no puede escribir `respondida`/`fechaRespondida`
  - Query con `respondida=true` + `fecha desc` + `limit` funciona en emulador
  - Crear documento en `peticiones_oracion/{id}/apoyos/{uid}` solo con uid propio (subcolección de apoyos no verificada)

**Conclusión:** T-029 **NO CUMPLE** ninguno de los 3 criterios de aceptación. Requiere tareas nuevas.

---

## Hallazgos adicionales (fuera de T-027/028/029)

1. **Filtros del feed de oración** — Roadmap §2.3 pide filtros `Recientes`, `Por las que oro`, `Respondidas`. Implementación actual: `Todas`, `Pendientes`, `Respondidas`. Falta filtro "Por las que oro" (peticiones donde el usuario actual ha hecho "Amén").

2. **Subcolección `apoyos`** — No verificada en reglas ni tests. La función `apoyarPeticion` incrementa contador pero no crea documento en `peticiones_oracion/{id}/apoyos/{uid}`.

3. **Tests de integración** — No hay tests que cubran el flujo completo: crear petición → apoyar → autor marca respondida → notificación (cuando exista).

---

## Archivos clave revisados

```
lib/presentation/screens/home_screen.dart
lib/presentation/widgets/lectura_hoy_card.dart
lib/presentation/widgets/lectura_hoy_estados.dart
test/widgets/lectura_hoy_card_test.dart

lib/presentation/screens/publicar_reflexion_screen.dart
lib/features/reflexion/data/borrador_reflexion_store.dart
lib/features/reflexion/presentation/vista_previa_reflexion.dart
test/screens/publicar_reflexion_screen_test.dart

lib/presentation/screens/oracion_screen.dart
lib/data/services/firestore_service.dart (peticionesStreamFiltrado, marcarPeticionComoRespondida)
lib/data/models/peticion_oracion.dart
lib/features/oracion/data/oracion_repository.dart
firestore.rules (peticiones_oracion, ownerEditOk)
firestore.indexes.json (peticiones_oracion)
functions/src/ (sin función de notificación oración respondida)
```
