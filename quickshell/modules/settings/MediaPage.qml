// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    SettingsGroup {
        width: parent.width
        title: "Media in top bar"

        SettingRow {
            label: "Show now playing"
            sublabel: "Compact media status on the right side of the top bar"

            GSwitch {
                checked: Settings.data.showMediaInBar
                onToggled: v => Settings.data.showMediaInBar = v
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Visualizer"

        SettingRow {
            label: "Audio visualizer"
            sublabel: Visualizer.available
                ? "Live spectrum next to the now-playing label (cava)"
                : "Requires cava — install it to enable"

            GSwitch {
                enabled: Visualizer.available || Settings.data.mediaVisualizer
                checked: Settings.data.mediaVisualizer
                onToggled: v => Settings.data.mediaVisualizer = v
            }
        }

        SettingRow {
            label: "Bars"
            sublabel: "Number of spectrum bars"

            GSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: 160
                value: (Settings.data.visualizerBars - 8) / 32
                onMoved: v => Settings.data.visualizerBars = 8 + Math.round(v * 32)
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                horizontalAlignment: Text.AlignRight
                text: Settings.data.visualizerBars
                color: Theme.fgDim
                font.pixelSize: Theme.fontSm
            }
        }

        SettingRow {
            label: "Bar shape"

            GSegmented {
                anchors.verticalCenter: parent.verticalCenter
                width: 240
                model: ["Rounded", "Square", "Dots"]
                currentIndex: Settings.data.visualizerShape === "square" ? 1
                            : Settings.data.visualizerShape === "dots" ? 2 : 0
                onSelected: i => Settings.data.visualizerShape =
                    i === 1 ? "square" : i === 2 ? "dots" : "rounded"
            }
        }

        SettingRow {
            label: "Bar color"
            sublabel: "Accent follows the theme (and dynamic color)"

            Row {
                spacing: 8

                // Accent (theme-following) swatch.
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: Theme.accent
                    border.width: Settings.data.visualizerColor === "accent" ? 2 : 0
                    border.color: Theme.fg

                    Icon {
                        anchors.centerIn: parent
                        visible: Settings.data.visualizerColor === "accent"
                        name: "check"
                        size: 12
                        color: Theme.onAccent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.data.visualizerColor = "accent"
                    }
                }

                Repeater {
                    model: ["#4fb3a8", "#5b9cf5", "#a78bfa", "#58b368", "#e57e94", "#e5605a"]

                    Rectangle {
                        id: colorSwatch

                        required property string modelData

                        width: 24
                        height: 24
                        radius: 12
                        color: modelData
                        border.width: Settings.data.visualizerColor === modelData ? 2 : 0
                        border.color: Theme.fg

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Settings.data.visualizerColor = colorSwatch.modelData
                        }
                    }
                }
            }
        }

        SettingRow {
            label: "Custom color"
            sublabel: "Hex value, e.g. #d9a94c"

            GTextField {
                width: 130
                placeholder: "#RRGGBB"
                onAccepted: {
                    const v = text.trim();
                    if (/^#[0-9a-fA-F]{6}$/.test(v))
                        Settings.data.visualizerColor = v;
                }
            }
        }
    }
}
