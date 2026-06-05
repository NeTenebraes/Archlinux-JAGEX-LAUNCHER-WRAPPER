step_group() {
    if ! getent group gamemode | grep -q "\b$USER\b"; then
        echo "Configurando grupo de usuario..."
        sudo groupadd gamemode 2>/dev/null
        sudo usermod -aG gamemode "$USER"
        RELOGIN="SÍ"
    fi
}
