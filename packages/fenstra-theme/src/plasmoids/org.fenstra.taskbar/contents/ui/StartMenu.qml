/*
    Fenstra-Startmenü (M4, docs/windows11-referenz.md 5.1/5.2): Inhalt des Start-Flyouts.

      ┌─────────────────────────────────────────────┐  642 × 726 außen, 12 px über der Taskleiste
      │  ( 🔍 Nach Apps, Einstellungen und … )      │  Pille 36 hoch, 32 px seitlich
      │   Angeheftet                     [Alle  >]  │
      │   ▢ ▢ ▢ ▢ ▢ ▢                           •   │  6 × 3 je Seite, Punkte rechts
      │   ▢ ▢ ▢ ▢ ▢ ▢                           ·   │
      │   ▢ ▢ ▢ ▢ ▢ ▢                               │
      │   Empfohlen                      [Mehr  >]  │
      │   ▭ Datei           ▭ Datei                 │  2 × 3
      ├─────────────────────────────────────────────┤
      │   (D) Daniel                            ⏻   │  Fußleiste 64
      └─────────────────────────────────────────────┘

    Ansichten: "start", "alle" (Alle Apps), "empfohlen" (Mehr), "suche" (Suchpanel; Tippen im
    Startmenü, Suchfeld der Taskleiste, Win+S). Maße im mainItem = außen minus 4 px Rand.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.coreaddons as KCoreAddons
import org.fenstra.shell

FocusScope {
    id: menu

    // gewünschter Inhalt beim Öffnen ("start" oder "suche"), kommt von main.qml
    readonly property string modus: kicker.startModus
    property string ansicht: "start"

    Layout.preferredWidth: 634
    Layout.preferredHeight: 718
    Layout.minimumWidth: 634
    Layout.minimumHeight: 718
    Layout.maximumWidth: 634
    Layout.maximumHeight: 718

    function schliessen() {
        kicker.startOpen = false;
    }
    function zuruecksetzen() {
        suchfeld.leeren();
        ansicht = modus === "suche" ? "suche" : "start";
        startSeite.zuruecksetzen();
        konto.visible = false;
        suchfeld.eingabe.forceActiveFocus();
    }
    // Eintrag eines Kicker-Modells starten und Menü schließen
    function starten(modell, zeile) {
        if (modell && zeile >= 0) {
            modell.trigger(zeile, "", null);
            schliessen();
        }
    }

    Connections {
        target: kicker
        function onStartOpenChanged() {
            if (kicker.startOpen) {
                menu.zuruecksetzen();
                kicker.recentDocsModel.refresh();
                empfehlungen.aktualisieren();
            }
        }
        function onStartModusChanged() {
            if (kicker.startOpen) {
                menu.ansicht = kicker.startModus === "suche" ? "suche" : "start";
                if (menu.ansicht === "start") {
                    suchfeld.leeren();
                }
                suchfeld.eingabe.forceActiveFocus();
            }
        }
    }

    KCoreAddons.KUser {
        id: benutzer
    }
    Empfehlungen {
        id: empfehlungen
    }
    WinKontextmenue {
        id: startKontext
    }

    // ---------------- Suchfeld (Startmenü: Pille; Suche: dasselbe Feld mit Filterleiste) ----------------
    WinSuchfeld {
        id: suchfeld
        x: 28
        y: 28
        width: 578
        height: 36
        pille: true
        fokusStil: menu.ansicht === "suche"
        focus: true
        platzhalter: menu.ansicht === "suche" ? "Hier eingeben, um zu suchen" : "Nach Apps, Einstellungen und Dokumenten suchen"
        onTextChanged: {
            if (text.length > 0 && menu.ansicht !== "suche") {
                menu.ansicht = "suche";
            }
        }
        onAngenommen: {
            if (menu.ansicht === "suche") {
                suchAnsicht.auswahlOeffnen();
            } else if (menu.ansicht === "start") {
                startSeite.auswahlStarten();
            }
        }
        onAbgebrochen: {
            if (text.length > 0) {
                leeren();
            } else if (startSeite.ordnerOffen) {
                startSeite.ordnerSchliessen();
            } else if (konto.visible) {
                konto.visible = false;
            } else if (menu.ansicht === "alle" || menu.ansicht === "empfohlen") {
                menu.ansicht = "start";
            } else {
                menu.schliessen();
            }
        }
        onPfeil: (dx, dy, event) => menu.pfeil(dx, dy, event)
    }
    // Pfeiltasten bleiben im Suchfeld (Tippen geht immer weiter) und steuern die Auswahl
    function pfeil(dx, dy, event) {
        if (ansicht === "suche") {
            suchAnsicht.auswahlBewegen(dy !== 0 ? dy : dx);
            event.accepted = true;
        } else if (ansicht === "start") {
            startSeite.auswahlBewegen(dx, dy);
            event.accepted = true;
        } else {
            event.accepted = false;
        }
    }

    // ---------------- Ansichten ----------------
    StartSeite {
        id: startSeite
        y: 64
        width: parent.width
        height: 590
        visible: menu.ansicht === "start"
        onAlleZeigen: menu.ansicht = "alle"
        onMehrZeigen: menu.ansicht = "empfohlen"
    }

    AlleAnsicht {
        id: alleAnsicht
        y: 64
        width: parent.width
        height: 590
        visible: menu.ansicht === "alle"
        onZurueck: menu.ansicht = "start"
    }

    EmpfohlenAnsicht {
        y: 64
        width: parent.width
        height: 590
        visible: menu.ansicht === "empfohlen"
        onZurueck: menu.ansicht = "start"
    }

    SuchAnsicht {
        id: suchAnsicht
        y: 64
        width: parent.width
        height: menu.height - 64
        visible: menu.ansicht === "suche"
        aktiv: visible
        anfrage: suchfeld.text
    }

    // ---------------- Fußleiste: Benutzer, Ein/Aus ----------------
    StartFuss {
        visible: menu.ansicht !== "suche"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 64
        benutzerName: benutzer.fullName || benutzer.loginName
        benutzerBild: benutzer.faceIconUrl
        onKontoKlick: konto.visible = !konto.visible
    }

    KontoKarte {
        id: konto
        visible: false
        x: 28
        y: menu.height - 64 - height + 4
        benutzerName: benutzer.fullName || benutzer.loginName
        benutzerBild: benutzer.faceIconUrl
    }

    // Tippen irgendwo im Startmenü landet im Suchfeld (Windows beginnt sofort die Suche)
    Keys.onPressed: event => {
        if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            suchfeld.eingabe.forceActiveFocus();
            suchfeld.text += event.text;
            event.accepted = true;
        }
    }
}
