// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    property string shortcutQuery: ""
    readonly property var shortcutResults: shortcutQuery.trim().length > 0
        ? AppSearch.query(shortcutQuery).slice(0, 5) : []

    SettingsGroup {
        width: parent.width
        title: "Widgets"

        SettingRow {
            label: "Edit mode"
            sublabel: "Drag widgets on the desktop to reposition; ✕ removes them"

            GSwitch {
                checked: GlobalState.desktopEditMode
                onToggled: v => GlobalState.desktopEditMode = v
            }
        }

        Row {
            spacing: 8

            GButton {
                icon: "clock"
                text: "Add clock"
                onClicked: Settings.data.desktopWidgets =
                    [...Settings.data.desktopWidgets, "clock::140::160"]
            }
            GButton {
                icon: "cloud"
                text: "Add weather"
                onClicked: Settings.data.desktopWidgets =
                    [...Settings.data.desktopWidgets, "weather::140::300"]
            }
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Settings.data.desktopWidgets

                Item {
                    id: widgetRow

                    required property string modelData
                    required property int index

                    readonly property string type: modelData.split("::")[0]

                    width: parent.width
                    height: 34

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: widgetRow.type === "weather" ? "cloud" : "clock"
                            size: 14
                            color: Theme.fgDim
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: widgetRow.type === "weather" ? "Weather" : "Clock"
                        }
                    }

                    GIconButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "trash-2"
                        buttonSize: 26
                        iconSize: 13
                        iconColor: Theme.danger
                        onClicked: Settings.data.desktopWidgets =
                            Settings.data.desktopWidgets.filter((w, i) => i !== widgetRow.index)
                    }
                }
            }

            StyledText {
                visible: Settings.data.desktopWidgets.length === 0
                text: "No widgets on the desktop"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Clock widget"

        property string fontQuery: ""

        readonly property var fontResults: fontQuery.trim().length > 0
            ? Qt.fontFamilies().filter(f =>
                f.toLowerCase().indexOf(fontQuery.toLowerCase().trim()) !== -1).slice(0, 6)
            : []

        id: clockGroup

        SettingRow {
            label: "Font"
            sublabel: Settings.data.clockWidgetFont !== ""
                ? Settings.data.clockWidgetFont
                : "Google Sans (interface default)"

            GButton {
                visible: Settings.data.clockWidgetFont !== ""
                text: "Reset"
                kind: "ghost"
                compact: true
                onClicked: Settings.data.clockWidgetFont = ""
            }
        }

        GTextField {
            width: parent.width
            leadingIcon: "type"
            placeholder: "Search installed fonts"
            onTextChanged: clockGroup.fontQuery = text
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: clockGroup.fontResults

                Rectangle {
                    id: fontRow

                    required property string modelData

                    width: parent.width
                    height: 34
                    radius: Theme.radiusXs
                    color: fontMouse.containsMouse ? Theme.layerHover : "transparent"

                    // Rendered in its own family as a live preview.
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: fontRow.modelData
                        color: Theme.fg
                        font.family: fontRow.modelData
                        font.pixelSize: Theme.fontMd
                    }

                    StyledText {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Settings.data.clockWidgetFont === fontRow.modelData
                        text: "current"
                        font.pixelSize: Theme.fontSm
                        color: Theme.fgMuted
                    }

                    MouseArea {
                        id: fontMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.data.clockWidgetFont = fontRow.modelData
                    }
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Weather"

        SettingRow {
            label: "Location"
            sublabel: Weather.place !== "" ? Weather.place : "Not set"

            GTextField {
                id: locationField
                width: 200
                leadingIcon: "map-pin"
                placeholder: "City name"
                onAccepted: Weather.setLocation(text)
            }
            GButton {
                text: Weather.geocoding ? "Searching…" : "Set"
                compact: true
                kind: "filled"
                enabled: !Weather.geocoding && locationField.text.trim().length > 0
                onClicked: Weather.setLocation(locationField.text)
            }
        }

        SettingRow {
            label: "Units"

            Row {
                spacing: 6

                GButton {
                    text: "°C"
                    compact: true
                    kind: Settings.data.weatherCelsius ? "filled" : "tonal"
                    onClicked: Settings.data.weatherCelsius = true
                }
                GButton {
                    text: "°F"
                    compact: true
                    kind: !Settings.data.weatherCelsius ? "filled" : "tonal"
                    onClicked: Settings.data.weatherCelsius = false
                }
            }
        }

        StyledText {
            visible: Weather.lastError !== ""
            width: parent.width
            text: Weather.lastError
            color: Theme.danger
            font.pixelSize: Theme.fontSm
            wrapMode: Text.WordWrap
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Desktop shortcuts"

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Settings.data.desktopShortcuts

                Item {
                    id: scRow

                    required property string modelData

                    readonly property var entry: AppSearch.entryFor(modelData)

                    width: parent.width
                    height: 36

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 22
                            sourceSize: Qt.size(44, 44)
                            source: AppSearch.iconFor(scRow.entry, scRow.modelData)
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: scRow.entry !== null ? scRow.entry.name : scRow.modelData
                        }
                    }

                    GIconButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "trash-2"
                        buttonSize: 26
                        iconSize: 13
                        iconColor: Theme.danger
                        onClicked: Settings.data.desktopShortcuts =
                            Settings.data.desktopShortcuts.filter(s => s !== scRow.modelData)
                    }
                }
            }

            StyledText {
                visible: Settings.data.desktopShortcuts.length === 0
                text: "No desktop shortcuts"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        GTextField {
            width: parent.width
            leadingIcon: "plus"
            placeholder: "Search for an app to add to the desktop"
            onTextChanged: page.shortcutQuery = text
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: page.shortcutResults

                ListButton {
                    required property var modelData
                    width: parent.width
                    icon: "plus"
                    label: modelData.name
                    onClicked: {
                        if (Settings.data.desktopShortcuts.indexOf(modelData.id) === -1)
                            Settings.data.desktopShortcuts =
                                [...Settings.data.desktopShortcuts, modelData.id];
                        page.shortcutQuery = "";
                    }
                }
            }
        }
    }
}
