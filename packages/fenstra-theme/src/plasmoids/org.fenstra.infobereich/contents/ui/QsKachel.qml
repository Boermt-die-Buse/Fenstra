/*
    Fenstra-Schnelleinstellungen: Kachel (docs/windows11-referenz.md 5.3): Knopf 96×48,
    Radius 4, Symbol 16, Beschriftung 12 px darunter (bis zwei Zeilen).
    an: Akzentfläche, Symbol in Textfarbe auf Akzent; aus: Steuerelementfläche mit Rand.
    geteilt (WLAN, Bluetooth): links schalten, rechts „>“ zur Unterseite.
    Im Bearbeiten-Modus: Lösen-Abzeichen oben rechts, Klick schaltet nicht.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.fenstra.shell

Item {
    id: kachel

    property string text: ""
    property string symbol: ""
    property bool an: false
    property bool geteilt: false
    property bool pfeil: false           // ganze Kachel öffnet eine Unterseite (Barrierefreiheit)
    property bool bearbeiten: false

    signal umschalten()
    signal seiteOeffnen()
    signal loesen()

    width: 96
    height: 84

    readonly property color vorder: !enabled ? Farben.textDeaktiviert : (an ? Farben.textAufAkzent : Farben.text)

    Item {
        id: knopf
        width: 96
        height: 48

        Rectangle {
            id: flaeche
            anchors.fill: parent
            radius: 4
            color: {
                if (!kachel.enabled) {
                    return Farben.controlFillDeaktiviert;
                }
                const gedrueckt = linksMaus.pressed || rechtsMaus.pressed;
                const hover = linksMaus.containsMouse || rechtsMaus.containsMouse;
                if (kachel.an) {
                    return gedrueckt ? Farben.akzentFlaecheGedrueckt : hover ? Farben.akzentFlaecheHover : Farben.akzentFlaeche;
                }
                return gedrueckt ? Farben.controlFillGedrueckt : hover ? Farben.controlFillHover : Farben.controlFill;
            }
            border.width: 1
            border.color: kachel.an ? Farben.akzentRand : Farben.controlRand
            Behavior on color {
                ColorAnimation { duration: 83 }
            }
        }
        Rectangle {
            // Unterkante (Elevation)
            visible: kachel.enabled && !linksMaus.pressed && !rechtsMaus.pressed
            x: 4
            width: parent.width - 8
            y: parent.height - 1
            height: 1
            color: kachel.an ? Farben.akzentRandUnten : Farben.controlRandUnten
        }

        // Symbol (bei geteilten Kacheln im linken Teil)
        Kirigami.Icon {
            readonly property real bereich: kachel.geteilt ? 60 : parent.width
            x: (bereich - width) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            source: kachel.symbol
            isMask: true
            color: kachel.vorder
        }
        // Trenner und Pfeil der geteilten Kachel
        Rectangle {
            visible: kachel.geteilt
            x: 60
            y: 12
            width: 1
            height: parent.height - 24
            color: kachel.an ? Farben.mitAlpha(Farben.textAufAkzent, 0.3) : Farben.controlRandUnten
        }
        Kirigami.Icon {
            visible: kachel.geteilt || kachel.pfeil
            x: kachel.geteilt ? 60 + (36 - width) / 2 : parent.width - width - 10
            anchors.verticalCenter: parent.verticalCenter
            width: 12
            height: 12
            source: "arrow-right"
            isMask: true
            color: kachel.vorder
        }

        MouseArea {
            id: linksMaus
            width: kachel.geteilt ? 60 : parent.width
            height: parent.height
            hoverEnabled: true
            enabled: kachel.enabled && !kachel.bearbeiten
            onClicked: kachel.pfeil ? kachel.seiteOeffnen() : kachel.umschalten()
        }
        MouseArea {
            id: rechtsMaus
            visible: kachel.geteilt
            x: 60
            width: parent.width - 60
            height: parent.height
            hoverEnabled: true
            enabled: kachel.enabled && !kachel.bearbeiten
            onClicked: kachel.seiteOeffnen()
        }
    }

    WinText {
        anchors.top: knopf.bottom
        anchors.topMargin: 6
        x: -4
        width: parent.width + 8
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        stil: "caption"
        text: kachel.text
        enabled: kachel.enabled
    }

    // Lösen-Abzeichen (Bearbeiten)
    Rectangle {
        visible: kachel.bearbeiten
        x: knopf.width - width / 2 - 2
        y: -width / 2 + 2
        width: 20
        height: 20
        radius: 10
        color: Farben.controlFest
        border.width: 1
        border.color: Farben.controlRandUnten
        Kirigami.Icon {
            anchors.centerIn: parent
            width: 12
            height: 12
            source: "window-unpin"
            isMask: true
            color: Farben.text
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            onClicked: kachel.loesen()
        }
    }
}
