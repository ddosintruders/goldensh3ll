// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Removable drives: polled via lsblk (JSON), mounted/unmounted through
// udisks2 so no elevated privileges are needed for user-session mounts.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // { path, label, size, mountpoint }
    property var drives: []
    property string busyPath: ""
    property string lastError: ""

    function refresh() {
        listProc.running = false;
        listProc.running = true;
    }

    function mount(path) { act("mount", path); }
    function unmount(path) { act("unmount", path); }

    function act(action, path) {
        if (busyPath !== "" || !path)
            return;
        busyPath = path;
        lastError = "";
        actProc.output = "";
        actProc.command = ["udisksctl", action, "-b", path];
        actProc.running = true;
    }

    function collect(node, out) {
        const removable = node.rm === true || node.hotplug === true;
        if (removable && node.fstype && (node.type === "part" || node.type === "disk")) {
            out.push({
                path: node.path,
                label: node.label || node.path.split("/").pop(),
                size: node.size || "",
                mountpoint: node.mountpoint || ""
            });
        }
        if (node.children !== undefined)
            for (const c of node.children)
                collect(c, out);
    }

    Process {
        id: listProc
        running: true
        command: ["sh", "-c",
            "command -v lsblk >/dev/null 2>&1 && " +
            "lsblk -J -o NAME,PATH,RM,HOTPLUG,SIZE,LABEL,TYPE,MOUNTPOINT,FSTYPE || echo '{}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    const out = [];
                    if (parsed.blockdevices !== undefined)
                        for (const d of parsed.blockdevices)
                            root.collect(d, out);
                    root.drives = out;
                } catch (e) {
                    root.drives = [];
                }
            }
        }
    }

    Process {
        id: actProc

        property string output: ""

        stdout: StdioCollector { onStreamFinished: actProc.output += text }
        stderr: StdioCollector { onStreamFinished: actProc.output += text }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.lastError = actProc.output.trim() || "Drive operation failed";
            actProc.output = "";
            root.busyPath = "";
            root.refresh();
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
