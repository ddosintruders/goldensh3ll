// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Control center with Windows-11-style split tiles: the left side toggles,
// the chevron slides to a dedicated Wi-Fi or Bluetooth panel.

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 380
    panelPadding: 14

    onExpandChanged: {
        if (expand)
            pager.page = 0;
    }

    // Screenshots must run after this overlay unmaps, or it gets captured.
    property string pendingShotKind: ""
    property var pendingGeom: [0, 0, 0, 0]

    function requestShot(kind, x, y, w, h) {
        pendingShotKind = kind;
        pendingGeom = [x, y, w, h];
        close();
        shotDelay.restart();
    }

    Timer {
        id: shotDelay
        interval: 450
        onTriggered: {
            if (root.pendingShotKind === "full")
                Capture.screenshotFull();
            else if (root.pendingShotKind === "region")
                Capture.screenshotRegion();
            else if (root.pendingShotKind === "area")
                Capture.screenshotArea(root.pendingGeom[0], root.pendingGeom[1],
                                       root.pendingGeom[2], root.pendingGeom[3]);
            root.pendingShotKind = "";
        }
    }

    component ToggleTile: Rectangle {
        id: tile

        property string icon
        property string label
        property string sub: ""
        property bool active: false
        property bool expandable: false

        signal clicked()
        signal expandClicked()

        width: (parent.width - 8) / 2
        height: 56
        radius: Theme.radiusMd
        color: active ? Theme.accent
             : tileMouse.containsMouse ? Theme.surfaceHover : Theme.surface
        border.width: active ? 0 : 1
        border.color: Theme.border

        Behavior on color { ColorAnimation { duration: Theme.animFast } }

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.right: parent.right
            anchors.rightMargin: tile.expandable ? 38 : 8
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: tile.icon
                size: 17
                color: tile.active ? Theme.onAccent : Theme.fgDim
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 27
                spacing: 1

                StyledText {
                    width: parent.width
                    text: tile.label
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.DemiBold
                    color: tile.active ? Theme.onAccent : Theme.fg
                    elide: Text.ElideRight
                }
                StyledText {
                    width: parent.width
                    visible: tile.sub !== ""
                    text: tile.sub
                    font.pixelSize: Theme.fontXs
                    color: tile.active ? Qt.rgba(Theme.onAccent.r, Theme.onAccent.g, Theme.onAccent.b, 0.75)
                                       : Theme.fgMuted
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            anchors.rightMargin: tile.expandable ? 32 : 0
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.clicked()
        }

        // Chevron zone opening the detail panel.
        Item {
            visible: tile.expandable
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 32

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: parent.height - 20
                color: tile.active
                    ? Qt.rgba(Theme.onAccent.r, Theme.onAccent.g, Theme.onAccent.b, 0.25)
                    : Theme.border
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: Theme.radiusSm
                color: chevMouse.pressed ? Theme.layerPressed
                     : chevMouse.containsMouse ? Theme.layerHover : "transparent"
            }

            Icon {
                anchors.centerIn: parent
                name: "chevron-right"
                size: 13
                color: tile.active ? Theme.onAccent : Theme.fgDim
            }

            MouseArea {
                id: chevMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: tile.expandClicked()
            }
        }
    }

    Item {
        id: pager

        property int page: 0

        width: parent.width
        implicitHeight: page === 0 ? mainCol.implicitHeight
                      : page === 1 ? wifiPanel.implicitHeight
                      : page === 2 ? btPanel.implicitHeight
                      : capturePanel.implicitHeight
        height: implicitHeight
        clip: true

        // ------------------------------------------------------- main page
        Column {
            id: mainCol
            width: pager.width
            x: -pager.page * (pager.width + 24)
            spacing: 12

            Behavior on x { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }

            Flow {
                width: parent.width
                spacing: 8

                ToggleTile {
                    visible: Network.available
                    icon: Network.wifiEnabled ? "wifi" : "wifi-off"
                    label: "Wi-Fi"
                    sub: !Network.wifiEnabled ? "Off"
                       : Network.connected && Network.type === "wifi" ? Network.connectionName
                       : "Not connected"
                    active: Network.wifiEnabled
                    expandable: true
                    onClicked: Network.toggleWifi()
                    onExpandClicked: pager.page = 1
                }
                ToggleTile {
                    visible: Bluetooth.available
                    icon: Bluetooth.powered ? "bluetooth" : "bluetooth-off"
                    label: "Bluetooth"
                    sub: !Bluetooth.powered ? "Off"
                       : Bluetooth.connectedCount > 0 ? Bluetooth.connectedCount + " connected"
                       : "On"
                    active: Bluetooth.powered
                    expandable: true
                    onClicked: Bluetooth.toggle()
                    onExpandClicked: pager.page = 2
                }
                ToggleTile {
                    icon: Settings.data.doNotDisturb ? "bell-off" : "bell"
                    label: "Do Not Disturb"
                    sub: Settings.data.doNotDisturb ? "On" : "Off"
                    active: Settings.data.doNotDisturb
                    onClicked: Settings.data.doNotDisturb = !Settings.data.doNotDisturb
                }
                ToggleTile {
                    icon: Settings.data.darkMode ? "moon" : "sun"
                    label: "Dark Mode"
                    sub: Settings.data.darkMode ? "On" : "Off"
                    active: Settings.data.darkMode
                    onClicked: Settings.data.darkMode = !Settings.data.darkMode
                }
                ToggleTile {
                    icon: "camera"
                    label: "Capture"
                    sub: Capture.recording
                        ? "Recording " + Capture.recordTimeText
                        : "Screenshot & record"
                    active: Capture.recording
                    expandable: true
                    onClicked: pager.page = 3
                    onExpandClicked: pager.page = 3
                }
            }

            Column {
                width: parent.width
                spacing: 8

                Row {
                    width: parent.width
                    spacing: 10

                    GIconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: Audio.iconName()
                        buttonSize: 26
                        iconSize: 14
                        onClicked: Audio.toggleMute()
                    }
                    GSlider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 78
                        value: Audio.muted ? 0 : Audio.volume
                        onMoved: v => Audio.setVolume(v)
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 32
                        horizontalAlignment: Text.AlignRight
                        text: Math.round((Audio.muted ? 0 : Audio.volume) * 100) + "%"
                        color: Theme.fgDim
                        font.pixelSize: Theme.fontSm
                    }
                }

                Row {
                    width: parent.width
                    spacing: 10
                    visible: Brightness.available

                    GIconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "sun"
                        buttonSize: 26
                        iconSize: 14
                        onClicked: {}
                    }
                    GSlider {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 78
                        value: Brightness.value
                        onMoved: v => Brightness.set(v)
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 32
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(Brightness.value * 100) + "%"
                        color: Theme.fgDim
                        font.pixelSize: Theme.fontSm
                    }
                }
            }

            Row {
                visible: Battery.present
                spacing: 8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: Battery.iconName()
                    size: 14
                    color: Theme.fgDim
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Battery.percentInt + "%" + (Battery.timeText !== "" ? "  ·  " + Battery.timeText : "")
                    color: Theme.fgDim
                    font.pixelSize: Theme.fontSm
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.border }

            Row {
                width: parent.width

                GIconButton {
                    icon: "settings"
                    onClicked: { root.close(); GlobalState.openSettings(""); }
                }

                Item { width: parent.width - 30 * 5 - 8 * 4; height: 1 }

                Row {
                    spacing: 8

                    GIconButton {
                        icon: "lock"
                        onClicked: { root.close(); Session.lock(); }
                    }
                    GIconButton {
                        icon: "log-out"
                        onClicked: Session.logout()
                    }
                    GIconButton {
                        icon: "rotate-ccw"
                        onClicked: Session.reboot()
                    }
                    GIconButton {
                        icon: "power"
                        iconColor: Theme.danger
                        onClicked: Session.poweroff()
                    }
                }
            }
        }

        // ------------------------------------------------------ wifi panel
        WifiPanel {
            id: wifiPanel
            width: pager.width
            x: (1 - pager.page) * (pager.width + 24)
            onBack: pager.page = 0
            onRequestSettings: { root.close(); GlobalState.openSettings("network"); }

            Behavior on x { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
        }

        // ------------------------------------------------- bluetooth panel
        BtPanel {
            id: btPanel
            width: pager.width
            x: (2 - pager.page) * (pager.width + 24)
            onBack: pager.page = 0
            onRequestSettings: { root.close(); GlobalState.openSettings("bluetooth"); }

            Behavior on x { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
        }

        // --------------------------------------------------- capture panel
        CapturePanel {
            id: capturePanel
            width: pager.width
            x: (3 - pager.page) * (pager.width + 24)
            onBack: pager.page = 0
            onShotRequested: (kind, x, y, w, h) => root.requestShot(kind, x, y, w, h)

            Behavior on x { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
        }
    }
}
