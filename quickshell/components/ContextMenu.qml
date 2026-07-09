// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Small right-click menu on the popup overlay pattern; fill with
// ListButton children.

import QtQuick
import qs.config

PopupPanel {
    id: root

    panelWidth: 200
    panelPadding: 6
    default property alias items: col.data

    Column {
        id: col
        width: parent.width
        spacing: 2
    }
}
