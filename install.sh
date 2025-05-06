# Finalización
echo -e "${Y}• Asegúrate de que estos servicios estén activos:${N}"
echo -e "  ${C}sv status lightdm${N} - Debe mostrar 'run' para iniciar el gestor de sesión"
echo -e "  ${C}sv status dbus${N} - Necesario para LightDM y componentes gráficos"
echo -e "  ${C}sv status bluetoothd${N} - Para el funcionamiento de Bluetooth"
echo -e "  ${C}sv status NetworkManager${N} - Para la gestión de redes"
echo -e "\n${Y}• Si el gestor de sesión no aparece después de reiniciar:${N}"
echo -e "  ${C}sudo sv restart lightdm${N} - Reiniciar el servicio LightDM"
echo -e "  ${C}sudo sv enable lightdm${N} - Asegurar que el servicio esté activado\n"#!/bin/bash

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
    pulseaudio pavucontrol thunar alacritty kitty bluez blueman bluez-alsa \
    ttf-fira-code-nerd ttf-noto-sans ttf-material-design-icons \
    materia-theme arc-gtk-theme flat-remix-gtk nordic-gtk-theme papirus-icon-theme \
    tela-circle-icon-theme material-design-icons flameshot

# Configuración de servicios
echo -e "${C}Configurando servicios...${N}"
ln -s /etc/sv/lightdm /var/service/
sv up lightdm
ln -s /etc/sv/NetworkManager /var/service/
sv up NetworkManager
ln -s /etc/sv/dbus /var/service/
sv up dbus
ln -s /etc/sv/bluetoothd /var/service/
sv up bluetoothd

# Creación de directorios de configuración
echo -e "${C}Creando estructura de directorios...${N}"
mkdir -p ~/.config/{bspwm,sxhkd,polybar,polybar/scripts,rofi,dunst,picom,yad}

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
blueman-applet &
feh --bg-fill $HOME/wallpaper.jpg &
$HOME/.config/yad/yad-system-tray.sh &

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
# Terminal (Alacritty)
super + Return
	alacritty

# Terminal alternativo (Kitty)
super + alt + Return
	kitty

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
modules-right = pulseaudio brightness memory cpu battery bluetooth date
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

[module/bluetooth]
type = custom/script
exec = ~/.config/polybar/scripts/bluetooth-status.sh
interval = 2
click-left = ~/.config/polybar/scripts/toggle-bluetooth.sh
format-padding = 1
format-background = #2980b9
format-foreground = #ecf0f1
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

# Configuración de LightDM y BSPWM como opción de sesión
echo -e "${C}Configurando LightDM con fondo personalizado y añadiendo BSPWM como opción de sesión...${N}"

# Asegurar que el directorio de sesiones existe
mkdir -p /usr/share/xsessions

# Crear archivo .desktop para BSPWM
cat > /usr/share/xsessions/bspwm.desktop << EOL
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=/usr/bin/bspwm
Type=Application
Keywords=tiling;wm;windowmanager;window;manager;
EOL

# Configurar greeter de LightDM
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

# Asegurarse de que LightDM use el greeter correcto
cat > /etc/lightdm/lightdm.conf << EOL
[LightDM]
run-directory=/run/lightdm
greeter-session=lightdm-gtk-greeter
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

# Configuración de scripts para Bluetooth en Polybar
echo -e "${C}Configurando scripts para Bluetooth...${N}"
cat > ~/.config/polybar/scripts/bluetooth-status.sh << 'EOL'
#!/bin/sh
if [ "$(systemctl is-active bluetooth)" = "active" ]; then
    if [ "$(bluetoothctl show | grep 'Powered: yes')" ]; then
        echo "%{F#2ecc71}BT ON"

        # Verificar conexión
        if [ "$(bluetoothctl info | grep 'Connected: yes')" ]; then
            echo "%{F#3498db}BT CON"
        fi
    else
        echo "%{F#e74c3c}BT OFF"
    fi
else
    echo "%{F#e74c3c}BT OFF"
fi
EOL
chmod +x ~/.config/polybar/scripts/bluetooth-status.sh

cat > ~/.config/polybar/scripts/toggle-bluetooth.sh << 'EOL'
#!/bin/sh
if [ "$(bluetoothctl show | grep 'Powered: yes')" ]; then
    bluetoothctl power off
    notify-send -u normal "Bluetooth" "Bluetooth desactivado"
else
    bluetoothctl power on
    notify-send -u normal "Bluetooth" "Bluetooth activado"
fi
EOL
chmod +x ~/.config/polybar/scripts/toggle-bluetooth.sh

# Configuración de YAD para menús del sistema
echo -e "${C}Configurando YAD para menús de sistema...${N}"
mkdir -p ~/.config/yad/icons
cat > ~/.config/yad/yad-system-tray.sh << 'EOL'
#!/bin/bash

function network_menu() {
    yad --center --title="Redes" --text="Gestión de red" --form \
        --field="Wifi":btn "nm-connection-editor" \
        --field="Bluetooth":btn "blueman-manager" \
        --button=Cerrar:1
}

function power_menu() {
    ACTION=$(yad --center --title="Energía" --text="Opciones de energía" --list \
        --column="Acción" \
        "Bloquear pantalla" \
        "Cerrar sesión" \
        "Reiniciar" \
        "Apagar" \
        --button=Cancelar:1 --button=Seleccionar:0)
    
    case $ACTION in
        "Bloquear pantalla")
            betterlockscreen -l dimblur
            ;;
        "Cerrar sesión")
            bspc quit
            ;;
        "Reiniciar")
            sudo reboot
            ;;
        "Apagar")
            sudo poweroff
            ;;
    esac
}

function main_menu() {
    ACTION=$(yad --notification --image="system-run" \
        --text="Menú del sistema" \
        --menu="Red!network-wireless:network_menu!Gestión de red|Energía!system-shutdown:power_menu!Opciones de energía")
    
    case $ACTION in
        network_menu)
            network_menu
            ;;
        power_menu)
            power_menu
            ;;
    esac
}

main_menu
EOL
chmod +x ~/.config/yad/yad-system-tray.sh

# Mensaje final
echo -e "\n${G}¡Instalación completada con éxito!${N}"
echo -e "${Y}• Tres fondos configurados:${N}"
echo -e "  ${C}wallpaper.jpg${N} - Fondo de escritorio"
echo -e "  ${C}wallpaper1.jpg${N} - Pantalla de bloqueo"
echo -e "  ${C}wallpaper2.jpg${N} - Gestor de sesión LightDM"
echo -e "${Y}• Reinicia y selecciona BSPWM en LightDM${N}"
echo -e "${Y}• Teclas principales:${N}"
echo -e "  ${C}Super+Return${N} - Alacritty"
echo -e "  ${C}Super+Alt+Return${N} - Kitty"
echo -e "  ${C}Super+Space${N} - Menu Rofi"
echo -e "  ${C}Super+L${N} - Bloqueo de pantalla"
echo -e "  ${C}Print${N} - Captura de pantalla"
echo -e "${Y}• Menús del sistema:${N}"
echo -e "  ${C}Click en la bandeja${N} - Menú YAD (WiFi, Bluetooth, Energía)"
echo -e "\n${G}¡Disfruta tu nuevo entorno!${N}"
