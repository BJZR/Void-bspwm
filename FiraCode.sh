#!/bin/bash
set -e

SOURCE_DIR="$(pwd)/FiraCode"
DEST_DIR="$HOME/.local/share/fonts"

echo "[+] Instalando fuentes desde carpeta FiraCode..."

# Verificar que la carpeta FiraCode existe
if [ ! -d "$SOURCE_DIR" ]; then
    echo "[✗] La carpeta FiraCode no existe en el directorio actual."
    exit 1
fi

# Crear carpeta de destino si no existe
mkdir -p "$DEST_DIR"

# Mover solamente archivos de fuentes (ej. .ttf y .otf)
echo "[+] Moviendo archivos de fuentes a $DEST_DIR..."
mv "$SOURCE_DIR"/*.ttf "$SOURCE_DIR"/*.otf "$DEST_DIR" 2>/dev/null || {
    echo "[!] No se encontraron archivos de fuentes para mover."
}

# Actualizar caché de fuentes
echo "[+] Actualizando caché de fuentes..."
fc-cache -fv "$DEST_DIR"

echo "[✓] Fuentes instaladas correctamente en $DEST_DIR"
