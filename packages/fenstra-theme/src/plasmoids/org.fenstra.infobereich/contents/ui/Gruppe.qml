/*
    Fenstra-Infobereich: Schnelleinstellungen-Gruppe (Netz, Lautstärke, Akku) mit gemeinsamer
    Hover-Fläche. Klick und Win+A öffnen die Schnelleinstellungen (SchnellEinstellungen.qml).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.plasma.plasma5support as P5Support
import org.fenstra.shell

Item {
    id: gruppe

    implicitWidth: symbole.implicitWidth + 2 * 8 + 4

    // ---------- Zustände ----------
    PlasmaNM.ConnectionIcon {
        id: netzSymbol
    }
    PlasmaNM.NetworkStatus {
        id: netzStatus
    }
    Loader {
        id: ton
        source: "Lautstaerke.qml"
    }
    readonly property var lautstaerke: ton.item
    readonly property string tonSymbol: {
        if (!lautstaerke || lautstaerke.stumm || lautstaerke.prozent === 0) {
            return "audio-volume-muted";
        }
        return lautstaerke.prozent < 34 ? "audio-volume-low" : (lautstaerke.prozent < 67 ? "audio-volume-medium" : "audio-volume-high");
    }

    P5Support.DataSource {
        id: energie
        engine: "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
    }
    readonly property var akku: energie.data["Battery"] || {}
    readonly property bool hatAkku: akku["Has Battery"] === true
    readonly property int akkuProzent: akku["Percent"] || 0
    readonly property bool laedt: akku["State"] === "Charging"
    readonly property string akkuSymbol: {
        const stufe = String(Math.round(akkuProzent / 10) * 10).padStart(3, "0");
        return "battery-" + stufe + (laedt ? "-charging" : "");
    }

    // ---------- Darstellung ----------
    Flaeche {
        x: 2
        width: parent.width - 4
        hover: maus.containsMouse
        gedrueckt: maus.pressed
        aktiv: dialog.visible
    }

    Row {
        id: symbole
        anchors.centerIn: parent
        spacing: 8
        Kirigami.Icon {
            width: 16
            height: 16
            source: netzSymbol.connectionIcon || "network-disconnect"
        }
        Kirigami.Icon {
            width: 16
            height: 16
            source: gruppe.tonSymbol
        }
        Kirigami.Icon {
            visible: gruppe.hatAkku
            width: 16
            height: 16
            source: gruppe.akkuSymbol
        }
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        active: !dialog.visible
        mainText: netzStatus.activeConnections || "Nicht verbunden"
        subText: (gruppe.lautstaerke && gruppe.lautstaerke.vorhanden
                  ? "Lautsprecher: " + (gruppe.lautstaerke.stumm ? "stumm" : gruppe.lautstaerke.prozent + " %")
                  : "Kein Audiogerät")
                 + (gruppe.hatAkku ? "\nAkku: " + gruppe.akkuProzent + " %" : "")
        location: PlasmaCore.Types.BottomEdge

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            property bool warOffen: false
            onPressed: warOffen = info.qsOffen
            onClicked: info.qsOffen = !warOffen
            onWheel: wheel => {
                if (gruppe.lautstaerke) {
                    gruppe.lautstaerke.setzen(gruppe.lautstaerke.prozent + (wheel.angleDelta.y > 0 ? 2 : -2));
                }
            }
        }
    }

    // ---------- Schnelleinstellungen (M4) ----------
    // Anker 12 px über der Taskleiste; „floating“ hält 12 px Abstand zum rechten Bildschirmrand
    FlyoutAnker {
        id: anker
        x: gruppe.width / 2
    }
    WinFlyout {
        id: dialog
        visualParent: anker
        visible: info.qsOffen
        onVisibleChanged: {
            if (!visible) {
                info.qsOffen = false;
            }
        }
        onHeightChanged: Qt.callLater(gruppe.medienNeuSetzen)
        mainItem: SchnellEinstellungen {
            id: inhalt
            onSchliessen: info.qsOffen = false
            // Anker für das Medien-Flyout: 12 px über der Oberkante der Schnelleinstellungen
            Item {
                id: medienAnker
                x: inhalt.width / 2
                y: -dialog.rand - 12
                width: 1
                height: 1
            }
        }
    }
    // Medien-Flyout über den Schnelleinstellungen (nur bei laufender/pausierter Wiedergabe);
    // Kindfenster der Schnelleinstellungen, damit Plasma beim Fokuswechsel keines schließt
    WinFlyout {
        id: medienFlyout
        visualParent: medienAnker
        visible: info.qsOffen && dialog.visible && medienInhalt.aktiv
        mainItem: QsMedien {
            id: medienInhalt
        }
    }
    function medienNeuSetzen() {
        if (medienFlyout.visible) {
            medienFlyout.visualParent = null;
            medienFlyout.visualParent = medienAnker;
        }
    }
    Connections {
        target: info
        function onQsOffenChanged() {
            if (info.qsOffen) {
                anker.aktualisieren();
                inhalt.zuruecksetzen();
            }
        }
    }
}
