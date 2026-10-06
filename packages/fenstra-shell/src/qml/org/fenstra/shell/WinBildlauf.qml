/*
    Fenstra-Shell: überlagernde Bildlaufleiste wie WinUI (docs/windows11-referenz.md 2.8):
    eingeklappt eine 2-px-Linie, beim Hover 6 px breit (167 ms), blendet nach 1,5 s Ruhe aus.
    Liegt neben (nicht in) dem Flickable: x/y/height vom Aufrufer setzen.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Item {
    id: leiste

    property Flickable flick: null
    readonly property bool noetig: flick !== null && flick.contentHeight > flick.height + 1
    readonly property bool breit: hover.hovered || maus.pressed
    property bool aktiv: false

    width: 12
    visible: noetig

    Connections {
        target: leiste.flick
        function onContentYChanged() {
            leiste.aktiv = true;
            ruhe.restart();
        }
    }
    Timer {
        id: ruhe
        interval: 1500
        onTriggered: leiste.aktiv = false
    }

    Rectangle {
        id: daumen
        readonly property real anteil: leiste.flick ? leiste.flick.visibleArea.heightRatio : 1
        readonly property real lage: leiste.flick ? leiste.flick.visibleArea.yPosition : 0
        width: leiste.breit ? 6 : 2
        radius: width / 2
        x: leiste.width - width - (leiste.breit ? 3 : 2)
        height: Math.max(30, anteil * leiste.height)
        y: Math.max(0, Math.min(leiste.height - height, lage * leiste.height))
        color: Farben.controlStark
        opacity: leiste.aktiv || leiste.breit || hover.hovered ? 1 : 0
        Behavior on width {
            NumberAnimation { duration: 167 }
        }
        Behavior on opacity {
            NumberAnimation { duration: 167 }
        }
    }

    HoverHandler {
        id: hover
    }
    MouseArea {
        id: maus
        anchors.fill: parent
        property real startY: 0
        property real startInhalt: 0
        onPressed: mouse => {
            startY = mouse.y;
            startInhalt = leiste.flick.contentY;
            if (mouse.y < daumen.y || mouse.y > daumen.y + daumen.height) {
                // Klick neben den Daumen: seitenweise
                const richtung = mouse.y < daumen.y ? -1 : 1;
                leiste.flick.contentY = Math.max(0, Math.min(leiste.flick.contentHeight - leiste.flick.height,
                                                             leiste.flick.contentY + richtung * leiste.flick.height));
                startInhalt = leiste.flick.contentY;
            }
        }
        onPositionChanged: mouse => {
            if (pressed) {
                const proPixel = leiste.flick.contentHeight / leiste.height;
                leiste.flick.contentY = Math.max(0, Math.min(leiste.flick.contentHeight - leiste.flick.height,
                                                             startInhalt + (mouse.y - startY) * proPixel));
            }
        }
    }
}
