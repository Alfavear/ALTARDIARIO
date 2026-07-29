# Arquitectura Social — AltarDiario

> Estado real del proyecto al 2026-07-28. Consultar `SYSTEM.md` para referencia técnica completa.

---

## 1. Estructura de Carpetas Implementada

```
lib/
  main.dart                          # Inicialización Firebase + ProviderScope
  firebase_options.dart
  core/
    theme/
      app_theme.dart                 # Colores, gradientes, tema Material
    services/
      notification_service.dart      # Notificaciones locales (flutter_local_notifications)
      community_policy_service.dart  # Normas de la Comunidad (5 reglas)
      gamification_service.dart      # Badges, XP, niveles (16 insignias definidas)
  data/
    models/
      badge.dart                     # Badge: id, name, icon, rarity, criteria, points
      bible_models.dart              # BibleVersion, BibleVerse, BiblePassage, BibleHighlight, BibleNote
      comment.dart                   # Comment: reflexionId, userId, texto, likes, likedBy
      debate.dart                    # Debate: titulo, contenido, libroId, votos
      debate_reply.dart              # DebateReply: contenido, votos, votantes
      lectura_dia.dart               # LecturaDia: plan de lectura anual
      message.dart                   # Message: senderId, texto, timestamp
      note.dart                      # Note: título, contenido, local
      peticion_oracion.dart          # PeticionOracion: texto, oracionesCount, category
      reflexion.dart                 # Reflexion: texto, pasajeDia, tags, likedBy, reactions
      usuario.dart                   # Usuario: nombre, bio, siguiendo, badges, totalPuntos, nivel
    services/
      auth_service.dart              # Firebase Auth: anónimo, Google, Apple
      bible_service.dart             # Biblias: SQLite (nativo), memoria (web)
      bible_download_service.dart    # Descarga de versiones desde bolls.life API
      firestore_service.dart         # CRUD Firestore completo
      storage_service.dart           # SharedPreferences: rachas, notas, modo enfoque, notificaciones
  presentation/
    providers/
      app_providers.dart             # Todos los Riverpod providers (centralizado)
    widgets/
      guest_access_restricted_widget.dart  # Pantalla bloqueo invitados con CTA registro
    screens/
      splash_screen.dart
      login_screen.dart              # Google | Apple | Iniciar como invitado
      main_navigation_view.dart      # IndexedStack 5 tabs
      home_screen.dart               # Inicio: versículo del día, stats, foro, rachas, sugerencias
      calendario_view.dart           # Plan anual de lectura
      feed_screen.dart               # Altar Comunitario (restringido para invitados)
      oracion_screen.dart            # Peticiones de oración (bloqueado para invitados)
      perfil_screen.dart             # Perfil: estadísticas, insignias, edición, configuración
      bible_reader_screen.dart       # Lector: temas, swipe, notas, highlights
      bible_versions_screen.dart     # Gestión de versiones descargadas
      publicar_reflexion_screen.dart # Publicar reflexión con política de comunidad
      public_profile_screen.dart     # Perfil público de otro usuario
      followers_screen.dart          # Listas siguiendo / seguidores
      notes_screen.dart              # Notas personales
      note_editor_screen.dart        # Editor de notas con markdown básico
      foro_screen.dart               # Foro bíblico
      crear_debate_screen.dart       # Crear debate con selector de libro
      debate_detail_screen.dart      # Hilo de debate con respuestas y votos
      amigos_rachas_screen.dart      # Ranking de rachas entre amigos
      bible_compare_screen.dart      # Comparador de versiones en paralelo
      chat_list_screen.dart          # (no activo)
      chat_screen.dart               # (no activo)
```

---

## 2. Modelos Clave (Firestore)

| Colección | Campos principales |
|-----------|-------------------|
| `usuarios` | nombre, email, fotoUrl, bio, siguiendo[], seguidores[], progresoLectura[], maxStreak, badges[], totalPuntos, nivel |
| `reflexiones` | userId, userName, texto, pasajeDia, tags[], likedBy[], reactions{}, commentCount |
| `reflexiones/{id}/comentarios` | userId, texto, likes, likedBy[] |
| `peticiones` | userId, userName, texto, oracionesCount, category |
| `debates` | userId, titulo, contenido, libroId, votos, votantes{} |
| `debates/{id}/respuestas` | userId, contenido, votos, votantes{} |

