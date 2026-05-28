#!/usr/bin/env bash
# unpublish.sh — quita un HTML del canal, lo mueve a _archive/ (no borra), commit, push.
# Uso:
#   unpublish.sh <nombre-en-url>     # sin .html
#
# El archivo queda en _archive/<nombre>-<timestamp>.html — recuperable.
# Para remoción dura: git rm + push manual.

set -euo pipefail

PUB_DIR="$HOME/Documents/ha-public"

if [ $# -lt 1 ]; then
  echo "Uso: $0 <nombre-en-url>  (sin .html)" >&2
  exit 2
fi

NAME="$1"
NAME="${NAME%.html}"
NAME="${NAME%.htm}"
SRC="$PUB_DIR/${NAME}.html"

if [ ! -f "$SRC" ]; then
  echo "ERROR: no existe ${NAME}.html en ha-public/" >&2
  exit 1
fi

cd "$PUB_DIR"

mkdir -p _archive
TS="$(date '+%Y%m%d-%H%M%S')"
DEST="_archive/${NAME}-${TS}.html"
git mv "${NAME}.html" "$DEST"

# Regenerar index
"$PUB_DIR/.scripts/build-index.sh"

git add -A
git commit -m "unpublish: ${NAME} (archivado a ${DEST})"
git push origin main

echo ""
echo "Despublicado:"
echo "  https://edgarbarroso.github.io/ha-public/${NAME}.html  → 404 en ~30 seg"
echo ""
echo "Archivo preservado en: ha-public/${DEST}"
