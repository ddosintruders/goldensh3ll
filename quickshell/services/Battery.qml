// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device !== null && device.isLaptopBattery
    readonly property real percent: device ? device.percentage : 0
    readonly property int percentInt: Math.round(percent * 100)
    readonly property bool charging: device
        ? (device.state === UPowerDeviceState.Charging
           || device.state === UPowerDeviceState.FullyCharged
           || device.state === UPowerDeviceState.PendingCharge)
        : false
    readonly property bool low: !charging && percentInt <= 20
    readonly property bool critical: !charging && percentInt <= 10

    readonly property string timeText: {
        if (!device) return "";
        if (charging && device.timeToFull > 0)
            return format(device.timeToFull) + " until full";
        if (!charging && device.timeToEmpty > 0)
            return format(device.timeToEmpty) + " remaining";
        return "";
    }

    function format(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    function iconName() {
        if (charging) return "battery-charging";
        if (percentInt <= 10) return "battery-warning";
        if (percentInt <= 30) return "battery-low";
        if (percentInt <= 65) return "battery-medium";
        return "battery-full";
    }
}
