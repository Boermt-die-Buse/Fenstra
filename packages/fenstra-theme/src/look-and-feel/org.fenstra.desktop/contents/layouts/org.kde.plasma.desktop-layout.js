// Fenstra: Taskleiste im Aufbau von Windows 11 (Baustein 4b).
// Wird von Plasma beim ersten Anmelden eines Benutzers ausgeführt (globales Design
// org.fenstra.desktop) und beim Anwenden des Designs mit "Layout übernehmen".
//
// Aufbau von links nach rechts:
//   [flexibler Abstand] Start  Suche  Aktive Anwendungen  angeheftete/offene Programme
//   [flexibler Abstand] Infobereich  Uhr mit Datum  Desktop anzeigen
// Die Programmgruppe sitzt dadurch mittig zwischen linkem Rand und Infobereich.

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
// durchscheinend mit Unschärfe dahinter (Acrylic-Annäherung, Plasma-Design "default")
if ("opacity" in panel) {
    panel.opacity = "adaptive";
}

panel.addWidget("org.kde.plasma.panelspacer");

var start = panel.addWidget("org.kde.plasma.kickoff");
start.currentConfigGroup = ["General"];
start.writeConfig("icon", "start-here");
start.writeConfig("favoritesDisplay", 0);      // angeheftete Apps als Raster
start.writeConfig("applicationsDisplay", 1);   // "Alle Apps" als Liste
start.writeConfig("showActionButtonCaptions", false);
start.writeConfig("primaryActions", 3);        // unten: Ausschalten/Neu starten/...

var search = panel.addWidget("org.kde.plasma.icon");
search.currentConfigGroup = ["General"];
search.writeConfig("url", "file:///usr/share/applications/fenstra-search.desktop");

var taskview = panel.addWidget("org.kde.plasma.icon");
taskview.currentConfigGroup = ["General"];
taskview.writeConfig("url", "file:///usr/share/applications/fenstra-taskview.desktop");

var tasks = panel.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", [
    "applications:org.kde.dolphin.desktop",
    "applications:org.mozilla.firefox.desktop",
    "applications:org.kde.discover.desktop"
]);
tasks.writeConfig("showOnlyCurrentDesktop", false);
tasks.writeConfig("iconSpacing", 2);
tasks.writeConfig("fill", false);              // Programmgruppe nicht strecken (mittig)

panel.addWidget("org.kde.plasma.panelspacer");

panel.addWidget("org.kde.plasma.systemtray");

var clock = panel.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", true);
clock.writeConfig("dateDisplayFormat", "BelowTime");
clock.writeConfig("dateFormat", "shortDate");

panel.addWidget("org.kde.plasma.showdesktop");

// Hintergrundbild für alle Desktops
var desktopsArray = desktopsForActivity(currentActivity());
for (var j = 0; j < desktopsArray.length; j++) {
    desktopsArray[j].wallpaperPlugin = "org.kde.image";
}
