---
name: i18n
description: Internacionalización con flutter_localizations y archivos ARB. Usar al crear textos de UI nuevos o migrar una pantalla a i18n.
---

# i18n

Hoy la app está en español hardcodeado. La migración es gradual: pantalla a pantalla, empezando por las nuevas.

## Setup (ya en la rama de andamiaje)
- `l10n.yaml` en la raíz, ARBs en `lib/l10n/app_es.arb` (plantilla) y `app_en.arb`.
- `flutter pub get` genera `lib/l10n/generated/app_localizations.dart` (ignorado en git).
- En `main.dart`: `localizationsDelegates: AppLocalizations.localizationsDelegates`, `supportedLocales: AppLocalizations.supportedLocales`.

## Uso
```dart
final l = AppLocalizations.of(context)!;
Text(l.feedEmptyTitle)
Text(l.streakDays(count))   // plural
```

## Reglas
- Claves en camelCase con prefijo de feature: `feedEmptyTitle`, `oracionAmenButton`.
- Cada clave nueva se añade a `app_es.arb` (con `@descripción`) y a `app_en.arb` (puede ser traducción provisional).
- Textos con variables → placeholders, nunca concatenación.
- Fechas/números → `intl` con `Localizations.localeOf(context)`.
- Al migrar una pantalla, migra TODOS sus strings; una pantalla a medias confunde.
- Textos bíblicos (versículos) NO se localizan: vienen de la versión de la Biblia elegida.
