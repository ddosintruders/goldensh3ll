// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    component DeviceRow: Rectangle {
        id: row

        property var node
        property bool current: false

        signal picked()

        width: parent.width
        height: 36
        radius: Theme.radiusSm
        color: rowMouse.containsMouse ? Theme.surfaceHover : "transparent"

        Rectangle {
            id: radio
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: width / 2
            color: "transparent"
            border.width: row.current ? 5 : 1
            border.color: row.current ? Theme.accent : Theme.fgMuted

            Behavior on border.width { NumberAnimation { duration: Theme.animFast } }
        }

        StyledText {
            anchors.left: radio.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            text: row.node !== null ? (row.node.description || row.node.name) : ""
            elide: Text.ElideRight
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.picked()
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Output"

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Audio.sinks

                DeviceRow {
                    required property var modelData
                    node: modelData
                    current: modelData === Audio.sink
                    onPicked: Audio.setSink(modelData)
                }
            }

            StyledText {
                visible: Audio.sinks.length === 0
                text: "No output devices"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        SettingRow {
            label: "Volume"

            GIconButton {
                icon: Audio.iconName()
                buttonSize: 26
                iconSize: 14
                onClicked: Audio.toggleMute()
            }
            GSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: 220
                value: Audio.muted ? 0 : Audio.volume
                onMoved: v => Audio.setVolume(v)
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                horizontalAlignment: Text.AlignRight
                text: Math.round((Audio.muted ? 0 : Audio.volume) * 100) + "%"
                color: Theme.fgDim
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Input"

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Audio.sources

                DeviceRow {
                    required property var modelData
                    node: modelData
                    current: modelData === Audio.source
                    onPicked: Audio.setSource(modelData)
                }
            }

            StyledText {
                visible: Audio.sources.length === 0
                text: "No input devices"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        SettingRow {
            label: "Microphone volume"

            GIconButton {
                icon: Audio.micMuted ? "mic-off" : "mic"
                buttonSize: 26
                iconSize: 14
                onClicked: Audio.toggleMicMute()
            }
            GSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: 220
                value: Audio.micMuted ? 0 : Audio.micVolume
                onMoved: v => Audio.setMicVolume(v)
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                horizontalAlignment: Text.AlignRight
                text: Math.round((Audio.micMuted ? 0 : Audio.micVolume) * 100) + "%"
                color: Theme.fgDim
            }
        }
    }
}
