# Estado del carril B (otra sesión)

> Lo escribe **solo** el carril B. La orquestadora lo lee con:
> `git fetch origin ops/estado && git show origin/ops/estado:roadmap/ESTADO-B.md`
>
> Formato: una línea por tarea terminada + la tarea en curso + los bloqueos.
> Sin esto, la orquestadora no sabe en qué estás ni qué te toca.

## Tarea en curso

- **id**: —
- **qué**: —
- **rama**: —
- **PR**: —

## Terminado (empieza por la más reciente)

| fecha | tarea | rama / PR | verificación | qué cambió |
|---|---|---|---|---|
| 2026-10-21 | B0 Port de privacidad sobre T-015 (PR #21) | `fix/privacy-port` → PR #29, rama `origin/codex/audit-privacy` | 126/126 Dart, 42/42 reglas, format+analyze limpios | noPrivateFields en call sites de contenido público, privateOnlyRemoved en update de perfil, allowlist email/fcmToken en private/account, 8 tests de reglas nuevos + test legacy reescrito, FcmTokenNotifier escribe en private/account, crearOActualizarUsuario con try/catch, backfill de email en login, docs/SECURITY.md con paso minVersion |

## Bloqueos (necesitan decisión humana o del producto)

- Desplegar reglas de privacidad requiere: app publicada + `config/app_info.minVersion` subido + migración T-018 con 0 perfiles con datos privados. Valor de minVersion: decisión humana.
- B1-B4 de la bandeja están cubiertos dentro de B0 (mismo alcance: noPrivateFields, allowlist privado, privateOnlyRemoved, límites ya aplicados en el port).

## Notas para la orquestadora

- B1-B4 ya implementados como parte de B0; la primera tarea realmente pendiente es B5 (T-043 borrado del perfil borra documento privado).
