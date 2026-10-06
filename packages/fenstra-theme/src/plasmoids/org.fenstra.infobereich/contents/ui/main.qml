/*
    Fenstra-Infobereich (M3): rechtes Ende der Taskleiste wie Windows 11.

      … [Plasma-Systemabschnitt: ^ und App-Symbole] [ 📶 🔊 🔋 ] [ 01:12 / 06.10.2026 ] [🔔] ▏
                                                     └ Gruppe ┘   └──── Uhr ────┘        └ Desktop anzeigen

    Die Gruppe hat eine gemeinsame Hover-Fläche und öffnet eine erste Fassung der
    Schnelleinstellungen (Lautstärke, Netz, Akku); die vollständige Fassung folgt in M4.
    Die Uhr öffnet den Kalender. Der schmale Streifen ganz rechts zeigt den Desktop.

    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.dbus as DBus

PlasmoidItem {
    id: info

    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Farben wie in der Fenstra-Taskleiste
    readonly property bool dunkel: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark
    readonly property color textFarbe: Kirigami.Theme.textColor
    readonly property color textSekundaer: dunkel ? Qt.rgba(1, 1, 1, 0.786) : Qt.rgba(0, 0, 0, 0.62)
    readonly property color flaecheHover: dunkel ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.55)
    readonly property color flaecheAktiv: dunkel ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(1, 1, 1, 0.78)
    readonly property color flaecheGedrueckt: dunkel ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(1, 1, 1, 0.35)
    readonly property color randHover: dunkel ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.05)

    function kwinKuerzel(name) {
        DBus.SessionBus.asyncCall({
            service: "org.kde.kglobalaccel",
            path: "/component/kwin",
            iface: "org.kde.kglobalaccel.Component",
            member: "invokeShortcut",
            arguments: [name]
        });
    }

    fullRepresentation: RowLayout {
        Layout.minimumWidth: implicitWidth
        Layout.maximumWidth: implicitWidth
        Layout.fillHeight: true
        spacing: 0

        Gruppe {
            Layout.fillHeight: true
        }
        Uhr {
            Layout.fillHeight: true
        }
        Glocke {
            Layout.fillHeight: true
        }
        // Desktop anzeigen: schmaler Streifen ganz rechts
        Item {
            id: streifen
            Layout.fillHeight: true
            Layout.preferredWidth: 10
            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 16
                color: info.dunkel ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(0, 0, 0, 0.3)
                visible: streifenMaus.containsMouse
            }
            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: "Desktop anzeigen"
                location: PlasmaCore.Types.BottomEdge
                MouseArea {
                    id: streifenMaus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: info.kwinKuerzel("Show Desktop")
                }
            }
        }
    }
}
