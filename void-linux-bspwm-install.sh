#!/bin/bash
# Script instalación BSPWM ultraligero para Void Linux - Tema morado oscuro
# Optimizado para rendimiento y estética minimalista

C_RED='\033[0;31m'
C_GRN='\033[0;32m'
C_YLW='\033[0;33m'
C_BLU='\033[0;34m'
C_PRP='\033[0;35m'
C_NC='\033[0m'

log() { echo -e "${C_BLU}[*]${C_NC} $1"; }
ok() { echo -e "${C_GRN}[✓]${C_NC} $1"; }
err() { echo -e "${C_RED}[✗]${C_NC} $1"; }

# Función para instalar paquetes
pkg_install() {
    log "Instalando $1..."
    sudo xbps-install -Sy "$1" >/dev/null 2>&1 && ok "$1 instalado" || err "Error al instalar $1"
}

log "Iniciando instalación BSPWM ultraligero ▇ ▅ █ ▇"

# Actualizar sistema
log "Actualizando repositorios..."
sudo xbps-install -Suy xbps >/dev/null 2>&1
sudo xbps-install -Suy >/dev/null 2>&1
ok "Sistema actualizado"

# Paquetes esenciales (mínimo absoluto)
BASE="xorg-minimal xinit libX11-devel libXft-devel libXinerama-devel"
CORE="bspwm sxhkd polybar kitty rofi picom feh dunst"
UTILS="git curl xtools scrot xdg-utils dbus acpi"
EXTRA="font-firacode NetworkManager papirus-icon-theme"

log "Instalando componentes esenciales..."
sudo xbps-install -Sy $BASE $CORE $UTILS $EXTRA >/dev/null 2>&1
ok "Componentes base instalados"

# Crear estructura de directorios
log "Preparando directorios de configuración..."
mkdir -p ~/.config/{bspwm,sxhkd,polybar,kitty,rofi,picom,dunst,themes}
mkdir -p ~/.fonts
mkdir -p ~/.local/bin
mkdir -p ~/Pictures

# Tema de colores principal - morado oscuro
COLORS='{
    "dark0":     "#1a1b26",
    "dark1":     "#24283b",
    "dark2":     "#414868",
    "light0":    "#c0caf5",
    "light1":    "#a9b1d6",
    "light2":    "#9aa5ce",
    "accent0":   "#7aa2f7",
    "accent1":   "#bb9af7",
    "accent2":   "#9d7cd8",
    "accent3":   "#7dcfff",
    "accent4":   "#2ac3de",
    "accent5":   "#ff7a93"
}'

# Extraer valores para usar en configs
BG=$(echo $COLORS | jq -r '.dark0')
BG_ALT=$(echo $COLORS | jq -r '.dark1')
FG=$(echo $COLORS | jq -r '.light0')
FG_ALT=$(echo $COLORS | jq -r '.light1')
ACCENT=$(echo $COLORS | jq -r '.accent1')
ACCENT_ALT=$(echo $COLORS | jq -r '.accent2')
URGENT=$(echo $COLORS | jq -r '.accent5')

# === BSPWM ===
log "Configurando BSPWM..."
cat > ~/.config/bspwm/bspwmrc << EOF
#!/bin/sh
# Autostart
pgrep -x sxhkd > /dev/null || sxhkd &
pgrep -x picom > /dev/null || picom &
pgrep -x dunst > /dev/null || dunst &
pgrep -x nm-applet > /dev/null || nm-applet &
~/.config/polybar/launch.sh &
[ -f ~/.fehbg ] && ~/.fehbg &

# BSPWM config
bspc monitor -d 1 2 3 4 5
bspc config border_width         2
bspc config window_gap           8
bspc config top_padding          28
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config focus_follows_pointer true

# Colores
bspc config normal_border_color "$BG_ALT"
bspc config active_border_color "$ACCENT_ALT"
bspc config focused_border_color "$ACCENT"
bspc config presel_feedback_color "$ACCENT_ALT"

# Reglas básicas
bspc rule -a firefox desktop='^2' follow=on
bspc rule -a kitty desktop='^1' follow=on
EOF
chmod +x ~/.config/bspwm/bspwmrc

# === SXHKD ===
log "Configurando atajos de teclado..."
cat > ~/.config/sxhkd/sxhkdrc << EOF
# Terminal
super + Return
	kitty

# Launcher
super + @space
	rofi -show drun

# Recargar config
super + Escape
	pkill -USR1 -x sxhkd

# BSPWM: salir/reiniciar
super + alt + {q,r}
	bspc {quit,wm -r}

