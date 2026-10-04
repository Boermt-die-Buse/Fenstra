/*
    Fenstra-Startmenü: Knopf in der Taskleiste
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

Item {
    id: button

    implicitWidth: Kirigami.Units.iconSizes.medium
    implicitHeight: Kirigami.Units.iconSizes.medium

    Kirigami.Icon {
        anchors.fill: parent
        anchors.margins: Math.round(Math.min(parent.width, parent.height) * 0.1)
        source: Plasmoid.icon
        active: mouseArea.containsMouse || kicker.expanded
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        // Popup schließt bei Fokusverlust; Zustand beim Drücken merken, damit ein
        // Klick auf den Knopf das offene Menü schließt statt es neu zu öffnen.
        property bool wasExpanded: false
        onPressed: wasExpanded = kicker.expanded
        onClicked: kicker.expanded = !wasExpanded
    }
}
