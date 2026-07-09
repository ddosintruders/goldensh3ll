// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Removable drives popup: mount, unmount, or open each detected drive.

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 330
    panelPadding: 12
    fromTop: false

    Column {
        width: parent.width
        spacing: 10

        StyledText {
            role: Theme.typeOverline
            text: "REMOVABLE DRIVES"
            color: Theme.fgMuted
        }

        Column {
            width: parent.width
            spacing: 4

            Repeater {
                model: Drives.drives

                Item {
                    id: driveRow

                    required property var modelData

                    readonly property bool mounted: modelData.mountpoint !== ""
                    readonly property bool busy: Drives.busyPath === modelData.path

                    width: parent.width
                    height: 46

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            height: 32
                            radius: Theme.radiusSm
                            color: driveRow.mounted ? Theme.accent : Theme.surfaceHover

                            Icon {
                                anchors.centerIn: parent
                                name: "usb"
                                size: 15
                                color: driveRow.mounted ? Theme.onAccent : Theme.fgDim
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            StyledText {
                                text: driveRow.modelData.label
                                font.weight: Font.Medium
                                width: 130
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: driveRow.busy ? "Working…"
                                    : driveRow.modelData.size
                                      + (driveRow.mounted ? " · " + driveRow.modelData.mountpoint : " · Not mounted")
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgMuted
                                width: 130
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        GButton {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: driveRow.mounted
                            text: "Open"
                            kind: "ghost"
                            compact: true
                            onClicked: {
                                Quickshell.execDetached(["xdg-open", driveRow.modelData.mountpoint]);
                                root.close();
                            }
                        }
                        GButton {
                            anchors.verticalCenter: parent.verticalCenter
                            text: driveRow.mounted ? "Unmount" : "Mount"
                            kind: driveRow.mounted ? "tonal" : "filled"
                            compact: true
                            enabled: Drives.busyPath === ""
                            onClicked: driveRow.mounted
                                ? Drives.unmount(driveRow.modelData.path)
                                : Drives.mount(driveRow.modelData.path)
                        }
                    }
                }
            }

            StyledText {
                visible: Drives.drives.length === 0
                text: "No removable drives"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }

        StyledText {
            visible: Drives.lastError !== ""
            width: parent.width
            text: Drives.lastError
            color: Theme.danger
            font.pixelSize: Theme.fontXs
            wrapMode: Text.WordWrap
        }
    }
}
