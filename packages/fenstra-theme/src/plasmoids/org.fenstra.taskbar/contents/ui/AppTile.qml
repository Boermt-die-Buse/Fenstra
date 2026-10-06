/*
    Fenstra-Startmenü: Kachel in "Angeheftet" (großes Symbol, Name darunter)
    Rechtsklick: "Lösen" (vom Start lösen).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Item {
    id: tile

    required property int index
    required property var model
    signal activated()

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.highlightColor
        opacity: mouseArea.containsMouse ? 0.12 : 0
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium + Kirigami.Units.smallSpacing * 2
            Layout.preferredHeight: Layout.preferredWidth
            source: tile.model.decoration
        }
        PC3.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: tile.model.display || ""
            elide: Text.ElideRight
            maximumLineCount: 1
            font: Kirigami.Theme.smallFont
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup();
            } else {
                tile.activated();
            }
        }
    }

    PC3.Menu {
        id: contextMenu
        PC3.MenuItem {
            text: "Von Start lösen"
            icon.name: "window-unpin"
            onTriggered: kicker.rootModel.favoritesModel.removeFavorite(tile.model.favoriteId)
        }
    }
}
