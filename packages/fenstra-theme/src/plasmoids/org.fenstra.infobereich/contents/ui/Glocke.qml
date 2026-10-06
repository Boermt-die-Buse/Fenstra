/*
    Fenstra-Infobereich: Glocke rechts neben der Uhr (Windows 11 24H2). Sichtbar bei
    ungelesenen Benachrichtigungen (mit Zähler) oder bei „Nicht stören“.
    Klick öffnet Benachrichtigungen und Kalender (wie die Uhr).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

Item {
    id: glocke

    NotificationManager.Settings {
        id: einstellungen
    }
    NotificationManager.Notifications {
        id: benachrichtigungen
        showNotifications: true
        showJobs: false
        showExpired: true
        showDismissed: true
        blacklistedDesktopEntries: (einstellungen.historyBlacklistedApplications || []).filter(x => x !== "@other")
        blacklistedNotifyRcNames: einstellungen.historyBlacklistedServices
    }

    readonly property date bis: einstellungen.notificationsInhibitedUntil
    readonly property bool nichtStoeren: !isNaN(bis.getTime()) && bis.getTime() > Date.now()
    readonly property int ungelesen: benachrichtigungen.unreadNotificationsCount || 0
    readonly property bool sichtbar: nichtStoeren || ungelesen > 0

    visible: sichtbar
    implicitWidth: sichtbar ? 32 + 4 : 0

    Flaeche {
        x: 2
        width: parent.width - 4
        hover: maus.containsMouse
        gedrueckt: maus.pressed
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: 16
        height: 16
        source: glocke.nichtStoeren ? "notifications-disabled" : "notifications"
    }
    // Zähler (Akzentkreis mit Zahl)
    Rectangle {
        visible: !glocke.nichtStoeren && glocke.ungelesen > 0
        x: parent.width / 2 + 2
        y: parent.height / 2 - 12
        width: Math.max(14, zahl.implicitWidth + 6)
        height: 14
        radius: 7
        color: Kirigami.Theme.highlightColor
        Text {
            id: zahl
            anchors.centerIn: parent
            text: glocke.ungelesen > 9 ? "9+" : glocke.ungelesen
            color: "white"
            font.pixelSize: 9
            font.weight: Font.DemiBold
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: glocke.nichtStoeren ? "Nicht stören ist aktiviert" : glocke.ungelesen + " neue Benachrichtigungen"
        location: PlasmaCore.Types.BottomEdge
        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            property bool warOffen: false
            onPressed: warOffen = info.zentraleOffen
            onClicked: info.zentraleOffen = !warOffen
        }
    }
}
