/*
    Fenstra-Infobereich: Schnelleinstellungen-Gruppe (Netz, Lautstärke, Akku) mit gemeinsamer
    Hover-Fläche. Klick öffnet eine erste Fassung der Schnelleinstellungen (Lautstärke-Regler,
    Netzstatus, Akku, Links zu den Einstellungen); die Windows-Fassung mit Kacheln folgt in M4.
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
            onPressed: warOffen = dialog.visible
            onClicked: dialog.visible = !warOffen
            onWheel: wheel => {
                if (gruppe.lautstaerke) {
                    gruppe.lautstaerke.setzen(gruppe.lautstaerke.prozent + (wheel.angleDelta.y > 0 ? 2 : -2));
                }
            }
        }
    }

    // ---------- Schnelleinstellungen (erste Fassung) ----------
    P5Support.DataSource {
        id: befehle
        engine: "executable"
        onNewData: (quelle, daten) => disconnectSource(quelle)
    }

    PlasmaCore.Dialog {
        id: dialog
        visible: false
        visualParent: gruppe
        location: PlasmaCore.Types.BottomEdge
        type: PlasmaCore.Dialog.PopupMenu
        hideOnWindowDeactivate: true
        flags: Qt.WindowStaysOnTopHint
        onVisibleChanged: if (visible) requestActivate()

        mainItem: ColumnLayout {
            width: 360
            spacing: 12

            // Lautstärke
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 8
                spacing: 8
                PC3.ToolButton {
                    icon.name: gruppe.tonSymbol
                    enabled: gruppe.lautstaerke && gruppe.lautstaerke.vorhanden
                    onClicked: gruppe.lautstaerke.umschalten()
                    PC3.ToolTip.text: "Stummschalten"
                    PC3.ToolTip.visible: hovered
                }
                PC3.Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    enabled: gruppe.lautstaerke && gruppe.lautstaerke.vorhanden
                    value: gruppe.lautstaerke ? gruppe.lautstaerke.prozent : 0
                    onMoved: gruppe.lautstaerke.setzen(value)
                }
                PC3.Label {
                    Layout.preferredWidth: 32
                    horizontalAlignment: Text.AlignRight
                    text: gruppe.lautstaerke && gruppe.lautstaerke.vorhanden ? gruppe.lautstaerke.prozent : "–"
                }
            }

            // Netz
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 12
                Kirigami.Icon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    source: netzSymbol.connectionIcon || "network-disconnect"
                }
                PC3.Label {
                    Layout.fillWidth: true
                    text: netzStatus.activeConnections || "Nicht verbunden"
                    wrapMode: Text.Wrap
                }
            }

            // Akku
            RowLayout {
                visible: gruppe.hatAkku
                Layout.fillWidth: true
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                spacing: 12
                Kirigami.Icon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    source: gruppe.akkuSymbol
                }
                PC3.Label {
                    Layout.fillWidth: true
                    text: gruppe.akkuProzent + " %" + (gruppe.laedt ? " (wird geladen)" : "")
                }
            }

            // Fußzeile mit Links zu den Einstellungen
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: info.randHover
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 4
                PC3.ToolButton {
                    text: "Netzwerk und Internet"
                    icon.name: "network-wired"
                    onClicked: { dialog.visible = false; befehle.connectSource("systemsettings kcm_networkmanagement"); }
                }
                Item { Layout.fillWidth: true }
                PC3.ToolButton {
                    text: "Sound"
                    icon.name: "audio-volume-high"
                    onClicked: { dialog.visible = false; befehle.connectSource("systemsettings kcm_pulseaudio"); }
                }
            }
        }
    }
}
