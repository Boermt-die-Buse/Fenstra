/*
    Fenstra-Schnelleinstellungen: Unterseite „Bluetooth“ – bekannte Geräte (BlueZ).
    Klick verbindet bzw. trennt.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.bluezqt as BluezQt
import org.fenstra.shell

Item {
    ListView {
        id: liste
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: daten.bluetoothAn ? BluezQt.Manager.devices : []
        delegate: WinListenEintrag {
            required property var modelData
            width: liste.width
            height: 48
            symbol: modelData.icon || "bluetooth"
            symbolMaske: true
            symbolGroesse: 16
            titel: modelData.name
            untertitel: modelData.connected ? "Verbunden" : (modelData.paired ? "Gekoppelt" : "")
            ausgewaehlt: modelData.connected
            onClicked: modelData.connected ? modelData.disconnectFromDevice() : modelData.connectToDevice()
        }
    }
    WinText {
        visible: !daten.bluetoothAn || liste.count === 0
        x: 12
        y: 8
        width: parent.width - 24
        wrapMode: Text.WordWrap
        sekundaer: true
        text: !daten.bluetoothVerfuegbar ? "Kein Bluetooth-Adapter gefunden." : (!daten.bluetoothAn ? "Bluetooth ist deaktiviert." : "Keine Geräte gekoppelt.")
    }
}
