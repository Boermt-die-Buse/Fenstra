/*
    Fenstra-Widgets: Fotos – Bilder aus dem Ordner „Bilder“ im Wechsel (alle 15 s); ohne eigene
    Bilder die Fenstra-Hintergründe. Klick öffnet den Bilderordner.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtCore
import Qt.labs.folderlistmodel

import org.fenstra.shell

Item {
    id: f

    property int nr: 0
    readonly property var ersatz: ["file:///usr/share/wallpapers/Fenstra/contents/images/1920x1080.jpg",
                                   "file:///usr/share/wallpapers/Fenstra/contents/images_dark/1920x1080.jpg"]
    readonly property int anzahl: bilder.count > 0 ? bilder.count : ersatz.length
    readonly property url aktuell: bilder.count > 0 ? bilder.get(nr % bilder.count, "fileUrl") : ersatz[nr % ersatz.length]

    FolderListModel {
        id: bilder
        folder: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
        showDirs: false
        sortField: FolderListModel.Time
    }
    Timer {
        interval: 15000
        running: f.visible && f.anzahl > 1
        repeat: true
        onTriggered: f.nr = (f.nr + 1) % f.anzahl
    }

    Rectangle {
        anchors.fill: parent
        radius: 4
        color: Farben.controlFill
        clip: true
        Image {
            anchors.fill: parent
            source: f.aktuell
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize.width: 512
        }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            Qt.openUrlExternally(StandardPaths.writableLocation(StandardPaths.PicturesLocation));
            kicker.widgetsOffen = false;
        }
    }
}
