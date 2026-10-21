# Relevo de auditoría — 2026-10-20

Este documento permite continuar la remediación de la auditoría sin depender
del contexto de esta conversación. El repositorio es una aplicación Flutter y
Firebase en producción; no desplegar ni publicar sin autorización humana.

## Estado de las ramas y PR

La rama remota `main` está protegida. GitHub rechazó el push directo porque
exige pull request y cuatro comprobaciones obligatorias. La integración debe
seguir este orden:

1. [PR #20](https://github.com/Alfavear/ALTARDIARIO/pull/20): límite de
   lecturas y accesibilidad. Rama `codex/audit-improvements`.
2. [PR #21](https://github.com/Alfavear/ALTARDIARIO/pull/21): privacidad de
   perfiles. Rama `codex/audit-privacy`, basada en la anterior.
3. [PR #22](https://github.com/Alfavear/ALTARDIARIO/pull/22): reporte de
   perfiles. Rama `codex/audit-moderation`, basada en la anterior.

Los pull requests están apilados. Al fusionar uno, actualizar la base del
siguiente a `main` si GitHub no lo hace automáticamente.

## Auditoría realizada

### Hallazgos priorizados

| Prioridad | Hallazgo | Estado |
| --- | --- | --- |
| Crítica | Los perfiles públicos podían guardar `email` y `fcmToken`. | Corregido para datos nuevos en PR #21. |
| Alta | Consultas sociales y chats sin límite podían leer colecciones completas. | Corregido en PR #20. |
| Alta | La app anulaba la escala de texto configurada por el sistema. | Corregido en PR #20. |
| Alta | Existían reglas y Function de moderación, pero no una acción de usuario para reportar. | Primera acción disponible en PR #22. |
| Media | No hay bloqueo funcional de usuarios ni filtrado de su contenido. | Pendiente. |
| Alta | No hay flujo de eliminación de cuenta. | Pendiente. |
| Media | Feed, comentarios, debates y chats tienen límites, pero no paginación por cursor. | Pendiente. |
| Media | Código heredado grande en `lib/presentation/` y `app_providers.dart`. | Pendiente, migrar una unidad por PR. |

## Cambios entregados

### PR #20 — coste y accesibilidad

Commit integrado localmente: `4fa79f5 fix(core): acotar streams y respetar escala de texto`.

- Añade límites a reflexiones, comentarios, debates, respuestas, peticiones,
  chats y mensajes en `FirestoreService`.
- Quita `TextScaler.noScaling` de `lib/main.dart`.
- Añade prueba del límite de peticiones.
- Incluye entrada de `CHANGELOG.md`.

Verificación realizada: `flutter analyze --no-pub` y la suite Flutter del
hook, entonces con 126 pruebas verdes.

### PR #21 — privacidad de perfiles

Commit: `fa38026 fix(perfil): separar datos privados del perfil público`.

- Mueve correo y token FCM nuevos a
  `usuarios/{uid}/private/account`.
- `Usuario.toMap()` deja de escribir el correo público; `privateAccountMap`
  conserva el dato privado.
- Actualiza los servicios de perfil, autenticación, rachas y sugerencias.
- Las reglas impiden crear perfiles con `email` o `fcmToken` y restringen el
  subdocumento privado a su dueño.
- Añade pruebas de modelo, servicio y reglas.

Verificación realizada:

- `dart format --output=none --set-exit-if-changed`.
- `flutter analyze --no-pub`.
- Pruebas focalizadas de modelo y servicio.
- `scripts/rules_test.sh`: 29 pruebas verdes.
- `scripts/check.sh --fast`: 126 pruebas verdes.

### PR #22 — reporte de perfiles

Commit: `044a188 feat(moderacion): permitir reportar perfiles`.

- Añade `ReportUserDialog` en
  `lib/features/moderation/presentation/report_user_dialog.dart`.
- El perfil público muestra la acción de reporte para usuarios autenticados
  que no sean invitados ni el propio usuario.
- Los motivos son: lenguaje ofensivo, acoso o intimidación, spam y contenido
  inapropiado.
- Añade `FirestoreService.reportarContenido`; escribe en `reports` para que
  la Cloud Function existente procese el reporte.
- Endurece las reglas: acepta solo `reporterId`, `targetType`, `targetId`,
  `reason` y `createdAt`; el motivo debe existir y tener 500 caracteres o
  menos.
- Incluye pruebas de interfaz, servicio y reglas.

Verificación realizada: `scripts/check.sh --fast`, con formato, análisis y
128 pruebas Flutter verdes. El test de reglas debe volver a ejecutarse antes
de fusionar porque la sesión de emulador dejó de responder después de la
última edición de reglas.

## Limitación importante de privacidad

Las reglas protegen los perfiles nuevos, pero **no migran datos existentes**.
Los documentos antiguos que ya contienen `email` o `fcmToken` permanecen
legibles mientras `allow read: if true` exista en `/usuarios/{userId}`.

Antes de endurecer la lectura pública, crear y ejecutar una migración
administrativa que:

1. Lea cada `usuarios/{uid}` con credenciales de administrador.
2. Copie `email` y `fcmToken` a `usuarios/{uid}/private/account`.
3. Elimine esos campos del documento público.
4. Registre cantidades migradas y fallos sin registrar valores privados.
5. Verifique una muestra y después cambie las reglas de lectura según el
   modelo público final.

No ejecutar esa migración desde el cliente ni desplegarla sin autorización.

## Trabajo pendiente, en orden recomendado

1. Esperar las comprobaciones requeridas y fusionar #20, #21 y #22 en ese
   orden. No se pudo consultar ni fusionar GitHub al final de la sesión por
   el límite de uso del revisor automático de permisos.
2. Ejecutar `scripts/rules_test.sh` sobre #22 antes de fusionar. Debe cubrir
   el nuevo campo inválido y el motivo vacío.
3. Crear la migración administrativa de perfiles existentes y planificar su
   ejecución controlada. Solo entonces evaluar restringir la lectura pública
   del perfil.
4. Implementar bloqueo real de usuario: almacenamiento privado de bloqueos,
   acción desde perfil, y filtrado de perfiles, feed, peticiones, debates,
   comentarios, notificaciones y chats. Añadir reglas y pruebas.
5. Añadir acciones de reporte para reflexiones, peticiones y debates. La
   Function `functions/src/moderation.ts` ya procesa esos tres `targetType` y
   marca contenido con tres reportantes distintos como `hidden`.
6. Filtrar en el cliente el contenido con `hidden: true`; actualmente la
   Function lo marca, pero las consultas y pantallas todavía no lo excluyen.
7. Crear el flujo de eliminación de cuenta en una Cloud Function
   administrativa: Auth, perfil, subcolecciones y contenido asociado. Mostrar
   el flujo en Perfil y documentar qué datos elimina.
8. Sustituir los límites de lectura por paginación con cursor
   (`startAfterDocument`) en feed, comentarios, debates y chats.
9. Migrar una feature heredada por pull request a `lib/features/`, sin mezclar
   la migración con funcionalidad nueva.

## Reglas de trabajo del repositorio

- Leer `AGENTS.md` antes de cambiar código.
- Escribir tests antes de cambios testeables y actualizar `CHANGELOG.md`.
- Ejecutar `scripts/check.sh --fast`; si se modifican reglas, también
  `scripts/rules_test.sh`.
- Usar commits convencionales en español.
- Nunca hacer `git push`, deploy de Firebase ni build de app bundle sin
  autorización humana. El usuario ya autorizó publicar ramas y avanzar hacia
  `main`, pero la protección de GitHub obliga el flujo de PR.
- No editar `roadmap/tasks.yaml` ni `roadmap/BITACORA.md` manualmente. El MCP
  de roadmap no estaba disponible durante esta auditoría.

## Referencias locales

- Plan mantenido: `docs/AUDIT_REMEDIATION_PLAN.md`.
- Roadmap funcional para el siguiente agente:
  `docs/PRODUCT_EVOLUTION_ROADMAP.md`.
- Reglas: `firestore.rules` y `firestore-tests/rules.test.mjs`.
- Moderación en servidor: `functions/src/moderation.ts`.
- Servicio principal: `lib/data/services/firestore_service.dart`.

