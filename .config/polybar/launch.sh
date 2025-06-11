#!/bin/bash

# Terminar instancias previas
pkill polybar

# Esperar a que termine
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Iniciar la barra
polybar bspwm &
