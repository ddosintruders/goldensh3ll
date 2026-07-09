// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components

Card {
    id: root

    property string title: ""
    default property alias content: inner.data

    implicitHeight: wrap.implicitHeight + 28

    Column {
        id: wrap
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        StyledText {
            visible: root.title !== ""
            text: root.title.toUpperCase()
            font.pixelSize: Theme.fontXs
            font.weight: Font.DemiBold
            color: Theme.fgMuted
        }

        Column {
            id: inner
            width: parent.width
            spacing: 6
        }
    }
}
