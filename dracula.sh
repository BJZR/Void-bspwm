#!/bin/bash
set -e

# Rutas
THEME_ZIP="dracula-theme.zip"
ICON_ZIP="dracula-icons.zip"
TMP_DIR="/tmp/dracula-tmp"

# Crear carpeta temporal
mkdir -p "$TMP_DIR"

# --- EXTRAER TEMA GTK ---
echo "[+] Extrayendo $THEME_ZIP..."
if [ ! -f "$THEME_ZIP" ]; then
    echo "[✗] Archivo $THEME_ZIP no encontrado."
    exit 1
fi

unzip -q "$THEME_ZIP" -d "$TMP_DIR/theme"
if [ ! -d "$TMP_DIR/theme/dracula" ]; then
    echo "[✗] La carpeta 'dracula' no fue encontrada dentro de $THEME_ZIP."
    exit 1
fi

echo "[✓] Moviendo tema GTK Dracula a /usr/share/themes/"
sudo mkdir -p /usr/share/themes
sudo mv "$TMP_DIR/theme/dracula" /usr/share/themes/Dracula

# Limpiar carpeta temporal
rm -rf "$TMP_DIR"

# --- EXTRAER ICONOS ---
mkdir -p "$TMP_DIR"
echo "[+] Extrayendo $ICON_ZIP..."
if [ ! -f "$ICON_ZIP" ]; then
    echo "[✗] Archivo $ICON_ZIP no encontrado."
    exit 1
fi

unzip -q "$ICON_ZIP" -d "$TMP_DIR/icons"
if [ ! -d "$TMP_DIR/icons/dracula" ]; then
    echo "[✗] La carpeta 'dracula' no fue encontrada dentro de $ICON_ZIP."
    exit 1
fi

echo "[✓] Moviendo iconos Dracula a /usr/share/icons/"
sudo mkdir -p /usr/share/icons
sudo mv "$TMP_DIR/icons/dracula" /usr/share/icons/Dracula

# Limpiar carpeta temporal final
rm -rf "$TMP_DIR"

echo "[✓] Tema e iconos Dracula instalados correctamente."
