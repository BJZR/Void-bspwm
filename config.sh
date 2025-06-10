#!/bin/bash
set -e

ORIG_CONFIG="./.config"
DEST_CONFIG="$HOME/.config"
BACKUP_DIR="$HOME/config-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "[+] Preparando para mover .config al directorio raíz del usuario..."

# Verifica si existe el nuevo .config en el mismo directorio del script
if [ ! -d "$ORIG_CONFIG" ]; then
    echo "[✗] No se encontró la carpeta .config en el directorio actual."
    exit 1
fi

# Si ya existe un .config en el home, respáldalo
if [ -d "$DEST_CONFIG" ]; then
    echo "[!] Ya existe una carpeta .config en el home. Creando respaldo..."

    mkdir -p "$BACKUP_DIR"
    BACKUP_PATH="$BACKUP_DIR/config_backup_$TIMESTAMP.zip"
    
    # Comprimir la carpeta actual
    zip -r "$BACKUP_PATH" "$DEST_CONFIG"
    echo "[✓] Respaldo guardado en $BACKUP_PATH"

    # Eliminar la original para mover la nueva
    rm -rf "$DEST_CONFIG"
fi

# Mover el nuevo .config
mv "$ORIG_CONFIG" "$DEST_CONFIG"
echo "[✓] Nueva carpeta .config movida correctamente a $DEST_CONFIG"
