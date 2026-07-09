// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Hybrid Bluetooth backend: Quickshell's native BlueZ integration provides
// live STATE (adapter power, discovery, device list, connected/paired),
// while ACTIONS run through bluetoothctl — pairing needs a BlueZ agent,
// which bluetoothctl registers and Quickshell does not.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: root

    // Address currently being acted on ("" when idle) + last failure text.
    property string busyAddress: ""
    property string busyAction: ""
    property string lastError: ""

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool powered: available && adapter.enabled
    readonly property bool discovering: available && adapter.discovering

    readonly property var devices: {
        if (!available)
            return [];
        // Device list lives on the Bluetooth singleton (not the adapter).
        const list = [...Bluetooth.devices.values];
        list.sort((a, b) => (b.connected - a.connected)
                         || (b.paired - a.paired)
                         || (a.name || "").localeCompare(b.name || ""));
        return list;
    }
    readonly property var pairedDevices: devices.filter(d => d.paired || d.connected)
    readonly property var discoveredDevices:
        devices.filter(d => !d.paired && !d.connected && d.name && d.name.length > 0)
    readonly property int connectedCount: devices.filter(d => d.connected).length

    function toggle() {
        if (available)
            adapter.enabled = !adapter.enabled;
    }

    function setPowered(on) {
        if (available)
            adapter.enabled = on;
    }

    function setDiscovering(on) {
        if (!available)
            return;
        if (on && !adapter.enabled)
            adapter.enabled = true;
        adapter.discovering = on;
    }

    // ------------------------------------------------ actions (bluetoothctl)
    function runAction(action, address, script) {
        if (busyAddress !== "" || !address)
            return;
        lastError = "";
        busyAddress = address;
        busyAction = action;
        actionProc.command = ["sh", "-c", script, "gs-bt", address];
        actionProc.running = true;
    }

    // Full pairing flow: pair, trust (so BlueZ auto-accepts the profile
    // connection), then connect.
    function pairDevice(device) {
        runAction("pair", device.address,
            'bluetoothctl --timeout 30 pair "$1" && bluetoothctl trust "$1" && bluetoothctl connect "$1"');
    }

    function connectDevice(device) {
        runAction("connect", device.address, 'bluetoothctl connect "$1"');
    }

    function disconnectDevice(device) {
        runAction("disconnect", device.address, 'bluetoothctl disconnect "$1"');
    }

    function forgetDevice(device) {
        runAction("remove", device.address, 'bluetoothctl remove "$1"');
    }

    Process {
        id: actionProc

        property string output: ""

        stdout: StdioCollector {
            onStreamFinished: actionProc.output += text
        }
        stderr: StdioCollector {
            onStreamFinished: actionProc.output += text
        }
        onExited: exitCode => {
            if (exitCode !== 0) {
                const lines = output.split("\n").filter(l =>
                    /fail|error|not available|not ready/i.test(l));
                root.lastError = lines.length > 0
                    ? lines[lines.length - 1].trim()
                    : "Bluetooth " + root.busyAction + " failed";
            }
            output = "";
            root.busyAddress = "";
            root.busyAction = "";
        }
    }

    // Maps a BlueZ device icon name onto a bundled Lucide glyph.
    function iconFor(device) {
        const ic = (device && device.icon) ? device.icon : "";
        if (ic.indexOf("audio") !== -1 || ic.indexOf("head") !== -1) return "headphones";
        if (ic.indexOf("phone") !== -1) return "smartphone";
        if (ic.indexOf("keyboard") !== -1) return "keyboard";
        if (ic.indexOf("mouse") !== -1) return "mouse";
        if (ic.indexOf("game") !== -1 || ic.indexOf("joystick") !== -1) return "gamepad-2";
        if (ic.indexOf("watch") !== -1) return "watch";
        if (ic.indexOf("printer") !== -1) return "printer";
        if (ic.indexOf("display") !== -1 || ic.indexOf("video") !== -1) return "tv";
        return "bluetooth";
    }

    function statusText(device) {
        if (!device) return "";
        if (device.address === busyAddress) {
            switch (busyAction) {
            case "pair": return "Pairing…";
            case "connect": return "Connecting…";
            case "disconnect": return "Disconnecting…";
            case "remove": return "Removing…";
            }
        }
        if (device.connected) {
            let s = "Connected";
            if (device.batteryAvailable)
                s += " · " + Math.round(device.battery * 100) + "%";
            return s;
        }
        if (device.paired) return "Paired";
        return "Discovered";
    }
}
