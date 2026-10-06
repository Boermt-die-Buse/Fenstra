/*
    Fenstra-Taskleiste: Widgets-Knopf ganz links (Windows 11 4.2). Mit Wetterdaten:
    Wettersymbol 24 + Temperatur und Kurztext (zwei Zeilen, 12 px); ohne: Widgets-Symbol.
    Wetter kommt aus der Plasma-Wetter-Engine (Quelle in den Taskleisteneinstellungen).
    Klick, Hover (500 ms) und Win+W öffnen das Widgets-Board (WidgetsBoard.qml).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

Item {
    id: knopf

    readonly property string quelle: Plasmoid.configuration.weatherSource || ""
    readonly property var daten: quelle.length > 0 ? wetter.data[quelle] : undefined
    readonly property bool hatWetter: daten !== undefined && daten["Temperature"] !== undefined
                                      && daten["Temperature"] !== ""
    readonly property string temperatur: hatWetter ? Math.round(Number(daten["Temperature"])) + " °C" : ""
    readonly property string kurztext: hatWetter ? (daten["Current Conditions"] || textZuSymbol(daten["Condition Icon"] || "")) : ""

    // Kurztext aus dem Wettersymbol, falls die Quelle keinen liefert (z. B. DWD)
    function textZuSymbol(s) {
        const tabelle = [
            ["freezing", "Gefrierender Regen"], ["hail", "Hagel"], ["snow-rain", "Schneeregen"],
            ["snow", "Schnee"], ["storm", "Gewitter"], ["showers-scattered", "Vereinzelt Schauer"],
            ["showers", "Regenschauer"], ["rain", "Regen"], ["fog", "Nebel"], ["mist", "Dunst"],
            ["many-clouds", "Stark bewölkt"], ["overcast", "Bedeckt"], ["few-clouds", "Leicht bewölkt"],
            ["clouds", "Bewölkt"], ["clear-night", "Klar"], ["clear", "Sonnig"]
        ];
        for (let i = 0; i < tabelle.length; ++i) {
            if (s.indexOf(tabelle[i][0]) >= 0) {
                return tabelle[i][1];
            }
        }
        return "";
    }
    readonly property string wetterSymbol: hatWetter ? (daten["Condition Icon"] || "weather-none-available") : ""

    width: hatWetter ? Math.max(inhalt.implicitWidth + 16, 44) : 44

    P5Support.DataSource {
        id: wetter
        engine: "weather"
        connectedSources: knopf.quelle.length > 0 ? [knopf.quelle] : []
        interval: 30 * 60 * 1000
    }

    KnopfFlaeche {
        anchors.centerIn: undefined
        anchors.verticalCenter: parent.verticalCenter
        x: 2
        width: parent.width - 4
        hover: maus.containsMouse
        gedrueckt: maus.pressed
    }

    Row {
        id: inhalt
        anchors.centerIn: parent
        spacing: 8

        // farbiges Wettersymbol aus dem Symbolthema (M4), ohne Wetter das Widgets-Symbol
        Kirigami.Icon {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24
            source: knopf.hatWetter ? knopf.wetterSymbol : Qt.resolvedUrl("../icons/widgets.svg")
            isMask: !knopf.hatWetter
            color: kicker.akzentStufe(kicker.akzent, kicker.dunkel ? 2 : 0)
        }
        Column {
            visible: knopf.hatWetter
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: knopf.temperatur
                color: kicker.textFarbe
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: 12
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }
            Text {
                text: knopf.kurztext
                color: kicker.textSekundaer
                font.family: Kirigami.Theme.defaultFont.family
                font.pixelSize: 12
                elide: Text.ElideRight
                width: Math.min(implicitWidth, 110)
                renderType: Text.NativeRendering
            }
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: knopf.hatWetter ? knopf.kurztext : "Widgets"
        subText: knopf.hatWetter ? knopf.temperatur : ""
        location: PlasmaCore.Types.BottomEdge
        interactive: false

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            // Klick öffnet/schließt das Widgets-Board; Hover (500 ms) öffnet es wie Windows 11
            property bool warOffen: false
            onPressed: warOffen = kicker.widgetsOffen
            onClicked: kicker.widgetsOffen = !warOffen
            onContainsMouseChanged: containsMouse ? hoverOeffnen.restart() : hoverOeffnen.stop()
            Timer {
                id: hoverOeffnen
                interval: 500
                onTriggered: kicker.widgetsOffen = true
            }
        }
    }
}
