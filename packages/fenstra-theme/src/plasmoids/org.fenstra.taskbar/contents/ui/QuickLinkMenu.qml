/*
    Fenstra-Taskleiste: Schnelllink-Menü (Rechtsklick auf Start, wie Win+X in Windows 11).
    Wie unter Windows ohne Symbole. Die Einträge öffnen die passenden KDE-Programme bzw.
    Einstellungsseiten; eigene
    Fenstra-Apps ersetzen sie später (Explorer, Einstellungen, Task-Manager, Ausführen).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support

Item {
    id: schnell

    function oeffnen(knopf) {
        menue.visualParent = knopf;
        menue.openRelative();
    }

    // Befehle ohne Rückgabe ausführen
    P5Support.DataSource {
        id: befehle
        engine: "executable"
        connectedSources: []
        onNewData: (quelle, daten) => disconnectSource(quelle)
    }
    function befehl(b) {
        befehle.connectSource(b);
    }

    PlasmaExtras.Menu {
        id: menue
        placement: PlasmaExtras.Menu.TopPosedLeftAlignedPopup

        PlasmaExtras.MenuItem { text: "Installierte Apps"; onClicked: schnell.befehl("plasma-discover --mode installed") }
        PlasmaExtras.MenuItem { text: "Energieoptionen"; onClicked: schnell.befehl("systemsettings kcm_powerdevilprofilesconfig") }
        PlasmaExtras.MenuItem { text: "Ereignisanzeige"; onClicked: kicker.starteApp("org.kde.kjournaldbrowser.desktop") }
        PlasmaExtras.MenuItem { text: "System"; onClicked: kicker.starteApp("org.kde.kinfocenter.desktop") }
        PlasmaExtras.MenuItem { text: "Geräte-Manager"; onClicked: schnell.befehl("kinfocenter kcm_devinfo") }
        PlasmaExtras.MenuItem { text: "Netzwerkverbindungen"; onClicked: schnell.befehl("systemsettings kcm_networkmanagement") }
        PlasmaExtras.MenuItem { text: "Datenträgerverwaltung"; onClicked: kicker.starteApp("org.kde.partitionmanager.desktop") }
        PlasmaExtras.MenuItem { text: "Computerverwaltung"; onClicked: kicker.starteApp("org.kde.kinfocenter.desktop") }
        PlasmaExtras.MenuItem { text: "Terminal"; onClicked: kicker.starteApp("org.kde.konsole.desktop") }
        PlasmaExtras.MenuItem { text: "Terminal (Administrator)"; onClicked: schnell.befehl("konsole -e sudo -i") }
        PlasmaExtras.MenuItem { separator: true }
        PlasmaExtras.MenuItem { text: "Task-Manager"; onClicked: kicker.starteApp("org.kde.plasma-systemmonitor.desktop") }
        PlasmaExtras.MenuItem { text: "Einstellungen"; onClicked: kicker.starteApp("systemsettings.desktop") }
        PlasmaExtras.MenuItem { text: "Datei-Explorer"; onClicked: kicker.starteApp("org.kde.dolphin.desktop") }
        PlasmaExtras.MenuItem { text: "Suchen"; onClicked: kicker.sucheOeffnen() }
        PlasmaExtras.MenuItem { text: "Ausführen"; onClicked: kicker.sucheOeffnen() }
        PlasmaExtras.MenuItem { separator: true }
        PlasmaExtras.MenuItem {
            id: ausschalten
            text: "Herunterfahren oder abmelden"
            property PlasmaExtras.Menu untermenue: PlasmaExtras.Menu {
                visualParent: ausschalten.action
                PlasmaExtras.MenuItem { text: "Abmelden"; onClicked: schnell.befehl("qdbus-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout") }
                PlasmaExtras.MenuItem { text: "Energie sparen"; onClicked: schnell.befehl("systemctl suspend") }
                PlasmaExtras.MenuItem { text: "Herunterfahren"; onClicked: schnell.befehl("qdbus-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndShutdown") }
                PlasmaExtras.MenuItem { text: "Neu starten"; onClicked: schnell.befehl("qdbus-qt6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logoutAndReboot") }
            }
        }
        PlasmaExtras.MenuItem { text: "Desktop"; onClicked: kicker.kwinKuerzel("Show Desktop") }
    }
}
