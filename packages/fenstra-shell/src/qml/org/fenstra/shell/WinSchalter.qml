/*
    Fenstra-Shell: Umschalter im WinUI-Aussehen (docs/windows11-referenz.md 2.5).
    Spur 40×20 Radius 10; aus: Rand ControlStrong, Knopf Ø 12 (Hover 14);
    ein: Spur Akzent, Knopf in Textfarbe auf Akzent. Knopf gleitet in 167 ms.
    Optional Beschriftung rechts ("Ein"/"Aus" oder eigener Text).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Item {
    id: schalter

    property bool checked: false
    property string text: ""          // leer: keine Beschriftung
    readonly property alias hovered: maus.containsMouse

    signal toggled()

    implicitWidth: 40 + (beschriftung.visible ? 10 + beschriftung.implicitWidth : 0)
    implicitHeight: 20
    activeFocusOnTab: true
    Keys.onSpacePressed: { checked = !checked; toggled(); }

    Rectangle {
        id: spur
        width: 40
        height: 20
        radius: 10
        anchors.verticalCenter: parent.verticalCenter
        color: !schalter.enabled ? (schalter.checked ? Farben.controlStarkDeaktiviert : "transparent")
             : schalter.checked ? (maus.pressed ? Farben.akzentFlaecheGedrueckt : maus.containsMouse ? Farben.akzentFlaecheHover : Farben.akzentFlaeche)
             : (maus.pressed ? Farben.controlAltHover : maus.containsMouse ? Farben.controlAltHover : Farben.controlAlt)
        border.width: schalter.checked ? 0 : 1
        border.color: schalter.enabled ? Farben.controlStark : Farben.controlStarkDeaktiviert
        Behavior on color {
            ColorAnimation { duration: 83 }
        }

        Rectangle {
            id: knopfPunkt
            readonly property real d: maus.pressed ? 14 : (maus.containsMouse ? 14 : 12)
            width: maus.pressed ? 17 : d
            height: d
            radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            x: schalter.checked ? spur.width - width - (20 - height) / 2 : (20 - height) / 2
            color: !schalter.enabled ? Farben.textDeaktiviert
                 : schalter.checked ? Farben.textAufAkzent : Farben.controlStark
            Behavior on x {
                NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                NumberAnimation { duration: 83 }
            }
            Behavior on height {
                NumberAnimation { duration: 83 }
            }
        }
    }

    WinText {
        id: beschriftung
        visible: schalter.text.length > 0
        anchors.left: spur.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: schalter.text
        enabled: schalter.enabled
    }

    MouseArea {
        id: maus
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            schalter.checked = !schalter.checked;
            schalter.toggled();
        }
    }
}
