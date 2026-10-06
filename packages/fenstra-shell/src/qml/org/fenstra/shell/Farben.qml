/*
    Fenstra-Shell: WinUI-Farbwerte (docs/windows11-referenz.md 1.1, 1.2) für alle Flyouts.
    Hell/dunkel folgt dem Plasma-Design; der Akzent kommt aus dem Farbschema.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami

QtObject {
    id: farben

    readonly property bool dunkel: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor) === Kirigami.ColorUtils.Dark
    readonly property string schrift: Kirigami.Theme.defaultFont.family

    // ---------------- Text ----------------
    readonly property color text: dunkel ? "#FFFFFF" : "#E4000000"
    readonly property color textSekundaer: dunkel ? "#C5FFFFFF" : "#9E000000"
    readonly property color textTertiaer: dunkel ? "#87FFFFFF" : "#72000000"
    readonly property color textDeaktiviert: dunkel ? "#5DFFFFFF" : "#5C000000"
    readonly property color textAufAkzent: dunkel ? "#000000" : "#FFFFFF"
    readonly property color textAufAkzentSekundaer: dunkel ? "#80000000" : "#B3FFFFFF"

    // ---------------- Akzent (hell Dark1, dunkel Light2) ----------------
    readonly property color akzent: Kirigami.Theme.highlightColor
    readonly property color akzentFlaeche: akzentStufe(akzent, dunkel ? 2 : -1)
    readonly property color akzentFlaecheHover: mitAlpha(akzentFlaeche, 0.9)
    readonly property color akzentFlaecheGedrueckt: mitAlpha(akzentFlaeche, 0.8)
    readonly property color akzentText: akzentStufe(akzent, dunkel ? 3 : -2)
    readonly property color akzentRand: "#14FFFFFF"
    readonly property color akzentRandUnten: dunkel ? "#23000000" : "#66000000"

    // ---------------- Steuerelemente ----------------
    readonly property color controlFill: dunkel ? "#0FFFFFFF" : "#B3FFFFFF"
    readonly property color controlFillHover: dunkel ? "#15FFFFFF" : "#80F9F9F9"
    readonly property color controlFillGedrueckt: dunkel ? "#08FFFFFF" : "#4DF9F9F9"
    readonly property color controlFillDeaktiviert: dunkel ? "#0BFFFFFF" : "#4DF9F9F9"
    readonly property color controlFillEingabe: dunkel ? "#B31E1E1E" : "#FFFFFF"
    readonly property color controlRand: dunkel ? "#12FFFFFF" : "#0F000000"
    readonly property color controlRandUnten: dunkel ? "#18FFFFFF" : "#29000000"
    readonly property color controlStark: dunkel ? "#8BFFFFFF" : "#72000000"
    readonly property color controlStarkDeaktiviert: dunkel ? "#3FFFFFFF" : "#37000000"
    readonly property color controlFest: dunkel ? "#454545" : "#FFFFFF"
    readonly property color controlAlt: dunkel ? "#19000000" : "#06000000"
    readonly property color controlAltHover: dunkel ? "#0BFFFFFF" : "#0F000000"

    // transparente Flächen (Listen, Menüs, Symbolknöpfe)
    readonly property color subtilHover: dunkel ? "#0FFFFFFF" : "#09000000"
    readonly property color subtilGedrueckt: dunkel ? "#0AFFFFFF" : "#06000000"

    // Karten, Trennlinien, Ebenen
    readonly property color karte: dunkel ? "#0DFFFFFF" : "#B3FFFFFF"
    readonly property color karteZwei: dunkel ? "#08FFFFFF" : "#80F6F6F6"
    readonly property color karteRand: dunkel ? "#19000000" : "#0F000000"
    readonly property color trenner: dunkel ? "#15FFFFFF" : "#0F000000"
    readonly property color ebene: dunkel ? "#4C3A3A3A" : "#80FFFFFF"
    readonly property color flyoutRand: dunkel ? "#33000000" : "#0F000000"
    // deckende Flächen für Einblendungen innerhalb eines Flyouts (Ordner, Kontokarte, Tooltips)
    readonly property color flaeche: dunkel ? "#2C2C2C" : "#F9F9F9"
    readonly property color flaecheErhoeht: dunkel ? "#353535" : "#FCFCFC"
    readonly property color schatten: dunkel ? "#66000000" : "#30000000"
    // dunklere Leiste unten in Startmenü und Schnelleinstellungen (Acrylic Basis)
    readonly property color fussleiste: dunkel ? "#33000000" : "#0B000000"
    readonly property color fussRand: dunkel ? "#1AFFFFFF" : "#0F000000"

    readonly property color kritisch: dunkel ? "#FF99A4" : "#C42B1C"
    readonly property color warnung: dunkel ? "#FCE100" : "#9D5D00"
    readonly property color erfolg: dunkel ? "#6CCB5F" : "#0F7B0F"

    function mitAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, c.a * a);
    }

    // Akzentpalette: für #0078D4 die exakten Windows-Werte, sonst Näherung über die Helligkeit
    function akzentStufe(c, stufe) {
        if (stufe === 0) {
            return c;
        }
        const exakt = {"-3": "#001A68", "-2": "#003E92", "-1": "#0067C0", "1": "#0091F8", "2": "#4CC2FF", "3": "#99EBFF"};
        if (Math.abs(c.r - 0) < 0.01 && Math.abs(c.g - 120 / 255) < 0.01 && Math.abs(c.b - 212 / 255) < 0.01) {
            return exakt[String(stufe)];
        }
        const l = Math.max(0, Math.min(1, c.hslLightness + stufe * 0.12));
        return Qt.hsla(c.hslHue, c.hslSaturation, l, 1);
    }
}
