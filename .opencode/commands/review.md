---
description: Revisión de código del diff actual (o de una rama contra main)
---
Invoca al subagente `reviewer` sobre `$ARGUMENTS` (si está vacío: el diff actual
staged + working tree; si es un nombre de rama: `git diff main...<rama>`).
Devuélveme su informe sin editarlo.
