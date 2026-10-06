/*
    Fenstra-Schnelleinstellungen (M4, docs/windows11-referenz.md 5.3): Inhalt des Flyouts.

      ┌───────────────────────────────────┐  Breite 360, rechts unten, 12 px Abstand
      │ [WLAN  >] [Bluet. >] [Flugzeug ]  │  Kacheln 96×48, 3 Spalten
      │ [Energie] [Nacht   ] [Barriere>]  │
      │ ☼ ━━━━━━━━━━━━━━━━━━━━━━━━━       │  Helligkeit (nur bei regelbarem Bildschirm)
      │ 🔊 ━━━━━━━━━━━━━━━━━━━━━━━  >     │  Lautstärke, „>“ = Ausgabegerät
      ├───────────────────────────────────┤
      │ 🔋 85 %                    ✎   ⚙  │  Fußleiste
      └───────────────────────────────────┘

    Unterseiten: "wlan", "bluetooth", "barrierefreiheit", "ton". „Bearbeiten“ (Stift): Kacheln
    lösen/hinzufügen, Auswahl in der Konfiguration (schnellKacheln).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.fenstra.shell

FocusScope {
    id: qs

    property string seite: "haupt"
    property bool bearbeiten: false
    signal schliessen()

    readonly property int breite: 352
    readonly property var kacheln: {
        const l = Plasmoid.configuration.schnellKacheln || [];
        const alle = Plasmoid.configuration.alleKachelnZeigen;
        return l.filter(id => daten.verzeichnis[id] !== undefined && (alle || bearbeiten || daten.verfuegbar(id)));
    }
    readonly property int zeilen: Math.max(1, Math.ceil(kacheln.length / 3))

    width: breite
    implicitWidth: breite
    implicitHeight: seite === "haupt" ? hauptHoehe : 420
    height: implicitHeight
    Layout.preferredWidth: breite
    Layout.preferredHeight: implicitHeight
    Layout.minimumWidth: breite
    Layout.maximumWidth: breite
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight

    readonly property int hauptHoehe: 20 + zeilen * 88 + (bearbeiten ? 44 : 0)
                                     + (daten.helligkeitVerfuegbar ? 48 : 0) + 48 + 12 + 48
    focus: true
    Keys.onEscapePressed: {
        if (seite !== "haupt") {
            seite = "haupt";
        } else if (bearbeiten) {
            bearbeiten = false;
        } else {
            qs.schliessen();
        }
    }

    function zuruecksetzen() {
        seite = "haupt";
        bearbeiten = false;
        daten.zustandLesen();
        forceActiveFocus();
    }

    QsDaten {
        id: daten
    }

    // ================= Hauptseite =================
    Item {
        anchors.fill: parent
        visible: qs.seite === "haupt"

        Grid {
            id: raster
            x: 20
            y: 20
            columns: 3
            columnSpacing: 12
            rowSpacing: 4
            Repeater {
                model: qs.kacheln
                delegate: QsKachel {
                    required property string modelData
                    readonly property var info: daten.verzeichnis[modelData]
                    text: info.text
                    symbol: info.symbol
                    geteilt: info.geteilt
                    pfeil: info.pfeil === true
                    an: daten.an(modelData)
                    // im Prüfmodus auch ohne Hardware bedienbar (Unterseiten ansehen)
                    enabled: daten.verfuegbar(modelData) || qs.bearbeiten || Plasmoid.configuration.alleKachelnZeigen
                    bearbeiten: qs.bearbeiten
                    onUmschalten: daten.umschalten(modelData)
                    onSeiteOeffnen: {
                        qs.seite = info.seite;
                        if (info.seite === "wlan") {
                            daten.wlanSuchen();
                        }
                    }
                    onLoesen: {
                        const l = (Plasmoid.configuration.schnellKacheln || []).filter(x => x !== modelData);
                        Plasmoid.configuration.schnellKacheln = l;
                    }
                }
            }
        }

        // Bearbeiten: „Hinzufügen“ und „Fertig“
        Row {
            visible: qs.bearbeiten
            x: 20
            y: raster.y + qs.zeilen * 88 + 4
            spacing: 12
            WinKnopf {
                id: hinzu
                width: 150
                text: "Hinzufügen"
                symbol: "list-add"
                onClicked: {
                    const vorhanden = Plasmoid.configuration.schnellKacheln || [];
                    const liste = [];
                    for (const id in daten.verzeichnis) {
                        if (vorhanden.indexOf(id) < 0) {
                            liste.push({text: daten.verzeichnis[id].text, symbol: daten.verzeichnis[id].symbol,
                                        aktion: () => { Plasmoid.configuration.schnellKacheln = (Plasmoid.configuration.schnellKacheln || []).concat([id]); }});
                        }
                    }
                    if (liste.length === 0) {
                        liste.push({text: "Alle Kacheln sind bereits angeheftet", aktiv: false});
                    }
                    kontext.zeigen(hinzu, liste);
                }
            }
            WinKnopf {
                width: 150
                art: "akzent"
                text: "Fertig"
                onClicked: qs.bearbeiten = false
            }
        }

        // Regler
        Column {
            x: 12
            y: 20 + qs.zeilen * 88 + (qs.bearbeiten ? 44 : 0) + 4
            width: qs.breite - 24
            spacing: 0

            Repeater {
                model: daten.helligkeitVerfuegbar ? daten.bildschirme : null
                delegate: Item {
                    required property int index
                    required property var model
                    visible: index === 0
                    width: parent.width
                    height: visible ? 48 : 0
                    WinKnopf {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 40
                        height: 40
                        art: "subtil"
                        symbol: "brightness-high"
                        tooltip: "Helligkeit"
                    }
                    WinRegler {
                        x: 44
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 44 - 44
                        from: 0
                        to: model.maxBrightness || 100
                        value: model.brightness || 0
                        stepSize: Math.max(1, Math.round((model.maxBrightness || 100) / 100))
                        onMoved: v => daten.helligkeitSetzen(model.displayName, Math.round(v))
                    }
                }
            }

            Item {
                width: parent.width
                height: 48
                WinKnopf {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    art: "subtil"
                    symbol: gruppe.tonSymbol
                    tooltip: gruppe.lautstaerke && gruppe.lautstaerke.stumm ? "Stummschaltung aufheben" : "Stumm"
                    enabled: gruppe.lautstaerke && gruppe.lautstaerke.vorhanden
                    onClicked: gruppe.lautstaerke.umschalten()
                }
                WinRegler {
                    x: 44
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 44 - 44
                    from: 0
                    to: 100
                    enabled: gruppe.lautstaerke && gruppe.lautstaerke.vorhanden
                    value: gruppe.lautstaerke ? gruppe.lautstaerke.prozent : 0
                    onMoved: v => gruppe.lautstaerke.setzen(v)
                }
                WinKnopf {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 40
                    art: "subtil"
                    symbol: "arrow-right"
                    symbolGroesse: 12
                    tooltip: "Audioausgabe auswählen"
                    onClicked: qs.seite = "ton"
                }
            }
        }

        // Fußleiste: Akku, Bearbeiten, Alle Einstellungen
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 48
            FlyoutFuss {
                anchors.top: parent.top
            }
            Row {
                visible: gruppe.hatAkku
                x: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Kirigami.Icon {
                    width: 16
                    height: 16
                    source: gruppe.akkuSymbol
                    isMask: true
                    color: Farben.text
                }
                WinText {
                    stil: "caption"
                    text: gruppe.akkuProzent + " %"
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                WinKnopf {
                    width: 36
                    height: 36
                    art: "subtil"
                    symbol: "document-edit"
                    tooltip: "Schnelleinstellungen bearbeiten"
                    aktiv: qs.bearbeiten
                    onClicked: qs.bearbeiten = !qs.bearbeiten
                }
                WinKnopf {
                    width: 36
                    height: 36
                    art: "subtil"
                    symbol: "configure"
                    tooltip: "Alle Einstellungen"
                    onClicked: {
                        daten.befehl("systemsettings");
                        qs.schliessen();
                    }
                }
            }
        }
    }

    // ================= Unterseiten =================
    Item {
        id: unterseite
        anchors.fill: parent
        visible: qs.seite !== "haupt"

        readonly property var titel: ({wlan: "WLAN", bluetooth: "Bluetooth", barrierefreiheit: "Barrierefreiheit", ton: "Soundausgabe"})

        // Kopf: Zurück, Titel, ggf. Schalter
        WinKnopf {
            id: zurueck
            x: 12
            y: 12
            width: 32
            height: 32
            art: "subtil"
            symbol: "arrow-left"
            symbolGroesse: 12
            tooltip: "Zurück"
            onClicked: qs.seite = "haupt"
        }
        WinText {
            anchors.left: zurueck.right
            anchors.leftMargin: 8
            anchors.verticalCenter: zurueck.verticalCenter
            text: unterseite.titel[qs.seite] || ""
            stil: "bodyStrong"
        }
        WinSchalter {
            visible: qs.seite === "wlan" || qs.seite === "bluetooth"
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: zurueck.verticalCenter
            checked: qs.seite === "wlan" ? daten.wlanAn : daten.bluetoothAn
            enabled: qs.seite === "wlan" ? daten.wlanVerfuegbar : daten.bluetoothVerfuegbar
            onToggled: qs.seite === "wlan" ? daten.wlanUmschalten() : daten.bluetoothUmschalten()
        }

        Loader {
            x: 8
            y: 56
            width: parent.width - 16
            height: parent.height - 56 - 56
            active: qs.seite !== "haupt"
            source: qs.seite === "wlan" ? "QsWlan.qml"
                  : qs.seite === "bluetooth" ? "QsBluetooth.qml"
                  : qs.seite === "barrierefreiheit" ? "QsBarrierefreiheit.qml"
                  : qs.seite === "ton" ? "QsTon.qml" : ""
        }

        // Fußleiste mit Verweis auf die Einstellungen
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 48
            FlyoutFuss {
                anchors.top: parent.top
            }
            WinKnopf {
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                art: "subtil"
                text: qs.seite === "wlan" ? "Weitere WLAN-Einstellungen"
                    : qs.seite === "bluetooth" ? "Weitere Bluetooth-Einstellungen"
                    : qs.seite === "barrierefreiheit" ? "Weitere Einstellungen für die Barrierefreiheit"
                    : "Weitere Lautstärkeeinstellungen"
                onClicked: {
                    daten.befehl(qs.seite === "wlan" ? "systemsettings kcm_networkmanagement"
                               : qs.seite === "bluetooth" ? "systemsettings kcm_bluetooth"
                               : qs.seite === "barrierefreiheit" ? "systemsettings kcm_access"
                               : "systemsettings kcm_pulseaudio");
                    qs.schliessen();
                }
            }
        }
    }

    WinKontextmenue {
        id: kontext
    }
}
