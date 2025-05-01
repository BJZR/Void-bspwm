#!/bin/bash

# Script de instalación post-Void Linux para BSPWM
# Este script instala y configura un entorno BSPWM minimalista y funcional

# Colores para mejor legibilidad
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}Instalación de entorno BSPWM para Void Linux${NC}"
echo -e "${BLUE}==================================================${NC}"

# Función para instalar paquetes
install_package() {
    echo -e "${YELLOW}Instalando $1...${NC}"
    sudo xbps-install -Sy "$1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 instalado correctamente${NC}"
    else
        echo -e "${RED}✗ Error al instalar $1${NC}"
    fi
}

# Actualizar repositorios
echo -e "${BLUE}Actualizando repositorios...${NC}"
sudo xbps-install -Suy xbps
sudo xbps-install -Suy
echo -e "${GREEN}Repositorios actualizados${NC}"

# Instalación de paquetes base
echo -e "${BLUE}Instalando paquetes base...${NC}"
BASE_PACKAGES="base-devel git curl wget xorg xorg-minimal xorg-fonts xinit libX11-devel libXft-devel libXinerama-devel"
sudo xbps-install -Sy $BASE_PACKAGES

# Instalación de paquetes solicitados
PACKAGES=(
    "bspwm"
    "sxhkd"     # Necesario para los atajos de teclado de bspwm
    "polybar"
    "kitty"
    "rofi"
    "picom"
    "papirus-icon-theme"
    "feh"
    "lightdm"
    "lightdm-gtk-greeter"
    "font-firacode"   # Nombre correcto del paquete en Void Linux
    "tlp"       # Optimización de batería
    "acpi"      # Monitoreo de batería
    "xtools"    # Herramientas útiles para Void Linux
    "dunst"     # Notificaciones
    "lxappearance" # Configuración de temas GTK
    "ranger"    # Gestor de archivos en terminal
    "neofetch"  # Para mostrar información del sistema
    "htop"      # Monitor de recursos
    "NetworkManager" # Gestor de redes
    "network-manager-applet" # Applet para NetworkManager
    "pulseaudio" # Audio
    "pavucontrol" # Control de volumen gráfico
    "alsa-utils" # Utilidades de audio
    "xbacklight" # Control de brillo
    "nitrogen"  # Gestor de fondos de pantalla (alternativa a feh)
    "scrot"     # Para capturas de pantalla
    "firefox"   # Navegador web
    "gtk+3"     # Toolkit GTK para aplicaciones
    "dbus"      # Necesario para muchas aplicaciones
    "xdg-utils" # Utilidades básicas para aplicaciones X
)

echo -e "${BLUE}Instalando paquetes requeridos...${NC}"
for package in "${PACKAGES[@]}"; do
    install_package "$package"
done

# Crear directorios de configuración si no existen
echo -e "${BLUE}Creando directorios de configuración...${NC}"
mkdir -p ~/.config/{bspwm,sxhkd,polybar,kitty,rofi,picom}
mkdir -p ~/.fonts
mkdir -p ~/.local/bin

# Configuración de BSPWM
echo -e "${BLUE}Configurando BSPWM...${NC}"
cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/sh

# Autostart
sxhkd &
picom &
~/.config/polybar/launch.sh &
nitrogen --restore &
nm-applet &
dunst &

# BSPWM configuration
bspc monitor -d I II III IV V VI VII VIII IX X

bspc config border_width         2
bspc config window_gap          10
bspc config top_padding         30

bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config focus_follows_pointer true

# Colors
bspc config normal_border_color "#44475a"
bspc config active_border_color "#bd93f9"
bspc config focused_border_color "#ff79c6"
bspc config presel_feedback_color "#6272a4"

# Rules
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a firefox desktop='^2'
bspc rule -a kitty desktop='^1'
EOF

chmod +x ~/.config/bspwm/bspwmrc

# Configuración de SXHKD (atajos de teclado)
echo -e "${BLUE}Configurando atajos de teclado (sxhkd)...${NC}"
cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
# Terminal (kitty)
super + Return
	kitty

