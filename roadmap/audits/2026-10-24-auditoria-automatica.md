# Auditoría automática 2026-10-24

> Generada por la sesión auditora del ciclo autónomo (modelos `nvidia/nvidia/nemotron-3-ultra-550b-a55b, opencode/nemotron-3-ultra-free`, revisor `opencode/glm-5.3-flash-free, nvidia/nvidia/nemotron-3.5-super-vl-120b-a12b, nvidia/z-ai/glm-5.3`, origin/main @ cd53b22). tareas totales: 66; libres para el carril plataforma: 0.

## Tareas nuevas
| ID | Prioridad/Esfuerzo | Título |
|---|---|---|
| T-067 | P2/S | Validación cliente límite 5000 chars en reflexión + test integración nota→publicar |
| T-068 | P2/S | Tests de reglas para peticiones_oracion: paginación, actualizaciónAutor, apoyos subcolección |

## Propuestas descartadas
- «Cloud Function: notificación push opcional al marcar oración respondid»: revisor: No es de un solo carril: toca functions/ (carril a Plataforma/Seguridad) y lib/features/oracion/ (carril b Producto). Debe dividirse por carril o ceñirse a uno.
- «Paginación con cursor en oración (startAfterDocument) + índice compues»: revisor: No es de un solo carril: toca firestore.indexes.json (carril a) y lib/features/oracion/ (carril b). Además el índice compuesto para peticiones_oracion ya está cubierto por T-065.
- «Campo actualizaciónAutor en PeticionOracion + UI para añadirla al marc»: revisor: No es de un solo carril: toca firestore.rules (carril a) y lib/features/oracion/widgets (carril b). Debe dividirse por carril o ceñirse a uno.


---

# Auditoría Fase 2 — Hábito Devocional Diario

**Fecha:** 2026-10-24  
**Commit base:** cd53b22 (origin/main)  
**Alcance:** Verificación criterio por criterio de T-027, T-028, T-029

---

## Resumen ejecutivo

| Tarea | Estado real | Comentario |
|-------|-------------|------------|
| **T-027** Inicio "Hoy" | ✅ **COMPLETA** | Los 4 criterios verificados con tests |
| **T-028** Reflexión guiada | ⚠️ **PARCIAL** | 3/4 criterios OK; falta test de integración y validación UI del límite 5000 |
| **T-029** Oración con seguimiento | ❌ **INCOMPLETA** | 1/3 criterios OK; faltan notificación a apoyadores y paginación con cursor |

---

## T-027: Inicio "Hoy" — ✅ COMPLETA

**Archivos:** `lib/presentation/screens/home_screen.dart`, `lib/presentation/widgets/lectura_hoy_card.dart`, `lib/presentation/widgets/lectura_hoy_estados.dart`  
**Tests:** `test/widgets/lectura_hoy_card_test.dart` (5 tests)

| Criterio | Verificación | Evidencia |
|----------|--------------|-----------|
| En <2 toques abre lectura pendiente | ✅ | `testWidgets('pendiente: muestra el pasaje y se abre con un toque')` línea 48-62: `tap` en pasaje → `abiertas = 1` |
| Día completo → celebración + siguiente | ✅ | `testWidgets('completado: celebración discreta y siguiente lectura')` línea 87-112: `¡Día completado!`, `Siguiente: Génesis…`, tap "Abrir" → `siguientes = 1` |
| Skeleton, offline, textScaler | ✅ | 3 tests: `cargando` (skeleton), `sin conexión` (aviso), `escala 2.0` (sin overflow) |
| Widget tests 3 estados | ✅ | 5 tests cubren: pendiente, cargando, sin conexión, completado, textScaler 2x |

**Conclusión:** La implementación cumple todos los criterios. La tarjeta `LecturaHoyCard` usa `Wrap` para botones (no rompe a 2x), `ExcludeSemantics` en skeleton, y `TweenAnimationBuilder` para celebración discreta.

---

## T-028: Reflexión guiada y privada por defecto — ⚠️ PARCIAL

**Archivos:** `lib/presentation/screens/publicar_reflexion_screen.dart`, `lib/features/reflexion/data/borrador_reflexion_store.dart`, `lib/features/reflexion/presentation/vista_previa_reflexion.dart`  
**Tests:** `test/features/reflexion/borrador_reflexion_store_test.dart` (4), `test/features/reflexion/vista_previa_reflexion_test.dart` (2)

