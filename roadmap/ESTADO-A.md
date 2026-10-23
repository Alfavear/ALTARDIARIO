# Estado del carril A (orquestadora)

Actualizado: ciclo 7 del roadmap.

## Ahora

- **T-027 · Inicio "Hoy"** implementado en `auto/T-027-inicio-hoy`: la tarjeta de la
  lectura se extrae a `lib/presentation/widgets/lectura_hoy_card.dart` y
  `lectura_hoy_estados.dart` (ninguno supera 400 líneas). Cuatro estados:
  cargando (skeleton), sin conexión, pendiente y completado con celebración
  discreta y siguiente lectura del plan. Se abre con un solo toque y respeta el
  escalado de texto. 5 widget tests nuevos.

## Mergeado en `main`

| PR | Qué | Commit |
|---|---|---|
| #26 | Herramienta de migración de datos privados del perfil (T-018) | `e6a3ea5` |
| #27 | Bandeja compartida y reparto de carriles | `b741499` |
| #28 | Roadmap sin reformateo, `STATE.md` sin encabezados duplicados y `loop.sh` sin SIGPIPE (T-012, T-013, T-046) | `1f85a74` |

## Siguiente (carril A)

1. T-028 · Reflexión guiada y privada por defecto
2. T-033 · Biblioteca personal (resaltados, notas y reflexiones privadas)
3. T-036 · Observabilidad accionable sin datos sensibles
4. T-037 · Rendimiento: métricas, caché offline de Biblia y reintentos
5. T-035 · Migrar la feature de moderación a `lib/features/moderation/`

## Reglas del carril A

- El roadmap (`tasks.yaml`, `STATE.md`, `BITACORA.md`) lo escribe **solo** el carril A.
- El carril B no mergea a `main`: publica rama + PR y anota en `ESTADO-B.md`.
- Ningún merge sin los 4 checks en verde y la rama al día con `main`.
- Nada de deploys, tags ni `config/app_info.minVersion` sin humano.

## Pendiente humano (despliegue de privacidad)

1. Publicar la app nueva.
2. Subir `config/app_info.minVersion` para forzar la actualización.
3. Ejecutar la migración (`npm run migrate:private-account`) hasta 0 campos privados.
4. **Solo entonces** desplegar las reglas de privacidad.
