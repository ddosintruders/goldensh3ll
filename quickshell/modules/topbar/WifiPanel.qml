// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Compact Wi-Fi connection panel inside the control center.

import QtQuick
import qs.config
import qs.components
import qs.services

Column {
    id: root

    signal back()
    signal requestSettings()

    property string expandedSsid: ""

    readonly property var visibleNetworks: Network.networks.slice(0, 8)

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
            onClicked: { root.expandedSsid = ""; root.back(); }
        }
        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: 34
            anchors.verticalCenter: parent.verticalCenter
            text: "Wi-Fi"
            font.pixelSize: Theme.fontLg
            font.weight: Font.DemiBold
        }
        GSwitch {
            anchors.right: parent.right
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
            model: root.visibleNetworks

            Column {
                id: netRow

                required property var modelData

                readonly property bool expanded: root.expandedSsid === modelData.ssid
                readonly property bool connecting: Network.connectingSsid === modelData.ssid

                width: parent.width
                spacing: 0

                Rectangle {
                    width: parent.width
                    height: 36
                    radius: Theme.radiusSm
                    color: netMouse.containsMouse || netRow.expanded ? Theme.layerHover : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: netRow.modelData.strength >= 66 ? "wifi"
                                : netRow.modelData.strength >= 33 ? "wifi-high" : "wifi-low"
                            size: 14
                            color: netRow.modelData.inUse ? Theme.accent : Theme.fgDim
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: netRow.modelData.ssid
                            font.pixelSize: Theme.fontSm
                            font.weight: netRow.modelData.inUse ? Font.DemiBold : Font.Normal
                        }
                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: netRow.modelData.secure
                            name: "lock"
                            size: 10
                            color: Theme.fgMuted
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: netRow.connecting
                            text: "Connecting…"
                            font.pixelSize: Theme.fontXs
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
                            visible: !netRow.modelData.inUse
                                && Network.isSaved(netRow.modelData.ssid)
                                && netMouse.containsMouse
                            icon: "trash-2"
                            buttonSize: 22
                            iconSize: 11
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
                            if (!netRow.modelData.secure) {
                                Network.connectTo(netRow.modelData.ssid, "");
                                return;
                            }
                            root.expandedSsid = netRow.expanded ? "" : netRow.modelData.ssid;
                        }
                    }
                }

                Row {
                    visible: netRow.expanded && !netRow.modelData.inUse
                    width: parent.width - 16
                    x: 8
                    spacing: 6
                    topPadding: 4
                    bottomPadding: 6

                    GTextField {
                        id: pwField
                        width: parent.width - 86
                        echoMode: TextInput.Password
                        leadingIcon: "lock"
                        placeholder: "Password (empty if saved)"
                        onAccepted: {
                            Network.connectTo(netRow.modelData.ssid, text);
                            root.expandedSsid = "";
                        }
                    }
                    GButton {
                        anchors.verticalCenter: pwField.verticalCenter
                        text: "Join"
                        kind: "filled"
                        compact: true
                        enabled: !netRow.connecting
                        onClicked: {
                            Network.connectTo(netRow.modelData.ssid, pwField.text);
                            root.expandedSsid = "";
                        }
                    }
                }
            }
        }

        StyledText {
            visible: root.visibleNetworks.length === 0
            text: Network.scanning ? "Scanning…" : "No networks found"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }
    }

    StyledText {
        visible: !Network.wifiEnabled
        text: "Wi-Fi is off"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
    }

    Row {
        width: parent.width

        GButton {
            icon: "refresh-cw"
            text: Network.scanning ? "Scanning…" : "Scan"
            kind: "ghost"
            compact: true
            enabled: Network.wifiEnabled && !Network.scanning
            onClicked: Network.rescan()
        }

        Item { width: parent.width - 200; height: 1 }

        GButton {
            text: "All settings"
            kind: "ghost"
            compact: true
            onClicked: root.requestSettings()
        }
    }
}
