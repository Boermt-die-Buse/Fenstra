#!/bin/bash
# In der VM: Konfigurationswert eines Applets in der Taskleiste setzen (Plasma-Skript-API).
#   applet-config.sh <plugin-id> <gruppe> <schlüssel> <wert>
#   applet-config.sh org.fenstra.infobereich General alleKachelnZeigen true
# Listen als Komma-getrennte Zeichenkette übergeben (wird zur Liste).
set -u
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
PLUGIN=$1 GRUPPE=$2 KEY=$3 WERT=$4
qdbus-qt6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
var wert = '$WERT';
var v = wert === 'true' ? true : wert === 'false' ? false : (wert.indexOf(',') >= 0 ? wert.split(',') : wert);
panels().forEach(function (p) {
  p.widgets('$PLUGIN').forEach(function (w) {
    w.currentConfigGroup = ['$GRUPPE'];
    w.writeConfig('$KEY', v);
    w.reloadConfig();
    print('gesetzt: ' + w.id);
  });
});"
