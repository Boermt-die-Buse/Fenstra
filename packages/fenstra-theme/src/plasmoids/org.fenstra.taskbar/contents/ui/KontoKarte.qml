/*
    Fenstra-Startmenü: Kontomenü (Klick auf den Benutzer, docs/windows11-referenz.md 5.1):
    Karte über der Fußleiste mit Kopf (Bild 48, Name, „Lokales Konto“), darunter
    „Kontoeinstellungen ändern“, „Sperren“, „Abmelden“ und – falls vorhanden – weitere
    Benutzer zum Wechseln (AccountsService). Klick außerhalb oder Esc schließt.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Effects

import org.kde.kirigamiaddons.components as KirigamiComponents
import org.kde.plasma.private.sessions as Sessions
import org.kde.plasma.workspace.dbus as DBus
import org.fenstra.shell

Rectangle {
    id: karte

    property string benutzerName: ""
    property url benutzerBild
    property var andere: []          // [{name, bild}]

    width: 300
    height: inhalt.implicitHeight + 16
    radius: 8
    color: Farben.flaecheErhoeht
    border.width: 1
    border.color: Farben.flyoutRand
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Farben.schatten
        shadowBlur: 0.8
        shadowVerticalOffset: 6
    }

    onVisibleChanged: if (visible) benutzerLaden()

    // weitere lokale Benutzer über AccountsService (Systembus)
    function benutzerLaden() {
        const antwort = DBus.SystemBus.asyncCall({
            service: "org.freedesktop.Accounts",
            path: "/org/freedesktop/Accounts",
            iface: "org.freedesktop.Accounts",
            member: "ListCachedUsers",
            arguments: []
        });
        antwort.finished.connect(() => {
            if (antwort.isError) {
                return;
            }
            const pfade = antwort.value || [];
            karte.andere = [];
            for (let i = 0; i < pfade.length; ++i) {
                const p = String(pfade[i]);
                const a = DBus.SystemBus.asyncCall({
                    service: "org.freedesktop.Accounts", path: p,
                    iface: "org.freedesktop.DBus.Properties", member: "GetAll",
                    arguments: ["org.freedesktop.Accounts.User"]
                });
                a.finished.connect(() => {
                    if (a.isError || !a.value) {
                        return;
                    }
                    const v = a.value;
                    // Werte kommen als D-Bus-Varianten: über String() vergleichen
                    const login = String(v.UserName || "");
                    const name = String(v.RealName || "") || login;
                    const system = String(v.SystemAccount) === "true";
                    if (login === String(benutzer.loginName) || system || login.length === 0) {
                        return;
                    }
                    const datei = String(v.IconFile || "");
                    karte.andere = karte.andere.concat([{name: name, bild: datei.length > 0 ? "file://" + datei : ""}]);
                });
            }
        });
    }
    MouseArea {
        // Klicks auf die Karte nicht ans Startmenü weiterreichen
        anchors.fill: parent
    }

    Column {
        id: inhalt
        x: 8
        y: 8
        width: parent.width - 16
        spacing: 0

        // Kopf
        Item {
            width: parent.width
            height: 72
            KirigamiComponents.Avatar {
                id: bild
                x: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 48
                source: karte.benutzerBild
                name: karte.benutzerName
            }
            Column {
                anchors.left: bild.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                WinText {
                    width: parent.width
                    text: karte.benutzerName
                    stil: "bodyStrong"
                }
                WinText {
                    width: parent.width
                    text: "Lokales Konto"
                    stil: "caption"
                    sekundaer: true
                }
            }
        }
        WinTrenner {
            width: parent.width
        }
        Item {
            width: 1
            height: 4
        }
        WinListenEintrag {
            width: parent.width
            height: 36
            symbol: "user-identity"
            symbolMaske: true
            symbolGroesse: 16
            titel: "Kontoeinstellungen ändern"
            onClicked: {
                kicker.befehl("systemsettings kcm_users");
                kicker.startOpen = false;
            }
        }
        WinListenEintrag {
            width: parent.width
            height: 36
            symbol: "system-lock-screen"
            symbolMaske: true
            symbolGroesse: 16
            titel: "Sperren"
            enabled: kicker.sitzung.canLock
            onClicked: {
                kicker.startOpen = false;
                kicker.sitzung.lock();
            }
        }
        WinListenEintrag {
            width: parent.width
            height: 36
            symbol: "system-log-out"
            symbolMaske: true
            symbolGroesse: 16
            titel: "Abmelden"
            enabled: kicker.sitzung.canLogout
            onClicked: {
                kicker.startOpen = false;
                kicker.sitzung.requestLogout(Sessions.SessionManagement.Skip);
            }
        }
        // weitere Benutzer
        Repeater {
            model: karte.andere
            delegate: WinListenEintrag {
                required property var modelData
                width: inhalt.width
                height: 44
                symbol: modelData.bild || "user-identity"
                symbolGroesse: 28
                titel: modelData.name
                onClicked: {
                    kicker.startOpen = false;
                    kicker.sitzung.switchUser();
                }
            }
        }
    }
}
