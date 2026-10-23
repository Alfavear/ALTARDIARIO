# Bandeja de trabajo — dos carriles en paralelo

> Fuente de verdad de "quién hace qué" mientras las dos sesiones trabajan sin supervisor humano.
> La escribe la **orquestadora** (carril A). El carril B solo lee este fichero y escribe en
> su propio `roadmap/ESTADO-B.md`.
>
> ```bash
> git fetch origin ops/estado
> git show origin/ops/estado:roadmap/BANDEJA.md     # esta bandeja
> git show origin/ops/estado:roadmap/ESTADO-B.md   # en qué está el carril B
> git show origin/ops/estado:roadmap/ESTADO-A.md   # en qué está la orquestadora
> ```

## Reglas comunes (obligatorias)

1. **Nadie mergea a `main` salvo la orquestadora.** El carril B publica rama + PR y para ahí.
2. **Nada de deploys**: ni `firebase deploy`, ni tags de release, ni tocar `config/app_info.minVersion`.
3. **Nada de secretos**: no se commitean `.env`, `google-services.json`, keystores ni cuentas de servicio.
4. **Puerta de calidad**: `scripts/check.sh` completo en verde (con emulador) y `scripts/rules_test.sh`
   si se toca `firestore.rules`.
5. **No se bajan las reglas de Firestore** para que algo funcione, y **no se borran ni se saltan tests**.
6. **Un commit por unidad lógica**, Conventional Commits en español, y una línea en `CHANGELOG.md`.
7. **El carril B no escribe `roadmap/tasks.yaml`, `roadmap/STATE.md` ni `roadmap/BITACORA.md`** (son de A).
   Tampoco cierra tareas en el roadmap: lo hace la orquestadora a partir de lo que anota el carril B
   en `ESTADO-B.md`. El carril B **sí** puede usar `tools/roadmap-mcp/roadmap.mjs` para **leer**
   (next_task, list, state).
8. Si una tarea toca ficheros de los dos carriles: **es del carril B** (reglas y cliente compartido).
9. Si una tarea resulta demasiado grande (> 6 ficheros), se parte o se bloquea con motivo.
10. **Nunca se para**: si la cola propia se agota, se deriva una tarea del backlog cuyos `files` no
    toque el otro carril; si de verdad no hay ninguna, se revisan los PRs abiertos del propio carril
    y se vuelve a mirar la bandeja cada 10 minutos.

## Reparto de ficheros

| Fichero | Dueño |
|---|---|
| `firestore.rules`, `firestore-tests/rules.test.mjs`, `firestore.indexes.json` | **B** |
| `lib/data/services/firestore_service.dart`, `lib/presentation/providers/app_providers.dart`, `lib/data/models/usuario.dart` | **B** |
| `lib/presentation/screens/public_profile_screen.dart`, `chat_list_screen.dart`, `notificaciones_screen.dart`, `perfil_screen.dart`, `feed_screen.dart`, `oracion_screen.dart`, `debate_detail_screen.dart` | **B** |
| `functions/src/moderation.ts`, `functions/src/index.ts`, `docs/SECURITY.md` | **B** |
| `tools/roadmap-mcp/**`, `scripts/**`, `roadmap/tasks.yaml`, `roadmap/STATE.md`, `roadmap/BITACORA.md` | **A** |
| `lib/core/theme/**`, `lib/core/observability/**`, `lib/data/services/bible_service.dart` | **A** |
| `lib/presentation/screens/home_screen.dart`, `publicar_reflexion_screen.dart`, `notes_screen.dart`, `lib/features/**` | **A** |

## Carril B — otra sesión

