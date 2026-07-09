// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Backlight control through brightnessctl. `userChanged` fires only for
// changes made through this service, so the OSD is not triggered by the
// periodic resync.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property real value: 0.5

    signal userChanged()

    function set(v) {
        if (!available) return;
        value = Math.max(0.01, Math.min(1, v));
        setProc.command = ["brightnessctl", "-q", "set", Math.round(value * 100) + "%"];
        setProc.running = true;
        userChanged();
    }

    function up() { set(value + 0.05); }
    function down() { set(value - 0.05); }

    function refresh() { readProc.running = true; }

    function parse(text) {
        const line = text.trim().split("\n")[0];
        if (!line) { available = false; return; }
        const parts = line.split(",");
        if (parts.length >= 4) {
            available = true;
            const pct = parseInt(parts[3]);
            if (!isNaN(pct)) value = pct / 100;
        }
    }

    Process {
        id: readProc
        running: true
        command: ["sh", "-c", "command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m || true"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Process {
        id: setProc
    }

    Timer {
        interval: 30000
        running: root.available
        repeat: true
        onTriggered: root.refresh()
    }
}
