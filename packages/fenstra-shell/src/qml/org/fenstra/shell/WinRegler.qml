/*
    Fenstra-Shell: Schieberegler im WinUI-Aussehen (docs/windows11-referenz.md 2.6).
    Höhe 32, Spur 4 px Radius 2 (Rest ControlStrong, gefüllter Teil Akzent), Daumen außen 18
    (ControlSolid + 1-px-Rand), innerer Akzentpunkt Ø 12 / 14 (Hover) / 10 (gedrückt).
    Beim Ziehen zeigt ein Tooltip den Wert. Mausrad ändert in Schritten von 2.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Item {
    id: regler

    property real from: 0
    property real to: 100
    property real value: 0
    property real stepSize: 1
    property bool zeigeWert: true
    readonly property alias gedrueckt: maus.pressed
    readonly property real anteil: to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    signal moved(real value)

    implicitWidth: 200
    implicitHeight: 32
    activeFocusOnTab: true

    function setze(v) {
        let w = Math.max(from, Math.min(to, v));
        if (stepSize > 0) {
            w = Math.round((w - from) / stepSize) * stepSize + from;
        }
        if (w !== value) {
            value = w;
            moved(w);
        }
    }
    Keys.onLeftPressed: setze(value - stepSize)
    Keys.onRightPressed: setze(value + stepSize)
    Keys.onDownPressed: setze(value - stepSize)
    Keys.onUpPressed: setze(value + stepSize)

    readonly property real spurLinks: 9
    readonly property real spurBreite: width - 18

    // Spur
    Rectangle {
        x: regler.spurLinks
        width: regler.spurBreite
        height: 4
        radius: 2
        anchors.verticalCenter: parent.verticalCenter
        color: regler.enabled ? Farben.controlStark : Farben.controlStarkDeaktiviert
    }
    Rectangle {
        x: regler.spurLinks
        width: regler.spurBreite * regler.anteil
        height: 4
        radius: 2
        anchors.verticalCenter: parent.verticalCenter
        color: regler.enabled ? Farben.akzentFlaeche : Farben.controlStarkDeaktiviert
    }

    // Daumen
    Rectangle {
        id: daumen
        width: 18
        height: 18
        radius: 9
        x: regler.spurLinks + regler.spurBreite * regler.anteil - width / 2
        anchors.verticalCenter: parent.verticalCenter
        color: Farben.controlFest
        border.width: 1
        border.color: Farben.dunkel ? "#23000000" : "#1A000000"

        Rectangle {
            readonly property real d: maus.pressed ? 10 : (daumenHover.hovered ? 14 : 12)
            anchors.centerIn: parent
            width: d
            height: d
            radius: d / 2
            color: regler.enabled ? Farben.akzentFlaeche : Farben.controlStarkDeaktiviert
            Behavior on width {
                NumberAnimation { duration: 83 }
            }
            Behavior on height {
                NumberAnimation { duration: 83 }
            }
        }
        HoverHandler {
            id: daumenHover
        }
    }

    // Wert beim Ziehen
    Rectangle {
        visible: regler.zeigeWert && maus.pressed
        width: wertText.implicitWidth + 18
        height: wertText.implicitHeight + 12
        radius: 4
        x: daumen.x + daumen.width / 2 - width / 2
        y: daumen.y - height - 8
        color: Farben.dunkel ? "#2C2C2C" : "#F9F9F9"
        border.width: 1
        border.color: Farben.dunkel ? "#33000000" : "#1A000000"
        WinText {
            id: wertText
            anchors.centerIn: parent
            stil: "caption"
            text: Math.round(regler.value)
        }
    }

    MouseArea {
        id: maus
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        function wertAus(mx) {
            const a = Math.max(0, Math.min(1, (mx - regler.spurLinks) / regler.spurBreite));
            return regler.from + a * (regler.to - regler.from);
        }
        onPressed: mouse => {
            regler.forceActiveFocus();
            regler.setze(wertAus(mouse.x));
        }
        onPositionChanged: mouse => {
            if (pressed) {
                regler.setze(wertAus(mouse.x));
            }
        }
        onWheel: wheel => regler.setze(regler.value + (wheel.angleDelta.y > 0 ? 2 : -2) * Math.max(1, regler.stepSize))
    }
}
