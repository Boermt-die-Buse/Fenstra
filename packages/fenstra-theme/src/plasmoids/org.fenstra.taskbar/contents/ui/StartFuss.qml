/*
    Fenstra-Startmenü: Fußleiste (Höhe 64): dunklere Fläche mit Trennlinie; links Benutzer
    (Bild 32 + Name, Klick → Kontomenü), rechts Ein/Aus (40×40, Klick → Menü mit
    „Anmeldeoptionen“, „Energie sparen“, „Herunterfahren“, „Neu starten“).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.plasma.private.sessions as Sessions
import org.kde.plasma.extras as PlasmaExtras
import org.fenstra.shell

Item {
    id: fuss

    property string benutzerName: ""
    property url benutzerBild
    signal kontoKlick()

    FlyoutFuss {
        rand: 4
        anchors.top: parent.top
    }

    // Benutzer
    Item {
        id: benutzer
        x: 40
        anchors.verticalCenter: parent.verticalCenter
        height: 40
        width: zeile.implicitWidth + 24
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: benutzerMaus.pressed ? Farben.subtilGedrueckt : benutzerMaus.containsMouse ? Farben.subtilHover : "transparent"
        }
        Row {
            id: zeile
            x: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            KirigamiComponents.Avatar {
                width: 32
                height: 32
                source: fuss.benutzerBild
                name: fuss.benutzerName
            }
            WinText {
                anchors.verticalCenter: parent.verticalCenter
                text: fuss.benutzerName
                stil: "caption"
            }
        }
        MouseArea {
            id: benutzerMaus
            anchors.fill: parent
            hoverEnabled: true
            onClicked: fuss.kontoKlick()
        }
    }

    // Ein/Aus
    WinKnopf {
        id: ausKnopf
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        width: 40
        height: 40
        art: "subtil"
        symbol: "system-shutdown"
        symbolGroesse: 16
        tooltip: "Ein/Aus"
        onClicked: {
            const s = kicker.sitzung;
            ausMenue.zeigen(ausKnopf, [
                {text: "Anmeldeoptionen", symbol: "configure", aktion: () => {
                    kicker.befehl("systemsettings kcm_users");
                    kicker.startOpen = false;
                }},
                {text: "Energie sparen", symbol: "system-suspend", aktiv: s.canSuspend, aktion: () => {
                    kicker.startOpen = false;
                    s.suspend();
                }},
                {text: "Herunterfahren", symbol: "system-shutdown", aktiv: s.canShutdown,
                 aktion: () => s.requestShutdown(Sessions.SessionManagement.Skip)},
                {text: "Neu starten", symbol: "system-reboot", aktiv: s.canReboot,
                 aktion: () => s.requestReboot(Sessions.SessionManagement.Skip)}
            ]);
        }
    }
    WinKontextmenue {
        id: ausMenue
        lage: PlasmaExtras.Menu.TopPosedRightAlignedPopup
    }
}
