/*
    Fenstra-Shell: dunklere Leiste am unteren Rand eines Flyouts (Startmenü, Schnell-
    einstellungen): reicht bis an den 1-px-Rand des Plasma-Hintergrunds, untere Ecken mit
    Radius 7 (8 minus Rand), Trennlinie oben. Elternelement ist das mainItem des Flyouts.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Rectangle {
    id: fuss

    property int rand: 4            // Innenabstand des Flyout-Hintergrunds

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.leftMargin: -(rand - 1)
    anchors.rightMargin: -(rand - 1)
    anchors.bottomMargin: -(rand - 1)
    bottomLeftRadius: 7
    bottomRightRadius: 7
    color: Farben.fussleiste

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Farben.fussRand
    }
}
