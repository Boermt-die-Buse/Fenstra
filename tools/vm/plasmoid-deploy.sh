#!/bin/bash
# In der VM (als Testbenutzer, z. B. über SSH): ein Plasmoid aus einem Quellverzeichnis
# für den Benutzer installieren bzw. aktualisieren und plasmashell neu laden.
#
#   plasmoid-deploy.sh <plasmoid-verzeichnis> [--layout]
#
#   --layout   Taskleiste neu aufbauen: alle Panels entfernen und das Layout-Skript des
#              installierten globalen Designs org.fenstra.desktop ausführen. Ergibt frische
#              Applets (z. B. um "erster Start"-Logik zu testen).
#
# Die Benutzerinstallation (~/.local/share/plasma/plasmoids) hat Vorrang vor dem Paket aus
# dem RPM. Zurück zum Paket: kpackagetool6 -t Plasma/Applet -r <id>
#
# Erfahrungen:
#  - plasmashell hält geladene QML-Dateien im Speicher: nach jeder Änderung neu starten.
#  - systemd blockiert nach mehreren schnellen Neustarts (Startbegrenzung); daher reset-failed.
#  - kpackagetool6 -s findet auch das Systempaket; deshalb das Benutzerverzeichnis prüfen.
set -u
DIR=${1:?Plasmoid-Verzeichnis angeben}
DIR=$(cd "$DIR" && pwd)
ID=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$DIR/metadata.json")
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}

# Windows-Zeilenenden entfernen (Dateien kommen oft per scp von Windows)
find "$DIR" -type f \( -name '*.qml' -o -name '*.js' -o -name '*.json' -o -name '*.xml' \) -exec sed -i 's/\r$//' {} +

if [ -d "$HOME/.local/share/plasma/plasmoids/$ID" ]; then
    kpackagetool6 -t Plasma/Applet -u "$DIR"
else
    kpackagetool6 -t Plasma/Applet -i "$DIR"
fi

SINCE=$(date '+%Y-%m-%d %H:%M:%S')
if [ "${2:-}" = --layout ]; then
    L=/usr/share/plasma/look-and-feel/org.fenstra.desktop/contents/layouts/org.kde.plasma.desktop-layout.js
    SCRIPT=$(printf '%s\n' 'panels().forEach(function (p) { p.remove(); });'; cat "$L")
    qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$SCRIPT"
fi

systemctl --user reset-failed plasma-plasmashell.service 2>/dev/null
systemctl --user restart plasma-plasmashell.service
sleep 6
echo "== QML-Meldungen seit dem Neustart (leer = keine Fehler)"
journalctl --user --since "$SINCE" --no-pager -o cat \
    | grep -i -E "$ID|TypeError|ReferenceError|is not a type|unavailable" \
    | grep -v -i -E 'libEGL|MESA' | head -40
