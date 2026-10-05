# Fenstra-Testsitzung: Umgebung der grafischen Sitzung auch für SSH-Befehle.
# Liegt in der VM als ~/.bashrc.d/fenstra-ssh-env.sh (Fedoras ~/.bashrc lädt ~/.bashrc.d/*,
# auch bei nicht-interaktiven SSH-Befehlen). Eingerichtet von tools/hyperv/vm-ssh-einrichten.ps1
# bzw. von Hand: scp tools/vm/fenstra-ssh-env.sh daniel@<IP>:.bashrc.d/
#
# Danach laufen über SSH gestartete Programme in der laufenden Plasma-Sitzung
# (Fenster erscheinen auf dem Bildschirm, qdbus erreicht plasmashell und KWin).
if [ -n "${SSH_CONNECTION:-}" ]; then
    export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
    export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}
    export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
    export QT_QPA_PLATFORM=${QT_QPA_PLATFORM:-wayland}
    export XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-wayland}
    export XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-KDE}
    export KDE_FULL_SESSION=true
    export KDE_SESSION_VERSION=6
    # Xwayland-Display der Sitzung (für X11-Programme), falls vorhanden
    if [ -z "${DISPLAY:-}" ]; then
        for s in /tmp/.X11-unix/X*; do [ -e "$s" ] && export DISPLAY=":${s##*/X}" && break; done
    fi
    export PATH="$HOME/.local/bin:$PATH"
fi
