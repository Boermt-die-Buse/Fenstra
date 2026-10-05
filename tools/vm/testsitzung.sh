#!/bin/bash
# In der VM (als Testbenutzer): Sitzung für die Entwicklung vorbereiten.
#  - automatisches Sperren, Abdunkeln, Bildschirm-Aus und Standby abschalten
#    (sonst sperrt bzw. dimmt die VM beim Entwickeln, Bildschirmfotos werden weiß/dunkel)
#  - Auflösung 1920x1080 (1-px-Linien, Abstände und Ecken beurteilbar)
#  - Helfer nach ~/.local/bin und ~/.bashrc.d (SSH-Befehle laufen in der Sitzung)
# Wirkt nur für diesen Benutzer (~/.config), nicht für die Fenstra-Vorgaben.
# Aufruf aus dem Ordner, in dem auch fenstra-shot.sh und fenstra-ssh-env.sh liegen.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}

kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume false
for profile in AC Battery LowBattery; do
    # Plasma 6: Zeitwerte in Sekunden, -1 = nie; die alten Schalter zusätzlich setzen
    kwriteconfig6 --file powerdevilrc --group "$profile" --group Display --key DimDisplayWhenIdle false
    kwriteconfig6 --file powerdevilrc --group "$profile" --group Display --key DimDisplayIdleTimeoutSec -- -1
    kwriteconfig6 --file powerdevilrc --group "$profile" --group Display --key TurnOffDisplayWhenIdle false
    kwriteconfig6 --file powerdevilrc --group "$profile" --group Display --key TurnOffDisplayIdleTimeoutSec -- -1
    kwriteconfig6 --file powerdevilrc --group "$profile" --group SuspendAndShutdown --key AutoSuspendAction 0
done
qdbus-qt6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement \
    org.kde.Solid.PowerManagement.reparseConfiguration >/dev/null 2>&1

# Auflösung (KScreen merkt sich die Einstellung pro Bildschirm)
out=$(kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/^Output:/ {print $3; exit}')
if [ -n "$out" ]; then
    kscreen-doctor "output.$out.mode.1920x1080@60" >/dev/null 2>&1 && echo "Auflösung: $out 1920x1080"
fi
kscreen-doctor --dpms on >/dev/null 2>&1

# Helfer installieren
mkdir -p "$HOME/.local/bin" "$HOME/.bashrc.d"
for f in fenstra-shot.sh plasmoid-deploy.sh; do
    [ -f "$HERE/$f" ] && install -m 0755 "$HERE/$f" "$HOME/.local/bin/$f"
done
[ -f "$HERE/fenstra-ssh-env.sh" ] && install -m 0644 "$HERE/fenstra-ssh-env.sh" "$HOME/.bashrc.d/fenstra-ssh-env.sh"
echo "Testsitzung: Sperren, Dimmen, Bildschirm-Aus abgeschaltet; Helfer in ~/.local/bin"
