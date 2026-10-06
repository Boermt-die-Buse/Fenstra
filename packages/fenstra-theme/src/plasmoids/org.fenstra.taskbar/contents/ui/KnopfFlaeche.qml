/*
    Fenstra-Taskleiste: Hover-/Aktiv-Fläche eines Knopfs (40×40, Radius 4, mittig).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Rectangle {
    id: flaeche

    property bool hover: false
    property bool gedrueckt: false
    property bool aktiv: false
    property color sonderFarbe: "transparent"   // z. B. Aufmerksamkeit

    width: 40
    height: 40
    radius: 4
    anchors.centerIn: parent
    color: sonderFarbe.a > 0 ? sonderFarbe
         : gedrueckt ? kicker.flaecheGedrueckt
         : aktiv ? kicker.flaecheAktiv
         : hover ? kicker.flaecheHover
         : "transparent"
    border.width: (hover || aktiv || gedrueckt) ? 1 : 0
    border.color: kicker.randHover

    Behavior on color {
        ColorAnimation { duration: 83 }
    }
}
