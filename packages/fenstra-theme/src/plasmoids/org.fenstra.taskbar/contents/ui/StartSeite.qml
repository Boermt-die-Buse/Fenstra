/*
    Fenstra-Startmenü: Startseite mit „Angeheftet“ (Seiten, Ordner) und „Empfohlen“.
    Koordinaten relativ zur Seite (Seite beginnt 64 px unter der Oberkante des mainItem).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.fenstra.shell

Item {
    id: seite

    readonly property bool ordnerOffen: ordnerAnsicht.visible
    signal alleZeigen()
    signal mehrZeigen()

    function zuruecksetzen() {
        raster.zuruecksetzen();
        ordnerAnsicht.visible = false;
    }
    function ordnerSchliessen() {
        ordnerAnsicht.schliessen();
    }
    function auswahlBewegen(dx, dy) {
        raster.auswahlBewegen(dx, dy);
    }
    function auswahlStarten() {
        raster.auswahlStarten();
    }

    // ---------------- Angeheftet ----------------
    WinText {
        x: 52
        y: 28
        height: 24
        text: "Angeheftet"
        stil: "bodyStrong"
    }
    WinKnopf {
        id: alleKnopf
        anchors.right: parent.right
        anchors.rightMargin: 634 - 582
        y: 28
        height: 24
        innenabstand: 8
        schriftGroesse: 12
        text: "Alle"
        symbol: "arrow-right"
        symbolGroesse: 12
        symbolRechts: true
        onClicked: seite.alleZeigen()
    }

    StartRaster {
        id: raster
        x: 29
        y: 64
        onOrdnerOeffnen: (oi) => ordnerAnsicht.oeffnen(oi)
    }

    // Seitenpunkte rechts (WinUI PipsPager senkrecht): nur bei mehr als einer Seite
    Column {
        x: 612
        anchors.verticalCenter: raster.verticalCenter
        visible: raster.seiten > 1
        Repeater {
            model: raster.seiten
            delegate: Item {
                required property int index
                width: 12
                height: 12
                Rectangle {
                    anchors.centerIn: parent
                    readonly property bool aktuell: index === raster.seite
                    width: aktuell ? 6 : (punktMaus.containsMouse ? 5 : 4)
                    height: width
                    radius: width / 2
                    color: aktuell ? Farben.controlStark : Farben.textTertiaer
                }
                MouseArea {
                    id: punktMaus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: raster.seite = index
                }
            }
        }
    }

    // ---------------- Empfohlen ----------------
    WinText {
        x: 52
        y: 340
        height: 24
        text: "Empfohlen"
        stil: "bodyStrong"
    }
    WinKnopf {
        anchors.right: parent.right
        anchors.rightMargin: 634 - 582
        y: 340
        height: 24
        innenabstand: 8
        schriftGroesse: 12
        text: "Mehr"
        symbol: "arrow-right"
        symbolGroesse: 12
        symbolRechts: true
        onClicked: seite.mehrZeigen()
    }

    Grid {
        id: empfohlenRaster
        x: 29
        y: 376
        columns: 2
        Repeater {
            model: empfehlungen.liste.slice(0, 6)
            delegate: EmpfohlenEintrag {
                width: 288
                height: 52
            }
        }
    }
    WinText {
        visible: empfehlungen.liste.length === 0
        x: 52
        y: 380
        width: 530
        wrapMode: Text.WordWrap
        stil: "caption"
        sekundaer: true
        text: "Je mehr Sie Ihr Gerät verwenden, desto mehr neue Apps und zuletzt verwendete Dateien werden hier angezeigt."
    }

    // ---------------- Ordner (Einblendung über dem Raster) ----------------
    StartOrdnerAnsicht {
        id: ordnerAnsicht
        anchors.fill: parent
        visible: false
    }
}
