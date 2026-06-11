#!/usr/bin/env bash
# build-index.sh — regenera index.html con listado simple de los HTMLs publicados.
# Sin dependencias (solo bash + ls + sed). Ejecutado por publish.sh y unpublish.sh.

set -euo pipefail

# Parametrizable por canal: publish.sh/unpublish.sh exportan PUB_DIR y REPO_SLUG.
PUB_DIR="${PUB_DIR:-$HOME/Documents/ha-public}"
REPO_SLUG="${REPO_SLUG:-edgarbarroso/ha-public}"
INDEX="$PUB_DIR/index.html"

cd "$PUB_DIR"

# Listar .html en raíz, excluir el propio index.html
ITEMS=$(ls -1 *.html 2>/dev/null | grep -v '^index\.html$' | sort || true)

TODAY="$(date '+%Y-%m-%d %H:%M')"

{
  cat <<'HEAD'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ha-public — Edgar Barroso</title>
<style>
  :root { color-scheme: light dark; }
  body {
    font: 16px/1.5 -apple-system, BlinkMacSystemFont, "Inter", "Segoe UI", sans-serif;
    max-width: 720px;
    margin: 4rem auto 6rem;
    padding: 0 1.5rem;
    color: #1a1a1a;
    background: #fafaf7;
  }
  @media (prefers-color-scheme: dark) {
    body { color: #e7e7e3; background: #1a1a18; }
    a { color: #8ab4f8; }
    .meta { color: #7a7a76; }
    hr { border-color: #2a2a26; }
  }
  h1 {
    font-weight: 500;
    font-size: 1.4rem;
    letter-spacing: -0.01em;
    margin: 0 0 0.25rem;
  }
  .sub { color: #6a6a66; margin: 0 0 2rem; font-size: 0.95rem; }
  ul { list-style: none; padding: 0; margin: 0; }
  li {
    padding: 0.6rem 0;
    border-bottom: 1px solid #ececea;
  }
  @media (prefers-color-scheme: dark) {
    li { border-bottom-color: #2a2a26; }
  }
  li:last-child { border-bottom: none; }
  a {
    color: #1a4480;
    text-decoration: none;
    font-weight: 500;
  }
  a:hover { text-decoration: underline; }
  .meta {
    display: block;
    color: #888;
    font-size: 0.82rem;
    margin-top: 0.15rem;
  }
  .empty {
    color: #888;
    font-style: italic;
    padding: 2rem 0;
  }
  footer {
    margin-top: 4rem;
    font-size: 0.8rem;
    color: #888;
  }
  hr { border: none; border-top: 1px solid #ececea; margin: 3rem 0 1rem; }
</style>
</head>
<body>
<h1>ha-public</h1>
<p class="sub">Canal de publicación de Edgar Barroso. HTMLs self-contained servidos por GitHub Pages.</p>
HEAD

  if [ -z "$ITEMS" ]; then
    echo '<p class="empty">Sin publicaciones todavía.</p>'
  else
    echo '<ul>'
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      name="${f%.html}"
      # mtime humano-legible
      mtime=$(stat -f "%Sm" -t "%Y-%m-%d" "$f" 2>/dev/null || date -r "$f" '+%Y-%m-%d')
      # size humano-legible
      size=$(stat -f "%z" "$f" 2>/dev/null || stat -c "%s" "$f" 2>/dev/null || echo "")
      if [ -n "$size" ]; then
        if [ "$size" -gt 1048576 ]; then
          size_h="$(awk "BEGIN{printf \"%.1f MB\", $size/1048576}")"
        elif [ "$size" -gt 1024 ]; then
          size_h="$(awk "BEGIN{printf \"%.0f KB\", $size/1024}")"
        else
          size_h="${size} B"
        fi
      else
        size_h=""
      fi
      printf '  <li><a href="%s">%s</a><span class="meta">%s · %s</span></li>\n' \
        "$f" "$name" "$mtime" "$size_h"
    done <<< "$ITEMS"
    echo '</ul>'
  fi

  cat <<TAIL
<hr>
<footer>
  Actualizado ${TODAY} · <a href="https://github.com/${REPO_SLUG}">repo</a>
</footer>
</body>
</html>
TAIL
} > "$INDEX"

N=$(printf '%s\n' "$ITEMS" | grep -c . || true)
echo "index.html regenerado (${N} publicaciones)"
