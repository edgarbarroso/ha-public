#!/usr/bin/env bash
# unpublish.sh — quita un HTML de un canal, lo mueve a _archive/ (no borra), commit, push.
# Uso:
#   unpublish.sh [--channel <nombre>] <nombre-en-url>     # sin .html
#
# --channel  personal (default) | ha   — ver .scripts/channels.sh
# El archivo queda en _archive/<nombre>-<timestamp>.html — recuperable.
# Para remoción dura: git rm + push manual.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=.scripts/channels.sh
source "$SCRIPT_DIR/.scripts/channels.sh"

# --- parse flags ---
CHANNEL="personal"
POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --channel) CHANNEL="${2:?--channel requiere un valor}"; shift 2 ;;
    --channel=*) CHANNEL="${1#*=}"; shift ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done
set -- "${POSITIONAL[@]:-}"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
  echo "Uso: $0 [--channel personal|ha] <nombre-en-url>  (sin .html)" >&2
  exit 2
fi

resolve_channel "$CHANNEL"
ensure_channel_dir
PUB_DIR="$CH_DIR"

NAME="$1"
NAME="${NAME%.html}"
NAME="${NAME%.htm}"
SRC="$PUB_DIR/${NAME}.html"

if [ ! -f "$SRC" ]; then
  echo "ERROR: no existe ${NAME}.html en el canal '$CHANNEL' ($PUB_DIR)" >&2
  exit 1
fi

cd "$PUB_DIR"

mkdir -p _archive
TS="$(date '+%Y%m%d-%H%M%S')"
DEST="_archive/${NAME}-${TS}.html"
git mv "${NAME}.html" "$DEST"

# Regenerar index (en el dir del canal)
PUB_DIR="$PUB_DIR" REPO_SLUG="$CH_REPO" "$SCRIPT_DIR/.scripts/build-index.sh"

git add -A
git commit -m "unpublish: ${NAME} (archivado a ${DEST})"
git push origin main

echo ""
echo "Despublicado (canal: $CHANNEL):"
echo "  ${CH_URL}/${NAME}.html  → 404 en ~30 seg"
echo ""
echo "Archivo preservado en: ${PUB_DIR##*/}/${DEST}"
