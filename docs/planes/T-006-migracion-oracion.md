# T-006 — Migrar `oracion` a `lib/features/oracion/` (ADR-0001)

**Estado:** plan listo · **Rama:** `lane-a/T-006` · **Rol:** carril A (arquitectura y core)

> **Progreso (andamiaje hecho):** `lib/features/oracion/data/oracion_repository.dart`
> y `test/features/oracion/oracion_repository_test.dart` existen y están verdes
> (rojo → verde, 4 tests). Falta lo que colisiona con #54: delegación desde
> `FirestoreService`, providers, mover pantalla y partirla.


Refactor puro: **sin cambios de comportamiento**. Si aparece un bug durante la
migración, se anota y no se arregla aquí (receta de `/migrate-feature`).

## 1. Condiciones de arranque (bloqueos reales)

| # | Condición | Por qué |
|---|---|---|
| 1 | **PR #54 mergeado** (`fix/lane-b-18-oracion-seguimiento`, B18/T-029) | Añade estado respondida y filtros en `oracion_screen.dart`, `peticion_oracion.dart`, `firestore_service.dart` y `app_providers.dart`. Mover esos archivos antes = conflicto de rename + edición, y se pierde el trabajo del carril B. |
| 2 | **PR #47 decidido** (`fix/lane-b-17-paginacion-cursor`, B17/T-020) | Toca `firestore_service.dart` y `app_providers.dart`. Está aparcado (sin tests, sin consumidores, base vieja). No bloquea el arranque, pero quien lo retome tendrá que rebasar sobre las rutas nuevas. |
| 3 | `origin/main` sin cambios en los cuatro archivos desde la última lectura | Se parte siempre de `origin/main`; no se mergea `main` local (regla del rol). |

Comando de arranque (cuando 1–3 se cumplan):

```bash
git fetch origin
git checkout -B lane-a/T-006 origin/main   # no se toca `main`
```

## 2. Inventario medido (hoy)

| Pieza | Dónde | Líneas |
|---|---|---|
| Pantalla | `lib/presentation/screens/oracion_screen.dart` | 415 |
| Diálogo "Pedir Oración" | misma pantalla, `_abrirDialogoNuevaPeticion` (L18-127) | 110 |
| Tarjeta | misma pantalla, `_PeticionCard` (L274-415) | 141 |
| Estado vacío | misma pantalla, `_buildEmptyState` (L238-271) | 34 |
| Modelo | `lib/data/models/peticion_oracion.dart` | 54 |
| Métodos de servicio | `firestore_service.dart` L634-658 (`peticionesStream`, `crearPeticionOracion`, `apoyarPeticion`) | 25 |
| Provider | `app_providers.dart` L149-153 (`peticionesStreamProvider`) | 5 |
| Constante | `FirestoreService.prayerPageSize` L73 (= 100) | 1 |
| Ruta | `main_navigation_view.dart:28` | 1 |
| Tests existentes | `test/models/peticion_oracion_test.dart` (5), `test/services/firestore_service_test.dart` (test de límite de página) | — |

Dependencias de la pantalla que **no** se mueven: `CommunityPolicyService`,
`GamificationService`, `AppTheme`, `ReportContentDialog`, `GuestAccessRestrictedWidget`,
`ShimmerListLoading` y los providers de `app_providers.dart` (perfil, auth, storage).

## 3. Destinos

```
lib/features/oracion/
  data/
    oracion_repository.dart              # NUEVO: los 3 métodos, con .limit()
  providers/
    oracion_providers.dart               # NUEVO: oracionRepositoryProvider + peticionesStreamProvider
  presentation/
    screens/
      oracion_screen.dart                # movida y partida (< 400 líneas)
    widgets/
      peticion_card.dart                 # pública (la usa la pantalla), 141 líneas
      nueva_peticion_dialog.dart         # función mostrarDialogoNuevaPeticion, ~110 líneas
      oracion_empty_state.dart           # estado vacío, 34 líneas
test/features/oracion/
  oracion_repository_test.dart           # NUEVO (fake_cloud_firestore)
  oracion_screen_test.dart               # NUEVO (widget test mínimo)
```

**El modelo se queda** en `lib/data/models/peticion_oracion.dart`: moverlo obliga a
editar `test/models/peticion_oracion_test.dart` y `firestore_service_test.dart`, y
T-006 exige que los tests existentes pasen **sin modificar**. Se moverá cuando
desaparezca `FirestoreService` (fase posterior de ADR-0001).

## 4. Contrato del repositorio (comportamiento idéntico)

```dart
class OracionRepository {
  OracionRepository(this._db);
  final FirebaseFirestore _db;

  static const int pageSize = 100; // era FirestoreService.prayerPageSize

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('peticiones_oracion');

  // Mismo orderBy y mismo límite que hoy (el test de límite lo verifica).
  Stream<List<PeticionOracion>> watchRecientes() => _col
      .orderBy('fecha', descending: true)
      .limit(pageSize)
      .snapshots()
      .map((s) => s.docs
          .map((d) => PeticionOracion.fromMap({'id': d.id, ...d.data()}))
          .toList());

  Future<void> crear(PeticionOracion peticion) => _col.add(peticion.toMap());

  Future<void> amen(String peticionId) => _col
      .doc(peticionId)
      .update({'oracionesCount': FieldValue.increment(1)});
}
```

`FirestoreService` pasa a **fachada temporal** y conserva la firma pública:

