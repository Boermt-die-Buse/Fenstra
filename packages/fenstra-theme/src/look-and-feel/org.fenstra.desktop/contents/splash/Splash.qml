/*
 * Fenstra-Startbildschirm (KSplash): schwarzer Hintergrund, Logo, Ladering.
 * Bewusst schlicht wie der Windows-Start: keine Balken, kein Text.
 * Lizenz: GPL-2.0+ (Grundgerüst nach Breeze-Splash von KDE, angepasst).
 */
import QtQuick

Rectangle {
    id: root
    color: "#000000"

    property int stage

    onStageChanged: {
        if (stage === 1) {
            introAnimation.running = true
        } else if (stage === 5) {
            introAnimation.target = busyIndicator
            introAnimation.from = 1
            introAnimation.to = 0
            introAnimation.running = true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            source: "images/fenstra-logo-white.svg"
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.36 - height / 2
            width: Math.round(Math.min(parent.width, parent.height) * 0.16)
            height: width
            sourceSize.width: width
            sourceSize.height: height
            smooth: true
        }

        /* Ladering: ein kurzer Bogen, der sich dreht (wie der Windows-Ladering) */
        Canvas {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            y: parent.height * 0.72 - height / 2
            width: 36
            height: 36
            property real angle: 0
            onAngleChanged: requestPaint()
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                ctx.lineWidth = 3
                ctx.lineCap = "round"
                ctx.strokeStyle = "#FFFFFF"
                ctx.beginPath()
                ctx.arc(width / 2, height / 2, width / 2 - 3, angle, angle + Math.PI * 0.55)
                ctx.stroke()
            }
            RotationAnimation on angle {
                from: 0
                to: 2 * Math.PI
                duration: 1100
                loops: Animation.Infinite
                running: true
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 400
        easing.type: Easing.InOutQuad
    }
}
