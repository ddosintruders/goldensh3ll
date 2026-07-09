// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The GoldenSh3ll Start menu. Three zones: profile + session actions on
// the left, keyboard-driven app search in the center, pinned apps on the
// right. Opens from the taskbar logo, Super, or Super+Space.

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    fromTop: false
    panelWidth: 760
    panelPadding: 14
    exclusiveKeyboard: true

    readonly property var results: expand ? AppSearch.query(searchField.text) : []
    // Start pins are independent of the taskbar pins.
    readonly property var pinned: expand
        ? Settings.data.startPinnedApps.map(id => AppSearch.entryFor(id)).filter(e => e !== null)
        : []

    // Right-click context menu state (coordinates in menuContent space).
    property var ctxEntry: null
    property real ctxX: 0
    property real ctxY: 0

    function openContext(entry, pos) {
        ctxEntry = entry;
        ctxX = pos.x;
        ctxY = pos.y;
    }

    function isStartPinned(id) {
        return Settings.data.startPinnedApps.indexOf(id) !== -1;
    }
    function toggleStartPin(id) {
        Settings.data.startPinnedApps = isStartPinned(id)
            ? Settings.data.startPinnedApps.filter(p => p !== id)
            : [...Settings.data.startPinnedApps, id];
    }
    function isTaskbarPinned(id) {
        return Settings.data.pinnedApps.indexOf(id) !== -1;
    }
    function toggleTaskbarPin(id) {
        Settings.data.pinnedApps = isTaskbarPinned(id)
            ? Settings.data.pinnedApps.filter(p => p !== id)
            : [...Settings.data.pinnedApps, id];
    }

    function launchEntry(entry) {
        if (entry !== null) {
            AppSearch.launch(entry);
            root.close();
        }
    }

    function launchSelected() {
        if (results.length > 0)
            launchEntry(results[Math.max(0, Math.min(list.currentIndex, results.length - 1))]);
    }

    onExpandChanged: {
        if (expand) {
            searchField.text = "";
            list.currentIndex = 0;
            ctxEntry = null;
            searchField.input.forceActiveFocus();
        }
    }

    Item {
        id: menuContent
        width: parent.width
        implicitHeight: 470

        // ------------------------------------------------------- left rail
        Item {
            id: rail
            width: 170
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                id: profileCard
                width: parent.width
                height: 52
                radius: Theme.radiusSm
                color: profileMouse.pressed ? Theme.layerPressed
                     : profileMouse.containsMouse ? Theme.layerHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    AvatarBadge {
                        anchors.verticalCenter: parent.verticalCenter
                        size: 34
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        StyledText {
                            text: Profile.displayName
                            font.weight: Font.DemiBold
                            width: 108
                            elide: Text.ElideRight
                        }
                        StyledText {
                            text: "Local account"
                            font.pixelSize: Theme.fontXs
                            color: Theme.fgMuted
                        }
                    }
                }

                MouseArea {
                    id: profileMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.close();
                        GlobalState.openSettings("profile");
                    }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: 2

                ListButton {
                    width: parent.width
                    icon: "settings"
                    label: "Settings"
                    onClicked: {
                        root.close();
                        GlobalState.openSettings("");
                    }
                }
                ListButton {
                    width: parent.width
                    icon: "lock"
                    label: "Lock"
                    onClicked: {
                        root.close();
                        Session.lock();
                    }
                }
                ListButton {
                    width: parent.width
                    icon: "log-out"
                    label: "Log Out"
                    onClicked: Session.logout()
                }
                ListButton {
                    width: parent.width
                    icon: "rotate-ccw"
                    label: "Restart"
                    onClicked: Session.reboot()
                }
                ListButton {
                    width: parent.width
                    icon: "power"
                    label: "Shut Down"
                    danger: true
                    onClicked: Session.poweroff()
                }
            }
        }

        Rectangle {
            anchors.left: rail.right
            anchors.leftMargin: 7
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: Theme.border
        }

        // ---------------------------------------------------------- center
        Column {
            anchors.left: rail.right
            anchors.leftMargin: 16
            anchors.right: pinnedCol.left
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            spacing: 10

            Keys.onDownPressed: list.incrementCurrentIndex()
            Keys.onUpPressed: list.decrementCurrentIndex()

            GTextField {
                id: searchField
                width: parent.width
                leadingIcon: "search"
                placeholder: "Search apps"
                onAccepted: root.launchSelected()
                onTextChanged: list.currentIndex = 0
            }

            ListView {
                id: list
                width: parent.width
                height: 396
                clip: true
                model: root.results
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                keyNavigationWraps: true

                delegate: Rectangle {
                    id: resultRow

                    required property var modelData
                    required property int index

                    width: list.width
                    height: 42
                    radius: Theme.radiusSm
                    color: list.currentIndex === index ? Theme.surfaceHover : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        Image {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            height: 26
                            sourceSize: Qt.size(52, 52)
                            source: AppSearch.iconFor(resultRow.modelData, "")
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 38
                            spacing: 0

                            StyledText {
                                width: parent.width
                                text: resultRow.modelData.name
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                            StyledText {
                                width: parent.width
                                visible: text !== ""
                                text: resultRow.modelData.genericName || ""
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgMuted
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onEntered: list.currentIndex = resultRow.index
                        onClicked: event => {
                            if (event.button === Qt.RightButton)
                                root.openContext(resultRow.modelData,
                                    resultRow.mapToItem(menuContent, event.x, event.y));
                            else
                                root.launchSelected();
                        }
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: root.expand && root.results.length === 0
                    text: "No results"
                    color: Theme.fgMuted
                }
            }

            Row {
                spacing: 14

                StyledText {
                    text: "↵ Launch"
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgMuted
                }
                StyledText {
                    text: "↑↓ Navigate"
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgMuted
                }
                StyledText {
                    text: "Esc Close"
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgMuted
                }
            }
        }

        Rectangle {
            anchors.right: pinnedCol.left
            anchors.rightMargin: 8
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: Theme.border
        }

        // ----------------------------------------------------- pinned apps
        Column {
            id: pinnedCol
            width: 200
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 10

            StyledText {
                role: Theme.typeOverline
                text: "PINNED"
                color: Theme.fgMuted
            }

            Flow {
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.pinned

                    Rectangle {
                        id: pinCell

                        required property var modelData

                        width: 64
                        height: 70
                        radius: Theme.radiusSm
                        color: pinMouse.pressed ? Theme.layerPressed
                             : pinMouse.containsMouse ? Theme.layerHover : "transparent"

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Image {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 28
                                height: 28
                                sourceSize: Qt.size(56, 56)
                                source: AppSearch.iconFor(pinCell.modelData, "")
                            }
                            StyledText {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 58
                                horizontalAlignment: Text.AlignHCenter
                                text: pinCell.modelData.name
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgDim
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: pinMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton)
                                    root.openContext(pinCell.modelData,
                                        pinCell.mapToItem(menuContent, event.x, event.y));
                                else
                                    root.launchEntry(pinCell.modelData);
                            }
                        }
                    }
                }
            }

            StyledText {
                visible: root.pinned.length === 0
                width: parent.width
                text: "Right-click any app to pin it here"
                font.pixelSize: Theme.fontXs
                color: Theme.fgMuted
                wrapMode: Text.WordWrap
            }
        }

        // ------------------------------------------------ app context menu
        MouseArea {
            anchors.fill: parent
            visible: root.ctxEntry !== null
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            z: 90
            onPressed: root.ctxEntry = null
        }

        Rectangle {
            visible: root.ctxEntry !== null
            z: 91
            x: Math.max(0, Math.min(root.ctxX, menuContent.width - width - 4))
            y: Math.max(0, Math.min(root.ctxY, menuContent.height - height - 4))
            width: 200
            height: ctxCol.implicitHeight + 12
            radius: Theme.radiusSm
            color: Theme.surface
            border.width: 1
            border.color: Theme.border

            Column {
                id: ctxCol
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                ListButton {
                    width: parent.width
                    icon: "pin"
                    label: root.ctxEntry !== null && root.isStartPinned(root.ctxEntry.id)
                        ? "Unpin from Start" : "Pin to Start"
                    onClicked: {
                        root.toggleStartPin(root.ctxEntry.id);
                        root.ctxEntry = null;
                    }
                }
                ListButton {
                    width: parent.width
                    icon: "panel-bottom"
                    label: root.ctxEntry !== null && root.isTaskbarPinned(root.ctxEntry.id)
                        ? "Unpin from taskbar" : "Pin to taskbar"
                    onClicked: {
                        root.toggleTaskbarPin(root.ctxEntry.id);
                        root.ctxEntry = null;
                    }
                }
            }
        }
    }
}
