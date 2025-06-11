#!/bin/bash

if bluetoothctl show | grep -q "Powered: yes"; then
    if bluetoothctl info | grep -q "Connected: yes"; then
        echo " Conectado"
    else
        echo " Encendido"
    fi
else
    echo " Apagado"
fi
