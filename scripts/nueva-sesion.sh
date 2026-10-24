#!/usr/bin/env bash
# Crea el espacio de trabajo de una sesión: carpeta propia con SU configuración de OpenCode
# (skills, MCPs y plugins de su carril) y un worktree nuevo desde origin/main.
#
#   scripts/nueva-sesion.sh <integradora|plataforma|producto> <T-xxx> [slug]
#
# Disposición (fuera del repo):
#   $ALTARDIARIO_SESIONES/<sesion>/opencode.jsonc      <- plantilla de .opencode/sesiones/<sesion>.jsonc
#   $ALTARDIARIO_SESIONES/<sesion>/<T-xxx>-<slug>/     <- worktree; abre OpenCode AQUÍ
# OpenCode busca opencode.jsonc desde el directorio de trabajo hacia arriba, así que el de la
# carpeta de la sesión aplica a todos sus worktrees y no a los de las otras sesiones.
# Ver docs/CAPACIDADES.md y docs/FLUJO.md.
set -euo pipefail

sesion="${1:-}"; tarea="${2:-}"; slug="${3:-trabajo}"
case "$sesion" in
  integradora) prefijo=i ;;
  plataforma)  prefijo=a ;;
  producto)    prefijo=b ;;
  *) echo "Uso: $0 <integradora|plataforma|producto> <T-xxx> [slug]" >&2; exit 2 ;;
esac
[[ "$tarea" =~ ^T-[0-9]{3}$ ]] || { echo "La tarea debe tener la forma T-123 (la reserva es un PR con ese ID)." >&2; exit 2; }
[[ "$slug" =~ ^[a-z0-9-]+$ ]] || { echo "El slug solo admite minúsculas, números y guiones." >&2; exit 2; }

repo="$(cd "$(dirname "$0")/.." && pwd)"
base="${ALTARDIARIO_SESIONES:-$(cd "$repo/.." && pwd)/sesiones}"
rama="$prefijo/$tarea-$slug"
carpeta="$base/$sesion"
wt="$carpeta/$tarea-$slug"
plantilla="$repo/.opencode/sesiones/$sesion.jsonc"

[ -f "$plantilla" ] || { echo "Falta la plantilla $plantilla (¿estás en un checkout al día de main?)" >&2; exit 1; }
[ -e "$wt" ] && { echo "Ya existe $wt" >&2; exit 1; }
git -C "$repo" show-ref --verify --quiet "refs/heads/$rama" && { echo "Ya existe la rama $rama" >&2; exit 1; }

# Todo lo que puede fallar se comprueba ANTES de crear nada (así no quedan restos a medias).
# node en Windows no entiende rutas /d/…: se le pasa la ruta de Windows (cygpath -m).
repo_node="$(cygpath -m "$repo" 2>/dev/null || echo "$repo")"
app_id="$(node -e "const c=JSON.parse(require('fs').readFileSync(process.argv[1]+'/scripts/gh-apps.json','utf8'));console.log(c.apps[process.argv[2]]||'')" "$repo_node" "$sesion")"
[ -n "$app_id" ] || { echo "No hay App ID de «$sesion» en scripts/gh-apps.json" >&2; exit 1; }

git -C "$repo" fetch --quiet origin
mkdir -p "$carpeta"
if [ -f "$carpeta/opencode.jsonc" ] && ! cmp -s "$plantilla" "$carpeta/opencode.jsonc"; then
  echo "⚠ $carpeta/opencode.jsonc difiere de la plantilla del repo; se conserva. Compáralo con $plantilla"
else
  cp "$plantilla" "$carpeta/opencode.jsonc"
fi

git -C "$repo" worktree add -q "$wt" -b "$rama" origin/main
sha="$(git -C "$wt" rev-parse --short HEAD)"

# Identidad de Git propia de este worktree (la de la app de la sesión)
git -C "$repo" config extensions.worktreeConfig true
git -C "$wt" config --worktree user.name "altardiario-$sesion[bot]"
git -C "$wt" config --worktree user.email "$app_id+altardiario-$sesion[bot]@users.noreply.github.com"

cat <<EOF

✔ Sesión «$sesion» lista
  worktree : $wt   (rama $rama desde origin/main @ $sha)
  config   : $carpeta/opencode.jsonc
  abre OpenCode en: $wt

  Token de esta sesión (compruébalo: no debe salir vacío):
    T=\$(node scripts/gh-app-token.mjs $sesion); [ -n "\$T" ] || echo "TOKEN VACÍO: gh usaría la cuenta del Owner"
  Reserva la tarea con un PR en borrador que lleve $tarea en el título.
  Al terminar: borra la rama y el worktree (git worktree remove "$wt").
EOF
