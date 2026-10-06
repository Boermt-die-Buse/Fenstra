/*
    Fenstra-Suche (M4, docs/windows11-referenz.md 5.2): Suchpanel an der Stelle des Startmenüs.

      [ 🔍 Suchtext                                      ]   (Suchfeld gehört StartMenu.qml)
       Alle  Apps  Dokumente  Web  Einstellungen  Ordner  Fotos
      ┌ Höchste Übereinstimmung ┐ ┌──────────────────────┐
      │ ▣ Rechner   App         │ │        ▣ 64          │
      │ Apps                    │ │      Rechner         │
      │  ▫ …                    │ │        App           │
      │ Einstellungen           │ │ ──────────────────── │
      │  ▫ …                    │ │ ↗ Öffnen             │
      └─────────────────────────┘ └──────────────────────┘

    Leer: „Top-Apps“, „Zuletzt verwendet“, „Schnellsuchen“. Backend: KRunner über das
    Kicker-RunnerModel (alle Treffer zusammengeführt, nach Relevanz); die Gruppen bildet diese
    Datei aus Art und Kategorie der Treffer. Koordinaten relativ zur Ansicht (64 px unter dem
    oberen Rand des mainItem).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker
import org.fenstra.shell

Item {
    id: suche

    property string anfrage: ""
    property bool aktiv: false
    property string filter: "alle"
    property var eintraege: []        // Treffer: {nr, zeile, art, titel, untertitel, symbol, gruppe, url, fav}
    property var anzeige: []          // Liste mit Überschriften: {kopf} oder {nr, gross}
    property int auswahl: 0

    readonly property int rolleBeschreibung: Qt.UserRole + 1
    readonly property int rolleGruppe: Qt.UserRole + 2
    readonly property int rolleFavorit: Qt.UserRole + 3
    readonly property int rolleAktionen: Qt.UserRole + 9
    readonly property int rolleUrl: Qt.UserRole + 10

    readonly property var filterListe: [
        {id: "alle", text: "Alle", runner: []},
        {id: "apps", text: "Apps", runner: ["krunner_services"]},
        {id: "dokumente", text: "Dokumente", runner: ["baloosearch", "krunner_recentdocuments"]},
        {id: "web", text: "Web", runner: ["krunner_services"]},
        {id: "einstellungen", text: "Einstellungen", runner: ["krunner_systemsettings"]},
        {id: "ordner", text: "Ordner", runner: ["baloosearch", "krunner_placesrunner"]},
        {id: "fotos", text: "Fotos", runner: ["baloosearch"]}
    ]

    onVisibleChanged: {
        if (visible) {
            filter = "alle";
            auswahl = 0;
        }
    }

    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: kicker
        favoritesModel: kicker.rootModel.favoritesModel
        mergeResults: true
        runners: {
            for (const f of suche.filterListe) {
                if (f.id === suche.filter) {
                    return f.runner;
                }
            }
            return [];
        }
        query: suche.aktiv && suche.filter !== "web" ? suche.anfrage : ""
    }
    readonly property var treffer: runnerModel.count > 0 ? runnerModel.modelForRow(0) : null
    Connections {
        target: suche.treffer
        ignoreUnknownSignals: true
        function onCountChanged() { aufbauTimer.restart(); }
        function onModelReset() { aufbauTimer.restart(); }
        function onDataChanged() { aufbauTimer.restart(); }
    }
    Connections {
        target: runnerModel
        function onCountChanged() { aufbauTimer.restart(); }
        function onQueryingChanged() { aufbauTimer.restart(); }
    }
    onAnfrageChanged: {
        auswahl = 0;
        aufbauTimer.restart();
    }
    onFilterChanged: {
        auswahl = 0;
        aufbauTimer.restart();
    }
    Timer {
        id: aufbauTimer
        interval: 40
        onTriggered: suche.aufbauen()
    }

    // ---------------- Treffer einordnen ----------------
    readonly property var bildEndungen: ["png", "jpg", "jpeg", "gif", "webp", "svg", "bmp", "tif", "tiff", "heic", "avif"]
    function artVon(fav, url, gruppe) {
        if (fav.length > 0) {
            return "app";
        }
        const g = gruppe.toLowerCase();
        if (g.indexOf("einstellung") >= 0 || g.indexOf("settings") >= 0) {
            return "einstellung";
        }
        if (url.startsWith("file://")) {
            const name = url.substring(url.lastIndexOf("/") + 1);
            const punkt = name.lastIndexOf(".");
            const endung = punkt > 0 ? name.substring(punkt + 1).toLowerCase() : "";
            if (g.indexOf("ordner") >= 0 || g.indexOf("folder") >= 0 || url.endsWith("/")) {
                return "ordner";
            }
            if (bildEndungen.indexOf(endung) >= 0 || g.indexOf("bild") >= 0) {
                return "foto";
            }
            return endung.length === 0 && g.indexOf("dokument") < 0 ? "ordner" : "dokument";
        }
        return "sonstiges";
    }
    readonly property var gruppenNamen: ({app: "Apps", einstellung: "Einstellungen", dokument: "Dokumente", ordner: "Ordner", foto: "Fotos"})
    readonly property var artNamen: ({app: "App", einstellung: "Systemeinstellungen", dokument: "Dokument", ordner: "Dateiordner", foto: "Foto", web: "Websuche"})

    function aufbauen() {
        const e = [];
        const m = treffer;
        if (m && anfrage.length > 0 && filter !== "web") {
            for (let i = 0; i < m.count; ++i) {
                const idx = m.index(i, 0);
                const fav = String(m.data(idx, rolleFavorit) || "");
                const url = String(m.data(idx, rolleUrl) || "");
                const gruppe = String(m.data(idx, rolleGruppe) || "");
                const art = artVon(fav, url, gruppe);
                if ((filter === "dokumente" && art !== "dokument") || (filter === "ordner" && art !== "ordner")
                    || (filter === "fotos" && art !== "foto") || (filter === "apps" && art !== "app")) {
                    continue;
                }
                e.push({zeile: i, art: art, titel: String(m.data(idx, Qt.DisplayRole) || ""),
                        untertitel: String(m.data(idx, rolleBeschreibung) || ""), symbol: m.data(idx, Qt.DecorationRole),
                        gruppe: gruppe, url: url, fav: fav});
            }
        }
        if (anfrage.length > 0 && (filter === "alle" || filter === "web")) {
            e.push({zeile: -1, art: "web", titel: anfrage, untertitel: "Webergebnisse anzeigen", symbol: "internet-web-browser",
                    gruppe: "Web durchsuchen", url: "", fav: ""});
        }
        // Höchste Übereinstimmung wie Windows: eine App, deren Name (oder Beschreibung) mit dem
        // Suchtext bzw. einem Wort davon beginnt, geht vor; sonst bleibt KRunners Reihenfolge.
        const q = anfrage.toLowerCase();
        function guete(x) {
            const t = x.titel.toLowerCase();
            const u = x.untertitel.toLowerCase();
            if (x.art === "web") {
                return 0;
            }
            if (t.startsWith(q)) {
                return 5 + (x.art === "app" ? 1 : 0);
            }
            if (t.split(/[\s\-_.]+/).some(w => w.startsWith(q))) {
                return 4 + (x.art === "app" ? 1 : 0);
            }
            if (x.art === "app") {
                const woerter = u.split(/[\s\-_.,]+/);
                if (woerter.some(w => w === q)) {
                    return 3.5;
                }
                if (woerter.some(w => w.startsWith(q))) {
                    return 3;
                }
            }
            return 1;
        }
        let beste = 0;
        for (let i = 1; i < e.length; ++i) {
            if (guete(e[i]) > guete(e[beste])) {
                beste = i;
            }
        }
        if (beste > 0) {
            e.unshift(e.splice(beste, 1)[0]);
        }
        // Anzeige: höchste Übereinstimmung, dann Gruppen in Windows-Reihenfolge
        const a = [];
        if (e.length > 0) {
            a.push({kopf: "Höchste Übereinstimmung"});
            a.push({nr: 0, gross: true});
            const reihenfolge = ["app", "einstellung", "dokument", "ordner", "foto", "sonstiges", "web"];
            for (const art of reihenfolge) {
                let kopfGesetzt = false;
                let letzteGruppe = "";
                for (let i = 1; i < e.length; ++i) {
                    if (e[i].art !== art) {
                        continue;
                    }
                    const kopf = art === "sonstiges" ? (e[i].gruppe || "Weitere Ergebnisse") : (art === "web" ? "Web durchsuchen" : gruppenNamen[art]);
                    if (!kopfGesetzt || (art === "sonstiges" && kopf !== letzteGruppe)) {
                        a.push({kopf: kopf});
                        kopfGesetzt = true;
                        letzteGruppe = kopf;
                    }
                    a.push({nr: i, gross: false});
                }
            }
        }
        e.forEach((x, i) => x.nr = i);
        eintraege = e;
        anzeige = a;
        if (auswahl >= e.length) {
            auswahl = Math.max(0, e.length - 1);
        }
    }

    // ---------------- Bedienung ----------------
    function auswahlBewegen(d) {
        if (eintraege.length === 0) {
            return;
        }
        auswahl = Math.max(0, Math.min(eintraege.length - 1, auswahl + d));
        for (let i = 0; i < anzeige.length; ++i) {
            if (anzeige[i].nr === auswahl) {
                ergebnisListe.positionViewAtIndex(i, ListView.Contain);
                break;
            }
        }
    }
    function auswahlOeffnen() {
        if (eintraege.length > 0) {
            oeffnen(eintraege[auswahl]);
        }
    }
    function oeffnen(e) {
        if (!e) {
            return;
        }
        if (e.art === "web") {
            Qt.openUrlExternally("https://duckduckgo.com/?q=" + encodeURIComponent(e.titel));
        } else if (treffer) {
            treffer.trigger(e.zeile, "", null);
        }
        kicker.startOpen = false;
    }
    function pfadVon(url) {
        return url.startsWith("file://") ? decodeURIComponent(url.substring(7)) : "";
    }
    function speicherortOeffnen(e) {
        if (e.art === "app") {
            const id = kicker.speicherId(e.fav);
            kicker.befehl("p=$(for d in ~/.local/share/applications /usr/local/share/applications /usr/share/applications /var/lib/flatpak/exports/share/applications; do "
                          + "[ -e \"$d\"/" + kicker.shellWort(id) + " ] && echo \"$d\"/" + kicker.shellWort(id) + " && break; done); dolphin --select \"$p\"");
        } else {
            const p = pfadVon(e.url);
            if (p.length > 0) {
                kicker.befehl("dolphin --select " + kicker.shellWort(p));
            }
        }
        kicker.startOpen = false;
    }
    function pfadKopieren(e) {
        zwischenablage.text = pfadVon(e.url);
        zwischenablage.selectAll();
        zwischenablage.copy();
    }
    TextEdit {
        id: zwischenablage
        visible: false
    }

    // Aktionen des Detailbereichs
    function aktionen(e) {
        if (!e) {
            return [];
        }
        const l = [];
        if (e.art === "web") {
            l.push({text: "Im Browser öffnen", symbol: "globe", aktion: () => suche.oeffnen(e)});
            return l;
        }
        l.push({text: "Öffnen", symbol: "document-open", aktion: () => suche.oeffnen(e)});
        if (e.art === "app") {
            // Aufgaben der App (Sprungliste), z. B. „Neues Fenster“
            const liste = treffer ? (treffer.data(treffer.index(e.zeile, 0), rolleAktionen) || []) : [];
            for (let i = 0; i < liste.length; ++i) {
                const a = liste[i];
                if (a.actionId === "_kicker_jumpListAction") {
                    l.push({text: a.text, symbol: a.icon || "", aktion: () => {
                        treffer.trigger(e.zeile, a.actionId, a.actionArgument);
                        kicker.startOpen = false;
                    }});
                }
            }
            const fm = kicker.rootModel.favoritesModel;
            const angeheftet = fm.isFavorite(e.fav);
            const tm = kicker.tasksModel;
            const url = kicker.launcherUrl(e.fav);
            const inTL = tm.launcherPosition(url) >= 0;
            l.push({text: "Dateispeicherort öffnen", symbol: "folder-open", aktion: () => suche.speicherortOeffnen(e)});
            l.push({text: angeheftet ? "Von Start lösen" : "An Start anheften", symbol: angeheftet ? "window-unpin" : "window-pin",
                    aktion: () => { angeheftet ? fm.removeFavorite(e.fav) : fm.addFavorite(e.fav, -1); suche.detailNeu++; }});
            l.push({text: inTL ? "Von Taskleiste lösen" : "An Taskleiste anheften", symbol: inTL ? "window-unpin" : "window-pin",
                    aktion: () => { inTL ? tm.requestRemoveLauncher(url) : tm.requestAddLauncher(url); suche.detailNeu++; }});
            const speicher = kicker.speicherId(e.fav);
            if (speicher.length > 0) {
                l.push({text: "Deinstallieren", symbol: "edit-delete", aktion: () => {
                    kicker.befehl("plasma-discover --application " + kicker.shellWort("appstream://" + speicher.replace(/\.desktop$/, "")));
                    kicker.startOpen = false;
                }});
            }
        } else if (e.art === "dokument" || e.art === "foto" || e.art === "ordner") {
            if (e.art !== "ordner") {
                l.push({text: "Dateispeicherort öffnen", symbol: "folder-open", aktion: () => suche.speicherortOeffnen(e)});
            }
            l.push({text: "Pfad kopieren", symbol: "edit-copy", aktion: () => suche.pfadKopieren(e)});
        }
        return l;
    }
    property int detailNeu: 0

    // ---------------- Filterleiste ----------------
    Row {
        id: filterLeiste
        x: 24
        y: 12
        height: 32
        spacing: 0
        Repeater {
            model: suche.filterListe
            delegate: Item {
                id: reiter
                required property var modelData
                readonly property bool gewaehlt: suche.filter === modelData.id
                width: reiterText.implicitWidth + 24
                height: 32
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    radius: 4
                    color: reiterMaus.pressed ? Farben.subtilGedrueckt : reiterMaus.containsMouse ? Farben.subtilHover : "transparent"
                }
                WinText {
                    id: reiterText
                    anchors.centerIn: parent
                    text: reiter.modelData.text
                    font.weight: reiter.gewaehlt ? Font.DemiBold : Font.Normal
                }
                Rectangle {
                    visible: reiter.gewaehlt
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: 16
                    height: 3
                    radius: 1.5
                    color: Farben.akzentFlaeche
                }
                MouseArea {
                    id: reiterMaus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: suche.filter = reiter.modelData.id
                }
            }
        }
    }

    // ---------------- Leerzustand ----------------
    Item {
        id: leer
        visible: suche.anfrage.length === 0
        anchors.fill: parent

        WinText {
            x: 32
            y: 64
            text: "Top-Apps"
            stil: "bodyStrong"
        }
        Row {
            x: 29
            y: 92
            Repeater {
                model: kicker.topAppsModel
                delegate: StartKachel {
                    required property int index
                    required property var model
                    visible: index < 6
                    width: visible ? 96 : 0
                    height: 84
                    eintrag: ({typ: "app", name: model.display || "", symbol: model.decoration})
                    onGeklickt: menu.starten(kicker.topAppsModel, index)
                }
            }
        }

        WinText {
            x: 32
            y: 196
            text: "Zuletzt verwendet"
            stil: "bodyStrong"
        }
        Column {
            x: 24
            y: 224
            width: 290
            Repeater {
                model: kicker.recentDocsModel
                delegate: WinListenEintrag {
                    required property int index
                    required property var model
                    visible: index < 8
                    width: 290
                    height: visible ? 40 : 0
                    symbol: model.decoration
                    symbolGroesse: 24
                    titel: model.display || ""
                    onClicked: menu.starten(kicker.recentDocsModel, index)
                }
            }
            WinText {
                visible: kicker.recentDocsModel.count === 0
                x: 8
                stil: "caption"
                sekundaer: true
                text: "Hier erscheinen zuletzt geöffnete Dateien."
            }
        }

        WinText {
            x: 336
            y: 196
            text: "Schnellsuchen"
            stil: "bodyStrong"
        }
        Column {
            x: 328
            y: 224
            width: 278
            Repeater {
                model: [
                    {titel: "Wetter", symbol: "weather-few-clouds", aktion: () => { kicker.startOpen = false; kicker.widgetsOffen = true; }},
                    {titel: "Rechner", symbol: "accessories-calculator-symbolic", aktion: () => { kicker.starteApp("org.kde.kcalc.desktop"); kicker.startOpen = false; }},
                    {titel: "Einstellungen", symbol: "configure", aktion: () => { kicker.starteApp("systemsettings.desktop"); kicker.startOpen = false; }},
                    {titel: "Bildschirmfoto", symbol: "camera-photo", aktion: () => { kicker.starteApp("org.kde.spectacle.desktop"); kicker.startOpen = false; }},
                    {titel: "Systeminformationen", symbol: "help-about", aktion: () => { kicker.starteApp("org.kde.kinfocenter.desktop"); kicker.startOpen = false; }}
                ]
                delegate: WinListenEintrag {
                    required property var modelData
                    width: 278
                    height: 40
                    symbol: modelData.symbol
                    symbolMaske: true
                    symbolGroesse: 16
                    titel: modelData.titel
                    onClicked: modelData.aktion()
                }
            }
        }
    }

    // ---------------- Ergebnisse ----------------
    Item {
        visible: suche.anfrage.length > 0
        anchors.fill: parent

        ListView {
            id: ergebnisListe
            x: 16
            y: 56
            width: 300
            height: parent.height - 56 - 16
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: suche.anzeige
            delegate: Item {
                id: zeile
                required property var modelData
                required property int index
                readonly property var e: modelData.kopf === undefined ? suche.eintraege[modelData.nr] : null
                width: ergebnisListe.width
                height: modelData.kopf !== undefined ? 32 : (modelData.gross ? 64 : 40)

                WinText {
                    visible: zeile.modelData.kopf !== undefined
                    x: 12
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 6
                    text: zeile.modelData.kopf || ""
                    stil: "bodyStrong"
                }
                WinListenEintrag {
                    id: trefferEintrag
                    visible: zeile.e !== null
                    anchors.fill: parent
                    symbol: zeile.e ? zeile.e.symbol : ""
                    symbolGroesse: zeile.modelData.gross ? 32 : 24
                    titel: zeile.e ? zeile.e.titel : ""
                    titelFett: zeile.modelData.gross === true
                    untertitel: !zeile.e ? "" : (zeile.modelData.gross ? (suche.artNamen[zeile.e.art] || zeile.e.gruppe) : (zeile.e.art === "app" ? "" : zeile.e.untertitel))
                    ausgewaehlt: zeile.e !== null && suche.auswahl === zeile.modelData.nr
                    onClicked: suche.oeffnen(zeile.e)
                    onRightClicked: suche.auswahl = zeile.modelData.nr
                    // „>“: Details zeigen
                    WinKnopf {
                        visible: trefferEintrag.hovered && !zeile.modelData.gross
                        width: 28
                        height: 28
                        art: "subtil"
                        symbol: "arrow-right"
                        symbolGroesse: 12
                        onClicked: suche.auswahl = zeile.modelData.nr
                    }
                }
            }
        }
        WinBildlauf {
            flick: ergebnisListe
            x: ergebnisListe.x + ergebnisListe.width - width
            y: ergebnisListe.y
            height: ergebnisListe.height
        }

        WinText {
            visible: suche.eintraege.length === 0 && !runnerModel.querying
            x: 28
            y: 72
            width: 280
            wrapMode: Text.WordWrap
            sekundaer: true
            text: "Keine Ergebnisse für „" + suche.anfrage + "“"
        }

        // Detailbereich
        Rectangle {
            id: detail
            readonly property var e: suche.eintraege.length > 0 ? suche.eintraege[suche.auswahl] : null
            visible: e !== null && e !== undefined
            x: 324
            y: 60
            width: parent.width - 324 - 16
            height: parent.height - 60 - 16
            radius: 8
            color: Farben.karte
            border.width: 1
            border.color: Farben.karteRand

            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 4

                Kirigami.Icon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 64
                    height: 64
                    source: detail.e ? detail.e.symbol : ""
                }
                Item { width: 1; height: 8 }
                WinText {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    stil: "subtitle"
                    text: detail.e ? detail.e.titel : ""
                }
                WinText {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    sekundaer: true
                    text: detail.e ? (suche.artNamen[detail.e.art] || detail.e.gruppe) : ""
                }
                WinText {
                    visible: detail.e !== null && detail.e !== undefined && detail.e.art !== "app" && detail.e.untertitel.length > 0
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    stil: "caption"
                    sekundaer: true
                    text: detail.e ? detail.e.untertitel : ""
                }
                Item { width: 1; height: 12 }
                WinTrenner {
                    width: parent.width
                }
                Item { width: 1; height: 4 }
                Repeater {
                    model: {
                        suche.detailNeu;
                        return suche.aktionen(detail.e);
                    }
                    delegate: WinListenEintrag {
                        required property var modelData
                        width: detail.width - 32
                        height: 36
                        symbol: modelData.symbol
                        symbolMaske: true
                        symbolGroesse: 16
                        titel: modelData.text
                        onClicked: modelData.aktion()
                    }
                }
            }
        }
    }
}
