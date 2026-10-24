#!/usr/bin/env bash
# Pone el main LOCAL al día con origin/main.
#
# Uso:  scripts/sync-main.sh
#
# Reglas:
#   - Solo fast-forward. Si el main local tiene commits propios, NO lo toca:
#     te dice cómo rescatarlos. Esos commits son trabajo que no está en el remoto.
#   - Si main está checkout en algún worktree, no lo mueve por debajo: te dice
#     dónde actualizarlo.
#
# El main local no se usa para trabajar (se ramifica desde origin/main), pero
# tenerlo al día evita que alguna sesión lo lea y saque conclusiones de hace
# 99 commits.
set -euo pipefail

git fetch --quiet origin main

if ! git rev-parse --verify --quiet refs/heads/main >/dev/null; then
  echo "No hay main local en este clon. Nada que hacer."
  exit 0
fi

remote_sha=$(git rev-parse origin/main)
behind=$(git rev-list --count "main..$remote_sha")
ahead=$(git rev-list --count "$remote_sha..main")
echo "main local: $(git rev-parse --short main) ($behind detrás, $ahead delante)"
echo "origin/main: $(git rev-parse --short "$remote_sha")"

if [ "$ahead" -gt 0 ]; then
  cat <<EOF

main local DIVERGIÓ: tiene $ahead commit(s) que no están en origin/main.
No lo toco, porque eso es trabajo que solo existe aquí.

Rescátalo primero:

  git branch rescate/main-local-\$(date +%Y%m%d-%H%M) main
  git push -u origin rescate/main-local-\$(date +%Y%m%d-%H%M)

y después:

  git branch -f main origin/main

Revisa qué hay en esos commits antes de dar nada por perdido.
EOF
  exit 1
fi

if [ "$behind" -eq 0 ]; then
  echo "Ya está al día."
  exit 0
fi

if git worktree list --porcelain | grep -qx "branch refs/heads/main"; then
  echo "main está checkout en un worktree: actualízalo allí con:"
  echo "  git merge --ff-only origin/main"
  exit 1
fi

git branch -f main "$remote_sha"
echo "main local actualizado a $(git rev-parse --short main)."
