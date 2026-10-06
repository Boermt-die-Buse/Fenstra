/*
    Fenstra-Taskleiste: Knopf ohne Fenster (Start, Suchsymbol, Task-Ansicht).
    44 px breit, Hover-Fläche 40×40, Symbol 24, beim Drücken kurz kleiner.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: knopf

    property string iconName: ""
    property url iconSource: ""
    property bool iconIsMask: false
    property string toolTip: ""
    property bool checked: false

    signal clicked()
    signal pressed()
    signal rightClicked()

    width: 44

    KnopfFlaeche {
        hover: maus.containsMouse
        gedrueckt: maus.pressed
        aktiv: knopf.checked
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: 24
        height: 24
        source: knopf.iconSource.toString().length > 0 ? knopf.iconSource : knopf.iconName
        isMask: knopf.iconIsMask
        color: kicker.textFarbe
        scale: maus.pressed ? 0.85 : 1
        Behavior on scale {
            NumberAnimation { duration: maus.pressed ? 83 : 250; easing.type: maus.pressed ? Easing.OutQuad : Easing.OutBack }
        }
    }

    // Tooltip als Elternteil der Maus-Fläche, damit beide die Hover-Ereignisse sehen
    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText: knopf.toolTip
        location: PlasmaCore.Types.BottomEdge
        active: !knopf.checked && knopf.toolTip.length > 0
        interactive: false

        MouseArea {
            id: maus
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    knopf.pressed();
                }
            }
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    knopf.rightClicked();
                } else {
                    knopf.clicked();
                }
            }
        }
    }
}
