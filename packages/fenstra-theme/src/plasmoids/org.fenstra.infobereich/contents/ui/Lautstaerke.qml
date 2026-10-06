/*
    Fenstra-Infobereich: Zustand der Lautstärke (plasma-pa, bevorzugtes Ausgabegerät).
    Eigene Datei für einen Loader: fehlt das Modul, bleibt der Rest des Infobereichs nutzbar.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import org.kde.plasma.private.volume

Item {
    readonly property var sink: PreferredDevice.sink
    readonly property bool vorhanden: sink !== null && sink !== undefined && sink.name !== "auto_null"
    readonly property int prozent: vorhanden ? Math.round(sink.volume / PulseAudio.NormalVolume * 100) : 0
    readonly property bool stumm: !vorhanden || sink.muted

    function setzen(p) {
        if (vorhanden) {
            sink.volume = Math.round(Math.max(0, Math.min(100, p)) / 100 * PulseAudio.NormalVolume);
            if (p > 0 && sink.muted) {
                sink.muted = false;
            }
        }
    }
    function umschalten() {
        if (vorhanden) {
            sink.muted = !sink.muted;
        }
    }
}
