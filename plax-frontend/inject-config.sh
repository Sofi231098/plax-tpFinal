#!/bin/sh
set -e

INDEX_FILE="/usr/share/nginx/html/index.html"

# Inyectar config.js SOLO si no existe
if ! grep -q 'config.js' "$INDEX_FILE"; then
  sed -i '/<\/head>/i <script src="\/config.js"><\/script>' "$INDEX_FILE"
fi

# Arrancar nginx
nginx -g 'daemon off;'
