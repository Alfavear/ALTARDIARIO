#!/usr/bin/env bash
# Estado de coordinación para sesiones concurrentes.
#
# Uso:  scripts/session-check.sh
#
# No modifica nada: solo informa. Si sales "desfasado", lo primero es
#   git fetch origin && git merge origin/main
# y antes de abrir un PR, mira que el diff no incluya ficheros que no has tocado.
set -euo pipefail

git fetch --quiet origin main 2>/dev/null || true

rama=$(git branch --show-current 2>/dev/null || true)
[ -z "$rama" ] && rama="(detached HEAD)"

behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)
main_sha=$(git rev-parse --short origin/main 2>/dev/null || echo "?")
head_sha=$(git rev-parse --short HEAD 2>/dev/null || echo "?")

echo "worktree : $(pwd)"
echo "rama     : $rama"
echo "HEAD     : $head_sha"
echo "main ref : $main_sha"

if [ "$behind" -gt 0 ]; then
  echo "desfase  : $behind commits por detrás de origin/main"
  echo "           -> git merge origin/main  (antes de nada)"
else
  echo "desfase  : al día con origin/main"
fi

# El main local no se usa para trabajar, pero conviene saber si envejece.
if git rev-parse --verify --quiet refs/heads/main >/dev/null; then
  mb=$(git rev-list --count main..origin/main 2>/dev/null || echo 0)
  ma=$(git rev-list --count origin/main..main 2>/dev/null || echo 0)
  if [ "$ma" -gt 0 ]; then
    echo "main loc.: $mb detrás y $ma DELANTE (divergió: rescátalo, ver docs/SESIONES.md)"
  else
    echo "main loc.: $mb por detrás (scripts/sync-main.sh lo pone al día)"
  fi
fi

echo
echo "worktrees:"
git worktree list 2>/dev/null | sed 's/^/  /'

if command -v gh >/dev/null 2>&1; then
  echo
  echo "PRs abiertos:"
  gh pr list --limit 30 --json number,headRefName,title \
    --jq '.[] | "  #\(.number) \(.headRefName) — \(.title)"' 2>/dev/null \
    || echo "  (no se pudo consultar gh)"
fi

echo
echo "Sesiones registradas:"
if [ -d roadmap/sesiones ]; then
  for f in roadmap/sesiones/*.md; do
    [ -e "$f" ] || continue
    case "$(basename "$f")" in
      README.md | PLANTILLA.md) continue ;;
    esac
    echo "  $(basename "$f" .md)"
  done
else
  echo "  (sin registro; ver docs/SESIONES.md §5)"
fi
