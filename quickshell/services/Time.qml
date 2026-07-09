// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property date now: clock.date
    readonly property string time: Settings.data.clock24h
        ? Qt.formatDateTime(clock.date, "HH:mm")
        : Qt.formatDateTime(clock.date, "h:mm AP")
    readonly property string dateShort: Qt.formatDateTime(clock.date, "MM/dd/yyyy")
    readonly property string dateLong: Qt.formatDateTime(clock.date, "dddd, MMMM d")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
