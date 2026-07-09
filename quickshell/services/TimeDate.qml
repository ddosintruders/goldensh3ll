// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// System clock configuration through timedatectl (NTP, timezone, manual
// time). Privileged calls go through polkit — a running polkit agent is
// required for non-root changes; failures surface in lastError.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string timezone: ""
    property bool ntp: true
    property bool ntpSynchronized: false
    property string lastError: ""
    property var timezones: []
    property bool busy: false

    function refresh() {
        statusProc.running = false;
        statusProc.running = true;
    }

    function loadTimezones() {
        if (timezones.length === 0)
            tzProc.running = true;
    }

    function setNtp(on) { act(["set-ntp", on ? "true" : "false"]); }
    function setTimezone(tz) { act(["set-timezone", tz]); }
    // dateStr "YYYY-MM-DD", timeStr "HH:MM:SS" — requires NTP off.
    function setTime(dateStr, timeStr) { act(["set-time", dateStr + " " + timeStr]); }

    function act(args) {
        if (busy)
            return;
        busy = true;
        lastError = "";
        actProc.command = ["timedatectl"].concat(args);
        actProc.running = true;
    }

    Process {
        id: statusProc
        running: true
        command: ["sh", "-c", "timedatectl show 2>/dev/null || echo NOTD"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.indexOf("NOTD") !== -1 || text.trim() === "") {
                    root.available = false;
                    return;
                }
                root.available = true;
                for (const line of text.trim().split("\n")) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const key = line.substring(0, i);
                    const val = line.substring(i + 1);
                    if (key === "Timezone") root.timezone = val;
                    else if (key === "NTP") root.ntp = val === "yes";
                    else if (key === "NTPSynchronized") root.ntpSynchronized = val === "yes";
                }
            }
        }
    }

    Process {
        id: tzProc
        command: ["timedatectl", "list-timezones"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.timezones = t.length > 0 ? t.split("\n") : [];
            }
        }
    }

    Process {
        id: actProc
        stderr: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                if (t) root.lastError = t;
            }
        }
        onExited: {
            root.busy = false;
            root.refresh();
        }
    }
}
