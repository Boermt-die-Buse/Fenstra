/*
    Fenstra-Widgets: Kalender – Wochentag, großes Tagesdatum, Monat; „groß“ zusätzlich ein
    kleiner Monatsüberblick.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.fenstra.shell

Item {
    id: k

    property date heute: new Date()
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: k.heute = new Date()
    }

    Column {
        spacing: 0
        WinText {
            stil: "caption"
            color: Farben.akzentText
            font.weight: Font.DemiBold
            text: k.heute.toLocaleDateString(Qt.locale(), "dddd")
        }
        WinText {
            font.pixelSize: 44
            font.weight: Font.DemiBold
            height: 52
            text: k.heute.getDate()
        }
        WinText {
            stil: "caption"
            sekundaer: true
            text: k.heute.toLocaleDateString(Qt.locale(), "MMMM yyyy")
        }
        Item { width: 1; height: 8 }
        WinText {
            stil: "caption"
            sekundaer: true
            text: "Keine Termine heute"
        }
    }

    // Monatsüberblick (nur groß)
    Grid {
        visible: k.parent && k.parent.groesse === "gross"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        columns: 7
        Repeater {
            model: 42
            delegate: WinText {
                required property int index
                readonly property date datum: {
                    const e = new Date(k.heute.getFullYear(), k.heute.getMonth(), 1);
                    return new Date(e.getFullYear(), e.getMonth(), 1 - (e.getDay() + 6) % 7 + index);
                }
                width: 26
                height: 22
                horizontalAlignment: Text.AlignHCenter
                stil: "caption"
                text: datum.getDate()
                color: datum.toDateString() === k.heute.toDateString() ? Farben.akzentText
                     : (datum.getMonth() === k.heute.getMonth() ? Farben.text : Farben.textTertiaer)
                font.weight: datum.toDateString() === k.heute.toDateString() ? Font.DemiBold : Font.Normal
            }
        }
    }
}
