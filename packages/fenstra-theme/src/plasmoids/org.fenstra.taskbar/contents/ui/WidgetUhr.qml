/*
    Fenstra-Widgets: Uhr – analoges Zifferblatt (Akzentzeiger) und Uhrzeit darunter.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Shapes

import org.fenstra.shell

Item {
    id: u

    property date jetzt: new Date()
    Timer {
        interval: 1000
        running: u.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: u.jetzt = new Date()
    }

    readonly property real d: Math.min(width, height - 22)

    Item {
        id: blatt
        width: u.d
        height: u.d
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Farben.controlFill
            border.width: 1
            border.color: Farben.controlRand
        }
        Repeater {
            model: 12
            delegate: Rectangle {
                required property int index
                width: 2
                height: index % 3 === 0 ? 8 : 4
                radius: 1
                color: Farben.textTertiaer
                x: blatt.width / 2 - 1
                y: 4
                transform: Rotation { origin.x: 1; origin.y: blatt.height / 2 - 4; angle: index * 30 }
            }
        }
        // Stundenzeiger
        Rectangle {
            width: 4
            height: blatt.height * 0.26
            radius: 2
            color: Farben.text
            x: blatt.width / 2 - 2
            y: blatt.height / 2 - height
            transform: Rotation { origin.x: 2; origin.y: blatt.height * 0.26; angle: (u.jetzt.getHours() % 12) * 30 + u.jetzt.getMinutes() / 2 }
        }
        // Minutenzeiger
        Rectangle {
            width: 3
            height: blatt.height * 0.38
            radius: 1.5
            color: Farben.text
            x: blatt.width / 2 - 1.5
            y: blatt.height / 2 - height
            transform: Rotation { origin.x: 1.5; origin.y: blatt.height * 0.38; angle: u.jetzt.getMinutes() * 6 + u.jetzt.getSeconds() / 10 }
        }
        // Sekundenzeiger (Akzent)
        Rectangle {
            width: 1.5
            height: blatt.height * 0.42
            color: Farben.akzentFlaeche
            x: blatt.width / 2 - 0.75
            y: blatt.height / 2 - height
            transform: Rotation { origin.x: 0.75; origin.y: blatt.height * 0.42; angle: u.jetzt.getSeconds() * 6 }
        }
        Rectangle {
            anchors.centerIn: parent
            width: 7
            height: 7
            radius: 3.5
            color: Farben.akzentFlaeche
        }
    }
    WinText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        stil: "caption"
        text: u.jetzt.toLocaleTimeString(Qt.locale(), "HH:mm") + " · Ortszeit"
    }
}
