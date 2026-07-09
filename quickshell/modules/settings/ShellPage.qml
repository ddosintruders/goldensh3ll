// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    property string pinQuery: ""
    readonly property var pinResults: pinQuery.trim().length > 0
        ? AppSearch.query(pinQuery).slice(0, 5) : []

    function movePin(index, delta) {
        const pins = [...Settings.data.pinnedApps];
        const target = index + delta;
        if (target < 0 || target >= pins.length)
            return;
        const tmp = pins[target];
        pins[target] = pins[index];
        pins[index] = tmp;
        Settings.data.pinnedApps = pins;
    }

    SettingsGroup {
        width: parent.width
        title: "Top bar"

        SettingRow {
            label: "Show battery"
            sublabel: "Hidden automatically on desktops without a battery"

            GSwitch {
                checked: Settings.data.showBattery
                onToggled: v => Settings.data.showBattery = v
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Taskbar"

        SettingRow {
            label: "Weather pill"
            sublabel: "Compact current weather next to the search bar (uses the Desktop & Widgets weather location)"

            GSwitch {
                checked: Settings.data.showWeatherInTaskbar
                onToggled: v => Settings.data.showWeatherInTaskbar = v
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Taskbar pinned apps"

        Column {
            width: parent.width
            spacing: 4

            Repeater {
                model: Settings.data.pinnedApps

                Item {
                    id: pinRow

                    required property string modelData
                    required property int index

                    readonly property var entry: AppSearch.entryFor(modelData)

                    width: parent.width
                    height: 38

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 22
                            sourceSize: Qt.size(44, 44)
                            source: AppSearch.iconFor(pinRow.entry, pinRow.modelData)
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: pinRow.entry !== null ? pinRow.entry.name : pinRow.modelData
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        GIconButton {
                            icon: "chevron-up"
                            buttonSize: 26
                            iconSize: 13
                            onClicked: page.movePin(pinRow.index, -1)
                        }
                        GIconButton {
                            icon: "chevron-down"
                            buttonSize: 26
                            iconSize: 13
                            onClicked: page.movePin(pinRow.index, 1)
                        }
                        GIconButton {
                            icon: "trash-2"
                            buttonSize: 26
                            iconSize: 13
                            iconColor: Theme.danger
                            onClicked: Settings.data.pinnedApps =
                                Settings.data.pinnedApps.filter((p, i) => i !== pinRow.index)
                        }
                    }
                }
            }

            StyledText {
                visible: Settings.data.pinnedApps.length === 0
                text: "No pinned apps"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        GTextField {
            id: pinSearch
            width: parent.width
            leadingIcon: "plus"
            placeholder: "Search for an app to pin"
            onTextChanged: page.pinQuery = text
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: page.pinResults

                ListButton {
                    required property var modelData
                    width: parent.width
                    label: modelData.name
                    icon: "plus"
                    onClicked: {
                        if (Settings.data.pinnedApps.indexOf(modelData.id) === -1)
                            Settings.data.pinnedApps = [...Settings.data.pinnedApps, modelData.id];
                        pinSearch.text = "";
                    }
                }
            }
        }
    }
}
