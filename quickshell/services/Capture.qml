// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Screenshot (grim/slurp) and screen recording (wf-recorder).
// Screenshots go to ~/Pictures/Screenshots, recordings to
// ~/Videos/ScreenRecs; a notification confirms every capture.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool grimAvailable: false
    property bool slurpAvailable: false
    property bool recorderAvailable: false

    property bool recording: false
    property int recordSeconds: 0
    property string lastError: ""

    readonly property string shotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
    readonly property string recDir: Quickshell.env("HOME") + "/Videos/ScreenRecs"

    readonly property string recordTimeText: {
        const m = Math.floor(recordSeconds / 60);
        const s = recordSeconds % 60;
        return m + ":" + (s < 10 ? "0" : "") + s;
    }

    function stamp() {
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
    }

    function screenshotFull() {
        runShot('grim "$1"');
    }

    // Interactive: user draws the region with the mouse (slurp).
    function screenshotRegion() {
        runShot('geom="$(slurp)"; [ -n "$geom" ] && grim -g "$geom" "$1"');
    }

    function screenshotArea(x, y, w, h) {
        runShot('grim -g "$2" "$1"', x + "," + y + " " + w + "x" + h);
    }

    function runShot(script, geom) {
        if (!grimAvailable)
            return;
        lastError = "";
        const file = shotDir + "/shot_" + stamp() + ".png";
        const cmd = ["sh", "-c",
            'mkdir -p "$(dirname "$1")"; ' + script +
            ' && notify-send "Screenshot saved" "$1" 2>/dev/null || true',
            "gs-shot", file];
        if (geom !== undefined)
            cmd.push(geom);
        Quickshell.execDetached(cmd);
    }

    function toggleRecording() {
        if (recording) {
            Quickshell.execDetached(["pkill", "-INT", "-x", "wf-recorder"]);
            return;
        }
        if (!recorderAvailable)
            return;
        lastError = "";
        const file = recDir + "/rec_" + stamp() + ".mp4";
        recProc.file = file;
        recProc.command = ["sh", "-c",
            'mkdir -p "$(dirname "$1")"; exec wf-recorder -f "$1"',
            "gs-rec", file];
        recProc.running = true;
        recording = true;
        recordSeconds = 0;
    }

    Process {
        id: recProc

        property string file: ""
        property string output: ""

        stderr: StdioCollector { onStreamFinished: recProc.output += text }
        onExited: exitCode => {
            root.recording = false;
            // SIGINT stop is the normal path; anything else is an error.
            if (exitCode !== 0 && root.recordSeconds < 1) {
                const lines = output.split("\n").filter(l => l.trim() !== "");
                root.lastError = lines.length > 0
                    ? lines[lines.length - 1].trim() : "Recording failed";
            } else {
                Quickshell.execDetached(["notify-send", "Recording saved", file]);
            }
            output = "";
        }
    }

    Timer {
        interval: 1000
        running: root.recording
        repeat: true
        onTriggered: root.recordSeconds++
    }

    Process {
        running: true
        command: ["sh", "-c",
            'echo "GRIM=$(command -v grim >/dev/null 2>&1 && echo yes || echo no)"; ' +
            'echo "SLURP=$(command -v slurp >/dev/null 2>&1 && echo yes || echo no)"; ' +
            'echo "REC=$(command -v wf-recorder >/dev/null 2>&1 && echo yes || echo no)"']
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const key = line.substring(0, i);
                    const val = line.substring(i + 1) === "yes";
                    if (key === "GRIM") root.grimAvailable = val;
                    else if (key === "SLURP") root.slurpAvailable = val;
                    else if (key === "REC") root.recorderAvailable = val;
                }
            }
        }
    }
}
