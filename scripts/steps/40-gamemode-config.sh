step_gamemode_config() {
    echo "Configurando GameMode.ini (CPU + GPU + zRAM + Megasync)..."
    local start_hook
    local end_hook
    start_hook="/usr/local/bin/gamemode-start.sh"
    end_hook="/usr/local/bin/gamemode-end.sh"
    local tmp_file
    tmp_file="$(mktemp)"
    cat << 'EOF' > "$tmp_file"
[general]
desiredgov=performance
defaultgov=schedutil

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high

[custom]
# Al empezar: Notifica, guarda swappiness actual, optimiza y cierra Megasync
start=/usr/local/bin/gamemode-start.sh
# Al terminar: Notifica, restaura swappiness guardado y abre Megasync (en background)
end=/usr/local/bin/gamemode-end.sh
EOF
    sudo install -m 644 "$tmp_file" "$GAMEMODE_INI"
    rm -f "$tmp_file"

    local start_tmp
    local end_tmp
    start_tmp="$(mktemp)"
    end_tmp="$(mktemp)"
    cp "$SCRIPT_DIR/scripts/hooks/gamemode-start.sh" "$start_tmp"
    cp "$SCRIPT_DIR/scripts/hooks/gamemode-end.sh" "$end_tmp"
    sed -i "s/__ICON_START__/$ICON_START/g" "$start_tmp"
    sed -i "s/__ICON_END__/$ICON_END/g" "$end_tmp"
    sudo install -m 755 "$start_tmp" "$start_hook"
    sudo install -m 755 "$end_tmp" "$end_hook"
    rm -f "$start_tmp" "$end_tmp"
}
