# Estado del carril A (orquestadora)

> Lo escribe **solo** la orquestadora. El carril B lo lee con:
> `git fetch origin ops/estado && git show origin/ops/estado:roadmap/ESTADO-A.md`

## Tarea en curso

- **id**: —
- **qué**: —
- **rama**: —
- **PR**: —

## Terminado

| fecha | tarea | rama / PR | verificación | qué cambió |
|---|---|---|---|---|
| 2026-10-21 | T-015 allowlist de campos en /chats | `auto/T-015-rules-chats-allowlist` → PR #23, mergeado (`085a20a`) | 33/33 reglas, 123/123 Dart, 4/4 CI | reglas endurecidas en `/chats`, desplegadas |
| 2026-10-21 | T-018 migración de datos privados | `auto/T-018-migracion-privacidad` → PR #26 | check.sh completo verde, functions 9/9 | script de migración + orden de operaciones |

## Decisiones tomadas por el humano

- **Ventana de compatibilidad**: Opción A — bloqueo por `config/app_info.minVersion` (el diálogo
  bloqueante de `update_service.dart`). Sin reglas transitorias. Orden: publicar app → `minVersion`
  → migrar → endurecer reglas.

## Bloqueos / pendientes de decisión humana

- Desplegar las reglas de privacidad requiere: app nueva publicada, `minVersion` subido y migración
  aplicada con 0 perfiles con datos privados.
- `config/app_info.minVersion` (valor) lo cambia el humano, no los agentes.
- T-010 (compartir versículo) implica una dependencia nueva: si no está justificada, se aplaza.
