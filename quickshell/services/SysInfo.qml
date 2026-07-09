// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Static-ish system facts for the About page.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string os: ""
    property string kernel: ""
    property string hostname: ""
    property string uptime: ""
    property string cpu: ""
    property string memory: ""
    property string qsVersion: ""
    readonly property string user: Quickshell.env("USER") || "user"

    function refresh() { proc.running = true; }

    Process {
        id: proc
        running: true
        command: ["sh", "-c",
            "echo \"OS=$(. /etc/os-release 2>/dev/null; echo \"$PRETTY_NAME\")\"; " +
            "echo \"KERNEL=$(uname -r)\"; " +
            "echo \"HOST=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null)\"; " +
            "echo \"UPTIME=$(uptime -p 2>/dev/null | sed 's/^up //')\"; " +
            "echo \"CPU=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2- | sed 's/^ *//')\"; " +
            "echo \"MEM=$(free -h 2>/dev/null | awk '/^Mem:/{print $2}')\"; " +
            "echo \"QS=$(qs --version 2>/dev/null | head -n1)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const key = line.substring(0, i);
                    const val = line.substring(i + 1).trim();
                    switch (key) {
                    case "OS": root.os = val; break;
                    case "KERNEL": root.kernel = val; break;
                    case "HOST": root.hostname = val; break;
                    case "UPTIME": root.uptime = val; break;
                    case "CPU": root.cpu = val; break;
                    case "MEM": root.memory = val; break;
                    case "QS": root.qsVersion = val; break;
                    }
                }
            }
        }
    }
}
