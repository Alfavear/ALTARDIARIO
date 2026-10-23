# Estado del carril A (orquestadora)

Actualizado: ciclo 9 del roadmap.

## Ahora

- **Tanda de merges.** El carril B (otra sesión) produce rama + PR; esta sesión
  revisa, resuelve conflictos y mergea. El carril B nunca mergea.
- **#48** (CI): el `Build APK (debug)` deja de compilar en cada PR. El job se
  ejecuta siempre (el check requerido no queda en `expected`) pero solo compila
  si el PR toca `android/`, `pubspec.*` o `.github/workflows/`; en `main`
  compila siempre. Añade caché de Gradle y una sola ABI.
- El **stack de privacidad (#29, #30) sigue abierto a propósito**: mergearlo
  desplegaría reglas que la app publicada todavía no cumple.

## Mergeado en `main`

| PR | Qué | Commit |
|---|---|---|
| #26 | Migración de datos privados del perfil (T-018) | `e6a3ea5` |
| #27 | Bandeja compartida y reparto de carriles | `b741499` |
| #28 | Roadmap sin reformateo, `STATE.md` y `loop.sh` (T-012, T-013, T-046) | `1f85a74` |
| #31 | Límites de tamaño en reglas (T-044) | `068f2db` |
| #32 | Bloqueo de usuarios: subcolección y reglas (T-019) | `fa7d0a4` |
| #33 | Filtrado de bloqueados en proveedores sociales (T-022) | `90ea33c` |
| #34 | Tarjeta de lectura de hoy en Inicio (T-027) | `c0aa2b3` |
| #39 | Índice compuesto de chats (T-038) | `6faec67` |
| #35 | Borrador + vista previa de reflexión (T-028) | `4471a39` |
| #37 | Biblioteca personal y exportación (T-033) | `3586e4b` |
| #40 | Eventos de producto sin datos personales (T-036) | `227604e` |
| #44 | JSON de índices válido (deploy de `main` en rojo) | `86ab8d4` |

## Hallazgos de la noche (encontrados al verificar, no al escribir)

1. **`reports` no aceptaba `targetType: 'comentario'`** → reportar un comentario
   habría dado `permission-denied`. Corregido en la rama de #38 + 3 tests.
2. **`firestore.indexes.json` inválido** (objeto de `chats` fuera del array y
   `participantIds` con `order` en vez de `arrayConfig: CONTAINS`) → dejó el
   deploy de `main` en rojo ~20 min y bloqueaba cualquier despliegue de reglas.
   Corregido en #44 + `test/infra/firestore_indexes_test.dart`.
3. **Desajuste reglas↔cliente** por los límites de #31: la UI no tiene topes y
   un título de debate >200 caracteres recibe hoy un error de permisos.
   Registrado como **T-047 (P1)** para el carril B.

## En cola de merge

#48 (CI), #38 (T-024), #43 (T-005), #46, #45, #36 (T-023), #42 (T-025, duplica
el diálogo de #38: se resuelve quedándose con la versión con tests) y #41
(cierre de roadmap).

## Siguiente (carril A)

1. T-037 — Rendimiento: métricas, caché offline de Biblia y reintentos.
2. T-035 — Migrar moderación a `lib/features/moderation/` (cuando el carril B
   suelte la UI de reportar).
3. T-010 y T-011 — T-011 hay que dividirla antes.

## Siguiente (carril B)

Antes de B12: **T-047** (P1) — topes del cliente alineados con las reglas.

Después, la cola de `roadmap/BANDEJA.md`: B12 = T-025, B13 = T-039, B14 = T-004,
B15 = T-005, B16 = T-017.

**Tope de trabajo en curso: 2 PRs abiertos a la vez.** Con más, cada merge deja
al resto `BEHIND` y la cola crece más rápido de lo que drena.

## Reglas del carril A

- El roadmap (`tasks.yaml`, `STATE.md`, `BITACORA.md`) lo escribe **solo** el carril A.
- El carril B no mergea a `main`: publica rama + PR y anota en `ESTADO-B.md`.
- Ningún merge sin los 4 checks en verde y la rama al día con `main`.
- Nada de deploys, tags ni `config/app_info.minVersion` sin humano.

## Pendiente humano (despliegue de privacidad)

1. Publicar la app nueva.
2. Subir `config/app_info.minVersion` (bloquea versiones antiguas con el diálogo
   que ya existe en `update_service.dart`).
3. Ejecutar la migración hasta 0 campos privados heredados.
4. Solo entonces mergear y desplegar #29/#30 (reglas endurecidas).
