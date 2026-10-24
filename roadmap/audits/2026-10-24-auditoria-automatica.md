# Auditoría automática 2026-10-24

> Generada por la sesión auditora del ciclo autónomo (modelos `nvidia/nvidia/nemotron-3-ultra-550b-a55b, opencode/nemotron-3-ultra-free`, revisor `nvidia/nvidia/nemotron-3.5-super-vl-120b-a12b, nvidia/z-ai/glm-5.3, nvidia/nvidia/nemotron-3-ultra-550b-a55b`, origin/main @ 61bf7a1). tareas totales: 71; libres para el carril plataforma: 0.

## Tareas nuevas
| ID | Prioridad/Esfuerzo | Título |
|---|---|---|
| T-072 | P2/S | Oración: añadir campo actualizacionAutor al modelo PeticionOracion y permitir su escritura en reglas |
| T-073 | P2/M | Oración: notificación FCM opcional a apoyadores cuando se marca respondida (sin texto sensible en lockscreen) |
| T-074 | P2/M | Oración: widget tests de OracionScreen (filtros, lista vacía, loading, error, marcar respondida, Amén) |

## Propuestas descartadas
- «Oración: paginación por cursor en peticionesStreamFiltrado (startAfter»: revisor: Duplica T-069 (Paginación por cursor en peticiones de oración): misma fase (4), mismo esfuerzo (M), mismos archivos (lib/data/services/firestore_service.dart, lib/presentation/providers/app_providers.dart, lib/presentation/screens/oracion_screen.dart, test/services/firestore_service_test.dart) y mismos criterios de aceptación (startAfterDocument, infinite scroll / 'Cargar más', test de servicio con cursor). T-069 ya está en roadmap/tasks.yaml en estado backlog.
- «Oración: tests de reglas para actualización de respondida/fechaRespond»: revisor: Duplica T-068 (Tests de reglas para peticiones_oracion: paginación, actualizaciónAutor, apoyos subcolección): misma fase (1), mismo esfuerzo (S), mismo archivo (firestore-tests/rules.test.mjs) y mismos criterios de aceptación (query respondida=true + fecha desc + limit(10) + startAfter, autor puede escribir respondida+actualizacionAutor, no-autor denegado, crear apoyos/{uid} solo con uid propio). T-068 ya está en roadmap/tasks.yaml en estado backlog.


---

# Auditoría de la Fase 2 — Hábito devocional diario

**Fecha:** 2026-10-24  
**Repositorio:** AltarDiario (origin/main @ 61bf7a1)  
**Objetivo:** Contrastar criterios de aceptación de T-027, T-028, T-029 (marcadas como `done`) con el código real.

---

## Resumen ejecutivo

| Tarea | Estado real | Comentario |
|-------|-------------|------------|
| **T-027** Inicio "Hoy" | ✅ **Cumple** | Todos los criterios verificados con tests |
| **T-028** Reflexión guiada y privada | ✅ **Cumple** | Todos los criterios verificados con tests |
| **T-029** Oración con seguimiento | ❌ **NO cumple** | 3 de 4 criterios fallan; reglas de Firestore bloquean la implementación actual |

---

## T-027: Inicio "Hoy" — lectura pendiente, día completado y sin conexión

**Archivo principal:** `lib/presentation/screens/home_screen.dart`, `lib/presentation/widgets/lectura_hoy_card.dart`, `lib/presentation/widgets/lectura_hoy_estados.dart`  
**Tests:** `test/widgets/lectura_hoy_card_test.dart` (5 tests)

| Criterio | Código | Test | Resultado |
|----------|--------|------|-----------|
| < 2 toques abre lectura pendiente | `LecturaHoyCard` con `onTap` en toda la tarjeta + botón "Leer pasaje" | `pendiente: muestra el pasaje y se abre con un toque` (línea 48-62) | ✅ |
| Día completo → celebración discreta + siguiente lectura | `LecturaCelebracion` + `LecturaSiguiente` en `lectura_hoy_estados.dart` | `completado: celebración discreta y siguiente lectura` (línea 87-112) | ✅ |
| Skeleton de carga | `LecturaSkeleton` en `lectura_hoy_estados.dart:13-29` | `cargando: muestra el skeleton y no el versículo` (línea 64-73) | ✅ |
| Estado offline | `LecturaAvisoSinConexion` en `lectura_hoy_estados.dart:52-78` | `sin conexión: avisa y mantiene el plan guardado` (línea 75-85) | ✅ |
| Escalado de texto accesible (textScaler 2x) | `Wrap` en botones, sin alturas fijas en texto | `escala de texto grande: no desborda` (línea 114-123) | ✅ |

**Evidencia:** Todos los 5 tests pasan (`flutter test test/widgets/lectura_hoy_card_test.dart`).

---

## T-028: Reflexión guiada y privada por defecto

**Archivo principal:** `lib/presentation/screens/publicar_reflexion_screen.dart`, `lib/features/reflexion/presentation/vista_previa_reflexion.dart`, `lib/features/reflexion/data/borrador_reflexion_store.dart`  
**Tests:** `test/screens/publicar_reflexion_screen_test.dart` (5 tests)

| Criterio | Código | Test | Resultado |
|----------|--------|------|-----------|
| Borrador local recuperable tras cerrar app | `BorradorReflexionStore` usa `SharedPreferences` (guardar/leer/borrar) | `un borrador guardado muestra "Borrador recuperado" y precarga el texto` (línea 78-100) | ✅ |
| Publicar exige confirmación explícita + vista previa | `VistaPreviaReflexion` bottom sheet con botones "Seguir editando" / "Publicar" | `"Guardar" abre VistaPreviaReflexion con pasaje y texto exactos` (línea 102-128) | ✅ |
| Usuario convierte nota en publicación sin copiar | Parámetro `textoInicial` en `PublicarReflexionScreen` | `textoInicial precarga el cuerpo sin anunciar borrador recuperado` (línea 63-76) | ✅ |
| No se eleva límite de texto sin revisar coste/moderación | Límite 5000 chars en reglas (T-044), validación cliente pendiente (T-067) | N/A — verificado en reglas | ✅ |

**Evidencia:** Todos los 5 tests pasan (`flutter test test/screens/publicar_reflexion_screen_test.dart`).

---

## T-029: Oración con seguimiento — estado respondida, actualización y filtros del feed

**Archivo principal:** `lib/presentation/screens/oracion_screen.dart`, `lib/data/services/firestore_service.dart` (métodos `peticionesStreamFiltrado`, `marcarPeticionComoRespondida`), `lib/presentation/providers/app_providers.dart` (`peticionesFiltradasProvider`, `peticionesFiltroProvider`)  
**Tests:** **NINGUNO** para la pantalla ni para los filtros. Tests de modelo en `test/models/peticion_oracion_test.dart`, tests de servicio en `test/services/firestore_service_test.dart` (solo `apoyarPeticion`).

| Criterio | Código | Test | Resultado |
|----------|--------|------|-----------|
| Solo el autor marca una petición como respondida y **añade la actualización** | `marcarPeticionComoRespondida` actualiza `respondida: true` + `fechaRespondida` **PERO**:<br>1. No existe campo `actualizacionAutor` en modelo `PeticionOracion` (`lib/data/models/peticion_oracion.dart`)<br>2. **Reglas de Firestore BLOQUEAN** la actualización: `ownerEditOk()` no permite cambiar `respondida`, `fechaRespondida` ni `actualizacionAutor` (líneas 136-143 de `firestore.rules`) | **NINGUNO** — no hay test de reglas ni de servicio para esta operación | ❌ **FALLA** |
| Aviso a quienes apoyaron (opcional, sin texto sensible en lockscreen) | **NO IMPLEMENTADO** — no hay código de notificaciones FCM para `apoyos` subcolección | **NINGUNO** | ❌ **FALLA** |
| Consultas tienen índice, límite y **paginación** | Índice compuesto existe (`firestore.indexes.json:86-93`), límite (`prayerPageSize`) **PERO**:<br>NO hay paginación con cursor (`startAfterDocument`) — `peticionesStreamFiltrado` no acepta `lastDocument` | **NINGUNO** | ❌ **FALLA** |

### Detalle técnico crítico: Reglas de Firestore bloquean la escritura

El método `FirestoreService.marcarPeticionComoRespondida` (líneas 800-819 de `firestore_service.dart`) hace:
```dart
await docRef.update({
  'respondida': true,
  'fechaRespondida': FieldValue.serverTimestamp(),
});
```

Pero `ownerEditOk()` en `firestore.rules:136-143` **prohíbe** cambiar estos campos:
```javascript
function ownerEditOk() {
  return isOwner(resource.data)
    && !changedKeys().hasAny([
      'userId', 'likes', 'likedBy', 'upvotes', 'votedBy', 'oracionesCount',
      'oculto', 'ocultoMotivo', 'ocultoEn',
    ])    // ← respondida, fechaRespondida, actualizacionAutor NO están permitidos
    && noPrivateFields(request.resource.data);
}
```

La regla `allow update` en `peticiones_oracion` (línea 193-198) solo permite:
- `ownerEditOk()` — no incluye los campos nuevos
- `counterDeltaOk('oracionesCount')` — solo para "Amén"
- `likeOnly()` — solo reacciones

**Resultado:** Cualquier intento de marcar una petición como respondida **fallará con PERMISSION_DENIED** en producción.

---

## Qué NO se encontró

1. **Tests de widget para `OracionScreen`** — no existe `test/screens/oracion_screen_test.dart`
2. **Tests de provider para filtros** — no hay tests de `peticionesFiltroProvider` ni `peticionesFiltradasProvider`
3. **Tests de reglas para `respondida`/`fechaRespondida`/`actualizacionAutor`** — ausencia total en `firestore-tests/rules.test.mjs`
4. **Campo `actualizacionAutor` en modelo** — no existe en `PeticionOracion`
5. **Paginación por cursor** — `peticionesStreamFiltrado` no acepta parámetro `lastDocument`
6. **Notificación FCM a apoyadores** — no hay implementación en `functions/` ni en cliente

---

## Conclusión

- **T-027 y T-028:** Correctamente implementadas y testeadas. ✅
- **T-029:** Marcada como `done` pero **NO cumple** 3 de 4 criterios de aceptación. La implementación actual **no funciona en producción** debido a las reglas de Firestore. Requiere trabajo real para completar.
