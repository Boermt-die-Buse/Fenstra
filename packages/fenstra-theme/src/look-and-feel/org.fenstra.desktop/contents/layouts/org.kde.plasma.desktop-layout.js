// Fenstra: Taskleiste im Aufbau von Windows 11 (M3).
// Wird von Plasma beim ersten Anmelden eines Benutzers ausgeführt (globales Design
// org.fenstra.desktop) und beim Anwenden des Designs mit "Layout übernehmen".
//
// Aufbau von links nach rechts:
//   Fenstra-Taskleiste (Widgets-Knopf; Start, Suche, Task-Ansicht, Apps mittig zum Bildschirm)
//   Plasma-Systemabschnitt (nur der Überlauf „^“ und App-Symbole; Netz, Ton usw. ausgeblendet)
//   Fenstra-Infobereich (Schnelleinstellungen-Gruppe, Uhr, Glocke, Desktop anzeigen)

var panel = new Panel;
panel.location = "bottom";
// Windows-Taskleiste: 48 px bei 100 % Skalierung (gridUnit ist dort 18 px)
panel.height = Math.round(gridUnit * 48 / 18);
panel.alignment = "center";
panel.lengthMode = "fill";
// nicht schwebend, über die ganze Breite (Plasma 6 schwebt standardmäßig)
if ("floating" in panel) {
    panel.floating = false;
}
// durchscheinend mit Unschärfe dahinter (Acrylic-Annäherung)
if ("opacity" in panel) {
    panel.opacity = "adaptive";
}

// Taskleiste mit Startmenü (Paket fenstra-taskleiste)
panel.addWidget("org.fenstra.taskbar");

// Plasma-Systemabschnitt: Statussymbole kommen in den Überlauf; Netz, Ton und Akku zeigt der
// Fenstra-Infobereich, Benachrichtigungen bleiben hier (sie liefern die Popups).
var tray = panel.addWidget("org.kde.plasma.systemtray");
tray.currentConfigGroup = ["General"];
tray.writeConfig("hiddenItems", [
    "org.kde.plasma.networkmanagement", "org.kde.plasma.volume", "org.kde.plasma.battery",
    "org.kde.plasma.notifications", "org.kde.plasma.brightness", "org.kde.plasma.clipboard",
    "org.kde.plasma.devicenotifier", "org.kde.kdeconnect", "org.kde.plasma.vault",
    "org.kde.plasma.printmanager", "org.kde.plasma.keyboardlayout", "org.kde.plasma.keyboardindicator",
    "org.kde.plasma.manage-inputmethod", "org.kde.plasma.mediacontroller", "org.kde.plasma.cameraindicator",
    "org.kde.plasma.weather", "org.kde.plasma.bluetooth", "org.kde.kscreen"
]);
tray.writeConfig("shownItems", []);

// Infobereich: Gruppe, Uhr, Glocke, Streifen „Desktop anzeigen“
panel.addWidget("org.fenstra.infobereich");

// Hintergrundbild für alle Desktops
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}
