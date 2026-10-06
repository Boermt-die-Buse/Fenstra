/*
    Fenstra-Schnelleinstellungen: Medien-Flyout über den Schnelleinstellungen (Windows 11, bei
    laufender oder pausierter Wiedergabe): App-Symbol und -Name, Cover, Titel, Interpret,
    ⏮ ⏯ ⏭. Daten über MPRIS (org.kde.plasma.private.mpris).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris
import org.fenstra.shell

Item {
    id: medien

    readonly property var spieler: mpris.currentPlayer
    readonly property bool aktiv: spieler !== null && spieler !== undefined
                                  && (spieler.playbackStatus === Mpris.PlaybackStatus.Playing
                                      || spieler.playbackStatus === Mpris.PlaybackStatus.Paused)
    readonly property bool spielt: aktiv && spieler.playbackStatus === Mpris.PlaybackStatus.Playing

    width: 352
    height: 132
    implicitWidth: 352
    implicitHeight: 132

    Mpris.Mpris2Model {
        id: mpris
    }

    // Kopf: App
    Kirigami.Icon {
        id: appSymbol
        x: 16
        y: 14
        width: 16
        height: 16
        source: medien.aktiv ? (medien.spieler.iconName || "media-playback-start") : ""
    }
    WinText {
        anchors.left: appSymbol.right
        anchors.leftMargin: 8
        anchors.verticalCenter: appSymbol.verticalCenter
        stil: "caption"
        sekundaer: true
        text: medien.aktiv ? (medien.spieler.identity || "") : ""
    }

    // Cover und Titel
    Rectangle {
        id: cover
        x: 16
        y: 42
        width: 48
        height: 48
        radius: 4
        color: Farben.controlFill
        clip: true
        Kirigami.Icon {
            anchors.centerIn: parent
            visible: !bild.visible
            width: 24
            height: 24
            source: "audio-x-generic"
        }
        Image {
            id: bild
            anchors.fill: parent
            visible: status === Image.Ready
            source: medien.aktiv ? (medien.spieler.artUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
            sourceSize.width: 96
        }
    }
    Column {
        anchors.left: cover.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: cover.verticalCenter
        WinText {
            width: parent.width
            stil: "bodyStrong"
            text: medien.aktiv ? (medien.spieler.track || medien.spieler.identity || "") : ""
        }
        WinText {
            width: parent.width
            stil: "caption"
            sekundaer: true
            text: medien.aktiv ? (medien.spieler.artist || "") : ""
        }
    }

    // Steuerung
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        y: 92
        spacing: 8
        WinKnopf {
            width: 40
            height: 36
            art: "subtil"
            symbol: "media-skip-backward"
            tooltip: "Zurück"
            enabled: medien.aktiv && medien.spieler.canGoPrevious
            onClicked: medien.spieler.Previous()
        }
        WinKnopf {
            width: 40
            height: 36
            art: "subtil"
            symbol: medien.spielt ? "media-playback-pause" : "media-playback-start"
            tooltip: medien.spielt ? "Anhalten" : "Wiedergeben"
            enabled: medien.aktiv
            onClicked: medien.spieler.PlayPause()
        }
        WinKnopf {
            width: 40
            height: 36
            art: "subtil"
            symbol: "media-skip-forward"
            tooltip: "Weiter"
            enabled: medien.aktiv && medien.spieler.canGoNext
            onClicked: medien.spieler.Next()
        }
    }
}
