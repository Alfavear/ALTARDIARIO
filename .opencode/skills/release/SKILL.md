---
name: release
description: Proceso de publicación de una versión (bump, CHANGELOG, tag, builds, tiendas, config remota de versión mínima).
---

# Release

Ver también `docs/RELEASE.md`.

1. `main` limpio y `scripts/check.sh` en verde.
2. Decidir bump semántico a partir de `[Unreleased]` en `CHANGELOG.md`.
3. `pubspec.yaml`: `version: X.Y.Z+B` — B (build number) SIEMPRE +1, nunca se repite; Play Store lo rechaza.
4. Mover `[Unreleased]` → `[X.Y.Z] - YYYY-MM-DD`.
5. `git commit -m "chore(release): vX.Y.Z"` → `git tag vX.Y.Z` → `git push --follow-tags` (con confirmación humana).
6. El tag dispara `release-android.yml` → `.aab` adjunto al GitHub Release.
7. Manual: subir `.aab` a Play Console (pista interna → producción), iOS con Xcode/Transporter, web se despliega sola al mergear.
8. Si la release obliga a actualizar (cambio de reglas incompatible): actualizar `config/app.minVersion` en Firestore para que `update_service.dart` avise.

Nunca hacer release desde una rama que no sea `main`.
