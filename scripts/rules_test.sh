#!/usr/bin/env bash
# Corre la suite de tests de reglas de Firestore contra el emulador.
# Requiere: Node 20+, Java 17+ (para el emulador).
set -euo pipefail
cd "$(dirname "$0")/../firestore-tests"
if [ ! -d node_modules ]; then
  echo "▶ Instalando dependencias de firestore-tests…"
  npm ci --silent || npm install --silent
fi
echo "▶ Levantando emulador de Firestore y ejecutando tests de reglas…"
npx firebase emulators:exec --only firestore --project altardiario-ec25f "node --test rules.test.mjs"
