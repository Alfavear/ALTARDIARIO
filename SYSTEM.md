# altarDiario — Documentación del Sistema

## Stack Tecnológico

| Componente | Tecnología |
|---|---|
| **Framework** | Flutter 3.x (SDK ^3.5.0) |
| **Lenguaje** | Dart 3.x |
| **Estado** | Riverpod 3.x (`flutter_riverpod`) |
| **Backend** | Firebase (Auth, Firestore, Storage, Messaging) |
| **Auth** | Anónimo, Google, Apple |
| **Almacenamiento local** | `shared_preferences` + SQLite (biblias) |
| **Notificaciones** | `flutter_local_notifications` + `timezone` |
| **Navegación** | Manual (`Navigator.push` + `IndexedStack`) |

---

## Estructura del Proyecto

```
lib/
  main.dart                          # Punto de entrada, inicialización Firebase
  firebase_options.dart              # Configuración Firebase auto-generada
  core/
    theme/app_theme.dart             # Tema, colores, gradientes, sombras
    services/notification_service.dart  # Notificaciones locales
  data/
    models/
      bible_models.dart              # BibleVersion, BibleVerse, BiblePassage, BibleHighlight, BibleNote
      comment.dart                   # Comment (comentarios en reflexiones)
      debate.dart                    # Debate (foro bíblico)
      debate_reply.dart              # DebateReply (respuestas en foro)
      lectura_dia.dart               # LecturaDia (plan diario)
      message.dart                   # Message (chats)
      note.dart                      # Note (notas personales)
      peticion_oracion.dart          # PeticionOracion
      reflexion.dart                 # Reflexion (publicaciones)
      usuario.dart                   # Usuario (perfil)
    services/
      auth_service.dart              # Auth: anónimo, Google, Apple, demo local
      bible_service.dart             # Carga y gestión de Biblias (SQLite + memoria web)
      firestore_service.dart         # CRUD Firestore: reflexiones, usuarios, comentarios, debates, streaks, chats
      storage_service.dart           # SharedPreferences: progreso, rachas, modo enfoque, notas, notificaciones
  presentation/
    providers/
      app_providers.dart             # Todos los providers Riverpod
    screens/
      splash_screen.dart             # Pantalla de carga inicial
      login_screen.dart              # Login: Google, Apple, Demo
      main_navigation_view.dart      # BottomNavigationBar + IndexedStack (5 tabs)
      home_screen.dart               # Tab 0: Inicio, versículo, stats, foro, rachas, modo enfoque, sugerencias
      calendario_view.dart           # Tab 1: Calendario de lectura anual
      feed_screen.dart               # Tab 2: Altar Comunitario (feed de reflexiones)
      oracion_screen.dart            # Tab 3: Peticiones de oración
      perfil_screen.dart             # Tab 4: Perfil personal
      bible_reader_screen.dart       # Lector bíblico con múltiples versiones
      bible_versions_screen.dart     # Gestión de versiones bíblicas
      notes_screen.dart              # Notas personales
      note_editor_screen.dart        # Editor de notas
      publicar_reflexion_screen.dart # Publicar reflexión
      public_profile_screen.dart     # Perfil público de otro usuario
      followers_screen.dart          # Siguiendo / Seguidores
      chat_list_screen.dart          # Lista de chats (no utilizado actualmente)
      chat_screen.dart               # Chat individual (no utilizado actualmente)
      foro_screen.dart               # Foro Bíblico (lista de debates)
      crear_debate_screen.dart       # Crear nuevo debate
      debate_detail_screen.dart      # Hilo de debate con respuestas
      amigos_rachas_screen.dart      # Ranking de rachas entre amigos
      anual_view.dart                # Vista anual (no utilizado)
    widgets/
      # Widgets compartidos (vacíos actualmente)
test/
  models/                            # Tests unitarios de modelos
  screens/                           # Tests widget
  widget_test.dart                   # Test de integración
```

---

## Pantallas y Navegación

### Flujo principal

```
SplashScreen → LoginScreen → MainNavigationView (IndexedStack)
                                 ├─ [0] HomeScreen
                                 ├─ [1] CalendarioView
                                 ├─ [2] FeedScreen (Altar Comunitario)
                                 ├─ [3] OracionScreen
                                 └─ [4] PerfilScreen
```

### Pantallas secundarias (push)

