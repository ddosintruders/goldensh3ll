// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Now-playing flyout with album art, progress and transport controls.

import QtQuick
import Quickshell.Widgets
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 360
    panelPadding: 14

    Timer {
        interval: 1000
        running: root.expand && Media.hasPlayer
        repeat: true
        triggeredOnStart: true
        onTriggered: Media.pollProgress()
    }

    Column {
        width: parent.width
        spacing: 12

        Row {
            width: parent.width
            spacing: 12

            ClippingRectangle {
                width: 64
                height: 64
                radius: Theme.radiusSm
                color: Theme.surfaceHover

                Image {
                    anchors.fill: parent
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    visible: Media.artUrl !== ""
                }
                Icon {
                    anchors.centerIn: parent
                    visible: Media.artUrl === ""
                    name: "music"
                    size: 26
                    color: Theme.fgMuted
                }
            }

            Column {
                width: parent.width - 76
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                ScrollingText {
                    width: parent.width
                    text: Media.title || "Nothing playing"
                    weight: Font.DemiBold
                    pixelSize: Theme.fontLg
                }
                ScrollingText {
                    width: parent.width
                    visible: Media.artist !== ""
                    text: Media.artist
                    color: Theme.fgDim
                }
                StyledText {
                    width: parent.width
                    visible: Media.appName !== ""
                    text: Media.appName
                    color: Theme.fgMuted
                    font.pixelSize: Theme.fontSm
                    elide: Text.ElideRight
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: Theme.surfaceActive

            Rectangle {
                width: parent.width * Media.progress
                height: parent.height
                radius: parent.radius
                color: Theme.accent

                Behavior on width { NumberAnimation { duration: 400 } }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 14

            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip-back"
                buttonSize: 34
                onClicked: Media.previous()
            }
            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: Media.playing ? "pause" : "play"
                buttonSize: 42
                iconSize: 18
                active: true
                onClicked: Media.toggle()
            }
            GIconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "skip-forward"
                buttonSize: 34
                onClicked: Media.next()
            }
        }
    }
}
