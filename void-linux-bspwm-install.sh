# Configuración de Dunst (tema oscuro)
echo -e "${BLUE}Configurando Dunst (temas claro y oscuro)...${NC}"
mkdir -p ~/.config/dunst

# Tema oscuro para Dunst
cat > ~/.config/dunst/dunstrc.dark << 'EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x40
    scale = 0
    notification_limit = 20
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 0
    separator_height = 2
    padding = 12
    horizontal_padding = 12
    text_icon_padding = 12
    frame_width = 2
    frame_color = "#BD93F9"
    separator_color = frame
    sort = yes
    font = JetBrainsMono Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    min_icon_size = 0
    max_icon_size = 48
    icon_path = /usr/share/icons/Papirus-Dark/16x16/status/:/usr/share/icons/Papirus-Dark/16x16/devices/:/usr/share/icons/Papirus-Dark/16x16/apps/
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 8
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "#282A36"
    foreground = "#F8F8F2"
    timeout = 10

[urgency_normal]
    background = "#282A36"
    foreground = "#F8F8F2"
    timeout = 10

[urgency_critical]
    background = "#FF5555"
    foreground = "#F8F8F2"
    frame_color = "#FF5555"
    timeout = 0
EOF

# Tema claro para Dunst
cat > ~/.config/dunst/dunstrc.light << 'EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x40
    scale = 0
    notification_limit = 20
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 0
    separator_height = 2
    padding = 12
    horizontal_padding = 12
    text_icon_padding = 12
    frame_width = 2
    frame_color = "#6272A4"
    separator_color = frame
    sort = yes
    font = JetBrainsMono Nerd Font 10
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count =#!/bin/bash

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

# Configuración de Rofi (tema oscuro)
echo -e "${BLUE}Configurando Rofi (temas claro y oscuro)...${NC}"
mkdir -p ~/.config/rofi

# Tema oscuro
cat > ~/.config/rofi/config.rasi.dark << 'EOF'
configuration {
    modi: "drun,run,window,ssh";
    font: "JetBrainsMono Nerd Font 12";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    terminal: "kitty";
    drun-display-format: "{icon}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "";
    display-run: "";
    display-window: "";
    display-ssh: "";
    sidebar-mode: false;
}

* {
    dark-bg:     #1E2127;
    dark-fg:     #FFFFFF;
    dark-accent: #BD93F9;
    dark-urgent: #FF5555;
    dark-border: #44475A;

    background-color: transparent;
    text-color:       @dark-fg;
    spacing:          10;
    width:            600px;
}

window {
    background-color: @dark-bg;
    border:           2px;
    border-color:     @dark-accent;
    border-radius:    10px;
    padding:          20px;
}

inputbar {
    margin:           0px 0px 20px 0px;
    background-color: @dark-border;
    border-radius:    50%;
    padding:          8px 16px;
    spacing:          8px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @dark-accent;
    font:             "JetBrainsMono Nerd Font 12";
}

entry {
    background-color: transparent;
    placeholder:      "Search";
    placeholder-color: @dark-fg;
}

mainbox {
    children: [ inputbar, listview ];
}

listview {
    layout:      horizontal;
    spacing:     12px;
    lines:       1;
    fixed-height: false;
}

element {
    orientation: vertical;
    padding:     12px;
    border-radius: 8px;
    min-width:   70px;
}

element-icon {
    size:        32px;
    horizontal-align: 0.5;
}

element-text {
    horizontal-align: 0.5;
    font:        "JetBrainsMono Nerd Font 24";
}

element selected {
    background-color: @dark-border;
    border:           2px;
    border-color:     @dark-accent;
}

element-text selected {
    text-color: @dark-accent;
}

element-text active {
    text-color: @dark-accent;
}

element-text urgent {
    text-color: @dark-urgent;
}

// Aplicaciones más utilizadas con iconos tipográficos
@import "icons-dark.rasi"
EOF

# Tema claro
cat > ~/.config/rofi/config.rasi.light << 'EOF'
configuration {
    modi: "drun,run,window,ssh";
    font: "JetBrainsMono Nerd Font 12";
    show-icons: true;
    icon-theme: "Papirus";
    terminal: "kitty";
    drun-display-format: "{icon}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "";
    display-run: "";
    display-window: "";
    display-ssh: "";
    sidebar-mode: false;
}

