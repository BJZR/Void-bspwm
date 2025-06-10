#!/bin/bash
set -e

echo "🧰 Instalando dependencias necesarias..."
sudo xbps-install -Sy base-devel ncurses libX11 libXft pam-devel libxcb-devel xcb-util xcb-util-wm xcb-util-image xcb-util-keysyms xkbcomp git utempter

echo "📥 Clonando repositorio de Ly..."
git clone https://github.com/fairyglade/ly.git /tmp/ly

cd /tmp/ly

echo "🔨 Compilando Ly..."
make

echo "📦 Instalando Ly..."
sudo make install

echo "⚙️ Creando servicio runit para Ly..."
sudo mkdir -p /etc/sv/ly
sudo tee /etc/sv/ly/run > /dev/null <<EOF
#!/bin/sh
exec /usr/bin/ly
EOF

sudo chmod +x /etc/sv/ly/run

echo "🔗 Activando Ly en runit..."
sudo ln -sf /etc/sv/ly /var/service/

echo "❌ Desactivando LightDM si está activo..."
sudo rm -f /var/service/lightdm || true

echo "🧼 Limpiando archivos temporales..."
cd ~
rm -rf /tmp/ly

echo "✅ Ly ha sido instalado y activado correctamente en Void Linux."
echo "🔁 Reinicia el sistema para comenzar a usar Ly:"
echo "    sudo reboot"
