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

# Establecer fondo de escritorio con feh
echo "[+] Aplicando fondo de escritorio con feh..."
if ! command -v feh >/dev/null; then
    echo "[✗] 'feh' no está instalado. Instálalo antes de continuar."
    exit 1
fi

feh --bg-scale "$DEST_DIR/wallpaper.jpg"

# Configurar LightDM GTK Greeter
echo "[+] Configurando fondo de LightDM (gtk-greeter)..."

LIGHTDM_CONF="/etc/lightdm/lightdm-gtk-greeter.conf"

if [ ! -f "$LIGHTDM_CONF" ]; then
    echo "[✗] Archivo lightdm-gtk-greeter.conf no encontrado."
    echo "    ¿Tienes instalado 'lightdm-gtk-greeter'?"
    exit 1
fi

# Cambiar fondo en lightdm-gtk-greeter.conf
sudo sed -i "s|^#*background=.*|background=$DEST_DIR/wallpaper1.jpg|" "$LIGHTDM_CONF"

echo "[✓] LightDM (gtk-greeter) configurado con fondo personalizado."
echo "[✓] Todo listo con wallpapers aplicados correctamente."
