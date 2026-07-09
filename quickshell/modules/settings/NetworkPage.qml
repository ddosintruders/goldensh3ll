// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    // SSID whose row is expanded for password entry.
    property string expandedSsid: ""

    StyledText {
        visible: !Network.available
        text: "NetworkManager (nmcli) was not found. Install it to manage networks from here."
        color: Theme.fgMuted
        wrapMode: Text.WordWrap
        width: parent.width
    }

    SettingsGroup {
        visible: Network.available
        width: parent.width
        title: "Wi-Fi"

        SettingRow {
            label: "Wi-Fi"
            sublabel: Network.connected
                ? "Connected to " + Network.connectionName
                : (Network.wifiEnabled ? "Not connected" : "Off")

            GButton {
                icon: "refresh-cw"
                text: Network.scanning ? "Scanning…" : "Scan"
                compact: true
                enabled: Network.wifiEnabled && !Network.scanning
                onClicked: Network.rescan()
            }
            GSwitch {
                anchors.verticalCenter: parent.verticalCenter
                checked: Network.wifiEnabled
                onToggled: Network.toggleWifi()
            }
        }

        StyledText {
            visible: Network.lastError !== ""
            width: parent.width
            text: Network.lastError
            color: Theme.danger
            font.pixelSize: Theme.fontSm
            wrapMode: Text.WordWrap
        }

        Column {
            width: parent.width
            spacing: 2
            visible: Network.wifiEnabled

            Repeater {
                model: Network.networks

                Column {
                    id: netRow

                    required property var modelData

                    readonly property bool expanded: page.expandedSsid === modelData.ssid
                    readonly property bool connecting: Network.connectingSsid === modelData.ssid

                    width: parent.width
                    spacing: 0

                    Rectangle {
                        width: parent.width
                        height: 40
                        radius: Theme.radiusSm
                        color: netMouse.containsMouse || netRow.expanded ? Theme.surfaceHover : "transparent"

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: netRow.modelData.strength >= 66 ? "wifi"
                                    : netRow.modelData.strength >= 33 ? "wifi-high" : "wifi-low"
                                size: 15
                                color: netRow.modelData.inUse ? Theme.accent : Theme.fgDim
                            }
                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                text: netRow.modelData.ssid
                                font.weight: netRow.modelData.inUse ? Font.DemiBold : Font.Normal
                            }
                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: netRow.modelData.secure
                                name: "lock"
                                size: 11
                                color: Theme.fgMuted
                            }
                        }

                        Row {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: netRow.connecting
                                text: "Connecting…"
                                font.pixelSize: Theme.fontSm
                                color: Theme.fgDim
                            }
                            GButton {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: netRow.modelData.inUse
                                text: "Disconnect"
                                kind: "ghost"
                                compact: true
                                onClicked: Network.disconnectWifi()
                            }
                            GIconButton {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: Network.isSaved(netRow.modelData.ssid)
                                icon: "trash-2"
                                buttonSize: 24
                                iconSize: 12
                                iconColor: Theme.danger
                                onClicked: Network.forget(netRow.modelData.ssid)
                            }
                        }

                        MouseArea {
                            id: netMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (netRow.modelData.inUse)
                                    return;
                                page.expandedSsid = netRow.expanded ? "" : netRow.modelData.ssid;
                            }
                        }
                    }

                    Row {
                        visible: netRow.expanded && !netRow.modelData.inUse
                        width: parent.width - 20
                        x: 10
                        spacing: 8
                        topPadding: 6
                        bottomPadding: 8

                        GTextField {
                            id: pwField
                            width: parent.width - 110
                            echoMode: TextInput.Password
                            leadingIcon: "lock"
                            placeholder: netRow.modelData.secure
                                ? "Password (empty if saved)" : "Open network"
                            onAccepted: {
                                Network.connectTo(netRow.modelData.ssid, text);
                                page.expandedSsid = "";
                            }
                        }
                        GButton {
                            anchors.verticalCenter: pwField.verticalCenter
                            text: "Connect"
                            kind: "filled"
                            enabled: !netRow.connecting
                            onClicked: {
                                Network.connectTo(netRow.modelData.ssid, pwField.text);
                                page.expandedSsid = "";
                            }
                        }
                    }
                }
            }

            StyledText {
                visible: Network.networks.length === 0
                text: Network.scanning ? "Scanning…" : "No networks found"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }
    }
}
