/*
    Fenstra-Taskleiste: App-Knopf (angeheftet und/oder laufend).

      ┌────────┐  44 px breit, Hover-Fläche 40×40 Radius 4, Symbol 24
      │  [ ■ ] │  Indikator unten: aktiv 16×3 Akzent, läuft 6×3 grau, nur angeheftet keiner
      │   ▬    │
      └────────┘

    Links: aktivieren / minimieren / bei mehreren Fenstern Vorschau-Auswahl.
    Mitte oder Umschalt+Links: neue Instanz. Rechts: Sprungliste. Ziehen: Reihenfolge.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.taskmanager as TaskManager

Item {
    id: knopf

    required property int index
    required property var model

    property var vorschau: null
    property var sprungliste: null

    readonly property bool istStarter: model.IsLauncher === true
    readonly property bool startetGerade: model.IsStartup === true
    readonly property bool laeuft: !istStarter && !startetGerade
    readonly property bool aktiv: model.IsActive === true
    readonly property bool mehrereFenster: (model.ChildCount || 0) > 1
    readonly property bool aufmerksamkeit: model.IsDemandingAttention === true

    width: 44

    function modellIndex() {
        return kicker.tasksModel.makeModelIndex(knopf.index);
    }

    // Lage für KWin (Minimieren-Animation fliegt zu diesem Knopf)
    function lageMelden() {
        if (!laeuft || !knopf.Window.window) {
            return;
        }
        const p = knopf.mapToGlobal(0, 0);
        kicker.tasksModel.requestPublishDelegateGeometry(modellIndex(), Qt.rect(p.x, p.y, width, height), knopf);
    }
    onXChanged: lageTimer.restart()
    onLaeuftChanged: lageTimer.restart()
    Timer {
        id: lageTimer
        interval: 300
        onTriggered: knopf.lageMelden()
    }

    KnopfFlaeche {
        hover: maus.containsMouse
        gedrueckt: maus.pressed && !maus.zieht
        aktiv: knopf.aktiv
        sonderFarbe: knopf.aufmerksamkeit && !knopf.aktiv ? kicker.aufmerksamkeit : "transparent"
    }

    Kirigami.Icon {
        id: symbol
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -1
        width: 24
        height: 24
        source: knopf.model.decoration
        scale: maus.pressed && !maus.zieht ? 0.85 : 1
        opacity: knopf.startetGerade ? 0.6 : 1
        Behavior on scale {
            NumberAnimation { duration: maus.pressed ? 83 : 250; easing.type: maus.pressed ? Easing.OutQuad : Easing.OutBack }
        }
    }

    // Indikator
    Rectangle {
        id: indikator
        visible: knopf.laeuft
        anchors.horizontalCenter: parent.horizontalCenter
        // 2 px über der Unterkante der 40er-Fläche
        y: Math.round((parent.height - 40) / 2) + 40 - 3 - 2
        height: 3
        radius: 1.5
        width: knopf.aktiv ? 16 : 6
        color: knopf.aufmerksamkeit ? "#F7630C" : (knopf.aktiv ? kicker.indikatorAktiv : kicker.indikatorInaktiv)
        Behavior on width {
            NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: 167 }
        }
    }

    // Nur angeheftet: einfacher Tooltip mit dem App-Namen
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: knopf.model.AppName || knopf.model.display || ""
        location: PlasmaCore.Types.BottomEdge
        active: knopf.istStarter && !maus.pressed
        interactive: false

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

            property bool zieht: false
            property real startX: 0

            onContainsMouseChanged: {
                if (!knopf.vorschau) {
                    return;
                }
                if (containsMouse && knopf.laeuft) {
                    knopf.vorschau.hoverStart(knopf);
                } else {
                    knopf.vorschau.hoverEnde(knopf);
                }
            }
            onPressed: mouse => {
                startX = mouse.x;
                zieht = false;
                if (knopf.vorschau) {
                    knopf.vorschau.hoverAbbrechen();
                }
            }
            onPositionChanged: mouse => {
                if (!pressed || mouse.buttons !== Qt.LeftButton) {
                    return;
                }
                if (!zieht && Math.abs(mouse.x - startX) > Qt.styleHints.startDragDistance) {
                    zieht = true;
                }
                if (zieht) {
                    // Zielposition aus der Mausposition in der Gruppe bestimmen
                    const inGruppe = knopf.mapToItem(knopf.parent, mouse.x, 0).x;
                    let ziel = knopf.index;
                    const kinder = knopf.parent.children;
                    for (let i = 0; i < kinder.length; ++i) {
                        const k = kinder[i];
                        if (k !== knopf && k.index !== undefined && k.visible
                            && inGruppe > k.x && inGruppe < k.x + k.width) {
                            ziel = k.index;
                        }
                    }
                    if (ziel !== knopf.index) {
                        kicker.tasksModel.move(knopf.index, ziel);
                    }
                }
            }
            onReleased: mouse => {
                if (zieht) {
                    zieht = false;
                    kicker.tasksModel.syncLaunchers();
                }
            }
            onClicked: mouse => {
                if (zieht) {
                    return;
                }
                const idx = knopf.modellIndex();
                if (mouse.button === Qt.RightButton) {
                    knopf.sprungliste.oeffne(knopf);
                } else if (mouse.button === Qt.MiddleButton || (mouse.modifiers & Qt.ShiftModifier)) {
                    kicker.tasksModel.requestNewInstance(idx);
                } else if (knopf.istStarter || knopf.startetGerade) {
                    kicker.tasksModel.requestActivate(idx);
                } else if (knopf.mehrereFenster) {
                    knopf.vorschau.zeigeFest(knopf);
                } else if (knopf.aktiv) {
                    kicker.tasksModel.requestToggleMinimized(idx);
                } else {
                    kicker.tasksModel.requestActivate(idx);
                }
            }
        }
    }
}
