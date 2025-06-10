#!/bin/bash
set -e

echo "[+] Moviendo wallpapers a ~/Imágenes..."
mkdir -p ~/Imágenes
mv -v ~/wallpaper.jpg ~/wallpaper1.jpg ~/wallpaper2.jpg ~/Imágenes/

echo "[+] Estableciendo fondo de pantalla con feh..."
feh --bg-scale ~/Imágenes/wallpaper.jpg

echo "[+] Configurando fondo para LightDM..."
sudo mkdir -p /etc/lightdm
echo "[Seat:*]" | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null
echo "background=/home/$USER/Imágenes/wallpaper1.jpg" | sudo tee -a /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null

echo "[+] Preparando fondo para slock..."
# Convertir wallpaper2.jpg a PNG compatible y colocar como fondo temporal
mkdir -p ~/.cache/slock
cp ~/Imágenes/wallpaper2.jpg ~/.cache/slock/background.jpg

# Crear un script para usar slock con fondo
cat > ~/.local/bin/slock-bg << 'EOF'
#!/bin/bash
feh --bg-scale ~/.cache/slock/background.jpg
slock
EOF

chmod +x ~/.local/bin/slock-bg

echo "[✓] ¡Todo listo! Usa 'slock-bg' para bloquear con fondo personalizado."
