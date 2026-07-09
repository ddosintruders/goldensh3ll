// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    property string expanded: ""
    property bool showAll: false

    Component.onCompleted: DefaultApps.refresh()

    component AppPicker: Column {
        id: picker

        property string kind
        property string label
        property var currentEntry: null

        signal pick(var entry)

        width: parent.width
        spacing: 2

        SettingRow {
            label: picker.label

            Image {
                visible: picker.currentEntry !== null
                anchors.verticalCenter: parent.verticalCenter
                width: 20
                height: 20
                sourceSize: Qt.size(40, 40)
                source: picker.currentEntry !== null
                    ? AppSearch.iconFor(picker.currentEntry, "") : ""
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: picker.currentEntry !== null ? picker.currentEntry.name : "Not set"
                color: Theme.fgDim
            }
            GButton {
                anchors.verticalCenter: parent.verticalCenter
                text: page.expanded === picker.kind ? "Close" : "Change"
                compact: true
                onClicked: {
                    page.showAll = false;
                    page.expanded = page.expanded === picker.kind ? "" : picker.kind;
                }
            }
        }

        Column {
            visible: page.expanded === picker.kind
            width: parent.width
            spacing: 2

            Repeater {
                model: page.expanded === picker.kind
                    ? (page.showAll ? AppSearch.all : DefaultApps.candidates(picker.kind))
                    : []

                ListButton {
                    required property var modelData
                    width: parent.width
                    label: modelData.name
                    hint: picker.currentEntry !== null
                          && modelData.id === picker.currentEntry.id ? "current" : ""
                    onClicked: {
                        picker.pick(modelData);
                        page.expanded = "";
                    }
                }
            }

            GButton {
                text: page.showAll ? "Show suggested" : "Show all apps"
                kind: "ghost"
                compact: true
                onClicked: page.showAll = !page.showAll
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Default applications"

        AppPicker {
            kind: "web"
            label: "Web browser"
            currentEntry: DefaultApps.webEntry
            onPick: entry => DefaultApps.setWeb(entry)
        }
        AppPicker {
            kind: "mail"
            label: "E-mail"
            currentEntry: DefaultApps.mailEntry
            onPick: entry => DefaultApps.setMail(entry)
        }
        AppPicker {
            kind: "photo"
            label: "Photos"
            currentEntry: DefaultApps.photoEntry
            onPick: entry => DefaultApps.setPhotos(entry)
        }
        AppPicker {
            kind: "video"
            label: "Videos"
            currentEntry: DefaultApps.videoEntry
            onPick: entry => DefaultApps.setVideos(entry)
        }
    }

    StyledText {
        width: parent.width
        text: "Choices are written through xdg-settings and xdg-mime, so every application and tool on the system honors them — including the taskbar web search."
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
        wrapMode: Text.WordWrap
    }
}
