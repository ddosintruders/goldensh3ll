// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Wayland session lock. GlobalState.locked survives shell reloads so a
// crash or config reload never drops the lock.

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

Scope {
    id: root

    LockContext {
        id: lockContext
        onUnlocked: GlobalState.unlock()
    }

    Connections {
        target: GlobalState
        function onLockedChanged() {
            lockContext.reset();
            // Fresh lock wallpaper on every lock when shuffle is enabled.
            if (GlobalState.locked
                    && Settings.data.separateLockWallpaper
                    && Settings.data.lockWallpaperShuffle)
                Wallpapers.randomLock();
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: GlobalState.locked

        WlSessionLockSurface {
            id: lockSurface
            color: "#101114"

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screenName: lockSurface.screen !== null ? lockSurface.screen.name : ""
            }
        }
    }
}
