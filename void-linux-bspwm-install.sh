#!/bin/bash
RED='\033[0;31m';GREEN='\033[0;32m';YELLOW='\033[0;33m';BLUE='\033[0;34m';NC='\033[0m'

echo -e "${BLUE}=== BSPWM Void Linux Installer ===${NC}"

install_pkg(){
  echo -e "${YELLOW}Installing $1...${NC}"
  sudo xbps-install -Sy "$1" >/dev/null 2>&1 && echo -e "${GREEN}✓ $1${NC}" || echo -e "${RED}✗ $1${NC}"
}

# Base setup
sudo xbps-install -Suy xbps >/dev/null 2>&1
sudo xbps-install -Suy >/dev/null 2>&1

# Security hardening
sudo xbps-install -Sy apparmor polkit acl gnupg2 ufw >/dev/null 2>&1
sudo ln -sf /etc/sv/ufw /var/service/
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Base packages
BASE="base-devel git curl wget xorg-minimal xorg-fonts xinit libX11-devel libXft-devel libXinerama-devel"
sudo xbps-install -Sy $BASE >/dev/null 2>&1

# Core packages - Added kitty, bluetooth, i3lock-color, polybar-scripts
PKGS=(
  "bspwm" "sxhkd" "polybar" "alacritty" "kitty" "rofi" "picom" "papirus-icon-theme"
  "feh" "lightdm" "lightdm-gtk-greeter" "tlp" "acpi" "xtools" "dunst"
  "lxappearance" "ranger" "neofetch" "htop" "NetworkManager" "network-manager-applet"
  "pulseaudio" "pavucontrol" "alsa-utils" "xbacklight" "nitrogen" "scrot"
  "qutebrowser" "gtk+3" "dbus" "xdg-utils" "unzip" "wal" "pywal" "wal-autostart"
  "bluez" "blueman" "i3lock-color" "polybar-scripts" "maim" "xclip" 
  "eww" "playerctl" "brightnessctl" "pamixer" "jq" "i3lock-fancy" "inotify-tools"
)

echo -e "${BLUE}Installing packages...${NC}"
for pkg in "${PKGS[@]}"; do install_pkg "$pkg"; done

# Fonts - only FiraCode, Font Awesome, and Noto Sans
echo -e "${BLUE}Installing fonts...${NC}"
sudo xbps-install -Sy font-firacode font-awesome5 noto-fonts-ttf >/dev/null 2>&1

# Create directories
mkdir -p ~/.config/{bspwm,sxhkd,polybar,alacritty,kitty,rofi,picom,wal/templates,gtk-3.0,eww}
mkdir -p ~/Pictures/{wallpaper,screenshots}
mkdir -p ~/.themes
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/scripts

# Create wallpaper directory and placeholder files
cat > ~/.config/set-theme.sh << 'EOF'
#!/bin/bash
THEME=$1
[ -z "$THEME" ] && THEME="default"
THEME_DIR="$HOME/.config/themes/$THEME"

if [ ! -d "$THEME_DIR" ]; then
    echo "Theme not found: $THEME"
    exit 1
fi

# Apply wallpaper
if [ -f "$THEME_DIR/wallpaper.jpg" ]; then
    nitrogen --set-zoom-fill "$THEME_DIR/wallpaper.jpg" --save
fi

# Apply pywal colors
if [ -f "$THEME_DIR/colors.json" ]; then
    wal --theme "$THEME_DIR/colors.json" -n
else
    wal -i "$THEME_DIR/wallpaper.jpg" -n
fi

# Reload polybar
$HOME/.config/polybar/launch.sh

# Notify
notify-send "Theme Changed" "Applied theme: $THEME"
EOF
chmod +x ~/.config/set-theme.sh

# Create default theme structure
mkdir -p ~/.config/themes/{default,dark,light}
for theme in default dark light; do
    touch ~/.config/themes/$theme/wallpaper.jpg
done

# Create lock screen script
cat > ~/.local/bin/lockscreen << 'EOF'
#!/bin/bash
# Take a screenshot of the current screen
TMPBG="/tmp/screen.png"
LOCK_ICON="$HOME/.config/lock-icon.png"

# Create lock icon if it doesn't exist
if [ ! -f "$LOCK_ICON" ]; then
    convert -size 100x100 xc:none -fill white -draw "circle 50,50 50,20" "$LOCK_ICON"
