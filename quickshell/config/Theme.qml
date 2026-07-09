// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// "Golden Standard" design tokens: palette (static or wallpaper-derived),
// glass materials, type ramp, state layers, motion spec and metrics.
// Every visual module reads from here so the whole shell restyles together.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string version: "0.21"
    readonly property url logo: Qt.resolvedUrl("../assets/logo.png")

    readonly property bool dark: Settings.data.darkMode
    readonly property bool glass: Settings.data.translucency
    readonly property bool reduceMotion: Settings.data.reduceMotion

    // ------------------------------------------------------------------ accent
    readonly property var accents: ({
        gold:   "#d9a94c",
        teal:   "#4fb3a8",
        blue:   "#5b9cf5",
        violet: "#a78bfa",
        green:  "#58b368",
        rose:   "#e57e94"
    })

    // Wallpaper-derived color takes over when enabled and generated.
    readonly property bool dynamicActive: Settings.data.dynamicColor && DynamicPalette.available

    readonly property color accent: dynamicActive
        ? (dark ? DynamicPalette.dPrimary : DynamicPalette.lPrimary)
        : (accents[Settings.data.accent] !== undefined ? accents[Settings.data.accent] : accents.gold)
    readonly property color onAccent: dynamicActive
        ? (dark ? DynamicPalette.dOnPrimary : DynamicPalette.lOnPrimary)
        : ((accent.r * 0.299 + accent.g * 0.587 + accent.b * 0.114) > 0.55 ? "#181307" : "#ffffff")

    // ----------------------------------------------------------------- palette
    readonly property color _chromeBase: dynamicActive
        ? (dark ? DynamicPalette.dSurface : DynamicPalette.lSurface)
        : (dark ? "#181b21" : "#f6f7f9")
    readonly property color _popupBase: dynamicActive
        ? (dark ? DynamicPalette.dSurfaceContainer : DynamicPalette.lSurfaceContainer)
        : (dark ? "#1d2026" : "#fafbfc")

    readonly property color bg: dynamicActive
        ? (dark ? DynamicPalette.dSurface : DynamicPalette.lSurface)
        : (dark ? "#141519" : "#eef0f3")

    // Floating chrome: the top bar can detach from the screen edge.
    readonly property bool barFloating: Settings.data.barFloating
    readonly property int barMargin: barFloating ? 8 : 0
    // Total vertical space the top bar consumes — anchors popups and toasts.
    readonly property int topExclusion: topBarHeight + barMargin * 2

    // Glass materials: translucent chrome + flyouts (compositor blur is
    // applied per layer namespace at shell startup, see shell.qml).
    readonly property color barBg:
        Qt.rgba(_chromeBase.r, _chromeBase.g, _chromeBase.b,
                glass ? Math.max(0.5, Math.min(1, Settings.data.barOpacity)) : 0.97)
    readonly property color popupBg:
        Qt.rgba(_popupBase.r, _popupBase.g, _popupBase.b, glass ? 0.80 : 1.0)
    readonly property color popupBorder: glass
        ? (dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.55))
        : border

    readonly property color surface: dynamicActive
        ? (dark ? DynamicPalette.dSurfaceContainer : DynamicPalette.lSurfaceContainer)
        : (dark ? "#242830" : "#ffffff")
    readonly property color surfaceHover: dynamicActive
        ? (dark ? DynamicPalette.dSurfaceContainerHigh : DynamicPalette.lSurfaceContainerHigh)
        : (dark ? "#2d323c" : "#e7eaee")
    readonly property color surfaceActive: dynamicActive
        ? (dark ? DynamicPalette.dSurfaceContainerHighest : DynamicPalette.lSurfaceContainerHighest)
        : (dark ? "#363c48" : "#dbdfe6")
    readonly property color border: dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.10)

    readonly property color fg: dynamicActive
        ? (dark ? DynamicPalette.dOnSurface : DynamicPalette.lOnSurface)
        : (dark ? "#f2f3f6" : "#1a1c20")
    readonly property color fgDim: dynamicActive
        ? (dark ? DynamicPalette.dOnSurfaceVariant : DynamicPalette.lOnSurfaceVariant)
        : (dark ? "#b7bdc8" : "#4d545e")
    readonly property color fgMuted: dynamicActive
        ? (dark ? DynamicPalette.dOutline : DynamicPalette.lOutline)
        : (dark ? "#7f8794" : "#7b828c")

    readonly property color danger:  "#e5605a"
    readonly property color warning: "#e2b53e"
    readonly property color success: "#58b368"

    // -------------------------------------------------------------- state layers
    // Composable interaction states (Fluent-style): overlay the foreground
    // at fixed alphas instead of hand-picking hover colors per component.
    readonly property real stateHover: 0.08
    readonly property real statePressed: 0.12
    readonly property real stateSelected: 0.16
    readonly property color layerHover: Qt.rgba(fg.r, fg.g, fg.b, stateHover)
    readonly property color layerPressed: Qt.rgba(fg.r, fg.g, fg.b, statePressed)
    readonly property color layerSelected: Qt.rgba(fg.r, fg.g, fg.b, stateSelected)

    // -------------------------------------------------------------- typography
    // Google Sans is preferred when installed; graceful fallback otherwise.
    readonly property string fontFamily: {
        const installed = Qt.fontFamilies();
        const preferred = ["Google Sans Text", "Google Sans", "Product Sans",
                           "Inter", "Roboto", "Noto Sans", "Cantarell", "DejaVu Sans"];
        for (const f of preferred)
            if (installed.indexOf(f) !== -1)
                return f;
        return "sans-serif";
    }

    // Type ramp roles (consumed via StyledText.role).
    readonly property var typeDisplay:    ({ size: 92, weight: Font.Light })
    readonly property var typeTitle:      ({ size: 26, weight: Font.DemiBold })
    readonly property var typeSubtitle:   ({ size: 18, weight: Font.DemiBold })
    readonly property var typeBody:       ({ size: 13, weight: Font.Normal })
    readonly property var typeBodyStrong: ({ size: 13, weight: Font.Medium })
    readonly property var typeCaption:    ({ size: 11, weight: Font.Normal })
    readonly property var typeOverline:   ({ size: 10, weight: Font.DemiBold, spacing: 0.6 })

    readonly property int fontXs: 10
    readonly property int fontSm: 11
    readonly property int fontMd: 13
    readonly property int fontLg: 15
    readonly property int fontXl: 18
    readonly property int fontH1: 26

    // ------------------------------------------------------------------ motion
    readonly property int durFast: reduceMotion ? 0 : 140
    readonly property int durMed: reduceMotion ? 0 : 220
    readonly property int durSlow: reduceMotion ? 0 : 320
    readonly property int easeStandard: Easing.OutCubic
    readonly property int easeEmphasized: Easing.OutBack

    // Legacy aliases — existing Behaviors pick up reduceMotion for free.
    readonly property int animFast: durFast
    readonly property int animNormal: durMed
    readonly property int animSlow: durSlow

    // ----------------------------------------------------------------- metrics
    readonly property int s4: 4
    readonly property int s8: 8
    readonly property int s12: 12
    readonly property int s16: 16
    readonly property int s24: 24

    readonly property int topBarHeight: 34
    readonly property int taskbarHeight: 62

    readonly property int radiusXs: 6
    readonly property int radiusSm: 10
    readonly property int radiusMd: 14
    readonly property int radiusLg: 18
}
