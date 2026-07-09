// SPDX-FileCopyrightText: 2026 ddosintruders
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Weather data from Open-Meteo (free, no API key). Location is geocoded
// once via the Open-Meteo geocoding API and persisted in settings.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

Singleton {
    id: root

    property bool hasData: false
    property real temp: 0
    property int code: -1
    property real wind: 0
    property bool geocoding: false
    property string lastError: ""

    readonly property string place: Settings.data.weatherPlace
    readonly property bool configured:
        Settings.data.weatherLat !== "" && Settings.data.weatherLon !== ""
    readonly property string unit: Settings.data.weatherCelsius ? "°C" : "°F"

    // Scene kind for the animated widget, from the WMO weather code.
    readonly property string kind: {
        if (code === 0 || code === 1) return "sun";
        if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82)) return "rain";
        if ((code >= 71 && code <= 77) || code === 85 || code === 86) return "snow";
        if (code >= 95) return "storm";
        return "cloud";
    }

    readonly property string condition: {
        if (!hasData) return "No data";
        if (code === 0) return "Clear";
        if (code === 1) return "Mostly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45 || code === 48) return "Fog";
        if (code >= 51 && code <= 57) return "Drizzle";
        if (code >= 61 && code <= 67) return "Rain";
        if (code >= 71 && code <= 77) return "Snow";
        if (code >= 80 && code <= 82) return "Showers";
        if (code === 85 || code === 86) return "Snow showers";
        if (code >= 95) return "Thunderstorm";
        return "—";
    }

    readonly property string iconName: {
        switch (kind) {
        case "sun": return "sun";
        case "rain": return "cloud-rain";
        case "snow": return "cloud-snow";
        case "storm": return "cloud-lightning";
        }
        return "cloud";
    }

    function refresh() {
        if (!configured)
            return;
        const unitParam = Settings.data.weatherCelsius ? "celsius" : "fahrenheit";
        fetchProc.command = ["curl", "-sf", "--max-time", "10",
            "https://api.open-meteo.com/v1/forecast?latitude=" + Settings.data.weatherLat
            + "&longitude=" + Settings.data.weatherLon
            + "&current=temperature_2m,weather_code,wind_speed_10m"
            + "&temperature_unit=" + unitParam];
        fetchProc.running = false;
        fetchProc.running = true;
    }

    function setLocation(query) {
        if (!query || query.trim().length === 0 || geocoding)
            return;
        geocoding = true;
        lastError = "";
        geoProc.command = ["curl", "-sf", "--max-time", "10",
            "https://geocoding-api.open-meteo.com/v1/search?count=1&name="
            + encodeURIComponent(query.trim())];
        geoProc.running = true;
    }

    Process {
        id: fetchProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const current = JSON.parse(text).current;
                    root.temp = current.temperature_2m;
                    root.code = current.weather_code;
                    root.wind = current.wind_speed_10m;
                    root.hasData = true;
                } catch (e) {
                    root.lastError = "Weather fetch failed";
                }
            }
        }
    }

    Process {
        id: geoProc
        stdout: StdioCollector {
            onStreamFinished: {
                root.geocoding = false;
                try {
                    const results = JSON.parse(text).results;
                    if (results === undefined || results.length === 0) {
                        root.lastError = "Location not found";
                        return;
                    }
                    const r = results[0];
                    Settings.data.weatherPlace = r.name + (r.country ? ", " + r.country : "");
                    Settings.data.weatherLat = String(r.latitude);
                    Settings.data.weatherLon = String(r.longitude);
                    root.refresh();
                } catch (e) {
                    root.lastError = "Location lookup failed";
                }
            }
        }
        onExited: root.geocoding = false
    }

    Connections {
        target: Settings.data
        function onWeatherCelsiusChanged() { root.refresh(); }
    }

    Timer {
        interval: 30 * 60000
        running: root.configured
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
