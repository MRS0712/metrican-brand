#!/usr/bin/env bash
# Convierte un documento de marca en PDF A4, sin abrir un navegador a mano.
#
# El README decía "abrí el HTML y Ctrl+P". Funciona, pero deja el resultado a
# merced de la configuración de impresión de quien lo genere: márgenes,
# encabezados del navegador, escala. Dos personas producían dos PDF distintos
# del mismo archivo. Esto fija el resultado.
#
#   tools/render.sh manual-instalacion/*.html
#   tools/render.sh                          # todos los documentos del repo
#
# Los PDF salen en dist/ y NO se versionan: son generados, como el BOOT.md del
# repo de Oráculo. Lo que se versiona es la fuente.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SALIDA="$RAIZ/dist"
CHROME="${CHROME:-$(command -v chromium || command -v chromium-browser || command -v google-chrome)}"

[ -n "$CHROME" ] || { echo "No hay chromium/chrome instalado" >&2; exit 1; }
mkdir -p "$SALIDA"

# Sin argumentos: todos los HTML de documento del repo. Se excluyen los
# `- print.html` del brand book y el brochure, que son variantes de impresión
# de piezas antiguas con su propio flujo.
if [ $# -gt 0 ]; then
  archivos=("$@")
else
  mapfile -t archivos < <(find "$RAIZ" -name "*.html" -not -name "*- print.html" -not -path "*/dist/*" | sort)
fi

for f in "${archivos[@]}"; do
  [ -f "$f" ] || { echo "no existe: $f" >&2; continue; }
  abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
  nombre="$(basename "${f%.html}")"
  destino="$SALIDA/${nombre// /_}.pdf"

  # --virtual-time-budget le da tiempo a doc-page.js a paginar y a las fuentes
  # de Google a llegar. Sin eso el PDF sale sin paginar o con la tipografía
  # de reserva, que es peor que un error: se ve casi bien.
  "$CHROME" --headless --disable-gpu --no-sandbox \
    --virtual-time-budget=20000 \
    --no-pdf-header-footer \
    --print-to-pdf="$destino" \
    "file://${abs// /%20}" 2>/dev/null

  paginas="$(pdfinfo "$destino" 2>/dev/null | awk '/^Pages/{print $2}')"
  echo "$destino — ${paginas:-?} páginas"
done
