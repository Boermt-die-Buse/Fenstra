/*
    Fenstra-Taskleiste: Vorschau beim Überfahren eines App-Knopfs (Windows 11 4.5).

      ┌──────────────────────────┐
      │ ▣ Titel des Fensters   ✕ │   Kopfzeile: Symbol 16, Titel 12 px, „X“ beim Hover
      │ ┌──────────────────────┐ │
      │ │     Vorschaubild     │ │   Bild höchstens 200×120 (PipeWire-Mitschnitt von KWin)
      │ └──────────────────────┘ │
      └──────────────────────────┘

    Erscheint nach 400 ms, bei mehreren Fenstern nebeneinander. Klick aktiviert das Fenster.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager
import org.kde.pipewire as PipeWire

// Steuerung als Item: ein PlasmaCore.Dialog nimmt keine Timer als Kinder an.
Item {
    id: dialog

    property Item knopf: null          // Knopf, zu dem die Vorschau gehört
    property Item wartenderKnopf: null
    property var eintraege: []         // [{zeile, kind}] je Fenster
    property bool fest: false          // per Klick geöffnet (mehrere Fenster)
    property alias offen: fenster.visible

    function hoverStart(k) {
        verstecken.stop();
        if (dialog.offen) {
            zeige(k);
        } else {
            wartenderKnopf = k;
            verzoegerung.restart();
        }
    }
    function hoverEnde(k) {
        if (wartenderKnopf === k) {
            verzoegerung.stop();
            wartenderKnopf = null;
        }
        if (dialog.offen && knopf === k) {
            verstecken.restart();
        }
    }
    function hoverAbbrechen() {
        verzoegerung.stop();
        wartenderKnopf = null;
        if (!fest) {
            dialog.offen = false;
        }
    }
    function zeigeFest(k) {
        fest = true;
        zeige(k);
    }
    function zeige(k) {
        knopf = k;
        neuAufbauen();
        // erst anzeigen, wenn die Einträge angelegt sind (sonst „empty dialog“)
        Qt.callLater(() => {
            dialog.offen = eintraege.length > 0;
        });
    }
    function neuAufbauen() {
        if (!knopf) {
            eintraege = [];
            return;
        }
        const tm = kicker.tasksModel;
        const zeile = knopf.index;
        const kinder = tm.data(tm.makeModelIndex(zeile), TaskManager.AbstractTasksModel.ChildCount) || 0;
        const liste = [];
        if (kinder > 0) {
            for (let i = 0; i < kinder; ++i) {
                liste.push({zeile: zeile, kind: i});
            }
        } else if (!tm.data(tm.makeModelIndex(zeile), TaskManager.AbstractTasksModel.IsLauncher)) {
            liste.push({zeile: zeile, kind: -1});
        }
        eintraege = liste;
    }


    Timer {
        id: verzoegerung
        interval: 400
        onTriggered: {
            if (dialog.wartenderKnopf) {
                dialog.zeige(dialog.wartenderKnopf);
                dialog.wartenderKnopf = null;
            }
        }
    }
    Timer {
        id: verstecken
        interval: 300
        onTriggered: {
            if (!inhaltMaus.containsMouse) {
                dialog.offen = false;
            }
        }
    }

    // Fenster kommen/gehen, Titel ändern sich: Vorschau aktualisieren
    Connections {
        target: kicker.tasksModel
        enabled: dialog.offen
        function onRowsInserted() { Qt.callLater(dialog.neuAufbauen); }
        function onRowsRemoved() { Qt.callLater(dialog.neuAufbauen); }
        function onDataChanged() { Qt.callLater(dialog.neuAufbauen); }
    }

    PlasmaCore.Dialog {
        id: fenster
        visible: false
        visualParent: dialog.knopf
        location: PlasmaCore.Types.BottomEdge
        type: PlasmaCore.Dialog.Tooltip
        flags: Qt.WindowDoesNotAcceptFocus
        backgroundHints: PlasmaCore.Types.StandardBackground
        onVisibleChanged: {
            if (!visible) {
                dialog.fest = false;
            }
        }

        mainItem: MouseArea {
            id: inhaltMaus
            hoverEnabled: true
            // Größe aus der Anzahl der Fenster (die Row rechnet ihre Breite erst später)
            width: Math.max(1, dialog.eintraege.length * 216 + Math.max(0, dialog.eintraege.length - 1) * 4)
            height: 24 + 8 + 120 + 8 + 8
            onContainsMouseChanged: {
                if (containsMouse) {
                    verstecken.stop();
                } else {
                    verstecken.restart();
                }
            }

            Row {
                id: zeileInhalt
                spacing: 4

                Repeater {
                    model: dialog.eintraege
                    delegate: Item {
                        id: eintrag
                        required property var modelData

                        readonly property var idx: modelData.kind >= 0
                            ? kicker.tasksModel.makeModelIndex(modelData.zeile, modelData.kind)
                            : kicker.tasksModel.makeModelIndex(modelData.zeile)
                        readonly property string titel: kicker.tasksModel.data(idx, Qt.DisplayRole) || ""
                        readonly property var symbol: kicker.tasksModel.data(idx, Qt.DecorationRole)
                        readonly property var fensterIds: kicker.tasksModel.data(idx, TaskManager.AbstractTasksModel.WinIdList) || []

                        width: 216
                        height: 24 + 8 + 120 + 8 + 8

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: eintragMaus.containsMouse ? kicker.flaecheHover : "transparent"
                            border.width: eintragMaus.containsMouse ? 1 : 0
                            border.color: kicker.randHover
                        }

                        // Kopfzeile
                        Kirigami.Icon {
                            id: kopfSymbol
                            x: 8
                            y: 8 + 4
                            width: 16
                            height: 16
                            source: eintrag.symbol
                        }
                        Text {
                            anchors.left: kopfSymbol.right
                            anchors.leftMargin: 8
                            anchors.right: schliessen.left
                            anchors.rightMargin: 4
                            anchors.verticalCenter: kopfSymbol.verticalCenter
                            text: eintrag.titel
                            elide: Text.ElideRight
                            color: kicker.textFarbe
                            font.family: Kirigami.Theme.defaultFont.family
                            font.pixelSize: 12
                            renderType: Text.NativeRendering
                        }

                        // Vorschaubild
                        Item {
                            id: bildRahmen
                            x: 8
                            y: 8 + 24 + 8
                            width: 200
                            height: 120

                            TaskManager.ScreencastingRequest {
                                id: mitschnitt
                                uuid: eintrag.fensterIds.length > 0 ? eintrag.fensterIds[0] : ""
                            }
                            PipeWire.PipeWireSourceItem {
                                anchors.fill: parent
                                nodeId: mitschnitt.nodeId
                                visible: mitschnitt.nodeId > 0
                            }
                            // ohne Mitschnitt: großes App-Symbol
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 48
                                height: 48
                                visible: mitschnitt.nodeId === 0
                                source: eintrag.symbol
                            }
                        }

                        MouseArea {
                            id: eintragMaus
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                kicker.tasksModel.requestActivate(eintrag.idx);
                                dialog.offen = false;
                            }
                        }

                        // Schließen-Knopf (rot beim Hover, wie die Titelleiste)
                        Rectangle {
                            id: schliessen
                            x: parent.width - width - 4
                            y: 4
                            width: 32
                            height: 24
                            radius: 4
                            visible: eintragMaus.containsMouse || schliessenMaus.containsMouse
                            color: schliessenMaus.containsMouse ? "#C42B1C" : "transparent"
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: "window-close"
                                isMask: true
                                color: schliessenMaus.containsMouse ? "white" : kicker.textFarbe
                            }
                            MouseArea {
                                id: schliessenMaus
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: kicker.tasksModel.requestClose(eintrag.idx)
                            }
                        }
                    }
                }
            }
        }
    }
}