---

## 3. Seguridad por Tipo de Usuario

| Funcionalidad | Invitado | Registrado |
|--------------|----------|------------|
| Ver feed de reflexiones | ✅ | ✅ |
| Publicar reflexión | ❌ (banner CTA) | ✅ |
| Like / Reacción / Comentar | ❌ | ✅ |
| Seguir usuario | ❌ | ✅ |
| Ver peticiones de oración | ❌ (pantalla bloqueada) | ✅ |
| Publicar petición | ❌ | ✅ |
| Perfil personal | ✅ (limitado) | ✅ (completo) |
| Leer Biblia | ✅ | ✅ |
| Foro bíblico | ✅ (solo ver) | ✅ |
| Gamificación (XP / badges) | ❌ | ✅ |

---

## 4. Flujo de Navegación

```
SplashScreen
  └→ LoginScreen (Google | Apple | Invitado)
       └→ MainNavigationView (IndexedStack)
            ├─ [0] HomeScreen
            │    ├→ BibleReaderScreen → BibleVersionsScreen
            │    ├→ NotesScreen → NoteEditorScreen
            │    ├→ ForoScreen → CrearDebateScreen / DebateDetailScreen
            │    └→ AmigosRachasScreen
            ├─ [1] CalendarioView → PublicarReflexionScreen
            ├─ [2] FeedScreen → PublicarReflexionScreen / PublicProfileScreen
            ├─ [3] OracionScreen (bloqueado si invitado)
            └─ [4] PerfilScreen → FollowersScreen / PublicProfileScreen
```

---

## 5. Gamificación

- **16 Insignias** en 5 categorías: Rachas, Lectura, Comunidad, Oración, Especiales
- **10 Niveles** de XP (Semilla → Maestro Espiritual)
- **Evaluación automática** al publicar reflexiones y peticiones
- **Notificación local** al desbloquear una insignia
- **Diálogo de celebración** (`showBadgeUnlockedDialog`)
- **UI en PerfilScreen**: barra de XP, nivel, colección completa de badges

---

## 6. Backend Firebase

| Servicio | Uso |
|----------|-----|
| **Firebase Auth** | Anónimo, Google, Apple |
| **Firestore** | Datos sociales (reflexiones, peticiones, debates, usuarios, comentarios) |
| **Firebase Storage** | Fotos de perfil |
| **Firebase Messaging (FCM)** | Notificaciones push |

- **Project ID**: `altardiario-ec25f`
- **Reglas**: `firestore.rules`
- **Índices**: `firestore.indexes.json`

---

## 7. Estado de Funcionalidades

| Feature | Estado |
|---------|--------|
| Lectura Bíblica + Swipe + Temas | ✅ Completo |
| Comparador de Versiones | ✅ Completo |
| Marcadores / Highlights / Notas | ✅ Completo |
| Descarga de versiones | ✅ Completo |
| Feed de Reflexiones (Altar Comunitario) | ✅ Completo |
| Like / Reacciones / Comentarios | ✅ Completo |
| Peticiones de Oración | ✅ Completo |
| Perfiles Públicos + Follow | ✅ Completo |
| Foro Bíblico (Debates) | ✅ Completo |
| Ranking Rachas Amigos | ✅ Completo |
| Gamificación (16 badges + XP) | ✅ Completo |
| Panel de Perfil + Configuración | ✅ Completo |
| Política de Comunidad | ✅ Completo |
| Seguridad Invitados | ✅ Completo |
| Ícono APK Personalizado | ✅ Completo |
| Notificaciones Push (FCM) | ✅ Completo |
| Modo Enfoque | ✅ Completo |
| Sugerencias de Amistad | ✅ Completo |
| Chat entre usuarios | 🔄 Implementado, no activo en UI |
| Modo Demo offline | ❌ Eliminado |

---

> Esta arquitectura refleja el estado productivo de AltarDiario como red social devocional completa, lista para distribución en Google Play Store y App Store.
