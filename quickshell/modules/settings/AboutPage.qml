// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

SettingsPage {
    Component.onCompleted: SysInfo.refresh()

    Column {
        width: parent.width
        spacing: 8

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: Theme.logo
            width: 72
            height: 72
            fillMode: Image.PreserveAspectFit
            mipmap: true
        }
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "GoldenSh3ll"
            font.pixelSize: Theme.fontH1
            font.weight: Font.DemiBold
        }
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Version " + Theme.version
            color: Theme.fgDim
        }
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Open-source opinionated desktop environment for Wayland compositors"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: creditRow.implicitWidth + 26
            height: 26
            radius: height / 2
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            Row {
                id: creditRow
                anchors.centerIn: parent
                spacing: 6

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sparkles"
                    size: 12
                    color: Theme.accent
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Designed with Claude Fable 5"
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgDim
                }
            }
        }

        GButton {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "external-link"
            text: "github.com/ddosintruders/goldensh3ll"
            kind: "ghost"
            compact: true
            onClicked: Quickshell.execDetached(
                ["xdg-open", "https://github.com/ddosintruders/goldensh3ll"])
        }
    }

    SettingsGroup {
        width: parent.width
        title: "System"

        SettingRow {
            label: "Operating system"
            StyledText { text: SysInfo.os || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Hostname"
            StyledText { text: SysInfo.hostname || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Kernel"
            StyledText { text: SysInfo.kernel || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Uptime"
            StyledText { text: SysInfo.uptime || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Processor"
            StyledText { text: SysInfo.cpu || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Memory"
            StyledText { text: SysInfo.memory || "—"; color: Theme.fgDim }
        }
        SettingRow {
            label: "Quickshell"
            StyledText { text: SysInfo.qsVersion || "—"; color: Theme.fgDim }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Maintenance"

        SettingRow {
            label: "Restart shell"
            sublabel: "Reload the GoldenSh3ll configuration"

            GButton {
                icon: "refresh-cw"
                text: "Restart"
                onClicked: Quickshell.reload(true)
            }
        }

        SettingRow {
            label: "Reload Hyprland"
            sublabel: "Re-read the Hyprland configuration"

            GButton {
                icon: "rotate-ccw"
                text: "Reload"
                onClicked: Quickshell.execDetached(["hyprctl", "reload"])
            }
        }
    }
}
