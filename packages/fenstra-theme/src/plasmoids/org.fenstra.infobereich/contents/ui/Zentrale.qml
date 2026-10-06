/*
    Fenstra-Zentrale (M4, docs/windows11-referenz.md 5.4): Benachrichtigungen (oben) und
    Kalender (unten) als zwei gestapelte Flyouts rechts unten, je 12 px Abstand zu Rand,
    Taskleiste und zueinander. Öffnen: Klick auf Uhr oder Glocke, Win+N.

    Das obere Flyout hängt als Kindfenster am Kalender (visualParent ist ein Anker im Kalender):
    So schließt Plasma keines der beiden, wenn der Fokus zwischen ihnen wechselt, aber beide,
    sobald außerhalb geklickt wird.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Window

import org.fenstra.shell

Item {
    id: zentrale

    width: 1
    height: parent ? parent.height : 0

    FlyoutAnker {
        id: kalenderAnker
        x: 0
    }

    WinFlyout {
        id: kalenderFlyout
        visualParent: kalenderAnker
        visible: info.zentraleOffen
        onVisibleChanged: {
            if (!visible) {
                info.zentraleOffen = false;
            }
        }
        onHeightChanged: Qt.callLater(zentrale.obenNeuSetzen)
        mainItem: Kalender {
            id: kalender
            onSchliessen: info.zentraleOffen = false
            // Anker für das obere Flyout: 12 px über der Oberkante des Kalenderfensters
            Item {
                id: listenAnker
                x: kalender.width / 2
                y: -kalenderFlyout.rand - 12
                width: 1
                height: 1
            }
        }
    }

    WinFlyout {
        id: listenFlyout
        visualParent: listenAnker
        visible: info.zentraleOffen && kalenderFlyout.visible
        mainItem: ZentraleListe {
            id: liste
            // Platz über dem Kalender: Bildschirmhöhe minus Taskleiste und Ränder
            maxHoehe: (Screen.height - 48) - 12 - kalenderFlyout.height - 12 - 12 - 8
            onSchliessen: info.zentraleOffen = false
        }
    }

    function obenNeuSetzen() {
        if (listenFlyout.visible) {
            listenFlyout.visualParent = null;
            listenFlyout.visualParent = listenAnker;
        }
    }

    Connections {
        target: info
        function onZentraleOffenChanged() {
            if (info.zentraleOffen) {
                kalenderAnker.aktualisieren();
                kalender.zuruecksetzen();
                liste.gelesen();
            }
        }
    }
}
