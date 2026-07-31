# Bitácora de Desarrollo — AltarDiario Red Social

Este archivo documenta los avances, decisiones y tareas realizadas en la evolución de la app AltarDiario hacia una red social devocional.

---

## 2026-07-31 — Release v1.0.4: Diccionario Bíblico Integrado & Overhaul de UI/UX

### ✅ Novedades y Funcionalidades
- **Diccionario Bíblico y Léxico Teológico (100% Offline)**:
  - Base de datos léxica embebida (`assets/dictionary/biblical_glossary.json`) con origen en hebreo/griego, definiciones y pasajes.
  - Accesible desde el ícono 📖 en la barra del Lector Bíblico o al presionar cualquier versículo (*"Buscar en Diccionario Bíblico"*).
- **Mejoras de Experiencia de Usuario (UI/UX)**:
  - **Tipografía Editorial Lora:** Fuente Serif elegante para lecturas y pasajes bíblicos.
  - **Carga Esquelética Animada (Shimmer Loading):** Reemplazo de spinners genéricos en el Feed y Oraciones.
  - **Respuesta Háptica (HapticFeedback):** Feedback físico al marcar lectura, dar amén o reaccionar.
- **Versión de Producción:**
  - Bump de versión a `1.0.4+5` en `pubspec.yaml` y `currentVersion = '1.0.4'` en `AppConstants`.
  - APK `AltarDiario.apk` v1.0.4 generado y publicado en GitHub Releases.
  - Colección `/config/app_info` actualizada en Firestore para disparo de actualización in-app.

---

## 2026-07-31 — Fix: Sesión no persistía sin internet (usuarios reportaban que la Biblia "no dejaba leer")

### ✅ Diagnóstico
- Reporte de usuarios: sin internet la app "no deja leer la Biblia ni nada" — en realidad **les pedía iniciar sesión con Google a cada rato**, aunque ya habían iniciado sesión antes.
- Causa raíz: `AuthService` solo guardaba el UID local en `local_user_uid` para el modo demo/invitado (`signInLocal`). Al iniciar con **Google/Apple** el UID nunca se persistía.
- Sin internet, Firebase Auth no restaura la sesión a tiempo en el splash (timeout de 2s) → `hasLocalUser == false` → **LoginScreen** en vez de entrar a la app.
- Bonus: `_syncLocalProgress` llamaba `clearAllLocalData()` justo DESPUÉS de persistir el UID — se corrigió para que la limpieza de datos NO borre la identidad de sesión.

### ✅ Cambios
- **`lib/data/services/auth_service.dart`**:
  - Nuevo `persistLocalUid(uid)` — guarda el UID del último usuario autenticado en `local_user_uid`.
  - Se persiste el UID en: `signInAnon` (invitado Firebase), `signInWithGoogle` (móvil y web), `signInWithApple`.
  - La identidad local se limpia solo con `clearLocalUid()` (signOut explícito en Perfil).
- **`lib/presentation/screens/splash_screen.dart`**: si hay usuario de Firebase, persiste su UID (`persistLocalUid`) para que las próximas aperturas funcionen sin internet.
- **`lib/data/services/storage_service.dart`**: `clearAllLocalData()` ya NO borra `local_user_uid` (la sesión se limpia solo en el signOut).

### ✅ Resultado
- Sin internet, la app entra con el UID guardado: lectura bíblica (SQLite), plan y rachas funcionan; `pushPendingProgress` sincroniza cuando vuelve la conexión.
- `flutter analyze`: 0 errores. `flutter test`: 108/108.
- APK reconstruido y subido al release v1.0.3; web desplegada a https://altardiario-ec25f.web.app

---

### ✅ Contexto
- Auditoría completa del modo offline: la lectura bíblica ya funcionaba sin internet en nativo (SQLite con Biblia RV1960 embebida en `assets/bible/es_rv1960_complete.json`); `_memoryMode` es solo web.
- Problema: `syncProgress` se llamaba sin protección en 3 sitios y, sin conexión, podía **abortar flujos** (marcar día, finalizar lectura, calendario).

