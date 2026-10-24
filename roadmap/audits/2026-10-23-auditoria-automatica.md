# Auditoría automática 2026-10-23

> Generada por la sesión auditora del ciclo autónomo (modelos `nvidia/nvidia/nemotron-3-ultra-550b-a55b, opencode/nemotron-3-ultra-free`, revisor `nvidia/z-ai/glm-5.3, opencode/glm-5.3-flash-free`, origin/main @ 3cc8b6c). tareas totales: 63; libres para el carril producto: 2.

## Tareas nuevas
| ID | Prioridad/Esfuerzo | Título |
|---|---|---|
| T-064 | P2/S | Widget test de PublicarReflexionScreen: flujo completo borrador → vista previa → publicar |
| T-065 | P2/S | Oración: índice compuesto de Firestore para peticiones_oracion |
| T-066 | P2/S | Reglas: allowlist explícita para campos respondida/fechaRespondida en peticiones_oracion |

## Propuestas descartadas
- «Oración: paginación por cursor en peticionesFiltradasProvider»: ruta inexistente: test/features/oracion/peticiones_paginacion_test.dart
- «Oración: notificar a apoyadores cuando el autor marca petición como re»: revisor: No es de un solo carril: mezcla el carril 'a' (functions/src/*.ts, firestore.rules y firestore-tests/rules.test.mjs, los tres humanRequired) con el carril 'b' del producto (peticion_card.dart, oracion_repository.dart). Verificado con ownership.json; debe partirse en dos tareas, la de carril 'a' (Function de notificación + reglas + tests) y la de carril 'b' (apoyadoPor en cliente y preferencia de usuario). No es duplicado de tasks.yaml (T-034 son preferencias globales, no este aviso), pero el array 'apoyadoPor' exige una regla nueva para el 'Amén' del no-propietario que el array de criterios no recoge.
- «Oración: tests unitarios y de widget para feature completa (marcar res»: revisor: No es de un solo carril: su file firestore-tests/rules.test.mjs pertenece al carril 'a' (humanRequired) mientras el resto son tests Flutter. Además duplica trabajo de otras propuestas del mismo lote: el criterio 'peticiones_paginacion_test.dart: cursor page 1 → page 2 sin duplicados' es idéntico a los dos criterios de test de la propuesta 2 (los tests dependen de que la paginación exista), y el criterio de reglas 'solo autor puede escribir respondida:true' es exactamente la propuesta 5, dejándola sin contenido propio. Los tests de repositorio/providers/screen deben repartirse en las propuestas 2 y 5 correspondientes. Evidencia válida (no existe test/features/oracion/, verificado), pero el lote queda cubierto sin esta tarea.


---

# Auditoría de tareas T-027, T-028, T-029 (Fase 2 — Hábito devocional diario)

**Fecha:** 2026-10-23  
**Commit base:** origin/main @ 3cc8b6c (verificado en FASE.md)  
**Worktree:** auditoria-20261023-mvlw0dnv  

---

## Resumen ejecutivo

Se han verificado las tres tareas marcadas como `done` en el roadmap correspondientes a la **Fase 2 — Hábito devocional diario** del `PRODUCT_EVOLUTION_ROADMAP.md`:

| Tarea | Título | Estado en roadmap | Veredicto real |
|-------|--------|-------------------|----------------|
| T-027 | Inicio "Hoy": lectura pendiente, día completado y sin conexión | ✅ done | **Cumple** — Implementación y tests completos |
| T-028 | Reflexión guiada y privada por defecto | ✅ done | **Parcial** — Falta widget test de la pantalla principal |
| T-029 | Oración con seguimiento: estado respondida, actualización y filtros del feed | ✅ done | **No cumple** — Faltan notificaciones, paginación, índice y tests |

---

## T-027: Inicio "Hoy" — ✅ CUMPLE

### Criterios de aceptación (tasks.yaml)

| Criterio | Cumple | Evidencia |
|----------|--------|-----------|
| En menos de dos toques se abre la lectura pendiente | ✅ | `test/widgets/lectura_hoy_card_test.dart:48-62` — Tapa en el título del pasaje dispara `onAbrir` (la tarjeta entera es `InkWell`) |
| Si el día está completo se muestra celebración discreta y siguiente lectura | ✅ | `test/widgets/lectura_hoy_card_test.dart:87-112` — `find.text('¡Día completado!')` y `find.text('Siguiente: …')` |
| Skeleton de carga, estado offline y escalado de texto accesible | ✅ | Tests: `cargando` (LecturaSkeleton), `sin conexión` (LecturaAvisoSinConexion), `escala 2.0` sin overflow |
| Widget test para pendiente, completado y sin conexión | ✅ | 3 tests dedicados + 1 de escala de texto |

### Archivos involucrados
- `lib/presentation/screens/home_screen.dart` (líneas 65-68, 265-278, 669-680)
- `lib/presentation/widgets/lectura_hoy_card.dart` (líneas 16-135, 179-231, 233-274)
- `lib/presentation/widgets/lectura_hoy_estados.dart` (Skeleton, aviso offline, celebración)
- `test/widgets/lectura_hoy_card_test.dart` (4 tests)

### Observaciones
La implementación es sólida y los tests cubren los tres estados principales más el escalado de texto. El criterio "menos de dos toques" se cumple porque la tarjeta completa responde a un solo toque.

---

## T-028: Reflexión guiada y privada por defecto — ⚠️ PARCIAL

### Criterios de aceptación (tasks.yaml)

| Criterio | Cumple | Evidencia |
|----------|--------|-----------|
| Borrador local recuperable tras cerrar la app | ✅ | `lib/features/reflexion/data/borrador_reflexion_store.dart` + `test/features/reflexion/borrador_reflexion_store_test.dart` (4 tests) |
| Publicar exige confirmación explícita y muestra vista previa | ✅ | `lib/features/reflexion/presentation/vista_previa_reflexion.dart` + `test/features/reflexion/vista_previa_reflexion_test.dart` (2 tests) |
| El usuario convierte su nota en publicación sin copiar texto | ✅ | `lib/presentation/screens/notes_screen.dart:430-444` → `PublicarReflexionScreen(textoInicial: …)` |
| No se eleva el límite de texto sin revisar coste y moderación | ✅ | `CommunityPolicyService.validarContenido()` en `_publicar()` |

### Qué NO se cumple

| Qué falta | Evidencia |
|-----------|-----------|
| **Widget test de la pantalla `PublicarReflexionScreen`** | No existe `test/screens/publicar_reflexion_screen_test.dart` ni `test/features/reflexion/publicar_reflexion_screen_test.dart`. Los 6 tests mencionados en la evidence (`borrador_reflexion_store_test.dart` 4 + `vista_previa_reflexion_test.dart` 2) son de componentes internos, **no** un test de integración de la pantalla completa que verifique: recuperación de borrador al abrir, escritura, botón "Guardar" → vista previa → confirmar → publicación. |

### Archivos involucrados
- `lib/presentation/screens/publicar_reflexion_screen.dart` (líneas 18-274, 127-141, 95-113)
- `lib/features/reflexion/data/borrador_reflexion_store.dart`
- `lib/features/reflexion/presentation/vista_previa_reflexion.dart`
- `lib/presentation/screens/notes_screen.dart` (líneas 428-444)
- `test/features/reflexion/borrador_reflexion_store_test.dart`
- `test/features/reflexion/vista_previa_reflexion_test.dart`

### Observaciones
La funcionalidad está implementada correctamente. El gap es **exclusivamente de testing**: falta un `testWidgets` que ejercite el flujo completo de la pantalla (abrir → ver borrador recuperado → escribir → tocar "Guardar" → ver vista previa → confirmar → verificar navegación de vuelta).

---

## T-029: Oración con seguimiento — ❌ NO CUMPLE

### Criterios de aceptación (tasks.yaml)

| Criterio | Cumple | Evidencia |
|----------|--------|-----------|
| Solo el autor marca una petición como respondida y añade la actualización | ✅ (solo en servicio) | `lib/data/services/firestore_service.dart:802-819` lanza `StateError` si `data['userId'] != userId` |
| El aviso a quienes la apoyaron es opcional y no expone texto sensible en pantalla de bloqueo | ❌ **FALTA** | No hay ningún código que envíe notificación al marcar como respondida. `oracionesCount` se incrementa pero **no se persiste quiénes apoyaron** (no hay subcolección `apoyos` ni array `apoyadoPor`). Solo existe `oracionesCount: int`. |
| Las consultas tienen índice, límite y paginación | ❌ **PARCIAL** | Tiene `.limit(prayerPageSize)` en `firestore_service.dart:776` pero **NO tiene paginación por cursor** (`startAfterDocument`). No hay índice compuesto en `firestore.indexes.json` para `peticiones_oracion` (query: `oculto == false` + `fecha desc` + `respondida == ?`). |

### Qué NO se cumple (detalle)

| Qué falta | Detalle técnico |
|-----------|-----------------|
| **Notificaciones a apoyadores** | El criterio exige "aviso a quienes la apoyaron". Hoy no hay tracking de quién apoyó (solo contador), no hay Cloud Function ni código cliente que envíe notificación al marcar `respondida: true`. |
| **Paginación real (cursor)** | El provider `peticionesFiltradasProvider` usa `peticionesStreamFiltrado` que solo hace `.limit()`. No hay `startAfterDocument` ni `StreamProvider` con cursor. El `oracion_screen.dart` usa `ListView.builder` sin carga incremental. |
| **Índice de Firestore** | `firestore.indexes.json` no declara índice para `peticiones_oracion`. La query requiere: `where('oculto', false)` + `orderBy('fecha', desc)` + `where('respondida', ...)` → índice compuesto necesario. |
| **Tests** | **Cero tests** en `test/features/oracion/`. No hay test de: `marcarPeticionComoRespondida`, filtro por estado, paginación, UI de botón "Respondida", reglas de seguridad para campo `respondida`. |

### Archivos involucrados
- `lib/features/oracion/presentation/oracion_screen.dart` (líneas 31-138, 196-216)
- `lib/features/oracion/presentation/widgets/peticion_card.dart` (líneas 117-119, 159-222)
- `lib/features/oracion/providers/oracion_providers.dart` (líneas 19-46, 49-80)
- `lib/features/oracion/data/oracion_repository.dart` (líneas 18-21, 28-31)
- `lib/data/services/firestore_service.dart` (líneas 769-786, 800-819)
- `firestore.rules` (líneas 185-199) — permite `respondida` en `ownerEditOk()` (no está en lista prohibida)
- `firestore.indexes.json` — **sin índice para peticiones_oracion**

### Observaciones críticas
1. **Seguridad**: La regla `ownerEditOk()` no prohíbe explícitamente `respondida`/`fechaRespondida` (no están en la lista de claves bloqueadas), por lo que el dueño **puede** cambiarlas — correcto para la feature, pero debería documentarse o añadirse a allowlist.
2. **Dato faltante**: Para notificar a apoyadores hay que guardar quiénes dijeron "Amén" (array `apoyadoPor` o subcolección). Hoy solo hay `oracionesCount: int`.
3. **Tests de reglas**: No hay tests en `firestore-tests/rules.test.mjs` que verifiquen que solo el autor puede escribir `respondida: true`.

---

## Conclusión general

| Tarea | Código | Tests | Reglas/Índices | Veredicto |
|-------|--------|-------|----------------|-----------|
| T-027 | ✅ Completo | ✅ Completo | N/A | **Validado** |
| T-028 | ✅ Completo | ⚠️ Falta test de pantalla | N/A | **Requiere test** |
| T-029 | ❌ Incompleto (notif, paginación) | ❌ Cero tests | ❌ Sin índice | **Requiere implementación + tests** |

**Recomendación:** No cerrar T-028 ni T-029 como `done` hasta resolver los gaps arriba. Crear tareas nuevas para cada criterio faltante (ver `PROPUESTAS.json`).
