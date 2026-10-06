/*
    Fenstra-Shell: Kontextmenü mit wechselndem Inhalt. Nutzt PlasmaExtras.Menu (QMenu), das der
    Qt-Stil Fenstra im Windows-11-Menüstil zeichnet (Radius 8, Einträge 32 px, Symbole 16).
      zeigen(element, [{text, symbol, aktion, aktiv}, {trenner: true}, …], x, y)
    Ohne x/y öffnet es neben dem Element (lage).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.extras as PlasmaExtras

Item {
    id: km

    property int lage: PlasmaExtras.Menu.BottomPosedLeftAlignedPopup

    Component {
        id: vorlage
        PlasmaExtras.MenuItem {}
    }

    PlasmaExtras.Menu {
        id: menue
        placement: km.lage
    }

    function zeigen(element, eintraege, x, y) {
        menue.clearMenuItems();
        for (let i = 0; i < eintraege.length; ++i) {
            const e = eintraege[i];
            if (e.trenner) {
                menue.addMenuItem(vorlage.createObject(menue, {separator: true}));
                continue;
            }
            const m = vorlage.createObject(menue, {text: e.text, icon: e.symbol || "", enabled: e.aktiv !== false});
            if (e.aktion) {
                m.clicked.connect(e.aktion);
            }
            menue.addMenuItem(m);
        }
        menue.visualParent = element;
        if (x !== undefined && y !== undefined) {
            menue.open(x, y);
        } else {
            menue.openRelative();
        }
    }
}
