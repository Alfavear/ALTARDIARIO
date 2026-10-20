---
name: firestore-rules
description: Cómo escribir, acotar y testear reglas de seguridad de Firestore en AltarDiario. Usar SIEMPRE que se toque firestore.rules o se añada una colección/campo que otro usuario pueda escribir.
---

# Reglas de Firestore

## Principios
1. **Deny por defecto.** El `match /{document=**}` final deniega todo; cada colección se abre explícitamente.
2. **Nadie edita lo ajeno.** Un no-dueño solo toca contadores sociales, ±1, y solo con su propio uid.
3. **Sin test no hay regla.** Cada `allow` tiene al menos un test positivo y uno negativo en `firestore-tests/rules.test.mjs`.
4. **Las reglas deben casar con el servicio.** Antes de cambiar una regla, mira qué escribe `lib/data/services/firestore_service.dart` (campos exactos, `FieldValue.increment`, `arrayUnion`, `SetOptions(merge)`).

## Helpers disponibles (ya definidos en firestore.rules)
| Helper | Qué garantiza |
|---|---|
| `isOwner(data)` | `data.userId == uid` |
| `changedKeys()` | claves que cambian en el update |
| `listOnlyTouchesSelf('campo')` | la lista solo añade/quita mi uid |
| `mapOnlyTouchesSelf('campo')` | el mapa solo cambia en la clave mi-uid |
| `counterDeltaOk('campo')` | entero que varía como máximo ±1 |
| `likeOnly()` / `voteOnly()` | combinación de los anteriores |
| `ownerEditOk()` | dueño edita, pero no autoría ni contadores |

## Receta para una colección nueva con contenido de usuario
```
match /nueva/{id} {
  allow read: if true;                       // o acotar
  allow create: if signedIn()
    && request.resource.data.userId == uid()
    && request.resource.data.texto is string
    && request.resource.data.texto.size() <= 2000;
  allow update: if signedIn() && (ownerEditOk() || likeOnly());
  allow delete: if isOwner(resource.data);
}
```
Y su test:
```js
test('nueva: dueño edita, otro solo like', async () => {
  await admin(db => setDoc(doc(db,'nueva','x'), {userId: ALICE, texto:'a', likes:0, likedBy:[]}));
  await assertFails(updateDoc(doc(as(BOB),'nueva','x'), {texto:'b'}));
  await assertSucceeds(updateDoc(doc(as(BOB),'nueva','x'), {likes: increment(1), likedBy: arrayUnion(BOB)}));
});
```

## Trampas conocidas
- `resource.data.campo` falla si el campo no existe en docs viejos → usa `resource.data.get('campo', default)`.
- `diff()` solo detecta cambios de valor: escribir el mismo valor no cuenta como cambio (útil para `set(merge)`).
- `get()` en reglas cuesta una lectura y cuenta para el límite de 10 por request. Úsalo solo cuando no haya alternativa (chats).
- Los subdocumentos deben crearse DESPUÉS del padre si la regla consulta al padre (ver `sendMessage`).
- Cambiar reglas no es retrocompatible: lo que hoy escribe la app en producción debe seguir pasando. Corre `scripts/rules_test.sh` y, antes de desplegar, prueba la app contra el emulador.

## Comandos
```bash
scripts/rules_test.sh                                  # tests
firebase emulators:start --only firestore,auth         # probar la app contra el emulador
firebase deploy --only firestore:rules                 # SOLO tras OK humano (la CI lo hace al mergear en main)
```
