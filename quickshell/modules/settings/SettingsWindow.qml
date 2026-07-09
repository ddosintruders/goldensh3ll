// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The GoldenSh3ll system settings application — Windows 11 navigation
// (profile card, accent-bar selection) with macOS-style tinted nav chips.

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.components
import qs.services

FloatingWindow {
    id: win

    title: "GoldenSh3ll Settings"
    implicitWidth: 960
    implicitHeight: 640
    color: Theme.bg

    onVisibleChanged: {
        if (!visible)
            GlobalState.settingsOpen = false;
    }

    readonly property var pages: [
        { id: "profile", label: "Profile", icon: "circle-user-round" },
        { id: "appearance", label: "Appearance", icon: "palette" },
        { id: "wallpaper", label: "Wallpaper", icon: "image" },
        { id: "desktop", label: "Desktop & Widgets", icon: "monitor" },
        { id: "shell", label: "Bar & Taskbar", icon: "panel-top" },
        { id: "defaultapps", label: "Default Apps", icon: "app-window" },
        { id: "audio", label: "Sound", icon: "speaker" },
        { id: "media", label: "Media", icon: "audio-lines" },
        { id: "network", label: "Network", icon: "wifi" },
        { id: "bluetooth", label: "Bluetooth", icon: "bluetooth" },
        { id: "accounts", label: "Accounts", icon: "circle-user-round" },
        { id: "timedate", label: "Time & Date", icon: "clock" },
        { id: "about", label: "About", icon: "info" }
    ]
    readonly property int currentIndex: {
        const i = pages.findIndex(p => p.id === GlobalState.settingsPage);
        return i >= 0 ? i : 1;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ---------------------------------------------------------- sidebar
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 236
            color: Theme.dark ? Qt.rgba(1, 1, 1, 0.02) : Qt.rgba(0, 0, 0, 0.03)

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: Theme.border
            }

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                // Profile card (navigates to the Profile page).
                Rectangle {
                    id: profileCard

                    readonly property bool current: GlobalState.settingsPage === "profile"

                    width: parent.width
                    height: 56
                    radius: Theme.radiusSm
                    color: current ? Theme.layerSelected
                         : profileMouse.containsMouse ? Theme.layerHover : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.animFast } }

                    Rectangle {
                        visible: profileCard.current
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 3
                        height: 22
                        radius: 1.5
                        color: Theme.accent
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        AvatarBadge {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 36
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            StyledText {
                                text: Profile.displayName
                                font.weight: Font.DemiBold
                                width: 150
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: "Local account"
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgMuted
                            }
                        }
                    }

                    MouseArea {
                        id: profileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: GlobalState.settingsPage = "profile"
                    }
                }

                Rectangle { width: parent.width; height: 1; color: Theme.border }

                Item { width: 1; height: 4 }

                Repeater {
                    model: win.pages.filter(p => p.id !== "profile")

                    Rectangle {
                        id: navItem

                        required property var modelData

                        readonly property bool current: GlobalState.settingsPage === modelData.id

                        width: parent.width
                        height: 34
                        radius: Theme.radiusSm
                        color: current ? Theme.layerSelected
                             : navMouse.containsMouse ? Theme.layerHover : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Rectangle {
                            visible: navItem.current
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: 18
                            radius: 1.5
                            color: Theme.accent
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: navItem.modelData.icon
                                size: 15
                                color: navItem.current ? Theme.accent : Theme.fgDim
                            }
                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: navItem.modelData.label
                                font.weight: navItem.current ? Font.DemiBold : Font.Normal
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: GlobalState.settingsPage = navItem.modelData.id
                        }
                    }
                }
            }

            StyledText {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 16
                text: "v" + Theme.version
                font.pixelSize: Theme.fontXs
                color: Theme.fgMuted
            }
        }

        // ---------------------------------------------------------- content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: win.pages[win.currentIndex].label
                    font.pixelSize: Theme.fontH1 - 4
                    font.weight: Font.DemiBold
                }

                GIconButton {
                    icon: "x"
                    onClicked: GlobalState.settingsOpen = false
                }
            }

            StackLayout {
                id: stack

                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: win.currentIndex

                onCurrentIndexChanged: pageFade.restart()

                ProfilePage {}
                AppearancePage {}
                WallpaperPage {}
                DesktopPage {}
                ShellPage {}
                DefaultAppsPage {}
                AudioPage {}
                MediaPage {}
                NetworkPage {}
                BluetoothPage {}
                AccountsPage {}
                TimeDatePage {}
                AboutPage {}
            }

            NumberAnimation {
                id: pageFade
                target: stack
                property: "opacity"
                from: 0.35
                to: 1
                duration: Theme.durMed
                easing.type: Theme.easeStandard
            }
        }
    }
}
