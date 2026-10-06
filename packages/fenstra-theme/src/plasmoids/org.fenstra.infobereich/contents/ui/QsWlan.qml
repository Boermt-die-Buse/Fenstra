/*
    Fenstra-Schnelleinstellungen: Unterseite „WLAN“ – verfügbare Netze (NetworkManager).
    Klick verbindet bzw. trennt; Kennwörter fragt der Plasma-Netzwerkdienst ab.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.networkmanagement as PlasmaNM
import org.fenstra.shell

Item {
    PlasmaNM.NetworkModel {
        id: netzModell
    }
    PlasmaNM.AppletProxyModel {
        id: netze
        sourceModel: netzModell
    }

    ListView {
        id: liste
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: daten.wlanAn ? netze : null
        delegate: WinListenEintrag {
            id: netz
            required property var model
            width: liste.width
            visible: model.Type === PlasmaNM.Enums.Wireless
            height: visible ? 48 : 0
            symbol: model.ConnectionIcon
            symbolMaske: true
            symbolGroesse: 16
            titel: model.ItemUniqueName
            untertitel: {
                const s = model.ConnectionState;
                const gesichert = model.SecurityType !== PlasmaNM.Enums.NoneSecurity;
                if (s === PlasmaNM.Enums.Activated) {
                    return gesichert ? "Verbunden, gesichert" : "Verbunden, offen";
                }
                if (s === PlasmaNM.Enums.Activating) {
                    return "Verbindung wird hergestellt …";
                }
                return gesichert ? "Gesichert" : "Offen";
            }
            ausgewaehlt: model.ConnectionState === PlasmaNM.Enums.Activated
            onClicked: {
                const h = daten.netzHandler;
                if (model.ConnectionState === PlasmaNM.Enums.Deactivated) {
                    if (model.Uuid) {
                        h.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath);
                    } else {
                        h.addAndActivateConnection(model.DevicePath, model.SpecificPath);
                    }
                } else {
                    h.deactivateConnection(model.ConnectionPath, model.DevicePath);
                }
            }
        }
    }
    WinText {
        visible: !daten.wlanVerfuegbar || !daten.wlanAn || liste.contentHeight < 1
        x: 12
        y: 8
        width: parent.width - 24
        wrapMode: Text.WordWrap
        sekundaer: true
        text: !daten.wlanVerfuegbar ? "Kein WLAN-Adapter gefunden." : (!daten.wlanAn ? "WLAN ist deaktiviert." : "Es wurden keine Netzwerke gefunden.")
    }
}
