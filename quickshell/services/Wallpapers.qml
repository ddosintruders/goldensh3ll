// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// The GoldenSh3ll wallpaper engine, driving hyprpaper over hyprctl IPC.
// Applies wallpapers live (per monitor or globally), persists the choice
// into ~/.config/hypr/hyprpaper.conf so it survives reboots, and offers
// an optional shuffle timer.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    readonly property string dir: Settings.data.wallpaperDir
    property var files: []
    property bool scanning: false
    property bool matugenFound: false

    onDirChanged: scan()
    Component.onCompleted: scan()

    function scan() {
        scanning = true;
        scanProc.running = false;
        scanProc.running = true;
    }

    function wallpaperFor(monitorName) {
        if (monitorName) {
            for (const e of Settings.data.monitorWallpapers) {
                const i = e.indexOf("::");
                if (i > 0 && e.substring(0, i) === monitorName)
                    return e.substring(i + 2);
            }
        }
        return Settings.data.wallpaper;
    }

    // ------------------------------------------- lockscreen wallpaper split
    // When enabled, the lockscreen cycles its own library; otherwise it
    // mirrors the desktop wallpaper (default behavior).
    property var lockFiles: []

    readonly property string lockDir: Settings.data.lockWallpaperDir
    onLockDirChanged: scanLock()

    function scanLock() {
        lockScanProc.running = false;
        lockScanProc.running = true;
    }

    function lockWallpaperFor(monitorName) {
        if (!Settings.data.separateLockWallpaper)
            return wallpaperFor(monitorName);
        return Settings.data.lockWallpaper || wallpaperFor(monitorName);
    }

    function applyLock(path) {
        if (path)
            Settings.data.lockWallpaper = path;
    }

    function randomLock() {
        if (lockFiles.length === 0)
            return;
        const candidates = lockFiles.filter(f => f !== Settings.data.lockWallpaper);
        const pool = candidates.length > 0 ? candidates : lockFiles;
        applyLock(pool[Math.floor(Math.random() * pool.length)]);
    }

    Process {
        id: lockScanProc
        running: true
        command: ["find", "-L", root.lockDir, "-maxdepth", "2", "-type", "f",
                  "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o",
                  "-iname", "*.png", "-o", "-iname", "*.webp", "-o",
                  "-iname", "*.bmp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.lockFiles = t.length > 0 ? t.split("\n").sort() : [];
            }
        }
    }

    property string lastError: ""

    // monitorName === "" applies to all monitors and clears overrides.
    //
    // Deterministic conf-then-restart strategy: hyprpaper's request IPC has
    // proven unreliable across versions ("invalid hyprpaper request"), while
    // the config file always works — so persist hyprpaper.conf and restart
    // the daemon to pick it up.
    function apply(path, monitorName) {
        if (!path) return;
        lastError = "";
        if (monitorName) {
            const list = Settings.data.monitorWallpapers
                .filter(e => !e.startsWith(monitorName + "::"));
            list.push(monitorName + "::" + path);
            Settings.data.monitorWallpapers = list;
            if (!Settings.data.wallpaper)
                Settings.data.wallpaper = path;
        } else {
            Settings.data.wallpaper = path;
            Settings.data.monitorWallpapers = [];
        }
        writeConf();
        restartDelay.restart();
        generatePalette(path);
    }

    // ------------------------------------------------- dynamic color (matugen)
    // Optional: when matugen is installed, derive a Material palette from the
    // wallpaper and flatten it into colors.json for DynamicPalette/Theme.
    function generatePalette(path) {
        if (!matugenFound || !path)
            return;
        matugenProc.command = ["matugen", "image", path, "--json", "hex", "--dry-run"];
        matugenProc.running = false;
        matugenProc.running = true;
    }

    function handleMatugen(text) {
        let scheme;
        try {
            scheme = JSON.parse(text).colors;
        } catch (e) {
            console.log("Wallpapers: could not parse matugen output");
            return;
        }
        if (!scheme || !scheme.dark || !scheme.light)
            return;
        const flat = {};
        const map = {
            Primary: "primary",
            OnPrimary: "on_primary",
            Surface: "surface",
            SurfaceContainer: "surface_container",
            SurfaceContainerHigh: "surface_container_high",
            SurfaceContainerHighest: "surface_container_highest",
            OnSurface: "on_surface",
            OnSurfaceVariant: "on_surface_variant",
            Outline: "outline"
        };
        for (const key in map) {
            flat["d" + key] = scheme.dark[map[key]] || "";
            flat["l" + key] = scheme.light[map[key]] || "";
        }
        try {
            paletteFile.setText(JSON.stringify(flat, null, 2) + "\n");
        } catch (e) {
            console.log("Wallpapers: could not write colors.json:", e);
        }
    }

    FileView {
        id: paletteFile
        path: Settings.configDir + "/colors.json"
        printErrors: false
    }

    Process {
        id: matugenProc
        stdout: StdioCollector {
            onStreamFinished: root.handleMatugen(text)
        }
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v matugen >/dev/null 2>&1 && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: root.matugenFound = text.trim() === "yes"
        }
    }

    function applyRandom() {
        if (files.length === 0) return;
        const candidates = files.filter(f => f !== Settings.data.wallpaper);
        const pool = candidates.length > 0 ? candidates : files;
        apply(pool[Math.floor(Math.random() * pool.length)], "");
    }

    // Rewrites hyprpaper.conf so the current selection is restored on boot.
    function writeConf() {
        const lines = [
            "# Managed by GoldenSh3ll - manual edits will be overwritten.",
            "ipc = on",
            "splash = false"
        ];
        const preloads = [];
        const global = Settings.data.wallpaper;
        if (global && preloads.indexOf(global) === -1)
            preloads.push(global);
        const perMonitor = [];
        for (const e of Settings.data.monitorWallpapers) {
            const i = e.indexOf("::");
            if (i <= 0) continue;
            const mon = e.substring(0, i);
            const p = e.substring(i + 2);
            perMonitor.push([mon, p]);
            if (preloads.indexOf(p) === -1)
                preloads.push(p);
        }
        for (const p of preloads)
            lines.push("preload = " + p);
        if (global && perMonitor.length === 0)
            lines.push("wallpaper = ," + global);
        for (const [mon, p] of perMonitor)
            lines.push("wallpaper = " + mon + "," + p);

        try {
            confFile.setText(lines.join("\n") + "\n");
        } catch (e) {
            console.log("Wallpapers: could not write hyprpaper.conf:", e);
        }
    }

    FileView {
        id: confFile
        path: Settings.home + "/.config/hypr/hyprpaper.conf"
    }

    // Give the conf write a moment to land on disk before restarting.
    Timer {
        id: restartDelay
        interval: 300
        onTriggered: {
            restartProc.output = "";
            restartProc.running = false;
            restartProc.running = true;
        }
    }

    Process {
        id: restartProc

        property string output: ""

        command: ["sh", "-c",
            'pkill -x hyprpaper 2>/dev/null; sleep 0.4; ' +
            '(hyprpaper >/dev/null 2>&1 &); sleep 0.6; ' +
            'pgrep -x hyprpaper >/dev/null || echo "hyprpaper failed to start (is it installed?)"']
        stdout: StdioCollector { onStreamFinished: restartProc.output += text }
        stderr: StdioCollector { onStreamFinished: restartProc.output += text }
        onExited: {
            const t = output.trim();
            if (t)
                root.lastError = t;
        }
    }

    Process {
        id: scanProc
        command: ["find", "-L", root.dir, "-maxdepth", "2", "-type", "f",
                  "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o",
                  "-iname", "*.png", "-o", "-iname", "*.webp", "-o",
                  "-iname", "*.bmp", ")"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.files = t.length > 0 ? t.split("\n").sort() : [];
                root.scanning = false;
            }
        }
    }

    Timer {
        running: Settings.data.wallpaperShuffle && root.files.length > 1
        repeat: true
        interval: Math.max(1, Settings.data.wallpaperShuffleMinutes) * 60000
        onTriggered: root.applyRandom()
    }
}
