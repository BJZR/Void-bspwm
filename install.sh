#!/bin/bash

# Colores
G="\033[0;32m"
C="\033[0;36m"
R="\033[0;31m"
Y="\033[0;33m"
N="\033[0m"

# Encabezado
echo -e "${C}#############################################"
echo -e "# ${G}Instalador Mejorado Entorno BSPWM${N}       #"
echo -e "#############################################${N}"

# Verificación de permisos
if [ "$(id -u)" != "0" ]; then
    echo -e "${R}¡Este script debe ejecutarse como root!${N}"
    echo -e "Ejecuta: ${C}sudo bash $0${N}"
    exit 1
fi

# Obtener el nombre de usuario del sistema
USUARIO=$(logname || echo $SUDO_USER)
if [ -z "$USUARIO" ]; then
    echo -e "${R}No se pudo determinar el nombre de usuario.${N}"
    read -p "Introduce tu nombre de usuario: " USUARIO
fi

# Directorio home del usuario
USER_HOME=$(eval echo ~$USUARIO)

# Ubicación actual del script
SCRIPT_DIR=$(pwd)

# Configurar repositorios adicionales
echo -e "${C}Configurando repositorios adicionales...${N}"
cat > /etc/xbps.d/00-repository.conf << 'EOL'
repository=https://mirror.clarkson.edu/voidlinux/current
repository=https://mirror.clarkson.edu/voidlinux/current/nonfree
repository=https://mirror.clarkson.edu/voidlinux/current/multilib
repository=https://mirror.clarkson.edu/voidlinux/current/multilib/nonfree
EOL

# Confirmación rápida
read -p "Iniciar instalación? (s/n): " resp
[[ ! "$resp" =~ ^[Ss]$ ]] && echo -e "${R}Cancelado.${N}" && exit 0

echo -e "${C}Actualizando repositorios...${N}"
xbps-install -Suy

# Instalación de paquetes con dependencias críticas primero (solución)
echo -e "${C}Instalando dependencias críticas primero...${N}"
xbps-install -y polkit elogind dbus eudev xorg-minimal

# Instalación del resto de paquetes
echo -e "${C}Instalando todos los paquetes necesarios...${N}"
xbps-install -y xorg-server xrandr xinput xsetroot \
    gtk+3 gtk-theme-config gtk-engine-murrine \
    bspwm sxhkd rofi polybar dunst picom feh yad i3lock \
    lightdm lightdm-gtk-greeter NetworkManager network-manager-applet \
    pulseaudio pavucontrol thunar alacritty kitty bluez blueman bluez-alsa \
    ttf-fira-code-nerd ttf-noto-sans ttf-material-design-icons \
    materia-theme arc-gtk-theme flat-remix-gtk nordic-gtk-theme papirus-icon-theme \
    tela-circle-icon-theme material-design-icons flameshot \
    git make ImageMagick # Dependencias para betterlockscreen

# Verificación de instalación de LightDM
if ! xbps-query lightdm > /dev/null; then
    echo -e "${R}Error: LightDM no se instaló correctamente. Intentando instalar desde nonfree...${N}"
    xbps-install -y lightdm lightdm-gtk-greeter
    if ! xbps-query lightdm > /dev/null; then
        echo -e "${R}Error: No se pudo instalar LightDM. Verifica los repositorios.${N}"
        exit 1
    fi
fi

# Configuración de servicios (corregida para incluir servicios críticos)
echo -e "${C}Configurando servicios...${N}"
for service in dbus elogind polkitd polkit lightdm NetworkManager bluetoothd; do
    if [ -d /etc/sv/$service ]; then
        echo -e "Habilitando servicio: ${Y}$service${N}"
        rm -f /var/service/$service
        ln -sf /etc/sv/$service /var/service/
    else
        echo -e "${Y}Servicio $service no encontrado, intentando alternativa...${N}"
        # Si polkitd no existe, intentar con polkit
        if [ "$service" = "polkitd" ] && [ -d /etc/sv/polkit ]; then
            echo -e "Habilitando servicio: ${Y}polkit${N} (alternativo)"
            rm -f /var/service/polkit
            ln -sf /etc/sv/polkit /var/service/
        fi
    fi
