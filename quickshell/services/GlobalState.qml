// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Cross-module UI state. The lock flag survives shell reloads.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool settingsOpen: false
    property string settingsPage: "appearance"
    property bool launcherOpen: false
    property bool desktopEditMode: false

    property alias locked: persist.locked

    function lock() { persist.locked = true; }
    function unlock() { persist.locked = false; }

    function openSettings(page) {
        if (page) settingsPage = page;
        settingsOpen = true;
    }

    PersistentProperties {
        id: persist
        reloadableId: "goldensh3llState"
        property bool locked: false
    }
}
