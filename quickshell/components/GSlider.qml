// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Minimal slider (0..1). Emits moved(value) while dragging; bind `value`
// to the backing service so external changes stay in sync.

import QtQuick
import qs.config

Item {
    id: root

    property real value: 0
    signal moved(real value)

    implicitHeight: 22
    implicitWidth: 160

    readonly property real handleSize: 14
    readonly property real usable: width - handleSize

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 5
        radius: height / 2
        color: Theme.surfaceActive
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: root.handleSize / 2 + root.usable * Math.max(0, Math.min(1, root.value))
        height: track.height
        radius: track.radius
        color: Theme.accent
    }

    Rectangle {
        x: root.usable * Math.max(0, Math.min(1, root.value))
        anchors.verticalCenter: parent.verticalCenter
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: "#ffffff"
        border.width: 1
        border.color: Qt.rgba(0, 0, 0, 0.18)
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.PointingHandCursor
        function update(mx) {
            root.moved(Math.max(0, Math.min(1, (mx - root.handleSize / 2) / root.usable)));
        }
        onPressed: event => update(event.x)
        onPositionChanged: event => { if (pressed) update(event.x); }
        onWheel: event => {
            const next = root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05);
            root.moved(Math.max(0, Math.min(1, next)));
        }
    }
}