# Cerrar ventana
super + {_,shift + }q
	bspc node -{c,k}

# Alternar tiling/monocle
super + m
	bspc desktop -l next

# Enviar a escritorio
super + shift + {1-5}
	bspc node -d '^{1-5}'

# Cambiar a escritorio
super + {1-5}
	bspc desktop -f '^{1-5}'

# Foco en ventana
super + {h,j,k,l}
	bspc node -f {west,south,north,east}

# Mover ventana
super + shift + {h,j,k,l}
	bspc node -s {west,south,north,east}

# Volumen
XF86Audio{Raise,Lower}Volume
	amixer -q set Master 5%{+,-}
    
XF86AudioMute
	amixer -q set Master toggle

# Brillo
XF86MonBrightness{Up,Down}
	xbacklight -{inc,dec} 10

# Capturas
Print
    scrot -e 'mv \$f ~/Pictures/'
EOF

# === POLYBAR ===
log "Configurando Polybar..."
cat > ~/.config/polybar/config.ini << EOF
[colors]
bg = ${BG}
bg-alt = ${BG_ALT}
fg = ${FG}
fg-alt = ${FG_ALT}
accent = ${ACCENT}
accent-alt = ${ACCENT_ALT}
urgent = ${URGENT}

[bar/main]
width = 100%
height = 24pt
radius = 0
background = \${colors.bg}
foreground = \${colors.fg}
line-size = 2
border-bottom-size = 1
border-color = \${colors.accent-alt}
padding = 1
module-margin = 1
separator = |
separator-foreground = \${colors.accent-alt}
font-0 = "Fira Code:size=9;2"
font-1 = "Font Awesome 6 Free:style=Solid:size=9;2"
modules-left = xworkspaces xwindow
modules-center = date
modules-right = memory cpu pulseaudio battery
cursor-click = pointer
enable-ipc = true

[module/xworkspaces]
type = internal/xworkspaces
label-active = %name%
label-active-background = \${colors.bg-alt}
label-active-underline= \${colors.accent}
label-active-padding = 1
label-occupied = %name%
label-occupied-padding = 1
label-urgent = %name%
label-urgent-background = \${colors.urgent}
label-urgent-padding = 1
label-empty = %name%
label-empty-foreground = \${colors.fg-alt}
label-empty-padding = 1

[module/xwindow]
type = internal/xwindow
label = %title:0:60:...%

[module/memory]
type = internal/memory
interval = 2
format-prefix = " "
format-prefix-foreground = \${colors.accent}
label = %percentage_used:2%%

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = " "
format-prefix-foreground = \${colors.accent}
label = %percentage:2%%

[module/date]
type = internal/date
interval = 1
date = %H:%M
date-alt = %Y-%m-%d %H:%M:%S
label = %date%
label-foreground = \${colors.accent}

[module/pulseaudio]
type = internal/pulseaudio
format-volume-prefix = " "
format-volume-prefix-foreground = \${colors.accent}
format-volume = <label-volume>
label-volume = %percentage%%
label-muted = 
label-muted-foreground = \${colors.fg-alt}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 99
format-charging = <label-charging>
format-charging-prefix = " "
format-charging-prefix-foreground = \${colors.accent}
format-discharging = <label-discharging>
format-discharging-prefix = " "
format-discharging-prefix-foreground = \${colors.accent}
format-full-prefix = " "
format-full-prefix-foreground = \${colors.accent}

[settings]
screenchange-reload = true
EOF

# Script de lanzamiento para Polybar
cat > ~/.config/polybar/launch.sh << EOF
#!/bin/bash
killall -q polybar
while pgrep -u \$UID -x polybar >/dev/null; do sleep 1; done
polybar main &
EOF
chmod +x ~/.config/polybar/launch.sh

# === KITTY ===
log "Configurando kitty..."
cat > ~/.config/kitty/kitty.conf << EOF
# Colores
foreground ${FG}
background ${BG}
selection_foreground ${BG}
selection_background ${ACCENT}
cursor ${ACCENT}
cursor_text_color ${BG}

# Colores normales
color0 ${BG}
color1 ${URGENT}
color2 #9ece6a
color3 #e0af68
color4 #7aa2f7
color5 ${ACCENT}
color6 #2ac3de
color7 ${FG}
color8 ${FG_ALT}
color9 #f7768e
color10 #73daca
color11 #ff9e64
color12 #7dcfff
color13 ${ACCENT_ALT}
color14 #89ddff
color15 ${FG}