* {
    light-bg:     #F8F8F2;
    light-fg:     #282A36;
    light-accent: #6272A4;
    light-urgent: #FF5555;
    light-border: #E6E6E6;

    background-color: transparent;
    text-color:       @light-fg;
    spacing:          10;
    width:            600px;
}

window {
    background-color: @light-bg;
    border:           2px;
    border-color:     @light-accent;
    border-radius:    10px;
    padding:          20px;
}

inputbar {
    margin:           0px 0px 20px 0px;
    background-color: @light-border;
    border-radius:    50%;
    padding:          8px 16px;
    spacing:          8px;
    children:         [ prompt, entry ];
}

prompt {
    background-color: transparent;
    text-color:       @light-accent;
    font:             "JetBrainsMono Nerd Font 12";
}

entry {
    background-color: transparent;
    placeholder:      "Search";
    placeholder-color: @light-fg;
}

mainbox {
    children: [ inputbar, listview ];
}

listview {
    layout:      horizontal;
    spacing:     12px;
    lines:       1;
    fixed-height: false;
}

element {
    orientation: vertical;
    padding:     12px;
    border-radius: 8px;
    min-width:   70px;
}

element-icon {
    size:        32px;
    horizontal-align: 0.5;
}

element-text {
    horizontal-align: 0.5;
    font:        "JetBrainsMono Nerd Font 24";
}

element selected {
    background-color: @light-border;
    border:           2px;
    border-color:     @light-accent;
}

element-text selected {
    text-color: @light-accent;
}

element-text active {
    text-color: @light-accent;
}

element-text urgent {
    text-color: @light-urgent;
}

// Aplicaciones más utilizadas con iconos tipográficos
@import "icons-light.rasi"
EOF

# Iconos para tema oscuro
cat > ~/.config/rofi/icons-dark.rasi << 'EOF'
/*
 * Iconos tipográficos para aplicaciones en Rofi (tema oscuro)
 */

element-text {
    text-color: inherit;
}

// Reescritura de iconos tipográficos para aplicaciones principales
@media ( -xrdb-drun-display-format: "{icon}" ) {
    element-text {
        expand: true;
        size: 24px;
    }
    element {
        padding: 15px;
        border-radius: 12px;
    }
}

element.selected.active {
    text-color: @dark-accent;
}

// Asignar iconos tipográficos a aplicaciones comunes
element-text, element-icon {
    background-color: inherit;
    text-color:       inherit;
}

// Firefox
element-text.normal.normal:nth-child(1) {
    /* Estas sustituciones solo aplican cuando se corre en modo -show drun */
    text-color: #FF9500;
}

// Terminal
element-text.normal.normal:nth-child(2) {
    text-color: #50FA7B;
}

// File Manager
element-text.normal.normal:nth-child(3) {
    text-color: #BD93F9;
}

// Editor
element-text.normal.normal:nth-child(4) {
    text-color: #8BE9FD;
}

// Settings
element-text.normal.normal:nth-child(5) {
    text-color: #FF79C6;
}
EOF

# Iconos para tema claro
cat > ~/.config/rofi/icons-light.rasi << 'EOF'
/*
 * Iconos tipográficos para aplicaciones en Rofi (tema claro)
 */

element-text {
    text-color: inherit;
}

// Reescritura de iconos tipográficos para aplicaciones principales
@media ( -xrdb-drun-display-format: "{icon}" ) {
    element-text {
        expand: true;
        size: 24px;
    }
    element {
        padding: 15px;
        border-radius: 12px;
    }
}

element.selected.active {
    text-color: @light-accent;
}

// Asignar iconos tipográficos a aplicaciones comunes
element-text, element-icon {
    background-color: inherit;
    text-color:       inherit;
}

// Firefox
element-text.normal.normal:nth-child(1) {
    /* Estas sustituciones solo aplican cuando se corre en modo -show drun */
    text-color: #E66000;
}

// Terminal
element-text.normal.normal:nth-child(2) {
    text-color: #2D7D4E;
}

// File Manager
element-text.normal.normal:nth-child(3) {
    text-color: #5546B8;
}

// Editor
element-text.normal.normal:nth-child(4) {
    text-color: #0083A3;
}

// Settings
element-text.normal.normal:nth-child(5) {
    text-color: #8F0069;
}
EOF

