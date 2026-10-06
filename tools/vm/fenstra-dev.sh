#!/bin/bash
# In der VM (als Testbenutzer): Entwicklungsstand der Fenstra-Shell ohne RPM einspielen.
#
#   fenstra-dev.sh <quellordner>     sudo-Passwort auf stdin
#       <quellordner>/qml/org/fenstra/shell   → /usr/lib64/qt6/qml/org/fenstra/shell (sudo)
#       <quellordner>/plasmoids/<id>          → Benutzerkopie (~/.local/share/plasma/plasmoids)
#       <quellordner>/kwin/<id>               → KWin-Skript als Benutzerkopie, KWin lädt neu
#   fenstra-dev.sh --aufraeumen      Benutzerkopien entfernen (zurück zum RPM-Stand)
#
# Danach wird plasmashell einmal neu gestartet und das Journal nach QML-Fehlern durchsucht.
# Das QML-Modul überschreibt Dateien des RPM fenstra-shell; ein späteres dnf install stellt
# den Paketstand wieder her.
set -u
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
QMLDIR=/usr/lib64/qt6/qml/org/fenstra/shell

neustart() {
    local since; since=$(date '+%Y-%m-%d %H:%M:%S')
    systemctl --user reset-failed plasma-plasmashell.service 2>/dev/null
    systemctl --user restart plasma-plasmashell.service
    sleep 7
    echo "== QML-Meldungen seit dem Neustart (leer = keine Fehler)"
    journalctl --user --since "$since" --no-pager -o cat \
        | grep -i -E 'org.fenstra|fenstra/shell|TypeError|ReferenceError|is not a type|unavailable|Cannot assign|non-existent' \
        | grep -v -i -E 'libEGL|MESA|COMMAND=' | head -60
}

if [ "${1:-}" = --aufraeumen ]; then
    for d in ~/.local/share/plasma/plasmoids/org.fenstra.*; do
        [ -d "$d" ] && kpackagetool6 -t Plasma/Applet -r "$(basename "$d")"
    done
    for d in ~/.local/share/kwin-wayland/scripts/fenstra-* ~/.local/share/kwin/scripts/fenstra-*; do
        [ -d "$d" ] && kpackagetool6 -t KWin/Script -r "$(basename "$d")"
    done
    neustart
    exit 0
fi

SRC=${1:?Quellordner angeben}
SRC=$(cd "$SRC" && pwd)
PW=$(cat)
find "$SRC" -type f \( -name '*.qml' -o -name '*.js' -o -name '*.json' -o -name '*.xml' -o -name qmldir \) -exec sed -i 's/\r$//' {} +

if [ -d "$SRC/qml/org/fenstra/shell" ]; then
    echo "$PW" | sudo -S -p '' install -d "$QMLDIR"
    echo "$PW" | sudo -S -p '' install -p -m 0644 "$SRC"/qml/org/fenstra/shell/* "$QMLDIR"/
    echo "QML-Modul: $(ls "$QMLDIR" | wc -l) Dateien"
fi
for d in "$SRC"/plasmoids/*/; do
    [ -f "$d/metadata.json" ] || continue
    id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$d/metadata.json")
    if [ -d "$HOME/.local/share/plasma/plasmoids/$id" ]; then
        kpackagetool6 -t Plasma/Applet -u "$d" >/dev/null
    else
        kpackagetool6 -t Plasma/Applet -i "$d" >/dev/null
    fi
    echo "Plasmoid: $id"
done
for d in "$SRC"/kwin/*/; do
    [ -f "$d/metadata.json" ] || continue
    id=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["KPlugin"]["Id"])' "$d/metadata.json")
    kpackagetool6 -t KWin/Script -r "$id" >/dev/null 2>&1
    kpackagetool6 -t KWin/Script -i "$d" >/dev/null
    qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$id" >/dev/null 2>&1
    qdbus-qt6 org.kde.KWin /KWin org.kde.KWin.reconfigure >/dev/null 2>&1
    qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null 2>&1
    echo "KWin-Skript: $id (geladen: $(qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded "$id" 2>/dev/null))"
done
neustart
