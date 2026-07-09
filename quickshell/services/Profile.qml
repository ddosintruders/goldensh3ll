// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// User identity shown in the settings sidebar and on the lockscreen.

pragma Singleton
import QtQuick
import Quickshell
import qs.config

Singleton {
    id: root

    readonly property string displayName: Settings.data.userName.length > 0
        ? Settings.data.userName
        : SysInfo.user.charAt(0).toUpperCase() + SysInfo.user.slice(1)

    readonly property string initial: displayName.charAt(0).toUpperCase()

    readonly property url avatarSource: {
        const a = Settings.data.avatar;
        if (!a || a.length === 0)
            return "";
        if (a.startsWith("preset:"))
            return Qt.resolvedUrl("../assets/avatars/abstract-" + a.substring(7) + ".svg");
        return "file://" + a;
    }

    readonly property bool hasAvatar: Settings.data.avatar.length > 0
}
