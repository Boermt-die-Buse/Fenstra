/*
    Fenstra-Shell: Listeneintrag (docs/windows11-referenz.md 2.10): Symbol, Titel, optional
    Untertitel; Hover SubtleFill, Radius 4; „ausgewaehlt“ zeigt zusätzlich den Akzentbalken
    links (3×16, Radius 1,5). Für Startmenü, Suche, Schnelleinstellungen, Kontomenü.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami

Item {
    id: eintrag

    property var symbol: ""
    property bool symbolMaske: false
    property int symbolGroesse: 32
    property string titel: ""
    property string untertitel: ""
    property int titelGroesse: 14
    property bool titelFett: false
    property bool ausgewaehlt: false
    property bool markiert: false          // Tastaturauswahl (wie Hover)
    property bool akzentBalken: true
    property int linkerAbstand: 12
    readonly property alias hovered: maus.containsMouse
    readonly property alias gedrueckt: maus.pressed
    default property alias rechts: rechtsBereich.data

    signal clicked()
    signal rightClicked(real mx, real my)
    signal doubleClicked()

    implicitHeight: 40
    implicitWidth: 240

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        radius: 4
        color: maus.pressed ? Farben.subtilGedrueckt
             : (maus.containsMouse || eintrag.ausgewaehlt || eintrag.markiert) ? Farben.subtilHover : "transparent"
        Behavior on color {
            ColorAnimation { duration: 83 }
        }
    }
    Rectangle {
        visible: eintrag.ausgewaehlt && eintrag.akzentBalken
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 16
        radius: 1.5
        color: Farben.akzentFlaeche
    }

    Kirigami.Icon {
        id: symbolBild
        visible: typeof eintrag.symbol !== "string" || eintrag.symbol.length > 0
        x: eintrag.linkerAbstand
        anchors.verticalCenter: parent.verticalCenter
        width: eintrag.symbolGroesse
        height: eintrag.symbolGroesse
        source: eintrag.symbol
        isMask: eintrag.symbolMaske
        color: Farben.text
    }

    Column {
        anchors.left: symbolBild.visible ? symbolBild.right : parent.left
        anchors.leftMargin: symbolBild.visible ? 12 : eintrag.linkerAbstand
        anchors.right: rechtsBereich.left
        anchors.rightMargin: rechtsBereich.width > 0 ? 8 : 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        WinText {
            width: parent.width
            text: eintrag.titel
            font.pixelSize: eintrag.titelGroesse
            font.weight: eintrag.titelFett ? Font.DemiBold : Font.Normal
        }
        WinText {
            width: parent.width
            visible: eintrag.untertitel.length > 0
            text: eintrag.untertitel
            stil: "caption"
            sekundaer: true
        }
    }

    Row {
        id: rechtsBereich
        anchors.right: parent.right
        anchors.rightMargin: width > 0 ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
    }

    MouseArea {
        id: maus
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                eintrag.rightClicked(mouse.x, mouse.y);
            } else {
                eintrag.clicked();
            }
        }
        onDoubleClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                eintrag.doubleClicked();
            }
        }
    }
}
