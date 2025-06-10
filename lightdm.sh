#!/bin/bash
set -e

show_menu() {
  echo "------------------------------------"
  echo "  🖥️  GESTOR LIGHTDM - MENU"
  echo "------------------------------------"
  echo "1. Desinstalar LightDM y configuración"
  echo "2. Instalar LightDM con greeter GTK3"
  echo "3. Salir"
  echo
  read -rp "Selecciona una opción [1-3]: " opcion
}

desinstalar_lightdm() {
  echo "🧹 Deteniendo y eliminando LightDM y greeter..."
  sudo sv stop lightdm || true
  sudo rm -f /var/service/lightdm
  sudo xbps-remove -Ry lightdm lightdm-gtk-greeter lightdm-gtk3-greeter || true
  sudo rm -rf /etc/lightdm
  echo "✅ LightDM y configuración eliminados por completo."
}

instalar_lightdm() {
  echo
  echo "🛠 Instalando LightDM y greeter GTK3..."
  if sudo xbps-install -Sy lightdm lightdm-gtk3-greeter; then
    echo "✅ Instalación exitosa."
  else
    echo "⚠️ Fallback: instalando greeter GTK2..."
    sudo xbps-install -Sy lightdm lightdm-gtk-greeter
  fi

  echo
  echo "🔁 Habilitando servicios en runit..."
  for svc in dbus elogind lightdm; do
    sudo ln -sf /etc/sv/$svc /var/service/
  done

  echo
  echo "🎨 Aplicando configuración del greeter..."
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
  echo "📦 Verificando que esté instalada la fuente Fira Code..."
  sudo xbps-install -Sy ttf-fira-code || true

  echo "🖼️ Asegúrate de tener el fondo 'wallpaper1.jpg' en:"
  echo "   /usr/share/backgrounds/"
  echo "   (puedes copiarlo con: sudo cp ~/Imágenes/wallpaper1.jpg /usr/share/backgrounds/)"

  echo
  echo "🔃 Recargando caché de fuentes..."
  sudo fc-cache -fv

  echo
  echo "✅ LightDM instalado y configurado."
  echo "🔄 Reinicia con: sudo reboot"
}

# Lógica principal
while true; do
  show_menu
  case $opcion in
    1) desinstalar_lightdm ;;
    2) instalar_lightdm ;;
    3) echo "👋 Saliendo..."; exit 0 ;;
    *) echo "❌ Opción no válida." ;;
  esac
  echo
  read -rp "Presiona Enter para continuar..."
done
