// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Windows-inspired taskbar: launcher search on the left, pinned + running
// apps centered, system tray and clock on the right.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs.config
import qs.components
import qs.services

Scope {
    id: root

    required property var modelData

    readonly property bool isFocusedScreen:
        Hyprland.focusedMonitor !== null && Hyprland.focusedMonitor.name === modelData.name

    // ------------------------------------------------------------ task model
    // Groups pinned apps and running toplevels, Windows style.
    property var taskGroups: []

    function rebuildTasks() {
        const groups = [];
        const byKey = {};
        for (const id of Settings.data.pinnedApps) {
            const entry = AppSearch.entryFor(id);
            const key = AppSearch.normalize(entry !== null ? entry.id : id);
            if (byKey[key] !== undefined)
                continue;
            const g = { key: key, id: id, entry: entry, pinned: true, windows: [] };
            byKey[key] = g;
            groups.push(g);
        }
        for (const t of ToplevelManager.toplevels.values) {
            let key = AppSearch.normalize(t.appId);
            let g = byKey[key];
            if (g === undefined) {
                const entry = AppSearch.entryFor(t.appId);
                if (entry !== null)
                    key = AppSearch.normalize(entry.id);
                g = byKey[key];
                if (g === undefined) {
                    g = { key: key, id: t.appId, entry: entry, pinned: false, windows: [] };
                    byKey[key] = g;
                    groups.push(g);
                }
            }
            g.windows.push(t);
        }
        taskGroups = groups;
    }

    function activateGroup(g) {
        if (g.windows.length === 0) {
            if (g.entry !== null)
                AppSearch.launch(g.entry);
            return;
        }
        const idx = g.windows.indexOf(ToplevelManager.activeToplevel);
        if (idx === -1) {
            g.windows[0].activate();
        } else if (g.windows.length === 1) {
            g.windows[0].minimized = true;
        } else {
            g.windows[(idx + 1) % g.windows.length].activate();
        }
    }

    Connections {
        target: ToplevelManager.toplevels
        function onValuesChanged() { root.rebuildTasks(); }
    }
    Connections {
        target: Settings.data
        function onPinnedAppsChanged() { root.rebuildTasks(); }
    }
    Component.onCompleted: rebuildTasks()

    // Start menu can be driven globally (Super / Super+Space via IPC) or by
    // clicking the logo.
    Connections {
        target: GlobalState
        function onLauncherOpenChanged() {
            if (GlobalState.launcherOpen && root.isFocusedScreen)
                launcher.openAt(logoButton.mapToItem(null, logoButton.width / 2, 0).x);
            else if (!GlobalState.launcherOpen)
                launcher.close();
        }
    }

    PanelWindow {
        id: bar

        screen: root.modelData
        anchors { bottom: true; left: true; right: true }
        implicitHeight: Theme.taskbarHeight
        color: "transparent"
        WlrLayershell.namespace: "goldensh3ll-taskbar"
        // Grants typing focus while the inline web search is active.
        WlrLayershell.keyboardFocus: searchPill.active
            ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        Rectangle {
            anchors.fill: parent
            color: Theme.barBg

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Theme.border
            }
        }

        // Right-click on empty bar background → customize bars.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: event => barMenu.openAt(event.x)
        }

        // ------------------------------------------------------------- left
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Rectangle {
                id: logoButton
                anchors.verticalCenter: parent.verticalCenter
                width: 38
                height: 38
                radius: Theme.radiusSm
                color: logoMouse.containsMouse ? Theme.surfaceHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Image {
                    anchors.centerIn: parent
                    source: Theme.logo
                    width: 24
                    height: 24
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                }

                MouseArea {
                    id: logoMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (launcher.expand)
                            launcher.close();
                        else
                            launcher.openAt(logoButton.mapToItem(null, logoButton.width / 2, 0).x);
                    }
                }
            }

            // Inline DuckDuckGo web search: click to expand, Enter opens the
            // query in the default browser (app search lives in the Start menu).
            Rectangle {
                id: searchPill

                property bool active: false

                function collapse() {
                    active = false;
                    webInput.text = "";
                }

                anchors.verticalCenter: parent.verticalCenter
                width: active ? 340 : 210
                height: 34
                radius: height / 2
                color: active ? Theme.surfaceActive
                     : searchMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                border.width: 1
                border.color: active ? Theme.accent : Theme.border

                Behavior on width { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
                Behavior on border.color { ColorAnimation { duration: Theme.animFast } }
                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Timer {
                    id: collapseDelay
                    interval: 150
                    onTriggered: {
                        if (!webInput.activeFocus)
                            searchPill.collapse();
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: "search"
                        size: 14
                        color: searchPill.active ? Theme.accent : Theme.fgMuted
                    }

                    Item {
                        width: parent.width - 22
                        height: searchPill.height
                        anchors.verticalCenter: parent.verticalCenter

                        TextInput {
                            id: webInput
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            visible: searchPill.active
                            color: Theme.fg
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontMd
                            clip: true
                            selectionColor: Theme.accent
                            selectedTextColor: Theme.onAccent
                            onAccepted: {
                                const q = text.trim();
                                if (q.length > 0)
                                    Quickshell.execDetached(["xdg-open",
                                        "https://duckduckgo.com/?q=" + encodeURIComponent(q)]);
                                searchPill.collapse();
                            }
                            Keys.onEscapePressed: searchPill.collapse()
                            onActiveFocusChanged: {
                                if (!activeFocus && searchPill.active)
                                    collapseDelay.restart();
                            }
                        }

                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !searchPill.active || webInput.text.length === 0
                            text: searchPill.active ? "Search DuckDuckGo" : "Search the web"
                            color: Theme.fgMuted
                        }
                    }
                }

                MouseArea {
                    id: searchMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: !searchPill.active
                    onClicked: {
                        searchPill.active = true;
                        webInput.forceActiveFocus();
                    }
                }
            }

            // Compact current weather (inherits the widget's location/units).
            Rectangle {
                visible: Settings.data.showWeatherInTaskbar && Weather.configured
                anchors.verticalCenter: parent.verticalCenter
                width: weatherRow.implicitWidth + 22
                height: 34
                radius: height / 2
                color: weatherMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                border.width: 1
                border.color: Theme.border

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Row {
                    id: weatherRow
                    anchors.centerIn: parent
                    spacing: 7

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        name: Weather.iconName
                        size: 14
                        color: Theme.fgDim
                    }
                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Weather.hasData ? Math.round(Weather.temp) + Weather.unit : "…"
                        font.pixelSize: Theme.fontSm
                        font.weight: Font.Medium
                        color: Theme.fgDim
                    }
                }

                MouseArea {
                    id: weatherMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: GlobalState.openSettings("desktop")
                }
            }
        }

        // ----------------------------------------------------------- center
        Row {
            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: root.taskGroups

                Item {
                    id: task

                    required property var modelData

                    readonly property bool running: modelData.windows.length > 0
                    readonly property bool isActive:
                        modelData.windows.indexOf(ToplevelManager.activeToplevel) !== -1

                    width: 46
                    height: 50
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 3
                        radius: Theme.radiusSm
                        color: task.isActive ? Theme.surfaceHover
                             : taskMouse.containsMouse ? Theme.surfaceHover : "transparent"
                        opacity: task.isActive ? 0.8 : 1

                        Behavior on color { ColorAnimation { duration: Theme.animFast } }
                    }

                    Image {
                        id: taskIcon
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        width: 28
                        height: 28
                        sourceSize: Qt.size(56, 56)
                        source: AppSearch.iconFor(task.modelData.entry, task.modelData.id)
                        scale: taskMouse.containsMouse ? 1.08 : 1

                        Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                    }

                    // Single bounce when launching a new instance.
                    SequentialAnimation {
                        id: launchBounce
                        NumberAnimation {
                            target: taskIcon
                            property: "anchors.topMargin"
                            to: 3
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: taskIcon
                            property: "anchors.topMargin"
                            to: 8
                            duration: 240
                            easing.type: Easing.OutBack
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        width: task.isActive ? 16 : task.running ? 7 : 0
                        height: 3
                        radius: 1.5
                        color: task.isActive ? Theme.accent : Theme.fgMuted
                        visible: task.running

                        Behavior on width { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        id: taskMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        onClicked: event => {
                            if (event.button === Qt.MiddleButton) {
                                for (const w of task.modelData.windows)
                                    w.close();
                            } else {
                                if (task.modelData.windows.length === 0 && !Theme.reduceMotion)
                                    launchBounce.restart();
                                root.activateGroup(task.modelData);
                            }
                        }
                    }
                }
            }
        }

        // ------------------------------------------------------------ right
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Removable drives (appears only when one is plugged in).
            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                visible: Drives.drives.length > 0
                icon: "usb"
                buttonSize: 26
                iconSize: 14
                active: drivesPopup.expand
                onClicked: {
                    if (drivesPopup.expand)
                        drivesPopup.close();
                    else
                        drivesPopup.openAt(mapToItem(null, width / 2, 0).x);
                }
            }

            // System tray
            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                visible: SystemTray.items.values.length > 0

                GIconButton {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "chevron-up"
                    buttonSize: 26
                    iconSize: 13
                    rotation: trayPopup.expand ? 180 : 0
                    onClicked: {
                        if (trayPopup.expand)
                            trayPopup.close();
                        else
                            trayPopup.openAt(mapToItem(null, width / 2, 0).x);
                    }

                    Behavior on rotation { NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard } }
                }

                Repeater {
                    model: SystemTray.items

                    Rectangle {
                        id: trayIcon

                        required property var modelData

                        anchors.verticalCenter: parent.verticalCenter
                        width: 26
                        height: 26
                        radius: Theme.radiusXs
                        color: trayIconMouse.containsMouse ? Theme.surfaceHover : "transparent"

                        Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            sourceSize: Qt.size(32, 32)
                            source: trayIcon.modelData.icon
                        }

                        MouseArea {
                            id: trayIconMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                            onClicked: event => {
                                if (event.button === Qt.RightButton || trayIcon.modelData.onlyMenu)
                                    root.openTrayMenu(trayIcon.modelData,
                                                      trayIcon.mapToItem(null, trayIcon.width / 2, 0).x);
                                else if (event.button === Qt.MiddleButton)
                                    trayIcon.modelData.secondaryActivate();
                                else
                                    trayIcon.modelData.activate();
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 1
                height: 26
                color: Theme.border
            }

            // Clock
            Rectangle {
                id: clockPill
                anchors.verticalCenter: parent.verticalCenter
                width: clockColumn.implicitWidth + 20
                height: 44
                radius: Theme.radiusSm
                color: clockMouse.containsMouse ? Theme.surfaceHover : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animFast } }

                Column {
                    id: clockColumn
                    anchors.centerIn: parent
                    spacing: 1

                    StyledText {
                        anchors.right: parent.right
                        text: Time.time
                        font.pixelSize: Theme.fontMd
                        font.weight: Font.Medium
                    }
                    StyledText {
                        anchors.right: parent.right
                        text: Time.dateShort
                        font.pixelSize: Theme.fontSm
                        color: Theme.fgDim
                    }
                }

                MouseArea {
                    id: clockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: event => {
                        if (event.button === Qt.RightButton) {
                            clockMenu.openAt(clockPill.mapToItem(null, clockPill.width / 2, 0).x);
                            return;
                        }
                        if (calendar.expand)
                            calendar.close();
                        else
                            calendar.openAt(clockPill.mapToItem(null, clockPill.width / 2, 0).x);
                    }
                }
            }
        }
    }

    // Native SNI context menus for tray items.
    QsMenuAnchor {
        id: trayMenu
        anchor.window: bar
        anchor.edges: Edges.Top
        anchor.gravity: Edges.Top
    }

    function openTrayMenu(item, x) {
        if (!item.hasMenu)
            return;
        trayMenu.menu = item.menu;
        trayMenu.anchor.rect.x = x;
        trayMenu.anchor.rect.y = 0;
        trayMenu.anchor.rect.width = 1;
        trayMenu.anchor.rect.height = 1;
        trayMenu.open();
    }

    LauncherPopup {
        id: launcher
        screen: root.modelData
        onExpandChanged: {
            if (expand)
                GlobalState.launcherOpen = true;
            else if (GlobalState.launcherOpen)
                GlobalState.launcherOpen = false;
        }
    }
    CalendarPopup { id: calendar; screen: root.modelData }
    TrayPopup { id: trayPopup; screen: root.modelData }
    DrivesPopup { id: drivesPopup; screen: root.modelData }

    ContextMenu {
        id: clockMenu
        screen: root.modelData
        fromTop: false

        ListButton {
            width: parent.width
            icon: "clock"
            label: "Adjust time & date…"
            onClicked: {
                clockMenu.close();
                GlobalState.openSettings("timedate");
            }
        }
    }

    ContextMenu {
        id: barMenu
        screen: root.modelData
        fromTop: false

        ListButton {
            width: parent.width
            icon: "panel-top"
            label: "Customize bars…"
            onClicked: {
                barMenu.close();
                GlobalState.openSettings("shell");
            }
        }
    }
}
