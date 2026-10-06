/*
    Fenstra-Widgets: Karte eines Widgets (Radius 8, Kartenfläche, Rand 1 px), Kopf mit Symbol 16,
    Titel 12 px Semibold und „…“ (Größe ändern, Widget entfernen). Inhalt aus WidgetXyz.qml.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.fenstra.shell

Rectangle {
    id: karte

    property string name: ""
    property string groesse: "klein"
    property string titel: ""
    property string symbol: ""
    property string datei: ""

    radius: 8
    color: Farben.karte
    border.width: 1
    border.color: Farben.karteRand

    Kirigami.Icon {
        id: kopfSymbol
        x: 14
        y: 12
        width: 16
        height: 16
        source: karte.symbol
    }
    WinText {
        anchors.left: kopfSymbol.right
        anchors.leftMargin: 8
        anchors.verticalCenter: kopfSymbol.verticalCenter
        stil: "caption"
        font.weight: Font.DemiBold
        text: karte.titel
    }
    WinKnopf {
        id: mehr
        anchors.right: parent.right
        anchors.rightMargin: 6
        y: 6
        width: 28
        height: 28
        art: "subtil"
        symbol: "overflow-menu"
        symbolGroesse: 12
        tooltip: "Weitere Optionen"
        onClicked: {
            const g = karte.groesse;
            menue.zeigen(mehr, [
                {text: "Klein", symbol: g === "klein" ? "dialog-ok" : "", aktion: () => board.groesseSetzen(karte.name, "klein")},
                {text: "Mittel", symbol: g === "mittel" ? "dialog-ok" : "", aktion: () => board.groesseSetzen(karte.name, "mittel")},
                {text: "Groß", symbol: g === "gross" ? "dialog-ok" : "", aktion: () => board.groesseSetzen(karte.name, "gross")},
                {trenner: true},
                {text: "Widget entfernen", symbol: "list-remove", aktion: () => board.entfernen(karte.name)}
            ]);
        }
    }

    Loader {
        x: 14
        y: 36
        width: parent.width - 28
        height: parent.height - 36 - 12
        source: karte.datei
        property string groesse: karte.groesse
    }
}
