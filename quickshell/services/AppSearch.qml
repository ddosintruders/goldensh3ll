// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Desktop application index: launcher search, taskbar id/icon resolution.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var all: {
        const list = DesktopEntries.applications.values.filter(a => !a.noDisplay);
        list.sort((a, b) => a.name.localeCompare(b.name));
        return list;
    }

    function query(q) {
        if (!q || q.trim().length === 0)
            return all;
        const term = q.toLowerCase().trim();
        const scored = [];
        for (const a of all) {
            const name = a.name.toLowerCase();
            let s = -1;
            if (name === term) s = 100;
            else if (name.startsWith(term)) s = 80;
            else if (name.split(/\s+/).some(w => w.startsWith(term))) s = 60;
            else if (name.indexOf(term) !== -1) s = 40;
            else if ((a.keywords || []).some(k => k.toLowerCase().startsWith(term))) s = 30;
            else if ((a.genericName || "").toLowerCase().indexOf(term) !== -1) s = 25;
            else if ((a.comment || "").toLowerCase().indexOf(term) !== -1) s = 15;
            if (s >= 0)
                scored.push({ score: s, entry: a });
        }
        scored.sort((x, y) => (y.score - x.score) || x.entry.name.localeCompare(y.entry.name));
        return scored.map(x => x.entry);
    }

    function normalize(id) {
        if (!id) return "";
        let n = id.toLowerCase();
        if (n.endsWith(".desktop"))
            n = n.substring(0, n.length - 8);
        return n;
    }

    // Resolves a desktop entry from a pinned id or a wayland appId.
    function entryFor(id) {
        const n = normalize(id);
        if (!n) return null;
        let match = all.find(a => normalize(a.id) === n);
        if (match !== undefined) return match;
        // "org.kde.dolphin" should match a pin named "dolphin" and vice versa.
        match = all.find(a => {
            const aid = normalize(a.id);
            return aid.endsWith("." + n) || n.endsWith("." + aid);
        });
        if (match !== undefined) return match;
        match = all.find(a => a.name.toLowerCase() === n);
        return match !== undefined ? match : null;
    }

    function iconFor(entry, appId) {
        if (entry && entry.icon) {
            const p = Quickshell.iconPath(entry.icon, true);
            if (p) return p;
        }
        if (appId) {
            let p = Quickshell.iconPath(appId, true);
            if (p) return p;
            p = Quickshell.iconPath(appId.toLowerCase(), true);
            if (p) return p;
        }
        return Quickshell.iconPath("application-x-executable", "image-missing");
    }

    function launch(entry) {
        if (entry) entry.execute();
    }
}
