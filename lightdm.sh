#!/bin/bash
set -e

echo "🧹 Deteniendo y eliminando LightDM y greeter..."
sudo sv stop lightdm || true
sudo rm -f /var/service/lightdm
sudo xbps-remove -Ry lightdm lightdm-gtk-greeter || true
sudo rm -rf /etc/lightdm

echo "✅ Desinstalación completa."

echo
echo "🛠 Instalando LightDM y greeter GTK3 (recomendado)..."
sudo xbps-install -Sy lightdm lightdm-gtk3-greeter || \
  sudo xbps-install -Sy lightdm lightdm-gtk-greeter
echo "✅ Instalación completada."

echo
echo "🔁 Habilitando servicios necesarios en runit..."
for svc in dbus elogind lightdm; do
  sudo ln -sf /etc/sv/$svc /var/service/
done
echo "✅ Servicios habilitados."

echo
echo "🎨 Aplicando configuración minimalista del greeter..."
sudo mkdir -p /etc/lightdm
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null <<EOF
[greeter]
font-name = Fira Code 12
background = /usr/share/backgrounds/wallpaper1.jpg
xft-antialias = true
xft-hintstyle = hintfull
EOF
echo "✅ Configuración aplicada."

echo
echo "👁️  Asegúrate de tener la fuente y el fondo instalados:"
echo "    sudo xbps-install -Sy ttf-fira-code"
echo "    sudo cp ~/Imágenes/wallpaper1.jpg /usr/share/backgrounds/"
echo "    sudo fc-cache -fv"
echo

echo "🛠 Reinicia ejecutando:"
echo "    sudo sv restart lightdm"
echo "  o reinicia el sistema:"
echo "    sudo reboot"
echo

echo "🎉 Listo. LightDM ha sido reinstalado y configurado desde cero."
