// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Label + optional description on the left, arbitrary control on the right.

import QtQuick
import qs.config
import qs.components

Item {
    id: root

    property string label
    property string sublabel: ""
    default property alias control: slot.data

    width: parent.width
    implicitHeight: Math.max(40, textCol.implicitHeight + 12, slot.implicitHeight + 12)

    Column {
        id: textCol
        anchors.left: parent.left
        anchors.right: slot.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        StyledText {
            width: parent.width
            text: root.label
            font.weight: Font.Medium
            elide: Text.ElideRight
        }
        StyledText {
            width: parent.width
            visible: root.sublabel !== ""
            text: root.sublabel
            font.pixelSize: Theme.fontSm
            color: Theme.fgMuted
            wrapMode: Text.WordWrap
        }
    }

    Row {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
    }
}
