## 2026-06-06 (continuación — Modo Demo, RV1960 en web, Firebase resiliente)

### ✅ Modo Demo offline
- **AuthService tolerante a Firebase caído**: `_initAuth()` con try/catch, `signInLocal()` genera uid persistido en SharedPreferences.
- **FirestoreService tolerante**: mismo patrón, todos los métodos no-op cuando `!_available`.
- **localUidProvider y effectiveUserUidProvider**: en `app_providers.dart` para unificar Firebase uid y local uid. Todas las pantallas migradas a `effectiveUserUidProvider`.
- **SplashScreen**: chequea Firebase auth stream y local uid desde SharedPreferences.
- **LoginScreen**: botón "MODO DEMO (sin conexión)" genera uid local y navega directamente a `MainNavigationView`.

### ✅ RV1960 como versión por defecto
- **availableVersions** incluye RV1960 como primera opción tanto en web como en nativo.
- **ensureDefaultDownloaded()**: en nativo descarga desde bolls.life a SQLite con barra de progreso; en web **descarga desde bolls.life API a memoria estática** (`_memoryVerses` static) con progreso en lotes de 1000.
- **Cache estático**: `_memoryVerses`, `_memoryHighlights`, `_memoryNotes` y `_memoryMode` se vuelven static para que persistan entre instancias de `BibleService` en web.
- **Fix**: `_autoDownloadDefault()` ya no retorna temprano en web — ahora descarga RV1960 vía API y luego carga el texto. Se elimina el `kIsWeb` return que causaba pantalla de carga infinita.
- **BibleReaderScreen**: muestra barra de progreso "Descargando Reina-Valera 1960… X de Y versículos" tanto en web como en nativo.

### ✅ Recordatorio diario configurable
- **PerfilScreen**: selector de hora con `showTimePicker`, persiste en SharedPreferences (`notification_hour`/`notification_minute`).
- **NotificationService.scheduleDailyReminder()**: ahora acepta `hour` y `minute` como parámetros.
- **main.dart**: pasa la hora guardada al programar la notificación.

### ✅ Firebase resiliente y errores
- **FirestoreService**: todos los métodos (`reflexionesStream`, `getUserReflexiones`, `peticionesStream`, etc.) protegidos con `if (!_available) return ...`. Streams usan `.handleError()` para devolver lista vacía en vez de crashear.
- **PerfilScreen**: mensaje de error amigable "No se pudieron cargar tus reflexiones. Verifica que Firebase Console tenga los índices necesarios."

### ✅ Firebase Console configurado
- Authentication: Anónimo habilitado (funcionando en Chrome).
- Firestore Database: creada en modo test.
- **Índice compuesto creado** para `reflexiones WHERE userId = X ORDER BY fecha DESC` (necesario para "Mis Reflexiones").
- Google Sign-In y Apple Sign-In: providers habilitados en Firebase Console.

### ✅ Commits realizados (push a origin/main)
- `fix: web-safe Bible (RV1909 only) and graceful Firestore error handling`
- `fix: Bible reader colgaba en web por initState sin llamar a _loadText`
- `feat: RV1960 en web via bolls.life API con progreso`

### ✅ Seguridad agregada
- **firestore.rules**: reglas con validación (`request.auth != null`, dueño del documento, participantes del chat).
- **firestore.indexes.json**: índice compuesto para `reflexiones (userId ASC, fecha DESC)`.
- **.gitignore**: agregado `.env` para futuras claves de API.
- **.env.example**: template para variables de entorno.

### ✅ Branch Protection (GitHub) — activada
- Require pull request reviews (1 approval)
- Include administrators
- No force pushes, no deletions
- Se usó `gh api` para configurarlo vía API.

### ⏳ Pendiente: Reglas en Firebase Console
Ir a **Firebase Console → Firestore → Rules** y pegar el contenido de `firestore.rules` (o ejecutar `firebase deploy --only firestore:rules` si tienen Firebase CLI instalado).

