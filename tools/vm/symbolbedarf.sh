#!/bin/bash
# In der VM: welche Symbolnamen benutzen Plasma und die installierten Programme vermutlich?
# Kandidaten = Zeichenketten in Programmen/Bibliotheken/QML/.desktop, geschnitten mit den
# Namen, die das Breeze-Symbolthema anbietet (dessen Lücken würden sonst sichtbar).
# Ausgabe: /tmp/symbolbedarf.txt (Kontext/Name), Zusammenfassung auf stdout.
#   symbolbedarf.sh          breit: alle Qt-Plugins und QML-Module (enthält viel Rauschen,
#                            z. B. Bildfilter-Namen aus digiKam-Plugins)
#   symbolbedarf.sh --kern   nur Plasma, KWin, KF6, Systemeinstellungen-Module und die
#                            Kernprogramme (Prüfpunkt I11) -> /tmp/symbolbedarf-kern.txt
set -u
kern=0
[ "${1:-}" = "--kern" ] && kern=1
out=/tmp/symbolbedarf.txt
[ $kern = 1 ] && out=/tmp/symbolbedarf-kern.txt
tmp=$(mktemp -d)
# alle Breeze-Namen mit Kontext (Ordnername der obersten Ebene: actions, places, …)
find /usr/share/icons/breeze -name '*.svg' -o -name '*.png' | \
  sed -E 's#^/usr/share/icons/breeze/([^/]+)/[^/]+/([^/]+)\.(svg|png)$#\1 \2#' | sort -u > "$tmp/breeze"
cut -d' ' -f2 "$tmp/breeze" | sort -u > "$tmp/breeze-names"
# Zeichenketten aus Programmen, Bibliotheken, Plugins, QML, Desktop-Dateien
{
  for f in /usr/bin/{dolphin,konsole,kwrite,kate,systemsettings,plasmashell,spectacle,gwenview,okular,ark,kcalc,plasma-discover,kwin_wayland,krunner,kded6,ksmserver,plasmalogin} ; do
    [ -f "$f" ] && strings -n 4 "$f"
  done
  find /usr/lib64 -maxdepth 1 -name 'libKF6*.so.*' -o -maxdepth 1 -name 'libplasma*.so.*' -o -maxdepth 1 -name 'libkworkspace*.so.*' | xargs -r strings -n 4
  if [ $kern = 1 ]; then
    find /usr/lib64/qt6/plugins/plasma /usr/lib64/qt6/plugins/kf6 /usr/lib64/qt6/plugins/kwin /usr/lib64/qt6/plugins/dolphin \
         /usr/lib64/qt6/plugins/konsoleplugins /usr/lib64/qt6/plugins/plasmacalendarplugins \
         /usr/lib64/qt6/qml/org/kde/plasma /usr/lib64/qt6/qml/org/kde/kirigami* /usr/lib64/qt6/qml/org/kde/kcmutils \
         /usr/lib64/qt6/qml/org/kde/taskmanager /usr/lib64/qt6/qml/org/kde/notificationmanager \
         -name '*.so' 2>/dev/null | xargs -r strings -n 4
  else
    find /usr/lib64/qt6/plugins /usr/lib64/qt6/qml -name '*.so' | xargs -r strings -n 4
  fi
  find /usr/share/plasma /usr/share/kwin* /usr/share/kservices6 /usr/share/knotifications6 -name '*.qml' -o -name '*.js' -o -name '*.json' -o -name '*.desktop' -o -name '*.notifyrc' 2>/dev/null | xargs -r cat 2>/dev/null
  # nur sichtbare Programme (wie im Startmenü)
  for f in /usr/share/applications/*.desktop /etc/xdg/autostart/*.desktop; do
    grep -q '^NoDisplay=true' "$f" 2>/dev/null && continue
    grep -m1 '^Icon=' "$f" 2>/dev/null | cut -d= -f2
  done
} | grep -oE '[a-z][a-z0-9]*(-[a-z0-9]+)*' | sort -u > "$tmp/strings"
comm -12 "$tmp/breeze-names" "$tmp/strings" > "$tmp/used"
# mit Kontext ausgeben
grep -F -w -f "$tmp/used" "$tmp/breeze" | awk 'NR==FNR{u[$1]=1;next} ($2 in u){print $1" "$2}' "$tmp/used" - | sort -u > "$out"
echo "Breeze-Namen: $(wc -l < "$tmp/breeze-names")"
echo "vermutlich benutzt: $(wc -l < "$tmp/used")"
cut -d' ' -f1 "$out" | sort | uniq -c | sort -rn
rm -rf "$tmp"
