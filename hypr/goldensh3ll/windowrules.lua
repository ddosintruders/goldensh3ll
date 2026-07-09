----------------------------------------------------------
------- SPDX-FileCopyrightText: 2026 ddosintruders -------
------- SPDX-License-Identifier: GPL-3.0-or-later --------
----------------------------------------------------------

hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- The GoldenSh3ll settings app opens as a centered floating window.
    name  = "float-goldensh3ll-settings",
    match = { title = "^GoldenSh3ll Settings$" },

    float = true,
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})
