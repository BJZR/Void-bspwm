#!/bin/bash
set -e

echo "[+] Preparando carpeta Imágenes en la raíz del usuario..."

SRC_DIR="$(pwd)/Imágenes"
DEST_DIR="$HOME/Imágenes"

# Verificar que la carpeta de origen exista
if [ ! -d "$SRC_DIR" ]; then
    echo "[✗] Carpeta Imágenes no encontrada en el directorio actual."
    exit 1
fi

# Si la carpeta de destino ya existe, solo copiar contenido
if [ -d "$DEST_DIR" ]; then
    echo "[!] Carpeta Imágenes ya existe en $HOME. Copiando contenido..."
    cp -r "$SRC_DIR/"* "$DEST_DIR/"
    echo "[✓] Contenido copiado a $DEST_DIR"
else
    # Mover completamente si no existe
    mv "$SRC_DIR" "$DEST_DIR"
    echo "[✓] Carpeta Imágenes movida a $DEST_DIR"
fi

# Verificar wallpapers necesarios
for img in wallpaper.jpg wallpaper1.jpg wallpaper2.jpg; do
    if [ ! -f "$DEST_DIR/$img" ]; then
        echo "[✗] Falta la imagen $img en $DEST_DIR"
        exit 1
    fi
done

# Establecer fondo con feh
echo "[+] Aplicando fondo de escritorio con feh..."
if ! command -v feh >/dev/null; then
    echo "[✗] 'feh' no está instalado. Instálalo antes de continuar."
    exit 1
fi

feh --bg-scale "$DEST_DIR/wallpaper.jpg"

# Configurar SLiM
echo "[+] Configurando fondo de SLiM..."
SLIM_CONF="/etc/slim.conf"

if [ ! -f "$SLIM_CONF" ]; then
    echo "[✗] Archivo slim.conf no encontrado en /etc. ¿Está instalado SLiM?"
    exit 1
fi

# Cambiar la línea del background en slim.conf
sudo sed -i "s|^current_theme.*|current_theme default|" "$SLIM_CONF"

# Asegurar ruta de fondo
sudo sed -i "s|^#*background.*|background $DEST_DIR/wallpaper1.jpg|" "$SLIM_CONF"

echo "[✓] SLiM configurado con fondo personalizado."
echo "[✓] Todo listo con tema Dracula (manual) y wallpapers aplicados correctamente."
