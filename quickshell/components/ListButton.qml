// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Menu-style row: icon + label with optional trailing hint.

import QtQuick
import qs.config

Rectangle {
    id: root

    property string icon: ""
    property string label
    property string hint: ""
    property bool danger: false

    signal clicked()

    readonly property color textColor: danger ? Theme.danger : Theme.fg

    implicitHeight: 32
    radius: Theme.radiusXs
    color: mouse.pressed ? Theme.layerPressed
         : mouse.containsMouse ? Theme.layerHover
         : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    Icon {
        id: leadIcon
        visible: root.icon !== ""
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        name: root.icon
        size: 14
        color: root.danger ? Theme.danger : Theme.fgDim
    }

    StyledText {
        anchors.left: parent.left
        anchors.leftMargin: root.icon !== "" ? 32 : 10
        anchors.right: hintText.visible ? hintText.left : parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: root.textColor
        elide: Text.ElideRight
    }

    StyledText {
        id: hintText
        visible: root.hint !== ""
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: root.hint
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
