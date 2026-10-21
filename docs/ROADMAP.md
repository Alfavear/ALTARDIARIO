# Roadmap — AltarDiario hacia talla internacional

Prioridad: **estabilidad y seguridad → andamiaje → arquitectura → producto**.
Cada ítem debería convertirse en un issue con la plantilla de `.github/ISSUE_TEMPLATE/feature.md`
para que OpenCode (`/feature`) pueda ejecutarlo.

## Fase 1 — Estabilizar (semanas 1-2) · _esta rama entrega la mayor parte_

| # | Ítem | Estado |
|---|---|---|
| 1.1 | Reglas de Firestore estrictas + tests con emulador | ✅ en esta rama |
| 1.2 | Chats privados realmente privados | ✅ |
| 1.3 | Notificaciones no suplantables | ✅ |
| 1.4 | Feed con límite de lectura | ✅ (límite fijo) → paginación real en 3.4 |
| 1.5 | Crashlytics + Analytics + App Check | ✅ código · ⏳ activar en consola, poner site key reCAPTCHA |
| 1.6 | CI: format/analyze/test/reglas/builds en cada PR | ✅ |
| 1.7 | Higiene: LF, logs fuera, dependabot | ✅ |
| 1.8 | **Desplegar reglas nuevas** tras probar la app contra el emulador | ⏳ humano |
| 1.9 | Reportar/bloquear usuarios (requisito App Store 1.2) — UI | ⏳ reglas y function listas; falta UI |
| 1.10 | Revisar licencias de versiones bíblicas (NVI, NTV, LBLA, DHH, RVC, PDT) | ⏳ legal |

## Fase 2 — Andamiaje IA (semanas 3-4)

| # | Ítem | Estado |
|---|---|---|
| 2.1 | AGENTS.md v2, opencode.jsonc V2, agentes, comandos, skills | ✅ |
| 2.2 | `scripts/check.sh` = CI | ✅ |
| 2.3 | Plantillas de issue/PR, CODEOWNERS | ✅ |
| 2.4 | mocktail + fake_cloud_firestore: primeros tests de `FirestoreService` | ⏳ |
| 2.5 | Golden tests de las 5 pantallas principales | ⏳ |
| 2.6 | `integration_test` del flujo login → lectura → publicar | ⏳ (esqueleto) |

## Fase 3 — Arquitectura (mes 2)

| # | Ítem |
|---|---|
| 3.1 | Migrar a `lib/features/` una feature por PR: `oracion` → `foro` → `feed` → `perfil` → `biblia` (`/migrate-feature`) |
| 3.2 | Partir `perfil_screen.dart` (1956 líneas) y `bible_reader_screen.dart` (1629) |
| 3.3 | XP/insignias/rachas en Cloud Functions; bloquear campos en reglas (ADR-0002) |
| 3.4 | Paginación real del feed (`startAfterDocument`, infinite scroll) |
| 3.5 | Sugerencias y ranking sin `getAllUsuarios()`: colección `leaderboards` materializada por function diaria |
| 3.6 | `go_router` + deep links (`altardiario://reflexion/{id}`) para push y compartir |
| 3.7 | i18n de pantallas migradas; inglés y portugués como primeros idiomas extra |
| 3.8 | Rachas en servidor (multi-dispositivo, no se pierden al reinstalar) |

## Fase 4 — Producto (mes 3+)

Ordenado por impacto estimado en retención/adquisición:

1. **Planes de lectura flexibles**: empezar cualquier día, "ponerme al día", planes temáticos de 7/21/40 días. El plan único de 365 días es la mayor barrera de retención.
2. **Compartir versículo como imagen** (WhatsApp/Instagram) con marca de agua: adquisición orgánica gratis.
3. **Widget de pantalla de inicio** (iOS/Android) con la lectura del día y la racha.
4. **Grupos / iglesias**: plan compartido, feed del grupo, racha grupal.
5. **Audio** del capítulo (TTS) y modo "escuchar mientras conduces".
6. **Terminar chat privado** (UI) con bloqueo y reporte integrados.
7. **Recordatorios inteligentes** (hora que el usuario realmente lee, según Analytics).
8. **Modo offline completo** para feed reciente y peticiones.

## Métricas que importan (definir en Analytics antes de la fase 4)
- D1 / D7 / D30 retention
- % usuarios con racha ≥ 7
- Lecturas completadas por usuario/semana
- Reflexiones publicadas por 100 lecturas
- Crash-free users > 99.5 %
