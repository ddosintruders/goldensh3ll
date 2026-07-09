// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Floating popup used by every bar flyout. Implemented as a transparent
// full-screen overlay so clicking anywhere outside the panel dismisses it.
// The panel positions itself against the top bar or the taskbar and sizes
// its height from the (single) content child's implicitHeight.

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    property bool expand: false
    property real anchorCenterX: width / 2
    property bool fromTop: true
    property real panelWidth: 340
    property real panelPadding: 12
    property bool exclusiveKeyboard: false
    default property alias contentData: slot.data

    function close() { expand = false; }
    function openAt(x) { anchorCenterX = x; expand = true; }
    function toggleAt(x) { anchorCenterX = x; expand = !expand; }

    // Stays mapped during the exit animation, then unmaps.
    visible: expand || closeDelay.running
    onExpandChanged: if (!expand) closeDelay.restart()

    Timer {
        id: closeDelay
        interval: Math.max(30, Theme.durFast + 40)
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "goldensh3ll-popup"
    WlrLayershell.keyboardFocus: expand
        ? (exclusiveKeyboard ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand)
        : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onPressed: root.close()
    }

    Rectangle {
        id: panel

        readonly property real contentHeight: slot.children.length > 0
            ? slot.children[0].implicitHeight : 0
        readonly property real baseY: root.fromTop
            ? Theme.topExclusion + 6
            : root.height - Theme.taskbarHeight - 6 - height

        width: root.panelWidth
        height: contentHeight + root.panelPadding * 2
        x: Math.max(8, Math.min(root.anchorCenterX - width / 2, root.width - width - 8))
        // Directional 12px slide from the owning bar.
        y: baseY + (root.expand ? 0 : (root.fromTop ? -12 : 12))

        radius: Theme.radiusLg
        color: Theme.popupBg
        border.width: 1
        border.color: Theme.popupBorder

        opacity: root.expand ? 1 : 0
        scale: root.expand ? 1 : 0.97
        transformOrigin: root.fromTop ? Item.Top : Item.Bottom
        Behavior on opacity { NumberAnimation { duration: Theme.durFast } }
        Behavior on y {
            NumberAnimation {
                duration: Theme.durMed
                easing.type: Theme.easeEmphasized
                easing.overshoot: 1.05
            }
        }
        Behavior on height {
            NumberAnimation { duration: Theme.durMed; easing.type: Theme.easeStandard }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Theme.durMed
                easing.type: Theme.easeEmphasized
                easing.overshoot: 1.05
            }
        }

        // Blocks clicks from falling through to the dismiss layer below.
        MouseArea { anchors.fill: parent }

        FocusScope {
            id: slot
            anchors.fill: parent
            anchors.margins: root.panelPadding
            focus: true
            Keys.onEscapePressed: root.close()
        }
    }
}
