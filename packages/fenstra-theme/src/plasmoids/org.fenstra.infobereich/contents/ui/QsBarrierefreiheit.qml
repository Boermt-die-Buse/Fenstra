/*
    Fenstra-Schnelleinstellungen: Unterseite „Barrierefreiheit“ mit Schaltern wie Windows 11:
    Lupe (KWin-Zoom), Farbfilter (KWin-Effekt), Sprachausgabe (Orca), Einrastfunktion.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.fenstra.shell

Column {
    spacing: 0

    Repeater {
        model: [
            {text: "Lupe", symbol: "zoom-in", an: daten.lupeAn, aktion: () => daten.lupeUmschalten()},
            {text: "Farbfilter", symbol: "preferences-desktop-color", an: daten.farbfilterAn, aktion: () => daten.farbfilterUmschalten()},
            {text: "Sprachausgabe", symbol: "audio-speakers", an: daten.sprachausgabeAn, aktion: () => daten.sprachausgabeUmschalten()},
            {text: "Einrastfunktion", symbol: "input-keyboard", an: daten.einrastenAn, aktion: () => daten.einrastenUmschalten()}
        ]
        delegate: Item {
            required property var modelData
            width: parent.width
            height: 48
            Kirigami.Icon {
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                source: modelData.symbol
                isMask: true
                color: Farben.text
            }
            WinText {
                x: 40
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.text
            }
            WinSchalter {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                checked: modelData.an
                onToggled: modelData.aktion()
            }
        }
    }
}
