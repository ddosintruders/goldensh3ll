// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Default applications via the freedesktop mechanisms (xdg-settings /
// xdg-mime), so choices apply system-wide — xdg-open, terminal tools and
// other apps all honor them.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string webFile: ""
    property string mailFile: ""
    property string photoFile: ""
    property string videoFile: ""

    readonly property var webEntry: webFile ? AppSearch.entryFor(webFile) : null
    readonly property var mailEntry: mailFile ? AppSearch.entryFor(mailFile) : null
    readonly property var photoEntry: photoFile ? AppSearch.entryFor(photoFile) : null
    readonly property var videoEntry: videoFile ? AppSearch.entryFor(videoFile) : null

    function refresh() {
        queryProc.running = false;
        queryProc.running = true;
    }

    function toFile(entry) {
        return entry.id.endsWith(".desktop") ? entry.id : entry.id + ".desktop";
    }

    function setWeb(entry) {
        Quickshell.execDetached(["xdg-settings", "set", "default-web-browser", toFile(entry)]);
        webFile = toFile(entry);
        refreshDelay.restart();
    }

    function setMail(entry) {
        Quickshell.execDetached(["xdg-mime", "default", toFile(entry),
            "x-scheme-handler/mailto"]);
        mailFile = toFile(entry);
        refreshDelay.restart();
    }

    function setPhotos(entry) {
        Quickshell.execDetached(["xdg-mime", "default", toFile(entry),
            "image/png", "image/jpeg", "image/webp", "image/gif", "image/bmp"]);
        photoFile = toFile(entry);
        refreshDelay.restart();
    }

    function setVideos(entry) {
        Quickshell.execDetached(["xdg-mime", "default", toFile(entry),
            "video/mp4", "video/x-matroska", "video/webm", "video/x-msvideo"]);
        videoFile = toFile(entry);
        refreshDelay.restart();
    }

    // Suggested apps per role, from desktop-entry categories.
    function candidates(kind) {
        return AppSearch.all.filter(a => {
            const c = a.categories || [];
            switch (kind) {
            case "web":
                return c.indexOf("WebBrowser") !== -1;
            case "mail":
                return c.indexOf("Email") !== -1;
            case "photo":
                return c.indexOf("Graphics") !== -1 || c.indexOf("Viewer") !== -1
                    || c.indexOf("Photography") !== -1;
            case "video":
                return c.indexOf("Video") !== -1 || c.indexOf("AudioVideo") !== -1
                    || c.indexOf("Player") !== -1;
            }
            return false;
        });
    }

    Process {
        id: queryProc
        running: true
        command: ["sh", "-c",
            'echo "WEB=$(xdg-settings get default-web-browser 2>/dev/null)"; ' +
            'echo "MAIL=$(xdg-mime query default x-scheme-handler/mailto 2>/dev/null)"; ' +
            'echo "PHOTO=$(xdg-mime query default image/png 2>/dev/null)"; ' +
            'echo "VIDEO=$(xdg-mime query default video/mp4 2>/dev/null)"']
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.trim().split("\n")) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const key = line.substring(0, i);
                    const val = line.substring(i + 1).trim();
                    if (key === "WEB") root.webFile = val;
                    else if (key === "MAIL") root.mailFile = val;
                    else if (key === "PHOTO") root.photoFile = val;
                    else if (key === "VIDEO") root.videoFile = val;
                }
            }
        }
    }

    Timer {
        id: refreshDelay
        interval: 1200
        onTriggered: root.refresh()
    }
}
