// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Shared authentication state for all lock surfaces (one per monitor),
// so typing on one monitor is reflected on every surface.

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()
    signal failed()

    property string currentText: ""
    property bool unlocking: false
    property string message: ""
    property bool showFailure: false

    function reset() {
        currentText = "";
        unlocking = false;
        message = "";
        showFailure = false;
    }

    function tryUnlock() {
        if (currentText.length === 0 || unlocking)
            return;
        unlocking = true;
        showFailure = false;
        message = "";
        pam.start();
    }

    PamContext {
        id: pam

        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root.currentText);
            else if (pam.messageIsError)
                root.message = pam.message;
        }

        onCompleted: result => {
            root.unlocking = false;
            if (result === PamResult.Success) {
                root.reset();
                root.unlocked();
            } else {
                root.currentText = "";
                root.showFailure = true;
                if (root.message.length === 0)
                    root.message = "Incorrect password. Try again.";
                root.failed();
            }
        }
    }
}
