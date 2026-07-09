// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The "apple menu" of GoldenSh3ll: shell + session actions.

import QtQuick
import Quickshell
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 230
    panelPadding: 8

    Column {
        width: parent.width
        spacing: 2

        ListButton {
            width: parent.width
            icon: "info"
            label: "About GoldenSh3ll"
            onClicked: { root.close(); GlobalState.openSettings("about"); }
        }
        ListButton {
            width: parent.width
            icon: "settings"
            label: "System Settings…"
            hint: "Super+I"
            onClicked: { root.close(); GlobalState.openSettings(""); }
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        ListButton {
            width: parent.width
            icon: "lock"
            label: "Lock Screen"
            hint: "Super+L"
            onClicked: { root.close(); Session.lock(); }
        }
        ListButton {
            width: parent.width
            icon: "refresh-cw"
            label: "Restart Shell"
            onClicked: Quickshell.reload(true)
        }

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        ListButton {
            width: parent.width
            icon: "log-out"
            label: "Log Out"
            onClicked: Session.logout()
        }
        ListButton {
            width: parent.width
            icon: "rotate-ccw"
            label: "Restart…"
            onClicked: Session.reboot()
        }
        ListButton {
            width: parent.width
            icon: "power"
            label: "Shut Down…"
            danger: true
            onClicked: Session.poweroff()
        }
    }
}
