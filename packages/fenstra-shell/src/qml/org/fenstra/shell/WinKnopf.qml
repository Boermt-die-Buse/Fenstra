/*
    Fenstra-Shell: Schaltfläche im WinUI-Aussehen (docs/windows11-referenz.md 2.1).
      art: "standard" (Steuerelementfläche mit Elevation-Rand), "akzent", "subtil" (transparent)
    Höhe 32, Radius 4, Text 14, Symbol 16. Hover/gedrückt mit 83 ms Farbübergang.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: knopf

    property string text: ""
    property var symbol: ""                 // Symbolname, URL oder QIcon
    property bool symbolMaske: true
    property int symbolGroesse: 16
    property bool symbolRechts: false
    property string art: "standard"
    property string tooltip: ""
    property int innenabstand: 12
    property int radius: 4
    property int schriftGroesse: 14
    property bool fett: false
    property bool aktiv: false              // dauerhaft hervorgehoben (z. B. geöffnetes Menü)
    readonly property alias hovered: maus.containsMouse
    readonly property alias gedrueckt: maus.pressed
    readonly property bool hatSymbol: typeof symbol !== "string" || symbol.length > 0

    signal clicked()
    signal rightClicked()

    implicitHeight: 32
    implicitWidth: Math.max(implicitHeight, inhalt.implicitWidth + 2 * innenabstand)
    activeFocusOnTab: true
    Keys.onSpacePressed: knopf.clicked()
    Keys.onReturnPressed: knopf.clicked()
    Keys.onEnterPressed: knopf.clicked()

    readonly property color textFarbe: !enabled ? Farben.textDeaktiviert
                                     : art === "akzent" ? (maus.pressed ? Farben.textAufAkzentSekundaer : Farben.textAufAkzent)
                                     : (maus.pressed && art === "standard" ? Farben.textSekundaer : Farben.text)

    Rectangle {
        id: flaeche
        anchors.fill: parent
        radius: knopf.radius
        color: {
            if (knopf.art === "akzent") {
                return !knopf.enabled ? Farben.controlStarkDeaktiviert
                     : maus.pressed ? Farben.akzentFlaecheGedrueckt
                     : maus.containsMouse ? Farben.akzentFlaecheHover : Farben.akzentFlaeche;
            }
            if (knopf.art === "subtil") {
                return maus.pressed ? Farben.subtilGedrueckt
                     : (maus.containsMouse || knopf.aktiv) ? Farben.subtilHover : "transparent";
            }
            return !knopf.enabled ? Farben.controlFillDeaktiviert
                 : maus.pressed ? Farben.controlFillGedrueckt
                 : maus.containsMouse ? Farben.controlFillHover : Farben.controlFill;
        }
        border.width: knopf.art === "subtil" ? 0 : 1
        border.color: knopf.art === "akzent" ? Farben.akzentRand : Farben.controlRand
        Behavior on color {
            ColorAnimation { duration: 83 }
        }
    }
    // Unterkante des Elevation-Rands (WinUI ControlElevationBorder)
    Rectangle {
        visible: knopf.art !== "subtil" && !maus.pressed && knopf.enabled
        x: knopf.radius
        width: parent.width - 2 * knopf.radius
        y: parent.height - 1
        height: 1
        color: knopf.art === "akzent" ? Farben.akzentRandUnten : Farben.controlRandUnten
    }
    // Fokusrahmen (2 px außen, 1.7), nur wenn der Fokus per Tastatur kam
    property bool tastaturFokus: false
    onActiveFocusChanged: if (!activeFocus) tastaturFokus = false
    Rectangle {
        visible: knopf.activeFocus && knopf.tastaturFokus
        anchors.fill: parent
        anchors.margins: -3
        radius: knopf.radius + 3
        color: "transparent"
        border.width: 2
        border.color: Farben.dunkel ? "#FFFFFF" : "#E4000000"
    }

    Row {
        id: inhalt
        anchors.centerIn: parent
        spacing: 8
        layoutDirection: knopf.symbolRechts ? Qt.RightToLeft : Qt.LeftToRight

        Kirigami.Icon {
            visible: knopf.hatSymbol
            anchors.verticalCenter: parent.verticalCenter
            width: knopf.symbolGroesse
            height: knopf.symbolGroesse
            source: knopf.symbol
            isMask: knopf.symbolMaske
            color: knopf.textFarbe
        }
        Text {
            visible: knopf.text.length > 0
            anchors.verticalCenter: parent.verticalCenter
            text: knopf.text
            color: knopf.textFarbe
            font.family: Farben.schrift
            font.pixelSize: knopf.schriftGroesse
            font.weight: knopf.fett ? Font.DemiBold : Font.Normal
            renderType: Text.NativeRendering
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: knopf.tooltip
        active: knopf.tooltip.length > 0
        interactive: false

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.ArrowCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    knopf.rightClicked();
                } else {
                    knopf.clicked();
                }
            }
        }
    }
}
