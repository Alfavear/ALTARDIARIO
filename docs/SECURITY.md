# Seguridad

## Modelo de amenazas (resumen)
| Amenaza | Mitigación |
|---|---|
| Usuario edita/borra contenido ajeno | `firestore.rules`: solo dueño; tests de regresión |
| Lectura de chats privados por terceros | regla `chats/*/messages` verifica participantes del padre |
| Inflar likes/XP/ranking | contadores ±1 con uid propio; XP a servidor (ADR-0002) |
| Spam de notificaciones / suplantación | `actorId == uid`, `read == false`, solo receptor lee |
| Abuso de cuota desde scripts | App Check (monitor → enforce) |
| Contenido inapropiado | `reports` + function de moderación + revisión humana |
| Secretos en el repo | `.gitignore`, permisos `deny` en OpenCode, CODEOWNERS |

## Secretos y dónde van
| Secreto | Dónde | Nunca |
|---|---|---|
| `google-services.json`, `GoogleService-Info.plist` | local, `flutterfire configure`; en CI, secret `GOOGLE_SERVICES_JSON_BASE64` | git |
| Keystore Android | `android/app/upload-keystore.jks` local + secret `ANDROID_KEYSTORE_BASE64` en GitHub | git |
| Cuenta de servicio Firebase | secret `FIREBASE_SERVICE_ACCOUNT` en GitHub | git, `.env` |
| `GOOGLE_STITCH_API_KEY` | `.env` / entorno | git |

Las API keys de `firebase_options.dart` son identificadores públicos; su
seguridad depende de las reglas y de App Check, no del secreto.

## Antes de desplegar reglas nuevas
1. `scripts/rules_test.sh` en verde.
2. Arranca el emulador (`firebase emulators:start --only firestore,auth`) y
   prueba la app apuntando a él (ver `FirebaseFirestore.instance.useFirestoreEmulator`).
3. Recorre: publicar, like, reaccionar, comentar, amén, seguir, chat.
4. Deploy. Vigila Crashlytics y los "permission-denied" en logs 24 h.

## Reportar una vulnerabilidad
Abre un issue privado o escribe al mantenedor. No publiques detalles hasta que haya parche.
