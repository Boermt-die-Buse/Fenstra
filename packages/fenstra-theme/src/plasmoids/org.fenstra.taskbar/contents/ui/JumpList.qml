/*
    Fenstra-Taskleiste: Sprungliste (Rechtsklick auf einen App-Knopf, Windows 11 4.4).

      Zuletzt verwendet         ← zuletzt geöffnete Dateien der App (falls vorhanden)
        datei.txt
      Aufgaben                  ← Aktionen aus der Desktop-Datei (z. B. „Neues Fenster“)
        Neues Fenster
      ───────────
      ▣ App-Name                ← neue Instanz
      📌 Von Taskleiste lösen / An Taskleiste anheften
      ✕ Fenster schließen / Alle Fenster schließen

    Die Einträge oben liefert das Kicker-Modell (dieselben Daten wie im Plasma-Startmenü).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.private.kicker as Kicker
import org.kde.taskmanager as TaskManager

Item {
    id: liste

    property Item knopf: null
    property var aktionen: []      // actionList des Kicker-Eintrags

    // Kicker-Eintrag der App (für Aufgaben und zuletzt verwendete Dateien)
    Kicker.SimpleFavoritesModel {
        id: appModell
    }
    Repeater {
        id: leser
        model: appModell
        delegate: Item {
            required property var model
            Component.onCompleted: liste.aktionen = model.actionList || []
        }
    }

    Component {
        id: eintragVorlage
        PlasmaExtras.MenuItem {}
    }

    PlasmaExtras.Menu {
        id: menue
        placement: PlasmaExtras.Menu.TopPosedLeftAlignedPopup
    }

    function speicherId(url) {
        const s = String(url || "");
        if (s.startsWith("applications:")) {
            return s.substring("applications:".length);
        }
        if (s.startsWith("file://") && s.endsWith(".desktop")) {
            return s.substring(s.lastIndexOf("/") + 1);
        }
        return "";
    }

    // Abschnittsüberschrift (grau, nicht anklickbar) wie „Aufgaben“ in Windows
    function ueberschrift(text) {
        menue.addMenuItem(eintragVorlage.createObject(menue, {text: text, enabled: false}));
    }

    function eintrag(text, symbol, aktion) {
        const e = eintragVorlage.createObject(menue, {text: text, icon: symbol});
        e.clicked.connect(aktion);
        menue.addMenuItem(e);
        return e;
    }

    function oeffne(k) {
        knopf = k;
        const tm = kicker.tasksModel;
        const idx = tm.makeModelIndex(k.index);
        const url = tm.data(idx, TaskManager.AbstractTasksModel.LauncherUrlWithoutIcon);
        let id = speicherId(url);
        if (id.length === 0) {
            const appId = tm.data(idx, TaskManager.AbstractTasksModel.AppId) || "";
            id = appId.length > 0 ? appId + (appId.endsWith(".desktop") ? "" : ".desktop") : "";
        }
        // Modell leeren und neu füllen: der Delegate wird neu angelegt und liest die
        // aktuellen Aktionen (zuletzt verwendete Dateien ändern sich laufend).
        aktionen = [];
        appModell.favorites = [];
        appModell.favorites = id.length > 0 ? [id] : [];
        Qt.callLater(() => {
            aufbauen(idx, url);
            menue.visualParent = k;
            menue.openRelative();
        });
    }

    function aufbauen(idx, url) {
        const tm = kicker.tasksModel;
        menue.clearMenuItems();

        const dateien = [];
        const aufgaben = [];
        for (let i = 0; i < aktionen.length; ++i) {
            const a = aktionen[i];
            if (a.actionId === "_kicker_recentDocument") {
                dateien.push(a);
            } else if (a.actionId === "_kicker_jumpListAction") {
                aufgaben.push(a);
            }
        }
        if (dateien.length > 0) {
            ueberschrift("Zuletzt verwendet");
            for (let i = 0; i < Math.min(dateien.length, 8); ++i) {
                const a = dateien[i];
                eintrag(a.text, a.icon, () => appModell.trigger(0, a.actionId, a.actionArgument));
            }
        }
        if (aufgaben.length > 0) {
            ueberschrift("Aufgaben");
            for (let i = 0; i < aufgaben.length; ++i) {
                const a = aufgaben[i];
                eintrag(a.text, a.icon, () => appModell.trigger(0, a.actionId, a.actionArgument));
            }
        }
        if (dateien.length > 0 || aufgaben.length > 0) {
            menue.addMenuItem(eintragVorlage.createObject(menue, {separator: true}));
        }

        const name = tm.data(idx, TaskManager.AbstractTasksModel.AppName) || tm.data(idx, Qt.DisplayRole) || "";
        eintrag(name, tm.data(idx, Qt.DecorationRole), () => tm.requestNewInstance(idx));

        const angeheftet = String(url || "").length > 0 && tm.launcherPosition(url) >= 0;
        if (angeheftet) {
            eintrag("Von Taskleiste lösen", "window-unpin", () => tm.requestRemoveLauncher(url));
        } else if (String(url || "").length > 0) {
            eintrag("An Taskleiste anheften", "window-pin", () => tm.requestAddLauncher(url));
        }

        if (!tm.data(idx, TaskManager.AbstractTasksModel.IsLauncher)) {
            const n = tm.data(idx, TaskManager.AbstractTasksModel.ChildCount) || 0;
            eintrag(n > 1 ? "Alle Fenster schließen" : "Fenster schließen", "window-close", () => tm.requestClose(idx));
        }
    }
}
