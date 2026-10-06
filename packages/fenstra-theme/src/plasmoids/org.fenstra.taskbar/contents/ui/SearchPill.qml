/*
    Fenstra-Taskleiste: Suchfeld „Suchen“ (Windows 11 24H2): Pille 180×32, Radius 16,
    Lupe links, Text in Sekundärfarbe. Klick öffnet die Suche.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: suche

    signal clicked()

    width: 180 + 8   // Pille + 4 px Abstand je Seite

    Rectangle {
        id: pille
        anchors.centerIn: parent
        width: 180
        height: 32
        radius: 16
        color: kicker.dunkel
               ? (maus.containsMouse ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(1, 1, 1, 0.06))
               : (maus.containsMouse ? Qt.rgba(1, 1, 1, 0.95) : Qt.rgba(1, 1, 1, 0.75))
        border.width: 1
        border.color: kicker.dunkel ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
        Behavior on color {
            ColorAnimation { duration: 83 }
        }

        Kirigami.Icon {
            id: lupe
            anchors.verticalCenter: parent.verticalCenter
            x: 12
            width: 16
            height: 16
            source: "search"
            isMask: true
            color: kicker.textFarbe
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: lupe.right
            anchors.leftMargin: 8
            text: "Suchen"
            color: kicker.textSekundaer
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 14
            renderType: Text.NativeRendering
        }
    }

    MouseArea {
        id: maus
        anchors.fill: pille
        hoverEnabled: true
        onClicked: suche.clicked()
    }
}
