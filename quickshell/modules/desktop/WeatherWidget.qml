// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

Rectangle {
    width: 270
    height: 130
    radius: Theme.radiusLg
    color: Theme.popupBg
    border.width: 1
    border.color: Theme.popupBorder

    Component.onCompleted: Weather.refresh()

    StyledText {
        visible: !Weather.configured
        anchors.centerIn: parent
        width: parent.width - 36
        horizontalAlignment: Text.AlignHCenter
        text: "Set a location in\nSettings → Desktop & Widgets"
        font.pixelSize: Theme.fontSm
        color: Theme.fgMuted
        wrapMode: Text.WordWrap
    }

    Item {
        visible: Weather.configured
        anchors.fill: parent
        anchors.margins: 16

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            StyledText {
                text: Weather.hasData ? Math.round(Weather.temp) + Weather.unit : "—"
                font.pixelSize: 34
                font.weight: Font.Light
            }
            StyledText {
                text: Weather.condition
                font.pixelSize: Theme.fontSm
                color: Theme.fgDim
            }
            Row {
                spacing: 4

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: "map-pin"
                    size: 10
                    color: Theme.fgMuted
                }
                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Weather.place
                    font.pixelSize: Theme.fontXs
                    color: Theme.fgMuted
                    width: 130
                    elide: Text.ElideRight
                }
            }
        }

        WeatherScene {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 96
            height: 96
            kind: Weather.kind
        }
    }
}
