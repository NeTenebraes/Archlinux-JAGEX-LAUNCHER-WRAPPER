step_install_launcher() {
    if ! flatpak list | grep -q "$APP_ID"; then
        echo "Instalando Jagex Launcher..."
        curl -fSsL https://raw.githubusercontent.com/nmlynch94/com.jagexlauncher.JagexLauncher/main/install-jagex-launcher-repo.sh | bash
    else
        echo "El juego ya está instalado."
    fi
}