done

# Creación de directorios de configuración
echo -e "${C}Creando estructura de directorios...${N}"
mkdir -p $USER_HOME/.config/{bspwm,sxhkd,polybar,polybar/scripts,rofi,dunst,picom,yad}
chown -R $USUARIO:$USUARIO $USER_HOME/.config

# Configuración de BSPWM
echo -e "${C}Configurando BSPWM...${N}"
cat > $USER_HOME/.config/bspwm/bspwmrc << 'EOL'
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
chmod +x $USER_HOME/.config/bspwm/bspwmrc
chown $USUARIO:$USUARIO $USER_HOME/.config/bspwm/bspwmrc

# Configuración de SXHKD
echo -e "${C}Configurando SXHKD...${N}"
cat > $USER_HOME/.config/sxhkd/sxhkdrc << 'EOL'
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
    i3lock -c 000000
EOL
chown $USUARIO:$USUARIO $USER_HOME/.config/sxhkd/sxhkdrc

# Configuración de Polybar
echo -e "${C}Configurando Polybar...${N}"
mkdir -p $USER_HOME/.config/polybar
cat > $USER_HOME/.config/polybar/config.ini << 'EOL'
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
exec = $HOME/.config/polybar/scripts/bluetooth-status.sh
interval = 2
click-left = $HOME/.config/polybar/scripts/toggle-bluetooth.sh
format-padding = 1
format-background = #2980b9
format-foreground = #ecf0f1
EOL
chown $USUARIO:$USUARIO $USER_HOME/.config/polybar/config.ini

# Script de lanzamiento de Polybar
cat > $USER_HOME/.config/polybar/launch.sh << 'EOL'
#!/bin/bash

# Terminar instancias previas
killall -q polybar

# Esperar a que terminen
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar polybar
polybar main &
EOL
chmod +x $USER_HOME/.config/polybar/launch.sh
chown $USUARIO:$USUARIO $USER_HOME/.config/polybar/launch.sh

# Configuración de Rofi
echo -e "${C}Configurando Rofi...${N}"
mkdir -p $USER_HOME/.config/rofi
cat > $USER_HOME/.config/rofi/config.rasi << 'EOL'
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
chown $USUARIO:$USUARIO $USER_HOME/.config/rofi/config.rasi

# Configuración de Picom
echo -e "${C}Configurando Picom...${N}"
cat > $USER_HOME/.config/picom/picom.conf << 'EOL'
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
chown $USUARIO:$USUARIO $USER_HOME/.config/picom/picom.conf

# Configuración de Dunst
echo -e "${C}Configurando Dunst...${N}"
cat > $USER_HOME/.config/dunst/dunstrc << 'EOL'
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
chown $USUARIO:$USUARIO $USER_HOME/.config/dunst/dunstrc

# Configuración para asegurar que LightDM muestre BSPWM (solución)
echo -e "${C}Creando entrada para BSPWM en LightDM...${N}"
mkdir -p /usr/share/xsessions
cat > /usr/share/xsessions/bspwm.desktop << EOL
[Desktop Entry]
Name=bspwm
Comment=Binary space partitioning window manager
Exec=/usr/bin/bspwm
Type=Application
Keywords=tiling;wm;windowmanager;window;manager;
EOL

# Configuración mejorada de LightDM (solución)
echo -e "${C}Configurando LightDM con soluciones mejoradas...${N}"
mkdir -p /etc/lightdm
cat > /etc/lightdm/lightdm.conf << EOL
[LightDM]
run-directory=/run/lightdm

