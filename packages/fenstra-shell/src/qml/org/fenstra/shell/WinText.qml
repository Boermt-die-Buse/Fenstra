/*
    Fenstra-Shell: Text in den WinUI-Schriftstilen (docs/windows11-referenz.md 1.3).
      stil: "caption" 12, "body" 14, "bodyStrong" 14 Semibold, "bodyLarge" 18,
            "subtitle" 20 Semibold, "title" 28 Semibold
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

Text {
    property string stil: "body"
    property bool sekundaer: false

    color: !enabled ? Farben.textDeaktiviert : (sekundaer ? Farben.textSekundaer : Farben.text)
    font.family: Farben.schrift
    font.pixelSize: stil === "caption" ? 12 : stil === "bodyLarge" ? 18 : stil === "subtitle" ? 20 : stil === "title" ? 28 : 14
    font.weight: (stil === "bodyStrong" || stil === "subtitle" || stil === "title") ? Font.DemiBold : Font.Normal
    elide: Text.ElideRight
    maximumLineCount: wrapMode === Text.NoWrap ? 1 : 3
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
}
