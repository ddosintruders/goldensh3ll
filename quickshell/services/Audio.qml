// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// PipeWire audio: default sink/source volume, mute and device switching.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    readonly property bool muted: (sink && sink.audio) ? sink.audio.muted : false

    readonly property real micVolume: (source && source.audio) ? source.audio.volume : 0
    readonly property bool micMuted: (source && source.audio) ? source.audio.muted : false

    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)

    readonly property string sinkName: (sink && (sink.description || sink.nickname || sink.name)) || "No output"

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources]
    }

    function setVolume(v) {
        if (sink && sink.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, v));
        }
    }

    function adjust(steps) {
        setVolume(volume + steps * 0.05);
    }

    function toggleMute() {
        if (sink && sink.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setMicVolume(v) {
        if (source && source.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1, v));
        }
    }

    function toggleMicMute() {
        if (source && source.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    function setSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function iconName() {
        if (muted || volume <= 0) return "volume-x";
        if (volume < 0.34) return "volume";
        if (volume < 0.67) return "volume-1";
        return "volume-2";
    }
}
