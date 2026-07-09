// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Standard push button. kind: "filled" | "tonal" | "danger" | "ghost"

import QtQuick
import qs.config

Rectangle {
    id: root

    property string text
    property string icon: ""
    property string kind: "tonal"
    property bool compact: false

    signal clicked()

    readonly property color fgColor: kind === "filled" ? Theme.onAccent
                                   : kind === "danger" ? Theme.danger
                                   : Theme.fg

    implicitHeight: compact ? 28 : 32
    implicitWidth: contentRow.implicitWidth + (compact ? 22 : 28)
    radius: Theme.radiusSm
    opacity: enabled ? 1 : 0.45
    scale: mouse.pressed && enabled ? 0.97 : 1

    color: {
        const hover = mouse.containsMouse && enabled;
        const pressed = mouse.pressed && enabled;
        if (kind === "filled") return pressed ? Qt.darker(Theme.accent, 1.08)
                                              : hover ? Qt.lighter(Theme.accent, 1.10) : Theme.accent;
        if (kind === "danger") return hover || pressed
                                   ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.28)
                                   : Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.16);
        if (kind === "ghost")  return pressed ? Theme.layerPressed
                                              : hover ? Theme.layerHover : "transparent";
        return pressed ? Theme.surfaceActive
             : hover ? Theme.surfaceHover : Theme.surface;
    }
    border.width: kind === "tonal" ? 1 : 0
    border.color: Theme.border

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.durFast; easing.type: Theme.easeStandard } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Icon {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: root.icon
            size: 14
            color: root.fgColor
        }
        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.fgColor
            font.pixelSize: root.compact ? Theme.fontSm : Theme.fontMd
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.clicked()
    }
}
