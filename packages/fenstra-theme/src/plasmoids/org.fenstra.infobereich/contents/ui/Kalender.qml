/*
    Fenstra-Kalender (M4, docs/windows11-referenz.md 5.4): unteres Flyout der Zentrale.

      Dienstag, 6. Oktober                 ˅     Kopf, Chevron klappt den Monat ein
      Oktober 2026                      ˄  ˅     Monat wechseln
       Mo  Di  Mi  Do  Fr  Sa  So
       28  29  30   1   2   3   4                Zellen 40×40, heute Akzentkreis
      ...
      [–]  30 Minuten  [+]           [▷ Fokus]   Fußleiste: Fokussitzung

    Fokus: „Nicht stören“ für die gewählte Zeit, Restzeit in der Fußleiste.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import org.fenstra.shell

FocusScope {
    id: kal

    property date heute: new Date()
    property bool eingeklappt: false
    property int monatVersatz: 0           // 0 = aktueller Monat
    property date gewaehlt: new Date(0)
    property int fokusMinuten: 30
    signal schliessen()

    readonly property date ersterDesMonats: new Date(heute.getFullYear(), heute.getMonth() + monatVersatz, 1)
    readonly property int breite: 352

    width: breite
    implicitWidth: breite
    implicitHeight: 48 + (eingeklappt ? 0 : 40 + 32 + 6 * 44 + 8) + 52
    height: implicitHeight
    // Größe über Layout-Grenzen an Plasmas Dialog geben (Einklappen ändert die Höhe)
    Layout.minimumWidth: breite
    Layout.maximumWidth: breite
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
    focus: true
    Keys.onEscapePressed: kal.schliessen()

    function zuruecksetzen() {
        heute = new Date();
        monatVersatz = 0;
        gewaehlt = new Date(0);
        forceActiveFocus();
    }

    // zur Mitternacht weiterschalten
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            const jetzt = new Date();
            if (jetzt.getDate() !== kal.heute.getDate()) {
                kal.heute = jetzt;
            }
        }
    }

    // ---------------- Kopf ----------------
    WinText {
        x: 16
        y: 0
        height: 48
        text: kal.heute.toLocaleDateString(Qt.locale(), "dddd, d. MMMM")
        stil: "bodyStrong"
    }
    WinKnopf {
        anchors.right: parent.right
        anchors.rightMargin: 8
        y: 8
        width: 32
        height: 32
        art: "subtil"
        symbol: kal.eingeklappt ? "arrow-up" : "arrow-down"
        symbolGroesse: 12
        tooltip: kal.eingeklappt ? "Kalender anzeigen" : "Kalender ausblenden"
        onClicked: kal.eingeklappt = !kal.eingeklappt
    }

    // ---------------- Monat ----------------
    Item {
        id: monat
        visible: !kal.eingeklappt
        y: 48
        width: parent.width
        height: 40 + 32 + 6 * 44

        WinTrenner {
            width: parent.width
            anchors.top: parent.top
        }
        WinText {
            x: 16
            y: 0
            height: 40
            text: kal.ersterDesMonats.toLocaleDateString(Qt.locale(), "MMMM yyyy")
            stil: "bodyStrong"
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            y: 4
            spacing: 4
            WinKnopf {
                width: 32
                height: 32
                art: "subtil"
                symbol: "arrow-up"
                symbolGroesse: 12
                tooltip: "Vorheriger Monat"
                onClicked: kal.monatVersatz--
            }
            WinKnopf {
                width: 32
                height: 32
                art: "subtil"
                symbol: "arrow-down"
                symbolGroesse: 12
                tooltip: "Nächster Monat"
                onClicked: kal.monatVersatz++
            }
        }

        // Wochentage
        Row {
            x: 12
            y: 40
            Repeater {
                model: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                delegate: WinText {
                    required property string modelData
                    width: (kal.breite - 24) / 7
                    height: 32
                    horizontalAlignment: Text.AlignHCenter
                    stil: "caption"
                    text: modelData
                }
            }
        }

        // Tage (6 Wochen ab dem Montag vor dem Monatsersten)
        Grid {
            x: 12
            y: 72
            columns: 7
            Repeater {
                model: 42
                delegate: Item {
                    id: tag
                    required property int index
                    readonly property date datum: {
                        const e = kal.ersterDesMonats;
                        const versatz = (e.getDay() + 6) % 7;      // Montag = 0
                        return new Date(e.getFullYear(), e.getMonth(), 1 - versatz + index);
                    }
                    readonly property bool imMonat: datum.getMonth() === kal.ersterDesMonats.getMonth()
                    readonly property bool istHeute: datum.toDateString() === kal.heute.toDateString()
                    readonly property bool istGewaehlt: datum.toDateString() === kal.gewaehlt.toDateString()
                    width: (kal.breite - 24) / 7
                    height: 44

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 20
                        color: tag.istHeute ? (tagMaus.pressed ? Farben.akzentFlaecheGedrueckt : tagMaus.containsMouse ? Farben.akzentFlaecheHover : Farben.akzentFlaeche)
                             : tagMaus.pressed ? Farben.subtilGedrueckt : tagMaus.containsMouse ? Farben.subtilHover : "transparent"
                        border.width: tag.istGewaehlt && !tag.istHeute ? 1 : 0
                        border.color: Farben.akzentFlaeche
                    }
                    WinText {
                        anchors.centerIn: parent
                        text: tag.datum.getDate()
                        color: tag.istHeute ? Farben.textAufAkzent : (tag.imMonat ? Farben.text : Farben.textTertiaer)
                        font.weight: tag.istHeute ? Font.DemiBold : Font.Normal
                    }
                    MouseArea {
                        id: tagMaus
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: kal.gewaehlt = tag.datum
                    }
                }
            }
        }
        // Mausrad wechselt den Monat
        WheelHandler {
            onWheel: event => {
                if (event.angleDelta.y > 0) {
                    kal.monatVersatz--;
                } else if (event.angleDelta.y < 0) {
                    kal.monatVersatz++;
                }
            }
        }
    }

    // ---------------- Fokus (Fußleiste) ----------------
    NotificationManager.Settings {
        id: einstellungen
    }
    property double fokusEnde: 0
    property double jetztMs: Date.now()
    readonly property bool fokusLaeuft: fokusEnde > jetztMs
    Timer {
        interval: 1000
        running: kal.fokusLaeuft || kal.visible
        repeat: true
        onTriggered: kal.jetztMs = Date.now()
    }
    function fokusStarten() {
        fokusEnde = Date.now() + fokusMinuten * 60000;
        einstellungen.notificationsInhibitedUntil = new Date(fokusEnde);
        einstellungen.save();
        jetztMs = Date.now();
    }
    function fokusBeenden() {
        fokusEnde = 0;
        einstellungen.notificationsInhibitedUntil = undefined;
        einstellungen.save();
    }
    function restText() {
        const s = Math.max(0, Math.round((fokusEnde - jetztMs) / 1000));
        const m = Math.floor(s / 60);
        return m + ":" + String(s % 60).padStart(2, "0");
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 52
        FlyoutFuss {
            anchors.top: parent.top
        }
        Row {
            visible: !kal.fokusLaeuft
            x: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            WinKnopf {
                width: 32
                height: 32
                art: "subtil"
                symbol: "list-remove"
                symbolGroesse: 12
                enabled: kal.fokusMinuten > 5
                tooltip: "Weniger Zeit"
                onClicked: kal.fokusMinuten = kal.fokusMinuten > 30 ? kal.fokusMinuten - 15 : Math.max(5, kal.fokusMinuten - 5)
            }
            WinText {
                anchors.verticalCenter: parent.verticalCenter
                width: 96
                horizontalAlignment: Text.AlignHCenter
                text: kal.fokusMinuten + " Minuten"
            }
            WinKnopf {
                width: 32
                height: 32
                art: "subtil"
                symbol: "list-add"
                symbolGroesse: 12
                enabled: kal.fokusMinuten < 240
                tooltip: "Mehr Zeit"
                onClicked: kal.fokusMinuten = kal.fokusMinuten >= 30 ? kal.fokusMinuten + 15 : kal.fokusMinuten + 5
            }
        }
        WinText {
            visible: kal.fokusLaeuft
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            text: "Fokus: noch " + kal.restText()
        }
        WinKnopf {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: kal.fokusLaeuft ? "Beenden" : "Fokus"
            symbol: kal.fokusLaeuft ? "media-playback-stop" : "media-playback-start"
            symbolGroesse: 12
            onClicked: kal.fokusLaeuft ? kal.fokusBeenden() : kal.fokusStarten()
        }
    }
}
