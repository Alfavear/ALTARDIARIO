# Estado del carril A (orquestadora)

Actualizado: ciclo 8 del roadmap.

## Ahora

- **Tanda de merges.** El carril B (otra sesión) produce rama + PR; esta sesión
  revisa, resuelve conflictos y mergea. El carril B nunca mergea.
- **T-028, T-033 y T-036** implementados por el carril A, con PR abierto y en
  cola de merge.
- **T-019, T-022, T-044 y T-027** cerrados en el roadmap tras mergear su PR.
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

## En cola de merge

#39 (T-038, índice compuesto de chats), #35 (T-028), #37 (T-033), #40 (T-036),
#36 (T-023), #38 (T-024).

## Siguiente (carril A)

1. T-037 — Rendimiento: métricas, caché offline de Biblia y reintentos.
2. T-035 — Migrar la feature de moderación a `lib/features/moderation/`
   (espera a que el carril B termine la UI de reportar, para no moverle el suelo).
3. T-010 y T-011 — T-011 hay que dividirla antes.

## Siguiente (carril B)

La cola vive en `roadmap/BANDEJA.md`. Tras B11: B12 = T-025, B13 = T-039,
B14 = T-004, B15 = T-005, B16 = T-017.

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
