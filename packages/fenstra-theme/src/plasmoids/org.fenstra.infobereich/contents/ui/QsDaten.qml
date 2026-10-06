/*
    Fenstra-Schnelleinstellungen: Zustände und Schaltvorgänge aller Kacheln (ohne Darstellung).

      WLAN, Flugzeugmodus   NetworkManager über org.kde.plasma.networkmanagement
      Bluetooth             BlueZ über org.kde.bluezqt
      Energiesparmodus      Energieprofil „power-saver“ (power-profiles-daemon/tuned-ppd)
      Nachtmodus            KWin-Nachtfarben (kwinrc [NightColor], Modus „immer an“)
      Barrierefreiheit      Lupe (KWin-Zoom), Farbfilter (KWin-Effekt), Sprachausgabe (Orca),
                            Einrastfunktion (kaccessrc, KWin)
      Projizieren, Tastaturlayout, VPN: zusätzliche Kacheln für „Bearbeiten“

    Kacheln ohne passende Hardware blendet Windows aus; hier ebenso (verfuegbar = false).
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.plasma.networkmanagement as PlasmaNM
import org.kde.bluezqt as BluezQt
import org.kde.plasma.private.batterymonitor as Batterie
import org.kde.plasma.private.brightnesscontrolplugin as Helligkeit
import org.kde.plasma.workspace.dbus as DBus
import org.kde.plasma.plasma5support as P5Support

Item {
    id: daten

    // ---------------- Befehle ----------------
    P5Support.DataSource {
        id: befehle
        engine: "executable"
        onNewData: (quelle, d) => disconnectSource(quelle)
    }
    function befehl(b) {
        befehle.connectSource(b);
    }
    function kwinKuerzel(name) {
        DBus.SessionBus.asyncCall({service: "org.kde.kglobalaccel", path: "/component/kwin",
                                   iface: "org.kde.kglobalaccel.Component", member: "invokeShortcut", arguments: [name]});
    }
    function kwinEffekt(methode, name) {
        DBus.SessionBus.asyncCall({service: "org.kde.KWin", path: "/Effects", iface: "org.kde.kwin.Effects",
                                   member: methode, arguments: [name]});
    }

    // ---------------- Netz ----------------
    PlasmaNM.Handler {
        id: netz
    }
    PlasmaNM.EnabledConnections {
        id: verbindungen
    }
    PlasmaNM.AvailableDevices {
        id: geraete
    }
    readonly property bool wlanVerfuegbar: geraete.wirelessDeviceAvailable
    readonly property bool wlanAn: verbindungen.wirelessEnabled && !PlasmaNM.Configuration.airplaneModeEnabled
    readonly property bool flugVerfuegbar: geraete.wirelessDeviceAvailable || geraete.modemDeviceAvailable || bluetoothVerfuegbar
    readonly property bool flugAn: PlasmaNM.Configuration.airplaneModeEnabled
    function wlanUmschalten() {
        netz.enableWireless(!verbindungen.wirelessEnabled);
    }
    function flugUmschalten() {
        const an = !PlasmaNM.Configuration.airplaneModeEnabled;
        netz.enableAirplaneMode(an);
        PlasmaNM.Configuration.airplaneModeEnabled = an;
    }
    function wlanSuchen() {
        netz.requestScan();
    }
    readonly property var netzHandler: netz

    // ---------------- Bluetooth ----------------
    readonly property bool bluetoothVerfuegbar: BluezQt.Manager.adapters.length > 0 || BluezQt.Manager.bluetoothBlocked
    readonly property bool bluetoothAn: BluezQt.Manager.bluetoothOperational
    function bluetoothUmschalten() {
        const an = !bluetoothAn;
        BluezQt.Manager.bluetoothBlocked = !an;
        for (let i = 0; i < BluezQt.Manager.adapters.length; ++i) {
            BluezQt.Manager.adapters[i].powered = an;
        }
    }

    // ---------------- Energiesparmodus ----------------
    Batterie.PowerProfilesControl {
        id: profile
    }
    readonly property bool energieVerfuegbar: profile.isPowerProfileDaemonInstalled && profile.profiles.indexOf("power-saver") >= 0
    readonly property bool energieAn: profile.activeProfile === "power-saver"
    function energieUmschalten() {
        profile.setProfile(energieAn ? (profile.configuredProfile || "balanced") : "power-saver");
    }

    // ---------------- Nachtmodus ----------------
    DBus.Properties {
        id: nacht
        busType: DBus.BusType.Session
        service: "org.kde.KWin.NightLight"
        path: "/org/kde/KWin/NightLight"
        iface: "org.kde.KWin.NightLight"
    }
    readonly property bool nachtVerfuegbar: Boolean(nacht.properties.available)
    readonly property bool nachtAn: Boolean(nacht.properties.enabled) && !Boolean(nacht.properties.inhibited)
    function nachtUmschalten() {
        // Windows: „Nachtmodus“ schaltet sofort warm (nicht nach Zeitplan) → Modus 3 = immer an
        const an = !nachtAn;
        // KWin beobachtet kwinrc per KConfigWatcher: --notify meldet die Änderung sofort
        const k = "kwriteconfig6 --notify --file kwinrc --group NightColor ";
        befehl(an ? k + "--key Mode Constant && " + k + "--key NightTemperature 4500 && " + k + "--key Active true"
                  : k + "--key Active false");
    }

    // ---------------- Helligkeit ----------------
    Helligkeit.ScreenBrightnessControl {
        id: helligkeit
    }
    readonly property bool helligkeitVerfuegbar: helligkeit.isBrightnessAvailable
    readonly property var bildschirme: helligkeit.displays
    function helligkeitSetzen(name, wert) {
        helligkeit.setBrightness(name, wert);
    }

    // ---------------- Barrierefreiheit ----------------
    property bool lupeAn: false
    function lupeUmschalten() {
        lupeAn = !lupeAn;
        if (lupeAn) {
            kwinKuerzel("view_zoom_in");
            kwinKuerzel("view_zoom_in");
        } else {
            kwinKuerzel("view_actual_size");
        }
    }
    property bool farbfilterAn: false
    function farbfilterUmschalten() {
        farbfilterAn = !farbfilterAn;
        kwinEffekt(farbfilterAn ? "loadEffect" : "unloadEffect", "colorblindnesscorrection");
    }
    property bool sprachausgabeAn: false
    function sprachausgabeUmschalten() {
        sprachausgabeAn = !sprachausgabeAn;
        befehl(sprachausgabeAn ? "orca --replace >/dev/null 2>&1 &" : "orca --quit || pkill -x orca");
    }
    property bool einrastenAn: false
    function einrastenUmschalten() {
        einrastenAn = !einrastenAn;
        befehl("kwriteconfig6 --notify --file kaccessrc --group Keyboard --key StickyKeys " + (einrastenAn ? "true" : "false"));
    }
    // Startzustand der Barrierefreiheit einlesen (Farbfilter-Effekt, Orca, Einrastfunktion)
    P5Support.DataSource {
        id: zustand
        engine: "executable"
        onNewData: (quelle, d) => {
            const t = String(d["stdout"] || "");
            daten.sprachausgabeAn = t.indexOf("orca=1") >= 0;
            daten.einrastenAn = t.indexOf("sticky=true") >= 0;
            daten.farbfilterAn = t.indexOf("filter=true") >= 0;
            disconnectSource(quelle);
        }
    }
    function zustandLesen() {
        zustand.connectSource("echo orca=$(pgrep -x orca >/dev/null && echo 1 || echo 0) "
                              + "sticky=$(kreadconfig6 --file kaccessrc --group Keyboard --key StickyKeys --default false) "
                              + "filter=$(qdbus-qt6 org.kde.KWin /Effects org.kde.kwin.Effects.isEffectLoaded colorblindnesscorrection) #"
                              + Date.now());
    }

    // ---------------- Zusätzliche Kacheln ----------------
    function projizieren() {
        befehl("qdbus-qt6 org.kde.kscreen.osdService /org/kde/kscreen/osdService org.kde.kscreen.osdService.showActionSelector");
    }
    function tastaturWechseln() {
        DBus.SessionBus.asyncCall({service: "org.kde.keyboard", path: "/Layouts", iface: "org.kde.KeyboardLayouts",
                                   member: "switchToNextLayout", arguments: []});
    }

    // ---------------- Kachelverzeichnis ----------------
    // id → Text, Symbol, geteilt (Pfeil zur Unterseite), Seite
    readonly property var verzeichnis: ({
        wlan: {text: "WLAN", symbol: "network-wireless", geteilt: true, seite: "wlan"},
        bluetooth: {text: "Bluetooth", symbol: "bluetooth", geteilt: true, seite: "bluetooth"},
        flugmodus: {text: "Flugzeugmodus", symbol: "network-flightmode-on", geteilt: false, seite: ""},
        energiesparen: {text: "Energiesparmodus", symbol: "battery-profile-powersave", geteilt: false, seite: ""},
        nachtmodus: {text: "Nachtmodus", symbol: "night-light", geteilt: false, seite: ""},
        barrierefreiheit: {text: "Barrierefreiheit", symbol: "preferences-desktop-accessibility", geteilt: false, seite: "barrierefreiheit", pfeil: true},
        projizieren: {text: "Projizieren", symbol: "video-display", geteilt: false, seite: ""},
        tastatur: {text: "Tastaturlayout", symbol: "input-keyboard", geteilt: false, seite: ""},
        vpn: {text: "VPN", symbol: "network-vpn", geteilt: false, seite: ""}
    })
    function verfuegbar(id) {
        switch (id) {
        case "wlan": return wlanVerfuegbar;
        case "bluetooth": return bluetoothVerfuegbar;
        case "flugmodus": return flugVerfuegbar;
        case "energiesparen": return energieVerfuegbar;
        case "nachtmodus": return nachtVerfuegbar;
        default: return true;
        }
    }
    function an(id) {
        switch (id) {
        case "wlan": return wlanAn;
        case "bluetooth": return bluetoothAn;
        case "flugmodus": return flugAn;
        case "energiesparen": return energieAn;
        case "nachtmodus": return nachtAn;
        // Barrierefreiheit hat bei Windows keinen An-Zustand (öffnet nur die Unterseite)
        default: return false;
        }
    }
    function umschalten(id) {
        switch (id) {
        case "wlan": wlanUmschalten(); break;
        case "bluetooth": bluetoothUmschalten(); break;
        case "flugmodus": flugUmschalten(); break;
        case "energiesparen": energieUmschalten(); break;
        case "nachtmodus": nachtUmschalten(); break;
        case "projizieren": projizieren(); break;
        case "tastatur": tastaturWechseln(); break;
        case "vpn": befehl("systemsettings kcm_networkmanagement"); break;
        }
    }
}
