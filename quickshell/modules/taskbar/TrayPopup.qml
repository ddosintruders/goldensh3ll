// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Expanded system tray grid, mirroring the collapsed taskbar area.

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.config
import qs.components

PopupPanel {
    id: root

    panelWidth: 240
    panelPadding: 12
    fromTop: false

    QsMenuAnchor {
        id: popupTrayMenu
        anchor.window: root
        anchor.edges: Edges.Top
        anchor.gravity: Edges.Top
    }

    Column {
        width: parent.width
        spacing: 10

        StyledText {
            text: "SYSTEM TRAY APPLICATIONS"
            font.pixelSize: Theme.fontXs
            font.weight: Font.DemiBold
            color: Theme.fgMuted
        }

        Flow {
            width: parent.width
            spacing: 6

            Repeater {
                model: SystemTray.items

                Rectangle {
                    id: cell

                    required property var modelData

                    width: 40
                    height: 40
                    radius: Theme.radiusSm
                    color: cellMouse.containsMouse ? Theme.surfaceHover : Theme.surface
                    border.width: 1
                    border.color: Theme.border

                    Image {
                        anchors.centerIn: parent
                        width: 20
                        height: 20
                        sourceSize: Qt.size(40, 40)
                        source: cell.modelData.icon
                    }

                    MouseArea {
                        id: cellMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        onClicked: event => {
                            if (event.button === Qt.RightButton || cell.modelData.onlyMenu) {
                                if (cell.modelData.hasMenu) {
                                    popupTrayMenu.menu = cell.modelData.menu;
                                    const pos = cell.mapToItem(null, cell.width / 2, 0);
                                    popupTrayMenu.anchor.rect.x = pos.x;
                                    popupTrayMenu.anchor.rect.y = pos.y;
                                    popupTrayMenu.anchor.rect.width = 1;
                                    popupTrayMenu.anchor.rect.height = 1;
                                    popupTrayMenu.open();
                                }
                            } else if (event.button === Qt.MiddleButton) {
                                cell.modelData.secondaryActivate();
                            } else {
                                cell.modelData.activate();
                                root.close();
                            }
                        }
                    }
                }
            }
        }

        StyledText {
            visible: SystemTray.items.values.length === 0
            text: "No tray applications"
            color: Theme.fgMuted
            font.pixelSize: Theme.fontSm
        }
    }
}
