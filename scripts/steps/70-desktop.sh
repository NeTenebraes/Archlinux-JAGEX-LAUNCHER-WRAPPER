step_desktop() {
    if [ -f "$DESKTOP_FILE" ]; then
        echo "Optimizando acceso directo (.desktop)..."
        if ! grep -q "gamemoderun" "$DESKTOP_FILE"; then
            sed -i 's/^Exec=/Exec=gamemoderun /' "$DESKTOP_FILE"
            echo "Prefijo 'gamemoderun' añadido al .desktop."
        else
            echo "El .desktop ya estaba optimizado."
        fi
    else
        echo "Aviso: No se encontró el archivo .desktop en la ruta local."
    fi
}
