/*
    Fenstra-Taskleiste: Anordnung. Widgets-Knopf links, die Gruppe Start · Suche ·
    Task-Ansicht · Apps mittig zur Bildschirmbreite (Windows richtet zur Bildschirmmitte
    aus, nicht zur Mitte des freien Platzes).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQml.Models

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.fenstra.shell

Item {
    id: bar

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: gruppe.width + (widgetsKnopf.visible ? widgetsKnopf.width + 24 : 0)

    // Lage des Applets im Panel-Fenster; das Panel ist so breit wie der Bildschirm,
    // daher ist das zugleich der Abstand zum linken Bildschirmrand.
    property real fensterX: 0
    function lageAktualisieren() {
        fensterX = bar.mapToItem(null, 0, 0).x;
    }
    onXChanged: lageAktualisieren()
    onWidthChanged: lageAktualisieren()
    Component.onCompleted: Qt.callLater(lageAktualisieren)
    Timer {
        // Panel-Aufbau ändert die Lage auch ohne eigene Größenänderung
        interval: 500; running: true; repeat: false
        onTriggered: bar.lageAktualisieren()
    }

    readonly property real bildschirmBreite: Plasmoid.containment.screenGeometry.width > 0
        ? Plasmoid.containment.screenGeometry.width : Screen.width
    // gewünschte linke Kante der Gruppe in Applet-Koordinaten
    readonly property real gruppeX: {
        if (!Plasmoid.configuration.centered) {
            return 12;
        }
        const links = (widgetsKnopf.visible ? widgetsKnopf.x + widgetsKnopf.width + 4 : 0);
        const mitte = bildschirmBreite / 2 - fensterX - gruppe.width / 2;
        return Math.max(links, Math.min(mitte, bar.width - gruppe.width));
    }

    // ---------------- Kontextmenü der freien Fläche ----------------
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onPressed: mouse => {
            leistenMenue.visualParent = bar;
            leistenMenue.open(mouse.x, mouse.y);
            mouse.accepted = true;
        }
    }
    PlasmaExtras.Menu {
        id: leistenMenue
        PlasmaExtras.MenuItem {
            text: "Task-Manager"
            icon: "utilities-system-monitor"
            onClicked: kicker.starteApp("org.kde.plasma-systemmonitor.desktop")
        }
        PlasmaExtras.MenuItem {
            text: "Taskleisteneinstellungen"
            icon: "configure"
            onClicked: Plasmoid.internalAction("configure").trigger()
        }
    }

    // ---------------- Widgets-Knopf (ganz links) ----------------
    WidgetsButton {
        id: widgetsKnopf
        visible: Plasmoid.configuration.showWidgets
        x: 4
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
    }

    // ---------------- Mittige Gruppe ----------------
    Row {
        id: gruppe
        x: Math.round(bar.gruppeX)
        height: parent.height
        spacing: 0

        Behavior on x {
            enabled: gruppe.width > 0
            NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
        }

        ShellButton {
            id: startKnopf
            height: gruppe.height
            // Fenstra-Symbol wie das Windows-Logo: blaues Fenster ohne Kachel (eigene SVGs);
            // ein in den Einstellungen gewähltes anderes Symbol hat Vorrang
            iconSource: Plasmoid.configuration.icon === "start-here"
                        ? Qt.resolvedUrl(kicker.dunkel ? "../icons/start-dunkel.svg" : "../icons/start.svg") : ""
            iconName: Plasmoid.icon
            toolTip: "Start"
            checked: kicker.startOpen
            onClicked: kicker.startOpen = !wasOpenOnPress
            property bool wasOpenOnPress: false
            onPressed: wasOpenOnPress = kicker.startOpen
            onRightClicked: schnelllinkMenue.oeffnen(startKnopf)
        }

        SearchPill {
            visible: Plasmoid.configuration.searchMode === 2
            height: gruppe.height
            onClicked: kicker.sucheOeffnen()
        }
        ShellButton {
            visible: Plasmoid.configuration.searchMode === 1
            height: gruppe.height
            iconName: "search"
            toolTip: "Suchen"
            onClicked: kicker.sucheOeffnen()
        }

        ShellButton {
            visible: Plasmoid.configuration.showTaskView
            height: gruppe.height
            iconSource: Qt.resolvedUrl("../icons/taskview.svg")
            iconIsMask: true
            toolTip: "Aktive Anwendungen"
            onClicked: kicker.kwinKuerzel("Overview")
        }

        Repeater {
            id: aufgaben
            model: kicker.tasksModel
            delegate: TaskButton {
                height: gruppe.height
                vorschau: vorschauDialog
                sprungliste: sprungListe
            }
        }
    }

    // Ankerpunkt für Startmenü und Suche: Bildschirmmitte, 12 px über der Taskleiste
    FlyoutAnker {
        id: startAnker
        x: bar.bildschirmBreite / 2 - bar.fensterX
    }

    WinFlyout {
        id: startDialog
        visible: kicker.startOpen
        visualParent: startAnker
        onVisibleChanged: {
            if (!visible) {
                kicker.startOpen = false;
            }
        }
        mainItem: StartMenu {
            width: 642 - 2 * startDialog.rand
            height: 726 - 2 * startDialog.rand
        }
    }
    Connections {
        target: kicker
        function onStartOpenChanged() {
            if (kicker.startOpen) {
                startAnker.aktualisieren();
            }
        }
    }


    // ---------------- Widgets-Board (von links) ----------------
    FlyoutAnker {
        id: widgetsAnker
        x: widgetsKnopf.x + widgetsKnopf.width / 2
    }
    WinFlyout {
        id: widgetsDialog
        visualParent: widgetsAnker
        visible: kicker.widgetsOffen
        onVisibleChanged: {
            if (!visible) {
                kicker.widgetsOffen = false;
            }
        }
        mainItem: WidgetsBoard {
            hoehe: Screen.height - 48 - 24 - 2 * widgetsDialog.rand
        }
    }
    Connections {
        target: kicker
        function onWidgetsOffenChanged() {
            if (kicker.widgetsOffen) {
                widgetsAnker.aktualisieren();
            }
        }
    }

    // Vorschau beim Hover und Sprungliste: je eine gemeinsame Instanz
    PreviewDialog {
        id: vorschauDialog
    }
    JumpList {
        id: sprungListe
    }
    QuickLinkMenu {
        id: schnelllinkMenue
    }
}
