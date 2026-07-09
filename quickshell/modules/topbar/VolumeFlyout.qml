// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Volume flyout: master slider + output device picker.

import QtQuick
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 320
    panelPadding: 14

    Column {
        width: parent.width
        spacing: 10

        Row {
            width: parent.width

            StyledText {
                text: "Volume"
                font.weight: Font.DemiBold
            }
            Item { width: parent.width - 90; height: 1 }
            StyledText {
                width: 40
                horizontalAlignment: Text.AlignRight
                text: Math.round((Audio.muted ? 0 : Audio.volume) * 100) + "%"
                color: Theme.fgDim
            }
        }

        Row {
            width: parent.width
            spacing: 10

            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: Audio.iconName()
                buttonSize: 28
                iconSize: 15
                onClicked: Audio.toggleMute()
            }
            GSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 38
                value: Audio.muted ? 0 : Audio.volume
                onMoved: v => Audio.setVolume(v)
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        StyledText {
            text: "OUTPUT DEVICE"
            font.pixelSize: Theme.fontXs
            font.weight: Font.DemiBold
            color: Theme.fgMuted
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Audio.sinks

                Rectangle {
                    id: deviceRow

                    required property var modelData
                    readonly property bool current: modelData === Audio.sink

                    width: parent.width
                    height: 32
                    radius: Theme.radiusXs
                    color: devMouse.containsMouse ? Theme.surfaceHover : "transparent"

                    StyledText {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: checkIcon.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: deviceRow.modelData.description || deviceRow.modelData.name
                        elide: Text.ElideRight
                        font.pixelSize: Theme.fontSm
                        color: deviceRow.current ? Theme.fg : Theme.fgDim
                    }

                    Icon {
                        id: checkIcon
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        name: "check"
                        size: 13
                        color: Theme.accent
                        visible: deviceRow.current
                    }

                    MouseArea {
                        id: devMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Audio.setSink(deviceRow.modelData)
                    }
                }
            }
        }
    }
}