| Pantalla | Desde | Back Button |
|---|---|---|
| BibleReaderScreen | HomeScreen, CalendarioView | ✅ AppBar leading |
| BibleVersionsScreen | BibleReaderScreen | ✅ AppBar leading |
| NotesScreen | HomeScreen, BibleReaderScreen | ✅ AppBar leading |
| NoteEditorScreen | NotesScreen | ✅ AppBar leading |
| PublicarReflexionScreen | CalendarioView, FeedScreen | ✅ AppBar leading |
| PublicProfileScreen | FeedScreen, HomeScreen, AmigosRachasScreen | ✅ AppBar leading |
| FollowersScreen | PerfilScreen, PublicProfileScreen | ✅ AppBar leading |
| ForoScreen | HomeScreen | ✅ AppBar leading |
| CrearDebateScreen | ForoScreen | ✅ AppBar leading |
| DebateDetailScreen | ForoScreen | ✅ AppBar leading |
| AmigosRachasScreen | HomeScreen | ✅ AppBar leading |

---

## Providers (Riverpod)

| Provider | Tipo | Descripción |
|---|---|---|
| `storageProvider` | `Provider<StorageService>` | Almacenamiento local (inyectado en main) |
| `authServiceProvider` | `Provider<AuthService>` | Autenticación Firebase |
| `authStateProvider` | `StreamProvider<User?>` | Stream del usuario Firebase Auth |
| `localUidProvider` | `NotifierProvider` | UID local para modo demo |
| `effectiveUserUidProvider` | `Provider<String?>` | UID efectivo (Firebase > local) |
| `firestoreServiceProvider` | `Provider<FirestoreService>` | Servicio Firestore |
| `userProfileProvider` | `StreamProvider<Usuario?>` | Perfil del usuario actual |
| `reflexionesStreamProvider` | `StreamProvider<List<Reflexion>>` | Feed de reflexiones |
| `userReflexionesProvider` | `StreamProvider.family<List<Reflexion>, String>` | Reflexiones por usuario |
| `peticionesStreamProvider` | `StreamProvider<List<PeticionOracion>>` | Peticiones de oración |
| `messagesStreamProvider` | `StreamProvider.family<List<Message>, String>` | Mensajes de chat |
| `isAuthorProvider` | `Provider.family<bool, String>` | ¿Es el autor? |
| `chatListProvider` | `StreamProvider.family<List<Map>, String>` | Lista de chats |
| `otherUserProfileProvider` | `StreamProvider.family<Usuario?, String>` | Perfil de otro usuario |
| `friendStreaksProvider` | `FutureProvider<List<FriendStreak>>` | Rachas de amigos |
| `isFollowingProvider` | `FutureProvider.family<bool, String>` | ¿Sigue a este usuario? |
| `comentariosStreamProvider` | `StreamProvider.family<List<Comment>, String>` | Comentarios de reflexión |
| `siguiendoUsuariosProvider` | `FutureProvider.family<List<Usuario>, String>` | Usuarios que sigo |
| `seguidoresUsuariosProvider` | `FutureProvider.family<List<Usuario>, String>` | Mis seguidores |
| `debatesStreamProvider` | `StreamProvider.family<List<Debate>, String?>` | Debates del foro |
| `debateRepliesStreamProvider` | `StreamProvider.family<List<DebateReply>, String>` | Respuestas de debate |
| `sugerenciasAmistadProvider` | `FutureProvider<List<Usuario>>` | Sugerencias de amistad |
| `focusModeProvider` | `NotifierProvider<FocusModeNotifier, bool>` | Modo Enfoque |

---

## Funcionalidades

### 1. Lectura Bíblica Diaria
- Plan anual de lectura (JSON en assets)
- Múltiples versiones: RV1960, RV1909, LBLA, RVC, DHH, NTV, NVI, PDT, BTX, RVR, TLA
- Descarga automática de RV1960 desde bolls.life API
- Marcadores, highlights, notas personales
- Progreso y racha (streak) local

### 2. Reflexiones y Feed Comunitario
- Publicar reflexión después de cada lectura
- Feed "Altar Comunitario" con todas las reflexiones
- Tags extraídos automáticamente del texto
- Búsqueda por texto y filtro por tags
- Like en reflexiones (toggle)
- Reacciones con emojis (❤️🙏🔥💡)
- Comentarios en tiempo real con likes

### 3. Perfiles y Follow
- Perfil personal con estadísticas (racha, lecturas, progresso)
- Perfil público de otros usuarios (avatar, bio, reflexiones, reacciones)
- Seguir / Dejar de seguir
- Listas de siguiendo y seguidores

### 4. Rachas entre Amigos
- Ranking de rachas con tus amigos
- Medallas 🥇🥈🥉 para top 3
- Color por intensidad de racha
- Badge "ERES TÚ" para tu posición

### 5. Foro Bíblico
- Debates por libro de la Biblia
- Crear nuevo debate con selector de libro
- Respuestas en hilo con votos (upvote/downvote)
- Búsqueda de debates

### 6. Sugerencias de Amistad
- Muestra 5 usuarios aleatorios que no sigues
- Tarjetas horizontales en HomeScreen
- Tappable para ver perfil