fi

# Take screenshot and blur it
maim "$TMPBG"
convert "$TMPBG" -scale 10% -blur 0x2 -resize 1000% "$TMPBG"
convert "$TMPBG" "$LOCK_ICON" -gravity center -composite "$TMPBG"

# Use i3lock to lock the screen with the blurred screenshot
i3lock -i "$TMPBG" -e -f -n
EOF
chmod +x ~/.local/bin/lockscreen

# BSPWM config
cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/sh
# Autostart
sxhkd &
picom &
~/.config/polybar/launch.sh &
nitrogen --restore &
nm-applet &
blueman-applet &
dunst &
wal -R &

# BSPWM config
bspc monitor -d I II III IV V VI VII VIII IX X
bspc config border_width         2
bspc config window_gap          10
bspc config top_padding         30
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true
bspc config focus_follows_pointer true

# Load theme colors from pywal
. "${HOME}/.cache/wal/colors.sh"
bspc config normal_border_color "$color1"
bspc config active_border_color "$color2"
bspc config focused_border_color "$color15"
bspc config presel_feedback_color "$color2"

# Window rules
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a qutebrowser desktop='^2'
bspc rule -a Alacritty desktop='^1'
bspc rule -a kitty desktop='^1'
bspc rule -a Blueman-manager state=floating
bspc rule -a Pavucontrol state=floating
EOF
chmod +x ~/.config/bspwm/bspwmrc

# SXHKD config - Added more shortcuts and terminals
cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
# Terminal - Alacritty
super + Return
	alacritty

# Terminal - Kitty (alternative)
super + shift + Return
	kitty

# Rofi launcher
super + @space
	rofi -show drun

# Theme switcher
super + alt + t
	~/.local/bin/theme-switcher

# Quick power menu
super + shift + p
    ~/.local/bin/powermenu

# Lock screen
super + l
    ~/.local/bin/lockscreen

# Bluetooth manager
super + shift + b
    blueman-manager

# WiFi manager
super + shift + w
    nm-connection-editor

# Volume control widget
super + shift + v
    pavucontrol

# Screenshot to clipboard
super + Print
    maim -s | xclip -selection clipboard -t image/png

# Full screenshot
Print
    maim ~/Pictures/screenshots/$(date +%s).png

# Reload sxhkd
super + Escape
	pkill -USR1 -x sxhkd

# Quit/restart bspwm
super + alt + {q,r}
	bspc {quit,wm -r}

# Close/kill node
super + {_,shift + }q
	bspc node -{c,k}

# Toggle monocle layout
super + m
	bspc desktop -l next

# Send node to desktop
super + shift + {1-9,0}
	bspc node -d '^{1-9,10}'

# Focus desktop
super + {1-9,0}
	bspc desktop -f '^{1-9,10}'

# Move focus
super + {h,j,k,l}
	bspc node -f {west,south,north,east}

# Move node
super + shift + {h,j,k,l}
	bspc node -s {west,south,north,east}

# Volume control
XF86AudioRaiseVolume
	pamixer -i 5
    
XF86AudioLowerVolume
	pamixer -d 5
    
XF86AudioMute
	pamixer -t

# Brightness control
XF86MonBrightnessUp
	brightnessctl set +10%
    
XF86MonBrightnessDown
	brightnessctl set 10%-

# Media player controls
XF86AudioPlay
    playerctl play-pause

XF86AudioNext
    playerctl next

XF86AudioPrev
    playerctl previous
EOF

# Create power menu script
cat > ~/.local/bin/powermenu << 'EOF'
#!/bin/bash
MENU="$(rofi -sep "|" -dmenu -i -p 'System' -width 12 -hide-scrollbar -line-padding 4 -padding 10 -lines 5 <<< "Lock|Logout|Suspend|Reboot|Shutdown")"

case "$MENU" in
    *Lock) ~/.local/bin/lockscreen ;;
    *Logout) bspc quit ;;
    *Suspend) systemctl suspend ;;
    *Reboot) sudo reboot ;;
    *Shutdown) sudo poweroff ;;
esac
EOF
chmod +x ~/.local/bin/powermenu

