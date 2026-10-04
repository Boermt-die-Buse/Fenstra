/*
    Fenstra-Startmenü (Baustein 4b-2)
    Startmenü im Aufbau von Windows 11: Suche oben, "Angeheftet" als Raster,
    "Empfohlen" (zuletzt benutzt), unten Benutzer und Ein/Aus. "Alle Apps" als
    alphabetische Liste. Reines QML auf Basis der Kicker-Modelle von Plasma.

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker

PlasmoidItem {
    id: kicker

    // für die Kicker-Modelle (appletInterface)
    readonly property bool isDash: false

    Plasmoid.icon: Plasmoid.configuration.icon
    preferredRepresentation: compactRepresentation
    hideOnWindowDeactivate: true
    switchWidth: Kirigami.Units.gridUnit * 20
    switchHeight: Kirigami.Units.gridUnit * 20
    toolTipMainText: "Start"
    toolTipSubText: ""

    // Alle Programme, Angeheftet (KActivities-Favoriten)
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

        Component.onCompleted: {
            favoritesModel.initForClient("org.fenstra.startmenu.favorites.instance-" + Plasmoid.id);
            if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favorites);
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
            rootModel.refresh();
        }
        // Zeile 0 ist "Alle Anwendungen": flache, alphabetische Liste aller Programme
        onRefreshed: kicker.allAppsModel = rootModel.modelForRow(0)
    }

    // Alle Apps, alphabetisch, ohne Kategorien (gesetzt, sobald rootModel geladen ist)
    property var allAppsModel: null

    // Empfohlen: zuletzt benutzte Dateien und Programme
    readonly property Kicker.RecentUsageModel recentModel: Kicker.RecentUsageModel {
        shownItems: Kicker.RecentUsageModel.AppsAndDocs
        ordering: Kicker.RecentUsageModel.Recent
    }

    // Sperren, Abmelden, Energiesparen, Neu starten, Herunterfahren
    readonly property Kicker.SystemModel systemModel: Kicker.SystemModel {}

    compactRepresentation: StartButton {}
    fullRepresentation: StartMenu {}
}
