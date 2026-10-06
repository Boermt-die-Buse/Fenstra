/*
    Fenstra-Startmenü: Daten für „Empfohlen“ (docs/windows11-referenz.md 5.1).
    Neu installierte Apps („Kürzlich hinzugefügt“, Kicker merkt sich das erste Auftauchen) und
    zuletzt geöffnete Dateien mit Zeitangabe („Vor 2 Std.“, „Gestern um 17:42“, „6. Okt.“).
    Die Zeit einer Datei ist der spätere Wert aus letztem Zugriff und letzter Änderung (stat).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasma5support as P5Support

Item {
    id: emp

    property var liste: []          // [{art, titel, symbol, modell, zeile, pfad}]
    property var zeiten: ({})       // Pfad -> Millisekunden
    property int jetztTakt: 0       // erzwingt Neuberechnung der Zeittexte beim Öffnen

    Instantiator {
        id: apps
        model: kicker.allAppsModel
        delegate: QtObject {
            required property int index
            required property var model
        }
        onObjectAdded: Qt.callLater(emp.aufbauen)
    }
    Instantiator {
        id: dokumente
        model: kicker.recentDocsModel
        delegate: QtObject {
            required property int index
            required property var model
        }
        onObjectAdded: Qt.callLater(emp.aufbauen)
        onObjectRemoved: Qt.callLater(emp.aufbauen)
    }

    function pfadAus(url) {
        const s = String(url || "");
        return s.startsWith("file://") ? decodeURIComponent(s.substring(7)) : "";
    }

    function aufbauen() {
        const l = [];
        for (let i = 0; i < apps.count; ++i) {
            const o = apps.objectAt(i);
            if (o && o.model.isNewlyInstalled) {
                l.push({art: "app", titel: o.model.display, symbol: o.model.decoration,
                        modell: kicker.allAppsModel, zeile: o.index, pfad: "", id: o.model.favoriteId || ""});
            }
        }
        for (let i = 0; i < dokumente.count; ++i) {
            const o = dokumente.objectAt(i);
            if (o) {
                l.push({art: "datei", titel: o.model.display, symbol: o.model.decoration,
                        modell: kicker.recentDocsModel, zeile: o.index, pfad: pfadAus(o.model.url), id: o.model.favoriteId || ""});
            }
        }
        liste = l;
    }

    function aktualisieren() {
        aufbauen();
        jetztTakt++;
        const pfade = liste.filter(e => e.pfad.length > 0).map(e => kicker.shellWort(e.pfad));
        if (pfade.length > 0) {
            stat.connectSource("stat -c '%X %Y %n' -- " + pfade.join(" ") + " 2>/dev/null; true #" + jetztTakt);
        }
    }

    P5Support.DataSource {
        id: stat
        engine: "executable"
        onNewData: (quelle, daten) => {
            const z = {};
            const zeilen = String(daten["stdout"] || "").split("\n");
            for (const zeile of zeilen) {
                const m = zeile.match(/^(\d+) (\d+) (.*)$/);
                if (m) {
                    z[m[3]] = Math.max(Number(m[1]), Number(m[2])) * 1000;
                }
            }
            emp.zeiten = z;
            disconnectSource(quelle);
        }
    }

    // Untertitel eines Eintrags wie Windows
    function untertitel(e) {
        jetztTakt;          // Abhängigkeit
        if (e.art === "app") {
            return "Kürzlich hinzugefügt";
        }
        return zeitText(zeiten[e.pfad] || 0);
    }

    function zeitText(ms) {
        if (!ms) {
            return "";
        }
        const jetzt = new Date();
        const d = new Date(ms);
        const minuten = (jetzt.getTime() - ms) / 60000;
        if (minuten < 1) {
            return "Gerade eben";
        }
        if (minuten < 60) {
            return "Vor " + Math.floor(minuten) + " Min.";
        }
        const heute = new Date(jetzt.getFullYear(), jetzt.getMonth(), jetzt.getDate()).getTime();
        const uhrzeit = d.toLocaleTimeString(Qt.locale(), "HH:mm");
        if (ms >= heute) {
            return "Vor " + Math.floor(minuten / 60) + " Std.";
        }
        if (ms >= heute - 86400000) {
            return "Gestern um " + uhrzeit;
        }
        if (d.getFullYear() === jetzt.getFullYear()) {
            return d.toLocaleDateString(Qt.locale(), "d. MMM");
        }
        return d.toLocaleDateString(Qt.locale(), "d. MMM yyyy");
    }
}
