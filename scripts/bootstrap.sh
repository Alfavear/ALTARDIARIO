#!/usr/bin/env bash
# Prepara un entorno de desarrollo desde cero (humano o agente).
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶ Verificando herramientas…"
for t in flutter dart git node npm java; do
  if ! command -v "$t" > /dev/null; then echo "  ✗ falta: $t"; MISSING=1; else echo "  ✓ $t"; fi
done
[ "${MISSING:-0}" = 1 ] && { echo "Instala las herramientas faltantes y vuelve a correr."; exit 1; }

echo "▶ flutter pub get"
flutter pub get

if [ ! -f .env ]; then
  cp .env.example .env
  echo "▶ Creado .env desde .env.example (rellena las claves si las necesitas)"
fi

echo "▶ Dependencias de tests de reglas"
(cd firestore-tests && npm install --silent)
echo "▶ MCP del roadmap"
(cd tools/roadmap-mcp && npm install --silent && npm test --silent)
node tools/roadmap-mcp/cli.mjs render

echo "▶ Instalando hooks versionados (pre-commit ligero, pre-push con tests y reglas)"
chmod +x scripts/hooks/*
git config core.hooksPath scripts/hooks

echo
echo "✔ Listo. Corre 'scripts/check.sh' para validar, o 'opencode' para trabajar con el agente."