# Lanzador de programas (rofi)
super + @space
	rofi -show drun

# Recargar configuración
super + Escape
	pkill -USR1 -x sxhkd

# Salir/reiniciar bspwm
super + alt + {q,r}
	bspc {quit,wm -r}

# Cerrar/matar ventana
super + {_,shift + }q
	bspc node -{c,k}

# Alternar entre modo tiling/monocle
super + m
	bspc desktop -l next

# Enviar a desktop
super + shift + {1-9,0}
	bspc node -d '^{1-9,10}'

# Foco en desktop
super + {1-9,0}
	bspc desktop -f '^{1-9,10}'

# Foco en ventana
super + {h,j,k,l}
	bspc node -f {west,south,north,east}

# Mover ventana
super + shift + {h,j,k,l}
	bspc node -s {west,south,north,east}

# Control de volumen
XF86AudioRaiseVolume
	amixer -q set Master 5%+
    
XF86AudioLowerVolume
	amixer -q set Master 5%-
    
XF86AudioMute
	amixer -q set Master toggle

# Control de brillo
XF86MonBrightnessUp
	xbacklight -inc 10
    
XF86MonBrightnessDown
	xbacklight -dec 10

# Screenshot
Print
    scrot 'screenshot_%Y%m%d_%H%M%S.png' -e 'mkdir -p ~/screenshots && mv $f ~/screenshots'
EOF

# Configuración de Polybar
echo -e "${BLUE}Configurando Polybar...${NC}"
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config.ini << 'EOF'
[colors]
background = #282a36
background-alt = #44475a
foreground = #f8f8f2
primary = #bd93f9
secondary = #ff79c6
alert = #ff5555
disabled = #6272a4

[bar/main]
width = 100%
height = 24pt
radius = 0
fixed-center = true

background = ${colors.background}
foreground = ${colors.foreground}

line-size = 3pt

border-size = 0pt
border-color = #00000000

padding-left = 0
padding-right = 1

module-margin = 1

separator = |
separator-foreground = ${colors.disabled}

font-0 = "Fira Code:size=10;2"
font-1 = "Fira Code:size=12;2"
font-2 = "Font Awesome 5 Free:style=Solid:size=10;2"
font-3 = "Font Awesome 5 Free:style=Regular:size=10;2"
font-4 = "Font Awesome 5 Brands:style=Regular:size=10;2"

modules-left = xworkspaces xwindow
modules-center = date
modules-right = filesystem pulseaudio memory cpu battery wlan eth

cursor-click = pointer
cursor-scroll = ns-resize

enable-ipc = true

[module/xworkspaces]
type = internal/xworkspaces

label-active = %name%
label-active-background = ${colors.background-alt}
label-active-underline= ${colors.primary}
label-active-padding = 1

label-occupied = %name%
label-occupied-padding = 1

label-urgent = %name%
label-urgent-background = ${colors.alert}
label-urgent-padding = 1

label-empty = %name%
label-empty-foreground = ${colors.disabled}
label-empty-padding = 1

[module/xwindow]
type = internal/xwindow
label = %title:0:60:...%

[module/filesystem]
type = internal/fs
interval = 25

mount-0 = /

