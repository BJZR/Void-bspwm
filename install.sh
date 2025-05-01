#!/bin/bash
# Script ultra-comprimido BSPWM/Void - Tema Oscuro-Morado
R='\033[0;31m' G='\033[0;32m' Y='\033[0;33m' B='\033[0;34m' N='\033[0m'
echo -e "${B}=== BSPWM Minimalista Morado ===${N}"

# Función ultra-comprimida instalación
pkg_i() { xbps-query -l | grep -q "^ii $1" && echo -e "${G}✓ $1${N}" || { echo -e "${Y}→ $1${N}"; sudo xbps-install -Sy "$1" && echo -e "${G}✓ $1${N}" || echo -e "${R}✗ $1${N}"; } }

# Actualizar e instalar base
sudo xbps-install -Suy xbps && sudo xbps-install -Suy
BASE="base-devel git curl wget xorg-minimal xorg-fonts xinit libX11-devel libXft-devel libXinerama-devel"
for pkg in $BASE; do pkg_i "$pkg"; done

# Paquetes - Ultra-comprimido
PKGS=(
    # WM y esenciales
    "bspwm" "sxhkd" "polybar" "picom" "feh" "lightdm" "lightdm-gtk-greeter"
    # Terminales y navegador
    "kitty" "alacritty" "qutebrowser" 
    # Sistema y tema
    "yad" "i3lock" "bluez" "bluez-alsa" "NetworkManager" "network-manager-applet" "rofi"
    "tlp" "acpi" "xtools" "dunst" "lxappearance" "gtk+3" "dbus" "clipmenu" "xdotool"
    # Fuentes con iconos
    "font-firacode" "font-awesome5" "noto-fonts-ttf" "font-symbola"
    # Utilidades
    "ranger" "neofetch" "htop" "pulseaudio" "pavucontrol" "alsa-utils" 
    "xbacklight" "scrot" "papirus-icon-theme" "qdirstat"
)
for pkg in "${PKGS[@]}"; do pkg_i "$pkg"; done

# Directorios
mkdir -p ~/.config/{bspwm,sxhkd,polybar,kitty,alacritty,rofi,picom,dunst,themes,qutebrowser} ~/.fonts ~/.local/bin ~/Pictures/{Screenshots,wallpaper}

# Fondo
wget -q -O ~/Pictures/wallpaper/morado.jpg "https://raw.githubusercontent.com/void-linux/void-artwork/master/splash/void-live-splash.png"

# BSPWM Config ultra-comprimido
cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/sh
# Autostart
sxhkd &
picom --experimental-backends &
~/.config/polybar/launch.sh &
feh --bg-fill ~/Pictures/wallpaper/morado.jpg &
nm-applet &
blueman-applet &
dunst &
clipmenud &

# Config
bspc monitor -d   󰿟    󰎬 
bspc config border_width         2
bspc config window_gap          10
bspc config top_padding         30
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config focus_follows_pointer true

# Colores - Ultra-Morado
bspc config normal_border_color "#44475a"
bspc config active_border_color "#bd93f9"
bspc config focused_border_color "#ff79c6"

# Reglas
bspc rule -a qutebrowser desktop='^2'
bspc rule -a kitty desktop='^1'
bspc rule -a Yad state=floating
EOF
chmod +x ~/.config/bspwm/bspwmrc

# Atajos super-comprimidos
cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
# Terminal
super + Return
	kitty

super + shift + Return
	alacritty

# Lanzadores
super + @space
	rofi -show drun

# Recargar 
super + Escape
	pkill -USR1 -x sxhkd

# Salir/reiniciar bspwm
super + alt + {q,r}
	bspc {quit,wm -r}

# Cerrar ventana
super + c
	bspc node -c

# Monocle
super + m
	bspc desktop -l next

# Enviar a desktop
super + shift + {1-5}
	bspc node -d '^{1-5}'

# Ir a desktop
super + {1-5}
	bspc desktop -f '^{1-5}'

# Control ventanas
super + {h,j,k,l}
	bspc node -f {west,south,north,east}
super + shift + {h,j,k,l}
	bspc node -s {west,south,north,east}

# Audio
XF86Audio{RaiseVolume,LowerVolume,Mute}
	amixer -q set Master {5%+,5%-,toggle}

# Brillo
XF86MonBrightness{Up,Down}
	xbacklight -{inc,dec} 10

# Screenshots
Print
    scrot '%Y%m%d_%H%M%S.png' -e 'mv $f ~/Pictures/Screenshots/'

# NUEVOS ATAJOS SÚPER INTUITIVOS
# Bloquear
super + x
    i3lock -i ~/Pictures/wallpaper/morado.jpg -c 000000

# Suspender
super + z
    systemctl suspend

# Apagar
super + shift + x
    yad --text="¿Desea apagar el sistema?" --button=gtk-yes:0 --button=gtk-no:1 && systemctl poweroff

