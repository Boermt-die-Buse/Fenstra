/*
    Fenstra-Benachrichtigungscenter (M4, docs/windows11-referenz.md 5.4): oberes Flyout der
    Zentrale. Kopf „Benachrichtigungen“ mit „Nicht stören“-Glocke und „Alle löschen“;
    Meldungen nach App gruppiert (Kopf mit App-Symbol 16 und Name), je Meldung eine Karte.
    Leer: „Keine neuen Benachrichtigungen“.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import org.fenstra.shell

FocusScope {
    id: zl

    property int maxHoehe: 600
    signal schliessen()

    readonly property int breite: 352
    width: breite
    implicitWidth: breite
    implicitHeight: 48 + (liste.count > 0 ? Math.min(liste.contentHeight + 8, maxHoehe - 48) : 72)
    height: implicitHeight
    Layout.minimumWidth: breite
    Layout.maximumWidth: breite
    Layout.minimumHeight: implicitHeight
    Layout.maximumHeight: implicitHeight
    Keys.onEscapePressed: zl.schliessen()

    NotificationManager.Settings {
        id: einstellungen
    }
    readonly property bool nichtStoeren: {
        const bis = einstellungen.notificationsInhibitedUntil;
        return !isNaN(bis.getTime()) && bis.getTime() > Date.now();
    }
    function nichtStoerenUmschalten() {
        if (nichtStoeren) {
            einstellungen.notificationsInhibitedUntil = undefined;
        } else {
            const bis = new Date();
            bis.setFullYear(bis.getFullYear() + 100);   // bis zum Ausschalten
            einstellungen.notificationsInhibitedUntil = bis;
        }
        einstellungen.save();
    }

    NotificationManager.Notifications {
        id: meldungen
        showExpired: true
        showDismissed: true
        showJobs: false
        showNotifications: true
        // Plasma hält Meldungen ohne App-Zuordnung („@other“, z. B. notify-send) aus dem Verlauf;
        // Windows zeigt alle Meldungen im Benachrichtigungscenter
        blacklistedDesktopEntries: (einstellungen.historyBlacklistedApplications || []).filter(x => x !== "@other")
        blacklistedNotifyRcNames: einstellungen.historyBlacklistedServices
        urgencies: NotificationManager.Notifications.CriticalUrgency | NotificationManager.Notifications.NormalUrgency
                   | (einstellungen.lowPriorityHistory ? NotificationManager.Notifications.LowUrgency : 0)
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.DescendingOrder
        groupMode: NotificationManager.Notifications.GroupApplicationsFlat
        groupLimit: 0
        expandUnread: true
    }
    function allesLoeschen() {
        meldungen.clear(NotificationManager.Notifications.ClearExpired);
        for (let i = meldungen.count - 1; i >= 0; --i) {
            meldungen.close(meldungen.index(i, 0));
        }
    }
    // Beim Öffnen gelten alle Meldungen als gelesen (Zähler an der Glocke verschwindet)
    function gelesen() {
        for (let i = 0; i < meldungen.count; ++i) {
            meldungen.setData(meldungen.index(i, 0), true, NotificationManager.Notifications.ReadRole);
        }
    }

    // ---------------- Kopf ----------------
    WinText {
        x: 16
        height: 48
        text: "Benachrichtigungen"
        stil: "bodyStrong"
    }
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        y: 8
        spacing: 4
        WinKnopf {
            width: 32
            height: 32
            art: "subtil"
            aktiv: zl.nichtStoeren
            symbol: zl.nichtStoeren ? "notifications-disabled" : "notifications"
            tooltip: "Nicht stören"
            onClicked: zl.nichtStoerenUmschalten()
        }
        WinKnopf {
            visible: liste.count > 0
            height: 32
            art: "subtil"
            text: "Alle löschen"
            schriftGroesse: 12
            onClicked: zl.allesLoeschen()
        }
    }

    // ---------------- Meldungen ----------------
    WinText {
        visible: liste.count === 0
        anchors.horizontalCenter: parent.horizontalCenter
        y: 48 + 16
        sekundaer: true
        text: "Keine neuen Benachrichtigungen"
    }

    ListView {
        id: liste
        x: 0
        y: 48
        width: parent.width
        height: parent.height - 48 - 4
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        spacing: 8
        model: meldungen
        delegate: Item {
            id: zeile
            required property int index
            required property var model
            readonly property bool istGruppe: model.isGroup === true
            width: liste.width
            height: istGruppe ? 32 : karte.implicitHeight + 24

            // App-Kopf einer Gruppe
            Item {
                visible: zeile.istGruppe
                anchors.fill: parent
                Kirigami.Icon {
                    x: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    source: zeile.model.applicationIconName || "preferences-desktop-notification"
                }
                WinText {
                    x: 40
                    anchors.verticalCenter: parent.verticalCenter
                    stil: "caption"
                    font.weight: Font.DemiBold
                    text: zeile.model.applicationName || ""
                }
                WinKnopf {
                    visible: kopfHover.hovered
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    height: 28
                    art: "subtil"
                    symbol: "window-close"
                    symbolGroesse: 12
                    tooltip: "Alle Benachrichtigungen dieser App löschen"
                    onClicked: meldungen.close(meldungen.index(zeile.index, 0))
                }
                HoverHandler {
                    id: kopfHover
                }
            }

            // Karte einer Meldung
            Rectangle {
                visible: !zeile.istGruppe
                x: 12
                width: parent.width - 24
                height: parent.height
                radius: 8
                color: kartenMaus.containsMouse ? Farben.karteZwei : Farben.karte
                border.width: 1
                border.color: Farben.karteRand

                MouseArea {
                    id: kartenMaus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (zeile.model.hasDefaultAction) {
                            meldungen.invokeDefaultAction(meldungen.index(zeile.index, 0),
                                zeile.model.resident ? NotificationManager.Notifications.None : NotificationManager.Notifications.Close);
                            zl.schliessen();
                        }
                    }
                }
                BenachrichtigungsKarte {
                    id: karte
                    x: 12
                    y: 12
                    width: parent.width - 24 - (schliessenKnopf.visible ? 24 : 0)
                    titel: zeile.model.summary || ""
                    text: zeile.model.body || ""
                    bild: zeile.model.image || null
                    symbolName: (zeile.model.image ? "" : (zeile.model.iconName || ""))
                    aktionNamen: zeile.model.actionNames || []
                    aktionTexte: zeile.model.actionLabels || []
                    onAktion: name => meldungen.invokeAction(meldungen.index(zeile.index, 0), name,
                                  zeile.model.resident ? NotificationManager.Notifications.None : NotificationManager.Notifications.Close)
                }
                WinKnopf {
                    id: schliessenKnopf
                    visible: kartenMaus.containsMouse || hovered
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    y: 6
                    width: 28
                    height: 28
                    art: "subtil"
                    symbol: "window-close"
                    symbolGroesse: 12
                    tooltip: "Schließen"
                    onClicked: meldungen.close(meldungen.index(zeile.index, 0))
                }
            }
        }
    }
    WinBildlauf {
        flick: liste
        x: liste.width - width
        y: liste.y
        height: liste.height
    }
}
