/*
    Fenstra-Schnelleinstellungen: Unterseite „Soundausgabe“ – Ausgabegeräte (plasma-pa),
    Klick wählt das Standardgerät.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.private.volume
import org.fenstra.shell

Item {
    SinkModel {
        id: senken
    }
    ListView {
        id: liste
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        model: senken
        delegate: WinListenEintrag {
            required property var model
            width: liste.width
            visible: model.PulseObject && model.PulseObject.name !== "auto_null"
            height: visible ? 48 : 0
            symbol: "audio-speakers"
            symbolMaske: true
            symbolGroesse: 16
            titel: model.Description || ""
            ausgewaehlt: model.PulseObject && model.PulseObject.default
            onClicked: model.PulseObject.default = true
        }
    }
    WinText {
        visible: liste.contentHeight < 1
        x: 12
        y: 8
        width: parent.width - 24
        wrapMode: Text.WordWrap
        sekundaer: true
        text: "Es wurden keine Audioausgabegeräte gefunden."
    }
}
