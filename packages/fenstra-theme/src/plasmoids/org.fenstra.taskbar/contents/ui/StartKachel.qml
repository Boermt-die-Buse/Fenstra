/*
    Fenstra-Startmenü: Kachel in „Angeheftet“ (Zelle 96×84): Symbol 32 oben, Name 12 px
    einzeilig darunter. Ordner: helle Fläche mit bis zu vier Mini-Symbolen (2×2).
    Hover SubtleFill Radius 4; Tastaturauswahl mit Fokusrahmen; beim Ziehen Ziel-Hinweise.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.kirigami as Kirigami
import org.fenstra.shell

Item {
    id: kachel

    property var eintrag: ({})
    property bool ausgewaehlt: false
    property bool ordnerZiel: false
    property bool gezogen: false
    property bool einfuegenVor: false
    property bool einfuegenNach: false
    readonly property bool istOrdner: eintrag.typ === "ordner"

    signal geklickt()
    signal kontext(real mx, real my)
    signal ziehenBeginnt(point p)
    signal ziehenBewegt(point p)
    signal ziehenEndet()

    opacity: gezogen ? 0.4 : 1

    Rectangle {
        x: 4
        y: 4
        width: parent.width - 8
        height: parent.height - 8
        radius: 4
        color: maus.pressed && !maus.zieht ? Farben.subtilGedrueckt
             : (maus.containsMouse || kachel.ausgewaehlt || kachel.ordnerZiel) ? Farben.subtilHover : "transparent"
        border.width: kachel.ausgewaehlt ? 2 : 0
        border.color: Farben.dunkel ? "#FFFFFF" : "#E4000000"
        Behavior on color {
            ColorAnimation { duration: 83 }
        }
    }

    // App-Symbol
    Kirigami.Icon {
        visible: !kachel.istOrdner
        x: (parent.width - 32) / 2
        y: 14
        width: 32
        height: 32
        source: kachel.eintrag.symbol || ""
        scale: kachel.ordnerZiel ? 0.85 : (maus.pressed && !maus.zieht ? 0.9 : 1)
        Behavior on scale {
            NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
        }
    }

    // Ordner-Symbol: Fläche mit Mini-Symbolen
    Rectangle {
        visible: kachel.istOrdner
        x: (parent.width - 36) / 2
        y: 12
        width: 36
        height: 36
        radius: 4
        color: Farben.controlFill
        border.width: 1
        border.color: Farben.controlRand
        scale: kachel.ordnerZiel ? 1.12 : 1
        Behavior on scale {
            NumberAnimation { duration: 167; easing.type: Easing.OutCubic }
        }
        Grid {
            anchors.centerIn: parent
            columns: 2
            spacing: 2
            Repeater {
                model: kachel.istOrdner ? kachel.eintrag.mitglieder.slice(0, 4) : []
                delegate: Kirigami.Icon {
                    required property var modelData
                    width: 13
                    height: 13
                    source: modelData.symbol || ""
                }
            }
        }
    }

    WinText {
        x: 4
        y: 54
        width: parent.width - 8
        height: 16
        horizontalAlignment: Text.AlignHCenter
        stil: "caption"
        text: kachel.eintrag.name || ""
    }

    // Einfügehinweis beim Ziehen
    Rectangle {
        visible: kachel.einfuegenVor || kachel.einfuegenNach
        x: kachel.einfuegenVor ? 0 : parent.width - 2
        y: 10
        width: 2
        height: parent.height - 20
        radius: 1
        color: Farben.akzentFlaeche
    }

    MouseArea {
        id: maus
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        preventStealing: true
        property bool zieht: false
        property bool warGezogen: false
        property point start: Qt.point(0, 0)
        onPressed: mouse => {
            start = Qt.point(mouse.x, mouse.y);
            zieht = false;
            warGezogen = false;
        }
        onPositionChanged: mouse => {
            if (!pressed || !(mouse.buttons & Qt.LeftButton)) {
                return;
            }
            if (!zieht && Math.hypot(mouse.x - start.x, mouse.y - start.y) > Qt.styleHints.startDragDistance) {
                zieht = true;
                warGezogen = true;
                kachel.ziehenBeginnt(Qt.point(mouse.x, mouse.y));
            } else if (zieht) {
                kachel.ziehenBewegt(Qt.point(mouse.x, mouse.y));
            }
        }
        onReleased: mouse => {
            if (zieht) {
                zieht = false;
                kachel.ziehenEndet();
            }
        }
        onCanceled: {
            if (zieht) {
                zieht = false;
                kachel.ziehenEndet();
            }
        }
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                kachel.kontext(mouse.x, mouse.y);
            } else if (!warGezogen) {
                kachel.geklickt();
            }
        }
    }
}
