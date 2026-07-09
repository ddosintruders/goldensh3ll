// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Styled single-line text field (no QtQuick.Controls dependency).

import QtQuick
import qs.config

Rectangle {
    id: root

    property alias text: input.text
    property alias input: input
    property alias echoMode: input.echoMode
    property string placeholder: ""
    property string leadingIcon: ""

    signal accepted()
    signal editingFinished()

    implicitHeight: 34
    implicitWidth: 220
    radius: Theme.radiusSm
    color: Theme.surface
    border.width: 1
    border.color: input.activeFocus ? Theme.accent : Theme.border

    Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 7

        Icon {
            visible: root.leadingIcon !== ""
            anchors.verticalCenter: parent.verticalCenter
            name: root.leadingIcon
            size: 14
            color: Theme.fgMuted
        }

        Item {
            width: parent.width - (root.leadingIcon !== "" ? 21 : 0)
            height: parent.height

            TextInput {
                id: input
                anchors.fill: parent
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontMd
                selectionColor: Theme.accent
                selectedTextColor: Theme.onAccent
                clip: true
                onAccepted: root.accepted()
                onEditingFinished: root.editingFinished()
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                visible: input.text.length === 0 && !input.activeFocus
                text: root.placeholder
                color: Theme.fgMuted
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.IBeamCursor
        acceptedButtons: Qt.LeftButton
        onClicked: input.forceActiveFocus()
    }
}
