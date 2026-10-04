/*
    Fenstra-Startmenü: Inhalt des Popups

      ┌──────────────────────────────────────┐
      │ [ Suche                            ] │
      │ Angeheftet                Alle Apps >│
      │  ▢ ▢ ▢ ▢ ▢ ▢                         │
      │  ▢ ▢ ▢ ▢ ▢ ▢                         │
      │ Empfohlen                            │
      │  ▭ Datei        ▭ Datei              │
      ├──────────────────────────────────────┤
      │ (D) Daniel                       ⏻   │
      └──────────────────────────────────────┘

    Seiten: "start" (oben), "apps" (Alle Apps), "search" (sobald getippt wird).

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.plasma.private.kicker as Kicker

Item {
    id: menu

    readonly property int pad: Kirigami.Units.gridUnit * 2
    property string page: searchField.text.length > 0 ? "search" : (showAllApps ? "apps" : "start")
    property bool showAllApps: false

    Layout.preferredWidth: Kirigami.Units.gridUnit * 36
    Layout.preferredHeight: Kirigami.Units.gridUnit * 38
    Layout.minimumWidth: Kirigami.Units.gridUnit * 28
    Layout.minimumHeight: Kirigami.Units.gridUnit * 30

    function close() {
        kicker.expanded = false;
    }
    function reset() {
        searchField.text = "";
        showAllApps = false;
        powerPopup.visible = false;
        searchField.forceActiveFocus();
    }
    // Eintrag eines Kicker-Modells starten und Menü schließen
    function launch(model, row) {
        if (model && row >= 0) {
            model.trigger(row, "", null);
            close();
        }
    }

    Connections {
        target: kicker
        function onExpandedChanged() {
            if (kicker.expanded) {
                menu.reset();
                kicker.recentModel.refresh();
            }
        }
    }

    KCoreAddons.KUser {
        id: kuser
    }

    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: kicker
        favoritesModel: kicker.rootModel.favoritesModel
        mergeResults: true
        query: searchField.text
    }

    // Hintergrund: fast deckend, damit das Menü auch ohne Unschärfe (z. B. VM ohne
    // Grafikkarte) lesbar bleibt; mit Blur wirkt es wie Acrylic.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -Kirigami.Units.smallSpacing
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.backgroundColor
        opacity: 0.92
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ---------- Suche ----------
        PC3.TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.topMargin: menu.pad * 0.75
            Layout.leftMargin: menu.pad
            Layout.rightMargin: menu.pad
            placeholderText: "Zum Suchen hier eingeben"
            focus: true
            Keys.onReturnPressed: menu.launchFirstResult()
            Keys.onEnterPressed: menu.launchFirstResult()
            Keys.onEscapePressed: {
                if (text.length > 0) {
                    text = "";
                } else {
                    menu.close();
                }
            }
            Keys.onDownPressed: {
                if (menu.page === "search") {
                    searchList.forceActiveFocus();
                    searchList.currentIndex = 0;
                }
            }
        }

        // ---------- Seiten ----------
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Kirigami.Units.gridUnit

            // Startseite: Angeheftet + Empfohlen
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: menu.pad
                anchors.rightMargin: menu.pad
                visible: menu.page === "start"
                spacing: Kirigami.Units.largeSpacing

                SectionHeader {
                    title: "Angeheftet"
                    buttonText: "Alle Apps"
                    buttonIcon: "go-next"
                    onButtonClicked: menu.showAllApps = true
                }

                GridView {
                    id: pinnedGrid
                    Layout.fillWidth: true
                    Layout.preferredHeight: cellHeight * 3
                    clip: true
                    interactive: contentHeight > height
                    cellWidth: Math.floor(width / 6)
                    cellHeight: Kirigami.Units.gridUnit * 5
                    model: kicker.rootModel.favoritesModel
                    delegate: AppTile {
                        width: pinnedGrid.cellWidth
                        height: pinnedGrid.cellHeight
                        onActivated: menu.launch(pinnedGrid.model, index)
                    }
                }

                SectionHeader {
                    title: "Empfohlen"
                }

                GridView {
                    id: recentGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    interactive: false
                    cellWidth: Math.floor(width / 2)
                    cellHeight: Kirigami.Units.gridUnit * 3
                    model: kicker.recentModel
                    delegate: ListEntry {
                        width: recentGrid.cellWidth
                        height: recentGrid.cellHeight
                        // nur so viele, wie Platz haben (Windows: 6)
                        visible: index < 6
                        onActivated: menu.launch(recentGrid.model, index)
                    }
                    PC3.Label {
                        anchors.centerIn: parent
                        visible: recentGrid.count === 0
                        text: "Zuletzt verwendete Dateien und Apps erscheinen hier."
                        opacity: 0.7
                    }
                }
            }

            // Alle Apps
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: menu.pad
                anchors.rightMargin: menu.pad
                visible: menu.page === "apps"
                spacing: Kirigami.Units.largeSpacing

                SectionHeader {
                    title: "Alle Apps"
                    buttonText: "Zurück"
                    buttonIcon: "go-previous"
                    buttonIconFirst: true
                    onButtonClicked: menu.showAllApps = false
                }

                PC3.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ListView {
                        id: appsList
                        model: kicker.allAppsModel
                        clip: true
                        section.property: "display"
                        section.criteria: ViewSection.FirstCharacter
                        section.delegate: PC3.Label {
                            required property string section
                            text: section.toUpperCase()
                            font.weight: Font.DemiBold
                            leftPadding: Kirigami.Units.smallSpacing
                            topPadding: Kirigami.Units.smallSpacing
                            bottomPadding: Kirigami.Units.smallSpacing
                        }
                        delegate: ListEntry {
                            width: appsList.width
                            height: Kirigami.Units.gridUnit * 2.2
                            showSubtitle: false
                            pinnable: true
                            onActivated: menu.launch(appsList.model, index)
                        }
                    }
                }
            }

            // Suchergebnisse
            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: menu.pad
                anchors.rightMargin: menu.pad
                visible: menu.page === "search"
                spacing: Kirigami.Units.largeSpacing

                SectionHeader {
                    title: "Beste Übereinstimmungen"
                }

                PC3.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ListView {
                        id: searchList
                        clip: true
                        model: runnerModel.count > 0 ? runnerModel.modelForRow(0) : null
                        keyNavigationEnabled: true
                        highlightMoveDuration: 0
                        delegate: ListEntry {
                            width: searchList.width
                            height: Kirigami.Units.gridUnit * 2.6
                            highlighted: ListView.isCurrentItem && searchList.activeFocus
                            pinnable: true
                            onActivated: menu.launch(searchList.model, index)
                        }
                        Keys.onReturnPressed: menu.launch(searchList.model, currentIndex)
                        Keys.onEnterPressed: menu.launch(searchList.model, currentIndex)
                        Keys.onUpPressed: {
                            if (currentIndex <= 0) {
                                searchField.forceActiveFocus();
                            } else {
                                decrementCurrentIndex();
                            }
                        }
                    }
                }

                PC3.Label {
                    visible: !runnerModel.querying && runnerModel.count === 0
                    text: "Keine Ergebnisse"
                    opacity: 0.7
                }
            }
        }

        // ---------- Leiste unten: Benutzer, Ein/Aus ----------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3.5
            Layout.topMargin: Kirigami.Units.largeSpacing
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04)

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: menu.pad * 1.5
                anchors.rightMargin: menu.pad * 1.5

                KirigamiComponents.Avatar {
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                    source: kuser.faceIconUrl
                    name: kuser.fullName || kuser.loginName
                }
                PC3.Label {
                    Layout.fillWidth: true
                    text: kuser.fullName || kuser.loginName
                    elide: Text.ElideRight
                }
                PC3.ToolButton {
                    id: powerButton
                    icon.name: "system-shutdown"
                    display: QQC2.AbstractButton.IconOnly
                    text: "Ein/Aus"
                    PC3.ToolTip.text: text
                    PC3.ToolTip.visible: hovered
                    onClicked: powerPopup.visible = !powerPopup.visible
                }
            }
        }
    }

    // Ein/Aus-Menü (Sperren, Abmelden, Energiesparmodus, Neu starten, Herunterfahren)
    Rectangle {
        id: powerPopup
        visible: false
        z: 10
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: menu.pad
        anchors.bottomMargin: Kirigami.Units.gridUnit * 3.5
        width: Kirigami.Units.gridUnit * 13
        height: powerColumn.implicitHeight + Kirigami.Units.smallSpacing * 2
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.backgroundColor
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)

        ColumnLayout {
            id: powerColumn
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            spacing: 0
            Repeater {
                model: kicker.systemModel
                delegate: ListEntry {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2.2
                    showSubtitle: false
                    onActivated: {
                        powerPopup.visible = false;
                        menu.launch(kicker.systemModel, index);
                    }
                }
            }
        }
    }

    function launchFirstResult() {
        if (page === "search" && searchList.count > 0) {
            launch(searchList.model, 0);
        }
    }
}
