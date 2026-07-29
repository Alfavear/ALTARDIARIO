# Bitácora de Desarrollo — AltarDiario Red Social

Este archivo documenta los avances, decisiones y tareas realizadas en la evolución de la app AltarDiario hacia una red social devocional.

---

## 2026-07-28 — Panel de Perfil Completo, Seguridad Invitados, Política de Comunidad & Ícono APK Personalizado

### ✅ Ícono de la APK Personalizado
- **`flutter_launcher_icons`**: Configurado en `pubspec.yaml` con `assets/logo_app.png` (logo 3D oficial de AltarDiario).
- **Regeneración de íconos**: Ejecutado `flutter pub run flutter_launcher_icons` para generar todos los tamaños Android (`mipmap-*`) e iOS automáticamente.
- **Resultado**: APK y App Bundle incluyen el ícono de llama dorada personalizado en todas las densidades.

### ✅ Panel de Perfil Mejorado (`PerfilScreen`)
- **Cabecera con estadísticas reales**: Reflexiones publicadas, peticiones enviadas, seguidores y seguidos con contador dinámico desde Firestore.
- **Banner de bienvenida**: Saludo personalizado con nombre del usuario.
- **Sección Configuración** completamente funcional con:
  - ✏️ Editar nombre, biografía y foto/avatar de perfil
  - 🔔 Notificaciones (hora configurable del recordatorio diario)
  - 📋 Normas de la Comunidad (modal con las 5 reglas detalladas + política de privacidad)
  - 🚪 Cerrar sesión con confirmación
- **Modal de Normas de la Comunidad**: Despliega las reglas de uso en un `BottomSheet` interactivo (respeto, contenido apropiado, fuentes bíblicas, no spam, privacidad).

### ✅ Seguridad para Usuarios Invitados (`GuestAccessRestrictedWidget`)
- **Nuevo widget**: `lib/presentation/widgets/guest_access_restricted_widget.dart` — pantalla de bloqueo con call-to-action para crear cuenta.
- **FeedScreen (`Tab 2 — Altar Comunitario`)**:
  - Los invitados ven un banner informativo en lugar del FAB de publicar.
  - Las acciones de seguir, reaccionar y comentar están deshabilitadas para invitados.
- **OracionScreen (`Tab 3 — Oración`)**:
  - Los usuarios invitados ven una pantalla bloqueada con `GuestAccessRestrictedWidget` invitándoles a registrarse para acceder a las peticiones de oración.

### ✅ Política de Comunidad (`CommunityPolicyService`)
- **Nuevo servicio**: `lib/core/services/community_policy_service.dart` — centraliza las reglas de la comunidad (5 normas de uso).
- **Integrado en**: `PerfilScreen` (configuración), `PublicarReflexionScreen` (banner antes de publicar) y `OracionScreen` (creación de peticiones).

### ✅ Nombres de Autor Dinámicos en Tiempo Real
- **`_ReflexionCard` (`feed_screen.dart`)**: Usa `userProfileByIdProvider(reflexion.userId)` para obtener el nombre actualizado del autor desde Firestore, eliminando el genérico `'Usuario'`.
- **`_PeticionCard` (`oracion_screen.dart`)**: Misma lógica para peticiones de oración — nombre real obtenido de Firestore.
- **Prioridad**: `usuario.nombre` → `usuario.userName` → nombre en el documento original.

### ✅ Modo Demo Eliminado / Invitado Renombrado
- Eliminado el botón "Modo Demo" de `LoginScreen`.
- Renombrado acceso anónimo a **"Iniciar sesión como invitado"** para mayor claridad UX.

### ✅ Análisis Estático Limpio
- `flutter analyze`: 0 errores, 0 warnings en código de producción.
- Removido import no usado `usuario.dart` en `feed_screen.dart`.
- Corregido import de test `community_policy_service_test.dart` con `package:altar_diario/`.

### ✅ Tests Actualizados
- `feed_screen_test.dart`: Agregado `isGuestUserProvider.overrideWithValue(false)` en todos los `ProviderScope` overrides.
- Nuevo test de restricción a invitados en FeedScreen.
- `community_policy_service_test.dart`: Import corregido a `package:altar_diario/`.

