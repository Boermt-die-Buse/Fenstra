/*
    Fenstra-Startmenü: Listeneintrag (Symbol, Name, optional zweite Zeile)
    Wird für Empfohlen, Alle Apps, Suchergebnisse und Ein/Aus benutzt.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: entry

    required property int index
    required property var model

    property bool showSubtitle: true
    property bool highlighted: false
    // Rechtsklick "An Start anheften" / "Von Start lösen" (Alle Apps, Suche)
    property bool pinnable: false
    signal activated()

    readonly property string favoriteId: entry.model.favoriteId || ""
    readonly property bool isPinned: {
        kicker.rootModel.favoritesModel.favorites; // Abhängigkeit: neu auswerten, wenn sich die Liste ändert
        return favoriteId.length > 0 && kicker.rootModel.favoritesModel.isFavorite(favoriteId);
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.highlightColor
        opacity: entry.highlighted ? 0.25 : (mouseArea.containsMouse ? 0.12 : 0)
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Icon {
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            source: entry.model.decoration
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PC3.Label {
                Layout.fillWidth: true
                text: entry.model.display || ""
                elide: Text.ElideRight
                maximumLineCount: 1
            }
            PC3.Label {
                Layout.fillWidth: true
                visible: entry.showSubtitle && text.length > 0
                text: entry.model.description || ""
                elide: Text.ElideRight
                maximumLineCount: 1
                font: Kirigami.Theme.smallFont
                opacity: 0.7
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (entry.pinnable && entry.favoriteId.length > 0) {
                    contextMenu.popup();
                }
            } else {
                entry.activated();
            }
        }
    }

    PC3.Menu {
        id: contextMenu
        PC3.MenuItem {
            text: entry.isPinned ? "Von Start lösen" : "An Start anheften"
            icon.name: entry.isPinned ? "window-unpin" : "window-pin"
            onTriggered: {
                if (entry.isPinned) {
                    kicker.rootModel.favoritesModel.removeFavorite(entry.favoriteId);
                } else {
                    kicker.rootModel.favoritesModel.addFavorite(entry.favoriteId, -1);
                }
            }
        }
    }
}
