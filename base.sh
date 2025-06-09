#!/bin/bash
set -e  # Salir si ocurre un error

# Función para crear symlinks si no existen
enable_service() {
    local svc="/etc/sv/$1"
    local link="/var/service/$1"
    [ ! -e "$link" ] && ln -s "$svc" "$link"
}

echo "[+] Sincronizando repositorios y actualizando sistema..."
xbps-install -Sy xbps
xbps-install -Syu

echo "[+] Activando repositorios nonfree y multilib..."
xbps-install -y void-repo-nonfree void-repo-multilib void-multilib-nonfree
xbps-install -Syu

echo "[+] Instalando herramientas de desarrollo y utilidades..."
xbps-install -y base-devel ncurses-devel git curl wget neovim

echo "[+] Instalando controlador de video Intel..."
xbps-install -y xf86-video-intel

echo "[+] Instalando entorno BSPWM y herramientas esenciales..."
xbps-install -y xorg-minimal xinit xrandr bspwm sxhkd kitty rofi polybar \
               feh xbacklight xclip lxappearance scrot dunst slock picom

echo "[+] Instalando Bluetooth y gestor Blueman..."
xbps-install -y bluez bluez-utils blueman
enable_service bluetoothd

echo "[+] Instalando LightDM y servicios de sesión..."
xbps-install -y lightdm lightdm-gtk-greeter dbus elogind polkit
enable_service dbus
enable_service lightdm

echo "[+] Instalando audio y herramientas PulseAudio..."
xbps-install -y pulseaudio pulseaudio-bluetooth pavucontrol

echo "[+] Instalando NetworkManager..."
xbps-install -y NetworkManager network-manager-applet
enable_service NetworkManager

echo "[✓] Instalación completa. Reinicia para aplicar los cambios."