### ⏳ Pendiente / Próximos pasos
- **Google Sign-In en web**: requiere configurar OAuth Client ID en Firebase Console → Authentication → Google → Web SDK configuration (URI de redirección). Probar en Chrome.
- **Sign in with Apple**: requiere app iOS/macOS registrada; ejecutar `flutterfire configure --project=altardiario-ec25f --platforms=ios,macos`.
- **BibleVersionsScreen**: gestor de versiones descargadas (buscar, descargar, eliminar). Funciona en nativo con sqflite; en web mostrar mensaje "no disponible".
- **Rachas entre amigos**: requiere Firestore estable; pospuesto.
- **Windows `flutter run`**: requiere Modo Desarrollador (symlinks).
- **Tests**: agregar tests para AuthService (local), FirestoreService (resiliencia), NotificationService (hora configurable).

## 2026-05-27 (Fase 4: Perfil y Sincronización)

- **Desarrollo de PerfilScreen**: Se implementa la vista de perfil con estadísticas reales (rachas, lecturas) y el historial de reflexiones del usuario.
- **Sincronización Cloud**: Se añade `syncProgress` en `FirestoreService` para respaldar el progreso local en la base de datos de Firebase.
- **Consolidación de Identidad**: Integración de `userReflexionesProvider` para mostrar contenido personalizado.
- **Siguiente paso**: Preparar el despliegue y pulir detalles de UI/UX (Fase 5).

## 2026-05-27 (User Provider y Fase 3: Oración)

- **Perfil en Tiempo Real**: Implementación de `userProfileProvider` para gestionar la identidad y relaciones del usuario (siguiendo/seguidores).
- **Comunidad de Oración**: Finalización de la **Fase 3** con la creación de `OracionScreen`.
- **Interacción de Apoyo**: Implementación de la lógica "Amén" para incrementar el contador de oraciones en peticiones compartidas.
- **Siguiente paso**: Avanzar a la **Fase 4** implementando la pantalla de Perfil completa con estadísticas y sincronización de progreso.

## 2026-05-27 (Interacción Social Directa)

- **Seguimiento de Usuarios**: Se añade botón de "Seguir" en `FeedScreen` vinculado a `toggleFollow`.
- **Chat Privado**: Implementación de `ChatScreen` con suscripción en tiempo real a mensajes.
- **Navegación**: Se conecta el feed con el chat privado mediante una lógica de `chatId` compartido.
- **UI del Feed**: Mejora visual en la tarjeta de reflexión incluyendo el avatar del autor.
- **Siguiente paso**: Implementar la **Fase 3** (Peticiones de Oración) y la sincronización de perfiles.

## 2026-05-27 (Expansión Social: Seguidores y Chat)

- **Nuevos Requerimientos**: Se decide añadir un sistema de seguidores y mensajería interna.
- **Modelado de Datos**: Creación de los modelos `Usuario` (con listas de siguiendo/seguidores) y `Message`.
- **Lógica de Red**: Implementación de `toggleFollow` y gestión de chats en `FirestoreService`.
- **Infraestructura de Chat**: Configuración de `messagesStreamProvider` para suscripción en tiempo real a conversaciones.
- **Siguiente paso**: Diseñar la interfaz de la bandeja de entrada y la vista de chat privado.

## 2026-05-27 (Interacciones y Preparación de Oración)

- **Interactividad en Feed**: Se implementa `RefreshIndicator` para actualización manual y se habilita el botón de "Like" conectándolo con Firestore.
- **Refactorización UI**: `_ReflexionCard` migrado a `ConsumerWidget` para acceso directo a proveedores de estado.
- **Inicio Fase 3**: Creación del modelo `PeticionOracion` en `lib/data/models/`.
- **Siguiente paso**: Implementar `OracionScreen` y los métodos de Firestore para gestionar peticiones de oración.

## 2026-05-27 (Navegación Global)

- **Implementación de MainNavigationView**: Se crea el contenedor principal con `BottomNavigationBar` para alternar entre Calendario, Feed, Oración y Perfil.
- **Uso de IndexedStack**: Se utiliza para mantener el estado de las pantallas al navegar (por ejemplo, que el calendario no pierda el scroll al ir al feed).
- **Placeholders**: Se crean las estructuras base para `OracionScreen` y `PerfilScreen`.
- **Siguiente paso**: Iniciar la **Fase 2** con las interacciones del Feed (Likes y comentarios).

