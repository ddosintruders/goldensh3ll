<div align="center">
  <img alt="GoldenSh3ll Logo" src="https://github.com/ddosintruders/goldensh3ll/blob/main/assets/GoldenSh3ll%20logo%20png.png" width="100" />
  <h1>GoldenSh3ll (GoldenShell)</h1>
  <h2>Open-source opinionated <br>
    desktop environment for Wayland Compositors</h2>

  <p>
    <img alt="Version" src="https://img.shields.io/badge/version-v0.21-d9a94c" />
    <img alt="License" src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue" />
    <img alt="Built with" src="https://img.shields.io/badge/built%20with-Quickshell%20%2B%20Hyprland-4fb3a8" />
  </p>
</div>

GoldenSh3ll merges the two familiar desktop layouts, a **macOS-style top bar** and a **Windows-style taskbar** into one corporate-grade shell for Hyprland, with glass materials, wallpaper-driven color, and a full settings application. No terminal required after install.

### Behind the scope

GoldenSh3ll was initiated to revolve around desktop simplicity while having the look and feel of corporate-grade polish like macOS and Windows, except enhancing and simplifying over the base visuals. Hyprland-supported distros are the goal and it would be sub-optimal to only optimize for a specific distribution.

## Features (v0.21)

### Top bar
- Optionally **floating** with rounded corners and adjustable glass opacity
- Logo menu with session actions (lock, restart shell, log out, restart, shut down)
- Workspace switcher with focus animation
- **Notification center**: bell with unread badge, app-grouped history, clear-all, Do Not Disturb
- Now-playing media label with **marquee scrolling** and an optional **cava audio visualizer** (bar count, shape and color configurable)
- Control center with Windows-11-style split tiles sliding into full panels:
  - **Wi-Fi** — scan, join (with password), disconnect, forget
  - **Bluetooth** — pair, connect, disconnect, forget (bluetoothctl-backed agent)
  - **Capture** — screenshots (full / region / manual size) and screen recording with a live indicator
- Volume flyout with output device picker, battery indicator with percentage

### Taskbar & Start menu
- **Start menu** on the Windows key: type-to-search apps, pinned grid (right-click any app to pin/unpin, independent from taskbar pins), profile card, session buttons
- Inline **DuckDuckGo web search** that opens your default browser
- Compact **weather pill** (toggleable) sharing the widget's location settings
- Pinned + running apps with focus indicators and launch bounce
- System tray with overflow popup, **removable-drive** mount/unmount popup, clock with month calendar
- Right-click accessibility menus: clock → Time & Date, bar → bar settings

### Desktop
- App **shortcuts** (double-click to launch) managed from settings
- Draggable **widgets**: analog clock (dark face, smooth second hand, configurable font) and an **animated weather widget** (Open-Meteo, no API key)
- Right-click menu for shortcuts and wallpaper configuration

### Lockscreen
- Native Wayland session lock with PAM, blurred wallpaper, avatar + display name, media mini-player, battery, power actions
- Survives shell reloads; optional **separate lockscreen wallpaper library** with shuffle-on-lock

### Settings app (Windows 11 × macOS hybrid)
Profile (name + avatar presets/custom) · Appearance (dark mode with **system-wide propagation** to GTK/websites, accents, dynamic color, translucency, floating bar, cursor themes, reduce motion) · Wallpaper · Desktop & Widgets · Bar & Taskbar · Default Apps (xdg) · Sound · Media/visualizer · Network · Bluetooth · Accounts registry · Time & Date (NTP, timezone, 12/24h) · About

### Wallpaper engine
- hyprpaper-backed with per-monitor wallpapers, shuffle timer (1-minute granularity), persistence across reboots
- Optional **dynamic color**: the whole shell palette follows your wallpaper (matugen)

## Installation

> [!note]
> GoldenSh3ll's development is first tested on Arch + Hyprland. If you would like to test and optimize for a specific distribution, you can become a collaborator too :)

### Required

