// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// NetworkManager integration through nmcli (status polling, wifi list,
// connect). All commands run without a shell so SSIDs need no escaping.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property bool wifiEnabled: true
    property bool connected: false
    property string type: ""        // "wifi" | "ethernet" | ""
    property string connectionName: ""
    property int strength: 0
    property var networks: []       // { ssid, strength, secure, inUse }
    property bool scanning: false
    property string connectingSsid: ""
    property string lastError: ""

    function iconName() {
        if (!connected) return "wifi-off";
        if (type === "ethernet") return "network";
        if (strength >= 66) return "wifi";
        if (strength >= 33) return "wifi-high";
        if (strength > 5) return "wifi-low";
        return "wifi-zero";
    }

    // Saved connection profiles (for Forget availability).
    property var savedConnections: []

    function isSaved(ssid) {
        return savedConnections.indexOf(ssid) !== -1;
    }

    function disconnectWifi() {
        if (!connected || connectionName === "")
            return;
        Quickshell.execDetached(["nmcli", "connection", "down", "id", connectionName]);
        refreshDelay.restart();
    }

    function forget(ssid) {
        if (!ssid)
            return;
        Quickshell.execDetached(["nmcli", "connection", "delete", "id", ssid]);
        refreshDelay.restart();
    }

    function refresh() {
        statusProc.running = true;
        if (available) {
            savedProc.running = true;
            if (wifiEnabled)
                listProc.running = true;
        }
    }

    function rescan() {
        if (!available || !wifiEnabled) return;
        scanning = true;
        rescanProc.running = true;
    }

    function toggleWifi() {
        if (!available) return;
        Quickshell.execDetached(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"]);
        wifiEnabled = !wifiEnabled;
        if (!wifiEnabled) networks = [];
        refreshDelay.restart();
    }

    function connectTo(ssid, password) {
        if (!available || !ssid) return;
        lastError = "";
        connectingSsid = ssid;
        connProc.command = password && password.length > 0
            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
            : ["nmcli", "device", "wifi", "connect", ssid];
        connProc.running = true;
    }

    function parseStatus(text) {
        if (text.indexOf("NONM") !== -1) { available = false; return; }
        available = true;
        connected = false;
        type = "";
        connectionName = "";
        for (const line of text.trim().split("\n")) {
            if (line.startsWith("RADIO=")) {
                wifiEnabled = line.substring(6).trim() === "enabled";
                continue;
            }
            const f = line.split(":");
            if (f.length >= 3 && f[1] === "connected" && (f[0] === "wifi" || f[0] === "ethernet")) {
                // Prefer wifi info only if nothing found yet; ethernet wins.
                if (!connected || f[0] === "ethernet") {
                    connected = true;
                    type = f[0];
                    connectionName = f.slice(2).join(":");
                }
            }
        }
    }

    function parseList(text) {
        const seen = {};
        const list = [];
        for (const line of text.trim().split("\n")) {
            if (!line) continue;
            const f = line.split(":");
            if (f.length < 4) continue;
            const inUse = f[0] === "*";
            const sig = parseInt(f[1]) || 0;
            const secure = f[2] !== "" && f[2] !== "--";
            const ssid = f.slice(3).join(":").replace(/\\:/g, ":");
            if (!ssid) continue;
            if (seen[ssid] !== undefined) {
                if (sig > list[seen[ssid]].strength) list[seen[ssid]].strength = sig;
                if (inUse) list[seen[ssid]].inUse = true;
                continue;
            }
            seen[ssid] = list.length;
            list.push({ ssid: ssid, strength: sig, secure: secure, inUse: inUse });
        }
        list.sort((a, b) => (b.inUse - a.inUse) || (b.strength - a.strength));
        networks = list;
        const current = list.find(n => n.inUse);
        strength = current ? current.strength : 0;
    }

    Process {
        id: statusProc
        command: ["sh", "-c",
            "command -v nmcli >/dev/null 2>&1 || { echo NONM; exit 0; }; " +
            "echo RADIO=$(nmcli radio wifi); nmcli -t -f TYPE,STATE,CONNECTION device status"]
        stdout: StdioCollector { onStreamFinished: root.parseStatus(text) }
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "IN-USE,SIGNAL,SECURITY,SSID", "device", "wifi", "list"]
        stdout: StdioCollector { onStreamFinished: root.parseList(text) }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.savedConnections = t.length > 0
                    ? t.split("\n").map(l => l.replace(/\\:/g, ":"))
                    : [];
            }
        }
    }

    Process {
        id: rescanProc
        command: ["sh", "-c", "nmcli device wifi rescan 2>/dev/null; sleep 2"]
        onExited: {
            root.scanning = false;
            root.refresh();
        }
    }

    Process {
        id: connProc
        stderr: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                if (t) root.lastError = t;
            }
        }
        onExited: {
            root.connectingSsid = "";
            root.refresh();
        }
    }

    Timer {
        id: refreshDelay
        interval: 2000
        onTriggered: root.refresh()
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
