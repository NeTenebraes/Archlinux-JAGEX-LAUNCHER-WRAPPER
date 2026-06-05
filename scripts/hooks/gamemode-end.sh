#!/bin/bash
set -euo pipefail

notify-send -i __ICON_END__ 'GameMode' 'Normal Mode Active'

SWAP_FILE="/run/user/$(id -u)/gamemode_swappiness"
if [ -f "$SWAP_FILE" ]; then
    ORIG_SWAPPINESS=$(cat "$SWAP_FILE")
    if [[ "$ORIG_SWAPPINESS" =~ ^[0-9]+$ ]]; then
        pkexec /usr/bin/sysctl -w vm.swappiness="$ORIG_SWAPPINESS"
    fi
    rm -f "$SWAP_FILE"
else
    pkexec /usr/bin/sysctl -w vm.swappiness=60
fi

(megasync &)
