/*
    Fenstra-Shell: Such-/Eingabefeld im WinUI-Aussehen (docs/windows11-referenz.md 2.2).
    pille: true → Radius = Höhe/2 (Suchfeld im Startmenü), sonst Radius 4.
    Ruhe: Steuerelementfläche, Rand 1 px, Unterkante ControlStrong; Fokus: Eingabefläche
    und 2 px Akzentlinie unten. Lupe links (abschaltbar), Löschen-„X“ bei Inhalt und Fokus.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami

FocusScope {
    id: feld

    property alias text: eingabe.text
    property alias eingabe: eingabe
    property string platzhalter: ""
    property bool pille: false
    property bool lupe: true
    property bool loeschenKnopf: true
    property int schriftGroesse: 14
    // false: Fokus nicht anzeigen (Startmenü: Tippen geht ins Feld, es sieht aber ruhend aus)
    property bool fokusStil: true
    readonly property bool fokus: eingabe.activeFocus && fokusStil
    readonly property alias hovered: hover.hovered

    signal angenommen()
    signal abgebrochen()
    // Pfeiltasten und Tab (dx/dy = -1/0/1); der Empfänger setzt event.accepted
    signal pfeil(int dx, int dy, var event)

    implicitHeight: 32
    implicitWidth: 240

    function leeren() {
        eingabe.text = "";
    }

    Rectangle {
        id: flaeche
        anchors.fill: parent
        radius: feld.pille ? height / 2 : 4
        color: feld.fokus ? Farben.controlFillEingabe : (hover.hovered ? Farben.controlFillHover : Farben.controlFill)
        border.width: 1
        border.color: Farben.controlRand
    }
    // Unterkante: Ruhe 1 px ControlStrong, Fokus 2 px Akzent (nur im geraden Teil der Kante)
    Rectangle {
        x: flaeche.radius
        width: parent.width - 2 * flaeche.radius
        height: feld.fokus ? 2 : 1
        y: parent.height - height
        color: feld.fokus ? Farben.akzentFlaeche : (feld.pille ? "transparent" : Farben.controlStark)
    }

    Kirigami.Icon {
        id: lupenSymbol
        visible: feld.lupe
        anchors.verticalCenter: parent.verticalCenter
        x: feld.pille ? 16 : 10
        width: 16
        height: 16
        source: "search"
        isMask: true
        color: Farben.text
    }

    TextInput {
        id: eingabe
        anchors.left: feld.lupe ? lupenSymbol.right : parent.left
        anchors.leftMargin: feld.lupe ? 10 : (feld.pille ? 16 : 11)
        anchors.right: loeschen.visible ? loeschen.left : parent.right
        anchors.rightMargin: loeschen.visible ? 2 : 11
        anchors.verticalCenter: parent.verticalCenter
        focus: true
        clip: true
        color: Farben.text
        selectionColor: Farben.akzent
        selectedTextColor: "#FFFFFF"
        font.family: Farben.schrift
        font.pixelSize: feld.schriftGroesse
        renderType: Text.NativeRendering
        selectByMouse: true
        Keys.onReturnPressed: feld.angenommen()
        Keys.onEnterPressed: feld.angenommen()
        Keys.onEscapePressed: event => {
            feld.abgebrochen();
            event.accepted = true;
        }
        Keys.onDownPressed: event => { event.accepted = false; feld.pfeil(0, 1, event); }
        Keys.onUpPressed: event => { event.accepted = false; feld.pfeil(0, -1, event); }
        Keys.onTabPressed: event => { event.accepted = false; feld.pfeil(1, 0, event); }
        // ← / → nur bei leerem Feld weiterreichen (sonst bewegen sie den Textcursor)
        Keys.onLeftPressed: event => { event.accepted = false; if (eingabe.text.length === 0) feld.pfeil(-1, 0, event); }
        Keys.onRightPressed: event => { event.accepted = false; if (eingabe.text.length === 0) feld.pfeil(1, 0, event); }
        Keys.onBacktabPressed: event => { event.accepted = false; feld.pfeil(-1, 0, event); }

        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            visible: eingabe.text.length === 0 && !eingabe.preeditText
            text: feld.platzhalter
            color: Farben.textSekundaer
            font: eingabe.font
            elide: Text.ElideRight
            renderType: Text.NativeRendering
        }
    }

    WinKnopf {
        id: loeschen
        visible: feld.loeschenKnopf && eingabe.activeFocus && eingabe.text.length > 0
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 28
        height: parent.height - 8
        art: "subtil"
        symbol: "window-close"
        symbolGroesse: 12
        activeFocusOnTab: false
        onClicked: {
            eingabe.text = "";
            eingabe.forceActiveFocus();
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.IBeamCursor
    }
    TapHandler {
        onTapped: eingabe.forceActiveFocus()
    }
}