### 📦 Artefactos Generados
| Archivo | Ubicación |
|---------|-----------|
| APK Release | `build/app/outputs/flutter-apk/app-release.apk` → `Desktop/AltarDiario.apk` |
| App Bundle Play Store | `build/app/outputs/bundle/release/app-release.aab` |
| Web Release | `build/web/` (servido en `localhost:8080`) |

---

## 2026-07-28 — Icono 3D Oficial, Google Sign-In SHA-1, Ficha Play Store & Optimización UX Biblia + Tests (98/98 Pasando)

### ✅ Icono 3D Oficial & Artefactos de Tienda
- **Icono 3D de Alta Resolución (1024x1024)**: Generado e instalado en `assets/logo_app.png`, `web/favicon.png`, `web/icons/` e iconos de sistema Android `mipmap-*`.
- **Ficha Google Play Store**: Creado artefacto [store_listing_metadata.md](file:///C:/Users/ALVEAR/.gemini/antigravity-ide/brain/6c8a2f47-f072-4b66-8bfd-9a658732b4cd/store_listing_metadata.md) con descripciones, categorías y banner promocional 1024x500.
- **Android App Bundle (.aab)**: Compilado y firmado en `build/app/outputs/bundle/release/app-release.aab`.

### ✅ Optimización de Navegabilidad y UX
- **Indicador de Gestos en la Biblia (`_buildSwipeHintBar`)**: Integrada barra píldora discreta en la parte superior del lector bíblico que guía al usuario sobre el gesto lateral (`👈 Desliza para cambiar de capítulo 👉`) mostrando nombres de los capítulos anterior y siguiente.
- **Limpieza de Inicio de Sesión**: Eliminado el modo demo y renombrado el botón a *"Iniciar sesión como invitado"*.

---

## 2026-07-27 — Experiencia Visual de la Biblia, Gestos Swipe, Buscador y Comparador de Versiones + Tests (98/98 Pasando)

### ✅ Experiencia Visual y Navegabilidad (`BibleReaderScreen`)
- **Temas de Lectura**: Soporte para conmutar dinámicamente entre ☀️ **Claro**, 📜 **Sepia (Pergamino)** y 🌙 **Noche (Dark Mode)**, adaptando fondo, textos y AppBars.
- **Navegación por Gestos (Swipe)**: Gestos `GestureDetector(onHorizontalDragEnd)` para cambiar de capítulo deslizando lateralmente la pantalla (izquierda: capítulo siguiente, derecha: capítulo anterior).
- **Selector de Libros con Buscador Dinámico**: Modal `_showBookSelector` mejorada con `TextField` de búsqueda rápida de libros por texto (ej. "Salmos", "Mateo") e identificador de Antiguo/Nuevo Testamento.

### ✅ Comparador de Versiones en Paralelo (`BibleCompareScreen`)
- **Pantalla y Modal Dedicada**: Creado `BibleCompareScreen` con dos modos de comparación:
  1. **Vista Paralela (2 Columnas)**: Muestra lado a lado el texto completo en dos versiones seleccionables (ej. RV1960 vs NVI/TLA/KJV).
  2. **Versículo por Versículo**: Muestra tarjetas comparativas por cada versículo individual entre versiones.
- **Acciones Rápidas en Versículos**: Opción *"Comparar en otras versiones"* y *"Copiar versículo"* agregadas al modal táctil de versículo.

### ✅ Pruebas 98/98 Pasando
- Creado [bible_compare_screen_test.dart](file:///d:/Projects/AltarDiario/ALTARDIARIO/test/screens/bible_compare_screen_test.dart) para probar el renderizado y cambio de pestañas en el comparador.

---

## 2026-07-27 — Evaluación Automática de Insignias + Edición de Perfil (Fase 4) + Tests (96/96 Pasando)

### ✅ Notificaciones y Celebración de Insignias
- **`GamificationService.evaluarYNotificarBadges`**: Evalúa automáticamente criterios al publicar reflexiones o peticiones de oración, otorgando las insignias y persistiendo XP/nivel en Firestore.
- **Notificación Local & Celebración UI**:
  - `NotificationService.showNotification`: Envía notificación local cuando se otorga una nueva insignia.
  - `GamificationService.showBadgeUnlockedDialog`: Despliega un diálogo emergente de celebración con las nuevas insignias y XP obtenidos.
- **Integrado en**: `PublicarReflexionScreen` y `OracionScreen`.

### ✅ Edición de Perfil de Usuario (Fase 4)
- **`_showEditProfileDialog` en `PerfilScreen`**: Permite al usuario editar su nombre de usuario, biografía/frase y foto de perfil o avatar.
- **Avatares Emoji Presets**: Selección rápida de avatares emoji (`emoji:🕊️`, `emoji:📖`, `emoji:⭐`, `emoji:🔥`, `emoji:📜`) compatibles 100% offline y sin requerir descargas de red.

### ✅ Tests 96/96 pasando
- Creado [gamification_flow_test.dart](file:///d:/Projects/AltarDiario/ALTARDIARIO/test/services/gamification_flow_test.dart) para probar el flujo de evaluación de insignias.
- Actualizado [perfil_screen_test.dart](file:///d:/Projects/AltarDiario/ALTARDIARIO/test/screens/perfil_screen_test.dart) para validar la interacción con la modal de edición de perfil.

---

## 2026-07-27 — Integración UI de Gamificación en PerfilScreen + Tests (93/93 Pasando)

### ✅ Nivel, Barra de XP e Insignias Reales en `PerfilScreen`
- **`_LevelProgressCard`**: Muestra el Nivel dinámico del usuario (1 al 10), sus puntos de experiencia totales (XP) y la barra de progreso calculada con `GamificationService`.
- **`_AchievementsSection` dinámico**: Conectado a la colección completa de 16 insignias de `GamificationService`. Muestra badges desbloqueados con su color de rareza y badges bloqueados en gris con icono 🔒.
- **Diálogo de Detalle & Modal de Colección Completa**:
  - `_showBadgeDetailDialog`: Muestra nombre, rareza, descripción, puntos XP que otorga y estado de desbloqueo.
  - `_showAllBadgesModal`: Despliega un `BottomSheet` interactivo con todas las insignias disponibles y el contador `unlocked/total`.
- **Compatibilidad Material**: Encapsulados contenedores en `Material` con `clipBehavior: Clip.antiAlias` para prevenir advertencias de `ListTile`/`InkWell`.

### ✅ Tests 93/93 pasando
- Creado [perfil_screen_test.dart](file:///d:/Projects/AltarDiario/ALTARDIARIO/test/screens/perfil_screen_test.dart) para validar el renderizado de nivel, XP y apertura del modal de insignias.

---

## 2026-07-27 — Validación completa + Fixes de estabilidad

### ✅ Análisis estático limpio
- `flutter analyze`: 0 errores, 0 warnings (solo 12 info `avoid_print` en archivos de scripts `.dart` — no es código de producción)
- Se corrigieron todas las advertencias de producción (ver `⚙️ Cambios de código` abajo)

### ✅ Tests 91/91 pasando
- `flutter test`: 91 tests pasan, 0 fallos
- Se corrigió el test fallante pre-existente `home_screen_test.dart` — `_MiniReadingCard` overflow en viewport reducido
- Se corrigieron warnings en test files (`@override` en `_available`, `@override` faltante en `toggleCommentLike`)

### ⚙️ Cambios de código

#### `lib/presentation/screens/home_screen.dart`
- Corregido overflow vertical en `_MiniReadingCard` Column (línea ~830)
  - Removido `Spacer()` que causaba desbordamiento en restricciones de altura reducida (viewport 124px en widget tests)
  - Cambiado `mainAxisAlignment: MainAxisAlignment.spaceBetween` para distribución equilibrada
  - Reducido `SizedBox(height: 6)` → `SizedBox(height: 4)`
  - Reducido passage `maxLines: 2` → `maxLines: 1` para caber en tarjetas compactas del ListView horizontal
  - Aplicado `Flexible` al Text "Planificado" dentro del Row para evitar overflow horizontal

#### `lib/data/services/auth_service.dart` (línea ~178)
- Corregido `UserCredential?` nullable innecesario → `UserCredential` (ya que `getRedirectResult()` retorna no-nulo)
- Eliminados operadores redundantes `?.` y `!` en líneas de acceso a `result.user`

#### `lib/presentation/screens/debate_detail_screen.dart` (línea ~167)
- Corregido: `if (sin llaves) return;` → envuelto en bloques `{ return; }` para evitar warning `curly_braces_in_flow_control_structures`

#### `test/screens/home_screen_test.dart` (línea ~111)
- Removido `@override` de `_available` (método privado de FirestoreService no es heredable)
- Eliminada declaración de `bool get _available => true;` no usada del MockFirestoreService

#### `test/screens/feed_screen_test.dart` (línea ~197, ~221)
- Removido `@override` de `_available` (mismo motivo que arriba)
- Eliminada declaración no usada de `bool get _available => true;`
- Agregado `@override` faltante en `toggleCommentLike(...)` (método de FirestoreService)

---

## 2026-07-24 — Corrección de tests + Gamificación (Badges/Achievements)

### ✅ Tests de pantalla corregidos (feed_screen_test.dart / home_screen_test.dart)
- **feed_screen_test.dart**: 5/5 tests pasan
  - Fix: Mocks Notifier usan `build()` en vez de `state =` en constructor.
  - Fix: Chip filtro tag clickeable con `tap()` en vez de `pumpWidget()` duplicado.
  - Fix: Navegación FAB valida tab "Comunidad" (índice 2) no 1.
- **home_screen_test.dart**: 1 test falla pre-existente (_MiniReadingCard overflow en viewport reducido)
  - Fix: Imports faltantes Comment, PeticionOracion.
  - Fix: Mocks FirestoreService usan `build()` en constructor.
  - Fix: Test "Modo Enfoque" removido (pantalla ya no tiene esa UI).

### ✅ Modelo Badge + enums BadgeCategory / BadgeRarity (lib/data/models/badge.dart)
- Badge: id, name, description, icon, category, rarity, criteria(Map), points, createdAt.
- fromMap/toMap con Timestamp, copyWith, const constructor (createdAt required sin default).
- Extensiones color y label para Rarity/Category.

### ✅ Modelo Usuario extendido (lib/data/models/usuario.dart)
- Agregados: badges: List<String>, totalPuntos: int, nivel: int con serialización Firestore/Map.

### ✅ GamificationService (lib/core/services/gamification_service.dart)
- 16 badges definidos: rachas (7/30 días), lecturas (1/100/365), comunidad (likes, comentarios, seguidores), oración (peticiones), Biblia (días enfoque), especiales (Navidad 2025).
- XP por nivel (1-10), cálculo de nivel, progreso a siguiente nivel.
- checkAndAwardBadges(usuario, stats, firestore, storage) → evalúa criterios, desbloquea, actualiza Firestore via updateUserConfig.
- addPoints(userId, points, firestore) → transacción atómica para sumar XP y recalcular nivel.

### ✅ Providers y servicios
- app_providers.dart: Import notification_service.dart corregido (../../core/services/).
- FirestoreService: Getter público `firestore` añadido para acceso directo en addPoints.

### ✅ Estado actualizado
- badge.dart: 0 errores
- gamification_service.dart: 0 errores — createdAt inyectado en los 17 Badge constructors
- app_providers.dart: Sin imports problemáticos

### 📋 Próximos pasos pendientes
1. Integrar badges en UI: pantalla perfil (mostrar badges desbloqueados), notificación al desbloquear, barra de progreso nivel/XP.
2. Fase 4: Perfiles dinámicos, estadísticas avanzadas.

---

## 2026-06-08 (continuación 4) — Modo Enfoque + Sugerencias de amistad

*Contenido anterior de la bitácora — detalles completos en la sección 2026-07-24 anterior.*