```dart
static const int prayerPageSize = OracionRepository.pageSize; // sin deriva

Stream<List<PeticionOracion>> peticionesStream() {
  if (!_available) return Stream.value([]);
  return OracionRepository(_firestore!).watchRecientes();
}
Future<void> crearPeticionOracion(PeticionOracion p) =>
    _available ? OracionRepository(_firestore!).crear(p) : Future.value();
Future<void> apoyarPeticion(String id) =>
    _available ? OracionRepository(_firestore!).amen(id) : Future.value();
```

El guard `_available` se queda en el servicio (contrato actual) y el repositorio
asume que `_firestore` no es null.

## 5. Providers y compatibilidad

`app_providers.dart` mantiene el símbolo con un `export` (ADR-0001):

```dart
export '../../features/oracion/providers/oracion_providers.dart';
```

```dart
final oracionRepositoryProvider = Provider<OracionRepository?>((ref) {
  final db = ref.watch(firestoreServiceProvider).firestore; // getter ya público
  return db == null ? null : OracionRepository(db);
});

final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final repo = ref.watch(oracionRepositoryProvider);
  return repo?.watchRecientes() ?? Stream.value(const []);
});
```

Se reutiliza `FirestoreService.firestore` (getter existente) en vez de crear un
`firestoreInstanceProvider`: así los tests que inyectan `FirestoreService(firestore: fake)`
siguen funcionando y no hay que tocar overrides.

**Ciclo de importación aceptado y documentado:** `app_providers` exporta
`oracion_providers`, que importa `app_providers` para `firestoreServiceProvider`.
Dart lo permite y es temporal hasta que el servicio desaparezca (ADR-0001).

## 6. División de la pantalla

- `peticion_card.dart`: la tarjeta tal cual, renombrada `PeticionCard` (pública,
  porque la usa la pantalla). 141 líneas < 150 ✓.
- `nueva_peticion_dialog.dart`: `mostrarDialogoNuevaPeticion(BuildContext, WidgetRef)`
  con el mismo contenido y el mismo flujo (validación de política, creación,
  gamificación, cierre y diálogo de badges). Sin cambios de comportamiento.
- `oracion_empty_state.dart`: el estado vacío.
- `oracion_screen.dart`: queda con `build`, el guard de invitado y el `when`.

Ninguna lógica nueva; no se introduce notifier en este PR (sería refactor de
comportamiento y complicaría la revisión).

## 7. Tests

Nuevos:

1. `oracion_repository_test.dart` (con `FakeFirebaseFirestore`):
   - `watchRecientes()` ordena por `fecha` descendente y se corta en `pageSize`.
   - `crear()` escribe `userId`, `userName`, `motivo`, `fecha` y `oracionesCount`.
   - `amen()` incrementa `oracionesCount` en 1.
2. `oracion_screen_test.dart` (widget, `ProviderScope` con overrides):
   - invitado → `GuestAccessRestrictedWidget` y sin FAB.
   - lista vacía → "No hay peticiones activas."
   - una petición → nombre, motivo y contador "1 orando".

Los tests existentes **no se tocan**. El de `firestore_service_test.dart`
("el stream de peticiones queda acotado a su tamaño de página") es la prueba de
que la delegación conserva el límite.

## 8. Verificación (gate de entrega)

```bash
scripts/check.sh --fast        # format + analyze + test (hoy 168 tests)
git diff --stat origin/main    # solo ficheros de esta lista
```

`node scripts/fast-lint.mjs` **no existe en el repo** (el rol lo pedía): el
equivalente real es `scripts/check.sh --fast`, que incluye `dart format --set-exit-if-changed`
y `flutter analyze`. Se reporta así en el PR.

Criterios de aceptación de T-006:

- [ ] `lib/features/oracion/{data,providers,presentation}` con `OracionRepository`
- [ ] `oracion_screen.dart` < 400 líneas (estimado: ~130)
- [ ] `app_providers.dart` exporta los providers migrados
- [ ] tests existentes pasan sin modificar

## 9. Riesgos

| Riesgo | Mitigación |
|---|---|
| Conflicto con #54 si arranca antes de integrarlo | Bloqueo 1; no se mueve ningún archivo hasta que esté en `main` |
| Divergencia de `prayerPageSize` | El servicio lo deriva del repositorio: un solo número |
| Ciclo `app_providers` ↔ `oracion_providers` | Aceptado, documentado; desaparece con el servicio |
| Cambio invisible de comportamiento en la tarjeta | Se mueve el widget sin reescribirlo; widget test con una petición |
| `main_navigation_view.dart` es una pantalla | Solo se cambia la línea de `import`; no lo toca el carril B (no está en #47/#54) |

## 10. Hallazgos fuera de alcance (no se arreglan aquí)

1. **`apoyarPeticion` no tiene idempotencia**: cada pulsación suma +1 sin
   registrar quién oró, así que se puede inflar `oracionesCount` a base de toques
   (las reglas solo limitan el delta a ±1 por escritura). Necesita campo
   `orandoPor`/subcolección y regla con uid propio. **Sugerencia: tarea nueva.**
2. **Estado de error crudo**: la pantalla muestra `'Error: $err'`. Debería ser un
   mensaje humano con reintento (DESIGN.md, estados obligatorios).
3. **Fallback `'anonimo'`** como uid cuando no hay sesión: con el guard de invitado
   es inalcanzable hoy, pero es una trampa si el guard cambia.