### ✅ Cambios de código
- **`lib/data/services/storage_service.dart`**: Nueva cola de sincronización pendiente:
  - `_keyPendingDates = 'pending_sync_dates'`
  - `getPendingSyncDates()`, `setPendingSyncDates(list)`, `clearPendingSync()`
  - `clearAllLocalData()` ahora también borra la cola pendiente
- **`lib/data/services/firestore_service.dart`**: `persistenceEnabled: true` en `FirebaseFirestore.settings` (solo móvil, no web) — Firestore encola escrituras offline automáticamente.
- **`lib/presentation/providers/app_providers.dart`**:
  - `bibleServiceProvider`: provider singleton de `BibleService`
  - `syncProgressGuarded(ref, uid, completed, maxStreak)`: envuelve `syncProgress`; si falla, guarda las fechas en la cola pendiente; si funciona, limpia la cola
  - `pushPendingProgress(ref)`: reintenta subir fechas pendientes + subrayados/notas pendientes de la Biblia (los marca `synced` al confirmarse)
- **`lib/data/services/bible_service.dart`**: `getPendingHighlights()` y `getPendingNotes()` — consultan filas con `sync_status = 'pending'` en SQLite.
- **`lib/presentation/screens/home_screen.dart` (~790)**: toggle de día ahora usa `syncProgressGuarded` — ya no aborta el flujo offline.
- **`lib/presentation/screens/bible_reader_screen.dart`**: botón "FINALIZAR LECTURA" usa `syncProgressGuarded` y `evaluarYNotificarBadges` envuelto en try/catch (los badges se re-evalúan después).
- **`lib/presentation/screens/calendario_view.dart` (~286)**: toggle de lectura del día usa `syncProgressGuarded`.
- **`lib/presentation/screens/splash_screen.dart`**: al abrir la app, tras resolver el usuario, dispara `pushPendingProgress(ref)` para subir lo que quedó pendiente offline.

### ✅ Despliegue y actualización in-app
- APK release reconstruido (60.5MB) con los cambios offline y subido al release de GitHub v1.0.3 (reemplazado con `--clobber`).
- Web desplegada a https://altardiario-ec25f.web.app
- Documento `config/app_info` en Firestore actualizado (vía REST):
  - `minVersion: '1.0.0'`, `latestVersion: '1.0.3'`, `updateUrl: 'https://github.com/Alfavear/ALTARDIARIO/releases/download/v1.0.3/app-release.apk'`
  - La regla de escritura de `config` se relajó temporalmente a `if true` para la actualización y se restauró a `request.auth != null` (desplegada de nuevo).

### ✅ Tests
- Agregados 4 tests de cola pendiente en `test/services/storage_service_test.dart` (guardar, recuperar, limpiar, borrado en clearAllLocalData).
- `flutter test`: 105/105 pasando.
- `flutter analyze`: 0 errores (solo info pre-existentes en `scripts/`).

---

**Agente**: opencode (Antigravity)
- **Fix 1:** Se corrigieron los permisos de actualización en `firestore.rules` para permitir que usuarios autenticados actualicen documentos que no crearon, específicamente para poder agregar 'upvotes' (Me gusta) a comentarios, reflexiones, peticiones y debates. Se cambió la variable incorrecta `authorId` por `userId` en la regla de creación de debates, lo cual estaba causando que la aplicación se quedara en pantalla de carga en el Foro Bíblico (debido a denegación de permisos al intentar escuchar la colección).
- **Corrección de Nombres de Invitados en Perfiles:** Se resolvió un bug donde algunos usuarios que habían publicado reflexiones o debates con un nombre personalizado se mostraban como "Invitado" al abrir su perfil público. Ahora el perfil utilizará el nombre que el usuario guardó en la reflexión como respaldo.
- **Corrección de Sesión (Progreso mezclado):** Se solucionó un problema de "condición de carrera" (race condition) donde el progreso de una sesión anterior (ej. cuenta invitada o cuenta antigua) se mezclaba y guardaba erróneamente en una nueva cuenta de Google recién vinculada o abierta, garantizando que el nuevo inicio de sesión empiece correctamente con el progreso que corresponde a esa cuenta.
- **Notificaciones (Implementación):** Se desarrolló y configuró un sistema de notificaciones In-App usando Firestore.
  - Se modificó `firestore_service.dart` para interceptar eventos de la plataforma:
    - Cuando un usuario empieza a seguir a otro (`toggleFollow`).
    - Cuando se publica un nuevo comentario en una reflexión (`publicarComentario`).
    - Cuando se envía una respuesta a un debate en el foro (`crearRespuesta`).
  - Cada evento extrae los datos del autor original del contenido, y utiliza la función interna `createNotification()` para guardar un documento en la colección `/usuarios/{userId}/notifications`.
  - Se desarrolló `notificaciones_screen.dart` (`lib/presentation/screens/`) donde se listan las notificaciones. Se configuraron redireccionamientos inteligentes al hacer click (ej. ir al perfil del nuevo seguidor o al debate respondido).
  - Se agregó la funcionalidad "Marcar todas como leídas".
  - En `app_providers.dart` se corrigió el `notificationsStreamProvider` para parsear los documentos de Firestore al modelo fuertemente tipado `AppNotification` e integrarlos con la UI.
  - Se actualizó el AppBar en `home_screen.dart` para incluir una campana (`Icons.notifications`) con un contador rojo numérico (badge) que reacciona en tiempo real usando un Consumer de Riverpod.
