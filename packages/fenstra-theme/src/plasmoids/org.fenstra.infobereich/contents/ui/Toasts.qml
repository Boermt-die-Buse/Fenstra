/*
    Fenstra-Toasts (M4, docs/windows11-referenz.md 5.4): Benachrichtigungs-Popups unten rechts
    über der Taskleiste. Ersetzt die Popups des Plasma-Benachrichtigungs-Applets (das aus dem
    Systemabschnitt entfernt ist; der Benachrichtigungsdienst selbst bleibt in plasmashell und
    wird von jedem Notifications-Modell gestartet).

    Neueste Meldung unten, ältere wandern nach oben (12 px Abstand). Anzeige 5 s, Hover hält an,
    kritische Meldungen bleiben stehen. „Nicht stören“ unterdrückt alles außer kritischen.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.notificationmanager as NotificationManager
import org.kde.plasma.plasma5support as P5Support

Item {
    id: toasts

    width: 1
    height: parent ? parent.height : 0

    NotificationManager.Settings {
        id: einstellungen
    }
    property double jetzt: Date.now()
    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: toasts.jetzt = Date.now()
    }
    readonly property bool nichtStoeren: {
        const bis = einstellungen.notificationsInhibitedUntil;
        return !isNaN(bis.getTime()) && bis.getTime() > jetzt;
    }
    onNichtStoerenChanged: NotificationManager.Server.inhibited = nichtStoeren

    NotificationManager.Notifications {
        id: popups
        limit: 4
        showExpired: false
        showDismissed: false
        showJobs: false
        showNotifications: true
        showAddedDuringInhibition: false
        blacklistedDesktopEntries: einstellungen.popupBlacklistedApplications
        blacklistedNotifyRcNames: einstellungen.popupBlacklistedServices
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.DescendingOrder
        groupMode: NotificationManager.Notifications.GroupDisabled
        urgencies: {
            let u = 0;
            if (!toasts.nichtStoeren || einstellungen.criticalPopupsInDoNotDisturbMode) {
                u |= NotificationManager.Notifications.CriticalUrgency;
            }
            if (!toasts.nichtStoeren) {
                u |= NotificationManager.Notifications.NormalUrgency;
                if (einstellungen.lowPriorityPopups) {
                    u |= NotificationManager.Notifications.LowUrgency;
                }
            }
            return u;
        }
    }
    readonly property alias modell: popups

    // Stapeln: Versatz eines Toasts = Höhen der neueren (darunter liegenden) + Abstände
    property int stapelTakt: 0
    function versatz(nr) {
        stapelTakt;
        let v = 0;
        for (let j = 0; j < nr; ++j) {
            const o = liste.objectAt(j);
            if (o) {
                v += o.hoehe + 12;
            }
        }
        return v;
    }

    // Windows spielt zu jedem Toast den Benachrichtigungsklang (Apps mit eigener
    // Ereigniskonfiguration spielen ihren Klang selbst)
    P5Support.DataSource {
        id: klang
        engine: "executable"
        onNewData: (quelle, d) => disconnectSource(quelle)
    }
    function klangSpielen() {
        klang.connectSource("canberra-gtk-play -i message-new-instant -d fenstra-toast 2>/dev/null || "
                            + "pw-play /usr/share/sounds/fenstra/stereo/message-new-instant.oga 2>/dev/null #" + Date.now());
    }

    // Öffnet sich das Benachrichtigungscenter, wandern die Toasts hinein (Windows)
    Connections {
        target: info
        function onZentraleOffenChanged() {
            if (info.zentraleOffen) {
                for (let i = liste.count - 1; i >= 0; --i) {
                    const o = liste.objectAt(i);
                    if (o) {
                        o.abgelaufen();
                    }
                }
            }
        }
    }

    Instantiator {
        id: liste
        model: popups
        delegate: Toast {
            parent: toasts
        }
        onObjectAdded: (index, objekt) => {
            toasts.stapelTakt++;
            if (!objekt.hatEigenenKlang) {
                toasts.klangSpielen();
            }
        }
        onObjectRemoved: toasts.stapelTakt++
    }
}
