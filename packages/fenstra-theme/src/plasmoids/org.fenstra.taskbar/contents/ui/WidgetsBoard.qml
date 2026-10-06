/*
    Fenstra-Widgets (M4, docs/windows11-referenz.md 5.5): Board von links, 12 px Abstand zu
    linkem und oberem Bildschirmrand und zur Taskleiste, Breite 760, Radius 8, Acrylic.

      ┌──────────────────────────────────────────────────┐
      │ 17:52                                   [+] (D)  │  Kopf: Uhrzeit, Widgets hinzufügen, Benutzer
      │ ┌──── Wetter ────┐ ┌Kalender┐ ┌ Uhr ┐            │  Raster 4 Spalten, Karten klein (1×1),
      │ │ 20 °C ☁       │ │   6    │ │  ◷  │            │  mittel (2×1), groß (2×2), Radius 8
      │ └────────────────┘ └────────┘ └─────┘            │
      └──────────────────────────────────────────────────┘

    Fenstra zeigt keinen Nachrichten-Feed (kein Internetdienst), nur Widgets. Auswahl und Größe
    stehen in der Konfiguration (Gruppe Widgets, Eintrag widgets: "name:größe").
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.coreaddons as KCoreAddons
import org.kde.kirigamiaddons.components as KirigamiComponents
import org.fenstra.shell

FocusScope {
    id: board

    property int hoehe: 1000
    readonly property int breite: 752
    readonly property int einheit: 164              // Rasterzelle (klein = 1×1)
    readonly property int abstand: 12
    readonly property var eintraege: (Plasmoid.configuration.widgets || []).map(s => {
        const t = String(s).split(":");
        return {name: t[0], groesse: t[1] || "klein"};
    }).filter(e => verzeichnis[e.name] !== undefined)

    readonly property var verzeichnis: ({
        wetter: {titel: "Wetter", datei: "WidgetWetter.qml", symbol: "weather-few-clouds"},
        kalender: {titel: "Kalender", datei: "WidgetKalender.qml", symbol: "view-calendar"},
        uhr: {titel: "Uhr", datei: "WidgetUhr.qml", symbol: "chronometer"},
        fotos: {titel: "Fotos", datei: "WidgetFotos.qml", symbol: "image"},
        system: {titel: "Systemleistung", datei: "WidgetSystem.qml", symbol: "utilities-system-monitor"},
        notizen: {titel: "Notizen", datei: "WidgetNotizen.qml", symbol: "document-edit"}
    })

    // Plasma übernimmt die Größe aus den Layout-Grenzen (eine height-Bindung überschreibt der
    // Dialog beim ersten Aufbau): minimum = maximum = gewünschte Größe
    width: breite
    height: hoehe
    Layout.preferredWidth: breite
    Layout.preferredHeight: hoehe
    Layout.minimumWidth: breite
    Layout.maximumWidth: breite
    Layout.minimumHeight: hoehe
    Layout.maximumHeight: hoehe
    focus: true
    Keys.onEscapePressed: kicker.widgetsOffen = false

    KCoreAddons.KUser {
        id: benutzer
    }
    property date jetzt: new Date()
    Timer {
        interval: 1000
        running: board.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: board.jetzt = new Date()
    }

    function speichern(liste) {
        Plasmoid.configuration.widgets = liste.map(e => e.name + ":" + e.groesse);
    }
    function entfernen(name) {
        speichern(eintraege.filter(e => e.name !== name));
    }
    function groesseSetzen(name, g) {
        speichern(eintraege.map(e => e.name === name ? {name: e.name, groesse: g} : e));
    }
    function hinzufuegen(name) {
        speichern(eintraege.concat([{name: name, groesse: name === "wetter" || name === "fotos" ? "mittel" : "klein"}]));
    }

    // Raster packen: jede Karte an die erste freie Stelle (4 Spalten)
    readonly property var lagen: {
        const belegt = [];
        const frei = (z, s) => !(belegt[z] && belegt[z][s]);
        const l = [];
        for (const e of eintraege) {
            const b = e.groesse === "klein" ? 1 : 2;
            const h = e.groesse === "gross" ? 2 : 1;
            let gesetzt = false;
            for (let z = 0; !gesetzt && z < 50; ++z) {
                for (let s = 0; s + b <= 4 && !gesetzt; ++s) {
                    let ok = true;
                    for (let dz = 0; dz < h && ok; ++dz) {
                        for (let ds = 0; ds < b && ok; ++ds) {
                            ok = frei(z + dz, s + ds);
                        }
                    }
                    if (ok) {
                        for (let dz = 0; dz < h; ++dz) {
                            belegt[z + dz] = belegt[z + dz] || [];
                            for (let ds = 0; ds < b; ++ds) {
                                belegt[z + dz][s + ds] = true;
                            }
                        }
                        l.push({name: e.name, groesse: e.groesse, spalte: s, zeile: z, b: b, h: h});
                        gesetzt = true;
                    }
                }
            }
        }
        return l;
    }

    // ---------------- Kopf ----------------
    WinText {
        x: 24
        y: 16
        height: 40
        stil: "subtitle"
        text: board.jetzt.toLocaleTimeString(Qt.locale(), "HH:mm")
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 20
        y: 20
        spacing: 8
        WinKnopf {
            id: plus
            width: 32
            height: 32
            art: "subtil"
            symbol: "list-add"
            tooltip: "Widgets hinzufügen"
            onClicked: {
                const vorhanden = board.eintraege.map(e => e.name);
                const l = [];
                for (const name in board.verzeichnis) {
                    if (vorhanden.indexOf(name) < 0) {
                        l.push({text: board.verzeichnis[name].titel, symbol: board.verzeichnis[name].symbol, aktion: () => board.hinzufuegen(name)});
                    }
                }
                if (l.length === 0) {
                    l.push({text: "Alle Widgets sind bereits hinzugefügt", aktiv: false});
                }
                menue.zeigen(plus, l);
            }
        }
        KirigamiComponents.Avatar {
            width: 32
            height: 32
            source: benutzer.faceIconUrl
            name: benutzer.fullName || benutzer.loginName
        }
    }

    // ---------------- Karten ----------------
    Flickable {
        id: flaeche
        x: 24
        y: 72
        width: board.breite - 48
        height: board.hoehe - 72 - 16
        clip: true
        contentHeight: inhalt.height
        boundsBehavior: Flickable.StopAtBounds

        Item {
            id: inhalt
            width: flaeche.width
            height: {
                let z = 0;
                for (const l of board.lagen) {
                    z = Math.max(z, l.zeile + l.h);
                }
                return z * (board.einheit + board.abstand);
            }
            Repeater {
                model: board.lagen
                delegate: WidgetKarte {
                    required property var modelData
                    x: modelData.spalte * (board.einheit + board.abstand)
                    y: modelData.zeile * (board.einheit + board.abstand)
                    width: modelData.b * board.einheit + (modelData.b - 1) * board.abstand
                    height: modelData.h * board.einheit + (modelData.h - 1) * board.abstand
                    name: modelData.name
                    groesse: modelData.groesse
                    titel: board.verzeichnis[modelData.name].titel
                    symbol: board.verzeichnis[modelData.name].symbol
                    datei: board.verzeichnis[modelData.name].datei
                }
            }
        }
    }
    WinBildlauf {
        flick: flaeche
        x: flaeche.x + flaeche.width - width + 12
        y: flaeche.y
        height: flaeche.height
    }

    WinText {
        visible: board.eintraege.length === 0
        anchors.centerIn: parent
        sekundaer: true
        text: "Fügen Sie über „+“ Widgets hinzu."
    }

    WinKontextmenue {
        id: menue
    }
}
