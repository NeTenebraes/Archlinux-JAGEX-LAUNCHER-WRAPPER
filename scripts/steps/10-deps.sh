step_deps() {
    echo "Verificando dependencias del sistema..."
    sudo pacman -S --needed --noconfirm flatpak gamemode cpupower curl libnotify > /dev/null 2>&1
}
