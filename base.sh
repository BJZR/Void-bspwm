# Actualización del sistema base
sudo xbps-install -Syu

# Herramientas de desarrollo
sudo xbps-install -Sy base-devel ncurses-devel git

# Drivers gráficos (Intel en este caso)
sudo xbps-install -Sy xf86-video-intel mesa-dri

# Entorno gráfico mínimo y utilidades esenciales
sudo xbps-install -y xorg xinit xrandr \
    bspwm sxhkd kitty rofi polybar xdo xprop \
    curl wget neovim feh xbacklight xclip lxappearance \
    scrot dunst slock qutebrowser

#carpetas de inicio
sudo xbps-install xdg-user-dirs
xdg-user-dirs-update

# Bluetooth
sudo usermod -aG bluetooth "$USER"
sudo xbps-install -Sy bluez blueman \
     bluez-alsa libspa-bluetooth
sudo ln -s /etc/sv/bluetoothd /var/service


# LightDM (gestor de inicio de sesión) y servicios relacionados
sudo xbps-install -y lightdm dbus elogind polkit

sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/lightdm /var/service
sudo ln -s /etc/sv/elogind /var/service
sudo ln -s /etc/sv/polkitd /var/service


# Audio (PulseAudio + soporte Bluetooth)
sudo xbps-install -Sy pulseaudio pulseaudio-bluetooth pavucontrol

# Red (NetworkManager)
sudo xbps-install -Sy NetworkManager network-manager-applet
sudo ln -s /etc/sv/NetworkManager /var/service
