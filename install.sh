#!/bin/bash

# Colores
G="\033[0;32m"
C="\033[0;36m"
R="\033[0;31m"
Y="\033[0;33m"
N="\033[0m"

# Encabezado
echo -e "${C}#############################################"
echo -e "# ${G}Instalador Entorno BSPWM Completo${N}       #"
echo -e "#############################################${N}"

# Verificación de permisos
if [ "$(id -u)" != "0" ]; then
    echo -e "${R}¡Este script debe ejecutarse como root!${N}"
    exit 1
fi

# Confirmación rápida
read -p "Iniciar instalación? (s/n): " resp
[[ ! "$resp" =~ ^[Ss]$ ]] && echo -e "${R}Cancelado.${N}" && exit 0

echo -e "${C}Actualizando repositorios...${N}"
xbps-install -Suy

# Instalación de paquetes (todo en un solo comando)
echo -e "${C}Instalando todos los paquetes necesarios...${N}"
xbps-install -y xorg-server xorg-xinit xorg-xrandr xorg-xinput xorg-utils \
    gtk+3 gtk-theme-config gtk-engine-murrine \
    bspwm sxhkd rofi polybar dunst picom feh yad i3lock betterlockscreen brightnessctl \
    lightdm lightdm-gtk-greeter NetworkManager network-manager-applet \
    pulseaudio pavucontrol thunar \
    ttf-fira-code-nerd ttf-noto-sans ttf-material-design-icons \
    materia-theme arc-gtk-theme flat-remix-gtk nordic-gtk-theme papirus-icon-theme \
    tela-circle-icon-theme material-design-icons flameshot

# Configuración de servicios
echo -e "${C}Configurando servicios...${N}"
ln -s /etc/sv/lightdm /var/service/
ln -s /etc/sv/NetworkManager /var/service/
ln -s /etc/sv/dbus /var/service/

# Creación de directorios de configuración
echo -e "${C}Creando estructura de directorios...${N}"
mkdir -p ~/.config/{bspwm,sxhkd,polybar,rofi,dunst,picom}

# Configuración de BSPWM
echo -e "${C}Configurando BSPWM...${N}"
cat > ~/.config/bspwm/bspwmrc << 'EOL'
#!/bin/sh

# Autostart
pgrep -x sxhkd > /dev/null || sxhkd &
$HOME/.config/polybar/launch.sh &
picom --config $HOME/.config/picom/picom.conf &
dunst &
nm-applet &
feh --bg-fill $HOME/wallpaper.jpg &

# Monitores y espacios de trabajo
bspc monitor -d I II III IV V VI VII VIII IX X

# Configuración general
bspc config border_width         2
bspc config window_gap          10
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true

# Reglas de ventanas
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a firefox desktop='^2'
bspc rule -a Thunar desktop='^3'
EOL
chmod +x ~/.config/bspwm/bspwmrc

# Configuración de SXHKD
echo -e "${C}Configurando SXHKD...${N}"
cat > ~/.config/sxhkd/sxhkdrc << 'EOL'
# Terminal
super + Return
	xterm

# Launcher
super + @space
	rofi -show drun

# Recargar configuración
super + Escape
	pkill -USR1 -x sxhkd

# Reiniciar/salir de bspwm
super + alt + {r,q}
	bspc {wm -r,quit}

# Cerrar ventana
super + w
	bspc node -c

# Alternar entre tiled/monocle
super + m
	bspc desktop -l next

# Enviar a workspace
super + {_,shift + }{1-9,0}
	bspc {desktop -f,node -d} '^{1-9,10}'

# Focus ventana
super + {h,j,k,l}
	bspc node -f {west,south,north,east}

# Captura de pantalla
Print
	flameshot gui

# Bloqueo de pantalla
super + l
	betterlockscreen -l dimblur
EOL

# Configuración de Polybar
echo -e "${C}Configurando Polybar...${N}"
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config.ini << 'EOL'
[colors]
background = #222
foreground = #eee
accent = #d8dee9

[bar/main]
width = 100%
height = 27
radius = 0
background = ${colors.background}
foreground = ${colors.foreground}
line-size = 3
padding-left = 0
padding-right = 2
module-margin-left = 1
module-margin-right = 1
font-0 = "Noto Sans:size=10;2"
font-1 = "Material Design Icons:size=12;3"
modules-left = bspwm
modules-center = xwindow
modules-right = pulseaudio brightness memory cpu battery date
cursor-click = pointer
enable-ipc = true

[module/bspwm]
type = internal/bspwm
pin-workspaces = true
label-focused = %index%
label-focused-background = #3f3f3f
label-focused-underline= ${colors.accent}
label-focused-padding = 2
label-occupied = %index%
label-occupied-padding = 2
label-urgent = %index%!
label-urgent-background = #bd2c40
label-urgent-padding = 2
label-empty = %index%
label-empty-foreground = #55
label-empty-padding = 2

[module/xwindow]
type = internal/xwindow
label = %title:0:80:...%

[module/date]
type = internal/date
interval = 5
date = %d-%m-%Y
time = %H:%M
label = %date% %time%

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <ramp-volume> <label-volume>
label-volume = %percentage%%
label-muted = 🔇 mute
ramp-volume-0 = 🔈
ramp-volume-1 = 🔉
ramp-volume-2 = 🔊

