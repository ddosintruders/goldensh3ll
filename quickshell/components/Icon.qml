// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Renders a bundled Lucide SVG (assets/icons) tinted to any color.

import QtQuick
import QtQuick.Effects
import qs.config

Item {
    id: root

    property string name
    property real size: 16
    property color color: Theme.fg

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        source: root.name ? Qt.resolvedUrl("../assets/icons/" + root.name + ".svg") : ""
        sourceSize: Qt.size(Math.round(root.size * 2), Math.round(root.size * 2))
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: img
        colorization: 1
        colorizationColor: root.color
    }
}
