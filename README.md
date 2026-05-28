# ha-public

Canal de publicación HTML de Edgar Barroso. Self-contained HTMLs servidos vía GitHub Pages.

URL base: <https://edgarbarroso.github.io/ha-public/>

## Para qué

Publicar artefactos puntuales que ya viven como HTML self-contained en uno de los vaults HA: decks, dashboards, consejos renderizados, reports, demos, prototipos. Este repo NO almacena el pensamiento ni los borradores — esos viven en sus vaults (ha-eb, ha-ha, ha-tec, ha-research, ha-al). Aquí solo aterriza la salida final renderizada.

Cero procesamiento server-side. `.nojekyll` apaga Jekyll; GitHub Pages sirve los archivos tal cual.

## Flujo

```bash
# desde cualquier vault, con el HTML self-contained ya generado:
~/Documents/ha-public/publish.sh <ruta/al/artefacto.html> [nombre-en-url]

# ejemplo:
~/Documents/ha-public/publish.sh ~/Documents/ha-ha/06-projects/teradata/deck-teradata.html teradata-williams-2026-06
```

El script: copia el HTML al raíz de `ha-public/`, regenera `index.html` (listado de lo publicado), commit, push. URL queda viva en <https://edgarbarroso.github.io/ha-public/{nombre}.html> en ~30 seg.

## Despublicar

```bash
~/Documents/ha-public/unpublish.sh <nombre-en-url>
```

Mueve a `_archive/` (no borra). Si quieres remoción dura, hazla a mano con `git rm` y push.

## Por qué este repo y no GitHub Pages de cada vault

Los vaults son grandes (ha-ha ~2.5GB), exceden el límite publicable de Pages (1GB), y mezclan trabajo crudo con artefactos finales — Pages auto-trigger en cada push de obsidian-git inunda Actions con builds fallidos. `ha-public` es un repo ligero, intencional: solo se mueve cuando Edgar decide publicar algo.

## Cuentas

Hoy: `edgarbarroso/ha-public` (cuenta personal). Si en el futuro se necesita separación de identidad (HA business vs research vs personal), se replica el patrón a `edgarbarrosoha/ha-public` y `ebarrosoresearch/ha-public`.