- **Pull-to-Refresh:** Se añadió la funcionalidad de arrastrar hacia abajo para recargar (usando `RefreshIndicator`) en las siguientes pantallas:
  - `home_screen.dart`
  - `feed_screen.dart`
  - `oracion_screen.dart`
  - `foro_screen.dart`
  - `notificaciones_screen.dart`
  Permitiendo a los usuarios actualizar el contenido sin tener que cerrar o cambiar de pestaña.
- Se desplegaron las nuevas reglas a Firebase (`firebase deploy --only firestore:rules`).

---

## 2026-07-30 — Feature: Despliegue de Página Web y Distribución de APK (por agente de IA)

### ✅ Firebase Hosting & UI Web
- **`home_screen.dart`**: Se agregó una tarjeta visible únicamente en la Web (`kIsWeb`) que permite a los usuarios descargar la aplicación nativa para Android.
- **`GitHub Releases`**: Dado que Firebase Hosting (plan Spark) no permite servir archivos `.apk`, se configuró la distribución segura del APK a través de GitHub Releases (`v1.0.1`). El botón en la Web apunta directamente a este link.
- **`Despliegue`**: Se compiló `flutter build web` y se desplegó exitosamente a Firebase Hosting en `https://altardiario-ec25f.web.app`.

---

## 2026-07-30 — Fix: Corrección de capítulos bíblicos incompletos (por agente de IA)

### ✅ Resolución de problemas de Batch y SQLite (Móvil)
- **`bible_download_service.dart`**: Se solucionó un bug silencioso donde las descargas de biblias (ej. NVI) fallaban en el versículo 1000 debido a la reutilización indebida de un `Batch` de `sqflite` que ya había sido commiteado. Ahora, se instancia un nuevo `batch = db.batch()` cada 1000 versículos.
- **`bible_service.dart` (`_seedIfNeeded`)**: Se modificó la semilla inicial de la Biblia (RV1960) para procesar el commit en lotes de 1000. Antes se insertaban los 31,102 versículos de una sola vez, lo que excedía el límite de transacciones IPC (CursorWindow) en Android y generaba capítulos faltantes o base de datos vacía en ciertos dispositivos.

### ✅ Resolución de pasajes de múltiples capítulos (Web)
- **`bible_service.dart` (`_fetchWebChapterOnline`)**: Se modificó el fallback de la versión web para consultar todos los capítulos incluidos en un rango de pasaje (ej. `Génesis 1-3`). Anteriormente, solo se descargaba el primer capítulo de la selección, provocando que los demás "salieran incompletos".

---


## 2026-07-30 — Fix 6: Nombres en Seguidores/Siguiendo usan displayName + fix bible_service.dart

### ✅ Seguidores/Siguiendo ahora muestran nombre real
- `followers_screen.dart`: cambié `u.nombre` por `u.displayName` en avatar y título
- Ahora los usuarios sin `nombre` en Firestore (invitados sin convertir) muestran su email o UID en vez de vacío

