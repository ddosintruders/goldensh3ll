// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Notification toast stack, top-right under the top bar.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import qs.config
import qs.components
import qs.services

Scope {
    id: root

    required property var modelData

    readonly property bool isFocusedScreen:
        Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

    PanelWindow {
        screen: root.modelData
        visible: Notifs.popups.length > 0 && root.isFocusedScreen

        anchors { top: true; right: true }
        // ExclusionMode.Ignore skips the bar's reserved zone, so offset manually.
        margins { top: Theme.topExclusion + 8; right: 8 }
        implicitWidth: 380
        implicitHeight: Math.max(1, stack.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "goldensh3ll-notifications"

        Column {
            id: stack
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            Repeater {
                model: Notifs.popups

                Rectangle {
                    id: toast

                    required property var modelData

                    readonly property bool critical:
                        modelData.urgency === NotificationUrgency.Critical

                    width: stack.width
                    height: body.implicitHeight + 24
                    radius: Theme.radiusMd
                    color: Theme.popupBg
                    border.width: 1
                    border.color: toast.critical ? Theme.danger : Theme.popupBorder

                    // Slide in from the right on arrival.
                    opacity: 0
                    x: 24
                    Component.onCompleted: appearAnim.start()

                    ParallelAnimation {
                        id: appearAnim
                        NumberAnimation {
                            target: toast
                            property: "opacity"
                            to: 1
                            duration: Theme.durMed
                        }
                        NumberAnimation {
                            target: toast
                            property: "x"
                            to: 0
                            duration: Theme.durMed
                            easing.type: Theme.easeStandard
                        }
                    }

                    Timer {
                        interval: 6000
                        running: !toast.critical && !toastMouse.containsMouse
                        onTriggered: Notifs.expire(toast.modelData)
                    }

                    MouseArea {
                        id: toastMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            const actions = toast.modelData.actions;
                            if (actions !== undefined && actions.length > 0)
                                actions[0].invoke();
                            Notifs.dismiss(toast.modelData);
                        }
                    }

                    Column {
                        id: body
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 6

                        Row {
                            width: parent.width
                            spacing: 8

                            Icon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "bell"
                                size: 12
                                color: toast.critical ? Theme.danger : Theme.accent
                            }
                            StyledText {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 74
                                text: toast.modelData.appName || "Notification"
                                font.pixelSize: Theme.fontXs
                                font.weight: Font.DemiBold
                                color: Theme.fgMuted
                                elide: Text.ElideRight
                            }
                            // Set aside: move to the notification center
                            // without dismissing it for the sender.
                            GIconButton {
                                icon: "chevron-right"
                                buttonSize: 22
                                iconSize: 11
                                onClicked: Notifs.expire(toast.modelData)
                            }
                            GIconButton {
                                icon: "x"
                                buttonSize: 22
                                iconSize: 11
                                onClicked: Notifs.dismiss(toast.modelData)
                            }
                        }

                        StyledText {
                            width: parent.width
                            visible: text !== ""
                            text: toast.modelData.summary
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        StyledText {
                            width: parent.width
                            visible: text !== ""
                            text: toast.modelData.body
                            font.pixelSize: Theme.fontSm
                            color: Theme.fgDim
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }

                        Row {
                            visible: toast.modelData.actions !== undefined
                                && toast.modelData.actions.length > 0
                            spacing: 6

                            Repeater {
                                model: toast.modelData.actions

                                GButton {
                                    required property var modelData
                                    text: modelData.text || "Open"
                                    compact: true
                                    onClicked: {
                                        modelData.invoke();
                                        Notifs.dismiss(toast.modelData);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
