/*
    Fenstra-Startmenü: geöffneter Ordner (Einblendung über „Angeheftet“, wie Windows 11):
    Karte mit umbenennbarem Namen oben und den Apps im Raster (4 Spalten). Klick außerhalb
    oder Esc schließt. Rechtsklick auf eine App: „Aus Ordner entfernen“ usw.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Effects

import org.fenstra.shell

Item {
    id: ansicht

    property int oi: -1
    readonly property var ordner: {
        const k = raster.kacheln;
        for (let i = 0; i < k.length; ++i) {
            if (k[i].typ === "ordner" && k[i].oi === oi) {
                return k[i];
            }
        }
        return null;
    }

    function oeffnen(index) {
        oi = index;
        visible = true;
        name.text = ordner ? ordner.name : "Ordner";
    }
    function schliessen() {
        if (ordner && name.text !== ordner.name) {
            raster.ordnerUmbenennen(oi, name.text.trim());
        }
        visible = false;
    }
    // Ordner aufgelöst (nur noch eine App) → schließen
    onOrdnerChanged: if (visible && !ordner) visible = false

    // Klick außerhalb der Karte schließt
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: ansicht.schliessen()
    }

    Rectangle {
        id: karte
        readonly property int anzahl: ansicht.ordner ? ansicht.ordner.mitglieder.length : 0
        readonly property int zeilen: Math.max(1, Math.ceil(anzahl / 4))
        width: 4 * 96 + 32
        height: 64 + zeilen * 84 + 16
        x: (parent.width - width) / 2
        y: 64 + Math.max(0, (252 - height) / 2)
        radius: 8
        color: Farben.flaecheErhoeht
        border.width: 1
        border.color: Farben.flyoutRand
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Farben.schatten
            shadowBlur: 0.8
            shadowVerticalOffset: 6
        }

        MouseArea {
            anchors.fill: parent      // Klicks auf die Karte nicht durchreichen
        }

        // Name (anklickbar zum Umbenennen)
        TextInput {
            id: name
            anchors.horizontalCenter: parent.horizontalCenter
            y: 20
            width: parent.width - 64
            horizontalAlignment: TextInput.AlignHCenter
            color: Farben.text
            selectionColor: Farben.akzent
            selectedTextColor: "#FFFFFF"
            font.family: Farben.schrift
            font.pixelSize: 14
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
            selectByMouse: true
            maximumLength: 40
            onAccepted: {
                raster.ordnerUmbenennen(ansicht.oi, text.trim());
                focus = false;
            }
            Keys.onEscapePressed: ansicht.schliessen()
            Rectangle {
                anchors.fill: parent
                anchors.margins: -6
                z: -1
                radius: 4
                visible: name.activeFocus || nameHover.hovered
                color: name.activeFocus ? Farben.controlFillEingabe : Farben.subtilHover
                border.width: name.activeFocus ? 1 : 0
                border.color: Farben.controlRand
            }
            HoverHandler {
                id: nameHover
                cursorShape: Qt.IBeamCursor
            }
        }

        Grid {
            x: 16
            y: 56
            columns: 4
            Repeater {
                model: ansicht.ordner ? ansicht.ordner.mitglieder : []
                delegate: StartKachel {
                    id: mitglied
                    required property var modelData
                    width: 96
                    height: 84
                    eintrag: ({typ: "app", id: modelData.id, zeile: modelData.zeile, name: modelData.name, symbol: modelData.symbol})
                    onGeklickt: raster.starten(mitglied.modelData.zeile)
                    onKontext: (mx, my) => raster.appMenue(mitglied, mitglied.eintrag, ansicht.oi, mx, my)
                }
            }
        }
    }
}
