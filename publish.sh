#!/usr/bin/env bash
# publish.sh — copia un HTML self-contained al canal ha-public, regenera index, commit, push.
# Uso:
#   publish.sh <ruta/al/artefacto.html> [nombre-en-url]
#
# Si no se pasa <nombre-en-url>, se usa el basename del archivo (sin .html).
# El archivo debe ser self-contained (CSS/JS/imágenes inline o data-uri). GitHub Pages
# sirve tal cual; no hay build server-side (.nojekyll).

set -euo pipefail

PUB_DIR="$HOME/Documents/ha-public"

if [ $# -lt 1 ]; then
  echo "Uso: $0 <ruta/al/artefacto.html> [nombre-en-url]" >&2
  exit 2
fi

SRC="$1"
if [ ! -f "$SRC" ]; then
  echo "ERROR: no existe el archivo: $SRC" >&2
  exit 1
fi

case "$SRC" in
  *.html|*.htm) ;;
  *) echo "ERROR: solo se publican .html/.htm (sin build server). Recibido: $SRC" >&2; exit 1 ;;
esac

# Nombre destino (sin .html, kebab-case sugerido por convención)
if [ $# -ge 2 ]; then
  NAME="$2"
else
  NAME="$(basename "$SRC" .html)"
  NAME="$(basename "$NAME" .htm)"
fi

DEST="$PUB_DIR/${NAME}.html"

cd "$PUB_DIR"

# Sanity: no estamos sobreescribiendo algo distinto sin avisar
if [ -f "$DEST" ]; then
  if cmp -s "$SRC" "$DEST"; then
    echo "ya idéntico, nada que publicar: ${NAME}.html"
    exit 0
  fi
  echo "Aviso: sobreescribiendo ${NAME}.html con versión nueva (la anterior queda en git history)."
fi

cp "$SRC" "$DEST"

# Regenerar index.html con listado simple
"$PUB_DIR/.scripts/build-index.sh"

git add -A
COMMIT_MSG="publish: ${NAME} ($(date '+%Y-%m-%d %H:%M'))"
git commit -m "$COMMIT_MSG"
git push origin main

echo ""
echo "Publicado:"
echo "  https://edgarbarroso.github.io/ha-public/${NAME}.html"
echo ""
echo "(GitHub Pages tarda ~30 seg en propagar el primer hit; refrescar si da 404.)"
