// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Notification center: session history grouped by app, with DND and
// clear-all. Opened from the bell at the center of the top bar.

import QtQuick
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 400
    panelPadding: 12

    onExpandChanged: {
        Notifs.centerOpen = expand;
        if (expand)
            Notifs.markRead();
    }

    Column {
        width: parent.width
        spacing: 10

        Item {
            width: parent.width
            height: 30

            StyledText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Notifications"
                font.pixelSize: Theme.fontLg
                font.weight: Font.DemiBold
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                GIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "bell-off"
                    buttonSize: 26
                    iconSize: 13
                    active: Settings.data.doNotDisturb
                    onClicked: Settings.data.doNotDisturb = !Settings.data.doNotDisturb
                }
                GButton {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Clear all"
                    kind: "ghost"
                    compact: true
                    enabled: Notifs.history.length > 0
                    onClicked: Notifs.clearAll()
                }
            }
        }

        StyledText {
            visible: Settings.data.doNotDisturb
            text: "Do Not Disturb is on — new notifications arrive silently."
            width: parent.width
            font.pixelSize: Theme.fontXs
            color: Theme.fgMuted
            wrapMode: Text.WordWrap
        }

        Flickable {
            width: parent.width
            height: Math.min(420, listCol.implicitHeight)
            contentHeight: listCol.implicitHeight
            clip: true
            visible: Notifs.history.length > 0
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: listCol
                width: parent.width
                spacing: 10

                Repeater {
                    model: root.expand ? Notifs.groups : []

                    Column {
                        id: group

                        required property var modelData

                        width: listCol.width
                        spacing: 4

                        StyledText {
                            role: Theme.typeOverline
                            text: group.modelData.app.toUpperCase()
                            color: Theme.fgMuted
                        }

                        Repeater {
                            model: group.modelData.items

                            Rectangle {
                                id: item

                                required property var modelData

                                width: group.width
                                height: itemBody.implicitHeight + 20
                                radius: Theme.radiusSm
                                color: itemMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                                border.width: 1
                                border.color: Theme.border

                                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                                MouseArea {
                                    id: itemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        const actions = item.modelData.n.actions;
                                        if (actions !== undefined && actions.length > 0)
                                            actions[0].invoke();
                                        Notifs.dismiss(item.modelData.n);
                                    }
                                }

                                Column {
                                    id: itemBody
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    anchors.margins: 10
                                    spacing: 3

                                    Item {
                                        width: parent.width
                                        height: 16

                                        StyledText {
                                            anchors.left: parent.left
                                            anchors.right: itemMeta.left
                                            anchors.rightMargin: 8
                                            text: item.modelData.n.summary || "Notification"
                                            font.pixelSize: Theme.fontSm
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }

                                        Row {
                                            id: itemMeta
                                            anchors.right: parent.right
                                            spacing: 4

                                            StyledText {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: Notifs.timeAgo(item.modelData.time)
                                                font.pixelSize: Theme.fontXs
                                                color: Theme.fgMuted
                                            }
                                            GIconButton {
                                                anchors.verticalCenter: parent.verticalCenter
                                                visible: itemMouse.containsMouse
                                                icon: "x"
                                                buttonSize: 16
                                                iconSize: 10
                                                onClicked: Notifs.dismiss(item.modelData.n)
                                            }
                                        }
                                    }

                                    StyledText {
                                        width: parent.width
                                        visible: text !== ""
                                        text: item.modelData.n.body
                                        font.pixelSize: Theme.fontXs
                                        color: Theme.fgDim
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                        textFormat: Text.PlainText
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Empty state
        Column {
            width: parent.width
            visible: Notifs.history.length === 0
            spacing: 8
            topPadding: 18
            bottomPadding: 18

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                height: 40
                radius: 20
                color: Theme.surface
                border.width: 1
                border.color: Theme.border

                Icon {
                    anchors.centerIn: parent
                    name: "check"
                    size: 18
                    color: Theme.accent
                }
            }
            StyledText {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "You're all caught up"
                font.weight: Font.Medium
                color: Theme.fgDim
            }
        }
    }
}
