step_audit() {
    echo -e "\n\e[1;34m--- [ DETAILED VALIDATION REPORT ] ---\e[0m"

    echo -ne "1. GameMode Config:   "
    if sudo grep -q "^start=/usr/local/bin/gamemode-start.sh" "$GAMEMODE_INI" \
        && sudo grep -q "^end=/usr/local/bin/gamemode-end.sh" "$GAMEMODE_INI" \
        && sudo test -x /usr/local/bin/gamemode-start.sh \
        && sudo test -x /usr/local/bin/gamemode-end.sh; then
        echo -e "\e[1;32mPASSED (Hooks active)\e[0m"
    else
        echo -e "\e[1;31mFAILED (Hooks missing or not executable)\e[0m"
    fi

    echo -ne "2. Flatpak Overrides: "
    FP_OVERRIDES=$(flatpak override --user --show "$APP_ID")
    if echo "$FP_OVERRIDES" | grep -q "libgamemodeauto" && echo "$FP_OVERRIDES" | grep -q "Notifications"; then
        echo -e "\e[1;32mPASSED (Sandbox bridge verified)\e[0m"
    else
        echo -e "\e[1;31mFAILED (Missing LD_PRELOAD or DBus talk)\e[0m"
    fi

    echo -ne "3. Polkit Security:   "
    if sudo test -f "$POLKIT_RULE" && sudo grep -q "isInGroup(\"gamemode\")" "$POLKIT_RULE"; then
        echo -e "\e[1;32mPASSED (Privilege bypass ready)\e[0m"
    else
        echo -e "\e[1;31mFAILED (Rule missing or corrupted)\e[0m"
    fi

    echo -ne "4. Launcher Wrapper:  "
    if grep -q "Exec=gamemoderun" "$DESKTOP_FILE" 2>/dev/null; then
        echo -e "\e[1;32mPASSED (gamemoderun prefix found)\e[0m"
    else
        echo -e "\e[1;31mFAILED (Exec line not optimized)\e[0m"
    fi

    echo -ne "5. System Group:      "
    if groups "$USER" | grep -q "gamemode"; then
        echo -e "\e[1;32mOK (Member of gamemode)\e[0m"
    else
        echo -e "\e[1;33mPENDING (Logout required to join group)\e[0m"
        RELOGIN="SÍ"
    fi

    echo -e "\e[1;34m--------------------------------------------------\e[0m"

    if [[ "${RELOGIN:-NO}" == "SÍ" ]]; then
        echo -e "\e[1;33m[!] ATTENTION: Everything is set, but you MUST reboot to apply group permissions.\e[0m"
    else
        echo -e "\e[1;32m[✔] ALL SYSTEMS NOMINAL. Performance & Megasync-Auto-Toggle ready.\e[0m"
    fi
}
