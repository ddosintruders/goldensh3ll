// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Text that slowly scrolls horizontally when it overflows its width
// (marquee). Falls back to eliding under reduce-motion.

import QtQuick
import qs.config

Item {
    id: root

    property string text: ""
    property color color: Theme.fg
    property int pixelSize: Theme.fontMd
    property int weight: Font.Normal

    implicitHeight: label.implicitHeight
    implicitWidth: label.implicitWidth
    clip: true

    readonly property bool overflow: label.implicitWidth > width + 1

    StyledText {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        color: root.color
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        elide: root.overflow && Theme.reduceMotion ? Text.ElideRight : Text.ElideNone
        width: root.overflow && Theme.reduceMotion ? root.width : implicitWidth
    }

    SequentialAnimation {
        id: marquee

        running: root.overflow && !Theme.reduceMotion && root.visible
        loops: Animation.Infinite

        onRunningChanged: {
            if (!running)
                label.x = 0;
        }

        PauseAnimation { duration: 1800 }
        NumberAnimation {
            target: label
            property: "x"
            to: -(label.implicitWidth - root.width)
            duration: Math.max(600, (label.implicitWidth - root.width) * 33)
        }
        PauseAnimation { duration: 1400 }
        NumberAnimation {
            target: label
            property: "x"
            to: 0
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}
