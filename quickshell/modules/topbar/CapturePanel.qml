// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Screenshot & screen-recording panel inside the control center.
// Screenshot actions emit a signal so the control center can close
// itself first (the overlay must unmap before grim captures).

import QtQuick
import qs.config
import qs.components
import qs.services

Column {
    id: root

    signal back()
    // kind: "full" | "region" | "area"; geometry only for "area".
    signal shotRequested(string kind, int x, int y, int w, int h)

    spacing: 10

    Item {
        width: parent.width
        height: 28

        GIconButton {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            icon: "arrow-left"
            buttonSize: 26
            iconSize: 14
            onClicked: root.back()
        }
        StyledText {
            anchors.left: parent.left
            anchors.leftMargin: 34
            anchors.verticalCenter: parent.verticalCenter
            text: "Capture"
            font.pixelSize: Theme.fontLg
            font.weight: Font.DemiBold
        }
    }

    StyledText {
        role: Theme.typeOverline
        text: "SCREENSHOT"
        color: Theme.fgMuted
    }

    StyledText {
        visible: !Capture.grimAvailable
        width: parent.width
        text: "Install grim (and slurp for region capture) to take screenshots."
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
        wrapMode: Text.WordWrap
    }

    Column {
        width: parent.width
        spacing: 2
        visible: Capture.grimAvailable

        ListButton {
            width: parent.width
            icon: "monitor"
            label: "Full screen"
            hint: "PrtSc"
            onClicked: root.shotRequested("full", 0, 0, 0, 0)
        }
        ListButton {
            width: parent.width
            icon: "crop"
            label: "Select region"
            hint: "Super+Shift+S"
            visible: Capture.slurpAvailable
            onClicked: root.shotRequested("region", 0, 0, 0, 0)
        }
    }

    // Manual geometry capture.
    Row {
        visible: Capture.grimAvailable
        width: parent.width
        spacing: 6

        GTextField { id: gx; width: 56; placeholder: "X"; text: "0" }
        GTextField { id: gy; width: 56; placeholder: "Y"; text: "0" }
        GTextField { id: gw; width: 64; placeholder: "W"; text: "800" }
        GTextField { id: gh; width: 64; placeholder: "H"; text: "600" }

        GButton {
            anchors.verticalCenter: gx.verticalCenter
            icon: "camera"
            text: "Capture"
            compact: true
            onClicked: {
                const x = parseInt(gx.text) || 0;
                const y = parseInt(gy.text) || 0;
                const w = parseInt(gw.text) || 0;
                const h = parseInt(gh.text) || 0;
                if (w > 0 && h > 0)
                    root.shotRequested("area", x, y, w, h);
            }
        }
    }

    Rectangle { width: parent.width; height: 1; color: Theme.border }

    StyledText {
        role: Theme.typeOverline
        text: "SCREEN RECORDING"
        color: Theme.fgMuted
    }

    StyledText {
        visible: !Capture.recorderAvailable
        width: parent.width
        text: "Install wf-recorder to record the screen."
        color: Theme.fgMuted
        font.pixelSize: Theme.fontSm
        wrapMode: Text.WordWrap
    }

    Row {
        visible: Capture.recorderAvailable
        spacing: 10

        GButton {
            icon: Capture.recording ? "x" : "video"
            text: Capture.recording
                ? "Stop recording  ·  " + Capture.recordTimeText
                : "Start recording"
            kind: Capture.recording ? "danger" : "filled"
            onClicked: Capture.toggleRecording()
        }
    }

    StyledText {
        visible: Capture.lastError !== ""
        width: parent.width
        text: Capture.lastError
        color: Theme.danger
        font.pixelSize: Theme.fontXs
        wrapMode: Text.WordWrap
    }

    StyledText {
        width: parent.width
        text: "Saved to ~/Pictures/Screenshots and ~/Videos/ScreenRecs"
        color: Theme.fgMuted
        font.pixelSize: Theme.fontXs
        wrapMode: Text.WordWrap
    }
}
