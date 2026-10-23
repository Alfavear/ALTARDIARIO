# Estado del carril B (otra sesión)

> Lo escribe **solo** el carril B. La orquestadora lo lee con:
> `git fetch origin ops/estado && git show origin/ops/estado:roadmap/ESTADO-B.md`
>
> Formato: una línea por tarea terminada + la tarea en curso + los bloqueos.
> Sin esto, la orquestadora no sabe en qué estás ni qué te toca.

## Tarea en curso

- **id**: B17
- **qué**: T-020 paginación por cursor en comentarios, debates y chats
- **rama**: — (a crear sobre origin/main)
- **PR**: —

## Terminado (empieza por la más reciente)

| fecha | tarea | rama / PR | verificación | qué cambió |
|---|---|---|---|---|
| 2026-10-22 | B16 markAllNotificationsAsRead sin batch vacío (T-017) | `fix/lane-b-16-notificaciones-batch` → PR #45 | 132/132 Dart, format+analyze limpios | Retorna early si no hay notificaciones sin leer, evitando batch vacío |
| 2026-10-22 | B15 Tests FirestoreService (T-005) | `fix/lane-b-15-tests-firestore-service` → PR #43 | 140/140 Dart, format+analyze limpios | Tests para toggleLike, toggleReaction, toggleFollow, apoyarPeticion |
| 2026-10-22 | B12 Reportar peticiones de oración (T-025) | `fix/lane-b-12-reportar-peticiones-debates` → PR #42 | 127/127 Dart, format+analyze limpios | Botón 'Reportar' en _PeticionCard (oracion_screen) usando ReportContentDialog reutilizable, targetType='peticion' |
| 2026-10-22 | B11 Índice compuesto chats (T-038) | `fix/lane-b-11-chats-indice` → PR #39 | 127/127 Dart, format+analyze limpios | Índice compuesto `participantIds` + `lastUpdate` en `firestore.indexes.json` para colección `chats` |
| 2026-10-22 | B10 Reportar reflexiones y comentarios (T-024) | `fix/lane-b-10-reportar-reflexiones` → PR #38 | 127/127 Dart, format+analyze limpios | `reportarContenido` en FirestoreService; `ReportContentDialog` reutilizable; botones 'Reportar' en _ReflexionCard y _CommentTile |
| 2026-10-22 | B9 Filtrar bloqueos en chats, notificaciones + UI desbloqueo (T-023) | `fix/lane-b-09-filtrar-chats-notif` → PR #36 | 123/123 Dart, 34/34 reglas, format+analyze limpios | getUserChatsFiltrados, notificationsStreamFiltrado, providers filtrados, _showBloqueadosDialog con desbloquear, getUsuariosBloqueados/desbloquearUsuario |
| 2026-10-21 | B8 Filtrar usuarios bloqueados en proveedores sociales (T-022) | `fix/lane-b-08-filtrar-bloqueados` → PR #33 | 123/123 Dart, format+analyze limpios | usuariosBloqueadosProvider; otherUserProfileProvider retorna null si bloqueado; friendStreaksProvider, sugerenciasAmistadProvider, globalLeaderboardProvider excluyen bloqueados; getUsuariosBloqueados(uid) en FirestoreService |
| 2026-10-21 | B7 Bloquear usuarios: documento y reglas (T-019) | `fix/lane-b-07-bloquear-usuarios` → PR #32 | 127/127 Dart, 34/34 reglas, format+analyze limpios | Match `/usuarios/{userId}/blocked/{blockedUid}`; modelo `Bloqueo`; métodos `bloquearUsuario`/`desbloquearUsuario`/`getUsuariosBloqueados`; tests de reglas y de servicio |
| 2026-10-21 | B6 Límites de tamaño en debates, respuestas, comentarios, notificaciones (T-044) | `fix/lane-b-06-tamano-limites` → PR #31 | 123/123 Dart, 34/34 reglas, format+analyze limpios | Reglas: límites en debates (título ≤200, contenido ≤5000), respuestas (contenido ≤2000), comentarios de petición (texto ≤2000), notificaciones (title ≤200, body ≤1000), aplicados también en edición del dueño |
| 2026-10-21 | B5 Borrar cuenta también borra documento privado (T-043) | `fix/lane-b-05-privado-borrado` → PR #30 | 125/125 Dart, 35/35 reglas, format+analyze limpios | `FirestoreService.borrarCuenta(uid)`, match `/usuarios/{userId}/private/{privateId}` con read/create/update/delete, allowlist email ≤320 / fcmToken ≤4096, tests de reglas y de servicio |
| 2026-10-21 | B0 Port de privacidad sobre T-015 (PR #21) | `fix/privacy-port` → PR #29, rama `origin/codex/audit-privacy` | 126/126 Dart, 42/42 reglas, format+analyze limpios | noPrivateFields en call sites de contenido público, privateOnlyRemoved en update de perfil, allowlist email/fcmToken en private/account, 8 tests de reglas nuevos + test legacy reescrito, FcmTokenNotifier escribe en private/account, crearOActualizarUsuario con try/catch, backfill de email en login, docs/SECURITY.md con paso minVersion |

## Bloqueos (necesitan decisión humana o del producto)

- Desplegar reglas de privacidad requiere: app publicada + `config/app_info.minVersion` subido + migración T-018 con 0 perfiles con datos privados. Valor de minVersion: decisión humana.
- B1-B4 de la bandeja están cubiertos dentro de B0 (mismo alcance).
- B13 (T-039 impedir chats no solicitados) bloqueada por decisión de producto.

## Notas para la orquestadora

- Tareas completadas: B0, B5, B6, B7, B8, B9, B10, B11, B12, B15, B16 (11 PRs: #29, #30, #31, #32, #33, #36, #38, #39, #42, #43, #45).
- Siguiente tarea libre: B17 (T-020 paginación por cursor en comentarios, debates y chats).
- Todas las ramas están basadas en origin/main; ninguna está mergeada a main.