# Estilo
font_family      Fira Code
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size 10.0
window_padding_width 10
enable_audio_bell no
background_opacity 0.95
cursor_shape beam
EOF

# === ROFI (con íconos) ===
log "Configurando Rofi con íconos..."
cat > ~/.config/rofi/config.rasi << EOF
configuration {
    modi: "drun,run,window";
    icon-theme: "Papirus";
    show-icons: true;
    terminal: "kitty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: " ";
    display-run: " ";
    display-window: " ";
    display-Network: " ";
    sidebar-mode: true;
}

* {
    font: "Fira Code 10";
    bg: ${BG};
    bg-alt: ${BG_ALT};
    fg: ${FG};
    accent: ${ACCENT};
    accent-alt: ${ACCENT_ALT};
    urgent: ${URGENT};
    
    background-color: @bg;
    text-color: @fg;
}

window {
    width: 35%;
    transparency: "real";
    border: 2px;
    border-color: @accent;
    border-radius: 0px;
}

mainbox {
    children: [inputbar, listview];
    padding: 5px;
}

inputbar {
    children: [prompt, entry];
    background-color: @bg-alt;
    border-radius: 5px;
    padding: 2px;
    margin: 0px 0px 10px 0px;
}

prompt {
    background-color: @accent;
    padding: 6px;
    text-color: @bg;
    border-radius: 3px;
    margin: 0px 5px 0px 0px;
}

entry {
    padding: 6px;
    text-color: @fg;
    background-color: inherit;
}

listview {
    border: 0px;
    border-radius: 5px;
    padding: 0px;
    margin: 0px;
    columns: 2;
    lines: 6;
    background-color: transparent;
}

element {
    padding: 5px;
    background-color: transparent;
    border-radius: 5px;
}

element-icon {
    size: 16px;
    padding: 0px 10px 0px 0px;
}

element selected {
    background-color: @bg-alt;
    text-color: @accent;
}

element urgent {
    background-color: @urgent;
    text-color: @fg;
}
EOF

# Crear versión clara para themes alternos
mkdir -p ~/.config/rofi/themes/
cat > ~/.config/rofi/themes/purple-light.rasi << EOF
* {
    bg: #f0f0f0;
    bg-alt: #e0e0e0;
    fg: #2d2b40;
    accent: #6a5acd;
    accent-alt: #8a7aed;
    urgent: #e35374;
}
EOF

cat > ~/.config/rofi/themes/purple-dark.rasi << EOF
* {
    bg: ${BG};
    bg-alt: ${BG_ALT};
    fg: ${FG};
    accent: ${ACCENT};
    accent-alt: ${ACCENT_ALT};
    urgent: ${URGENT};
}
EOF

# Script para cambiar temas
cat > ~/.local/bin/theme-toggle << EOF
#!/bin/bash
CURRENT=\$(readlink -f ~/.config/rofi/theme.rasi 2>/dev/null || echo "none")
DARK=~/.config/rofi/themes/purple-dark.rasi
LIGHT=~/.config/rofi/themes/purple-light.rasi

if [[ "\$CURRENT" == *"light"* ]]; then
    ln -sf \$DARK ~/.config/rofi/theme.rasi
    echo "Cambiado a tema oscuro"
else
    ln -sf \$LIGHT ~/.config/rofi/theme.rasi
    echo "Cambiado a tema claro"
fi
EOF
chmod +x ~/.local/bin/theme-toggle

# Aplicar tema por defecto
ln -sf ~/.config/rofi/themes/purple-dark.rasi ~/.config/rofi/theme.rasi

# === PICOM ===
log "Configurando Picom..."
cat > ~/.config/picom/picom.conf << EOF
# Sombras
shadow = true;
shadow-radius = 10;
shadow-opacity = 0.8;
shadow-offset-x = -10;
shadow-offset-y = -10;
shadow-color = "#000000";

# Opacidad
inactive-opacity = 0.90;
active-opacity = 1.0;
frame-opacity = 1.0;
inactive-opacity-override = false;

# Esquinas redondeadas
corner-radius = 10;
rounded-corners-exclude = [
  "window_type = 'dock'",
  "window_type = 'desktop'"
];

# Fundido
fading = true;
fade-in-step = 0.08;
fade-out-step = 0.08;

# Configuración general
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
use-damage = true;
log-level = "warn";

# Opacidad específica
opacity-rule = [
  "95:class_g = 'kitty'",
  "95:class_g = 'Rofi'"
];
EOF

