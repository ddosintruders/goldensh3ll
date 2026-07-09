// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// MPRIS media aggregation: exposes the most relevant player.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var active: {
        const playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing !== undefined) return playing;
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool hasPlayer: active !== null
    readonly property bool playing: active !== null
        && active.playbackState === MprisPlaybackState.Playing

    readonly property string title: (active && active.trackTitle) || ""
    readonly property string artist: (active && active.trackArtist) || ""
    readonly property string appName: (active && active.identity) || ""
    readonly property string artUrl: (active && active.trackArtUrl) || ""

    // "App | Artist - Title", the compact form shown in the top bar.
    readonly property string barLabel: {
        if (!active) return "";
        let track = title || "Unknown track";
        if (artist) track = artist + " - " + track;
        return appName ? appName + " | " + track : track;
    }

    function toggle() {
        if (active && active.canTogglePlaying) active.togglePlaying();
    }
    function next() {
        if (active && active.canGoNext) active.next();
    }
    function previous() {
        if (active && active.canGoPrevious) active.previous();
    }

    // Progress ratio 0..1, refreshed by pollProgress() while a popup is open.
    property real progress: 0
    function pollProgress() {
        if (active && active.length > 0 && isFinite(active.length) && isFinite(active.position)) {
            // MPRIS position can be stale right after a track change (it
            // refreshes on playback-state changes); a position beyond the
            // track length means "not updated yet".
            if (active.position > active.length) {
                progress = 0;
                return;
            }
            progress = Math.max(0, Math.min(1, active.position / active.length));
        } else {
            progress = 0;
        }
    }

    // Reset the timeline whenever the track changes.
    Connections {
        target: root.active
        ignoreUnknownSignals: true
        function onTrackTitleChanged() { root.progress = 0; }
        function onTrackArtUrlChanged() { root.progress = 0; }
    }
}
