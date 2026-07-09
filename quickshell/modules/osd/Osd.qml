// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Click-through on-screen display for volume and brightness changes.
// Only shown on the focused monitor; ignores the initial service sync.

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

    readonly property bool isFocusedScreen:
        Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

    property bool ready: false
    property bool shown: false
    property string kind: "volume"

    readonly property real level: kind === "volume"
        ? (Audio.muted ? 0 : Audio.volume)
        : Brightness.value
    readonly property string icon: kind === "volume" ? Audio.iconName() : "sun"

    function show(k) {
        if (!ready) return;
        kind = k;
        shown = true;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1400
        onTriggered: root.shown = false
    }

    // Suppress the OSD while services settle after startup / reload.
    Timer {
        interval: 3000
        running: true
        onTriggered: root.ready = true
    }

    Connections {
        target: Audio
        function onVolumeChanged() { root.show("volume"); }
        function onMutedChanged() { root.show("volume"); }
    }
    Connections {
        target: Brightness
        function onUserChanged() { root.show("brightness"); }
    }

    PanelWindow {
        screen: root.modelData
        visible: root.shown && root.isFocusedScreen

        anchors.bottom: true
        margins.bottom: Theme.taskbarHeight + 22
        implicitWidth: 260
        implicitHeight: 46
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "goldensh3ll-osd"
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.popupBg
            border.width: 1
            border.color: Theme.popupBorder

            opacity: root.shown ? 1 : 0
            scale: root.shown ? 1 : 0.92
            Behavior on opacity { NumberAnimation { duration: Theme.durFast } }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.durMed
                    easing.type: Theme.easeEmphasized
                    easing.overshoot: 1.1
                }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: root.icon
                    size: 16
                    color: Theme.fg
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 80
                    height: 5
                    radius: height / 2
                    color: Theme.surfaceActive

                    Rectangle {
                        width: parent.width * root.level
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width { NumberAnimation { duration: 90 } }
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 34
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(root.level * 100) + "%"
                    font.pixelSize: Theme.fontSm
                    color: Theme.fgDim
                }
            }
        }
    }
}
