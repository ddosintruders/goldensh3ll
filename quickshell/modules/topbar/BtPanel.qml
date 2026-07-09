// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Compact Bluetooth panel inside the control center: paired devices with
// connect/disconnect/forget, plus discovery for pairing new devices.

import QtQuick
import qs.config
import qs.components
import qs.services

Column {
    id: root

    signal back()
    signal requestSettings()

    spacing: 10

    Item {
        width: parent.width
        height: 28

        GIconButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: "arrow-left"
            buttonSize: 26
            iconSize: 14
            onClicked: root.back()
        }
        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: 34
            anchors.verticalCenter: parent.verticalCenter
            text: "Bluetooth"
            font.pixelSize: Theme.fontLg
            font.weight: Font.DemiBold
        }
        GSwitch {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: Bluetooth.powered
            onToggled: v => Bluetooth.setPowered(v)
        }
    }

    StyledText {
        visible: !Bluetooth.powered
        text: "Bluetooth is off"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
    }

    StyledText {
        visible: Bluetooth.lastError !== ""
        width: parent.width
        text: Bluetooth.lastError
        color: Theme.danger
        font.pixelSize: Theme.fontXs
        wrapMode: Text.WordWrap
    }

    // ------------------------------------------------------ paired devices
    StyledText {
        visible: Bluetooth.powered && Bluetooth.pairedDevices.length > 0
        role: Theme.typeOverline
        text: "MY DEVICES"
        color: Theme.fgMuted
    }

    Column {
        width: parent.width
        spacing: 2
        visible: Bluetooth.powered

        Repeater {
            model: Bluetooth.pairedDevices

            Item {
                id: devRow

                required property var modelData

                width: parent.width
                height: 40

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: Bluetooth.iconFor(devRow.modelData)
                        size: 15
                        color: devRow.modelData.connected ? Theme.accent : Theme.fgDim
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        StyledText {
                            text: devRow.modelData.name || devRow.modelData.address
                            font.pixelSize: Theme.fontSm
                            font.weight: devRow.modelData.connected ? Font.DemiBold : Font.Normal
                            width: root.width - 170
                            elide: Text.ElideRight
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

                    GButton {
                        text: devRow.modelData.connected ? "Disconnect" : "Connect"
                        kind: "ghost"
                        compact: true
                        enabled: Bluetooth.busyAddress === ""
                        onClicked: devRow.modelData.connected
                            ? Bluetooth.disconnectDevice(devRow.modelData)
                            : Bluetooth.connectDevice(devRow.modelData)
                    }
                    GIconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "trash-2"
                        buttonSize: 24
                        iconSize: 12
                        iconColor: Theme.danger
                        onClicked: Bluetooth.forgetDevice(devRow.modelData)
                    }
                }
            }
        }

        StyledText {
            visible: Bluetooth.pairedDevices.length === 0
            text: "No paired devices"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }
    }

    // ---------------------------------------------------------- discovery
    Item {
        width: parent.width
        height: 26
        visible: Bluetooth.powered

        StyledText {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            role: Theme.typeOverline
            text: "NEARBY"
            color: Theme.fgMuted
        }
        GButton {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            icon: Bluetooth.discovering ? "x" : "refresh-cw"
            text: Bluetooth.discovering ? "Stop" : "Scan"
            kind: "ghost"
            compact: true
            onClicked: Bluetooth.setDiscovering(!Bluetooth.discovering)
        }
    }

    Column {
        width: parent.width
        spacing: 2
        visible: Bluetooth.powered

        Repeater {
            model: Bluetooth.discoveredDevices.slice(0, 6)

            Rectangle {
                id: foundRow

                required property var modelData

                width: parent.width
                height: 36
                radius: Theme.radiusSm
                color: foundMouse.containsMouse ? Theme.layerHover : "transparent"

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: Bluetooth.iconFor(foundRow.modelData)
                        size: 14
                        color: Theme.fgDim
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: foundRow.modelData.name
                        font.pixelSize: Theme.fontSm
                    }
                }

                StyledText {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: Bluetooth.busyAddress === foundRow.modelData.address
                        ? Bluetooth.statusText(foundRow.modelData) : "Tap to pair"
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgMuted
                    visible: foundMouse.containsMouse
                        || Bluetooth.busyAddress === foundRow.modelData.address
                }

                MouseArea {
                    id: foundMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Bluetooth.pairDevice(foundRow.modelData)
                }
            }
        }

        StyledText {
            visible: Bluetooth.discoveredDevices.length === 0
            text: Bluetooth.discovering ? "Searching…" : "Scan to find nearby devices"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }
    }

    Row {
        width: parent.width

        Item { width: parent.width - 90; height: 1 }

        GButton {
            text: "All settings"
            kind: "ghost"
            compact: true
            onClicked: root.requestSettings()
        }
    }
}