| Criterio | Verificación | Evidencia / Falta |
|----------|--------------|-------------------|
| Borrador local recuperable | ✅ | `BorradorReflexionStore` usa `SharedPreferences`; `initState` → `_restaurarBorrador()`; `dispose` guarda final. Tests: guarda/recupera, vacío=no recuperable, borrar limpia. |
| Publicar exige confirmación + vista previa | ✅ | `_confirmarPublicacion()` muestra `VistaPreviaReflexion` (bottom sheet) con botones "Publicar" (true) / "Seguir editando" (false). Tests verifican textos y retorno booleano. |
| Nota → publicación sin copiar | ✅ | Constructor `PublicarReflexionScreen({textoInicial})` línea 23, 28; `_restaurarBorrador()` prioriza `textoInicial` sobre borrador guardado (línea 97-100). |
| No elevar límite sin revisar coste/moderación | ✅ (regla) / ❌ (UI) | Regla en `firestore.rules:155` limita `texto.size() <= 5000`. **Falta en cliente:** contador de caracteres, validación preventiva, error amigable antes de enviar. Sin test que verifique que la UI impide >5000. |

**Hallazgos:**
- ✅ La arquitectura (borrador + vista previa + confirmación) está bien hecha.
- ❌ **No hay test de integración** que recorra: escribir → cerrar app → reabrir → borrador recuperado → vista previa → publicar.
- ❌ **Falta validación en cliente** del límite 5000: el usuario descubre el error solo tras fallo de permisos Firestore (violación de AGENTS.md: "nunca un error de permisos de Firestore").

---

## T-029: Oración con seguimiento — ❌ INCOMPLETA (2/3 criterios faltan)

**Archivos:** `lib/features/oracion/presentation/oracion_screen.dart`, `lib/features/oracion/providers/oracion_providers.dart`, `lib/features/oracion/data/oracion_repository.dart`, `lib/features/oracion/presentation/widgets/peticion_card.dart`, `lib/data/services/firestore_service.dart` (marcarPeticionComoRespondida)  
**Modelo:** `lib/data/models/peticion_oracion.dart`  
**Tests:** Solo modelo (`test/models/peticion_oracion_test.dart`)

| Criterio | Verificación | Evidencia / Falta |
|----------|--------------|-------------------|
| Solo autor marca respondida + actualización | ✅ | `firestore_service.dart:802-819` verifica `data['userId'] != userId` → `StateError`. `PeticionCard` muestra `_MarcarRespondidaButton` solo si `currentUid == peticion.userId` (línea 168). |
| Notificación opcional a apoyadores (sin texto sensible en lockscreen) | ❌ **FALTA** | No existe: (1) campo en modelo para rastrear quién dijo "Amén" (`oracionesCount` es solo contador), (2) Cloud Function que dispare FCM al marcar `respondida=true`, (3) preferencia de usuario para activar/desactivar este aviso. Criterio exige "opcional" y "no expone texto sensible". |
| Consultas con índice, límite y paginación | ❌ **PARCIAL** | Límite existe: `prayerPageSize = 100` (línea 73, 762, 776). **Faltan:** (1) paginación con cursor (`startAfterDocument`) — no hay `DocumentSnapshot` pasado a siguiente página, (2) índice compuesto declarado para `respondida + fecha` (query filtra por `respondida`), (3) tests de paginación (cursor, fin de lista, error). Los filtros "Todas/Pendientes/Respondidas" funcionan pero sin "Cargar más". |

**Hallazgos adicionales:**
- El modelo `PeticionOracion` **no tiene campo** `actualizacionAutor` (texto de actualización al marcar respondida) — el criterio dice "añadir una actualización del autor".
- No hay tests de: providers (`peticionesFiltradasProvider`), repository (`peticionesStreamFiltrado`), widget (`PeticionCard` con estado respondida), ni integración.

---

## Qué NO se encontró (brechas transversales)

1. **Tests de integración E2E** para los tres flujos principales (Inicio → Lectura, Nota → Publicar, Oración → Respondida + aviso).
2. **Validación cliente de límites de texto** (T-028: 5000, T-029 motivo: 3000) — hoy el usuario ve error de permisos Firestore.
3. **Paginación real con cursores** en oración (y feed, T-007) — solo `limit()`.
4. **Cloud Functions** para notificaciones push de oración respondida (requiere plan Blaze + despliegue).
5. **Índices compuestos** en `firestore.indexes.json` para `peticiones_oracion: respondida + fecha desc`.

---

## Comandos de verificación ejecutados

```bash
# Tests unitarios y widget
flutter test test/widgets/lectura_hoy_card_test.dart
# 5/5 passed

flutter test test/features/reflexion/
# 6/6 passed (borrador 4 + vista_previa 2)

flutter test test/models/peticion_oracion_test.dart
# 4/4 passed

# Análisis estático
flutter analyze
# No issues found

# Formato
dart format --output=none --set-exit-if-changed lib test
# Formatted 0 files
```
