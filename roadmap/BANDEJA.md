# Bandeja de trabajo — dos carriles en paralelo

> Esta es la fuente de verdad de "quién hace qué" mientras las dos sesiones
> trabajan sin supervisor humano. La escribe la **orquestadora** (carril A);
> el carril B solo lee este fichero y escribe en su propio `ESTADO-B.md`.
>
> Estado de los estados: `roadmap/ESTADO-A.md` (orquestadora) · `roadmap/ESTADO-B.md` (otra sesión)
>
> ```bash
> git fetch origin ops/estado
> git show origin/ops/estado:roadmap/BANDEJA.md
> git show origin/ops/estado:roadmap/ESTADO-B.md
> ```

## Reparto de ficheros (no se pisan)

| Fichero | Dueño |
|---|---|
| `firestore.rules`, `firestore-tests/rules.test.mjs`, `firestore.indexes.json` | **B** |
| `lib/data/services/firestore_service.dart`, `lib/presentation/providers/app_providers.dart`, `lib/data/models/usuario.dart` | **B** |
| `lib/presentation/screens/public_profile_screen.dart`, `chat_list_screen.dart`, `notificaciones_screen.dart`, `perfil_screen.dart`, `feed_screen.dart`, `oracion_screen.dart`, `debate_detail_screen.dart` | **B** |
| `functions/src/moderation.ts`, `functions/src/index.ts`, `docs/SECURITY.md` | **B** |
| `tools/roadmap-mcp/**`, `scripts/**`, `roadmap/tasks.yaml`, `roadmap/STATE.md`, `roadmap/BITACORA.md` | **A** |
| `lib/core/theme/app_theme.dart`, `lib/core/observability/**`, `lib/data/services/bible_service.dart` | **A** |
| `lib/presentation/screens/home_screen.dart`, `publicar_reflexion_screen.dart`, `notes_screen.dart`, `lib/features/**` | **A** |

Si una tarea toca ficheros de los dos carriles: **se asigna al carril B** (reglas y cliente
compartido) y se anota en `ESTADO-B.md`; el carril A no la toca.

## Reglas comunes (obligatorias)

1. **Nadie mergea a `main` salvo la orquestadora.** El carril B publica rama + PR y para ahí.
2. **Nada de deploys**: ni `firebase deploy`, ni tags de release, ni tocar `config/app_info.minVersion`.
3. **Nada de secretos**: no se commitean `.env`, `google-services.json`, keystores ni service accounts.
4. **Puerta de calidad**: `scripts/check.sh` completo en verde (con emulador) y `scripts/rules_test.sh`
   si se toca `firestore.rules`. Nada de "loMergeo luego".
5. **No se bajan las reglas de Firestore** para que algo funcione, y **no se borran ni se saltan tests**.
6. **Un commit por unidad lógica**, Conventional Commits en español, y una línea en `CHANGELOG.md` → `[Unreleased]`.
7. **El carril B no escribe `roadmap/tasks.yaml`** (es de A). Si encuentra trabajo nuevo, lo describe en
   `ESTADO-B.md` y la orquestadora lo registra.
8. Cada tarea del roadmap se cierra con `complete_task` + `log_cycle` (MCP o `tools/roadmap-mcp/roadmap.mjs`).
9. Si una tarea resulta demasiado grande (> 6 ficheros), se parte o se bloquea con motivo.
10. **Nunca se para**: si no hay tarea disponible, se derivan tareas del backlog cuyo `files` no toque el
    otro carril, o se revisan los PRs abiertos del propio carril.

## Carril B — otra sesión (cola)

| # | Tarea | Ficheros | Notas |
|---|---|---|---|
| B0 | **Port de privacidad sobre T-015** (PR #21) | reglas + tests + `firestore_service.dart` + `app_providers.dart` | en curso; ver el prompt de la sesión |
| B1 | T-040 `noPrivateFields()` en todo el contenido público | reglas + tests | sin colisión con B0 |
| B2 | T-041 documento privado con allowlist de campos, tipos y tamaños | reglas + tests | |
| B3 | T-042 permitir borrar email/fcmToken del perfil público | reglas + tests | sin el bloqueo actual |
| B4 | T-044 límites de tamaño en debates, respuestas, notificaciones y comentarios | reglas + tests | |
| B5 | T-043 el borrado del perfil borra también el documento privado | `firestore_service.dart` + functions | |
| B6 | T-019 bloquear usuarios: documento y reglas | reglas + tests + nuevos ficheros | reglas nuevas en `usuarios/{uid}/blocked/{blockedUid}` |
| B7 | T-022 filtrar usuarios bloqueados en feed, oración, debate y perfiles | `app_providers.dart` | |
| B8 | T-026 filtrar contenido oculto en providers y pantallas | `app_providers.dart` | el PR #24 ya filtra en los feeds: verificar y completar |
| B9 | T-023 filtrar bloqueos en chats y notificaciones + desbloqueo en Ajustes | `chat_list_screen` + `notificaciones_screen` + `perfil_screen` | |
| B10 | T-024 reportar reflexiones y comentarios | `feed_screen` + widgets | reutiliza el diálogo de #22 |
| B11 | T-038 índice compuesto de chats (`participantIds` + `lastUpdate`) | `firestore.indexes.json` | la lista de chats falla hoy en producción |
| B12 | T-025 reportar peticiones, debates y respuestas + test de la Function | `functions/src/moderation.ts` + `debate_detail_screen` | |
| B13 | T-039 impedir chats no solicitados | reglas | necesita criterio de producto:Blocked si no se decide |
| B14 | T-016 partir `firestore-tests/rules.test.mjs` (>400 líneas) | tests de reglas | **al final**: mueve código que B0-B6 tocan |

## Carril A — orquestadora (cola)

| # | Tarea | Ficheros |
|---|---|---|
| A0 | T-012 el MCP roadmap no debe reformatear `tasks.yaml` entero | `tools/roadmap-mcp/roadmap.mjs` |
| A1 | T-013 corregir el encabezado duplicado (`## ##`) de STATE.md | `tools/roadmap-mcp/roadmap.mjs` |
| A2 | Corregir el `exit 1` por SIGPIPE de `scripts/loop.sh` | `scripts/loop.sh` |
| A3 | T-027 Inicio "Hoy": pendiente, completado y sin conexión | `home_screen.dart` |
| A4 | T-028 reflexión guiada y privada por defecto | `publicar_reflexion_screen.dart` |
| A5 | T-033 biblioteca personal: resaltados, notas y reflexiones privadas | `notes_screen.dart` |
| A6 | T-036 observabilidad accionable sin datos sensibles | `lib/core/observability/` |
| A7 | T-037 rendimiento: métricas, caché offline de Biblia y reintentos | `bible_service.dart` |
| A8 | T-035 migrar la feature de moderación a `lib/features/moderation/` | `lib/features/moderation/` |
| A9 | T-010 compartir versículo como imagen | lector + `share_plus` — **no añadir dependencias sin justificarlas**: si `share_plus` no está ya, se aplaza |

## Resumen para el humano (lo escribe la orquestadora)

- PRs abiertos por carril, con su estado de checks.
- Qué falta para el despliegue de la privacidad (app publicada + `minVersion` + migración aplicada con 0).
- Decisiones pendientes de producto o de despliegue.
