#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/lib/config.sh"
source "$SCRIPT_DIR/scripts/lib/utils.sh"
source "$SCRIPT_DIR/scripts/steps/10-deps.sh"
source "$SCRIPT_DIR/scripts/steps/20-install-launcher.sh"
source "$SCRIPT_DIR/scripts/steps/30-flatpak-overrides.sh"
source "$SCRIPT_DIR/scripts/steps/40-gamemode-config.sh"
source "$SCRIPT_DIR/scripts/steps/50-polkit.sh"
source "$SCRIPT_DIR/scripts/steps/60-group.sh"
source "$SCRIPT_DIR/scripts/steps/70-desktop.sh"
source "$SCRIPT_DIR/scripts/steps/80-audit.sh"

require_sudo

echo "--- [ INSTALACIÓN + OPTIMIZACIÓN CPU + ZRAM + MEGASYNC ] ---"

step_deps
step_install_launcher
step_flatpak_overrides
step_gamemode_config
step_polkit
step_group
step_desktop
step_audit
