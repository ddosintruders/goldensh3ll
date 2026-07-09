// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    property string tzQuery: ""
    readonly property var tzResults: tzQuery.trim().length > 0
        ? TimeDate.timezones.filter(t => t.toLowerCase().indexOf(tzQuery.toLowerCase()) !== -1).slice(0, 8)
        : []

    Component.onCompleted: {
        TimeDate.refresh();
        TimeDate.loadTimezones();
    }

    StyledText {
        visible: !TimeDate.available
        width: parent.width
        text: "timedatectl was not found — time settings are unavailable."
        color: Theme.fgMuted
        wrapMode: Text.WordWrap
    }

    SettingsGroup {
        visible: TimeDate.available
        width: parent.width
        title: "Time"

        SettingRow {
            label: "Set time automatically"
            sublabel: TimeDate.ntpSynchronized
                ? "Synchronized over the network (NTP)"
                : "Uses network time (NTP) when available"

            GSwitch {
                checked: TimeDate.ntp
                onToggled: v => TimeDate.setNtp(v)
            }
        }

        SettingRow {
            label: "Current time"

            StyledText {
                text: Qt.formatDateTime(Time.now, "yyyy-MM-dd") + "  " + Time.time
                color: Theme.fgDim
            }
        }

        SettingRow {
            label: "Set date and time"
            sublabel: TimeDate.ntp
                ? "Turn off automatic time to set manually"
                : "Applied through timedatectl (polkit prompt may appear)"

            GTextField {
                id: dateField
                enabled: !TimeDate.ntp
                width: 110
                placeholder: "YYYY-MM-DD"
            }
            GTextField {
                id: timeField
                enabled: !TimeDate.ntp
                width: 90
                placeholder: "HH:MM:SS"
            }
            GButton {
                text: "Apply"
                kind: "filled"
                compact: true
                enabled: !TimeDate.ntp && !TimeDate.busy
                    && dateField.text.length > 0 && timeField.text.length > 0
                onClicked: TimeDate.setTime(dateField.text, timeField.text)
            }
        }
    }

    SettingsGroup {
        visible: TimeDate.available
        width: parent.width
        title: "Time zone"

        SettingRow {
            label: "Current time zone"

            StyledText {
                text: TimeDate.timezone || "—"
                color: Theme.fgDim
            }
        }

        GTextField {
            width: parent.width
            leadingIcon: "search"
            placeholder: "Search time zones (e.g. Europe/Berlin)"
            onTextChanged: page.tzQuery = text
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: page.tzResults

                ListButton {
                    required property string modelData
                    width: parent.width
                    icon: "globe"
                    label: modelData
                    hint: modelData === TimeDate.timezone ? "current" : ""
                    onClicked: TimeDate.setTimezone(modelData)
                }
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Format"

        SettingRow {
            label: "Time format"
            sublabel: "Applies to the taskbar clock and lockscreen"

            GSegmented {
                anchors.verticalCenter: parent.verticalCenter
                width: 190
                model: ["12-hour", "24-hour"]
                currentIndex: Settings.data.clock24h ? 1 : 0
                onSelected: i => Settings.data.clock24h = i === 1
            }
        }
    }

    StyledText {
        visible: TimeDate.lastError !== ""
        width: parent.width
        text: TimeDate.lastError
        color: Theme.danger
        font.pixelSize: Theme.fontSm
        wrapMode: Text.WordWrap
    }
}