# Theme switcher script
cat > ~/.local/bin/theme-switcher << 'EOF'
#!/bin/bash
THEMES_DIR="$HOME/.config/themes"
THEMES=$(ls -1 "$THEMES_DIR")
THEME=$(echo "$THEMES" | rofi -dmenu -p "Select Theme" -i)
[ -n "$THEME" ] && ~/.config/set-theme.sh "$THEME"
EOF
chmod +x ~/.local/bin/theme-switcher

# System info script for widgets
cat > ~/.local/bin/system-info << 'EOF'
#!/bin/bash
function get_cpu {
    grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
}

function get_memory {
    free | grep Mem | awk '{print $3/$2 * 100.0}'
}

function get_battery {
    acpi -b | grep -P -o '[0-9]+(?=%)'
}

function get_volume {
    pamixer --get-volume
}

function get_wifi {
    WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d\: -f2)
    if [ -z "$WIFI" ]; then
        echo "Disconnected"
    else
        echo "$WIFI"
    fi
}

function get_bluetooth {
    if bluetoothctl show | grep "Powered: yes" > /dev/null; then
        echo "On"
    else
        echo "Off"
    fi
}

case "$1" in
    cpu) get_cpu ;;
    memory) get_memory ;;
    battery) get_battery ;;
    volume) get_volume ;;
    wifi) get_wifi ;;
    bluetooth) get_bluetooth ;;
    *) echo "Usage: $0 {cpu|memory|battery|volume|wifi|bluetooth}" ;;
esac
EOF
chmod +x ~/.local/bin/system-info

# Polybar config with pywal integration and more modules
cat > ~/.config/polybar/config.ini << 'EOF'
[colors]
include-file = ~/.cache/wal/colors-polybar.ini

[bar/main]
width = 100%
height = 24pt
radius = 0
fixed-center = true

background = ${colors.background}
foreground = ${colors.foreground}

line-size = 3pt
border-size = 0pt
padding-left = 0
padding-right = 1
module-margin = 1

separator = |
separator-foreground = ${colors.color8}

font-0 = "Fira Code:size=10;2"
font-1 = "Font Awesome 5 Free:style=Solid:size=10;2"
font-2 = "Font Awesome 5 Free:style=Regular:size=10;2"
font-3 = "Font Awesome 5 Brands:style=Regular:size=10;2"
font-4 = "Noto Sans:size=10;2"

modules-left = xworkspaces xwindow
modules-center = date
modules-right = filesystem pulseaudio bluetooth backlight memory cpu battery wlan eth powermenu

cursor-click = pointer
cursor-scroll = ns-resize
enable-ipc = true

[module/xworkspaces]
type = internal/xworkspaces
label-active = %name%
label-active-background = ${colors.color8}
label-active-underline= ${colors.color4}
label-active-padding = 1
label-occupied = %name%
label-occupied-padding = 1
label-urgent = %name%
label-urgent-background = ${colors.color1}
label-urgent-padding = 1
label-empty = %name%
label-empty-foreground = ${colors.color7}
label-empty-padding = 1

[module/xwindow]
type = internal/xwindow
label = %title:0:60:...%

