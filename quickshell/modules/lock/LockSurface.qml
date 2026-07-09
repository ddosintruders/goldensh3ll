// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Visual content of the lockscreen: blurred wallpaper, clock, user badge,
// password entry with PAM feedback, media mini-player and power actions.

import QtQuick
import QtQuick.Effects
import Quickshell
import qs.config
import qs.components
import qs.services

Item {
    id: root

    property var context
    property string screenName: ""

    readonly property string wallpaper: Wallpapers.lockWallpaperFor(screenName)

    // ------------------------------------------------------------ background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: "#16181d" }
            GradientStop { position: 1; color: "#0c0d10" }
        }
    }

    Image {
        id: bgImage
        anchors.fill: parent
        source: root.wallpaper !== "" ? "file://" + root.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        visible: false
        cache: false
    }

    MultiEffect {
        anchors.fill: parent
        source: bgImage
        visible: bgImage.status === Image.Ready
        blurEnabled: true
        blur: 1
        blurMax: 48
        autoPaddingEnabled: false
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    // --------------------------------------------------------- battery pill
    Rectangle {
        visible: Battery.present
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 28
        width: battRow.implicitWidth + 26
        height: 34
        radius: height / 2
        color: Qt.rgba(0, 0, 0, 0.35)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.14)

        Row {
            id: battRow
            anchors.centerIn: parent
            spacing: 8

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: Battery.iconName()
                size: 14
                color: Battery.critical ? Theme.danger : "#ffffff"
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Battery.percentInt + "%"
                color: "#ffffff"
                font.pixelSize: Theme.fontSm
                font.weight: Font.Medium
            }
        }
    }

    // ----------------------------------------------------------------- clock
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.14
        spacing: 6

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.time
            color: "#ffffff"
            font.pixelSize: 92
            font.weight: Font.Light
        }
        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Time.dateLong
            color: Qt.rgba(1, 1, 1, 0.75)
            font.pixelSize: Theme.fontXl
            font.weight: Font.Medium
        }
    }

    // ------------------------------------------------------------ auth panel
    Column {
        id: authPanel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: shakeOffset
        y: parent.height * 0.52
        spacing: 14

        property real shakeOffset: 0

        SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: authPanel; property: "shakeOffset"; to: -14; duration: 50 }
            NumberAnimation { target: authPanel; property: "shakeOffset"; to: 12; duration: 50 }
            NumberAnimation { target: authPanel; property: "shakeOffset"; to: -8; duration: 50 }
            NumberAnimation { target: authPanel; property: "shakeOffset"; to: 5; duration: 50 }
            NumberAnimation { target: authPanel; property: "shakeOffset"; to: 0; duration: 50 }
        }

        Connections {
            target: root.context
            function onFailed() { shakeAnim.restart(); }
        }

        AvatarBadge {
            anchors.horizontalCenter: parent.horizontalCenter
            size: 76
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Profile.displayName
            color: "#ffffff"
            font.pixelSize: Theme.fontLg
            font.weight: Font.DemiBold
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 44
            radius: height / 2
            color: Qt.rgba(1, 1, 1, 0.10)
            border.width: 1
            border.color: passwordInput.activeFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.22)

            Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

            Icon {
                id: lockIcon
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                name: "lock"
                size: 14
                color: Qt.rgba(1, 1, 1, 0.6)
            }

            TextInput {
                id: passwordInput
                anchors.left: lockIcon.right
                anchors.leftMargin: 10
                anchors.right: submitArea.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                focus: true
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: "#ffffff"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontMd
                clip: true
                enabled: root.context ? !root.context.unlocking : true

                onTextChanged: {
                    if (root.context && root.context.currentText !== text)
                        root.context.currentText = text;
                }
                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        if (root.context.currentText !== passwordInput.text)
                            passwordInput.text = root.context.currentText;
                    }
                }

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: passwordInput.text.length === 0
                    text: "Enter password"
                    color: Qt.rgba(1, 1, 1, 0.45)
                }
            }

            Item {
                id: submitArea
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: submitMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.10)
                    visible: !root.context.unlocking

                    Icon {
                        anchors.centerIn: parent
                        name: "arrow-right"
                        size: 14
                        color: "#ffffff"
                    }

                    MouseArea {
                        id: submitMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.context.tryUnlock()
                    }
                }

                Icon {
                    id: spinner
                    anchors.centerIn: parent
                    visible: root.context.unlocking
                    name: "loader-circle"
                    size: 16
                    color: "#ffffff"

                    RotationAnimation on rotation {
                        running: root.context.unlocking
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 900
                    }
                }
            }
        }

        StyledText {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.context.showFailure && root.context.message !== ""
            text: root.context.message
            color: Theme.danger
            font.pixelSize: Theme.fontSm
            font.weight: Font.Medium
        }
    }

    // ------------------------------------------------------- media mini card
    Rectangle {
        visible: Media.hasPlayer
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        width: 300
        height: 62
        radius: Theme.radiusMd
        color: Qt.rgba(0, 0, 0, 0.4)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)

        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                name: "music"
                size: 18
                color: Qt.rgba(1, 1, 1, 0.7)
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 100
                spacing: 1

                StyledText {
                    width: parent.width
                    text: Media.title || "Nothing playing"
                    color: "#ffffff"
                    font.pixelSize: Theme.fontSm
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
                StyledText {
                    width: parent.width
                    visible: Media.artist !== ""
                    text: Media.artist
                    color: Qt.rgba(1, 1, 1, 0.6)
                    font.pixelSize: Theme.fontXs
                    elide: Text.ElideRight
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                GIconButton {
                    icon: Media.playing ? "pause" : "play"
                    buttonSize: 28
                    iconSize: 13
                    iconColor: "#ffffff"
                    onClicked: Media.toggle()
                }
                GIconButton {
                    icon: "skip-forward"
                    buttonSize: 28
                    iconSize: 13
                    iconColor: "#ffffff"
                    onClicked: Media.next()
                }
            }
        }
    }

    // ---------------------------------------------------------- power strip
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28
        spacing: 10

        component PowerButton: Rectangle {
            id: pb

            property string icon
            signal clicked()

            width: 44
            height: 44
            radius: width / 2
            color: pbMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.14)

            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            Icon {
                anchors.centerIn: parent
                name: pb.icon
                size: 17
                color: "#ffffff"
            }

            MouseArea {
                id: pbMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: pb.clicked()
            }
        }

        PowerButton {
            icon: "moon"
            onClicked: Session.suspend()
        }
        PowerButton {
            icon: "rotate-ccw"
            onClicked: Session.reboot()
        }
        PowerButton {
            icon: "power"
            onClicked: Session.poweroff()
        }
    }
}
