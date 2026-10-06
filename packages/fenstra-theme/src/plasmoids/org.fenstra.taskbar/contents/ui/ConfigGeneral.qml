/*
    Fenstra-Taskleiste: Einstellungen („Taskleisteneinstellungen“), Aufbau wie
    Windows-Einstellungen > Personalisierung > Taskleiste.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_searchMode: suche.currentIndex
    property alias cfg_showTaskView: taskView.checked
    property alias cfg_showWidgets: widgets.checked
    property alias cfg_centered: mitte.checked
    property alias cfg_weatherSource: wetter.text

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: suche
            Kirigami.FormData.label: "Suche:"
            model: ["Ausblenden", "Nur Suchsymbol", "Suchfeld"]
        }
        QQC2.CheckBox {
            id: taskView
            Kirigami.FormData.label: "Taskleistenelemente:"
            text: "Aktive Anwendungen (Task-Ansicht)"
        }
        QQC2.CheckBox {
            id: widgets
            text: "Widgets"
        }
        QQC2.CheckBox {
            id: mitte
            Kirigami.FormData.label: "Verhalten:"
            text: "Taskleistenausrichtung: Zentriert"
        }
        QQC2.TextField {
            id: wetter
            Kirigami.FormData.label: "Wetterquelle:"
            placeholderText: "z. B. dwd|weather|Berlin-Tempelhof|10384"
            Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        }
    }
}
