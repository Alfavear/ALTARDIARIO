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

## Migración de datos privados del perfil

Los perfiles públicos guardaban `email` y `fcmToken` en `usuarios/{uid}`, un
documento de lectura pública. El modelo nuevo los guarda en
`usuarios/{uid}/private/account`, que solo puede leer su dueño. La migración
mueve los datos que ya existen.

```bash
cd functions && npm install
# informe: no escribe nada
npm run migrate:private-account -- --project altardiario-ec25f
# aplicar
npm run migrate:private-account -- --project altardiario-ec25f --apply
```

- Requiere la cuenta de servicio con rol `Firebase Admin`
  (`GOOGLE_APPLICATION_CREDENTIALS`).
- Es **idempotente**: se puede repetir; los perfiles ya migrados no se tocan.
- Si el documento privado ya tiene el campo, **gana el privado**: no se
  sobrescribe el token de FCM más reciente.
- Verificación: la segunda pasada debe dejar `perfiles con datos privados: 0`.

### Orden de operaciones (no alterar)

1. Publica la versión de la app que escribe en `private/account`.
2. Ejecuta la migración (informe y después `--apply`).
3. Despliega las reglas endurecidas de `/usuarios`.
4. Repite la migración hasta que no quede ningún perfil con datos privados.

> **Clientes antiguos.** Las versiones ya publicadas en Play Store siguen
> escribiendo `email`/`fcmToken` en el documento público. Si las reglas
> endurecidas se despliegan antes de que esas versiones se actualicen, sus
> escrituras se deniegan: el usuario pierde el token de FCM y el guardado de
> perfil. Por eso la app y la migración van **antes** de endurecer las reglas,
> y la ventana de compatibilidad se decide con el humano (tarea T-018 del
> roadmap).

## Reportar una vulnerabilidad
Abre un issue privado o escribe al mantenedor. No publiques detalles hasta que haya parche.