label-mounted = %{F#bd93f9}%mountpoint%%{F-} %percentage_used%%

label-unmounted = %mountpoint% not mounted
label-unmounted-foreground = ${colors.disabled}

[module/pulseaudio]
type = internal/pulseaudio

format-volume-prefix = "VOL "
format-volume-prefix-foreground = ${colors.primary}
format-volume = <label-volume>

label-volume = %percentage%%

label-muted = muted
label-muted-foreground = ${colors.disabled}

[module/memory]
type = internal/memory
interval = 2
format-prefix = "RAM "
format-prefix-foreground = ${colors.primary}
label = %percentage_used:2%%

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "CPU "
format-prefix-foreground = ${colors.primary}
label = %percentage:2%%

[module/date]
type = internal/date
interval = 1

date = %H:%M
date-alt = %Y-%m-%d %H:%M:%S

label = %date%
label-foreground = ${colors.primary}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 99

format-charging = <label-charging>
format-charging-prefix = "CHR "
format-charging-prefix-foreground = ${colors.primary}

format-discharging = <label-discharging>
format-discharging-prefix = "BAT "
format-discharging-prefix-foreground = ${colors.primary}

format-full-prefix = "FULL "
format-full-prefix-foreground = ${colors.primary}

[module/wlan]
type = internal/network
interface-type = wireless
interval = 3.0

format-connected = <label-connected>
format-connected-prefix = "WiFi "
format-connected-prefix-foreground = ${colors.primary}
label-connected = %essid%

format-disconnected = <label-disconnected>
label-disconnected = disconnected
label-disconnected-foreground = ${colors.disabled}

[module/eth]
type = internal/network
interface-type = wired
interval = 3.0

format-connected-prefix = "LAN "
format-connected-prefix-foreground = ${colors.primary}
label-connected = %local_ip%

format-disconnected = <label-disconnected>
label-disconnected = disconnected
label-disconnected-foreground = ${colors.disabled}

[settings]
screenchange-reload = true
pseudo-transparency = true
EOF

# Script de lanzamiento de Polybar
cat > ~/.config/polybar/launch.sh << 'EOF'
#!/bin/bash

# Terminar instancias en ejecución
killall -q polybar

# Esperar hasta que los procesos se hayan cerrado
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar polybar
polybar main &

echo "Polybar lanzado..."
EOF

chmod +x ~/.config/polybar/launch.sh

# Configuración de kitty
echo -e "${BLUE}Configurando kitty...${NC}"
cat > ~/.config/kitty/kitty.conf << 'EOF'
# Dracula theme for kitty
foreground            #f8f8f2
background            #282a36
selection_foreground  #ffffff
selection_background  #44475a

# Black
color0  #21222c
color8  #6272a4

# Red
color1  #ff5555
color9  #ff6e6e

# Green
color2  #50fa7b
color10 #69ff94

# Yellow
color3  #f1fa8c
color11 #ffffa5

# Blue
color4  #bd93f9
color12 #d6acff

# Magenta
color5  #ff79c6
color13 #ff92df

# Cyan
color6  #8be9fd
color14 #a4ffff

# White
color7  #f8f8f2
color15 #ffffff

# URL styles
url_color #8be9fd
url_style curly

# Cursor colors
cursor            #f8f8f2
cursor_text_color background

# Tab bar colors
active_tab_foreground   #282a36
active_tab_background   #f8f8f2
inactive_tab_foreground #282a36
inactive_tab_background #6272a4

# Font configuration
font_family      Fira Code
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 11.0

# Terminal bell
enable_audio_bell no

# Window settings
remember_window_size  no
initial_window_width  82c
initial_window_height 25c
window_padding_width 5

# Keyboard shortcuts
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
EOF

# Configuración de Rofi
echo -e "${BLUE}Configurando Rofi...${NC}"
mkdir -p ~/.config/rofi
cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "window,run,ssh,drun";
    font: "Fira Code 12";
    show-icons: true;
    icon-theme: "Papirus";
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "   Apps ";
    display-run: "   Run ";
    display-window: " 﩯  Window";
    display-Network: " 󰤨  Network";
    sidebar-mode: true;
}

* {
    bg-col:  #282a36;
    bg-col-light: #44475a;
    border-col: #bd93f9;
    selected-col: #44475a;
    blue: #bd93f9;
    fg-col: #f8f8f2;
    fg-col2: #ff79c6;
    grey: #6272a4;
    width: 600;
}

element-text, element-icon , mode-switcher {
    background-color: inherit;
    text-color:       inherit;
}

window {
    height: 360px;
    border: 3px;
    border-color: @border-col;
    background-color: @bg-col;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col;
    border-radius: 5px;
    padding: 2px;
}

