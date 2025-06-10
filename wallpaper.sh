#!/bin/bash
set -e

echo "[+] Moviendo carpeta Imágenes a la raíz del usuario..."

SRC_DIR="$(pwd)/Imágenes"
DEST_DIR="$HOME/Imágenes"

# Mover carpeta Imágenes si existe
if [ -d "$SRC_DIR" ]; then
    mv "$SRC_DIR" "$DEST_DIR"
    echo "[✓] Carpeta Imágenes movida a $DEST_DIR"
else
    echo "[✗] Carpeta Imágenes no encontrada. Colócala en el mismo directorio que este script."
    exit 1
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

# Configurar LightDM
echo "[+] Configurando fondo de LightDM..."
LIGHTDM_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

sudo mkdir -p "$(dirname "$LIGHTDM_CONF")"

sudo tee "$LIGHTDM_CONF" > /dev/null <<EOF
[greeter]
background=$DEST_DIR/wallpaper1.jpg
theme-name=Dracula
icon-theme-name=Dracula
font-name=Fira Code 10
xft-antialias=true
xft-hintstyle=hintfull
EOF

echo "[✓] LightDM configurado con tema Dracula y fondo personalizado."
echo "[✓] Todo listo con tema Dracula y wallpapers aplicados correctamente."
