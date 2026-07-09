// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import Quickshell.Widgets
import qs.config
import qs.components
import qs.services

SettingsPage {
    SettingsGroup {
        width: parent.width
        title: "Profile"

        Row {
            spacing: 16

            AvatarBadge {
                anchors.verticalCenter: parent.verticalCenter
                size: 64
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                StyledText {
                    text: Profile.displayName
                    font.pixelSize: Theme.fontXl
                    font.weight: Font.DemiBold
                }
                StyledText {
                    text: "Local account · @" + SysInfo.user
                    font.pixelSize: Theme.fontSm
                    color: Theme.fgMuted
                }
            }
        }

        SettingRow {
            label: "Display name"
            sublabel: "Shown on the lockscreen and in settings"

            GTextField {
                width: 220
                text: Settings.data.userName
                placeholder: SysInfo.user.charAt(0).toUpperCase() + SysInfo.user.slice(1)
                onEditingFinished: Settings.data.userName = text
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Avatar"

        Flow {
            width: parent.width
            spacing: 10

            // "None" — accent initial.
            Rectangle {
                width: 52
                height: 52
                radius: 26
                color: "transparent"
                border.width: Settings.data.avatar === "" ? 2 : 0
                border.color: Theme.accent

                Rectangle {
                    anchors.centerIn: parent
                    width: 44
                    height: 44
                    radius: 22
                    color: Theme.accent

                    StyledText {
                        anchors.centerIn: parent
                        text: Profile.initial
                        color: Theme.onAccent
                        font.weight: Font.DemiBold
                        font.pixelSize: Theme.fontLg
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Settings.data.avatar = ""
                }
            }

            Repeater {
                model: 8

                Rectangle {
                    id: presetCell

                    required property int index

                    readonly property string presetId: "preset:" + (index + 1)

                    width: 52
                    height: 52
                    radius: 26
                    color: "transparent"
                    border.width: Settings.data.avatar === presetId ? 2 : 0
                    border.color: Theme.accent

                    ClippingRectangle {
                        anchors.centerIn: parent
                        width: 44
                        height: 44
                        radius: 22
                        color: Theme.surfaceHover

                        Image {
                            anchors.fill: parent
                            source: Qt.resolvedUrl("../../assets/avatars/abstract-"
                                                   + (presetCell.index + 1) + ".svg")
                            sourceSize: Qt.size(88, 88)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.data.avatar = presetCell.presetId
                    }
                }
            }
        }

        SettingRow {
            label: "Custom image"
            sublabel: "Absolute path to a square image file"

            GTextField {
                width: 280
                leadingIcon: "image"
                placeholder: Settings.home + "/Pictures/me.png"
                text: Settings.data.avatar.startsWith("preset:") ? "" : Settings.data.avatar
                onAccepted: {
                    if (text.trim().length > 0)
                        Settings.data.avatar = text.trim();
                }
            }
        }
    }
}
