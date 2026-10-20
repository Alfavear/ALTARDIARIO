---
name: observability
description: Crashlytics, Analytics y App Check en AltarDiario. Usar al añadir eventos de producto, capturar errores o depurar fallos en producción.
---

# Observabilidad

Todo pasa por `lib/core/observability/observability.dart` para que las pantallas no importen Firebase directamente.

```dart
Observability.logEvent('reflexion_publicada', {'pasaje': pasajeDia});
Observability.recordError(e, st, reason: 'publicarReflexion');
Observability.setUser(uid);   // al iniciar sesión; null al cerrar
```

## Eventos de producto (nombres canónicos)
| Evento | Cuándo | Parámetros |
|---|---|---|
| `lectura_completada` | usuario marca lectura del día | `dia`, `racha` |
| `reflexion_publicada` | publica en el feed | `pasaje`, `longitud` |
| `amen_enviado` | pulsa Amén | — |
| `biblia_capitulo_abierto` | abre un capítulo | `libro`, `capitulo`, `version` |
| `version_descargada` | descarga una Biblia | `version` |
| `insignia_desbloqueada` | gana badge | `badge_id` |
| `modo_enfoque_activado` | activa Modo Enfoque | — |

Snake_case, máx 40 chars, sin datos personales en parámetros.

## Errores
- `try/catch` en servicios → `Observability.recordError`. Nunca tragar excepciones en silencio.
- Los `FlutterError.onError` y `PlatformDispatcher.onError` ya están enganchados en `main.dart`.
- En web Crashlytics no está disponible: el helper lo ignora.

## App Check
- Activado en `main.dart` con Play Integrity (Android), DeviceCheck (iOS) y reCAPTCHA v3 (web).
- En debug usa el provider de debug: registra el token que imprime la consola en Firebase Console → App Check.
- Modo "monitor" primero; pasar a "enforce" en Firestore solo cuando el 95%+ de las peticiones sean verificadas.
