// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config

Rectangle {
    id: root

    property string icon
    property real iconSize: 16
    property bool active: false
    property bool circle: true
    property color iconColor: active ? Theme.onAccent
                            : mouse.containsMouse ? Theme.fg : Theme.fgDim
    property real buttonSize: 30

    signal clicked()

    implicitWidth: buttonSize
    implicitHeight: buttonSize
    radius: circle ? height / 2 : Theme.radiusXs
    color: active ? Theme.accent
         : mouse.pressed ? Theme.layerPressed
         : mouse.containsMouse ? Theme.layerHover
         : "transparent"
    scale: mouse.pressed ? 0.92 : 1

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.durFast; easing.type: Theme.easeStandard } }

    Icon {
        anchors.centerIn: parent
        name: root.icon
        size: root.iconSize
        color: root.iconColor
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
