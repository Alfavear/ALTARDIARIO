# AltarDiario Social Features - Implementation Status

## Phase 2: Social Core (COMPLETED ✅)

### Feed & Reflections
| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| Feed tiempo real | `FeedScreen` | `reflexionesStreamProvider` | `reflexionesStream()` | ✅ |
| Publicar reflexión | `PublicarReflexionScreen` | - | `publicarReflexion()` | ✅ |
| Like toggle | `FeedScreen` (_ReflexionCard) | `isAuthorProvider` | `toggleLike()` | ✅ |
| Reacciones emoji (❤️🙏🔥💡) | `FeedScreen` | - | `toggleReaction()` | ✅ |
| Comentarios (bottom sheet) | `FeedScreen` | `comentariosStreamProvider` | `comentariosStream()`, `publicarComentario()`, `toggleCommentLike()` | ✅ |
| Búsqueda texto + tags | `FeedScreen` | - | Local filter | ✅ |
| Tags auto-extraídos | `PublicarReflexionScreen` | - | Regex `#\w+` | ✅ |

### Profiles & Follow
| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| Perfil público | `PublicProfileScreen` | `otherUserProfileProvider` | `getUsuario()`, `getUserReflexiones()` | ✅ |
| Seguir/Dejar seguir | `FeedScreen`, `PublicProfileScreen` | `isFollowingProvider` | `toggleFollow()` | ✅ |
| Lista siguiendo | `FollowersScreen` (tab) | `siguiendoUsuariosProvider` | `getSiguiendo()` | ✅ |
| Lista seguidores | `FollowersScreen` (tab) | `seguidoresUsuariosProvider` | `getSeguidores()` | ✅ |
| Stats tappables | `PerfilScreen` | - | Navegación a `FollowersScreen` | ✅ |

### Friend Streaks (Leaderboard)
| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| Ranking rachas amigos | `AmigosRachasScreen` | `friendStreaksProvider` | `getStreaksData()` + `calcularRachaFromDates()` | ✅ |
| Medallas 🥇🥈🥉 top 3 | `AmigosRachasScreen` | - | Local sort | ✅ |
| Badge "ERES TÚ" | `AmigosRachasScreen` | - | Compara UID | ✅ |
| Colores por intensidad | `AmigosRachasScreen` | - | 3+ naranja, 7+ fuerte, 30+ rojo | ✅ |
| Card en Home | `HomeScreen` | - | Navega a `AmigosRachasScreen` | ✅ |

### Friend Suggestions
| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| 5 usuarios aleatorios | `HomeScreen` (horizontal) | `sugerenciasAmistadProvider` | `getAllUsuarios()` (excluye self + following) | ✅ |
| Tap → Perfil público | `HomeScreen` | - | `Navigator.push` | ✅ |

### Focus Mode
| Feature | Implementation | Status |
|---------|----------------|--------|
| Persistencia | `StorageService.getFocusMode()/setFocusMode()` | ✅ |
| Provider | `FocusModeNotifier` en `app_providers.dart` | ✅ |
| Cancela notificaciones | `NotificationService.cancelAll()` al activar | ✅ |
| Restaura recordatorio | `scheduleDailyReminder()` al desactivar | ✅ |
| PopScope back button | Bloquea si focusMode && !completed | ✅ |
| 🔒 en AppBar | `HomeScreen` AppBar | ✅ |
| SwitchListTile card | Sección "Modo Enfoque" en Home | ✅ |
| Bloqueo tabs | `_handleNavigate()` bloquea tabs 1-4 | ✅ |
| Diálogo opciones | "Seguir leyendo" / "Desactivar" | ✅ |

## Phase 3: Prayer Community (COMPLETED ✅)

| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| Peticiones de oración | `OracionScreen` | `peticionesStreamProvider` | `peticionesStream()` | ✅ |
| Publicar petición | `OracionScreen` (FAB) | - | `publicarPeticion()` | ✅ |
| Botón "Amén" (contador) | `OracionScreen` | - | `incrementarOraciones()` | ✅ |

## Phase 4: Profile & Sync (COMPLETED ✅)

| Feature | Screen | Provider | Service Method | Status |
|---------|--------|----------|----------------|--------|
| Perfil personal stats | `PerfilScreen` | `userProfileProvider` | `getUsuario()` + local streak | ✅ |
| Historial reflexiones | `PerfilScreen` | `userReflexionesProvider` | `userReflexionesStream()` | ✅ |
| Sincronización cloud | - | - | `syncProgress()` | ✅ |
| Recordatorio configurable | `PerfilScreen` (time picker) | - | `scheduleDailyReminder(hour, min)` | ✅ |
| Modo Demo offline | `LoginScreen` | `localUidProvider`, `effectiveUserUidProvider` | `signInLocal()` | ✅ |
| Firebase resilient | All services | - | `_available` guards + `.handleError()` | ✅ |

## Phase 1: Infrastructure (COMPLETED ✅)

| Feature | Implementation | Status |
|---------|----------------|--------|
| Riverpod setup | `app_providers.dart` centralizado | ✅ |
| Navegación global | `MainNavigationView` (IndexedStack 5 tabs) | ✅ |
| Firebase init | `main.dart` + `firebase_options.dart` | ✅ |
| Auth (Anon, Google, Apple) | `AuthService` + `LoginScreen` | ✅ |
| Bible reader multi-version | `BibleReaderScreen` + `BibleVersionsScreen` | ✅ |
| RV1960 web (bolls.life API) | `BibleService` static memory cache | ✅ |
| Local notifications | `NotificationService` + timezone | ✅ |

## Pending / Next Phases

### Phase 4 Remaining: Leaderboard & Debates
- [ ] Leaderboard comunitario (lecturas, racha, actividad)
- [ ] Foro debates bíblicos (por libro/capítulo, upvote/downvote)

### Phase 5: Polish
- [ ] Gamificación (badges, logros)
- [ ] Animaciones premium
- [ ] Push notifications (FCM)
- [ ] Tests para features sociales

## Key Files for Social Features
```
lib/presentation/screens/
  feed_screen.dart              # Feed principal + reacciones + comentarios + follow
  home_screen.dart              # Inicio + modo enfoque + rachas amigos + sugerencias
  public_profile_screen.dart    # Perfil público + follow button
  followers_screen.dart         # Siguiendo / Seguidores tabs
  amigos_rachas_screen.dart     # Leaderboard rachas
  oracion_screen.dart           # Peticiones de oración
  perfil_screen.dart            # Perfil personal + stats + config notificaciones
  publicar_reflexion_screen.dart

lib/data/services/firestore_service.dart
  # TODOS los métodos sociales: streams, writes, queries

lib/presentation/providers/app_providers.dart
  # TODOS los providers: reflexionesStreamProvider, userProfileProvider,
  # friendStreaksProvider, sugerenciasAmistadProvider, focusModeProvider,
  # isFollowingProvider, comentariosStreamProvider, etc.

lib/data/models/
  reflexion.dart, comment.dart, usuario.dart, peticion_oracion.dart, message.dart, debate.dart