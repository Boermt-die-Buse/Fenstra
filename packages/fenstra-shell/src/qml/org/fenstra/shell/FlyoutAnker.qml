/*
    Fenstra-Shell: unsichtbarer Anker für WinFlyout. Liegt (im Koordinatensystem der Taskleiste)
    „abstand“ + „versatz“ Pixel über der Oberkante der Taskleiste; Plasma setzt die Unterkante
    des Flyouts genau an die Oberkante des Ankers. Vor dem Öffnen aktualisieren() aufrufen
    (die Lage des Applets im Panel steht erst nach dem Aufbau fest).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Item {
    id: anker

    property real abstand: 12
    property real versatz: 0
    property real fensterY: 0       // Abstand des Elternelements zur Oberkante des Panel-Fensters

    function aktualisieren() {
        if (parent) {
            fensterY = parent.mapToItem(null, 0, 0).y;
        }
    }

    width: 1
    height: 1
    y: -abstand - versatz - fensterY
    Component.onCompleted: Qt.callLater(aktualisieren)
}
