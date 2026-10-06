#!/bin/bash
# In der VM (Testbenutzer): Benutzerkonfiguration eines bestehenden Kontos auf die M4-Vorgaben
# bringen, die neue Konten über /etc/xdg bzw. das Layout-Skript bekommen:
#  - Tastenkürzel: Meta+W/Meta+A/Meta+Q frei für Widgets, Schnelleinstellungen, Suche
#    (KWin-Übersicht → Meta+Tab, Plasma-Aktivitäten ohne Taste)
#  - Plasmas Benachrichtigungs-Applet aus dem Systemabschnitt entfernen (Toasts und
#    Benachrichtigungscenter kommen jetzt von org.fenstra.infobereich); neue Konten bekommen
#    das über das Layout-Skript des globalen Designs
# kglobalaccel läuft in KWin: die Kürzel wirken erst nach einem KWin-Neustart (--kwin).
set -u
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
K=kglobalshortcutsrc
kwriteconfig6 --file $K --group kwin --key "Overview" "Meta+Tab,Meta+W,Übersicht umschalten"
kwriteconfig6 --file $K --group kwin --key "Walk Through Windows" "$(printf 'Alt+Tab,Alt+Tab\tMeta+Tab,Zwischen Fenstern wechseln')"
kwriteconfig6 --file $K --group plasmashell --key "manage activities" "none,Meta+Q,Aktivitätenwechsler anzeigen"
kwriteconfig6 --file $K --group plasmashell --key "next activity" "none,none,Zwischen Aktivitäten wechseln"
for n in "Fenstra Suche:Meta+S:Fenstra: Suche öffnen" "Fenstra Suche Q:Meta+Q:Fenstra: Suche öffnen (Win+Q)" \
         "Fenstra Schnelleinstellungen:Meta+A:Fenstra: Schnelleinstellungen öffnen" \
         "Fenstra Benachrichtigungen:Meta+N:Fenstra: Benachrichtigungen und Kalender öffnen" \
         "Fenstra Widgets:Meta+W:Fenstra: Widgets öffnen"; do
    IFS=: read -r name taste text <<< "$n"
    kwriteconfig6 --file $K --group kwin --key "$name" "$taste,$taste,$text"
done
echo "Tastenkürzel geschrieben"

# Plasmas Benachrichtigungs-Applet aus dem Systemabschnitt entfernen (plasmashell angehalten):
# Applet-Gruppe löschen, aus extraItems/hiddenItems/shownItems nehmen, in knownItems lassen
# (sonst nimmt der Systemabschnitt es beim nächsten Start als „neu“ wieder auf).
systemctl --user stop plasma-plasmashell
sleep 2
python3 - <<'PY'
import os
import re
import sys

pfad = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else '~/.config/plasma-org.kde.plasma.desktop-appletsrc')
NAME = 'org.kde.plasma.notifications'
text = open(pfad, encoding='utf-8').read()
bloecke = re.split(r'(?m)^(?=\[)', text)
# Gruppen des Applets finden
weg = set()
for b in bloecke:
    m = re.match(r'(\[[^\n]*\])\n', b)
    if m and re.search(r'(?m)^plugin=' + re.escape(NAME) + r'$', b):
        weg.add(m.group(1))
neu = []
for b in bloecke:
    m = re.match(r'(\[[^\n]*\])\n', b)
    kopf = m.group(1) if m else ''
    if any(kopf == w or kopf.startswith(w[:-1] + '][') for w in weg):
        continue
    def liste(mm):
        schluessel, werte = mm.group(1), mm.group(2)
        if schluessel == 'knownItems':
            l = [x for x in werte.split(',') if x]
            return schluessel + '=' + ','.join(l + ([] if NAME in l else [NAME]))
        return schluessel + '=' + ','.join(x for x in werte.split(',') if x and x != NAME)
    b = re.sub(r'(?m)^(extraItems|hiddenItems|shownItems|knownItems)=(.*)$', liste, b)
    neu.append(b)
open(pfad, 'w', encoding='utf-8').write(''.join(neu))
print('entfernt:', ', '.join(sorted(weg)) or 'nichts')
PY
systemctl --user start plasma-plasmashell
sleep 6

if [ "${1:-}" = --kwin ]; then
    kill -9 "$(pgrep -x kwin_wayland)"
    sleep 8
    echo "KWin neu gestartet"
fi