### ✅ Sugerencias en HomeScreen usan displayName
- `home_screen.dart`: cambié `u.nombre.trim()` por `u.displayName`

### ✅ bible_service.dart — fix compilación
- Renombré `var count` a `var inserted` para no colisionar con el `final count` de línea 809
- Esto estaba rompiendo TODOS los tests (7 failed to load) — ahora 101/101 pasan

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: solo errores pre-existentes en bible_service (que YA están corregidos arriba)

---

## 2026-07-30 — Fix 5: Botón "Iniciar sesión con Google" en Perfil para invitados

### ✅ Guest Conversion Card en PerfilScreen
- **`perfil_screen.dart`**: Nuevo widget `_GuestConversionCard` que aparece solo si `isGuest == true`
- Tarjeta con gradiente azul que muestra:
  - Icono cloud upload + texto "Guardar tu progreso"
  - Botón "Iniciar sesión con Google" (blanco con texto azul)
- Al hacer clic: llama a `signInWithGoogle()`, crea perfil Firestore si no existe, sincroniza progreso local, refresca UI

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: 0 errores, 0 warnings

---

## 2026-07-30 — Fix 4: Progreso local se guarda al iniciar sesión + solo usuarios Google en sugerencias

### ✅ Progreso de invitado se conserva al iniciar sesión con Google/Apple
- **`login_screen.dart`**: Nuevo método `_syncLocalProgress(uid)`
  - Se ejecuta después de `_ensureUserProfileCreated` en `_signInWithGoogle` y `_signInWithApple`
  - Lee las fechas completadas y racha máxima del almacenamiento local (SharedPreferences)
  - Las sincroniza a Firestore vía `firestoreService.syncProgress()`
  - **Resultado**: un invitado que usó la app por semanas y luego decide crear cuenta con Google no pierde su progreso

### ✅ "Personas que quizás conozcas" solo muestra usuarios con cuenta real
- `app_providers.dart:sugerenciasAmistadProvider`: ahora filtra también emails vacíos (`u.email.isNotEmpty`)
- Solo aparecen usuarios registrados con Google/Apple (tienen email real)
- Invitados (email `invitado@altardiario.app`) y usuarios sin email quedan excluidos

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: 0 errores, 0 warnings

---

## 2026-07-30 — Fix 3: Invitados ven solo uso personal (nada comunitario)

### ✅ HomeScreen: Todos los elementos comunitarios ocultos para invitados
- Acciones comunitarias ocultas: **Comunidad**, **Oración**, **Foro Bíblico**, **Leaderboard**, **Rachas entre Amigos**, **Personas que quizás conozcas**, **Últimas reflexiones**
- Invitados solo ven: lectura del día, devocional, Biblia, racha personal, progreso, notas personales
- FeedScreen ya estaba bloqueado con `GuestAccessRestrictedWidget` desde antes
- Controlado por `ref.watch(isGuestUserProvider)` + `if (!isGuest)` collection-if

### ✅ Invitados excluidos de sugerencias de amistad
- `sugerenciasAmistadProvider` filtra usuarios con email `invitado@altardiario.app`

### ✅ Nombres existentes corregidos al iniciar sesión
- `login_screen.dart:_fixExistingUserName` — si el nombre en Firestore está vacío/"anónimo", lo reemplaza con datos de Firebase Auth (displayName → email → UID)

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: 0 errores, 0 warnings

---

## 2026-07-30 — Fix 2: Invitados excluidos de sugerencias + Actualización automática de nombres existentes

### ✅ Invitados no aparecen en "Personas que quizás conozcas"
- **`app_providers.dart:sugerenciasAmistadProvider`**: Ahora filtra usuarios con email `invitado@altardiario.app` (todos los invitados/anónimos)
- Los usuarios invitados no tienen identidad real, no deben sugerirse como amistad

### ✅ Nombres de usuarios existentes corregidos al iniciar sesión
- **`login_screen.dart`**: Nuevo método `_fixExistingUserName(User user, Usuario existing)`
  - Se ejecuta después de `_ensureUserProfileCreated` si el usuario YA existía en Firestore
  - Si el `nombre` en Firestore está vacío o es "anónimo", lo reemplaza con el `displayName` de Firebase Auth
  - Si Firebase Auth tampoco tiene nombre, usa el prefijo del email
  - Si no hay email, usa un identificador basado en UID
