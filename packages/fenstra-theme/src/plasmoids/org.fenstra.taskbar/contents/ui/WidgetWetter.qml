/*
    Fenstra-Widgets: Wetter – Ort, farbiges Symbol, Temperatur, Zustand; ab „mittel“ zusätzlich
    die Vorhersage der nächsten Tage. Daten aus der Plasma-Wetter-Engine (Quelle wie beim
    Widgets-Knopf: Taskleisteneinstellungen → Wetterquelle).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support
import org.fenstra.shell

Item {
    id: w

    readonly property string quelle: Plasmoid.configuration.weatherSource || ""
    readonly property var d: quelle.length > 0 ? wetter.data[quelle] : undefined
    readonly property bool da: d !== undefined && d["Temperature"] !== undefined && d["Temperature"] !== ""
    readonly property bool breit: parent && parent.groesse !== "klein"

    P5Support.DataSource {
        id: wetter
        engine: "weather"
        connectedSources: w.quelle.length > 0 ? [w.quelle] : []
        interval: 30 * 60 * 1000
    }

    // Vorhersage: "Short Forecast Day N" = "Tag|Symbol|Zusammenfassung|Hoch|Tief|…"
    readonly property var tage: {
        const l = [];
        if (!da) {
            return l;
        }
        const n = Number(d["Total Weather Days"] || 0);
        for (let i = 0; i < Math.min(n, 5); ++i) {
            const t = String(d["Short Forecast Day " + i] || "").split("|");
            if (t.length >= 5) {
                l.push({tag: t[0], symbol: t[1], hoch: t[3], tief: t[4]});
            }
        }
        return l;
    }

    WinText {
        visible: !w.da
        width: parent.width
        wrapMode: Text.WordWrap
        stil: "caption"
        sekundaer: true
        text: w.quelle.length === 0 ? "Wetterort in den Taskleisteneinstellungen festlegen." : "Wetterdaten werden geladen …"
    }

    Column {
        visible: w.da
        width: w.breit ? parent.width / 2 : parent.width
        spacing: 2
        WinText {
            width: parent.width
            stil: "caption"
            sekundaer: true
            text: w.da ? String(w.d["Place"] || "").split(",")[0].replace(/\(.*\)/, "").trim() : ""
        }
        Row {
            spacing: 8
            Kirigami.Icon {
                width: 48
                height: 48
                source: w.da ? (w.d["Condition Icon"] || "weather-none-available") : ""
            }
            WinText {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 32
                font.weight: Font.DemiBold
                text: w.da ? Math.round(Number(w.d["Temperature"])) + "°" : ""
            }
        }
        WinText {
            width: parent.width
            text: w.da ? (w.d["Current Conditions"] || "") : ""
        }
    }

    Row {
        visible: w.breit && w.da
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 6
        Repeater {
            model: w.tage.slice(0, 4)
            delegate: Column {
                required property var modelData
                width: 36
                spacing: 2
                WinText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    stil: "caption"
                    sekundaer: true
                    text: modelData.tag
                }
                Kirigami.Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 24
                    height: 24
                    source: modelData.symbol
                }
                WinText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    stil: "caption"
                    text: modelData.hoch !== "N/U" && modelData.hoch !== "" ? Math.round(Number(modelData.hoch)) + "°" : ""
                }
                WinText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    stil: "caption"
                    sekundaer: true
                    text: modelData.tief !== "N/U" && modelData.tief !== "" ? Math.round(Number(modelData.tief)) + "°" : ""
                }
            }
        }
    }

    // einmalig die gelieferten Schlüssel ins Journal schreiben (Fehlersuche Vorhersageformat)
    onDaChanged: if (da && tage.length === 0) console.info("Fenstra-Wetter Schlüssel:", Object.keys(d).join(", "))
}