[module/memory]
type = internal/memory
interval = 2
format-prefix = "MEM "
label = %percentage_used%%

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "CPU "
label = %percentage%%

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 98
format-charging = <animation-charging> <label-charging>
format-discharging = <ramp-capacity> <label-discharging>
ramp-capacity-0 = 
ramp-capacity-1 = 
ramp-capacity-2 = 
animation-charging-0 = 
animation-charging-framerate = 750

[module/brightness]
type = internal/backlight
card = intel_backlight
format = <label>
label = BRI %percentage%%
EOL

# Script de lanzamiento de Polybar
cat > ~/.config/polybar/launch.sh << 'EOL'
#!/bin/bash

# Terminar instancias previas
killall -q polybar

# Esperar a que terminen
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar polybar
polybar main &
EOL
chmod +x ~/.config/polybar/launch.sh

# Configuración de Rofi
echo -e "${C}Configurando Rofi...${N}"
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'EOL'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    font: "Noto Sans 10";
}

* {
    background-color: #222222;
    text-color: #EFEFEF;
    selected-background: #3F3F3F;
    selected-text: #FFFFFF;
}

#window {
    border: 1px;
    border-color: #3F3F3F;
    padding: 10px;
    width: 500px;
}

#element selected {
    background-color: @selected-background;
    text-color: @selected-text;
}
EOL

# Configuración de Picom
echo -e "${C}Configurando Picom...${N}"
cat > ~/.config/picom/picom.conf << 'EOL'
backend = "glx";
vsync = true;
shadow = true;
shadow-radius = 12;
shadow-offset-x = -12;
shadow-offset-y = -12;
shadow-opacity = 0.7;
shadow-exclude = [
  "name = 'Notification'",
  "class_g = 'Polybar'",
  "class_g = 'Rofi'"
];
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
inactive-opacity = 0.85;
frame-opacity = 0.9;
inactive-opacity-override = false;
focus-exclude = [ "class_g = 'Rofi'" ];
blur-background = true;
blur-background-frame = true;
blur-background-fixed = true;
blur-kern = "3x3box";
blur-background-exclude = [ "window_type = 'dock'", "window_type = 'desktop'" ];
EOL

# Configuración de Dunst
echo -e "${C}Configurando Dunst...${N}"
cat > ~/.config/dunst/dunstrc << 'EOL'
[global]
    font = Noto Sans 10
    allow_markup = yes
    format = "<b>%s</b>\n%b"
    sort = yes
    indicate_hidden = yes
    alignment = left
    bounce_freq = 0
    show_age_threshold = 60
    word_wrap = yes
    ignore_newline = no
    geometry = "300x5-30+20"
    transparency = 10
    idle_threshold = 120
    monitor = 0
    follow = mouse
    sticky_history = yes
    history_length = 20
    show_indicators = yes
    line_height = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    separator_color = frame
    startup_notification = false
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#222222"
    foreground = "#888888"
    timeout = 10

[urgency_normal]
    background = "#285577"
    foreground = "#ffffff"
    timeout = 10

[urgency_critical]
    background = "#900000"
    foreground = "#ffffff"
    timeout = 0
EOL

# Configuración de LightDM con fondo personalizado
echo -e "${C}Configurando LightDM con fondo personalizado...${N}"
cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOL
[greeter]
background = $(pwd)/wallpaper2.jpg
theme-name = Nordic
icon-theme-name = Papirus
font-name = Noto Sans 10
xft-antialias = true
xft-hintstyle = hintfull
position = 50%,center
clock-format = %H:%M:%S %d/%m/%Y
EOL

# Configurar fondos de pantalla
echo -e "${C}Configurando fondos de pantalla...${N}"
# El fondo de pantalla principal se configura en bspwmrc (wallpaper.jpg)
# El fondo de bloqueo se configura a continuación
betterlockscreen -u $(pwd)/wallpaper1.jpg

# Configuración de .xinitrc
echo -e "${C}Configurando .xinitrc...${N}"
cat > ~/.xinitrc << 'EOL'
#!/bin/sh

# Iniciar dbus si no está en ejecución
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Configuración de teclado y ratón
setxkbmap es &
xsetroot -cursor_name left_ptr &

# Iniciar bspwm
exec bspwm
EOL
chmod +x ~/.xinitrc

# Mensaje final
echo -e "\n${G}¡Instalación completada con éxito!${N}"
echo -e "${Y}• Tres fondos configurados:${N}"
echo -e "  ${C}wallpaper.jpg${N} - Fondo de escritorio"
echo -e "  ${C}wallpaper1.jpg${N} - Pantalla de bloqueo"
echo -e "  ${C}wallpaper2.jpg${N} - Gestor de sesión LightDM"
echo -e "${Y}• Reinicia y selecciona BSPWM en LightDM${N}"
echo -e "${Y}• Teclas principales:${N}"
echo -e "  ${C}Super+Return${N} - Terminal"
echo -e "  ${C}Super+Space${N} - Menu Rofi"
echo -e "  ${C}Super+L${N} - Bloqueo de pantalla"
echo -e "  ${C}Print${N} - Captura de pantalla"
echo -e "\n${G}¡Disfruta tu nuevo entorno!${N}"
