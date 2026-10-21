# Publicar una versión

1. `main` en verde (`scripts/check.sh`).
2. `/release` en OpenCode, o manual:
   - `pubspec.yaml` → `version: X.Y.Z+B` (B = build anterior + 1)
   - `CHANGELOG.md` → mover `[Unreleased]` a `[X.Y.Z] - fecha`
   - `git commit -m "chore(release): vX.Y.Z" && git tag vX.Y.Z && git push --follow-tags`
3. `release-android.yml` genera el `.aab` y lo adjunta al GitHub Release.
4. Play Console: pista interna → cerrada → producción. Notas de la versión desde el CHANGELOG.
5. iOS: `flutter build ipa` en macOS → Transporter / Xcode → TestFlight → App Store.
6. Web: se despliega sola al mergear en `main`.
7. Si la versión es obligatoria: Firestore `config/app` → `minVersion`.

## Secrets de GitHub necesarios
- `FIREBASE_SERVICE_ACCOUNT`: JSON de cuenta de servicio (Firebase Admin).
- `ANDROID_KEYSTORE_BASE64`: `base64 -w0 upload-keystore.jks`.
- `GOOGLE_SERVICES_JSON_BASE64`: `base64 -w0 android/app/google-services.json` (lo usa la CI; el archivo sigue sin versionarse).
- `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
