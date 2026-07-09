// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    SettingsGroup {
        width: parent.width
        title: "Theme"

        SettingRow {
            label: "Dark mode"
            sublabel: "Applies to the bars, popups and this window"

            GSwitch {
                checked: Settings.data.darkMode
                onToggled: v => Settings.data.darkMode = v
            }
        }

        SettingRow {
            label: "Dynamic color"
            sublabel: Wallpapers.matugenFound
                ? "Derive the palette from the current wallpaper"
                : "Requires matugen — install it to enable"

            GSwitch {
                enabled: Wallpapers.matugenFound || Settings.data.dynamicColor
                checked: Settings.data.dynamicColor
                onToggled: v => {
                    Settings.data.dynamicColor = v;
                    if (v && Settings.data.wallpaper)
                        Wallpapers.generatePalette(Settings.data.wallpaper);
                }
            }
        }

        SettingRow {
            label: "Accent color"
            sublabel: Theme.dynamicActive
                ? "Managed by dynamic color while it is enabled"
                : "Used for highlights, toggles and the focused workspace"

            Row {
                spacing: 8
                opacity: Theme.dynamicActive ? 0.35 : 1
                enabled: !Theme.dynamicActive

                Repeater {
                    model: ["gold", "teal", "blue", "violet", "green", "rose"]

                    Rectangle {
                        id: swatch

                        required property string modelData

                        readonly property bool selected: Settings.data.accent === modelData

                        width: 24
                        height: 24
                        radius: width / 2
                        color: Theme.accents[modelData]
                        border.width: selected ? 2 : 0
                        border.color: Theme.fg

                        Icon {
                            anchors.centerIn: parent
                            visible: swatch.selected
                            name: "check"
                            size: 12
                            color: "#1a1200"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Settings.data.accent = swatch.modelData
                        }
                    }
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Effects"

        SettingRow {
            label: "Translucency"
            sublabel: "Glass materials on bars and popups (uses compositor blur)"

            GSwitch {
                checked: Settings.data.translucency
                onToggled: v => Settings.data.translucency = v
            }
        }

        SettingRow {
            label: "Reduce motion"
            sublabel: "Disable panel and interaction animations"

            GSwitch {
                checked: Settings.data.reduceMotion
                onToggled: v => Settings.data.reduceMotion = v
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Top bar"

        SettingRow {
            label: "Floating bar"
            sublabel: "Detach the top bar from the screen edge with rounded corners"

            GSwitch {
                checked: Settings.data.barFloating
                onToggled: v => Settings.data.barFloating = v
            }
        }

        SettingRow {
            label: "Bar opacity"
            sublabel: Settings.data.translucency
                ? "Glass transparency of the bar background"
                : "Enable Translucency (below) to adjust"

            GSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: 160
                enabled: Settings.data.translucency
                opacity: Settings.data.translucency ? 1 : 0.4
                value: (Settings.data.barOpacity - 0.5) * 2
                onMoved: v => Settings.data.barOpacity = 0.5 + v * 0.5
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: 38
                horizontalAlignment: Text.AlignRight
                text: Math.round(Settings.data.barOpacity * 100) + "%"
                color: Theme.fgDim
                font.pixelSize: Theme.fontSm
            }
        }
    }

    SettingsGroup {
        id: cursorGroup

        width: parent.width
        title: "Cursor"

        property bool pickerOpen: false

        SettingRow {
            label: "Cursor theme"
            sublabel: CursorTheme.current || "System default — pick an installed theme"

            GButton {
                icon: "refresh-cw"
                compact: true
                kind: "ghost"
                text: "Rescan"
                onClicked: CursorTheme.scan()
            }
            GButton {
                text: cursorGroup.pickerOpen ? "Close" : "Change"
                compact: true
                onClicked: cursorGroup.pickerOpen = !cursorGroup.pickerOpen
            }
        }

        Column {
            width: parent.width
            spacing: 2
            visible: cursorGroup.pickerOpen

            Repeater {
                model: CursorTheme.themes

                ListButton {
                    required property string modelData
                    width: parent.width
                    icon: "mouse"
                    label: modelData
                    hint: modelData === CursorTheme.current ? "current" : ""
                    onClicked: CursorTheme.apply(modelData, CursorTheme.size)
                }
            }

            StyledText {
                visible: CursorTheme.themes.length === 0
                text: "No cursor themes found in ~/.icons or /usr/share/icons"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        SettingRow {
            label: "Cursor size"

            Row {
                spacing: 6

                Repeater {
                    model: [24, 32, 40]

                    GButton {
                        required property int modelData
                        text: modelData + "px"
                        compact: true
                        kind: CursorTheme.size === modelData ? "filled" : "tonal"
                        onClicked: CursorTheme.apply(
                            CursorTheme.current || "default", modelData)
                    }
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Typography"

        SettingRow {
            label: "Interface font"
            sublabel: "Google Sans is preferred when installed; otherwise the first available fallback is used"

            StyledText {
                text: Theme.fontFamily
                color: Theme.fgDim
            }
        }
    }
}