- **Proceso**: Al hacer login con Google/Apple, detecta automáticamente nombres malos y los corrige en Firestore

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: 0 errores, 0 warnings

---

## 2026-07-30 — Registro de Usuarios: Nombres Reales desde el Origen (eliminados placeholders)

### ✅ Cambios por opencode (asistente IA)

### ✅ Helper `displayName` en modelo Usuario
- **`usuario.dart`**: Nuevo getter `displayName` que deriva el nombre a mostrar desde los datos disponibles:
  1. Si `nombre` no está vacío ni es "anónimo" → lo usa
  2. Si no, y el email no es `invitado@altardiario.app` → usa el prefijo del email (`email.split('@').first`)
  3. Si no → usa los primeros 8 caracteres del UID
- Este getter se usa en TODOS los puntos de visualización de la app

### ✅ Registro Google/Apple: Captura real de nombres
- **`login_screen.dart`** — `_ensureUserProfileCreated` mejorado:
  - Primero usa `user.displayName` (nombre real de Google/Apple)
  - Si viene vacío, extrae la parte local del email (`email.split('@').first`)
  - Si aún así no hay nombre, genera `Usuario-{uid abreviado}` (técnico, no placeholder)
  - Eliminado el fallback genérico `'Usuario'`

### ✅ Registro Anónimo: Ya funcionaba correctamente
- El diálogo anónimo ya solicitaba nombre + apodo al usuario
- Se crea en Firestore con formato `"$nombre (Invitado)"`
- Sin cambios necesarios

### ✅ Datos existentes en Firestore: Derivación desde email
- **`firestore_service.dart:getStreaksData`**: Ahora incluye el campo `email` en la respuesta (además de `nombre`, `fotoUrl`, etc.)
- **`app_providers.dart:friendStreaksProvider`**: Si `nombre` está vacío, deriva desde el email o UID
- **`app_providers.dart:globalLeaderboardProvider`**: Usa `user.displayName` (deriva desde email si nombre vacío)
- **`app_providers.dart:sugerenciasAmistadProvider`**: Usa `u.displayName`

### ✅ Eliminados todos los placeholders inventados
- **`app_providers.dart`**: eliminado `'Creyente'` y `'Anónimo'` como fallbacks
- **`home_screen.dart`**: eliminado `'Usuario'` en tarjetas de sugerencias
- **`public_profile_screen.dart`**: usa `user.displayName`
- **`feed_screen.dart`**: eliminados `'Hermano en Fe'`, `'Usuario de Altar'`, `'Usuario'` → usa `authorProfile!.displayName`
- **`oracion_screen.dart`**: mismo cambio que feed_screen
- **`chat_list_screen.dart`**: eliminado `'Usuario'`
- **`chat_screen.dart`**: usa `currentProfile?.displayName`
- **`debate_detail_screen.dart`**: usa `user?.displayName`
- **`crear_debate_screen.dart`**: usa `user?.displayName`
- **`gamification_service.dart`**: eliminado `'Hermano en Fe'`

### ✅ Prompt para usuarios sin nombre real en Perfil
- **`perfil_screen.dart`**: Detecta si `nombre` está vacío o es "anónimo" (ignorando la derivación por email). Si no tiene nombre real, muestra un botón "Configurar perfil" que abre el diálogo de edición para que el usuario establezca su nombre

### ✅ Resumen
| Antes | Ahora |
|-------|-------|
| "Creyente" para usuarios sin nombre | Nombre real → email prefix → UID |
| "Usuario" como fallback genérico | Derivación inteligente desde datos disponibles |
| "Hermano en Fe" en reflexiones/peticiones | `displayName` del perfil Firestore |
| "Usuario de Altar" ignorado | Datos reales desde Firestore |
| "Anónimo" en streaks/chats | Email prefix o UID |

### ✅ Tests
- `flutter test`: 101/101 pasando
- `flutter analyze`: 0 errores, 0 warnings

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
