# GPX Recorder

A minimal iOS app that records your device's real, unfiltered location stream and exports it as a GPX file.

## Why this exists

Most GPS-recording apps on the App Store either record on a fixed interval (once every N seconds, regardless of what's actually happening) or quietly stop updating while stationary, even though iOS's own location services keep producing new fixes the whole time. GPX Recorder does neither. It uses `CLLocationManager` with distance filtering and automatic pausing both disabled, so every location update the OS decides to deliver gets written to the track, exactly as the device produced it, moving or stationary, foreground or background.

## Features

- **Record / Stop** — a single button to start and stop a recording session.
- **Live point count and elapsed timer** while recording.
- **Background recording** — keeps recording with the screen locked or while using other apps (requires "Always" location permission, see below).
- **Unthrottled updates** — no fixed sampling interval, no distance filter, no auto-pause. What you get is what CoreLocation actually reports.
- **Save anywhere** — on Stop, you're prompted for a filename, then the system Files picker lets you save the `.gpx` to Files, iCloud Drive, or any other location-aware app.

## Installation

1. Download the latest `.tipa` from this repo's [Actions](../../actions) artifacts.
2. Transfer it to your iPhone (AirDrop, Files, email or any method that gets the file onto the device).
3. Open it with [TrollStore](https://github.com/opa334/TrollStore) to install.
4. On first launch, grant location access. Then go to **Settings → Privacy & Security → Location Services → GPX Recorder** and set it to **Always**, with **Precise Location** enabled — this is required for recording to continue while the app is backgrounded or the screen is locked.

## What's recorded

Each track point currently includes latitude, longitude, altitude, and a timestamp — standard GPX `<trkpt>` fields, readable by any GPX-compatible mapping or analysis tool.

## Building it yourself

The project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the Xcode project from `project.yml`, and builds via GitHub Actions on a macOS runner, no local Mac required.

To build:
1. Go to the **Actions** tab → **Build GPX Recorder .tipa** → **Run workflow**.
2. Enter a version number (e.g. `1.0.0`).
3. Once the run finishes, download the artifact — it contains `GPXRecorder_v<version>.tipa`.

The app is unsigned by design (`CODE_SIGNING_ALLOWED=NO`, ad-hoc signed with `ldid`) since it's meant to be installed via TrollStore, which handles its own signing at install time.

## A note on GPS jitter

If you notice recorded points wobbling slightly (by a few meters) even while completely stationary, that's expected — it's normal GPS receiver noise (multipath reflections, atmospheric variation), not a bug. This app intentionally doesn't smooth or filter that out, since the goal is to capture what the device actually sees.

## License

No license specified yet.
