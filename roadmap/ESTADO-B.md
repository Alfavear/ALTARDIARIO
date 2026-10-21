# Estado del carril B (otra sesión)

> Lo escribe **solo** el carril B. La orquestadora lo lee con:
> `git fetch origin ops/estado && git show origin/ops/estado:roadmap/ESTADO-B.md`
>
> Formato: una línea por tarea terminada + la tarea en curso + los bloqueos.
> Sin esto, la orquestadora no sabe en qué estás ni qué te toca.

## Tarea en curso

- **id**: B6
- **qué**: T-044 límites de tamaño en debates, respuestas, notificaciones y comentarios
- **rama**: — (a crear sobre origin/main)
- **PR**: —

## Terminado (empieza por la más reciente)

| fecha | tarea | rama / PR | verificación | qué cambió |
|---|---|---|---|---|
| 2026-10-21 | B5 Borrar cuenta también borra documento privado (T-043) | `fix/lane-b-05-privado-borrado` → PR #30 | 125/125 Dart, 35/35 reglas, format+analyze limpios | `FirestoreService.borrarCuenta(uid)`, match `/usuarios/{userId}/private/{privateId}` con read/create/update/delete, allowlist email ≤320 / fcmToken ≤4096, tests de reglas y de servicio |
| 2026-10-21 | B0 Port de privacidad sobre T-015 (PR #21) | `fix/privacy-port` → PR #29, rama `origin/codex/audit-privacy` | 126/126 Dart, 42/42 reglas, format+analyze limpios | noPrivateFields en call sites de contenido público, privateOnlyRemoved en update de perfil, allowlist email/fcmToken en private/account, 8 tests de reglas nuevos + test legacy reescrito, FcmTokenNotifier escribe en private/account, crearOActualizarUsuario con try/catch, backfill de email en login, docs/SECURITY.md con paso minVersion |

## Bloqueos (necesitan decisión humana o del producto)

- Desplegar reglas de privacidad requiere: app publicada + `config/app_info.minVersion` subido + migración T-018 con 0 perfiles con datos privados. Valor de minVersion: decisión humana.
- B1-B4 de la bandeja están cubiertos dentro de B0 (mismo alcance).

## Notas para la orquestadora

- Siguiente tarea libre: B6 (T-044 límites de tamaño). Después B6, continuar con B7 en adelante según la bandeja.