# Portapapeles
super + v
    CM_LAUNCHER=rofi clipmenu

# Bluetooth
super + b
    yad --form --width=300 --height=200 --title="Bluetooth" --button="Abrir Gestor":0 --text="<span font='16' foreground='#bd93f9'>󰂯 Bluetooth</span>\n\nGestione sus conexiones bluetooth" && blueman-manager

# Red
super + n
    nm-connection-editor

# Calendario
super + d
    yad --calendar --width=350 --height=300 --title="Calendario" --borders=10 --button=gtk-close:0 --center

# Gestor de archivos
super + f
    kitty -e ranger

# Monitor de sistema
super + s
    kitty -e htop

# Información del sistema
super + i
    yad --text-info --filename=<(neofetch --stdout) --width=600 --height=500 --title="Información del sistema" --button=gtk-close:0 --fontname="FiraCode 12" --fore="#f8f8f2" --back="#282a36" --center --borders=10
EOF

# Polybar ultra-compacta
mkdir -p ~/.config/polybar
cat > ~/.config/polybar/config.ini << 'EOF'
[colors]
bg = #282a36
bg-alt = #44475a
fg = #f8f8f2
primary = #bd93f9
secondary = #ff79c6
alert = #ff5555
disabled = #6272a4

[bar/main]
width = 100%
height = 24pt
background = ${colors.bg}
foreground = ${colors.fg}
line-size = 3pt
padding-left = 0
padding-right = 1
module-margin = 1
separator = |
separator-foreground = ${colors.disabled}
font-0 = "Fira Code:size=10;2"
font-1 = "Font Awesome 5 Free Solid:size=10;2"
font-2 = "Symbola:style=Regular:size=10;2"
modules-left = xworkspaces xwindow
modules-center = date
modules-right = filesystem pulseaudio memory cpu battery wlan
cursor-click = pointer
enable-ipc = true

[module/xworkspaces]
type = internal/xworkspaces
label-active = %name%
label-active-background = ${colors.bg-alt}
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
label-mounted =  %percentage_used%%
label-mounted-foreground = ${colors.primary}

[module/pulseaudio]
type = internal/pulseaudio
format-volume-prefix = " "
format-volume-prefix-foreground = ${colors.primary}
format-volume = <label-volume>
label-volume = %percentage%%
label-muted = 
label-muted-foreground = ${colors.disabled}

[module/memory]
type = internal/memory
interval = 2
format-prefix = " "
format-prefix-foreground = ${colors.primary}
label = %percentage_used:2%%

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
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
format-charging-prefix = " "
format-charging-prefix-foreground = ${colors.primary}
format-discharging-prefix = " "
format-discharging-prefix-foreground = ${colors.primary}
format-full-prefix = " "
format-full-prefix-foreground = ${colors.primary}

[module/wlan]
type = internal/network
interface-type = wireless
interval = 3.0
format-connected-prefix = " "
format-connected-prefix-foreground = ${colors.primary}
label-connected = %essid%
label-disconnected = 
label-disconnected-foreground = ${colors.disabled}

[settings]
screenchange-reload = true
EOF

# Launcher script
cat > ~/.config/polybar/launch.sh << 'EOF'
#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar main &
EOF
chmod +x ~/.config/polybar/launch.sh

# Kitty terminal ultra-comprimido
cat > ~/.config/kitty/kitty.conf << 'EOF'
foreground #f8f8f2
background #282a36
selection_foreground #ffffff
selection_background #44475a
color0 #21222c
color8 #6272a4
color1 #ff5555
color9 #ff6e6e
color2 #50fa7b
color10 #69ff94
color3 #f1fa8c
color11 #ffffa5
color4 #bd93f9
color12 #d6acff
color5 #ff79c6
color13 #ff92df
color6 #8be9fd
color14 #a4ffff
color7 #f8f8f2
color15 #ffffff
cursor #f8f8f2
cursor_text_color background
font_family Fira Code
font_size 11.0
enable_audio_bell no
window_padding_width 5
EOF

# Alacritty Terminal en TOML (no YAML)
cat > ~/.config/alacritty/alacritty.toml << 'EOF'
[window]
padding = { x = 5, y = 5 }
dynamic_title = true

[scrolling]
history = 10000
multiplier = 3

[font]
normal = { family = "Fira Code" }
size = 11.0

[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"

[colors.cursor]
text = "CellBackground"
cursor = "CellForeground"

[colors.search.matches]
foreground = "#44475a"
background = "#50fa7b"

[colors.normal]
black = "#21222c"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#f8f8f2"

[shell]
program = "/bin/bash"
args = ["-c", "neofetch && exec bash"]
EOF

# Rofi ultra-comprimido
cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "window,run,ssh,drun";
    font: "Fira Code 12";
    show-icons: true;
    icon-theme: "Papirus-Dark";
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    location: 0;
    hide-scrollbar: true;
    display-drun: "  Apps ";
    display-run: "  Run ";
    display-window: "  Window";
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

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 2;
    lines: 5;
    background-color: @bg-col;
}

