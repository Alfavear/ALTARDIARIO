---
description: Corre la puerta de calidad (format, analyze, test) y arregla lo que falle
---
Ejecuta `scripts/check.sh --fast`. Si falla:
- Errores de formato: corre `scripts/check.sh --fix` y vuelve a verificar.
- Warnings de analyze: arréglalos en el código, no los silencies con `// ignore`.
- Tests rotos: investiga la causa raíz. Nunca borres ni `skip`-ees un test.
Pega la salida final y confirma que todo está en verde.
