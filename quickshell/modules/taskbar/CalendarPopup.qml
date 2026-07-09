// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Month calendar attached to the taskbar clock.

import QtQuick
import qs.config
import qs.components
import qs.services

PopupPanel {
    id: root

    panelWidth: 300
    panelPadding: 14
    fromTop: false

    property int displayYear: 2026
    property int displayMonth: 0

    function goToday() {
        const now = new Date();
        displayYear = now.getFullYear();
        displayMonth = now.getMonth();
    }

    function shiftMonth(delta) {
        const d = new Date(displayYear, displayMonth + delta, 1);
        displayYear = d.getFullYear();
        displayMonth = d.getMonth();
    }

    function computeCells(year, month) {
        const first = new Date(year, month, 1);
        const start = 1 - first.getDay();   // week starts on Sunday
        const today = new Date();
        const cells = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(year, month, start + i);
            cells.push({
                day: d.getDate(),
                inMonth: d.getMonth() === month,
                today: d.getFullYear() === today.getFullYear()
                    && d.getMonth() === today.getMonth()
                    && d.getDate() === today.getDate()
            });
        }
        return cells;
    }

    readonly property var cells: computeCells(displayYear, displayMonth)

    onExpandChanged: if (expand) goToday()
    Component.onCompleted: goToday()

    Column {
        width: parent.width
        spacing: 10

        Row {
            width: parent.width

            Column {
                width: parent.width - 66
                spacing: 0

                StyledText {
                    text: Qt.formatDateTime(new Date(root.displayYear, root.displayMonth, 1), "MMMM yyyy")
                    font.weight: Font.DemiBold
                    font.pixelSize: Theme.fontLg
                }
                StyledText {
                    text: Time.dateLong
                    font.pixelSize: Theme.fontSm
                    color: Theme.accent
                }
            }

            Row {
                spacing: 2

                GIconButton {
                    icon: "chevron-left"
                    buttonSize: 26
                    iconSize: 14
                    onClicked: root.shiftMonth(-1)
                }
                GIconButton {
                    icon: "chevron-right"
                    buttonSize: 26
                    iconSize: 14
                    onClicked: root.shiftMonth(1)
                }
            }
        }

        Grid {
            columns: 7
            width: parent.width

            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                Item {
                    required property string modelData
                    width: parent.width / 7
                    height: 22

                    StyledText {
                        anchors.centerIn: parent
                        text: parent.modelData
                        font.pixelSize: Theme.fontXs
                        font.weight: Font.DemiBold
                        color: Theme.fgMuted
                    }
                }
            }
        }

        Grid {
            columns: 7
            width: parent.width

            Repeater {
                model: root.cells

                Item {
                    id: dayCell

                    required property var modelData

                    width: parent.width / 7
                    height: 30

                    Rectangle {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: width / 2
                        color: dayCell.modelData.today ? Theme.accent : "transparent"

                        StyledText {
                            anchors.centerIn: parent
                            text: dayCell.modelData.day
                            font.pixelSize: Theme.fontSm
                            font.weight: dayCell.modelData.today ? Font.DemiBold : Font.Normal
                            color: dayCell.modelData.today ? Theme.onAccent
                                 : dayCell.modelData.inMonth ? Theme.fg : Theme.fgMuted
                        }
                    }
                }
            }
        }

        Row {
            width: parent.width

            Item { width: parent.width - todayBtn.width; height: 1 }

            GButton {
                id: todayBtn
                text: "Today"
                kind: "ghost"
                compact: true
                onClicked: root.goToday()
            }
        }
    }
}
