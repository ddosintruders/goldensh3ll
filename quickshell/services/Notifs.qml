// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Freedesktop notification server: toast popups plus a session-scoped
// history feeding the notification center (unread badge, app grouping).

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

Singleton {
    id: root

    property var popups: []
    // History entries: { n: Notification, time: epoch ms }, newest first.
    property var history: []
    property int unreadCount: 0
    property bool centerOpen: false

    // Bumped every 30s so relative timestamps refresh.
    property double tick: Date.now()

    readonly property var groups: {
        const order = [];
        const byApp = {};
        for (const e of history) {
            const app = e.n.appName || "System";
            if (byApp[app] === undefined) {
                byApp[app] = { app: app, items: [] };
                order.push(byApp[app]);
            }
            byApp[app].items.push(e);
        }
        return order;
    }

    function timeAgo(t) {
        void tick;
        const s = (Date.now() - t) / 1000;
        if (s < 60) return "now";
        if (s < 3600) return Math.floor(s / 60) + "m";
        if (s < 86400) return Math.floor(s / 3600) + "h";
        return Math.floor(s / 86400) + "d";
    }

    function markRead() {
        unreadCount = 0;
    }

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function removeFromHistory(n) {
        history = history.filter(e => e.n !== n);
    }

    function dismiss(n) {
        removePopup(n);
        removeFromHistory(n);
        n.dismiss();
    }

    function expire(n) {
        // Toast timed out: it leaves the screen but stays in history.
        removePopup(n);
    }

    function clearAll() {
        const entries = [...history];
        history = [];
        popups = [];
        unreadCount = 0;
        for (const e of entries) {
            try { e.n.dismiss(); } catch (err) {}
        }
    }

    Timer {
        interval: 30000
        running: root.history.length > 0
        repeat: true
        onTriggered: root.tick = Date.now()
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: notif => {
            notif.tracked = true;
            if (notif.closed !== undefined) {
                notif.closed.connect(() => {
                    root.removePopup(notif);
                    root.removeFromHistory(notif);
                });
            }

            root.history = [{ n: notif, time: Date.now() }, ...root.history].slice(0, 50);
            if (!root.centerOpen)
                root.unreadCount++;

            const critical = notif.urgency === NotificationUrgency.Critical;
            if (Settings.data.doNotDisturb && !critical)
                return;
            root.popups = [...root.popups, notif];
        }
    }
}
