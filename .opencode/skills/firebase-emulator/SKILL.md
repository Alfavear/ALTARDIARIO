---
name: firebase-emulator
description: Reglas y protocolos para validación de Firestore Security Rules, Cloud Functions y pruebas en emuladores locales sin tocar producción.
---

# PROTOCOLO DE REGLAS DE SEGURIDAD Y FIRESTORE

Al modificar `firestore.rules` o endpoints en `functions/`:

## 1. Seguridad por Defecto (Zero Trust)
- Ninguna colección debe quedar expuesta con `allow read, write: if true;`.
- Toda regla debe exigir explícitamente `request.auth != null`.
- Las consultas y escrituras a recursos de usuario deben validar propiedad: `request.auth.uid == userId` o validar membresía mediante custom claims.

## 2. Validación Local
- Prohibido dar por buena una modificación de reglas sin ejecutar la suite de emulación correspondiente (`npm test` en `functions/` o pruebas locales de reglas).
- Si no hay emulador activo, redacta pruebas unitarias con `@firebase/rules-unit-testing` antes de solicitar el merge.
