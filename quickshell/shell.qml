// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// GoldenSh3ll entry point.
//
// IPC surface (usable from Hyprland binds or a terminal):
//   qs ipc call lockscreen lock
//   qs ipc call launcher toggle
//   qs ipc call settings toggle | qs ipc call settings open <page>
//   qs ipc call brightness up | down
//   qs ipc call wallpaper next | qs ipc call wallpaper set <path>

import Quickshell
import Quickshell.Io
import qs.config
import qs.services
import qs.modules.topbar
import qs.modules.taskbar
import qs.modules.lock
import qs.modules.osd
import qs.modules.notifications
import qs.modules.settings
import qs.modules.desktop

ShellRoot {
    id: shellRoot

    // Singletons only instantiate when referenced — touch the background
    // services (system theme sync, cursor re-apply) so they run at startup.
    readonly property var backgroundServices: [ThemeSync, CursorTheme]

    // Glass materials: ask Hyprland to blur our layer surfaces. Additive
    // keywords, re-applied on every shell start; harmless when translucency
    // is off since the surfaces are then near-opaque. (A Process is used
    // instead of Component.onCompleted — ShellRoot does not support
    // attached objects.)
    Process {
        running: true
        command: {
            const namespaces = ["goldensh3ll-topbar", "goldensh3ll-taskbar",
                                "goldensh3ll-popup", "goldensh3ll-osd",
                                "goldensh3ll-notifications"];
            const cmds = [];
            for (const ns of namespaces) {
                cmds.push("keyword layerrule blur," + ns);
                cmds.push("keyword layerrule ignorezero," + ns);
            }
            return ["hyprctl", "--batch", cmds.join(";")];
        }
    }

    Variants {
        model: Quickshell.screens
        Desktop {}
    }

    Variants {
        model: Quickshell.screens
        TopBar {}
    }

    Variants {
        model: Quickshell.screens
        Taskbar {}
    }

    Variants {
        model: Quickshell.screens
        Osd {}
    }

    Variants {
        model: Quickshell.screens
        NotificationPopups {}
    }

    LockScreen {}

    LazyLoader {
        active: GlobalState.settingsOpen
        SettingsWindow {}
    }

    IpcHandler {
        target: "lockscreen"
        function lock(): void { GlobalState.lock(); }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { GlobalState.launcherOpen = !GlobalState.launcherOpen; }
    }

    IpcHandler {
        target: "settings"
        function toggle(): void { GlobalState.settingsOpen = !GlobalState.settingsOpen; }
        function open(page: string): void { GlobalState.openSettings(page); }
    }

    IpcHandler {
        target: "brightness"
        function up(): void { Brightness.up(); }
        function down(): void { Brightness.down(); }
    }

    IpcHandler {
        target: "wallpaper"
        function next(): void { Wallpapers.applyRandom(); }
        function set(path: string): void { Wallpapers.apply(path, ""); }
    }

    IpcHandler {
        target: "capture"
        function full(): void { Capture.screenshotFull(); }
        function region(): void { Capture.screenshotRegion(); }
        function record(): void { Capture.toggleRecording(); }
    }
}
