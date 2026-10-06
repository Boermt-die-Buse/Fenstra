/*
    Fenstra-Widgets: Notizen – kurzer Text, wird in der Applet-Konfiguration gespeichert.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasmoid
import org.fenstra.shell

Item {
    Flickable {
        id: f
        anchors.fill: parent
        clip: true
        contentHeight: eingabe.contentHeight
        TextEdit {
            id: eingabe
            width: f.width
            wrapMode: TextEdit.Wrap
            color: Farben.text
            selectionColor: Farben.akzent
            selectedTextColor: "#FFFFFF"
            font.family: Farben.schrift
            font.pixelSize: 14
            renderType: Text.NativeRendering
            selectByMouse: true
            text: Plasmoid.configuration.notizen
            onTextChanged: speichern.restart()
            WinText {
                visible: eingabe.text.length === 0 && !eingabe.activeFocus
                sekundaer: true
                text: "Notiz eingeben …"
            }
        }
    }
    Timer {
        id: speichern
        interval: 800
        onTriggered: Plasmoid.configuration.notizen = eingabe.text
    }
}
