/*
    Fenstra-Infobereich: Hover-Fläche (Höhe 40, Radius 4).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Rectangle {
    property bool hover: false
    property bool gedrueckt: false
    property bool aktiv: false

    height: 40
    radius: 4
    anchors.verticalCenter: parent.verticalCenter
    color: gedrueckt ? info.flaecheGedrueckt : aktiv ? info.flaecheAktiv : hover ? info.flaecheHover : "transparent"
    border.width: (hover || aktiv || gedrueckt) ? 1 : 0
    border.color: info.randHover
    Behavior on color {
        ColorAnimation { duration: 83 }
    }
}
