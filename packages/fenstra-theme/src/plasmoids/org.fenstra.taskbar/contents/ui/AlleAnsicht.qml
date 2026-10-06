/*
    Fenstra-Startmenü: „Alle“ (Alle Apps, docs/windows11-referenz.md 5.1): Kopf „Alle“ mit
    „< Zurück“, alphabetische Liste mit Buchstabenüberschriften (Eintrag 40 px, Symbol 24).
    Klick auf eine Überschrift zeigt das Buchstabenraster; ein Buchstabe springt dorthin.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.fenstra.shell

Item {
    id: alle

    signal zurueck()

    onVisibleChanged: {
        if (visible) {
            buchstaben.visible = false;
            liste.positionViewAtBeginning();
        }
    }

    readonly property var modell: kicker.allAppsModel

    function ersterBuchstabe(s) {
        const c = String(s || "").charAt(0).toUpperCase();
        if (c >= "0" && c <= "9") {
            return "#";
        }
        return c.normalize("NFD").charAt(0).match(/[A-Z]/) ? c.normalize("NFD").charAt(0) : (c.length ? "&" : "");
    }
    function vorhandeneBuchstaben() {
        const s = {};
        if (!modell) {
            return s;
        }
        for (let i = 0; i < modell.count; ++i) {
            s[ersterBuchstabe(modell.data(modell.index(i, 0), Qt.DisplayRole))] = true;
        }
        return s;
    }
    function springeZu(b) {
        for (let i = 0; i < modell.count; ++i) {
            if (ersterBuchstabe(modell.data(modell.index(i, 0), Qt.DisplayRole)) === b) {
                liste.positionViewAtIndex(i, ListView.Beginning);
                break;
            }
        }
        buchstaben.visible = false;
    }

    WinText {
        x: 52
        y: 28
        height: 24
        text: "Alle"
        stil: "bodyStrong"
    }
    WinKnopf {
        anchors.right: parent.right
        anchors.rightMargin: 634 - 582
        y: 28
        height: 24
        innenabstand: 8
        schriftGroesse: 12
        text: "Zurück"
        symbol: "arrow-left"
        symbolGroesse: 12
        onClicked: alle.zurueck()
    }

    ListView {
        id: liste
        x: 29
        y: 64
        width: 590
        height: parent.height - 64 - 8
        clip: true
        visible: !buchstaben.visible
        boundsBehavior: Flickable.StopAtBounds
        model: alle.modell
        section.property: "display"
        section.criteria: ViewSection.FirstCharacter
        section.delegate: Item {
            required property string section
            width: liste.width
            height: 40
            WinKnopf {
                x: 8
                anchors.verticalCenter: parent.verticalCenter
                height: 32
                width: Math.max(32, implicitWidth)
                art: "subtil"
                text: alle.ersterBuchstabe(parent.section)
                fett: true
                onClicked: buchstaben.visible = true
            }
        }
        delegate: WinListenEintrag {
            id: app
            required property int index
            required property var model
            width: liste.width - 16
            height: 40
            symbol: model.decoration
            symbolGroesse: 24
            titel: model.display || ""
            linkerAbstand: 16
            onClicked: menu.starten(alle.modell, index)
            onRightClicked: (mx, my) => {
                const id = String(app.model.favoriteId || "");
                const fm = kicker.rootModel.favoritesModel;
                const angeheftet = id.length > 0 && fm.isFavorite(id);
                const tm = kicker.tasksModel;
                const url = kicker.launcherUrl(id);
                const inTL = url.length > 0 && tm.launcherPosition(url) >= 0;
                startKontext.zeigen(app, [
                    {text: angeheftet ? "Von Start lösen" : "An Start anheften", symbol: angeheftet ? "window-unpin" : "window-pin",
                     aktiv: id.length > 0, aktion: () => angeheftet ? fm.removeFavorite(id) : fm.addFavorite(id, -1)},
                    {text: inTL ? "Von Taskleiste lösen" : "An Taskleiste anheften", symbol: inTL ? "window-unpin" : "window-pin",
                     aktiv: url.length > 0, aktion: () => inTL ? tm.requestRemoveLauncher(url) : tm.requestAddLauncher(url)}
                ], mx, my);
            }
        }
    }
    // überlagernde Bildlaufleiste wie WinUI (schmal, breiter beim Hover)
    WinBildlauf {
        flick: liste
        x: liste.x + liste.width - width
        y: liste.y
        height: liste.height
    }

    // Buchstabenraster
    Rectangle {
        id: buchstaben
        visible: false
        x: 29
        y: 64
        width: 576
        height: parent.height - 64 - 8
        color: "transparent"
        readonly property var vorhanden: visible ? alle.vorhandeneBuchstaben() : ({})
        MouseArea {
            anchors.fill: parent
            onClicked: buchstaben.visible = false
        }
        Grid {
            anchors.centerIn: parent
            columns: 7
            spacing: 4
            Repeater {
                model: ["&", "#", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
                delegate: WinKnopf {
                    required property string modelData
                    width: 64
                    height: 56
                    art: "subtil"
                    text: modelData
                    schriftGroesse: 20
                    enabled: buchstaben.vorhanden[modelData] === true
                    onClicked: alle.springeZu(modelData)
                }
            }
        }
    }
}
