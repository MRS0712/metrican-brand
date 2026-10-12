#!/usr/bin/env bash
# Dice, página por página, si el contenido cabe en la hoja — y cuánto sobra.
#
# POR QUÉ
# -------
# `<doc-page>` imprime cada `.page` en una caja de tamaño fijo con
# `overflow:hidden`: lo que no entra se RECORTA en silencio. No hay error, no hay
# aviso, y el PDF se ve casi bien — normalmente lo que desaparece es el pie, que
# es justo lo que nadie mira. Agregar tres líneas a una página llena rompe el
# documento sin que el render diga nada.
#
# Esto abre el HTML en el mismo chromium que produce el PDF y mide, por página,
# el hueco que queda entre el último bloque y el pie:
#
#   tools/comprobar-desborde.sh "guia-ota/MetriCAN Campanas OTA.html"
#   tools/comprobar-desborde.sh guia-*/*.html
#
#   3:libre 100   → cabe, con 100 px de aire
#   3:DESBORDA+42 → se pierden 42 px por abajo: hay que recomponer la paginación
#
# El HTML se copia a un directorio temporal EN LA RAÍZ del repo, porque los
# documentos enlazan `../assets/doc.css` y desde /tmp no resolvería.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHROME="${CHROME:-$(command -v chromium || command -v chromium-browser || command -v google-chrome)}"
[ -n "$CHROME" ] || { echo "No hay chromium/chrome instalado" >&2; exit 1; }

TMP="$(mktemp -d "$RAIZ/.desborde-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

for src in "$@"; do
  [ -f "$src" ] || { echo "no existe: $src" >&2; continue; }
  dst="$TMP/$(basename "$src")"
  python3 - "$src" "$dst" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
sonda = """
<script>
window.addEventListener('load',()=>setTimeout(()=>{
  const o=[];
  document.querySelectorAll('.page').forEach((p,i)=>{
    const d=p.scrollHeight-p.clientHeight;
    const ft=p.querySelector('.ft'), pr=ft&&ft.previousElementSibling;
    let libre='?';
    if(ft&&pr) libre=Math.round(ft.offsetTop-(pr.offsetTop+pr.offsetHeight));
    o.push((i+1)+':'+(d>1?('DESBORDA+'+d):('libre '+libre)));
  });
  document.title='MEDIDA|'+o.join(' ');
},2500));
</script>
"""
open(dst, 'w', encoding='utf-8').write(
    open(src, encoding='utf-8').read().replace('</body>', sonda + '</body>'))
PY
  echo "== $(basename "$src")"
  # --virtual-time-budget, igual que en render.sh: hay que darle tiempo a
  # doc-page.js a paginar y a las fuentes a llegar, o se mide una página que no
  # es la que se va a imprimir.
  "$CHROME" --headless --disable-gpu --no-sandbox --virtual-time-budget=12000 \
    --dump-dom "file://${dst// /%20}" 2>/dev/null \
    | grep -om1 'MEDIDA|[^<]*' | sed 's/^MEDIDA|/  /' || echo "  (sin lectura)"
done