# Crear un enlace simbólico al tema oscuro como predeterminado
ln -sf ~/.config/rofi/config.rasi.dark ~/.config/rofi/config.rasi

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
sudo xbps-install -Sy font-firacode font-awesome5 font-material-design-icons-ttf

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

# Instalación de JetBrainsMono Nerd Font para tener más iconos tipográficos
echo -e "${YELLOW}Descargando JetBrainsMono Nerd Font...${NC}"
wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/JetBrainsMono.zip || \
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip

if [ -f JetBrainsMono.zip ]; then
    unzip -q JetBrainsMono.zip -d ~/.fonts
    echo -e "${GREEN}✓ JetBrainsMono Nerd Font instalada${NC}"
else
    echo -e "${RED}✗ Error al descargar JetBrainsMono Nerd Font${NC}"
fi

cd ~
fc-cache -fv

# Crear un sistema de temas
echo -e "${BLUE}Configurando sistema de temas...${NC}"
mkdir -p ~/.config/theme
cat > ~/.config/theme/theme-manager.sh << 'EOF'
#!/bin/bash

# Script para cambiar temas
# Uso: theme-manager.sh [dark|light]

THEME_DIR="$HOME/.config/theme"
CURRENT_THEME_FILE="$THEME_DIR/current_theme"

# Colores para mensajes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Verificar argumentos
if [ "$1" = "dark" ]; then
    echo "dark" > "$CURRENT_THEME_FILE"
    echo -e "${GREEN}Cambiando al tema oscuro${NC}"
elif [ "$1" = "light" ]; then
    echo "light" > "$CURRENT_THEME_FILE"
    echo -e "${GREEN}Cambiando al tema claro${NC}"
elif [ -z "$1" ]; then
    # Sin argumento, mostrar tema actual o establecer oscuro como predeterminado
    if [ -f "$CURRENT_THEME_FILE" ]; then
        CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")
        echo -e "${BLUE}Tema actual: ${YELLOW}$CURRENT_THEME${NC}"
        exit 0
    else
        echo "dark" > "$CURRENT_THEME_FILE"
        echo -e "${GREEN}Estableciendo tema oscuro como predeterminado${NC}"
    fi
else
    echo -e "${YELLOW}Uso: theme-manager.sh [dark|light]${NC}"
    exit 1
fi

# Obtener el tema actual
CURRENT_THEME=$(cat "$CURRENT_THEME_FILE")

# Aplicar tema a Rofi
if [ "$CURRENT_THEME" = "dark" ]; then
    ln -sf "$HOME/.config/rofi/config.rasi.dark" "$HOME/.config/rofi/config.rasi"
else
    ln -sf "$HOME/.config/rofi/config.rasi.light" "$HOME/.config/rofi/config.rasi"
fi

# Aplicar tema a Dunst
if [ "$CURRENT_THEME" = "dark" ]; then
    ln -sf "$HOME/.config/dunst/dunstrc.dark" "$HOME/.config/dunst/dunstrc"
else
    ln -sf "$HOME/.config/dunst/dunstrc.light" "$HOME/.config/dunst/dunstrc"
fi

# Aplicar tema a Polybar
if [ "$CURRENT_THEME" = "dark" ]; then
    ln -sf "$HOME/.config/polybar/config.ini.dark" "$HOME/.config/polybar/config.ini"
else
    ln -sf "$HOME/.config/polybar/config.ini.light" "$HOME/.config/polybar/config.ini"
fi

# Aplicar tema a Kitty
if [ "$CURRENT_THEME" = "dark" ]; then
    ln -sf "$HOME/.config/kitty/kitty.conf.dark" "$HOME/.config/kitty/kitty.conf"
else
    ln -sf "$HOME/.config/kitty/kitty.conf.light" "$HOME/.config/kitty/kitty.conf"
fi

# Recargar configuraciones
pkill -USR1 dunst 2>/dev/null || true
[ -f "$HOME/.config/polybar/launch.sh" ] && "$HOME/.config/polybar/launch.sh" &

echo -e "${GREEN}✓ Tema aplicado correctamente${NC}"
EOF

chmod +x ~/.config/theme/theme-manager.sh

# Enlace simbólico para acceder al script desde cualquier lugar
mkdir -p ~/.local/bin
ln -sf ~/.config/theme/theme-manager.sh ~/.local/bin/theme-manager

# Agregar el manejador de temas al PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

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
