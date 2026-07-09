// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Central session actions. logout() must fully terminate the logind
// session (not just exit Hyprland) so the display manager (SDDM) returns:
// prefer uwsm when it manages the session, then the Hyprland exit
// dispatcher, and finally force logind to tear the session down.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    function lock() {
        GlobalState.lock();
    }

    function logout() {
        Quickshell.execDetached(["sh", "-c",
            'if command -v uwsm >/dev/null 2>&1 && uwsm check is-active >/dev/null 2>&1; then ' +
            'uwsm stop; else hyprctl dispatch exit; fi; ' +
            'sleep 2; loginctl terminate-session "$XDG_SESSION_ID" 2>/dev/null || true']);
    }

    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }
}
