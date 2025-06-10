#!/bin/bash
set -e

echo "🧰 Instalando dependencias necesarias..."
sudo xbps-install -Sy base-devel ncurses libX11 git

echo "📥 Clonando repositorio de Ly..."
git clone https://github.com/fairyglade/ly.git /tmp/ly

cd /tmp/ly

echo "🔨 Compilando Ly..."
make

echo "📦 Instalando Ly..."
sudo make install
sudo make installsystemd || true  # No importa si falla en Void

echo "⚙️ Habilitando Ly en runit..."
sudo ln -sf /etc/sv/ly /var/service/

echo "❌ Desactivando LightDM si está activo..."
sudo rm -f /var/service/lightdm || true

echo "🧼 Limpiando archivos temporales..."
cd ~
rm -rf /tmp/ly

echo "✅ Ly ha sido instalado correctamente."
echo "🔁 Reinicia el sistema para comenzar a usar Ly:"
echo "    sudo reboot"
