#!/bin/bash
set -e

ZIP_NAME="FiraCode.zip"
ZIP_PATH="$(pwd)/$ZIP_NAME"
DEST_DIR="$HOME/.local/share/fonts"

echo "[+] Instalando fuente Fira Code desde $ZIP_NAME..."

# Verificar que el zip exista
if [ ! -f "$ZIP_PATH" ]; then
    echo "[✗] No se encontró el archivo $ZIP_NAME en el directorio actual."
    exit 1
fi

# Crear carpeta si no existe
mkdir -p "$DEST_DIR"

# Extraer el zip
unzip -o "$ZIP_PATH" -d "$DEST_DIR"

# Actualizar caché de fuentes
echo "[+] Actualizando caché de fuentes..."
fc-cache -fv "$DEST_DIR"

echo "[✓] Fuente Fira Code instalada correctamente en $DEST_DIR"
