// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Per-screen desktop layer (above wallpaper, below windows): app
// shortcuts arranged Windows-style in columns, plus draggable widgets
// (clock, weather). Widgets move in edit mode (Settings → Desktop).

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.components
import qs.services

Scope {
    id: root

    required property var modelData

    function saveWidgetPos(index, x, y) {
        const list = [...Settings.data.desktopWidgets];
        if (index < 0 || index >= list.length)
            return;
        const type = list[index].split("::")[0];
        list[index] = type + "::" + Math.round(x) + "::" + Math.round(y);
        Settings.data.desktopWidgets = list;
    }

    function removeWidget(index) {
        Settings.data.desktopWidgets =
            Settings.data.desktopWidgets.filter((w, i) => i !== index);
    }

    PanelWindow {
        id: win

        screen: root.modelData
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "goldensh3ll-desktop"

        // Right-click on the desktop → configuration shortcuts. Declared
        // first so shortcut/widget interaction stacks above it.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: event => {
                deskMenu.x = Math.min(event.x, win.width - deskMenu.width - 8);
                deskMenu.y = Math.min(event.y, win.height - deskMenu.height - 8);
                deskMenu.visible = true;
            }
        }

        // ------------------------------------------------------- shortcuts
        Flow {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: Theme.topExclusion + 16
            anchors.leftMargin: 16
            height: parent.height - Theme.topExclusion - Theme.taskbarHeight - 48
            flow: Flow.TopToBottom
            spacing: 8

            Repeater {
                model: Settings.data.desktopShortcuts

                Item {
                    id: shortcut

                    required property string modelData

                    readonly property var entry: AppSearch.entryFor(modelData)

                    width: 80
                    height: 88

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: shortcutMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"
                        border.width: shortcutMouse.containsMouse ? 1 : 0
                        border.color: Qt.rgba(1, 1, 1, 0.18)

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 6

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 38
                            height: 38
                            sourceSize: Qt.size(76, 76)
                            source: AppSearch.iconFor(shortcut.entry, shortcut.modelData)
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: labelText.implicitWidth + 10
                            height: 16
                            radius: 8
                            color: Qt.rgba(0, 0, 0, 0.42)

                            StyledText {
                                id: labelText
                                anchors.centerIn: parent
                                text: shortcut.entry !== null ? shortcut.entry.name : shortcut.modelData
                                font.pixelSize: Theme.fontXs
                                color: "#ffffff"
                                width: Math.min(implicitWidth, 66)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        id: shortcutMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onDoubleClicked: AppSearch.launch(shortcut.entry)
                    }

                    // Remove control in edit mode.
                    GIconButton {
                        visible: GlobalState.desktopEditMode
                        anchors.top: parent.top
                        anchors.right: parent.right
                        icon: "x"
                        buttonSize: 20
                        iconSize: 10
                        iconColor: Theme.danger
                        onClicked: Settings.data.desktopShortcuts =
                            Settings.data.desktopShortcuts.filter(s => s !== shortcut.modelData)
                    }
                }
            }
        }

        // --------------------------------------------------------- widgets
        Repeater {
            model: Settings.data.desktopWidgets

            Item {
                id: widgetSlot

                required property string modelData
                required property int index

                readonly property var parts: modelData.split("::")
                readonly property string type: parts[0]

                x: parts.length > 2 ? (parseInt(parts[1]) || 140) : 140
                y: parts.length > 2 ? (parseInt(parts[2]) || 160) : 160
                width: content.item !== null ? content.item.width : 200
                height: content.item !== null ? content.item.height : 100

                Loader {
                    id: content
                    sourceComponent: widgetSlot.type === "weather" ? weatherComp : clockComp
                }

                // Edit-mode chrome: accent outline + drag + remove.
                Rectangle {
                    visible: GlobalState.desktopEditMode
                    anchors.fill: parent
                    anchors.margins: -3
                    radius: Theme.radiusLg + 3
                    color: "transparent"
                    border.width: 2
                    border.color: Theme.accent
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: GlobalState.desktopEditMode
                    cursorShape: GlobalState.desktopEditMode ? Qt.SizeAllCursor : Qt.ArrowCursor
                    drag.target: widgetSlot
                    onReleased: root.saveWidgetPos(widgetSlot.index, widgetSlot.x, widgetSlot.y)
                }

                GIconButton {
                    visible: GlobalState.desktopEditMode
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6
                    icon: "x"
                    buttonSize: 22
                    iconSize: 11
                    iconColor: Theme.danger
                    onClicked: root.removeWidget(widgetSlot.index)
                }
            }
        }

        Component {
            id: clockComp
            ClockWidget {}
        }
        Component {
            id: weatherComp
            WeatherWidget {}
        }

        // Dismiss layer + the desktop context menu itself.
        MouseArea {
            anchors.fill: parent
            visible: deskMenu.visible
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            z: 50
            onPressed: deskMenu.visible = false
        }

        Rectangle {
            id: deskMenu
            visible: false
            z: 51
            width: 210
            height: deskMenuCol.implicitHeight + 12
            radius: Theme.radiusSm
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            Column {
                id: deskMenuCol
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                ListButton {
                    width: parent.width
                    icon: "layout-grid"
                    label: "Desktop shortcuts…"
                    onClicked: {
                        deskMenu.visible = false;
                        GlobalState.openSettings("desktop");
                    }
                }
                ListButton {
                    width: parent.width
                    icon: "image"
                    label: "Change wallpaper…"
                    onClicked: {
                        deskMenu.visible = false;
                        GlobalState.openSettings("wallpaper");
                    }
                }
            }
        }
    }
}
