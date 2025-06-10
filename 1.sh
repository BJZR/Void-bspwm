echo "[+] Configurando BSPWM y SXHKD..."

# Crear directorios de configuración
mkdir -p ~/.config/{bspwm,sxhkd}

# bspwmrc
cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/sh

# Configuración inicial
sxhkd &
picom --config ~/.config/picom/picom.conf &

# Fondos de pantalla
feh --bg-scale ~/Imágenes/wallpaper.jpg &

# Indicadores
nm-applet &
blueman-applet &
volumeicon &

# Barra
~/.config/polybar/launch.sh &

# Cursor
xsetroot -cursor_name left_ptr

# Tamaño de borde
bspc config border_width         2
bspc config window_gap          8
bspc config split_ratio         0.5
bspc config borderless_monocle true
bspc config gapless_monocle     true

# Esquema de bordes
bspc config normal_border_color "#44475a"
bspc config active_border_color "#bd93f9"
bspc config focused_border_color "#50fa7b"
EOF

chmod +x ~/.config/bspwm/bspwmrc

# sxhkdrc
cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
# Lanzadores
super + Return
    kitty

super + d
    rofi -show drun

# Gestión de ventanas
super + {h,j,k,l}
    bspc node -f {west,south,north,east}

super + shift + {h,j,k,l}
    bspc node -s {west,south,north,east}

super + q
    bspc node -c

super + space
    bspc node -t ~floating

super + {1-9}
    bspc desktop -f ^{1-9}

super + shift + {1-9}
    bspc node -d ^{1-9}

# Reiniciar BSPWM
super + Escape
    bspc wm -r

# Bloquear pantalla
super + shift + x
    slock
EOF