### 7. Modo Enfoque
- Bloquea navegación entre tabs si no has completado la lectura del día
- Cancela notificaciones push al activarse
- PopScope intercepta botón de retroceso
- Diálogo de advertencia: "Seguir leyendo" o "Desactivar"
- 🔒 en AppBar cuando está activo
- Persiste en SharedPreferences

### 8. Peticiones de Oración
- Publicar y ver peticiones de la comunidad
- Botón "Amén" para apoyar

### 9. Notas Personales
- Crear, editar, eliminar notas
- Persistencia local en SharedPreferences

### 10. Autenticación
- Firebase Auth (anónimo, Google, Apple)
- Modo Demo offline (sin Firebase)
- Tolerante a Firebase caído

### 11. Notificaciones
- Recordatorio diario configurable
- Hora configurable desde Perfil

---

## Firestore — Colecciones y Estructura

### `usuarios`
```
{userId}
  ├── nombre: String
  ├── email: String?
  ├── fotoUrl: String
  ├── bio: String
  ├── fechaCreacion: Timestamp
  ├── siguiendo: String[] (UIDs)
  ├── seguidores: String[] (UIDs)
  ├── progresoLectura: String[] (fechas "yyyy-MM-dd")
  ├── maxStreak: int
  ├── fcmToken: String?
  └── ultimaLectura: Timestamp?
```

### `reflexiones`
```
{reflexionId}
  ├── userId: String
  ├── userName: String
  ├── userFotoUrl: String
  ├── texto: String
  ├── pasajeDia: String
  ├── fecha: Timestamp
  ├── tags: String[]
  ├── likedBy: String[] (UIDs)
  ├── commentCount: int
  └── reactions: Map<String, String> (userId → emoji)
```

### `reflexiones/{id}/comentarios`
```
{commentId}
  ├── reflexionId: String
  ├── userId: String
  ├── userName: String
  ├── userFotoUrl: String
  ├── texto: String
  ├── fecha: Timestamp
  ├── likes: int
  └── likedBy: String[] (UIDs)
```

### `peticiones`
```
{peticionId}
  ├── userId: String
  ├── userName: String
  ├── texto: String
  ├── fecha: Timestamp
  ├── oracionesCount: int
  └── category: String?
```

### `debates`
```
{debateId}
  ├── userId: String
  ├── userName: String
  ├── titulo: String
  ├── contenido: String
  ├── libroId: String?
  ├── libroNombre: String?
  ├── fecha: Timestamp
  ├── votos: int
  ├── replyCount: int
  └── votantes: Map<String, int> (userId → 1 | -1)
```

### `debates/{id}/respuestas`
```
{replyId}
  ├── userId: String
  ├── userName: String
  ├── contenido: String
  ├── fecha: Timestamp
  ├── votos: int
  └── votantes: Map<String, int>
```

### `chats`
```
{chatId}
  ├── participantIds: String[]
  ├── participantNames: Map<String, String>
  ├── lastMessage: String
  ├── lastSenderId: String
  └── lastUpdate: Timestamp
```

### `chats/{id}/messages`
```
{messageId}
  ├── senderId: String
  ├── texto: String
  └── timestamp: Timestamp
```

---

## Google Sign-In — Configuración Requerida

### Web (Chrome)
1. Firebase Console → Authentication → Google → Web SDK configuration
2. Agregar URI de redirección: `https://altardiario-ec25f.firebaseapp.com/__/auth/handler`
3. En Google Cloud Console → Credentials, verificar OAuth Client ID

### Android (APK)
1. Firebase Console → Project Settings → Android apps
2. Agregar SHA-1 y SHA-256 fingerprints de tu keystore:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
3. Para release: usar el SHA de tu keystore de release

### Solución temporal para pruebas
Usar **Modo Demo** desde la pantalla de Login — funciona sin configuración de Google.

---

## Comandos Útiles

```bash
flutter run -d chrome              # Probar en Chrome
flutter build web --release        # Build production web
flutter analyze                    # Análisis estático
flutter test                       # Ejecutar tests
flutter build apk --release        # Build Android
flutter build ios --release        # Build iOS
```

---

## Convenciones de Código

- Archivos: `snake_case`
- Clases: `PascalCase`
- Métodos/variables: `camelCase`
- Providers: camelCase + `Provider` suffix
- Modelos de dominio: español (`usuario`, `peticion_oracion`)
- Modelos técnicos: inglés (`BibleVerse`, `StorageService`)
- Campos `final`, prefieren `const`
- Null safety con `??` y defaults, nunca `as`
- Firebase: factories `fromFirestore`, `toMap()` retorna `Map<String, dynamic>`
