#!/bin/bash
# In der VM: ein Fenster (nach Titelanfang) auf feste Position/Größe setzen – über ein
# kurzes KWin-Skript (Wayland-Programme dürfen sich nicht selbst platzieren).
# Für reproduzierbare Bildschirmfotos und Pixelmessungen.
#
#   fenster-setzen.sh "Fenstra Stiltest" X Y [BREITE HÖHE]
#
# X/Y/BREITE/HÖHE beziehen sich auf den Fensterrahmen (frameGeometry, inkl. Titelleiste).
set -eu
titel=$1; x=$2; y=$3; b=${4:-}; h=${5:-}
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
js=$(mktemp /tmp/fenstra-setzen-XXXX.js)
cat > "$js" <<EOF
const fenster = workspace.windowList().filter(w => w.caption.startsWith("$titel"));
for (const w of fenster) {
    const g = w.frameGeometry;
    w.frameGeometry = { x: $x, y: $y, width: ${b:-g.width}, height: ${h:-g.height} };
    workspace.activeWindow = w;
}
EOF
name="fenstra-setzen-$$"
id=$(qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$js" "$name")
qdbus-qt6 org.kde.KWin "/Scripting/Script$id" org.kde.kwin.Script.run >/dev/null 2>&1 || \
  qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null
sleep 0.3
qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$name" >/dev/null
rm -f "$js"
