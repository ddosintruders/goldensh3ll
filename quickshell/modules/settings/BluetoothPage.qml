// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    StyledText {
        visible: !Bluetooth.available
        width: parent.width
        text: "No Bluetooth adapter found."
        color: Theme.fgMuted
        wrapMode: Text.WordWrap
    }

    SettingsGroup {
        visible: Bluetooth.available
        width: parent.width
        title: "Bluetooth"

        SettingRow {
            label: "Bluetooth"
            sublabel: Bluetooth.powered
                ? (Bluetooth.connectedCount > 0
                    ? Bluetooth.connectedCount + " device(s) connected" : "On")
                : "Off"

            GSwitch {
                checked: Bluetooth.powered
                onToggled: v => Bluetooth.setPowered(v)
            }
        }

        SettingRow {
            label: "Discovery"
            sublabel: "Scan for nearby devices to pair"

            GSwitch {
                enabled: Bluetooth.powered
                checked: Bluetooth.discovering
                onToggled: v => Bluetooth.setDiscovering(v)
            }
        }

        StyledText {
            visible: Bluetooth.lastError !== ""
            width: parent.width
            text: Bluetooth.lastError
            color: Theme.danger
            font.pixelSize: Theme.fontSm
            wrapMode: Text.WordWrap
        }
    }

    SettingsGroup {
        visible: Bluetooth.available && Bluetooth.powered
        width: parent.width
        title: "Devices"

        Column {
            width: parent.width
            spacing: 4

            Repeater {
                model: Bluetooth.devices

                Item {
                    id: devRow

                    required property var modelData

                    width: parent.width
                    height: 48

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            height: 32
                            radius: Theme.radiusSm
                            color: devRow.modelData.connected ? Theme.accent : Theme.surfaceHover

                            Icon {
                                anchors.centerIn: parent
                                name: Bluetooth.iconFor(devRow.modelData)
                                size: 15
                                color: devRow.modelData.connected ? Theme.onAccent : Theme.fgDim
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            StyledText {
                                text: devRow.modelData.name || devRow.modelData.address
                                font.weight: Font.Medium
                            }
                            StyledText {
                                text: Bluetooth.statusText(devRow.modelData)
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgMuted
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        GIconButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: devRow.modelData.paired
                            icon: "shield-check"
                            buttonSize: 26
                            iconSize: 13
                            active: devRow.modelData.trusted
                            onClicked: devRow.modelData.trusted = !devRow.modelData.trusted
                        }
                        GButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: devRow.modelData.paired || devRow.modelData.connected
                            text: devRow.modelData.connected ? "Disconnect" : "Connect"
                            compact: true
                            enabled: Bluetooth.busyAddress === ""
                            onClicked: devRow.modelData.connected
                                ? Bluetooth.disconnectDevice(devRow.modelData)
                                : Bluetooth.connectDevice(devRow.modelData)
                        }
                        GButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !devRow.modelData.paired && !devRow.modelData.connected
                            text: Bluetooth.busyAddress === devRow.modelData.address ? "Pairing…" : "Pair"
                            kind: "filled"
                            compact: true
                            enabled: Bluetooth.busyAddress === ""
                            onClicked: Bluetooth.pairDevice(devRow.modelData)
                        }
                        GIconButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: devRow.modelData.paired
                            icon: "trash-2"
                            buttonSize: 26
                            iconSize: 13
                            iconColor: Theme.danger
                            onClicked: Bluetooth.forgetDevice(devRow.modelData)
                        }
                    }
                }
            }

            StyledText {
                visible: Bluetooth.devices.length === 0
                text: Bluetooth.discovering ? "Searching…"
                    : "No devices. Turn on Discovery to find nearby devices."
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }
    }
}
