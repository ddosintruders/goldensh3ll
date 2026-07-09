// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config

Text {
    id: root

    // Optional type-ramp role from Theme (e.g. Theme.typeOverline).
    property var role: null

    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: role !== null ? role.size : Theme.fontMd
    font.weight: role !== null ? role.weight : Font.Normal
    font.letterSpacing: role !== null && role.spacing !== undefined ? role.spacing : 0
    verticalAlignment: Text.AlignVCenter
}
