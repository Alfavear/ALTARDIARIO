# Estado del carril A (orquestadora)

Actualizado: ciclo 10 del roadmap. **21/49 tareas cerradas (43 %)**.

## Ahora

- **Tanda 3 de merges cerrada**: #48 (CI), #38 (T-024), #43 (T-005), #45 (T-017), #36 (T-023).
- **El CI ya no es el cuello de botella.** El job `Build APK (debug)` se ejecuta siempre
  (el check requerido nunca queda en `expected`) pero solo compila si el PR toca
  `android/`, `pubspec.*` o `.github/workflows/`. Medido en #38: **6 s en vez de ~6 min**.
  Un PR de Dart/UI pasa de ~7,6 a ~1,5 min.
- El stack de privacidad (#29, #30) sigue **abierto a propósito**: mergearlo desplegaría
  reglas que la app publicada todavía no cumple.

## Mergeado en `main`

| PR | Qué | Commit |
|---|---|---|
| #26 | Migración de datos privados del perfil (T-018) | `e6a3ea5` |
| #27 | Bandeja compartida y reparto de carriles | `b741499` |
| #28 | Roadmap sin reformateo y `loop.sh` (T-012, T-013, T-046) | `1f85a74` |
| #31 | Límites de tamaño en reglas (T-044) | `068f2db` |
| #32 | Bloqueo de usuarios (T-019) | `fa7d0a4` |
| #33 | Filtrado de bloqueados en proveedores (T-022) | `90ea33c` |
| #34 | Tarjeta de lectura de hoy (T-027) | `c0aa2b3` |
| #39 | Índice compuesto de chats (T-038) | `6faec67` |
| #35 | Borrador + vista previa de reflexión (T-028) | `4471a39` |
| #37 | Biblioteca personal y exportación (T-033) | `3586e4b` |
| #40 | Eventos de producto sin datos personales (T-036) | `227604e` |
| #44 | JSON de índices válido (deploy de `main` en rojo) | `86ab8d4` |
| #48 | `Build APK` condicional + caché + una ABI | `a6bfad8` |
| #38 | Reportar reflexiones y comentarios (T-024) | `31b6610` |
| #43 | Tests de interacción en Firestore (T-005) | `0a568f2` |
| #45 | `markAllNotificationsAsRead` sin batch vacío (T-017) | `15d4cb8` |
| #36 | Bloqueos en chats y notificaciones (T-023) | `7559028` |

## Hallazgos de la noche (encontrados al verificar, no al escribir)

1. **`reports` no aceptaba `targetType: 'comentario'`** → reportar un comentario habría
   dado `permission-denied`. Corregido en #38 (+3 tests de reglas).
2. **`firestore.indexes.json` inválido** → dejó el deploy de `main` en rojo y bloqueaba
   cualquier despliegue de reglas. Corregido en #44 + test que valida el fichero en cada PR.
3. **Desajuste reglas↔cliente** por los límites de #31: la UI no tenía topes.
   Registrado como **T-047 (P1)**.
4. **La Function de moderación solo mapea 3 tipos** (`reflexion`, `peticion`, `debate`):
   los reportes de **comentarios** (habilitados en #38) y de **perfiles** se guardan y
   nadie los procesa. **T-048 (P1)**.
5. **`reports` sin `keys().hasOnly`**: un cliente modificado puede añadir campos
   (`status`, `hidden`…). **T-049 (P2)**.

Los puntos 4 y 5 salieron de un informe de auditoría externa que, por lo demás, estaba
hecho sobre un checkout atrasado 67 commits: daba por muerto el diálogo de reportar
(se instancia en el feed en dos sitios), daba por ausente el allowlist de `comentario`
(ya está en `main` y desplegado) y pedía un `maxLength` en el motivo (existe, 200).

## En cola de merge

#42 (T-025, conflicto del diálogo resuelto a favor de la versión con tests),
#49 (`reflexion_publicada`) y #41 (este cierre).

## En espera

- **#46** — grafo de conocimiento con `OPENAI_API_KEY`, `contents: write` y `push --force`.
  Requiere decisión humana; el comentario del PR ofrece tres salidas.
- **#47** — paginación sin tests, sin consumidores y sobre una base vieja que revertiría #44.
- **#29/#30** — privacidad, tras el despliegue ordenado (app → `minVersion` → migración).
- **#6–#18** — 13 PRs de Dependabot; cinco son *major* con breaking real y necesitan
  su propia sesión.

## Siguiente (carril A)

1. T-037 — rendimiento: métricas, caché offline de Biblia y reintentos.
2. T-035 — migrar moderación a `lib/features/moderation/`.
3. T-010 y T-011 — T-011 hay que dividirla antes.

## Siguiente (carril B)

**T-047, T-048 y T-049** antes de seguir con producto. Después, la cola de
`roadmap/BANDEJA.md`: B12 (T-025, falta la Function), B13 (T-039), B14 (T-004).

**Tope de trabajo en curso: 2 PRs abiertos a la vez.** Con más, cada merge deja al resto
`BEHIND` y la cola crece más rápido de lo que drena.

## Reglas del carril A

- El roadmap (`tasks.yaml`, `STATE.md`, `BITACORA.md`) lo escribe **solo** el carril A.
- El carril B no mergea a `main`: publica rama + PR y anota en `ESTADO-B.md`.
- Ningún merge sin los 4 checks en verde y la rama al día con `main`.
- Nada de deploys, tags ni `config/app_info.minVersion` sin humano.

## Pendiente humano (despliegue de privacidad)

1. Publicar la app nueva.
2. Subir `config/app_info.minVersion`.
3. Ejecutar la migración hasta 0 campos privados heredados.
4. Solo entonces mergear y desplegar #29/#30 (reglas endurecidas).
