#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
#  Puerta de calidad única de AltarDiario.
#  Lo que corre aquí es EXACTAMENTE lo que corre la CI. Si pasa local,
#  pasa en GitHub. Úsalo antes de cada commit y haz que el agente lo use.
#
#  Uso:  scripts/check.sh            # todo
#        scripts/check.sh --fast     # sin tests de reglas (no requiere Java)
#        scripts/check.sh --fix      # formatea en lugar de solo verificar
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

FAST=0; FIX=0
for a in "$@"; do
  case "$a" in
    --fast) FAST=1 ;;
    --fix)  FIX=1 ;;
  esac
done

step() { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }

step "flutter pub get"
flutter pub get > /dev/null

step "dart format"
if [ "$FIX" = 1 ]; then
  dart format lib test
else
  dart format --output=none --set-exit-if-changed lib test
fi

step "flutter analyze"
flutter analyze --no-pub

step "flutter test"
flutter test --no-pub --coverage

if [ "$FAST" = 0 ]; then
  step "tests de reglas de Firestore (emulador)"
  scripts/rules_test.sh
else
  echo "(--fast) saltando tests de reglas de Firestore"
fi

printf '\n\033[1;32m✔ Todo en verde.\033[0m\n'
