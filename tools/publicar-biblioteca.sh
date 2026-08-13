#!/usr/bin/env bash
# Copia los PDF terminados a la biblioteca, en `documentos/`.
#
# POR QUÉ
# -------
# El repo de marca es donde se EDITA la documentación; la biblioteca es donde el
# equipo va a BUSCARLA. Son dos preguntas distintas: "dónde toco el manual" y
# "dónde bajo el manual". Pedirle a un técnico que clone el repo de marca, se
# instale chromium y renderice para leer cuatro páginas no es una respuesta.
#
# Sólo viajan los PDF. La fuente se queda en el repo de marca — dos copias de un
# HTML editable son dos verdades a los tres días.
#
# NO hace commit ni push: eso es tarea del publicador de la biblioteca
# (`oraculo/services/biblioteca-git/publicar.sh`), que ya sabe cómo hacerlo sin
# pisar nada. Aquí sólo se dejan los ficheros en su sitio.
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIBLIOTECA="${BIBLIOTECA:-$HOME/metrican-library}"
DESTINO="$BIBLIOTECA/documentos"

[ -d "$BIBLIOTECA" ] || { echo "No existe la biblioteca en $BIBLIOTECA" >&2; exit 1; }

# Se renderiza siempre antes de copiar. Publicar un PDF viejo desde dist/ es el
# fallo silencioso clásico: el fichero está, tiene buena pinta, y le falta el
# último cambio.
bash "$RAIZ/tools/render.sh" >/dev/null
bash "$RAIZ/tools/render.sh" --dossier >/dev/null

mkdir -p "$DESTINO"
cp -f "$RAIZ"/dist/*.pdf "$DESTINO"/

for f in "$DESTINO"/*.pdf; do
  printf '%s  %s\n' "$(du -h "$f" | cut -f1)" "$(basename "$f")"
done
echo "→ $DESTINO"
