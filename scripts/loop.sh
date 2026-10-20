#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
#  Bucle autónomo: corre N ciclos de /cycle sin intervención.
#
#  Uso:  scripts/loop.sh [N=1] [--model proveedor/modelo]
#  Parar: touch roadmap/STOP   (o Ctrl-C)
#
#  Cada ciclo deja una rama auto/<task>-<slug> con commits, actualiza
#  roadmap/tasks.yaml, BITACORA.md y STATE.md. Nunca hace push.
#  Requiere: opencode (V2) con un modelo configurado, flutter, node, java.
# ─────────────────────────────────────────────────────────────────────
set -euo pipefail
cd "$(dirname "$0")/.."

N="${1:-1}"; shift || true
EXTRA=("$@")
rm -f roadmap/STOP

command -v opencode >/dev/null || { echo "✗ opencode no está instalado: https://opencode.ai"; exit 1; }

echo "▶ Verificando entorno base (scripts/check.sh --fast)…"
if ! scripts/check.sh --fast > /tmp/altardiario-precheck.log 2>&1; then
  echo "✗ El entorno base no pasa check.sh. No se arranca el bucle sobre una base rota."
  tail -30 /tmp/altardiario-precheck.log
  exit 1
fi

BASE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
echo "▶ Rama base: $BASE_BRANCH · ciclos: $N"
node tools/roadmap-mcp/cli.mjs validate

FAILS=0; LAST_TASK=""
for i in $(seq 1 "$N"); do
  [ -f roadmap/STOP ] && { echo "■ STOP detectado"; break; }
  [ "${LOOP_STOP:-0}" = 1 ] && { echo "■ LOOP_STOP=1"; break; }

  BEFORE="$(node tools/roadmap-mcp/cli.mjs next | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{const j=JSON.parse(s);console.log(j.task?j.task.id:"none")})')"
  [ "$BEFORE" = "none" ] && echo "▶ Sin tarea elegible: el ciclo ejecutará una auditoría."

  echo
  echo "═══════════════ Ciclo $i/$N · tarea candidata: $BEFORE ═══════════════"
  git checkout -q "$BASE_BRANCH"

  # opencode run: sesión no interactiva. --agent selecciona el orquestador.
  opencode run --agent orchestrator "${EXTRA[@]}" \
    "Ejecuta un ciclo autónomo completo según la skill autonomous-loop. Rama base: $BASE_BRANCH." \
    | tee "roadmap/audits/.last-cycle.log" || true

  node tools/roadmap-mcp/cli.mjs render >/dev/null
  LAST_LINE="$(grep -E '^\- \*\*Resultado:\*\*' roadmap/BITACORA.md | tail -1 || true)"
  echo "▶ $LAST_LINE"

  if echo "$LAST_LINE" | grep -q 'failed'; then
    if [ "$LAST_TASK" = "$BEFORE" ]; then FAILS=$((FAILS+1)); else FAILS=1; fi
    LAST_TASK="$BEFORE"
    if [ "$FAILS" -ge 2 ]; then echo "■ Dos fallos seguidos en $BEFORE: parando para que un humano revise."; break; fi
  else
    FAILS=0
  fi
done

git checkout -q "$BASE_BRANCH"
echo
echo "═══════════════ Resumen ═══════════════"
node tools/roadmap-mcp/cli.mjs state | head -25
echo
echo "Ramas producidas:"; git branch --list 'auto/*' | sed 's/^/  /'
echo
echo "Siguiente paso humano: revisar ramas auto/*, abrir PRs, resolver tareas blocked."