[module/filesystem]
type = internal/fs
interval = 25
mount-0 = /
label-mounted = %{F#F0C674}%mountpoint%%{F-} %percentage_used%%
label-unmounted = %mountpoint% not mounted
label-unmounted-foreground = ${colors.color8}

[module/pulseaudio]
type = internal/pulseaudio
format-volume-prefix = "VOL "
format-volume-prefix-foreground = ${colors.primary}
format-volume = <label-volume>
label-volume = %percentage%%
label-muted = muted
label-muted-foreground = ${colors.color8}
click-right = pavucontrol

[module/bluetooth]
type = custom/script
exec = ~/.local/bin/system-info bluetooth
interval = 5
format-prefix = "BT "
format-prefix-foreground = ${colors.primary}
click-left = blueman-manager
click-right = bluetoothctl power toggle

[module/backlight]
type = internal/backlight
card = intel_backlight
format-prefix = "BL "
format-prefix-foreground = ${colors.primary}
use-actual-brightness = true
enable-scroll = true

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
label-foreground = ${colors.color4}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 99
format-charging = <label-charging>
format-charging-prefix = "CHR "
format-charging-prefix-foreground = ${colors.color2}
format-discharging = <label-discharging>
format-discharging-prefix = "BAT "
format-discharging-prefix-foreground = ${colors.color3}
format-full-prefix = "FULL "
format-full-prefix-foreground = ${colors.color2}

[module/wlan]
type = internal/network
interface-type = wireless
interval = 3.0
format-connected = <label-connected>
format-connected-prefix = "WiFi "
format-connected-prefix-foreground = ${colors.color2}
label-connected = %essid%
format-disconnected = <label-disconnected>
label-disconnected = disconnected
label-disconnected-foreground = ${colors.color8}
click-left = nm-connection-editor

[module/eth]
type = internal/network
interface-type = wired
interval = 3.0
format-connected-prefix = "LAN "
format-connected-prefix-foreground = ${colors.color2}
label-connected = %local_ip%
format-disconnected = <label-disconnected>
label-disconnected = disconnected
label-disconnected-foreground = ${colors.color8}

[module/powermenu]
type = custom/text
content = 
content-foreground = ${colors.color1}
click-left = ~/.local/bin/powermenu

[settings]
screenchange-reload = true
pseudo-transparency = true
EOF

# Polybar launcher with pywal
cat > ~/.config/polybar/launch.sh << 'EOF'
#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar main &
EOF
chmod +x ~/.config/polybar/launch.sh

# Pywal template for polybar
mkdir -p ~/.config/wal/templates
cat > ~/.config/wal/templates/colors-polybar.ini << 'EOF'
background = ${color0}
background-alt = ${color8}
foreground = ${color7}
foreground-alt = ${color15}
primary = ${color4}
secondary = ${color5}
alert = ${color1}
disabled = ${color8}
color1 = ${color1}
color2 = ${color2}
color3 = ${color3}
color4 = ${color4}
color5 = ${color5}
color6 = ${color6}
color7 = ${color7}
color8 = ${color8}
EOF

# Alacritty config with pywal integration
cat > ~/.config/alacritty/alacritty.yml << 'EOF'
import:
  - ~/.cache/wal/colors-alacritty.yml

font:
  normal:
    family: Fira Code
    style: Regular
  bold:
    family: Fira Code
    style: Bold
  italic:
    family: Fira Code
    style: Italic
  bold_italic:
    family: Fira Code
    style: Bold Italic
  size: 11.0

window:
  padding:
    x: 5
    y: 5

cursor:
  style:
    shape: Block
    blinking: On

live_config_reload: true
EOF

# Kitty config with pywal integration
cat > ~/.config/kitty/kitty.conf << 'EOF'
include ~/.cache/wal/colors-kitty.conf

font_family      Fira Code
bold_font        Fira Code Bold
italic_font      Fira Code Italic
bold_italic_font Fira Code Bold Italic
font_size 11.0

window_padding_width 5
enable_audio_bell no
background_opacity 0.95
confirm_os_window_close 0

# Keyboard shortcuts
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+n new_os_window
EOF

# Rofi config with icons
cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    modi: "window,run,drun";
    font: "Fira Code 12";
    show-icons: true;
    icon-theme: "Papirus";
    terminal: "alacritty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "  Apps ";
    display-run: "  Run ";
    display-window: "  Window";
    display-Network: "  Network";
    sidebar-mode: true;
}

@theme "~/.cache/wal/colors-rofi-dark.rasi"

element-icon {
    size: 1.5em;
}
EOF

# Picom config
cat > ~/.config/picom/picom.conf << 'EOF'
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
shadow-opacity = 0.60;
inactive-opacity = 0.90;
active-opacity = 1;
frame-opacity = 0.90;
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
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
detect-transient = true;
detect-client-leader = true;
use-damage = true;
log-level = "warn";
opacity-rule = [
  "90:class_g = 'Alacritty'",
  "90:class_g = 'Rofi'"
];
EOF

# LightDM config
sudo mkdir -p /etc/lightdm
sudo cat > /etc/lightdm/lightdm-gtk-greeter.conf << 'EOF'
[greeter]
theme-name = Adwaita-dark
icon-theme-name = Papirus-Dark
font-name = Fira Code 11
background = /usr/share/backgrounds/wallpaper2.jpg
clock-format = %H:%M:%S
indicators = ~host;~spacer;~clock;~spacer;~session;~power
EOF

# Create GTK theme config for theme switching
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Noto Sans 11
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
EOF

