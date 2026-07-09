// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Connected accounts registry: records which accounts belong to which
// services (display + organization only — no credentials are stored and
// no sign-in happens here; deep OAuth integration is a future topic).

import QtQuick
import qs.config
import qs.components
import qs.services

SettingsPage {
    id: page

    property string newService: "Google"

    readonly property var services: ["Google", "Apple", "Microsoft", "GitHub", "Other"]

    function iconFor(service) {
        switch (service) {
        case "Google": return "globe";
        case "Apple": return "smartphone";
        case "Microsoft": return "layout-grid";
        case "GitHub": return "external-link";
        }
        return "circle-user-round";
    }

    SettingsGroup {
        width: parent.width
        title: "Connected accounts"

        StyledText {
            width: parent.width
            text: "Keep track of which accounts you use per service. This is a local registry — nothing is signed in and no credentials are stored."
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
            wrapMode: Text.WordWrap
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: Settings.data.accounts

                Item {
                    id: accountRow

                    required property string modelData

                    readonly property int sep: modelData.indexOf("::")
                    readonly property string service: sep > 0 ? modelData.substring(0, sep) : "Other"
                    readonly property string identifier: sep > 0 ? modelData.substring(sep + 2) : modelData

                    width: parent.width
                    height: 44

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 30
                            height: 30
                            radius: Theme.radiusSm
                            color: Theme.surfaceHover

                            Icon {
                                anchors.centerIn: parent
                                name: page.iconFor(accountRow.service)
                                size: 14
                                color: Theme.fgDim
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            StyledText {
                                text: accountRow.identifier
                                font.weight: Font.Medium
                            }
                            StyledText {
                                text: accountRow.service
                                font.pixelSize: Theme.fontXs
                                color: Theme.fgMuted
                            }
                        }
                    }

                    GIconButton {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "trash-2"
                        buttonSize: 26
                        iconSize: 13
                        iconColor: Theme.danger
                        onClicked: Settings.data.accounts =
                            Settings.data.accounts.filter(a => a !== accountRow.modelData)
                    }
                }
            }

            StyledText {
                visible: Settings.data.accounts.length === 0
                text: "No accounts added"
                color: Theme.fgMuted
                font.pixelSize: Theme.fontSm
            }
        }
    }

    SettingsGroup {
        width: parent.width
        title: "Add account"

        SettingRow {
            label: "Service"

            Row {
                spacing: 6

                Repeater {
                    model: page.services

                    GButton {
                        required property string modelData
                        text: modelData
                        compact: true
                        kind: page.newService === modelData ? "filled" : "tonal"
                        onClicked: page.newService = modelData
                    }
                }
            }
        }

        SettingRow {
            label: "Identifier"
            sublabel: "E-mail address, ID or username"

            GTextField {
                id: idField
                width: 240
                leadingIcon: "circle-user-round"
                placeholder: "example1@gmail.com"
            }
            GButton {
                text: "Add"
                kind: "filled"
                compact: true
                enabled: idField.text.trim().length > 0
                onClicked: {
                    const entry = page.newService + "::" + idField.text.trim();
                    if (Settings.data.accounts.indexOf(entry) === -1)
                        Settings.data.accounts = [...Settings.data.accounts, entry];
                    idField.text = "";
                }
            }
        }
    }
}
