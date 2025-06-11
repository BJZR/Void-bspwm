#!/bin/bash
set -e

echo "[+] Buscando scripts .sh para hacerlos ejecutables..."

# Buscar todos los archivos .sh y dar permisos de ejecución
find . -type f -name "*.sh" | while read -r script; do
    chmod +x "$script"
    echo "[✓] Permiso de ejecución añadido: $script"
done

echo "[✓] Todos los scripts ahora tienen permisos de ejecución."
