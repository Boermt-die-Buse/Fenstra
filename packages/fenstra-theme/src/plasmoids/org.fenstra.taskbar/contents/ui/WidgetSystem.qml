/*
    Fenstra-Widgets: Systemleistung – Prozessor- und Arbeitsspeicherauslastung (Plasma-Sensoren)
    als Balken in Akzentfarbe.
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick

import org.kde.ksysguard.sensors as Sensoren
import org.fenstra.shell

Column {
    id: s

    spacing: 10
    width: parent ? parent.width : 100

    Sensoren.Sensor {
        id: cpu
        sensorId: "cpu/all/usage"
        updateRateLimit: 2000
    }
    Sensoren.Sensor {
        id: ram
        sensorId: "memory/physical/usedPercent"
        updateRateLimit: 2000
    }

    Repeater {
        model: [
            {titel: "Prozessor", wert: Number(cpu.value) || 0},
            {titel: "Arbeitsspeicher", wert: Number(ram.value) || 0}
        ]
        delegate: Column {
            required property var modelData
            width: s.width
            spacing: 4
            Item {
                width: parent.width
                height: 16
                WinText {
                    stil: "caption"
                    text: modelData.titel
                }
                WinText {
                    anchors.right: parent.right
                    stil: "caption"
                    font.weight: Font.DemiBold
                    text: Math.round(modelData.wert) + " %"
                }
            }
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Farben.controlStarkDeaktiviert
                Rectangle {
                    width: parent.width * Math.min(1, modelData.wert / 100)
                    height: parent.height
                    radius: 3
                    color: Farben.akzentFlaeche
                    Behavior on width {
                        NumberAnimation { duration: 250 }
                    }
                }
            }
        }
    }
}
