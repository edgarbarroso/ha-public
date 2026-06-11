#!/usr/bin/env bash
# channels.sh — registro de canales de publicación de ha-public.
# Cada canal = un repo GitHub Pages distinto. Sourced por publish.sh / unpublish.sh.
#
# resolve_channel <nombre>  -> exporta:
#   CH_DIR   working tree local
#   CH_URL   URL base de GitHub Pages (sin slash final)
#   CH_REPO  slug owner/repo (para el footer del index y mensajes)
#   CH_CLONE remote git (con alias SSH correcto) para auto-clonar si falta el working tree
#
# Para agregar un canal nuevo: añade un case. Nada más.

resolve_channel() {
  case "${1:-personal}" in
    personal|eb|edgarbarroso)
      CH_DIR="$HOME/Documents/ha-public"
      CH_URL="https://edgarbarroso.github.io/ha-public"
      CH_REPO="edgarbarroso/ha-public"
      CH_CLONE="git@github.com:edgarbarroso/ha-public.git"
      ;;
    ha|business|ha-ha|edgarbarrosoha)
      CH_DIR="$HOME/Documents/ha-public-ha"
      CH_URL="https://edgarbarrosoha.github.io/ha-public"
      CH_REPO="edgarbarrosoha/ha-public"
      CH_CLONE="git@github.com-edgarbarrosoha:edgarbarrosoha/ha-public.git"
      ;;
    *)
      echo "ERROR: canal desconocido '$1'. Válidos: personal (default), ha." >&2
      return 1
      ;;
  esac
  export CH_DIR CH_URL CH_REPO CH_CLONE
}

# ensure_channel_dir — clona el working tree del canal si no existe localmente.
ensure_channel_dir() {
  if [ ! -d "$CH_DIR/.git" ]; then
    echo "Working tree del canal no existe; clonando $CH_REPO → $CH_DIR ..." >&2
    git clone "$CH_CLONE" "$CH_DIR" >&2 || {
      echo "ERROR: no se pudo clonar $CH_CLONE" >&2
      return 1
    }
  fi
}
