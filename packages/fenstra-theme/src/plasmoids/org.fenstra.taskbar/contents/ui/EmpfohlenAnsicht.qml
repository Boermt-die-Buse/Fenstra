/*
    Fenstra-Startmenü: „Mehr“ in Empfohlen – alle Empfehlungen in zwei Spalten, Kopf
    „Empfohlen“ mit „< Zurück“.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.fenstra.shell

Item {
    id: mehr

    signal zurueck()

    WinText {
        x: 52
        y: 28
        height: 24
        text: "Empfohlen"
        stil: "bodyStrong"
    }
    WinKnopf {
        anchors.right: parent.right
        anchors.rightMargin: 634 - 582
        y: 28
        height: 24
        innenabstand: 8
        schriftGroesse: 12
        text: "Zurück"
        symbol: "arrow-left"
        symbolGroesse: 12
        onClicked: mehr.zurueck()
    }

    GridView {
        id: raster
        x: 29
        y: 64
        width: 576
        height: parent.height - 64 - 8
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        cellWidth: 288
        cellHeight: 52
        model: empfehlungen.liste
        delegate: EmpfohlenEintrag {
            width: 288
            height: 52
        }
    }
    WinBildlauf {
        flick: raster
        x: raster.x + raster.width
        y: raster.y
        height: raster.height
    }
}