| Package | Purpose |
| --- | --- |
| [Quickshell](https://quickshell.org/docs/v0.3.0/guide/install-setup/) (v0.2+) | The shell runtime |
| [Hyprland](https://wiki.hypr.land/Getting-Started/Installation/) | Compositor |
| [hyprpaper](https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/) | Wallpaper daemon |
| PipeWire + WirePlumber | Audio widgets |
| NetworkManager | Network widgets |
| xdg-utils | Default apps + web search |
| hyprpolkitagent | PolicyKit Authentication |

### Optional (feature-gated, everything degrades gracefully)

| Package | Enables |
| --- | --- |
| **Google Sans** / Product Sans (or Inter/Roboto/Noto) | Intended typography |
| bluez + bluez-utils (+ libspa-0.2-bluetooth) | Bluetooth panels (+ audio devices) |
| matugen | Dynamic color from wallpaper |
| cava | Top-bar audio visualizer |
| grim + slurp | Screenshots |
| wf-recorder | Screen recording |
| udisks2 | Removable-drive mounting |
| hyprpolkitagent | Time & Date changes (autostarted by the config) |
| xdg-desktop-portal + -gtk, adw-gtk3 | Dark mode propagation to apps/websites |
| brightnessctl, UPower | Backlight OSD, battery |
| A cursor theme you like | Settings → Appearance → Cursor |

### Install

```sh
git clone https://github.com/ddosintruders/goldensh3ll
cd goldensh3ll
cp -r hypr quickshell ~/.config/
```

Quickshell picks up `~/.config/quickshell/shell.qml` automatically — it is autostarted by the Hyprland config, or run `qs` manually. 

To preview from the repo without touching your config: 

```sh
qs -p ./quickshell/shell.qml
```
> [!CAUTION]
> Please back up any existing dotfiles before installing. This project assumes a clean, minimal installation.

## Keybinds

| Bind | Action |
| --- | --- |
| `SUPER` (tap) | Start menu — type immediately to search |
| `SUPER + SPACE` | Start menu |
| `SUPER + L` | Lock screen |
| `SUPER + I` | System Settings |
| `SUPER + W` | Next wallpaper (shuffle) |
| `SUPER + M` | Log out to the display manager |
| `PrtSc` | Full-screen screenshot |
| `SUPER + SHIFT + S` | Region screenshot (draw with mouse) |

## Shell IPC

Every surface can be driven from scripts:

```sh
qs ipc call lockscreen lock
qs ipc call launcher toggle
qs ipc call settings toggle          # or: settings open <page>
qs ipc call brightness up|down
qs ipc call wallpaper next           # or: wallpaper set /path/img.jpg
qs ipc call capture full|region|record
```

## Configuration

- Shell settings persist in `~/.config/goldensh3ll/settings.json` (hot-reloaded; everything is editable from the Settings app).
- The wallpaper engine manages `~/.config/hypr/hyprpaper.conf` and restarts hyprpaper on change — manual edits to that file will be overwritten.
- Dynamic color writes `~/.config/goldensh3ll/colors.json` via matugen.
- Glass blur is registered per layer namespace via `hyprctl` at shell start; restart the shell after a Hyprland reload to re-apply.

## Roadmap (v0.3)

Notification persistence · hypridle auto-lock · taskbar window previews · install script · deeper online-accounts research

## Credits

- [Lucide](https://lucide.dev) icons (ISC) — see `quickshell/assets/icons/LICENSE`
- [Open-Meteo](https://open-meteo.com) weather API
- cava, grim, slurp, wf-recorder — the excellent tools behind the visualizer and capture features
- Designed with **Claude Fable 5**

## Trademarks

**GoldenSh3ll is an independent, community-built project and is not affiliated with, endorsed by, sponsored by, or associated with Apple Inc., Microsoft Corporation, Google LLC, the GNOME Foundation, KDE e.V., Hyprland, or any other referenced organization.**

*Apple, macOS, and related marks are trademarks of Apple Inc.*  
*Microsoft, Windows, and related marks are trademarks of Microsoft Corporation.*  
*Google, Gemini, and related marks are trademarks of Google LLC.*  
*GNOME is a trademark of the GNOME Foundation.*  
*KDE is a trademark of KDE e.V.*  
*Hyprland and Quickshell are used only to identify compatible software or technologies and remain the property of their respective owners.*

***All product names, logos, brands, and trademarks mentioned in this repository are the property of their respective owners. References are used for identification, compatibility, comparison, or descriptive purposes only. GoldenSh3ll does not claim ownership of, or imply endorsement by, any third-party trademark owner.***

## License

GPL-3.0-or-later — see [LICENSE](LICENSE).
