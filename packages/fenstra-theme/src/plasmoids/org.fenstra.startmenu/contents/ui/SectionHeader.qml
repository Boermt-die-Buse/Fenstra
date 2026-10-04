/*
    Fenstra-Startmenü: Abschnittsüberschrift mit optionalem Knopf rechts
    ("Angeheftet ... Alle Apps >", "Alle Apps ... < Zurück")
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

RowLayout {
    id: header

    property string title
    property string buttonText: ""
    property string buttonIcon: ""
    property bool buttonIconFirst: false
    signal buttonClicked()

    Layout.fillWidth: true
    spacing: Kirigami.Units.smallSpacing

    PC3.Label {
        Layout.fillWidth: true
        text: header.title
        font.weight: Font.DemiBold
        leftPadding: Kirigami.Units.largeSpacing
    }

    PC3.Button {
        visible: header.buttonText.length > 0
        flat: false
        text: header.buttonText
        icon.name: header.buttonIcon
        LayoutMirroring.enabled: !header.buttonIconFirst
        onClicked: header.buttonClicked()
    }
}
