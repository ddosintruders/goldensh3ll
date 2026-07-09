// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Hoverable pill container used for interactive widgets inside the bars.

import QtQuick
import qs.config

Rectangle {
    id: root

    property bool interactive: true
    property real hpad: 9
    readonly property alias containsMouse: mouse.containsMouse
    default property alias content: row.data

    signal clicked(var event)
    signal scrolled(int delta)

    implicitHeight: 26
    implicitWidth: row.implicitWidth + hpad * 2
    radius: height / 2
    color: !interactive ? "transparent"
         : mouse.pressed ? Theme.layerPressed
         : mouse.containsMouse ? Theme.layerHover
         : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => root.clicked(event)
        onWheel: event => root.scrolled(event.angleDelta.y > 0 ? 1 : -1)
    }
}