[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=bspwm
session-wrapper=/etc/lightdm/Xsession
display-setup-script=/etc/lightdm/display-setup.sh
EOL

# Verificar si existe el fondo de pantalla
if [ -f "$SCRIPT_DIR/wallpaper2.jpg" ]; then
    WALLPAPER="$SCRIPT_DIR/wallpaper2.jpg"
    # Asegurar permisos
    chmod 644 "$WALLPAPER"
    # Copiar a /usr/share/backgrounds por si acaso
    mkdir -p /usr/share/backgrounds
    cp "$WALLPAPER" /usr/share/backgrounds/
    WALLPAPER="/usr/share/backgrounds/wallpaper2.jpg"
else
    WALLPAPER=""
fi

cat > /etc/lightdm/lightdm-gtk-greeter.conf << EOL
[greeter]
theme-name = Nordic
icon-theme-name = Papirus
font-name = Noto Sans 10
background = $WALLPAPER
position = 50%,center
xft-antialias = true
xft-hintstyle = hintfull
clock-format = %H:%M:%S %d/%m/%Y
EOL

# Scripts para lightdm (solución)
cat > /etc/lightdm/display-setup.sh << EOL
#!/bin/sh
# Configuración de pantalla para LightDM
xrandr --auto
xsetroot -cursor_name left_ptr
EOL
chmod +x /etc/lightdm/display-setup.sh

# Crear script Xsession (solución)
cat > /etc/lightdm/Xsession << 'EOL'
#!/bin/sh
# Global Xsession script
# Copied from Debian's /etc/X11/Xsession

exec $@
EOL
chmod +x /etc/lightdm/Xsession

# Instalación y configuración de betterlockscreen
echo -e "${C}Instalando betterlockscreen...${N}"
if ! command -v i3lock-color &> /dev/null; then
    echo "Instalando i3lock-color..."
    xbps-install -y i3lock-color
fi

if ! command -v betterlockscreen &> /dev/null; then
    echo "Instalando betterlockscreen desde GitHub..."
    TMP_DIR=$(mktemp -d)
    git clone https://github.com/betterlockscreen/betterlockscreen $TMP_DIR
    cd $TMP_DIR
    chmod +x betterlockscreen
    cp betterlockscreen /usr/local/bin/
    cd -
    rm -rf $TMP_DIR
fi

# Configurar fondos de pantalla
echo -e "${C}Configurando fondos de pantalla...${N}"
# Copiar archivos de fondo de pantalla al directorio home del usuario
cp $(pwd)/wallpaper*.jpg $USER_HOME/
chown $USUARIO:$USUARIO $USER_HOME/wallpaper*.jpg

# Usar i3lock en lugar de betterlockscreen si este último no está disponible
if command -v betterlockscreen &> /dev/null; then
    echo "Configurando betterlockscreen..."
    betterlockscreen -u $USER_HOME/wallpaper1.jpg
    # Actualizar sxhkdrc para usar betterlockscreen
    sed -i 's/i3lock -c 000000/betterlockscreen -l dimblur/' $USER_HOME/.config/sxhkd/sxhkdrc
fi

# Configuración de .xinitrc (solución)
echo -e "${C}Configurando .xinitrc mejorado...${N}"
cat > $USER_HOME/.xinitrc << 'EOL'
#!/bin/sh

# Iniciar sesión dbus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Configurar cursor
xsetroot -cursor_name left_ptr

# Cargar fondo de escritorio si existe
if [ -f "$HOME/wallpaper.jpg" ]; then
    feh --bg-fill "$HOME/wallpaper.jpg" &
fi

# Iniciar componentes básicos
nm-applet &
[ -x /usr/bin/picom ] && picom &

# Iniciar BSPWM
exec bspwm
EOL
chmod +x $USER_HOME/.xinitrc
chown $USUARIO:$USUARIO $USER_HOME/.xinitrc

# Configurar inicio automático de X como respaldo (solución)
echo -e "${C}Configurando inicio automático como respaldo...${N}"
if [ ! -f "/etc/profile.d/startx.sh" ]; then
    cat > /etc/profile.d/startx.sh << 'EOL'
# Auto-start X on tty1 if not already running
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOL
    chmod +x /etc/profile.d/startx.sh
fi

# Configuración de scripts para Bluetooth en Polybar
echo -e "${C}Configurando scripts para Bluetooth...${N}"
cat > $USER_HOME/.config/polybar/scripts/bluetooth-status.sh << 'EOL'
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
chmod +x $USER_HOME/.config/polybar/scripts/bluetooth-status.sh
chown $USUARIO:$USUARIO $USER_HOME/.config/polybar/scripts/bluetooth-status.sh

cat > $USER_HOME/.config/polybar/scripts/toggle-bluetooth.sh << 'EOL'
#!/bin/sh
if [ "$(bluetoothctl show | grep 'Powered: yes')" ]; then
    bluetoothctl power off
    notify-send -u normal "Bluetooth" "Bluetooth desactivado"
else
    bluetoothctl power on
    notify-send -u normal "Bluetooth" "Bluetooth activado"
fi
EOL
chmod +x $USER_HOME/.config/polybar/scripts/toggle-bluetooth.sh
chown $USUARIO:$USUARIO $USER_HOME/.config/polybar/scripts/toggle-bluetooth.sh

# Configuración de YAD para menús del sistema
echo -e "${C}Configurando YAD para menús de sistema...${N}"
mkdir -p $USER_HOME/.config/yad/icons
cat > $USER_HOME/.config/yad/yad-system-tray.sh << 'EOL'
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
            if command -v betterlockscreen &> /dev/null; then
                betterlockscreen -l dimblur
            else
                i3lock -c 000000
            fi
            ;;
        "Cerrar sesión")
            bspc quit
            ;;
        "Reiniciar")
            reboot
            ;;
        "Apagar")
            poweroff
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
chmod +x $USER_HOME/.config/yad/yad-system-tray.sh
chown $USUARIO:$USUARIO $USER_HOME/.config/yad/yad-system-tray.sh

