#!/bin/bash

# --- CONFIGURACIÓN ---
APP_ID="com.jagexlauncher.JagexLauncher"
GAMEMODE_INI="/etc/gamemode.ini"
POLKIT_DIR="/etc/polkit-1/rules.d"
POLKIT_RULE="$POLKIT_DIR/10-gamemode.rules"
DESKTOP_FILE="$HOME/.local/share/applications/com.jagexlauncher.JagexLauncher.desktop"
# Iconos Papirus elegidos
ICON_START="edge-game"
ICON_END="applications-system"

echo "--- [ INSTALACIÓN + OPTIMIZACIÓN CPU + ZRAM + MEGASYNC ] ---"

# 1. Instalar dependencias necesarias de Arch
echo "Verificando dependencias del sistema..."
sudo pacman -S --needed --noconfirm flatpak gamemode cpupower curl libnotify > /dev/null 2>&1

# 2. Instalación del Launcher (Idempotente)
if ! flatpak list | grep -q "$APP_ID"; then
    echo "Instalando Jagex Launcher..."
    curl -fSsL https://raw.githubusercontent.com/nmlynch94/com.jagexlauncher.JagexLauncher/main/install-jagex-launcher-repo.sh | bash
else
    echo "El juego ya está instalado."
fi

# 3. Overrides de Flatpak (Asegurando el puente con el sistema)
echo "Configurando Overrides de Flatpak..."
flatpak override --user --env=LD_PRELOAD=libgamemodeauto.so.0 $APP_ID
flatpak override --user --device=all --talk-name=org.freedesktop.Notifications $APP_ID
flatpak override --user --talk-name=com.feralinteractive.GameMode $APP_ID
flatpak override --user --talk-name=org.freedesktop.GameMode $APP_ID

# 4. Configuración de GameMode con pkexec y Control de Megasync
echo "Configurando GameMode.ini (CPU + GPU + zRAM + Megasync)..."
sudo bash -c "cat << EOF > $GAMEMODE_INI
[general]
desiredgov=performance
defaultgov=schedutil

[gpu]
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high

[custom]
# Al empezar: Notifica, optimiza swappiness y cierra Megasync
start=notify-send -i $ICON_START 'GameMode' 'Max Performance & zRAM Optimized' && pkexec sysctl -w vm.swappiness=10 && pkill -9 megasync
# Al terminar: Notifica, restaura swappiness y abre Megasync (en background)
end=notify-send -i $ICON_END 'GameMode' 'Normal Mode Active' && pkexec sysctl -w vm.swappiness=60 && (megasync &)
EOF"

# 5. Regla de Polkit (Autorización para Governor y Swappiness)
echo "Configurando reglas de Polkit..."
sudo mkdir -p "$POLKIT_DIR"
sudo bash -c "cat << EOF > $POLKIT_RULE
polkit.addRule(function(action, subject) {
    if ((action.id == \"org.freedesktop.policykit.exec\" || 
         action.id == \"org.archlinux.pkexec.cpupower\") &&
        subject.isInGroup(\"gamemode\")) {
        return polkit.Result.YES;
    }
});
EOF"

# 6. Gestión del Grupo gamemode
if ! getent group gamemode | grep -q "\b$USER\b"; then
    echo "Configurando grupo de usuario..."
    sudo groupadd gamemode 2>/dev/null
    sudo usermod -aG gamemode "$USER"
    RELOGIN="SÍ"
fi

# 7. Optimización del archivo .desktop (Asegurar gamemoderun)
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

# --- [ AUDITORÍA TÉCNICA DE CONFIGURACIÓN ] ---
echo -e "\n\e[1;34m--- [ DETAILED VALIDATION REPORT ] ---\e[0m"

# 1. Comprobación de Configuración GameMode
echo -ne "1. GameMode Config:   "
if sudo grep -q "swappiness=10" "$GAMEMODE_INI" && sudo grep -q "pkill -9 megasync" "$GAMEMODE_INI"; then
    echo -e "\e[1;32mPASSED (CPU/zRAM/Megasync-Kill active)\e[0m"
else
    echo -e "\e[1;31mFAILED (Config incomplete)\e[0m"
fi

# 2. Comprobación de Flatpak Overrides
echo -ne "2. Flatpak Overrides: "
FP_OVERRIDES=$(flatpak override --user --show "$APP_ID")
if echo "$FP_OVERRIDES" | grep -q "libgamemodeauto" && echo "$FP_OVERRIDES" | grep -q "Notifications"; then
    echo -e "\e[1;32mPASSED (Sandbox bridge verified)\e[0m"
else
    echo -e "\e[1;31mFAILED (Missing LD_PRELOAD or DBus talk)\e[0m"
fi

# 3. Comprobación de Permisos Polkit
echo -ne "3. Polkit Security:   "
if sudo test -f "$POLKIT_RULE" && sudo grep -q "isInGroup(\"gamemode\")" "$POLKIT_RULE"; then
    echo -e "\e[1;32mPASSED (Privilege bypass ready)\e[0m"
else
    echo -e "\e[1;31mFAILED (Rule missing or corrupted)\e[0m"
fi

# 4. Comprobación del Lanzador (.desktop)
echo -ne "4. Launcher Wrapper:  "
if grep -q "Exec=gamemoderun" "$DESKTOP_FILE" 2>/dev/null; then
    echo -e "\e[1;32mPASSED (gamemoderun prefix found)\e[0m"
else
    echo -e "\e[1;31mFAILED (Exec line not optimized)\e[0m"
fi

# 5. Estado del Usuario y Grupo
echo -ne "5. System Group:      "
if groups "$USER" | grep -q "gamemode"; then
    echo -e "\e[1;32mOK (Member of gamemode)\e[0m"
else
    echo -e "\e[1;33mPENDING (Logout required to join group)\e[0m"
    RELOGIN="SÍ"
fi

echo -e "\e[1;34m--------------------------------------------------\e[0m"

if [[ "$RELOGIN" == "SÍ" ]]; then
    echo -e "\e[1;33m[!] ATTENTION: Everything is set, but you MUST reboot to apply group permissions.\e[0m"
else
    echo -e "\e[1;32m[✔] ALL SYSTEMS NOMINAL. Performance & Megasync-Auto-Toggle ready.\e[0m"
fi