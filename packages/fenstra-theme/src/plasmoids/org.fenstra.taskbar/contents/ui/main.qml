/*
    Fenstra-Taskleiste (M3): alles links vom Infobereich in einem Applet.

      [Widgets]          [Start][ Suchen ][Task-Ansicht][App][App][App]           |Infobereich|
                         └───────── mittig zur Bildschirmbreite ─────────┘

    Das Applet füllt die Taskleiste bis zum Infobereich und setzt die Gruppe selbst so, dass
    sie zur Bildschirmmitte zentriert ist (Plasma-Abstandhalter zentrieren nur im freien
    Platz). Das Startmenü ist ein eigener Dialog, waagrecht mittig über der Taskleiste.

    Daten: org.kde.taskmanager (Fenster, angeheftete Apps), Kicker-Modelle (Startmenü,
    Sprunglisten), KPipeWire (Vorschaubilder).

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.private.sessions as Sessions
import org.kde.plasma.workspace.dbus as DBus
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    // Der Name "kicker" bleibt: die Startmenü-Dateien (aus 4b-2 übernommen) greifen darauf zu.
    id: kicker

    readonly property bool isDash: false       // für die Kicker-Modelle
    property bool startOpen: false
    // Inhalt des Start-Flyouts: "start" (Startmenü) oder "suche" (Suchpanel, Win+S, Suchfeld)
    property string startModus: "start"
    property bool widgetsOffen: false

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.constraintHints: Plasmoid.CanFillArea
    Plasmoid.icon: Plasmoid.configuration.icon

    // ------------------------------------------------------------------
    // Farben wie in der Windows-11-Taskleiste (docs/windows11-referenz.md 4.2)
    readonly property bool dunkel: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark
    readonly property color textFarbe: Kirigami.Theme.textColor
    readonly property color textSekundaer: dunkel ? Qt.rgba(1, 1, 1, 0.786) : Qt.rgba(0, 0, 0, 0.62)
    // Hover/aktiv: helle, halbdurchsichtige Fläche mit feinem Rand (wie ein Steuerelement)
    readonly property color flaecheHover: dunkel ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.55)
    readonly property color flaecheAktiv: dunkel ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(1, 1, 1, 0.78)
    readonly property color flaecheGedrueckt: dunkel ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(1, 1, 1, 0.35)
    readonly property color randHover: dunkel ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)
    // Indikator: aktiv Akzent (hell AccentDark1, dunkel AccentLight2), sonst grau
    readonly property color akzent: Kirigami.Theme.highlightColor
    readonly property color indikatorAktiv: akzentStufe(akzent, dunkel ? 2 : -1)
    readonly property color indikatorInaktiv: dunkel ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.45)
    readonly property color aufmerksamkeit: dunkel ? Qt.rgba(0.97, 0.39, 0.05, 0.35) : Qt.rgba(0.97, 0.39, 0.05, 0.22)

    // Akzentpalette: für #0078D4 die exakten Windows-Werte, sonst Näherung über die Helligkeit
    function akzentStufe(c, stufe) {
        if (stufe === 0) {
            return c;
        }
        const exakt = {"-3": "#001A68", "-2": "#003E92", "-1": "#0067C0", "1": "#0091F8", "2": "#4CC2FF", "3": "#99EBFF"};
        if (Math.abs(c.r - 0) < 0.01 && Math.abs(c.g - 120 / 255) < 0.01 && Math.abs(c.b - 212 / 255) < 0.01) {
            return exakt[String(stufe)];
        }
        const l = Math.max(0, Math.min(1, c.hslLightness + stufe * 0.12));
        return Qt.hsla(c.hslHue, c.hslSaturation, l, 1);
    }

    // ------------------------------------------------------------------
    // Aufgaben (Fenster und angeheftete Apps)
    TaskManager.VirtualDesktopInfo { id: virtualDesktopInfo }
    TaskManager.ActivityInfo { id: activityInfo }

    property alias tasksModel: tasksModel
    TaskManager.TasksModel {
        id: tasksModel

        virtualDesktop: virtualDesktopInfo.currentDesktop
        screenGeometry: Plasmoid.containment.screenGeometry
        activity: activityInfo.currentActivity
        // Windows: Apps nur vom aktuellen Desktop, von allen Bildschirmen
        filterByVirtualDesktop: true
        filterByScreen: false
        filterByActivity: true
        filterNotMinimized: false
        groupMode: TaskManager.TasksModel.GroupApplications
        groupInline: false
        groupingWindowTasksThreshold: -1
        sortMode: TaskManager.TasksModel.SortManual
        separateLaunchers: false
        hideActivatedLaunchers: true
        launchInPlace: true

        onLauncherListChanged: {
            if (kicker.launchersGeladen) {
                Plasmoid.configuration.launchers = launcherList;
            }
        }
        Component.onCompleted: {
            launcherList = Plasmoid.configuration.launchers;
            kicker.launchersGeladen = true;
        }
    }
    property bool launchersGeladen: false

    // Win+1 … Win+9 (plasmashell ruft das bei "org.kde.plasma.multitasking" auf)
    function activateTaskAtIndex(index) {
        if (typeof index !== "number" || index < 0 || index >= tasksModel.count) {
            return;
        }
        const idx = tasksModel.makeModelIndex(index);
        const istStarter = tasksModel.data(idx, TaskManager.AbstractTasksModel.IsLauncher);
        if (istStarter) {
            tasksModel.requestActivate(idx);
        } else if (tasksModel.data(idx, TaskManager.AbstractTasksModel.IsActive)
                   && !tasksModel.data(idx, TaskManager.AbstractTasksModel.IsGroupParent)) {
            tasksModel.requestToggleMinimized(idx);
        } else {
            tasksModel.requestActivate(idx);
        }
    }

    // ------------------------------------------------------------------
    // Startmenü-Daten (aus 4b-2)
    readonly property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false
        appletInterface: kicker
        flat: true
        sorted: true
        showSeparators: false
        showTopLevelItems: true
        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        // „Kürzlich hinzugefügt“ in Empfohlen (Kicker merkt sich, wann eine App zuerst auftauchte)
        highlightNewlyInstalledApps: true

        Component.onCompleted: {
            // dieselbe Favoritenliste wie das frühere Startmenü-Applet (KActivities, global)
            favoritesModel.initForClient("org.fenstra.startmenu.favorites.instance-" + Plasmoid.id);
            if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                const wanted = Plasmoid.configuration.favorites;
                for (let i = 0; i < wanted.length; ++i) {
                    if (!favoritesModel.isFavorite(wanted[i])) {
                        favoritesModel.addFavorite(wanted[i], -1);
                    }
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
            rootModel.refresh();
        }
        onRefreshed: kicker.allAppsModel = rootModel.modelForRow(0)
    }
    property var allAppsModel: null
    // Empfohlen und Suche: zuletzt geöffnete Dateien, meistgenutzte Apps
    readonly property Kicker.RecentUsageModel recentDocsModel: Kicker.RecentUsageModel {
        shownItems: Kicker.RecentUsageModel.OnlyDocs
        ordering: Kicker.RecentUsageModel.Recent
    }
    readonly property Kicker.RecentUsageModel topAppsModel: Kicker.RecentUsageModel {
        shownItems: Kicker.RecentUsageModel.OnlyApps
        ordering: Kicker.RecentUsageModel.Popular
    }
    // Sperren, Abmelden, Energie sparen, Herunterfahren, Neu starten
    readonly property Sessions.SessionManagement sitzung: Sessions.SessionManagement {}

    // Programme per Desktop-Datei starten (mit Startrückmeldung, wie aus dem Startmenü)
    Kicker.SimpleFavoritesModel {
        id: starter
    }
    function starteApp(storageId) {
        starter.favorites = [storageId];
        if (starter.count > 0) {
            starter.trigger(0, "", null);
        }
    }

    // ------------------------------------------------------------------
    // D-Bus-Aufrufe (Suche, Task-Ansicht, Desktop anzeigen)
    function kwinKuerzel(name) {
        DBus.SessionBus.asyncCall({
            service: "org.kde.kglobalaccel",
            path: "/component/kwin",
            iface: "org.kde.kglobalaccel.Component",
            member: "invokeShortcut",
            arguments: [name]
        });
    }
    // Suchpanel (Suchfeld der Taskleiste, Win+S/Win+Q): an der Stelle des Startmenüs
    function sucheOeffnen() {
        if (kicker.startOpen && kicker.startModus === "suche") {
            kicker.startOpen = false;
            return;
        }
        kicker.startModus = "suche";
        kicker.startOpen = true;
    }
    function startUmschalten() {
        if (!kicker.startOpen) {
            kicker.startModus = "start";
            kicker.startOpen = true;
        } else if (kicker.startModus !== "start") {
            kicker.startModus = "start";
        } else {
            kicker.startOpen = false;
        }
    }
    // Befehle ohne Rückgabe ausführen (Einstellungen, Discover, Dateimanager)
    P5Support.DataSource {
        id: befehle
        engine: "executable"
        connectedSources: []
        onNewData: (quelle, daten) => disconnectSource(quelle)
    }
    function befehl(b) {
        befehle.connectSource(b);
    }
    // Favoriten-IDs sind reine Desktop-IDs („org.kde.kcalc.desktop“) oder URLs
    // („preferred://browser“, „applications:…“); Taskleisten-Starter brauchen eine URL.
    function launcherUrl(id) {
        id = String(id || "");
        return id.length === 0 ? "" : (id.indexOf(":") > 0 ? id : "applications:" + id);
    }
    function speicherId(id) {
        id = String(id || "");
        if (id.startsWith("applications:")) {
            return id.substring(13);
        }
        return id.endsWith(".desktop") && id.indexOf(":") < 0 ? id : "";
    }
    // Text sicher für die Shell einfassen
    function shellWort(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    Connections {
        target: Plasmoid
        // Windows-Taste (plasmashell: "Anwendungsstarter aktivieren")
        function onActivated() {
            kicker.startUmschalten();
        }
    }

    // Win+S/Win+Q/Win+W: kglobalaccel meldet die Kürzel des KWin-Skripts fenstra-kuerzel
    DBus.SignalWatcher {
        busType: DBus.BusType.Session
        service: "org.kde.kglobalaccel"
        path: "/component/kwin"
        iface: "org.kde.kglobalaccel.Component"
        function dbusglobalShortcutPressed(komponente, name, zeit) {
            // Argumente kommen als Variant-Objekte: über String() vergleichen
            const n = String(name);
            if (n === "Fenstra Suche" || n === "Fenstra Suche Q") {
                kicker.sucheOeffnen();
            } else if (n === "Fenstra Widgets") {
                kicker.widgetsOffen = !kicker.widgetsOffen;
            }
        }
    }

    fullRepresentation: Bar {}
}
