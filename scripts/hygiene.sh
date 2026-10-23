#!/usr/bin/env bash
# Informe de higiene del repo y de las sesiones. Solo informa; --apply borra ÚNICAMENTE
# ramas locales ya mergeadas en origin/main (con `branch -d`) y poda worktrees muertos.
set -euo pipefail
cd "$(dirname "$0")/.."
git fetch --quiet origin main --prune || true

echo "== Worktrees (uno por sesión; ninguno en HEAD desacoplado sin dueño)"
git worktree list
echo
echo "== Ramas locales ya mergeadas en origin/main"
merged=$(git branch --merged origin/main --format='%(refname:short)' | grep -vE '^(main|master)$' || true)
if [ -n "$merged" ]; then echo "$merged"; else echo "(ninguna)"; fi
echo
echo "== Ramas locales SIN push (trabajo que solo existe aquí)"
for b in $(git branch --format='%(refname:short)'); do
  git rev-parse --verify --quiet "origin/$b" > /dev/null || echo "$b"
done
echo
echo "== Peso y suciedad"
du -sh build .dart_tool coverage 2> /dev/null || true
ls ./*.apk ./*.xlsx 2> /dev/null | sed 's/^/suelto en raíz: /' || true
git status --porcelain | grep '^??' | sed 's/^/sin trackear: /' || true

if [ "${1:-}" = "--apply" ]; then
  echo
  echo "== --apply"
  git worktree prune
  if [ -n "$merged" ]; then
    # `branch -d` (no -D) rehúsa borrar lo no mergeado y lo que otro worktree usa.
    echo "$merged" | while read -r b; do git branch -d "$b" || true; done
  fi
fi
