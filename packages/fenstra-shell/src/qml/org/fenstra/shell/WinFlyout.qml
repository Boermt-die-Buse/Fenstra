/*
    Fenstra-Shell: Flyout-Fenster wie in Windows 11 (docs/windows11-referenz.md 5): schwebend
    mit 12 px Abstand zu Taskleiste und Bildschirmrändern, alle vier Ecken gerundet (Plasma
    zeichnet bei floating > 0 alle Ränder), Acrylic-Hintergrund aus dem Plasma-Design „fenstra“.

    Abstand zur Taskleiste: Plasma setzt ein Popup bündig an sein visualParent. Deshalb dient
    als visualParent ein unsichtbarer Anker 12 px über der Taskleiste (siehe FlyoutAnker.qml).
    Seitlich hält „floating“ den Abstand zu den Bildschirmrändern ein.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.core as PlasmaCore

PlasmaCore.Dialog {
    id: flyout

    // Innenabstand des Plasma-Hintergrunds (dialogs/background, 4 px) – für randlose Fußleisten
    readonly property int rand: 4

    location: PlasmaCore.Types.BottomEdge
    type: PlasmaCore.Dialog.PopupMenu
    hideOnWindowDeactivate: true
    flags: Qt.WindowStaysOnTopHint
    backgroundHints: PlasmaCore.Types.StandardBackground
    floating: 12
    visible: false

    onVisibleChanged: {
        if (visible) {
            requestActivate();
        }
    }
}
