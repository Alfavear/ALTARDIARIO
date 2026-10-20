---
description: Auditoría de seguridad completa (reglas + servicio + secretos)
---
1. Invoca al subagente `rules-auditor` para auditar `firestore.rules`.
2. Busca en `lib/` consultas sin `.limit()`, uso de `print(`, y lecturas de
   colecciones completas (`getAll`).
3. Verifica con `git ls-files` que no hay `.env`, `google-services.json`,
   `GoogleService-Info.plist`, `*.jks` ni `key.properties` versionados.
4. Entrega un informe único ordenado por severidad.