| # | Tarea | Ficheros | Notas |
|---|---|---|---|
| B0 | **Port de privacidad sobre T-015** (PR #21) | reglas + tests + `firestore_service.dart` + `app_providers.dart` | en curso; spec en el prompt de la sesión |
| B1 | T-040 `noPrivateFields()` en todo el contenido público | reglas + tests | aplicar en los call sites, no dentro de `ownerEditOk()` |
| B2 | T-041 documento privado con allowlist de campos, tipos y tamaños | reglas + tests | email ≤ 320, fcmToken ≤ 4096 |
| B3 | T-042 permitir borrar email/fcmToken sin bloqueo | reglas + tests | helper `privateOnlyRemoved` |
| B4 | T-044 límites de tamaño en debates, respuestas, notificaciones y comentarios | reglas + tests | |
| B5 | T-043 el borrado del perfil borra también el documento privado | `firestore_service.dart` + functions | |
| B6 | T-019 bloquear usuarios: documento y reglas | reglas + tests + nuevos ficheros | `usuarios/{uid}/blocked/{blockedUid}` |
| B7 | T-022 filtrar usuarios bloqueados en feed, oración, debate y perfiles | `app_providers.dart` | |
| B8 | T-026 filtrar contenido oculto en providers y pantallas | `app_providers.dart` | el PR #24 ya filtra en los feeds: verificar y completar |
| B9 | T-023 filtrar bloqueos en chats y notificaciones + desbloqueo en Ajustes | `chat_list_screen` + `notificaciones_screen` + `perfil_screen` | |
| B10 | T-024 reportar reflexiones y comentarios | `feed_screen` + widgets | reutiliza el diálogo de #22 |
| B11 | T-038 índice compuesto de chats (`participantIds` + `lastUpdate`) | `firestore.indexes.json` | la lista de chats falla hoy en producción |
| B12 | T-025 reportar peticiones, debates y respuestas + test de la Function | `functions/src/moderation.ts` + `debate_detail_screen` | |
| B13 | T-039 impedir chats no solicitados | reglas | criterio de producto: bloquéala si no se decide |
| B14 | T-004 UI de reportar contenido y bloquear usuario (App Store 1.2) | `feed_screen` + `public_profile_screen` + `firestore_service` | |
| B15 | T-005 tests de FirestoreService (likes, reacciones, seguir, amén) | `test/services/firestore_service_test.dart` | |
| B16 | T-017 `markAllNotificationsAsRead` sin batch vacío | `firestore_service.dart` + test | S, rápido |
| B17 | T-020 paginación por cursor en comentarios, debates y chats | `firestore_service.dart` | |
| B18 | T-029 oración con seguimiento: estado respondida y filtros | `oracion_screen.dart` + reglas | el aviso a quienes apoyaron es opcional |
| B19 | T-030 búsqueda y temas seguidos en la comunidad | `app_providers.dart` | P3, al final |
| B20 | T-031 debate bíblico de calidad: etiquetas y respuestas anidadas | `debate_detail_screen.dart` | P3 |
| B21 | T-032 ajustes de lectura: traducción, tamaño, espaciado y alto contraste | `app_theme.dart` + `perfil_screen` | no anular `MediaQuery.textScaler` |
| B22 | T-034 notificaciones con intención: preferencias por categoría | `notification_service.dart` | las preferencias FCM van al documento privado |
| B23 | T-021 flujo de eliminación de cuenta (Auth, perfil, datos y contenido) | `functions/src/index.ts` + `perfil_screen` | |
| B24 | T-006 migrar la feature de oración a `lib/features/oracion/` | `lib/features/oracion/` | ADR-0001 |
| B25 | T-007 paginación real del feed con `startAfterDocument` | `firestore_service.dart` + `feed_screen` | |
| B26 | T-016 partir `firestore-tests/rules.test.mjs` (>400 líneas) | tests de reglas | **al final**: mueve código que tocan B0-B4 |
| B27 | T-008 partir `perfil_screen.dart` (1956 líneas) | `perfil_screen` | L → dividir antes de empezar |
| B28 | T-045 job de functions en la CI | `.github/workflows/ci.yml` | **requiere OK humano**: el ciclo no toca workflows |

## Carril A — orquestadora

| # | Tarea | Ficheros |
|---|---|---|
| A0 | T-013 `STATE.md` sin encabezados duplicados (PR #28) | `tools/roadmap-mcp/roadmap.mjs` |
| A1 | T-012 el MCP roadmap no debe reformatear `tasks.yaml` entero | `tools/roadmap-mcp/roadmap.mjs` |
| A2 | T-046 `scripts/loop.sh` sin exit 1 por SIGPIPE | `scripts/loop.sh` |
| A3 | T-027 Inicio "Hoy": pendiente, completado y sin conexión | `home_screen.dart` |
| A4 | T-028 reflexión guiada y privada por defecto | `publicar_reflexion_screen.dart` |
| A5 | T-033 biblioteca personal: resaltados, notas y reflexiones privadas | `notes_screen.dart` |
| A6 | T-036 observabilidad accionable sin datos sensibles | `lib/core/observability/` |
| A7 | T-037 rendimiento: métricas, caché offline de Biblia y reintentos | `bible_service.dart` |
| A8 | T-035 migrar la feature de moderación a `lib/features/moderation/` | `lib/features/moderation/` |
| A9 | T-010 compartir versículo como imagen | lector + `share_plus` — **no añadir dependencias sin justificarlas**: si no está justificada, se aplaza |
| A10 | T-011 planes de lectura flexibles | L → dividir antes de empezar |

## Resumen para el humano (lo escribe la orquestadora)

- PRs abiertos por carril con el estado de sus checks.
- Qué falta para el despliegue de la privacidad (app publicada + `minVersion` + migración con 0).
- Decisiones pendientes de producto o de despliegue.
