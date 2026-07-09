// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Wallpaper engine UI: browse a folder, apply per monitor, shuffle.

import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    // "" targets all displays.
    property string targetMonitor: ""

    SettingsGroup {
        width: parent.width
        title: "Library"

        SettingRow {
            label: "Wallpaper folder"
            sublabel: "Scanned up to two levels deep for jpg / png / webp / bmp"

            GTextField {
                width: 280
                text: Settings.data.wallpaperDir
                onAccepted: Settings.data.wallpaperDir = text
            }
            GButton {
                icon: "refresh-cw"
                text: Wallpapers.scanning ? "Scanning…" : "Rescan"
                enabled: !Wallpapers.scanning
                onClicked: Wallpapers.scan()
            }
        }

        StyledText {
            visible: Wallpapers.lastError !== ""
            width: parent.width
            text: Wallpapers.lastError
            color: Theme.danger
            font.pixelSize: Theme.fontSm
            wrapMode: Text.WordWrap
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Apply to"

        Row {
            spacing: 8

            GButton {
                text: "All displays"
                kind: page.targetMonitor === "" ? "filled" : "tonal"
                compact: true
                onClicked: page.targetMonitor = ""
            }

            Repeater {
                model: Quickshell.screens

                GButton {
                    required property var modelData
                    text: modelData.name
                    kind: page.targetMonitor === modelData.name ? "filled" : "tonal"
                    compact: true
                    onClicked: page.targetMonitor = modelData.name
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Wallpapers"

        StyledText {
            visible: Wallpapers.files.length === 0
            text: Wallpapers.scanning ? "Scanning folder…"
                : "No wallpapers found. Put images in " + Settings.data.wallpaperDir + " and rescan."
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }

        Flow {
            width: parent.width
            spacing: 10

            Repeater {
                model: Wallpapers.files

                Item {
                    id: thumb

                    required property string modelData

                    readonly property bool current:
                        Wallpapers.wallpaperFor(page.targetMonitor) === modelData

                    width: 158
                    height: 96

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: Theme.surfaceHover

                        Image {
                            anchors.fill: parent
                            source: "file://" + thumb.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize: Qt.size(316, 192)
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: "transparent"
                        border.width: thumb.current ? 2 : thumbMouse.containsMouse ? 1 : 0
                        border.color: thumb.current ? Theme.accent : Theme.fg
                    }

                    Rectangle {
                        visible: thumb.current
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 20
                        height: 20
                        radius: width / 2
                        color: Theme.accent

                        Icon {
                            anchors.centerIn: parent
                            name: "check"
                            size: 11
                            color: Theme.onAccent
                        }
                    }

                    MouseArea {
                        id: thumbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpapers.apply(thumb.modelData, page.targetMonitor)
                    }
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Lockscreen wallpaper"

        SettingRow {
            label: "Separate lockscreen wallpaper"
            sublabel: "Off: the lockscreen mirrors the desktop wallpaper"

            GSwitch {
                checked: Settings.data.separateLockWallpaper
                onToggled: v => Settings.data.separateLockWallpaper = v
            }
        }

        SettingRow {
            visible: Settings.data.separateLockWallpaper
            label: "Lockscreen folder"

            GTextField {
                width: 240
                text: Settings.data.lockWallpaperDir
                onAccepted: Settings.data.lockWallpaperDir = text
            }
            GButton {
                icon: "refresh-cw"
                text: "Rescan"
                compact: true
                onClicked: Wallpapers.scanLock()
            }
        }

        SettingRow {
            visible: Settings.data.separateLockWallpaper
            label: "Shuffle on lock"
            sublabel: "Pick a random lockscreen wallpaper every time the session locks"

            GSwitch {
                checked: Settings.data.lockWallpaperShuffle
                onToggled: v => Settings.data.lockWallpaperShuffle = v
            }
        }

        Flow {
            visible: Settings.data.separateLockWallpaper
            width: parent.width
            spacing: 10

            Repeater {
                model: Wallpapers.lockFiles

                Item {
                    id: lockThumb

                    required property string modelData

                    readonly property bool current: Settings.data.lockWallpaper === modelData

                    width: 158
                    height: 96

                    ClippingRectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: Theme.surfaceHover

                        Image {
                            anchors.fill: parent
                            source: "file://" + lockThumb.modelData
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize: Qt.size(316, 192)
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: "transparent"
                        border.width: lockThumb.current ? 2 : lockThumbMouse.containsMouse ? 1 : 0
                        border.color: lockThumb.current ? Theme.accent : Theme.fg
                    }

                    Rectangle {
                        visible: lockThumb.current
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 20
                        height: 20
                        radius: 10
                        color: Theme.accent

                        Icon {
                            anchors.centerIn: parent
                            name: "lock"
                            size: 10
                            color: Theme.onAccent
                        }
                    }

                    MouseArea {
                        id: lockThumbMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpapers.applyLock(lockThumb.modelData)
                    }
                }
            }

            StyledText {
                visible: Wallpapers.lockFiles.length === 0
                text: "No wallpapers found in the lockscreen folder"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Shuffle"

        SettingRow {
            label: "Shuffle wallpapers"
            sublabel: "Rotate through the library on all displays"

            GSwitch {
                checked: Settings.data.wallpaperShuffle
                onToggled: v => Settings.data.wallpaperShuffle = v
            }
        }

        SettingRow {
            label: "Interval"
            sublabel: "Minutes between wallpaper changes (type a value or step by 1)"

            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "minus"
                buttonSize: 26
                iconSize: 13
                onClicked: Settings.data.wallpaperShuffleMinutes =
                    Math.max(1, Settings.data.wallpaperShuffleMinutes - 1)
            }
            GTextField {
                id: intervalField
                anchors.verticalCenter: parent.verticalCenter
                width: 64
                text: Settings.data.wallpaperShuffleMinutes
                onEditingFinished: {
                    const n = parseInt(text);
                    if (!isNaN(n))
                        Settings.data.wallpaperShuffleMinutes = Math.max(1, Math.min(1440, n));
                    text = Settings.data.wallpaperShuffleMinutes;
                }
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "min"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "plus"
                buttonSize: 26
                iconSize: 13
                onClicked: Settings.data.wallpaperShuffleMinutes =
                    Math.min(1440, Settings.data.wallpaperShuffleMinutes + 1)
            }
        }

        SettingRow {
            label: "Shuffle now"

            GButton {
                icon: "shuffle"
                text: "Next wallpaper"
                enabled: Wallpapers.files.length > 1
                onClicked: Wallpapers.applyRandom()
            }
        }
    }
}
