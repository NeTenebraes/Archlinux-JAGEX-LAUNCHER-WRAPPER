step_flatpak_overrides() {
    echo "Configurando Overrides de Flatpak..."
    flatpak override --user --env=LD_PRELOAD=libgamemodeauto.so.0 "$APP_ID"
    flatpak override --user --device=all --talk-name=org.freedesktop.Notifications "$APP_ID"
    flatpak override --user --talk-name=com.feralinteractive.GameMode "$APP_ID"
    flatpak override --user --talk-name=org.freedesktop.GameMode "$APP_ID"
}
