#!/bin/bash
set -euo pipefail

notify-send -i __ICON_START__ 'GameMode' 'Max Performance & zRAM Optimized'

SWAP_FILE="/run/user/$(id -u)/gamemode_swappiness"
ORIG_SWAPPINESS=$(sysctl -n vm.swappiness)
printf '%s' "$ORIG_SWAPPINESS" > "$SWAP_FILE"

pkexec /usr/bin/sysctl -w vm.swappiness=10

if command -v pkill >/dev/null 2>&1; then
    pkill -x -9 megasync || true
fi