element {
    padding: 5px;
    background-color: @bg-col;
    text-color: @fg-col;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @fg-col2;
}
EOF

# Picom (compositor)
cat > ~/.config/picom/picom.conf << 'EOF'
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.6;
inactive-opacity = 0.9;
active-opacity = 1;
frame-opacity = 0.9;
inactive-opacity-override = false;
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
corner-radius = 10;
rounded-corners-exclude = [
  "window_type = 'dock'",
  "window_type = 'desktop'"
];
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
use-damage = true;
log-level = "warn";
opacity-rule = [
  "90:class_g = 'kitty'",
  "90:class_g = 'Rofi'"
];
EOF

# Dunst ultra-comprimido
cat > ~/.config/dunst/dunstrc << 'EOF'
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    scale = 0
    notification_limit = 0
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 15
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 2
    frame_color = "#bd93f9"
    separator_color = frame
    sort = yes
    font = Fira Code 10
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
    max_icon_size = 32
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/rofi -dmenu -p dunst:
    browser = /usr/bin/qutebrowser
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 10
    ignore_dbusclose = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "#282a36"
    foreground = "#f8f8f2"
    timeout = 10

[urgency_normal]
    background = "#282a36"
    foreground = "#f8f8f2"
    timeout = 10

[urgency_critical]
    background = "#ff5555"
    foreground = "#f8f8f2"
    frame_color = "#ff5555"
    timeout = 0
EOF

# LightDM tema oscuro/morado
sudo mkdir -p /etc/lightdm
sudo tee /etc/lightdm/lightdm-gtk-greeter.conf > /dev/null << 'EOF'
[greeter]
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = Fira Code 11
background = /usr/share/backgrounds/void.png
clock-format = %H:%M:%S
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

# Configurar fondos para lightdm
sudo mkdir -p /usr/share/backgrounds
sudo cp ~/Pictures/wallpaper/morado.jpg /usr/share/backgrounds/void.png 2>/dev/null || 
    sudo wget -O /usr/share/backgrounds/void.png "https://raw.githubusercontent.com/void-linux/void-artwork/master/splash/void-live-splash.png"

# Tema GTK oscuro/morado mejorado
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Fira Code 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-application-prefer-dark-theme=1
EOF

cat > ~/.gtkrc-2.0 << 'EOF'
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Papirus-Dark"
gtk-font-name="Fira Code 11"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

# qutebrowser config minimalista
cat > ~/.config/qutebrowser/config.py << 'EOF'
c.colors.webpage.preferred_color_scheme = 'dark'
c.colors.webpage.darkmode.enabled = True
c.fonts.default_family = ["Fira Code"]
c.fonts.default_size = "11pt"
c.url.start_pages = ["https://voidlinux.org"]
c.url.searchengines = {"DEFAULT": "https://duckduckgo.com/?q={}"}
EOF

# Habilitar servicios
for srv in lightdm tlp dbus NetworkManager bluetoothd; do
    sudo ln -sf /etc/sv/$srv /var/service/ 2>/dev/null
done

# .xinitrc con teclado la-co (Colombia)
cat > ~/.xinitrc << 'EOF'
#!/bin/sh
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
xsetroot -cursor_name left_ptr &
feh --bg-fill ~/Pictures/wallpaper/morado.jpg &
setxkbmap -layout la -variant co &
exec bspwm
EOF
chmod +x ~/.xinitrc

# Configurar shell ultra-comprimido
cat >> ~/.bashrc << 'EOF'
# Alias ultra-comprimidos
alias ls='ls --color=auto'
alias ll='ls -la'
alias up='sudo xbps-install -Su'
alias in='sudo xbps-install -S'
alias rm='sudo xbps-remove -R'
alias se='xbps-query -Rs'
alias cl='sudo xbps-remove -Oo'
PS1='\[\033[01;35m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# Mensaje final ultra-comprimido
echo -e "${G}¡INSTALACIÓN COMPLETA!${N}"
echo -e "${Y}ATAJOS RÁPIDOS:${N}"
echo -e "${G}Super+Enter${N}: Terminal Kitty"
echo -e "${G}Super+Space${N}: Menú apps"
echo -e "${G}Super+c${N}: Cerrar ventana"
echo -e "${G}Super+x${N}: Bloquear"
echo -e "${G}Super+z${N}: Suspender"
echo -e "${G}Super+b${N}: Bluetooth"
echo -e "${G}Super+n${N}: Red"
echo -e "${G}Super+v${N}: Portapapeles"
echo -e "${G}Super+d${N}: Calendario"
echo -e "${G}Super+f${N}: Archivos"
echo -e "${G}Super+i${N}: Info sistema"
echo -e "${G}Super+s${N}: Monitor sistema"