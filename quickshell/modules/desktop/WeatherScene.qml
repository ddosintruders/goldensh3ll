// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Small animated weather vignette: rotating sun, drifting clouds,
// falling rain/snow, flashing storm. Pure QML primitives; all motion
// respects the reduce-motion setting.

import QtQuick
import qs.config
import qs.components

Item {
    id: root

    property string kind: "sun"

    clip: true

    component CloudShape: Item {
        property color tint: Theme.fgMuted

        width: 64
        height: 36

        Rectangle { x: 0; y: 14; width: 64; height: 22; radius: 11; color: parent.tint }
        Rectangle { x: 8; y: 5; width: 26; height: 26; radius: 13; color: parent.tint }
        Rectangle { x: 27; y: 0; width: 32; height: 32; radius: 16; color: parent.tint }
    }

    // --------------------------------------------------------------- sun
    Item {
        visible: root.kind === "sun"
        anchors.fill: parent

        Item {
            id: rays
            anchors.centerIn: parent
            width: 72
            height: 72

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 24000
                loops: Animation.Infinite
                running: root.kind === "sun" && root.visible && !Theme.reduceMotion
            }

            Repeater {
                model: 8

                Item {
                    required property int index
                    anchors.fill: parent
                    rotation: index * 45

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        width: 3
                        height: 11
                        radius: 1.5
                        color: Theme.warning
                    }
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: 36
            height: 36
            radius: 18
            color: Theme.warning
        }
    }

    // ------------------------------------------------------------- cloud
    Item {
        visible: root.kind === "cloud"
        anchors.fill: parent

        CloudShape {
            id: cloudBack
            x: 24
            y: 14
            scale: 0.7
            opacity: 0.55

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: root.kind === "cloud" && root.visible && !Theme.reduceMotion
                NumberAnimation { to: 34; duration: 4200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 24; duration: 4200; easing.type: Easing.InOutSine }
            }
        }
        CloudShape {
            id: cloudFront
            x: 10
            y: 34

            SequentialAnimation on x {
                loops: Animation.Infinite
                running: root.kind === "cloud" && root.visible && !Theme.reduceMotion
                NumberAnimation { to: 22; duration: 5200; easing.type: Easing.InOutSine }
                NumberAnimation { to: 10; duration: 5200; easing.type: Easing.InOutSine }
            }
        }
    }

    // ------------------------------------------------------- rain / snow
    Item {
        visible: root.kind === "rain" || root.kind === "snow"
        anchors.fill: parent

        CloudShape {
            x: 14
            y: 8
        }

        Repeater {
            model: 7

            Rectangle {
                id: drop

                required property int index

                readonly property bool snow: root.kind === "snow"

                x: 16 + index * 9
                width: snow ? 4 : 2.5
                height: snow ? 4 : 9
                radius: snow ? 2 : 1.2
                color: snow ? "#ffffff" : "#7cb8f5"
                opacity: 0.9
                y: 48

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: (root.kind === "rain" || root.kind === "snow")
                             && root.visible && !Theme.reduceMotion
                    PauseAnimation { duration: drop.index * 140 }
                    NumberAnimation {
                        from: 48
                        to: 86
                        duration: drop.snow ? 1700 : 850
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------- storm
    Item {
        visible: root.kind === "storm"
        anchors.fill: parent

        CloudShape {
            x: 14
            y: 8
            tint: Theme.fgDim
        }

        Icon {
            id: bolt
            x: 36
            y: 46
            name: "zap"
            size: 22
            color: Theme.warning
            opacity: 0.35

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.kind === "storm" && root.visible && !Theme.reduceMotion
                NumberAnimation { to: 1; duration: 120 }
                PauseAnimation { duration: 180 }
                NumberAnimation { to: 0.35; duration: 420 }
                PauseAnimation { duration: 1100 }
            }
        }
    }
}
