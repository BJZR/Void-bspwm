#!/bin/bash

# Instala FiraCode Nerd Font en ~/.local/share/fonts

FONT_DIR="$HOME/.local/share/fonts"
FONT_ZIP="FiraCode.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_ZIP"

# Crear directorio de fuentes si no existe
mkdir -p "$FONT_DIR"

# Ir al directorio de fuentes
cd "$FONT_DIR" || exit 1

# Descargar la fuente
echo "Descargando FiraCode Nerd Font..."
if ! wget -q --show-progress "$FONT_URL"; then
  echo "❌ Error al descargar $FONT_ZIP"
  exit 1
fi

# Descomprimir la fuente
echo "Descomprimiendo..."
unzip -o "$FONT_ZIP" > /dev/null

# Actualizar la caché de fuentes
echo "Actualizando caché de fuentes..."
fc-cache -fv > /dev/null

# Limpiar archivo zip
rm -f "$FONT_ZIP"

echo "✅ FiraCode Nerd Font instalada correctamente."
