#!/bin/bash

# Cierra cualquier instancia previa de Polybar
killall -q polybar

# Espera a que se cierren
while pgrep -x polybar >/dev/null; do sleep 1; done

# Inicia Polybar con el nombre de la barra configurada en config.ini (por ejemplo: mybar)
polybar &