# Basic eww widget configs
mkdir -p ~/.config/eww/{eww.scss,eww.yuck}
cat > ~/.config/eww/eww.yuck << 'EOF'
(defwindow system-info
  :monitor 0
  :geometry (geometry :x "0%"
                     :y "0%"
                     :width "280px"
                     :height "180px"
                     :anchor "top right")
  :stacking "fg"
  :reserve (struts :distance "40px" :side "top")
  :windowtype "dock"
  :wm-ignore false
  (box :class "system-info-box" :orientation "v" :spacing 10
    (label :text "System Info" :class "title")
    (box :orientation "h" :spacing 5
      (label :text "CPU: ")
      (label :text "${cpu}%"))
    (box :orientation "h" :spacing 5
      (label :text "RAM: ")
      (label :text "${memory}%"))
    (box :orientation "h" :spacing 5
      (label :text "Battery: ")
      (label :text "${battery}%"))
    (box :orientation "h" :spacing 5
      (label :text "Volume: ")
      (label :text "${volume}%"))
    (box :orientation "h" :spacing 5
      (label :text "WiFi: ")
      (label :text wifi))
    (box :orientation "h" :spacing 5
      (label :text "Bluetooth: ")
      (label :text bluetooth))
  )
)

(defpoll cpu :interval "2s"
  "~/.local/bin/system-info cpu")

(defpoll memory :interval "2s"
  "~/.local/bin/system-info memory")

(defpoll battery :interval "5s"
  "~/.local/bin/system-info battery")

(defpoll volume :interval "1s"
  "~/.local/bin/system-info volume")

(defpoll wifi :interval "5s"
  "~/.local/bin/system-info wifi")

(defpoll bluetooth :interval "5s"
  "~/.local/bin/system-info bluetooth")
EOF

cat > ~/.config/eww/eww.scss << 'EOF'
* {
  font-family: "Fira Code", monospace;
  font-size: 12px;
}

.system-info-box {
  background-color: #1e1e2e;
  border-radius: 10px;
  padding: 10px;
  border: 1px solid #313244;
}

.title {
  font-size: 14px;
  font-weight: bold;
  color: #cdd6f4;
  margin-bottom: 10px;
}
EOF

# Setup wallpapers
sudo mkdir -p /usr/share/backgrounds
cd ~/Pictures/wallpaper
touch wallpaper.jpg wallpaper1.jpg wallpaper2.jpg
sudo cp wallpaper2.jpg /usr/share/backgrounds/

# Configure wallpaper and themes
cat > ~/.fehbg << 'EOF'
#!/bin/sh
feh --bg-fill "$HOME/Pictures/wallpaper/wallpaper.jpg"
EOF
chmod +x ~/.fehbg

# X config
cat > ~/.xinitrc << 'EOF'
#!/bin/sh
[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources
xsetroot -cursor_name left_ptr &
~/.fehbg &
setxkbmap -layout us &
wal -R &
# Start Bluetooth
bluetoothctl power on &
exec bspwm
EOF
chmod +x ~/.xinitrc

# Enable all necessary services
for svc in lightdm tlp dbus NetworkManager apparmor bluez; do
    sudo ln -sf /etc/sv/$svc /var/service/ 2>/dev/null
done

# Verify critical packages
for pkg in xorg-minimal bspwm sxhkd lightdm bluez i3lock-color; do
    if ! xbps-query -l | grep -q "^ii $pkg"; then
        sudo xbps-install -Sy $pkg >/dev/null 2>&1
    fi
done

echo -e "${GREEN}Installation completed!${NC}"
echo -e "${BLUE}To start your new environment:${NC}"
echo -e "1. ${GREEN}sudo reboot${NC}"
echo -e "2. Login via LightDM"
echo -e "3. Press ${GREEN}Super+Alt+T${NC} to switch themes"
echo -e "${BLUE}Main shortcuts:${NC}"
echo -e "${GREEN}Super+Return${NC}: Alacritty ${GREEN}Super+Shift+Return${NC}: Kitty"
echo -e "${GREEN}Super+Space${NC}: App menu ${GREEN}Super+L${NC}: Lock screen"
echo -e "${GREEN}Super+Shift+B${NC}: Bluetooth ${GREEN}Super+Shift+W${NC}: WiFi"
echo -e "${GREEN}Super+Print${NC}: Area screenshot ${GREEN}Print${NC}: Full screenshot"
echo -e "${GREEN}Super+Shift+P${NC}: Power menu"
