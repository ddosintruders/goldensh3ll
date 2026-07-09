// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Scrollable page scaffold for the settings window.

import QtQuick

Flickable {
    id: root

    default property alias content: col.data

    contentHeight: col.implicitHeight + 8
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: col
        // Readability cap, Windows-Settings style.
        width: Math.min(root.width, 640)
        spacing: 14
    }
}