# Verificación de servicios (solución)
echo -e "${C}Verificando estado de servicios críticos...${N}"
echo "Estado de dbus:"
sv status dbus || echo -e "${R}Servicio dbus no encontrado${N}"

echo "Estado de elogind:"
sv status elogind || echo -e "${R}Servicio elogind no encontrado${N}"

echo "Estado de polkit/polkitd:"
sv status polkitd || sv status polkit || echo -e "${R}Servicio polkit no encontrado${N}"

echo "Estado de lightdm:"
sv status lightdm || echo -e "${R}Servicio lightdm no encontrado${N}"

# Reiniciar servicios críticos (solución)
echo -e "${C}Reiniciando servicios críticos...${N}"
for service in dbus elogind polkitd polkit lightdm; do
    if [ -L "/var/service/$service" ]; then
        echo -e "Reiniciando servicio: ${Y}$service${N}"
        sv restart $service || echo -e "${R}Fallo al reiniciar $service${N}"
    fi
done

# Mensaje final
echo -e "\n${G}¡Instalación mejorada completada con éxito!${N}"
echo -e "${Y}• Tres fondos configurados:${N}"
echo -e "  ${C}wallpaper.jpg${N} - Fondo de escritorio"
echo -e "  ${C}wallpaper1.jpg${N} - Pantalla de bloqueo"
echo -e "  ${C}wallpaper2.jpg${N} - Gestor de sesión LightDM"
echo -e "${Y}• IMPORTANTE: Asegúrate de tener estos archivos de fondos en $(pwd)${N}"

echo -e "\n${G}• Mejoras implementadas:${N}"
echo -e "  ${C}1.${N} Instalación de dependencias críticas en orden correcto"
echo -e "  ${C}2.${N} Configuración mejorada de LightDM"
echo -e "  ${C}3.${N} Script Xsession correcto"
echo -e "  ${C}4.${N} Sistema de respaldo con .xinitrc y startx"
echo -e "  ${C}5.${N} Verificación de servicios"

echo -e "\n${Y}• Teclas principales:${N}"
echo -e "  ${C}Super+Return${N} - Alacritty"
echo -e "  ${C}Super+Alt+Return${N} - Kitty"
echo -e "  ${C}Super+Space${N} - Menu Rofi"
echo -e "  ${C}Super+L${N} - Bloqueo de pantalla"
echo -e "  ${C}Print${N} - Captura de pantalla"
echo -e "${Y}• Menús del sistema:${N}"
echo -e "  ${C}Click en la bandeja${N} - Menú YAD (WiFi, Bluetooth, Energía)"

echo -e "\n${G}Se recomienda reiniciar el sistema ahora.${N}"
echo -e "${Y}¿Reiniciar ahora? (s/n):${N} "
read -r respuesta
if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    echo -e "${G}Reiniciando sistema...${N}"
    reboot
else
    echo -e "${Y}Recuerda reiniciar el sistema pronto para aplicar todos los cambios.${N}"
fi