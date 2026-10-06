/*
    Fenstra: Tastenkürzel von Windows 11 für die Shell-Flyouts (docs/windows11-referenz.md 7.1).

    Das Skript meldet die Kürzel nur bei kglobalaccel an. kglobalaccel sendet bei jedem Druck das
    D-Bus-Signal globalShortcutPressed("kwin", <Name>) auf /component/kwin; die Plasma-Applets
    org.fenstra.taskbar (Suche, Widgets) und org.fenstra.infobereich (Schnelleinstellungen,
    Benachrichtigungen) hören darauf und öffnen bzw. schließen ihr Flyout. So bleibt die Logik
    in den Applets und es entsteht kein Prozess je Tastendruck.

    Konflikte (Plasma-Vorgaben Meta+W Übersicht, Meta+A/Meta+Q Aktivitäten) entfernt
    /etc/xdg/kglobalshortcutsrc aus fenstra-theme.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
function nichts() {
}

registerShortcut("Fenstra Suche", "Fenstra: Suche öffnen", "Meta+S", nichts);
registerShortcut("Fenstra Suche Q", "Fenstra: Suche öffnen (Win+Q)", "Meta+Q", nichts);
registerShortcut("Fenstra Schnelleinstellungen", "Fenstra: Schnelleinstellungen öffnen", "Meta+A", nichts);
registerShortcut("Fenstra Benachrichtigungen", "Fenstra: Benachrichtigungen und Kalender öffnen", "Meta+N", nichts);
registerShortcut("Fenstra Widgets", "Fenstra: Widgets öffnen", "Meta+W", nichts);