prompt {
    background-color: @blue;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 3px;
    margin: 20px 0px 0px 20px;
}

textbox-prompt-colon {
    expand: false;
    str: ":";
}

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px 0px 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 2;
    lines: 5;
    background-color: @bg-col;
}

element {
    padding: 5px;
    background-color: @bg-col;
    text-color: @fg-col  ;
}

element-icon {
    size: 25px;
}

element selected {
    background-color:  @selected-col ;
    text-color: @fg-col2  ;
}

mode-switcher {
    spacing: 0;
  }

button {
    padding: 10px;
    background-color: @bg-col-light;
    text-color: @grey;
    vertical-align: 0.5; 
    horizontal-align: 0.5;
}

button selected {
  background-color: @bg-col;
  text-color: @blue;
}
EOF

# Configuración de Picom (compositor para efectos visuales)
echo -e "${BLUE}Configurando Picom...${NC}"
cat > ~/.config/picom/picom.conf << 'EOF'
# Sombras
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.60;

# Transparencia
inactive-opacity = 0.90;
active-opacity = 1;
frame-opacity = 0.90;
inactive-opacity-override = false;

# Fundido
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;

# Esquinas redondeadas
corner-radius = 10;
rounded-corners-exclude = [
  "window_type = 'dock'",
  "window_type = 'desktop'"
];

# Configuraciones generales
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
detect-transient = true;
detect-client-leader = true;
use-damage = true;
log-level = "warn";

# Reglas de opacidad
opacity-rule = [
  "90:class_g = 'kitty'",
  "90:class_g = 'Rofi'"
];
EOF

# Configuración de LightDM
echo -e "${BLUE}Configurando LightDM...${NC}"
sudo mkdir -p /etc/lightdm
sudo cat > /etc/lightdm/lightdm-gtk-greeter.conf << 'EOF'
[greeter]
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = Fira Code 11
background = /usr/share/backgrounds/void.png
clock-format = %H:%M:%S
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

# Crear un fondo de pantalla predeterminado para lightdm si no existe
sudo mkdir -p /usr/share/backgrounds
if [ ! -f /usr/share/backgrounds/void.png ]; then
    echo -e "${YELLOW}Descargando imagen de fondo para LightDM...${NC}"
    sudo wget -O /usr/share/backgrounds/void.png https://raw.githubusercontent.com/void-linux/void-artwork/master/splash/void-live-splash.png
fi

# Habilitar servicios
echo -e "${BLUE}Habilitando servicios...${NC}"
sudo ln -sf /etc/sv/lightdm /var/service/
sudo ln -sf /etc/sv/tlp /var/service/
sudo ln -sf /etc/sv/dbus /var/service/
sudo ln -sf /etc/sv/NetworkManager /var/service/

# Verificar que los servicios están habilitados
echo -e "${BLUE}Verificando servicios...${NC}"
for service in lightdm tlp dbus NetworkManager; do
    if [ -L /var/service/$service ]; then
        echo -e "${GREEN}✓ Servicio $service habilitado${NC}"
    else
        echo -e "${RED}✗ Servicio $service no habilitado${NC}"
    fi
done

# Instalar fuentes necesarias
echo -e "${BLUE}Instalando fuentes adicionales...${NC}"
sudo xbps-install -Sy font-firacode font-awesome5

# También instalamos algunas fuentes adicionales manualmente
mkdir -p ~/.fonts
cd /tmp
echo -e "${YELLOW}Descargando fuentes Nerd Fonts...${NC}"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/FiraCode.zip || \
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip

if [ -f FiraCode.zip ]; then
    unzip -q FiraCode.zip -d ~/.fonts
    echo -e "${GREEN}✓ Nerd Fonts instaladas${NC}"
else
    echo -e "${RED}✗ Error al descargar Nerd Fonts${NC}"
fi

cd ~
fc-cache -fv

# Crear directorios adicionales
mkdir -p ~/Pictures/Screenshots
mkdir -p ~/Documents
mkdir -p ~/Downloads

