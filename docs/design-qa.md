# GoldenSh3ll v0.2 — Design QA Checklist

Release gate for tagging `v0.2`. Run the shell from the repo checkout so
nothing touches your real config until it passes:

```sh
qs -p <repo>/quickshell/shell.qml
```

Zero QML errors on stderr is a hard requirement before any visual check.

## Icons & materials

- [ ] Icons are tinted correctly in **dark mode** (light glyphs) and **light mode** (dark glyphs) — check the top bar, taskbar, settings nav, lockscreen.
- [ ] Glass is active: `hyprctl layers` lists the `goldensh3ll-*` namespaces and the bars/popups show background blur.
- [ ] Appearance → Translucency **off** falls back to clean, near-opaque surfaces.

## Dynamic color

- [ ] With matugen installed: apply 3 different wallpapers → accent and surfaces follow each one (both dark and light mode).
- [ ] Appearance → Dynamic color **off** → static accent returns instantly; accent swatches re-enable.
- [ ] Without matugen: the switch is disabled with the install hint; nothing errors.

## Connections

- [ ] Control center → Wi-Fi chevron: panel slides in; join an open network, join a secured network (password field), rescan, back arrow returns.
- [ ] Control center → Bluetooth chevron: connect/disconnect a paired device, scan finds a nearby device, tap-to-pair works, forget removes it.
- [ ] Settings → Bluetooth: same operations plus the trust toggle; battery % shows for devices that report it.
- [ ] Settings → Network: full list, connect with password, error message on a wrong password.
- [ ] Brightness slider appears only when brightnessctl has a device.

## Notification center

- [ ] Send test notifications (`notify-send "Title" "Body"`) → toast slides in; bell badge counts unread.
- [ ] Opening the center clears the badge; history is grouped by app; per-item dismiss and Clear all work.
- [ ] DND on: toasts stop, history still records, critical notifications still toast.

## Profile

- [ ] Set a display name + preset avatar → settings sidebar card and lockscreen both update.
- [ ] Custom image path works; empty avatar falls back to the accent initial.

## Motion

- [ ] Every popup: slide+fade+scale entrance, animated exit, Esc and click-outside close it, correct anchor position on every monitor.
- [ ] Control center panel slide, launcher height growth while typing, taskbar launch bounce, tray chevron rotation, OSD pop, toast slide-in — all smooth (~60 fps).
- [ ] Appearance → Reduce motion kills all of the above instantly.

## Lockscreen

- [ ] Lock/unlock ×3, including one wrong password (shake + error message).
- [ ] Reload the shell while locked (`Quickshell.reload` from the logo menu on another screen or restart qs) → session stays locked.
- [ ] Media mini-player and power buttons work while locked.

## Hardware-fix round (v0.2.x)

- [ ] **Logout** → SDDM greeter appears, from the logo menu, Start menu, control center and `SUPER+M`.
- [ ] **Bluetooth**: fresh pair shows "Pairing…" then real Connected (`bluetoothctl info <mac>` agrees); audio routes (needs libspa-0.2-bluetooth); forget removes; failures show an error line.
- [ ] **Wallpaper** applies immediately even if hyprpaper wasn't running; error surfaces on the Wallpaper page on failure; survives reboot.
- [ ] **Dark mode propagation**: toggling dark mode flips a GTK app and a website (`prefers-color-scheme`) — needs xdg-desktop-portal-gtk.
- [ ] **Cursor picker** lists installed themes; applying changes the cursor immediately and persists after shell restart.
- [ ] **Web search**: click pill → expands with focus; query + Enter opens DuckDuckGo in the default browser; Esc collapses.
- [ ] **Default apps**: change each role; verify with `xdg-settings get default-web-browser` / `xdg-mime query default`.
- [ ] **Start menu**: Windows key opens it; typing searches instantly; pinned grid launches; profile card opens Profile settings; session buttons work.
- [ ] **Toast set-aside** (chevron) moves the toast to the bell history without dismissing; ✕ dismisses fully.
- [ ] **Floating bar**: toggle on/off — margins, rounding, opacity slider live; popups and toasts anchor correctly in both modes.
- [ ] **Desktop**: shortcuts double-click launch; edit mode drags widgets and persists positions; clock/weather widgets render; weather animates per condition and freezes under reduce-motion; windows still tile normally above the desktop layer.
- [ ] **Time & Date**: NTP toggle, timezone search+set (polkit prompt OK), manual time with NTP off.
- [ ] **Accounts**: add/remove entries; persist across shell reloads.

## v0.21 round

- [ ] **Wallpaper** applies on the desktop (hyprpaper restarts with the new conf) — no "invalid request"; persists across reboot.
- [ ] **Start menu**: Restart present; Start pins independent of taskbar pins; right-click pin/unpin in the app list and pinned grid.
- [ ] **Wi-Fi**: Disconnect (connected row) and Forget (saved networks) from both settings and the control-center panel.
- [ ] **NTP toggle** works on a fresh boot (hyprpolkitagent autostarted).
- [ ] **Media**: long titles marquee-scroll in the bar and popup; a newly started track shows the correct timeline position; visualizer reacts to audio (cava), bar count/shape/color apply live; media bar toggle in Settings → Media.
- [ ] **Weather pill** in the taskbar follows the widget location/units and its toggle.
- [ ] **Right-click menus**: clock → Time & Date; bar background → bar settings; desktop → shortcuts / wallpaper.
- [ ] **Capture**: PrtSc full shot, Super+Shift+S region, manual geometry from the control-center panel — files in ~/Pictures/Screenshots with a toast; recording start/stop with the pulsing top-bar indicator, file in ~/Videos/ScreenRecs.
- [ ] **Drives**: USB stick insert → usb icon appears; mount, open, unmount work; icon disappears on removal.
- [ ] **Lock wallpaper split**: separate library cycles on each lock when enabled; disabled = mirrors desktop.
- [ ] **Analog clock**: smooth second hand (ticks under reduce-motion), 12/3/6/9 numerals, date/time bar, font picker preview + apply.
- [ ] **v0.21 polish**: About shows the "Designed with Claude Fable 5" pill; settings nav is plain Lucide icons; 12/24h segmented slider animates; wallpaper interval accepts typed minutes.

## Sign-off

- [ ] 4-hour dogfood session with no crashes; file anything odd as a GitHub issue tagged `design-qa`.
