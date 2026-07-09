// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Segmented control with an animated sliding thumb.

import QtQuick
import qs.config

Rectangle {
    id: root

    property var model: []
    property int currentIndex: 0

    signal selected(int index)

    readonly property real segWidth: model.length > 0
        ? (width - 6) / model.length : 0

    implicitHeight: 30
    implicitWidth: Math.max(140, model.length * 78)
    radius: height / 2
    color: Theme.surface
    border.width: 1
    border.color: Theme.border

    Rectangle {
        x: 3 + root.currentIndex * root.segWidth
        anchors.verticalCenter: parent.verticalCenter
        width: root.segWidth
        height: parent.height - 6
        radius: height / 2
        color: Theme.accent

        Behavior on x { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
    }

    Row {
        anchors.fill: parent
        anchors.margins: 3

        Repeater {
            model: root.model

            Item {
                required property string modelData
                required property int index

                width: root.segWidth
                height: parent.height

                StyledText {
                    anchors.centerIn: parent
                    text: parent.modelData
                    font.pixelSize: Theme.fontSm
                    font.weight: parent.index === root.currentIndex ? Font.DemiBold : Font.Normal
                    color: parent.index === root.currentIndex ? Theme.onAccent : Theme.fgDim
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(parent.index)
                }
            }
        }
    }
}
