step_polkit() {
    echo "Configurando reglas de Polkit..."
    sudo mkdir -p "$POLKIT_DIR"
    local tmp_rule
    tmp_rule="$(mktemp)"
    cat << 'POLKIT_EOF' > "$tmp_rule"
polkit.addRule(function(action, subject) {
    if (!subject.isInGroup("gamemode")) {
        return;
    }

    if (action.id == "org.freedesktop.policykit.exec") {
        var cmd = action.lookup("command");
        if (!cmd) {
            cmd = action.lookup("program");
        }
        if (!cmd) {
            cmd = action.lookup("path");
        }
        var argv = action.lookup("argv");
        var commandLine = action.lookup("command_line");

        if (cmd == "/usr/bin/sysctl") {
            if (!argv) {
                if (commandLine && /^\/usr\/bin\/sysctl\s+-w\s+vm\.swappiness=[0-9]+$/.test(commandLine)) {
                    return polkit.Result.YES;
                }
                return;
            }

            if (argv.length == 3) {
                if (argv[0] != "/usr/bin/sysctl" && argv[0] != "sysctl") {
                    return;
                }
                if (argv[1] != "-w") {
                    return;
                }
                if (!/^vm\.swappiness=[0-9]+$/.test(argv[2])) {
                    return;
                }
                return polkit.Result.YES;
            }

            if (argv.length == 2) {
                if (argv[0] != "-w") {
                    return;
                }
                if (!/^vm\.swappiness=[0-9]+$/.test(argv[1])) {
                    return;
                }
                return polkit.Result.YES;
            }

            return;
        }

        if (cmd == "/usr/lib/gamemode/cpugovctl") {
            return polkit.Result.YES;
        }

        if (cmd == "/usr/lib/gamemode/procsysctl") {
            return polkit.Result.YES;
        }
    }
});
POLKIT_EOF
    sudo install -m 644 "$tmp_rule" "$POLKIT_RULE"
    rm -f "$tmp_rule"
    sudo systemctl restart polkit
    echo "Polkit recargado."
}
