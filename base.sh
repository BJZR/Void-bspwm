#!/bin/bash

xbps-install -Sy xbps
sudo xbps-install -syu

xbps-install void-repo-nonfree void-repo-multilib

sudo xbps-install -S base-devel ncurses-devel

sudo xbps-install -S xf86-video-intel

sudo xbps-install -y xorg-minimal xinit xrandr bspwm sxhkd kitty rofi polybar git curl wget neovim feh xbacklight xclip lxappearance scrot dunst


sudo xbps-install -S bluez bluez-utils

sudo xbps-install blueman

sudo ln -s /etc/sv/bluetoothd /var/service

sudo xbps-install -y lightdm lightdm-gtk-greeter dbus elogind polkit

sudo ln -s /etc/sv/dbus /var/service/

sudo ln -s /etc/sv/lightdm /var/service/

sudo xbps-install -S pulseaudio pulseaudio-bluetooth pavucontrol

sudo xbps-install -S NetworkManager network-manager-applet

sudo ln -s /etc/sv/NetworkManager /var/service/

