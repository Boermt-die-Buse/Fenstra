/*
    Fenstra-Toast (eine Benachrichtigung, docs/windows11-referenz.md 5.4): Breite 364, Radius 8,
    Acrylic; Kopf mit App-Symbol 16, App-Name 12 px, „…“ und „X“ (beim Hover); darunter Titel,
    Text und Aktionsknöpfe. Gleitet von rechts herein (300 ms).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager
import org.fenstra.shell

Item {
    id: toast

    required property int index
    required property var model

    readonly property var mod: toasts.modell
    readonly property int hoehe: dialog.height
    readonly property bool kritisch: model.urgency === NotificationManager.Notifications.CriticalUrgency
    readonly property bool hatAktionen: model.hasDefaultAction || (model.actionLabels || []).length > 0
    readonly property bool hatEigenenKlang: (model.notifyRcName || "").length > 0
    readonly property bool hover: maus.containsMouse || kopfHover.hovered

    width: 1
    height: 1

    function modellIndex() {
        return mod.index(toast.index, 0);
    }
    function abgelaufen() {
        if (model.resident || (hatAktionen && !model.transient)) {
            model.expired = true;          // bleibt in der Zentrale benutzbar
        } else {
            mod.expire(modellIndex());
        }
    }

    // Anker: 12 px über der Taskleiste plus Höhe der neueren Toasts darunter
    FlyoutAnker {
        id: anker
        versatz: toasts.versatz(toast.index)
        onVersatzChanged: Qt.callLater(toast.neuSetzen)
    }
    function neuSetzen() {
        if (dialog.visible) {
            dialog.visualParent = null;
            dialog.visualParent = anker;
        }
    }

    Timer {
        id: anzeige
        interval: toast.model.timeout > 0 ? Math.max(5000, toast.model.timeout) : 5000
        running: dialog.visible && !toast.hover && !toast.kritisch
        onTriggered: toast.abgelaufen()
    }

    PlasmaCore.Dialog {
        id: dialog
        visualParent: anker
        location: PlasmaCore.Types.BottomEdge
        type: PlasmaCore.Dialog.Notification
        flags: Qt.WindowStaysOnTopHint | Qt.WindowDoesNotAcceptFocus
        hideOnWindowDeactivate: false
        backgroundHints: PlasmaCore.Types.StandardBackground
        floating: 12
        visible: false

        mainItem: Item {
            id: rahmen
            width: 356
            readonly property real inhaltHoehe: kopf.height + karte.implicitHeight + 12
            height: inhaltHoehe
            Layout.minimumWidth: 356
            Layout.maximumWidth: 356
            Layout.minimumHeight: inhaltHoehe
            Layout.maximumHeight: inhaltHoehe
            clip: true

            Item {
                id: inhalt
                width: parent.width
                height: parent.height
                x: 0
                opacity: 1

                MouseArea {
                    id: maus
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton) {
                            toast.mod.close(toast.modellIndex());
                        } else if (toast.model.hasDefaultAction) {
                            toast.mod.invokeDefaultAction(toast.modellIndex(),
                                toast.model.resident ? NotificationManager.Notifications.None : NotificationManager.Notifications.Close);
                        } else {
                            toast.abgelaufen();
                        }
                    }
                }

                // Kopf: App-Symbol, App-Name, „…“, „X“
                Item {
                    id: kopf
                    width: parent.width
                    height: 36
                    HoverHandler {
                        id: kopfHover
                    }
                    Kirigami.Icon {
                        x: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        source: toast.model.applicationIconName || "preferences-desktop-notification"
                    }
                    WinText {
                        x: 36
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 36 - 72
                        stil: "caption"
                        text: toast.model.applicationName || ""
                    }
                    Row {
                        visible: toast.hover
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        WinKnopf {
                            id: mehrKnopf
                            width: 32
                            height: 28
                            art: "subtil"
                            symbol: "overflow-menu"
                            symbolGroesse: 12
                            tooltip: "Weitere Optionen"
                            onClicked: {
                                const l = [];
                                if (toast.model.configurable) {
                                    l.push({text: toast.model.configureActionLabel || "Benachrichtigungseinstellungen",
                                            symbol: "configure", aktion: () => toast.mod.configure(toast.modellIndex())});
                                }
                                l.push({text: "Zu den Benachrichtigungseinstellungen wechseln", symbol: "preferences-desktop-notification",
                                        aktion: () => toast.mod.configure(toast.modellIndex())});
                                menue.zeigen(mehrKnopf, l);
                            }
                        }
                        WinKnopf {
                            width: 32
                            height: 28
                            art: "subtil"
                            symbol: "window-close"
                            symbolGroesse: 12
                            tooltip: "Schließen"
                            onClicked: toast.mod.close(toast.modellIndex())
                        }
                    }
                }

                BenachrichtigungsKarte {
                    id: karte
                    x: 12
                    y: kopf.height
                    width: parent.width - 24
                    titel: toast.model.summary || ""
                    text: toast.model.body || ""
                    bild: toast.model.image || null
                    symbolName: toast.model.image ? "" : (toast.model.iconName || "")
                    aktionNamen: toast.model.actionNames || []
                    aktionTexte: toast.model.actionLabels || []
                    onAktion: name => toast.mod.invokeAction(toast.modellIndex(), name,
                                  toast.model.resident ? NotificationManager.Notifications.None : NotificationManager.Notifications.Close)
                }
            }

            // von rechts hereingleiten
            ParallelAnimation {
                id: hereingleiten
                NumberAnimation { target: inhalt; property: "x"; from: 80; to: 0; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: inhalt; property: "opacity"; from: 0; to: 1; duration: 200 }
            }
        }
    }

    WinKontextmenue {
        id: menue
    }

    Component.onCompleted: {
        // das Modell soll nicht selbst ablaufen lassen; die Anzeigedauer regelt dieser Toast
        mod.stopTimeout(modellIndex());
        anker.aktualisieren();
        dialog.visible = true;
        hereingleiten.start();
    }
    Component.onDestruction: dialog.visible = false
}
