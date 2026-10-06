/*
    Fenstra-Startmenü: Eintrag in „Empfohlen“: Symbol 32, Titel 12 px, Untertitel 12 px sekundär
    („Kürzlich hinzugefügt“, „Vor 2 Std.“ …). Rechtsklick: „Dateispeicherort öffnen“,
    „Aus Liste entfernen“.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.fenstra.shell

WinListenEintrag {
    id: eintrag

    required property var modelData

    symbol: modelData.symbol
    symbolGroesse: 32
    titel: modelData.titel
    titelGroesse: 12
    untertitel: empfehlungen.untertitel(modelData)
    linkerAbstand: 16

    onClicked: menu.starten(modelData.modell, modelData.zeile)
    onRightClicked: (mx, my) => {
        const e = eintrag.modelData;
        const liste = [];
        if (e.art === "datei") {
            liste.push({text: "Dateispeicherort öffnen", symbol: "folder-open", aktion: () => {
                e.modell.trigger(e.zeile, "openParentFolder", null);
                menu.schliessen();
            }});
            liste.push({text: "Aus Liste entfernen", symbol: "edit-clear-history", aktion: () => {
                e.modell.trigger(e.zeile, "forget", null);
                empfehlungen.aktualisieren();
            }});
        } else {
            liste.push({text: "Öffnen", symbol: "document-open", aktion: () => menu.starten(e.modell, e.zeile)});
        }
        startKontext.zeigen(eintrag, liste, mx, my);
    }
}
