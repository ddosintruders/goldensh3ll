// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Cursor theme management: lists installed themes (~/.icons and
// /usr/share/icons containing a cursors/ dir), applies live via
// hyprctl setcursor + gsettings, persists in shell settings.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property var themes: []
    readonly property string current: Settings.data.cursorTheme
    readonly property int size: Settings.data.cursorSize

    function scan() {
        scanProc.running = false;
        scanProc.running = true;
    }

    function apply(name, sizePx) {
        if (!name)
            return;
        Settings.data.cursorTheme = name;
        Settings.data.cursorSize = sizePx;
        push();
    }

    function push() {
        if (!Settings.data.cursorTheme)
            return;
        Quickshell.execDetached(["sh", "-c",
            'hyprctl setcursor "$1" "$2" >/dev/null 2>&1; ' +
            'command -v gsettings >/dev/null 2>&1 && { ' +
            'gsettings set org.gnome.desktop.interface cursor-theme "$1"; ' +
            'gsettings set org.gnome.desktop.interface cursor-size "$2"; } || true',
            "gs-cursor", Settings.data.cursorTheme, String(Settings.data.cursorSize)]);
    }

    Process {
        id: scanProc
        running: true
        command: ["sh", "-c",
            'for d in "$HOME/.icons"/* "$HOME/.local/share/icons"/* /usr/share/icons/*; do ' +
            '[ -d "$d/cursors" ] && basename "$d"; done 2>/dev/null | sort -u']
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.themes = t.length > 0 ? t.split("\n") : [];
            }
        }
    }

    // Re-apply the persisted cursor after the shell (re)starts.
    Timer {
        interval: 3000
        running: true
        onTriggered: root.push()
    }
}
