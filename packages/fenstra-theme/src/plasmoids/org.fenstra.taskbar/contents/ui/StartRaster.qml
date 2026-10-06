/*
    Fenstra-Startmenü: Raster „Angeheftet“ (docs/windows11-referenz.md 5.1).
    6 Spalten × 3 Zeilen je Seite (Zelle 96×84), Seiten senkrecht (Mausrad, 250 ms), Ordner.

    Datenhaltung: Welche Apps angeheftet sind und in welcher Reihenfolge, bleibt in der
    KActivities-Favoritenliste (dieselbe wie „An Start anheften“ überall in Plasma). Ordner
    stehen als JSON in der Applet-Konfiguration ("ordner"); ein Ordner steht an der Stelle
    seines ersten Mitglieds. Hinweis: favoritesModel.favorites liefert in Plasma 6 nichts
    mehr, die IDs kommen über die Rolle FavoriteIdRole (Qt.UserRole + 3).

    Ziehen: Kachel auf die Mitte einer anderen → Ordner bzw. in den Ordner; auf den Rand →
    davor/dahinter einsortieren.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.fenstra.shell

Item {
    id: raster

    readonly property int spalten: 6
    readonly property int proSeite: 18
    readonly property int zelleB: 96
    readonly property int zelleH: 84
    readonly property int rolleFavorit: Qt.UserRole + 3
    readonly property var fm: kicker.rootModel.favoritesModel

    property var kacheln: []
    property var ordnerListe: []
    readonly property int seiten: Math.max(1, Math.ceil(kacheln.length / proSeite))
    property int seite: 0
    property int auswahl: -1

    signal ordnerOeffnen(int oi)

    width: zelleB * spalten
    height: zelleH * 3

    function zuruecksetzen() {
        seite = 0;
        auswahl = -1;
        zieht = false;
    }

    // ---------------- Aufbau aus Favoriten + Ordnern ----------------
    function daten(zeile, rolle) {
        return fm.data(fm.index(zeile, 0), rolle);
    }
    function favoritenIds() {
        const ids = [];
        for (let i = 0; i < fm.count; ++i) {
            ids.push(String(daten(i, rolleFavorit) || ""));
        }
        return ids;
    }
    function ordnerLesen() {
        try {
            const l = JSON.parse(Plasmoid.configuration.ordner || "[]");
            return Array.isArray(l) ? l : [];
        } catch (e) {
            return [];
        }
    }
    function ordnerSchreiben(l) {
        const s = JSON.stringify(l);
        if (s !== Plasmoid.configuration.ordner) {
            Plasmoid.configuration.ordner = s;
        }
    }

    function aufbauen() {
        const ids = favoritenIds();
        // aufräumen: nicht mehr angeheftete Apps entfernen, Ordner mit < 2 Apps auflösen
        let ordner = ordnerLesen().map(o => ({name: String(o.name || "Ordner"), ids: (o.ids || []).filter(id => ids.indexOf(id) >= 0)}))
                                  .filter(o => o.ids.length >= 2);
        if (fm.count > 0) {
            ordnerSchreiben(ordner);
        }
        ordnerListe = ordner;
        const inOrdner = {};
        ordner.forEach((o, oi) => o.ids.forEach(id => inOrdner[id] = oi));

        const k = [];
        const gesetzt = {};
        for (let i = 0; i < ids.length; ++i) {
            const oi = inOrdner[ids[i]];
            if (oi === undefined) {
                k.push({typ: "app", id: ids[i], zeile: i, name: daten(i, Qt.DisplayRole) || "", symbol: daten(i, Qt.DecorationRole)});
            } else if (!gesetzt[oi]) {
                gesetzt[oi] = true;
                const mitglieder = ordner[oi].ids.map(mid => ids.indexOf(mid)).sort((a, b) => a - b)
                    .map(z => ({id: ids[z], zeile: z, name: daten(z, Qt.DisplayRole) || "", symbol: daten(z, Qt.DecorationRole)}));
                k.push({typ: "ordner", oi: oi, name: ordner[oi].name, mitglieder: mitglieder});
            }
        }
        kacheln = k;
        if (seite >= seiten) {
            seite = seiten - 1;
        }
    }
    Connections {
        target: raster.fm
        function onCountChanged() { Qt.callLater(raster.aufbauen); }
        function onModelReset() { Qt.callLater(raster.aufbauen); }
        function onRowsMoved() { Qt.callLater(raster.aufbauen); }
        function onDataChanged() { Qt.callLater(raster.aufbauen); }
        function onLayoutChanged() { Qt.callLater(raster.aufbauen); }
    }
    Connections {
        target: Plasmoid.configuration
        function onOrdnerChanged() { Qt.callLater(raster.aufbauen); }
    }
    Component.onCompleted: Qt.callLater(aufbauen)

    // ---------------- Aktionen ----------------
    function starten(zeile) {
        if (zeile >= 0) {
            fm.trigger(zeile, "", null);
            kicker.startOpen = false;
        }
    }
    // Favorit von Zeile „von“ an Zielzeile „nach“ verschieben (Endposition)
    function verschieben(von, nach) {
        nach = Math.max(0, Math.min(fm.count - 1, nach));
        if (von !== nach) {
            fm.moveRow(von, nach);
        }
    }
    function zeileVon(id) {
        return favoritenIds().indexOf(id);
    }
    // Kachel (App oder ganzer Ordner) vor/hinter eine andere Kachel setzen
    function kachelEinsortieren(quelle, ziel, dahinter) {
        const q = kacheln[quelle];
        const z = kacheln[ziel];
        if (!q || !z || quelle === ziel) {
            return;
        }
        const quellIds = q.typ === "app" ? [q.id] : q.mitglieder.map(m => m.id);
        const zielIds = z.typ === "app" ? [z.id] : z.mitglieder.map(m => m.id);
        const anker = dahinter ? zielIds[zielIds.length - 1] : zielIds[0];
        // Mitglieder der Reihe nach umsetzen: jedes landet direkt vor bzw. hinter dem Anker
        let letztes = anker;
        for (let i = 0; i < quellIds.length; ++i) {
            const von = zeileVon(quellIds[i]);
            let an = zeileVon(letztes);
            if (dahinter || i > 0) {
                an = von < an ? an : an + 1;
            } else {
                an = von < an ? an - 1 : an;
            }
            verschieben(von, an);
            letztes = quellIds[i];
        }
    }
    function ordnerBilden(quelle, ziel) {
        const q = kacheln[quelle];
        const z = kacheln[ziel];
        if (!q || !z || q.typ !== "app" || quelle === ziel) {
            return;
        }
        const ordner = ordnerListe.slice();
        if (z.typ === "ordner") {
            ordner[z.oi] = {name: ordner[z.oi].name, ids: ordner[z.oi].ids.concat([q.id])};
            kachelEinsortieren(quelle, ziel, true);
        } else {
            ordner.push({name: "Ordner", ids: [z.id, q.id]});
            kachelEinsortieren(quelle, ziel, true);
        }
        ordnerSchreiben(ordner);
    }
    function ausOrdnerEntfernen(oi, id) {
        const ordner = ordnerListe.slice();
        if (!ordner[oi]) {
            return;
        }
        const rest = ordner[oi].ids.filter(x => x !== id);
        ordner[oi] = {name: ordner[oi].name, ids: rest};
        // die App wandert hinter den Ordner
        const letzte = rest.length > 0 ? zeileVon(rest[rest.length - 1]) : -1;
        const von = zeileVon(id);
        if (letzte >= 0 && von >= 0) {
            verschieben(von, von < letzte ? letzte : letzte + 1);
        }
        ordnerSchreiben(ordner.filter(o => o.ids.length >= 2));
    }
    function ordnerUmbenennen(oi, name) {
        const ordner = ordnerListe.slice();
        if (ordner[oi]) {
            ordner[oi] = {name: name.length > 0 ? name : "Ordner", ids: ordner[oi].ids};
            ordnerSchreiben(ordner);
        }
    }

    // Kontextmenü einer App-Kachel (auch in Ordnern)
    function appMenue(element, eintrag, oi, mx, my) {
        const url = kicker.launcherUrl(eintrag.id);
        const tm = kicker.tasksModel;
        const angeheftetTL = url.length > 0 && tm.launcherPosition(url) >= 0;
        const liste = [];
        if (oi === undefined || oi < 0) {
            liste.push({text: "An erste Stelle verschieben", symbol: "go-top", aktiv: eintrag.zeile > 0,
                        aktion: () => raster.verschieben(eintrag.zeile, 0)});
        } else {
            liste.push({text: "Aus Ordner entfernen", symbol: "folder-remove", aktion: () => raster.ausOrdnerEntfernen(oi, eintrag.id)});
        }
        liste.push({text: "Von Start lösen", symbol: "window-unpin", aktion: () => raster.fm.removeFavorite(eintrag.id)});
        liste.push({text: angeheftetTL ? "Von Taskleiste lösen" : "An Taskleiste anheften", symbol: angeheftetTL ? "window-unpin" : "window-pin",
                    aktion: () => angeheftetTL ? tm.requestRemoveLauncher(url) : tm.requestAddLauncher(url)});
        const speicher = kicker.speicherId(eintrag.id);
        if (speicher.length > 0) {
            liste.push({trenner: true});
            liste.push({text: "Deinstallieren", symbol: "edit-delete", aktion: () => {
                kicker.befehl("plasma-discover --application " + kicker.shellWort("appstream://" + speicher.replace(/\.desktop$/, "")));
                kicker.startOpen = false;
            }});
        }
        startKontext.zeigen(element, liste, mx, my);
    }

    // ---------------- Tastatur ----------------
    function auswahlBewegen(dx, dy) {
        if (kacheln.length === 0) {
            return;
        }
        if (auswahl < 0) {
            auswahl = seite * proSeite;
        } else {
            auswahl = Math.max(0, Math.min(kacheln.length - 1, auswahl + dx + dy * spalten));
        }
        seite = Math.floor(auswahl / proSeite);
    }
    function auswahlStarten() {
        const k = kacheln[auswahl];
        if (!k) {
            return;
        }
        if (k.typ === "app") {
            starten(k.zeile);
        } else {
            ordnerOeffnen(k.oi);
        }
    }

    // ---------------- Ziehen ----------------
    property bool zieht: false
    property int ziehQuelle: -1
    property int ziehZiel: -1
    property string ziehArt: ""         // "ordner", "vor", "nach"
    property point ziehPunkt: Qt.point(0, 0)

    function ziehStart(index, p) {
        zieht = true;
        ziehQuelle = index;
        ziehBewegung(p);
    }
    function ziehBewegung(p) {
        ziehPunkt = p;
        const x = Math.max(0, Math.min(width - 1, p.x));
        const y = Math.max(0, Math.min(height - 1, p.y));
        const spalte = Math.floor(x / zelleB);
        const zeile = Math.floor(y / zelleH);
        let ziel = seite * proSeite + zeile * spalten + spalte;
        const mitte = x - (spalte * zelleB + zelleB / 2);
        if (ziel >= kacheln.length) {
            ziehZiel = kacheln.length - 1;
            ziehArt = "nach";
            return;
        }
        ziehZiel = ziel;
        const quelleIstApp = kacheln[ziehQuelle] && kacheln[ziehQuelle].typ === "app";
        if (Math.abs(mitte) < 22 && ziel !== ziehQuelle && quelleIstApp) {
            ziehArt = "ordner";
        } else {
            ziehArt = mitte < 0 ? "vor" : "nach";
        }
    }
    function ziehEnde() {
        if (!zieht) {
            return;
        }
        const q = ziehQuelle, z = ziehZiel, art = ziehArt;
        zieht = false;
        ziehQuelle = -1;
        ziehZiel = -1;
        if (z < 0 || q < 0 || q === z) {
            return;
        }
        if (art === "ordner") {
            ordnerBilden(q, z);
        } else {
            kachelEinsortieren(q, z, art === "nach");
        }
    }
    // am oberen/unteren Rand blättern
    Timer {
        interval: 600
        repeat: true
        running: raster.zieht && (raster.ziehPunkt.y < 8 || raster.ziehPunkt.y > raster.height - 8)
        onTriggered: {
            if (raster.ziehPunkt.y < 8 && raster.seite > 0) {
                raster.seite--;
            } else if (raster.ziehPunkt.y > raster.height - 8 && raster.seite < raster.seiten - 1) {
                raster.seite++;
            }
        }
    }

    // ---------------- Darstellung ----------------
    ListView {
        id: seitenListe
        anchors.fill: parent
        clip: true
        interactive: false
        orientation: ListView.Vertical
        snapMode: ListView.SnapOneItem
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 250
        highlightMoveVelocity: -1
        currentIndex: raster.seite
        model: raster.seiten
        delegate: Item {
            id: seitenItem
            required property int index
            width: raster.width
            height: raster.height
            Repeater {
                model: raster.kacheln.slice(seitenItem.index * raster.proSeite, (seitenItem.index + 1) * raster.proSeite)
                delegate: StartKachel {
                    id: kachelItem
                    required property int index
                    required property var modelData
                    readonly property int nr: seitenItem.index * raster.proSeite + index
                    x: (index % raster.spalten) * raster.zelleB
                    y: Math.floor(index / raster.spalten) * raster.zelleH
                    width: raster.zelleB
                    height: raster.zelleH
                    eintrag: modelData
                    ausgewaehlt: raster.auswahl === nr
                    ordnerZiel: raster.zieht && raster.ziehArt === "ordner" && raster.ziehZiel === nr
                    gezogen: raster.zieht && raster.ziehQuelle === nr
                    einfuegenVor: raster.zieht && raster.ziehArt === "vor" && raster.ziehZiel === nr && raster.ziehQuelle !== nr
                    einfuegenNach: raster.zieht && raster.ziehArt === "nach" && raster.ziehZiel === nr && raster.ziehQuelle !== nr
                    onGeklickt: kachelItem.modelData.typ === "app" ? raster.starten(kachelItem.modelData.zeile) : raster.ordnerOeffnen(kachelItem.modelData.oi)
                    onKontext: (mx, my) => {
                        const k = kachelItem.modelData;
                        if (k.typ === "app") {
                            raster.appMenue(kachelItem, k, -1, mx, my);
                        } else {
                            startKontext.zeigen(kachelItem, [
                                {text: "Öffnen", symbol: "folder-open", aktion: () => raster.ordnerOeffnen(k.oi)},
                                {text: "An erste Stelle verschieben", symbol: "go-top", aktiv: kachelItem.nr > 0,
                                 aktion: () => raster.kachelEinsortieren(kachelItem.nr, 0, false)}
                            ], mx, my);
                        }
                    }
                    onZiehenBeginnt: p => raster.ziehStart(kachelItem.nr, kachelItem.mapToItem(raster, p.x, p.y))
                    onZiehenBewegt: p => raster.ziehBewegung(kachelItem.mapToItem(raster, p.x, p.y))
                    onZiehenEndet: raster.ziehEnde()
                }
            }
        }
    }

    // Mausrad blättert seitenweise
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        property real summe: 0
        onWheel: event => {
            summe += event.angleDelta.y;
            if (summe <= -120 && raster.seite < raster.seiten - 1) {
                raster.seite++;
                summe = 0;
            } else if (summe >= 120 && raster.seite > 0) {
                raster.seite--;
                summe = 0;
            } else if (Math.abs(summe) >= 120) {
                summe = 0;
            }
        }
    }

    // gezogenes Symbol folgt der Maus
    Kirigami.Icon {
        visible: raster.zieht && raster.kacheln[raster.ziehQuelle] !== undefined
        z: 10
        width: 32
        height: 32
        x: raster.ziehPunkt.x - 16
        y: raster.ziehPunkt.y - 16
        opacity: 0.9
        source: {
            const k = raster.kacheln[raster.ziehQuelle];
            return !k ? "" : (k.typ === "app" ? k.symbol : (k.mitglieder.length > 0 ? k.mitglieder[0].symbol : "folder"));
        }
    }
}
