// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The user's avatar: chosen image or preset, falling back to an
// accent-colored initial.

import QtQuick
import Quickshell.Widgets
import qs.config
import qs.services

Item {
    id: root

    property real size: 36

    implicitWidth: size
    implicitHeight: size

    ClippingRectangle {
        anchors.fill: parent
        radius: root.size / 2
        color: Theme.accent

        Image {
            anchors.fill: parent
            visible: Profile.hasAvatar
            source: Profile.avatarSource
            fillMode: Image.PreserveAspectCrop
            sourceSize: Qt.size(root.size * 2, root.size * 2)
        }

        StyledText {
            anchors.centerIn: parent
            visible: !Profile.hasAvatar
            text: Profile.initial
            color: Theme.onAccent
            font.pixelSize: root.size * 0.42
            font.weight: Font.DemiBold
        }
    }
}