## 2026-05-27 (Planificación Estratégica)

- **Definición de RoadMap**: Se establece un plan de 5 fases para transformar la app en red social.
- **Integración de Flujo Devocional**: Se modifica `CalendarioView` para redirigir automáticamente a `PublicarReflexionScreen` tras marcar una lectura.
- **Estructuración de Tareas**: Priorización de navegación global y sistema de oraciones para las próximas sesiones.
- **Siguiente paso**: Crear el `MainNavigationView` que servirá de contenedor para todas las nuevas secciones (Feed, Oración, Perfil).

## 2026-05-27 (continuación)

- **Implementación de Pantallas Sociales**: Se crean `PublicarReflexionScreen.dart` y `FeedScreen.dart`.
- **Integración en Tiempo Real**: Se utiliza `reflexionesStreamProvider` de Riverpod para actualizar el feed automáticamente cuando alguien publica.
- **Lógica de Publicación**: Conectado el formulario de reflexiones con `FirestoreService` y manejo de estados de carga.
- **Siguiente paso**: Integrar estas pantallas en la navegación principal y comenzar con el sistema de **Peticiones de Oración**.

## 2026-05-27

- **Migración a Riverpod**: Se implementan `app_providers.dart` para gestionar `StorageService`, `AuthService` y `FirestoreService`.
- **Refactorización UI**: Se limpia `CalendarioView` eliminando la inyección manual de dependencias en favor de `ConsumerStatefulWidget`.
- **Backend Social**: Se crea `FirestoreService` y el modelo `Reflexion` para soportar el feed devocional.
- **Siguiente paso**: Implementar la lógica de publicación en `PublicarReflexionScreen` y mostrar los datos en tiempo real en el `FeedScreen`.

## 2026-05-26 (continuación 3)

- Se define la arquitectura tecnológica escalable:
  - Flutter + Riverpod para frontend y estado global.
  - Firebase (Firestore, Auth, Storage, Messaging, Functions) para backend, base de datos y notificaciones.
  - Se agregan dependencias de Firebase y Riverpod al pubspec.yaml.
- Siguiente paso: Inicializar Firebase en el proyecto y crear providers base con Riverpod.
# Bitácora de Desarrollo — AltarDiario Red Social

Este archivo documenta los avances, decisiones y tareas realizadas en la evolución de la app AltarDiario hacia una red social devocional.


## 2026-05-26

## 2026-05-26 (continuación)

- Se crean los modelos base: Usuario, Reflexion y PeticionOracion en lib/data/models/.
- Se implementa AuthService para autenticación con Firebase Auth (inicio anónimo y base para Google/email).
- Se crea la pantalla base FeedScreen en lib/presentation/screens/ para mostrar el feed devocional.
- Siguiente paso: Integrar el feed con backend y estado global (Provider/Riverpod), y crear pantallas de publicación de reflexión y perfil de usuario.

- **Inicio de transformación**: Se decide evolucionar la app de lectura bíblica diaria a una red social devocional.
- **Nuevas funcionalidades propuestas:**
  - Publicar reflexiones tras cada lectura.
  - Feed devocional para ver reflexiones de otros usuarios.
  - Compañeros de oración: agregar amigos, enviar/recibir peticiones de oración.
  - Notificaciones sociales (comentarios, reacciones, peticiones).
  - Perfil de usuario con estadísticas y reflexiones.
  - Persistencia y sincronización en la nube (Firebase/Supabase sugerido).
- **Siguiente paso:**
  - Proponer arquitectura y estructura de archivos para la nueva versión social.

---

> Agrega aquí cada avance, decisión o cambio relevante para mantener el historial del proyecto actualizado.

## 2026-05-26 (continuación 2)

- Se crean pantallas base para publicar reflexión (PublicarReflexionScreen) y perfil de usuario (PerfilScreen) en lib/presentation/screens/.
- Siguiente paso: Integrar el feed y reflexiones con backend y estado global, y conectar la publicación de reflexiones al feed.
