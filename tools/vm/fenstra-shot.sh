#!/bin/bash
# In der VM: Bildschirmfoto der laufenden Plasma-Sitzung in voller Auflösung (Spectacle,
# KWin-ScreenShot2-Schnittstelle). Weckt vorher den Bildschirm (sonst nur Weiß/Schwarz).
#
#   fenstra-shot.sh [datei.png] [--region X,Y,B,H] [--fenster] [--warten SEK]
#
#   --region   nur einen Ausschnitt speichern (Gastpixel), zum genauen Vergleich
#   --fenster  nur das aktive Fenster (ohne Schatten)
#   --warten   vor der Aufnahme warten (Animationen ausklingen lassen), Standard 0,3 s
#
# Ausgabe: Dateiname. Holen mit scp (tools/hyperv/vm-gastfoto.ps1 macht beides).
set -euo pipefail
out=/tmp/fenstra-shot.png; region=""; mode=-f; wait=0.3
while [ $# -gt 0 ]; do
    case "$1" in
        --region) region=$2; shift 2 ;;
        --fenster) mode=-a; shift ;;
        --warten) wait=$2; shift 2 ;;
        *) out=$1; shift ;;
    esac
done
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}
kscreen-doctor --dpms on >/dev/null 2>&1 || true
sleep "$wait"
rm -f "$out"
spectacle -b -n "$mode" -o "$out" >/dev/null 2>&1
if [ -n "$region" ]; then
    IFS=, read -r x y w h <<<"$region"
    python3 - "$out" "$x" "$y" "$w" "$h" <<'EOF'
import sys
from PIL import Image
p, x, y, w, h = sys.argv[1], *map(int, sys.argv[2:])
Image.open(p).crop((x, y, x + w, y + h)).save(p)
EOF
fi
echo "$out"
