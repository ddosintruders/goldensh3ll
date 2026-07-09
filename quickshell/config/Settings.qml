// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Persistent shell configuration, stored as JSON at
// ~/.config/goldensh3ll/settings.json and hot-reloaded on external edits.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string configDir: home + "/.config/goldensh3ll"
    property alias data: adapter

    Process {
        running: true
        command: ["mkdir", "-p", root.configDir]
    }

    FileView {
        id: file
        path: root.configDir + "/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            // Appearance
            property bool darkMode: true
            property string accent: "gold"
            property bool dynamicColor: false
            property bool translucency: true
            property bool reduceMotion: false

            // Profile
            property string userName: ""
            // "" | "preset:1".."preset:8" | absolute image path
            property string avatar: ""

            // Cursor
            property string cursorTheme: ""
            property int cursorSize: 24

            // Top bar chrome
            property bool barFloating: true
            property real barOpacity: 0.72

            // Desktop: shortcuts are desktop-entry ids; widgets encode
            // "type::x::y" per instance.
            property list<string> desktopShortcuts: []
            property list<string> desktopWidgets: []

            // Weather widget
            property string weatherPlace: ""
            property string weatherLat: ""
            property string weatherLon: ""
            property bool weatherCelsius: true

            // Connected accounts registry, encoded "Service::identifier"
            property list<string> accounts: []

            // Top bar
            property bool showMediaInBar: true
            property bool showBattery: true

            // Taskbar
            property bool clock24h: false
            property list<string> pinnedApps: ["firefox", "org.kde.dolphin", "kitty"]
            property bool showWeatherInTaskbar: true

            // Start menu pins (independent of the taskbar)
            property list<string> startPinnedApps: ["firefox", "org.kde.dolphin", "kitty"]

            // Media / visualizer
            property bool mediaVisualizer: true
            property int visualizerBars: 20
            // "rounded" | "square" | "dots"
            property string visualizerShape: "rounded"
            // "accent" or "#RRGGBB"
            property string visualizerColor: "accent"

            // Lockscreen wallpaper (optional split from the desktop)
            property bool separateLockWallpaper: false
            property string lockWallpaperDir: root.home + "/Pictures/Wallpapers"
            property string lockWallpaper: ""
            property bool lockWallpaperShuffle: false

            // Clock widget font ("" = interface font)
            property string clockWidgetFont: ""

            // Wallpaper engine
            property string wallpaperDir: root.home + "/Pictures/Wallpapers"
            property string wallpaper: ""
            // Per-monitor overrides, encoded as "MONITOR::/absolute/path"
            property list<string> monitorWallpapers: []
            property bool wallpaperShuffle: false
            property int wallpaperShuffleMinutes: 30

            // Notifications
            property bool doNotDisturb: false
        }
    }
}
