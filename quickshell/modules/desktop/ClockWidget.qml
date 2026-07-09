// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Analog desktop clock: dark face, 12/3/6/9 numerals, smooth accent
// second hand, and a date/time bar below. Font is configurable
// (Settings → Desktop & Widgets); defaults to the interface font.

import QtQuick
import qs.config
import qs.components
import qs.services

Item {
    id: root

    width: 210
    height: 254

    readonly property string clockFont: Settings.data.clockWidgetFont !== ""
        ? Settings.data.clockWidgetFont : Theme.fontFamily

    property date now: new Date()

    // Sub-second ticks drive the smooth second hand; one-second ticks
    // under reduce-motion.
    Timer {
        interval: Theme.reduceMotion ? 1000 : 50
        running: root.visible
        repeat: true
        onTriggered: root.now = new Date()
    }

    readonly property real secs: now.getSeconds()
        + (Theme.reduceMotion ? 0 : now.getMilliseconds() / 1000)
    readonly property real mins: now.getMinutes() + secs / 60
    readonly property real hrs: (now.getHours() % 12) + mins / 60

    // ------------------------------------------------------------------ face
    Rectangle {
        id: face
        width: 210
        height: 210
        radius: width / 2
        color: "#15171c"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)

        // Minute ticks (12 positions).
        Repeater {
            model: 12

            Item {
                required property int index
                anchors.fill: parent
                rotation: index * 30

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    width: 2
                    height: 7
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.28)
                }
            }
        }

        // Main numerals.
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 20
            text: "12"
            color: "#e8eaee"
            font.family: root.clockFont
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 22
            anchors.verticalCenter: parent.verticalCenter
            text: "3"
            color: "#e8eaee"
            font.family: root.clockFont
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            text: "6"
            color: "#e8eaee"
            font.family: root.clockFont
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 22
            anchors.verticalCenter: parent.verticalCenter
            text: "9"
            color: "#e8eaee"
            font.family: root.clockFont
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }

        // Hands (each rotates about the face center).
        Item {
            anchors.fill: parent
            rotation: root.hrs * 30

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 - 50
                width: 5
                height: 50
                radius: 2.5
                color: "#e8eaee"
            }
        }
        Item {
            anchors.fill: parent
            rotation: root.mins * 6

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 - 74
                width: 3.5
                height: 74
                radius: 1.75
                color: "#c9ced8"
            }
        }
        Item {
            anchors.fill: parent
            rotation: root.secs * 6

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height / 2 - 84
                width: 1.5
                height: 96
                radius: 0.75
                color: Theme.accent
            }
        }

        // Center cap.
        Rectangle {
            anchors.centerIn: parent
            width: 11
            height: 11
            radius: 5.5
            color: Theme.accent
            border.width: 2
            border.color: "#15171c"
        }
    }

    // ------------------------------------------------------- date/time bar
    Rectangle {
        anchors.top: face.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: face.horizontalCenter
        width: face.width
        height: 34
        radius: height / 2
        color: Theme.popupBg
        border.width: 1
        border.color: Theme.popupBorder

        Text {
            anchors.centerIn: parent
            text: Time.dateShort + "   ·   " + Time.time
            color: Theme.fg
            font.family: root.clockFont
            font.pixelSize: Theme.fontSm
            font.weight: Font.Medium
        }
    }
}
