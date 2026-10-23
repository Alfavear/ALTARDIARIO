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
| Acoso tras bloquear (comentar, escribir en el chat, notificar, seguir) | `blockBetween()` en reglas: si A bloqueó a B, ninguno de los dos escribe en el contenido del otro |
| Secretos en el repo | `.gitignore`, permisos `deny` en OpenCode, CODEOWNERS |

## Bloqueo real (T-053)

Bloquear no solo oculta contenido en el cliente: **impide escribir**. Si Alice
bloqueó a Bob, el bloqueo es **simétrico** a efectos de escritura: Bob no puede
comentar la reflexión o la petición de Alice, responder su debate, escribirle en
el chat, crearle notificaciones ni seguirla; y Alice tampoco puede hacerlo sobre
el contenido de Bob (el cliente ya se lo oculta, así que no hay camino legítimo).

Qué **sí** sigue permitido:

- Leer contenido público. El bloqueo no es una regla de lectura: ocultar es
  cliente (T-022, T-023). Convertirlo en regla costaría lecturas en cada `list`.
- Escribir en el **propio** contenido (Bob comenta su propia reflexión).
- **Dejar de seguir**: `addsFollower()` distingue añadirse de quitarse, para que
  el bloqueado pueda limpiar su rastro de la lista de seguidores del otro.

Coste: cada `blockBetween()` son **2 lecturas** de `usuarios/{uid}/blocked/{uid}`
(una por dirección). El límite de Firestore es 10 lecturas por request de un
solo documento; el peor caso aquí es un mensaje de chat: `get` del chat + 4
`exists` = 5. Se acepta el coste porque solo lo pagan las escrituras.

Límite conocido: las reglas no recorren listas, así que el chequeo de chat
comprueba solo los dos primeros `participantIds`. Es suficiente porque `/chats`
exige exactamente 2 participantes en `create` y `update`; un chat antiguo de
grupo quedaría parcialmente cubierto. Los likes, reacciones y votos no se
bloquean (camino caliente y daño bajo: el cliente ya oculta el contenido).

Cobertura: 6 tests en `firestore-tests/rules.test.mjs` (bloqueo → `permission-denied`,
tercero sin bloqueo → permitido, simetría, chat, notificaciones y seguimiento).

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
