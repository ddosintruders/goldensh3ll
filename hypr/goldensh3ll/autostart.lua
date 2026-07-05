----------------------------------------------------------
------- SPDX-FileCopyrightText: 2026 ddosintruders -------
------- SPDX-License-Identifier: GPL-3.0-or-later --------
----------------------------------------------------------

-- Customize your autostart apps if needed, this will only house hyprpaper & firefox for a default configuration.

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper & firefox")
end)