# Crear un wallpaper simple con feh
echo -e "${BLUE}Configurando fondo de pantalla...${NC}"
mkdir -p ~/.config/feh
wget -q -O ~/Pictures/wallpaper.jpg "https://raw.githubusercontent.com/void-linux/void-artwork/master/splash/void-live-splash.png"
echo '#!/bin/sh' > ~/.fehbg
echo "feh --bg-fill $HOME/Pictures/wallpaper.jpg" >> ~/.fehbg
chmod +x ~/.fehbg

# Configurar .xinitrc
echo -e "${BLUE}Configurando .xinitrc...${NC}"
cat > ~/.xinitrc << 'EOF'
#!/bin/sh

# Cargar recursos X
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

# Iniciar servicios
xsetroot -cursor_name left_ptr &
~/.fehbg &
setxkbmap -layout es &  # Cambiar por tu distribución de teclado

# Iniciar gestor de ventanas
exec bspwm
EOF

chmod +x ~/.xinitrc

# Configurar shell con configuración básica
echo -e "${BLUE}Configurando .bashrc...${NC}"
cat >> ~/.bashrc << 'EOF'

# Aliases
alias ls='ls --color=auto'
alias ll='ls -la'
alias grep='grep --color=auto'
alias update='sudo xbps-install -Su'
alias install='sudo xbps-install -S'
alias remove='sudo xbps-remove -R'
alias search='xbps-query -Rs'
alias clean='sudo xbps-remove -Oo'

# Prompt personalizado
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Mostrar info del sistema
if [ -f /usr/bin/neofetch ]; then
    neofetch
fi
EOF

# Verificar que todo está instalado correctamente
echo -e "${BLUE}Verificando la instalación...${NC}"
echo -e "${YELLOW}Comprobando paquetes críticos para el entorno gráfico...${NC}"

CRITICAL_PACKAGES="xorg-minimal bspwm sxhkd lightdm"
MISSING_PACKAGES=""

for package in $CRITICAL_PACKAGES; do
    if ! xbps-query -l | grep -q "^ii $package"; then
        MISSING_PACKAGES="$MISSING_PACKAGES $package"
    fi
done

if [ -n "$MISSING_PACKAGES" ]; then
    echo -e "${RED}ADVERTENCIA: Los siguientes paquetes críticos no están instalados:${NC}"
    echo -e "${RED}$MISSING_PACKAGES${NC}"
    echo -e "${YELLOW}Intentando reinstalar paquetes faltantes...${NC}"
    sudo xbps-install -Sy $MISSING_PACKAGES
else
    echo -e "${GREEN}✓ Todos los paquetes críticos están instalados${NC}"
fi

echo -e "${GREEN}Instalación completada!${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "${YELLOW}Para iniciar tu nuevo entorno:${NC}"
echo -e "1. Reinicia tu sistema: ${GREEN}sudo reboot${NC}"
echo -e "2. Inicia sesión a través de LightDM"
echo -e "3. Si LightDM no inicia automáticamente, puedes iniciarlo con: ${GREEN}sudo sv start lightdm${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "${YELLOW}Atajos de teclado principales:${NC}"
echo -e "${GREEN}Super + Enter${NC}: Abrir terminal (Kitty)"
echo -e "${GREEN}Super + Space${NC}: Menú de aplicaciones (Rofi)"
echo -e "${GREEN}Super + 1-9${NC}: Cambiar entre espacios de trabajo"
echo -e "${GREEN}Super + Shift + 1-9${NC}: Mover ventana a otro espacio de trabajo"
echo -e "${GREEN}Super + h/j/k/l${NC}: Navegar entre ventanas"
echo -e "${GREEN}Super + Shift + h/j/k/l${NC}: Mover ventanas"
echo -e "${GREEN}Super + q${NC}: Cerrar ventana"
echo -e "${GREEN}Super + Alt + q${NC}: Cerrar sesión"
echo -e "${GREEN}Super + Alt + r${NC}: Reiniciar BSPWM"
echo -e "${BLUE}==================================================${NC}"
