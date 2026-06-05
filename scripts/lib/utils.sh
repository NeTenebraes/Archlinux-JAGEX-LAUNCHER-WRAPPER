require_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        return 0
    fi
    sudo -k
    if ! sudo -v; then
        echo "Error: se requieren permisos sudo para continuar." >&2
        exit 1
    fi
}
