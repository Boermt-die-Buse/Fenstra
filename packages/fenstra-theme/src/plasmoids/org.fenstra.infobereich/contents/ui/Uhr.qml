/*
    Fenstra-Infobereich: Uhr wie Windows 11 – zwei Zeilen, 12 px, rechtsbündig
    („01:12“ / „06.10.2026“), Hover-Fläche Radius 4, Tooltip mit dem langen Datum.
    Klick und Win+N: Benachrichtigungen und Kalender (Zentrale.qml). Rechtsklick: „Datum und Uhrzeit anpassen“, „Benachrichtigungseinstellungen“.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as P5Support

Item {
    id: uhr

    property date jetzt: new Date()
    readonly property string zeit: Qt.formatTime(jetzt, Plasmoid.configuration.showSeconds ? "hh:mm:ss" : "hh:mm")
    readonly property string datum: Qt.formatDate(jetzt, "dd.MM.yyyy")

    implicitWidth: Math.max(zeitText.implicitWidth, datumText.implicitWidth) + 2 * 8 + 4

    // zur vollen Minute (bzw. Sekunde) weiterschalten
    Timer {
        id: takt
        running: true
        repeat: false
        interval: 1000
        onTriggered: {
            uhr.jetzt = new Date();
            interval = Plasmoid.configuration.showSeconds ? 1000 - uhr.jetzt.getMilliseconds()
                                                          : 60000 - (uhr.jetzt.getSeconds() * 1000 + uhr.jetzt.getMilliseconds());
            start();
        }
    }

    Flaeche {
        x: 2
        width: parent.width - 4
        hover: maus.containsMouse
        gedrueckt: maus.pressed
        aktiv: info.zentraleOffen
    }

    Column {
        anchors.right: parent.right
        anchors.rightMargin: 2 + 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        Text {
            id: zeitText
            anchors.right: parent.right
            text: uhr.zeit
            color: info.textFarbe
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 12
            renderType: Text.NativeRendering
        }
        Text {
            id: datumText
            anchors.right: parent.right
            text: uhr.datum
            color: info.textFarbe
            font.family: Kirigami.Theme.defaultFont.family
            font.pixelSize: 12
            renderType: Text.NativeRendering
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        active: !info.zentraleOffen
        mainText: uhr.jetzt.toLocaleDateString(Qt.locale(), "dddd, d. MMMM yyyy")
        location: PlasmaCore.Types.BottomEdge

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            property bool warOffen: false
            onPressed: mouse => warOffen = info.zentraleOffen
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    menue.visualParent = uhr;
                    menue.openRelative();
                } else {
                    info.zentraleOffen = !warOffen;
                }
            }
        }
    }

    P5Support.DataSource {
        id: befehle
        engine: "executable"
        onNewData: (quelle, daten) => disconnectSource(quelle)
    }
    PlasmaExtras.Menu {
        id: menue
        placement: PlasmaExtras.Menu.TopPosedRightAlignedPopup
        PlasmaExtras.MenuItem {
            text: "Datum und Uhrzeit anpassen"
            icon: "preferences-system-time"
            onClicked: befehle.connectSource("systemsettings kcm_clock")
        }
        PlasmaExtras.MenuItem {
            text: "Benachrichtigungseinstellungen"
            icon: "preferences-desktop-notification"
            onClicked: befehle.connectSource("systemsettings kcm_notifications")
        }
    }
}