# === DUNST (Notificaciones) ===
log "Configurando notificaciones..."
cat > ~/.config/dunst/dunstrc << EOF
[global]
    monitor = 0
    follow = mouse
    width = 300
    height = 300
    origin = top-right
    offset = 10x40
    scale = 0
    notification_limit = 0
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    indicate_hidden = yes
    transparency = 10
    separator_height = 1
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    frame_width = 2
    frame_color = "${ACCENT}"
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
    icon_path = /usr/share/icons/Papirus/16x16/status/:/usr/share/icons/Papirus/16x16/devices/
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 5
    ignore_dbusclose = false
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[experimental]
    per_monitor_dpi = false

[urgency_low]
    background = "${BG}"
    foreground = "${FG}"
    timeout = 10

[urgency_normal]
    background = "${BG}"
    foreground = "${FG}"
    timeout = 10

[urgency_critical]
    background = "${BG}"
    foreground = "${URGENT}"
    frame_color = "${URGENT}"
    timeout = 0
EOF

# === Fondos de pantalla ===
log "Configurando fondo de pantalla..."
# Generar wallpaper con gradiente morado oscuro
cat > ~/.local/bin/generate-wallpaper << EOF
#!/bin/bash
convert -size 1920x1080 gradient:'#1a1b26-#24283b' -blur 0x8 ~/Pictures/wallpaper.jpg
EOF
chmod +x ~/.local/bin/generate-wallpaper
~/.local/bin/generate-wallpaper

# Establecer wallpaper
echo '#!/bin/sh' > ~/.fehbg
echo "feh --bg-fill ~/Pictures/wallpaper.jpg" >> ~/.fehbg
chmod +x ~/.fehbg

# === Configuración X11 ===
log "Configurando X11..."
cat > ~/.xinitrc << EOF
#!/bin/sh
# Cargar recursos y configuración
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
~/.fehbg &
setxkbmap -layout es & # Cambiar por tu distribución

# Iniciar WM
exec bspwm
EOF

# Habilitando servicios
log "Habilitando servicios..."
sudo ln -sf /etc/sv/dbus /var/service/ 2>/dev/null
sudo ln -sf /etc/sv/NetworkManager /var/service/ 2>/dev/null

# Instalar fuentes de íconos para Rofi
log "Instalando fuentes..."
# Instalando FontAwesome 6
mkdir -p /tmp/fonts
cd /tmp/fonts
curl -sLO https://use.fontawesome.com/releases/v6.4.0/fontawesome-free-6.4.0-desktop.zip
unzip -q fontawesome-free-6.4.0-desktop.zip
mkdir -p ~/.fonts
cp -r fontawesome-free-6.4.0-desktop/otfs/*.otf ~/.fonts/
fc-cache -fv >/dev/null 2>&1
cd ~
rm -rf /tmp/fonts
ok "Fuentes instaladas"

# Script de cambio de tema
cat > ~/.local/bin/switch-theme << EOF
#!/bin/bash
THEME=\$1
CONFIG_DIR=\$HOME/.config/themes

if [[ "\$THEME" != "dark" && "\$THEME" != "light" ]]; then
    echo "Uso: switch-theme [dark|light]"
    exit 1
fi

# Cambiar tema de Rofi
ln -sf "\$HOME/.config/rofi/themes/purple-\$THEME.rasi" "\$HOME/.config/rofi/theme.rasi"

# Notificar cambio
notify-send "Tema" "Cambiado a modo \$THEME"
EOF
chmod +x ~/.local/bin/switch-theme

# Crear archivo para ejecutar comandos al inicio
cat > ~/.config/bspwm/autostart << EOF
#!/bin/bash
# Archivo para comandos al inicio
EOF
chmod +x ~/.config/bspwm/autostart

echo -e "${C_PRP}=== Instalación completada ===${C_NC}"
echo -e "${C_YLW}Inicio del sistema:${C_NC}"
echo -e "1. Reinicia con ${C_GRN}sudo reboot${C_NC}"
echo -e "2. Inicia sesión, ejecuta ${C_GRN}startx${C_NC}"
echo -e "${C_YLW}Atajos:${C_NC}"
echo -e "${C_GRN}Super + Enter${C_NC}: Terminal"
echo -e "${C_GRN}Super + Space${C_NC}: Menú aplicaciones"
echo -e "${C_GRN}Super + 1-5${C_NC}: Cambiar escritorio"
echo -e "${C_GRN}Super + q${C_NC}: Cerrar ventana"
echo -e "${C_GRN}Super + m${C_NC}: Alternar modo monocle"

# Sugerencia final
echo -e "\n${C_PRP}█ Para cambiar tema:${C_NC} ~/.local/bin/switch-theme [dark|light]"
