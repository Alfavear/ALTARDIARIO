# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/es/1.1.0/). Versionado semántico.

## [Unreleased]

### Seguridad
- Reglas de Firestore reescritas: nadie edita contenido ajeno; chats privados solo para participantes; notificaciones no suplantables; contadores sociales acotados a ±1 con uid propio; colección `reports` para moderación.
- App Check activado en cliente (monitor; pasar a enforce en consola).

### Añadido
- Suite de tests de reglas de Firestore con emulador (`firestore-tests/`).
- Observabilidad: Crashlytics, Analytics (`lib/core/observability`).
- Base de i18n (ARB es/en) y `flutter_localizations`.
- Esqueleto de Cloud Functions: XP en servidor y moderación por reportes.
- Andamiaje de IA: `AGENTS.md` v2, `opencode.jsonc` V2, agentes `planner`/`reviewer`/`rules-auditor`/`release-manager`, comandos y skills.
- CI/CD en GitHub Actions: format/analyze/test, reglas, builds Android/Web, deploy de Firebase, release Android por tag, Dependabot.
- `scripts/check.sh`, `scripts/rules_test.sh`, `scripts/bootstrap.sh`.
- Documentación: ROADMAP, ADR-0001/0002/0003, AI_WORKFLOW, SECURITY, RELEASE.

### Cambiado
- Feed de reflexiones limitado a 100 documentos por lectura (antes: colección completa).
- `sendMessage` crea el documento del chat antes del mensaje (requerido por las reglas).
- `analysis_options.yaml` con lints adicionales.
- Mocks permitidos en tests (`mocktail`, `fake_cloud_firestore`, `firebase_auth_mocks`).
- Formato y lints alineados con Dart 3.12 / Flutter 3.44; `pubspec.lock` y registro de plugins regenerados.

### Arreglado
- Chats: las reglas aceptan el reordenamiento de `participantIds` al enviar mensajes (antes solo podía escribir quien creó el chat). Tests de reglas para todas las escrituras del cliente.
- Build Android en CI: Gradle 8.14.3, AGP 8.11.1 y Kotlin 2.2.20 (mínimos de Flutter stable); `google-services.json` restaurado desde secret; archivos generados (`local.properties`, `GeneratedPluginRegistrant.java`, logs de Kotlin) fuera del control de versiones.

### Pendiente (no incluido en esta rama)
- UI de reportar/bloquear usuario.
- Migración a `lib/features/`.
- Paginación real del feed.

## [1.0.4] - 2026-07-31
- Diccionario bíblico offline, tipografía Lora, shimmer, háptica. (Ver BITACORA.md para el historial anterior.)
