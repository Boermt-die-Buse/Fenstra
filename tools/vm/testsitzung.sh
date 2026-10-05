#!/bin/bash
# In der VM (als Testbenutzer): automatisches Sperren, Abdunkeln und Ausschalten des
# Bildschirms abschalten, damit die VM beim Entwickeln nicht ständig gesperrt ist.
# Wirkt nur für diesen Benutzer (~/.config), nicht für die Fenstra-Vorgaben.
export DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-unix:path=/run/user/$(id -u)/bus}
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock false
kwriteconfig6 --file powerdevilrc --group AC --group Display --key TurnOffDisplayWhenIdle false
kwriteconfig6 --file powerdevilrc --group AC --group Display --key DimDisplayWhenIdle false
kwriteconfig6 --file powerdevilrc --group AC --group SuspendAndShutdown --key AutoSuspendAction 0
qdbus-qt6 org.kde.Solid.PowerManagement /org/kde/Solid/PowerManagement \
    org.kde.Solid.PowerManagement.reparseConfiguration >/dev/null 2>&1
echo "Testsitzung: Sperren und Bildschirm-Aus abgeschaltet"
