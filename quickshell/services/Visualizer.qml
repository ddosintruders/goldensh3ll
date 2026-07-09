// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Audio spectrum data via cava (optional dependency): a raw-ASCII config
// is generated per bar count, cava streams frames on stdout, and `values`
// holds the current normalized bar heights. Runs only while media plays
// and the visualizer is enabled.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool available: false
    property var values: []

    readonly property int bars: Math.max(8, Math.min(40, Settings.data.visualizerBars))
    readonly property bool enabled: Settings.data.mediaVisualizer && available
    readonly property bool shouldRun: enabled && Media.playing && Settings.data.showMediaInBar

    readonly property color barColor: {
        const c = Settings.data.visualizerColor;
        if (c && /^#[0-9a-fA-F]{6}$/.test(c))
            return c;
        return Theme.accent;
    }

    onShouldRunChanged: restart()
    onBarsChanged: restart()

    function restart() {
        cavaProc.running = false;
        if (!shouldRun) {
            values = [];
            return;
        }
        writeConfig();
        startDelay.restart();
    }

    function writeConfig() {
        const conf = "[general]\nbars = " + bars + "\nframerate = 30\n\n" +
            "[output]\nmethod = raw\nraw_target = /dev/stdout\n" +
            "data_format = ascii\nascii_max_range = 100\n" +
            "bar_delimiter = 59\nframe_delimiter = 10\n\n" +
            "[smoothing]\nnoise_reduction = 50\n";
        try {
            confFile.setText(conf);
        } catch (e) {
            console.log("Visualizer: could not write cava config:", e);
        }
    }

    FileView {
        id: confFile
        path: Settings.configDir + "/cava.conf"
        printErrors: false
    }

    Timer {
        id: startDelay
        interval: 250
        onTriggered: {
            if (root.shouldRun)
                cavaProc.running = true;
        }
    }

    Process {
        id: cavaProc
        command: ["cava", "-p", Settings.configDir + "/cava.conf"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(";");
                const vals = [];
                for (const p of parts) {
                    if (p === "")
                        continue;
                    const n = parseInt(p);
                    if (!isNaN(n))
                        vals.push(Math.min(1, n / 100));
                }
                if (vals.length > 0)
                    root.values = vals;
            }
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v cava >/dev/null 2>&1 && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = text.trim() === "yes";
                if (root.available)
                    root.restart();
            }
        }
    }
}
