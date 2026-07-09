// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// macOS-inspired top bar: logo menu + workspaces on the left,
// media / control center / volume / battery on the right.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.components
import qs.services

Scope {
    id: root

    required property var modelData

    function closePopups() {
        logoMenu.close();
        controlCenter.close();
        mediaPopup.close();
        volumeFlyout.close();
        notifCenter.close();
    }

    PanelWindow {
        id: bar

        screen: root.modelData
        anchors { top: true; left: true; right: true }
        implicitHeight: Theme.topBarHeight
        margins { top: Theme.barMargin; left: Theme.barMargin; right: Theme.barMargin }
        exclusiveZone: Theme.topBarHeight + Theme.barMargin * 2
        color: "transparent"
        WlrLayershell.namespace: "goldensh3ll-topbar"

        Rectangle {
            anchors.fill: parent
            color: Theme.barBg
            radius: Theme.barFloating ? Theme.radiusMd : 0
            border.width: Theme.barFloating ? 1 : 0
            border.color: Theme.popupBorder

            Rectangle {
                visible: !Theme.barFloating
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.border
            }
        }

        // Right-click on empty bar background → customize bars.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: event => topBarMenu.openAt(event.x)
        }

        // ------------------------------------------------------------- left
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            BarPill {
                id: logoPill
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: Theme.logo
                    width: 16
                    height: 16
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "GoldenSh3ll"
                    font.weight: Font.DemiBold
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "v" + Theme.version.split(".").slice(0, 2).join(".")
                    color: Theme.fgMuted
                    font.pixelSize: Theme.fontSm
                }

                onClicked: {
                    const wasOpen = logoMenu.expand;
                    root.closePopups();
                    if (!wasOpen)
                        logoMenu.openAt(logoPill.mapToItem(null, logoPill.width / 2, 0).x);
                }
            }

            // ------------------------------------------------- workspaces
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                readonly property int wsCount: {
                    let max = 5;
                    for (const w of Hyprland.workspaces.values)
                        if (w.id > max)
                            max = w.id;
                    return max;
                }
                readonly property int focusedId:
                    Hyprland.focusedWorkspace !== null ? Hyprland.focusedWorkspace.id : 1

                Repeater {
                    model: parent.wsCount

                    Rectangle {
                        id: wsPill

                        required property int index
                        readonly property int wsId: index + 1
                        readonly property bool focused: wsId === parent.focusedId
                        readonly property bool occupied:
                            Hyprland.workspaces.values.some(w => w.id === wsId)

                        anchors.verticalCenter: parent.verticalCenter
                        width: focused ? 30 : 22
                        height: 20
                        radius: height / 2
                        color: focused ? Theme.accent
                             : wsMouse.containsMouse ? Theme.surfaceHover
                             : "transparent"

                        Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        StyledText {
                            anchors.centerIn: parent
                            text: wsPill.wsId
                            font.pixelSize: Theme.fontSm
                            font.weight: wsPill.focused ? Font.DemiBold : Font.Medium
                            color: wsPill.focused ? Theme.onAccent
                                 : wsPill.occupied ? Theme.fg : Theme.fgMuted
                        }

                        MouseArea {
                            id: wsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch("workspace " + wsPill.wsId)
                            onWheel: event => Hyprland.dispatch(
                                event.angleDelta.y > 0 ? "workspace e-1" : "workspace e+1")
                        }
                    }
                }
            }
        }

        // ----------------------------------------------------------- center
        // Notification bell with unread badge.
        BarPill {
            id: bellPill
            anchors.centerIn: parent
            hpad: 8

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: 18
                height: 16

                Icon {
                    anchors.centerIn: parent
                    name: Settings.data.doNotDisturb ? "bell-off" : "bell"
                    size: 14
                    color: notifCenter.expand ? Theme.accent : Theme.fgDim
                }

                Rectangle {
                    visible: Notifs.unreadCount > 0
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: -4
                    anchors.rightMargin: -5
                    width: Math.max(13, badgeText.implicitWidth + 7)
                    height: 13
                    radius: height / 2
                    color: Theme.accent
                    border.width: 1
                    border.color: Theme.barBg

                    StyledText {
                        id: badgeText
                        anchors.centerIn: parent
                        text: Notifs.unreadCount > 9 ? "9+" : Notifs.unreadCount
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: Theme.onAccent
                    }
                }
            }

            onClicked: {
                const wasOpen = notifCenter.expand;
                root.closePopups();
                if (!wasOpen)
                    notifCenter.openAt(bellPill.mapToItem(null, bellPill.width / 2, 0).x);
            }
        }

        // ------------------------------------------------------------ right
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            // Recording indicator: pulsing red dot + elapsed; click stops.
            BarPill {
                visible: Capture.recording
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.danger

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: Capture.recording && !Theme.reduceMotion
                        NumberAnimation { to: 0.3; duration: 600 }
                        NumberAnimation { to: 1; duration: 600 }
                    }
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Capture.recordTimeText
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.Medium
                    color: Theme.danger
                }

                onClicked: Capture.toggleRecording()
            }

            // Audio spectrum (cava), sits just before the media label.
            Row {
                visible: Visualizer.shouldRun && Visualizer.values.length > 0
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Repeater {
                    model: Visualizer.bars

                    Item {
                        id: vizBar

                        required property int index

                        readonly property real level:
                            index < Visualizer.values.length ? Visualizer.values[index] : 0
                        readonly property bool dots: Settings.data.visualizerShape === "dots"

                        width: 3
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: vizBar.dots
                                ? (vizBar.height - 3) * (1 - vizBar.level)
                                : (vizBar.height - height) / 2
                            width: 3
                            height: vizBar.dots ? 3 : 2 + vizBar.level * 15
                            radius: Settings.data.visualizerShape === "square" ? 0 : 1.5
                            color: Visualizer.barColor
                        }
                    }
                }
            }

            BarPill {
                id: mediaPill
                anchors.verticalCenter: parent.verticalCenter
                visible: Settings.data.showMediaInBar && Media.hasPlayer

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: Media.playing ? "music-2" : "music"
                    size: 13
                    color: Media.playing ? Theme.accent : Theme.fgDim
                }
                ScrollingText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Media.barLabel
                    color: Theme.fgDim
                    pixelSize: Theme.fontSm
                    width: Math.min(implicitWidth, 280)
                }

                onClicked: event => {
                    if (event.button === Qt.MiddleButton) {
                        Media.toggle();
                        return;
                    }
                    const wasOpen = mediaPopup.expand;
                    root.closePopups();
                    if (!wasOpen)
                        mediaPopup.openAt(mediaPill.mapToItem(null, mediaPill.width / 2, 0).x);
                }
                onScrolled: delta => delta > 0 ? Media.previous() : Media.next()
            }

            BarPill {
                id: ccPill
                anchors.verticalCenter: parent.verticalCenter

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "sliders-horizontal"
                    size: 14
                    color: controlCenter.expand ? Theme.accent : Theme.fgDim
                }

                onClicked: {
                    const wasOpen = controlCenter.expand;
                    root.closePopups();
                    if (!wasOpen)
                        controlCenter.openAt(ccPill.mapToItem(null, ccPill.width / 2, 0).x);
                }
            }

            BarPill {
                id: volumePill
                anchors.verticalCenter: parent.verticalCenter

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: Audio.iconName()
                    size: 14
                    color: Audio.muted ? Theme.fgMuted : Theme.fgDim
                }

                onClicked: event => {
                    if (event.button === Qt.MiddleButton) {
                        Audio.toggleMute();
                        return;
                    }
                    const wasOpen = volumeFlyout.expand;
                    root.closePopups();
                    if (!wasOpen)
                        volumeFlyout.openAt(volumePill.mapToItem(null, volumePill.width / 2, 0).x);
                }
                onScrolled: delta => Audio.adjust(delta)
            }

            BarPill {
                id: batteryPill
                anchors.verticalCenter: parent.verticalCenter
                visible: Settings.data.showBattery && Battery.present

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: Battery.iconName()
                    size: 14
                    color: Battery.critical ? Theme.danger
                         : Battery.low ? Theme.warning
                         : Battery.charging ? Theme.success : Theme.fgDim
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Battery.percentInt + "%"
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.Medium
                }

                onClicked: {
                    const wasOpen = controlCenter.expand;
                    root.closePopups();
                    if (!wasOpen)
                        controlCenter.openAt(batteryPill.mapToItem(null, batteryPill.width / 2, 0).x);
                }
            }
        }
    }

    LogoMenu { id: logoMenu; screen: root.modelData }
    ControlCenter { id: controlCenter; screen: root.modelData }
    MediaPopup { id: mediaPopup; screen: root.modelData }
    VolumeFlyout { id: volumeFlyout; screen: root.modelData }
    NotificationCenter { id: notifCenter; screen: root.modelData }

    ContextMenu {
        id: topBarMenu
        screen: root.modelData

        ListButton {
            width: parent.width
            icon: "panel-top"
            label: "Customize bars…"
            onClicked: {
                topBarMenu.close();
                GlobalState.openSettings("shell");
            }
        }
    }
}
