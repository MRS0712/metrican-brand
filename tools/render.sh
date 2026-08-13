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

# ── Dossier: ficha + manual encuadernados en un solo PDF ───────────────────
#
# Son dos documentos con dos públicos y dos ciclos de vida distintos, y por eso
# viven separados. Pero al cliente que recibe una unidad se le manda UNA cosa.
# Esto los une al final, en el PDF, sin duplicar una sola línea de fuente.
#
# Cada pieza conserva su numeración y su código de documento en el pie
# (DS-MC-2026, MI-MC-2026): es un dossier de dos secciones, no un documento
# de seis páginas — y así se lee.
if [ "${1:-}" = "--dossier" ]; then
  command -v pdfunite >/dev/null || { echo "falta pdfunite (poppler-utils)" >&2; exit 1; }
  bash "$0" "$RAIZ/ficha-tecnica/MetriCAN Ficha Tecnica.html" \
            "$RAIZ/manual-instalacion/MetriCAN Manual de Instalacion.html" >/dev/null
  destino="$SALIDA/MetriCAN_Dossier_Tecnico.pdf"
  pdfunite "$SALIDA/MetriCAN_Ficha_Tecnica.pdf" \
           "$SALIDA/MetriCAN_Manual_de_Instalacion.pdf" "$destino"
  echo "$destino — $(pdfinfo "$destino" | awk '/^Pages/{print $2}') páginas (ficha + manual)"
  exit 0
fi

# Sin argumentos: todos los documentos del repo, prefiriendo SIEMPRE la variante
# `- print.html` cuando existe.
#
# La primera versión hacía lo contrario —excluía los `- print.html`— y el brand
# book y el brochure salieron cortados. No era un problema de escala: sus páginas
# miden 1280×800 px, formato de presentación, y la variante interactiva no trae
# `@page`, así que chromium las imprimía sobre A4 vertical y recortaba. El
# `- print.html` sí declara `@page { size: A4 landscape }` y el `scale(0.877)`
# que mete esos 1280 px dentro de la hoja. Esa variante existe exactamente para
# esto; saltársela y culpar al render era el camino largo.
if [ $# -gt 0 ]; then
  archivos=("$@")
else
  mapfile -t todos < <(find "$RAIZ" -name "*.html" -not -path "*/dist/*" | sort)
  archivos=()
  for f in "${todos[@]}"; do
    # Si este es el archivo base y existe su variante de impresión, se salta:
    # ya entrará la otra.
    case "$f" in
      *" - print.html") archivos+=("$f") ;;
      *) [ -f "${f%.html} - print.html" ] || archivos+=("$f") ;;
    esac
  done
fi

for f in "${archivos[@]}"; do
  [ -f "$f" ] || { echo "no existe: $f" >&2; continue; }
  abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
  # El sufijo " - print" es un detalle de cómo se produce el PDF, no del
  # documento. Al cliente le llega "Brand_Book.pdf".
  nombre="$(basename "${f%.html}")"; nombre="${nombre% - print}"
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
