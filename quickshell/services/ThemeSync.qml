// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Mirrors the shell's dark/light mode into the freedesktop appearance
// settings (gsettings color-scheme + gtk-theme), which xdg-desktop-portal
// exposes to GTK apps, Electron and browsers — so websites' auto
// prefers-color-scheme follows the shell theme.

pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    function apply() {
        const scheme = Settings.data.darkMode ? "prefer-dark" : "prefer-light";
        Quickshell.execDetached(["sh", "-c",
            'command -v gsettings >/dev/null 2>&1 || exit 0; ' +
            'gsettings set org.gnome.desktop.interface color-scheme "$1"; ' +
            'if [ "$1" = "prefer-dark" ]; then t="adw-gtk3-dark"; else t="adw-gtk3"; fi; ' +
            '{ [ -d "/usr/share/themes/$t" ] || [ -d "$HOME/.themes/$t" ]; } ' +
            '&& gsettings set org.gnome.desktop.interface gtk-theme "$t" || true',
            "gs-theme", scheme]);
    }

    Connections {
        target: Settings.data
        function onDarkModeChanged() { root.apply(); }
    }

    // Re-assert at startup once settings have loaded from disk.
    Timer {
        interval: 3000
        running: true
        onTriggered: root.apply()
    }
}
