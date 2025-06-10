#!/bin/bash
set -e  # Detener si ocurre un error

# Función para ejecutar scripts con verificación
run_script() {
    local name="$1"
    local path="./$name"

    echo "[+] Ejecutando $name..."

    if [ -x "$path" ]; then
        "$path"
        echo "[✓] $name ejecutado correctamente."
    elif [ -f "$path" ]; then
        echo "[✗] $name existe pero no es ejecutable. Otorgando permisos..."
        chmod +x "$path"
        "$path"
        echo "[✓] $name ejecutado correctamente tras conceder permisos."
    else
        echo "[✗] $name no encontrado. Asegúrate de que esté en el mismo directorio."
        exit 1
    fi
    echo
}

echo "===== Instalador de entorno Void Linux personalizado ====="
echo

run_script "base.sh"
run_script "config.sh"
run_script "FiraCode.sh"
run_script "dracula.sh"
#run_script "wallpaper.sh"

echo "===== ✅ Instalación completa sin errores. Reinicia tu equipo para aplicar los cambios. ====="
