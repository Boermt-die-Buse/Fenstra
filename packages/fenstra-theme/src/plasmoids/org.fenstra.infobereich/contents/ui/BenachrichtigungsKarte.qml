/*
    Fenstra-Benachrichtigungen: Inhalt einer Meldung (Toast und Zentrale), Windows-11-Aufbau:
    optional Bild/Symbol links (48), Titel 14 Semibold, Text 14 (bis 4 Zeilen), Aktionen als
    gleich breite Schaltflächen darunter.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.fenstra.shell

ColumnLayout {
    id: karte

    property string titel: ""
    property string text: ""
    property var bild: null            // QImage aus dem Modell
    property string symbolName: ""
    property var aktionNamen: []
    property var aktionTexte: []
    signal aktion(string name)

    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        Item {
            visible: karte.bild !== null && karte.bild !== undefined || karte.symbolName.length > 0
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            Layout.alignment: Qt.AlignTop
            Kirigami.Icon {
                anchors.fill: parent
                source: (karte.bild !== null && karte.bild !== undefined) ? karte.bild : karte.symbolName
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 2
            WinText {
                Layout.fillWidth: true
                visible: text.length > 0
                text: karte.titel
                stil: "bodyStrong"
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }
            WinText {
                Layout.fillWidth: true
                visible: text.length > 0
                text: karte.text
                textFormat: Text.StyledText
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                sekundaer: karte.titel.length > 0
            }
        }
    }

    RowLayout {
        visible: karte.aktionTexte.length > 0
        Layout.fillWidth: true
        spacing: 8
        Repeater {
            model: karte.aktionTexte
            delegate: WinKnopf {
                required property int index
                required property string modelData
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                text: modelData
                onClicked: karte.aktion(karte.aktionNamen[index])
            }
        }
    }
}
