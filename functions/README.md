# Cloud Functions

Lógica de servidor de AltarDiario. Aún **no desplegada** — ver `docs/adr/0002-gamificacion-en-servidor.md` para el plan de adopción.

```bash
cd functions && npm install
npm run build && npm test
npm run serve            # emulador local (functions + firestore)
firebase deploy --only functions   # solo con OK humano; requiere plan Blaze
```

Requiere el plan Blaze de Firebase (las funciones tienen cuota gratuita generosa).
