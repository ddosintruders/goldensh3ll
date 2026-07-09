----------------------------------------------------------
------- SPDX-FileCopyrightText: 2026 ddosintruders -------
------- SPDX-License-Identifier: GPL-3.0-or-later --------
----------------------------------------------------------

-- Customize your autostart apps if needed. The defaults start the wallpaper
-- daemon (hyprpaper), the GoldenSh3ll shell (quickshell), firefox, and the
-- polkit agent (required for privileged settings such as Time & Date).

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper & qs & firefox & systemctl --user enable --now hyprpolkitagent")
end)
