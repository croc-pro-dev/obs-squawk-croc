# Changelog

All notable changes in **obs-squawk-croc** relative to the original [obs-squawk](https://github.com/royshil/obs-squawk) plugin.

## 0.1.6 — 2026-08-25

Windows CI: `find_package(libobs)` now finds `libobsConfig.cmake`, but that file `find_dependency(w32-pthreads)` and CMake 4.2 does not search OBS’s flat `${prefix}/cmake/` layout. Set `w32-pthreads_DIR` next to `libobs_DIR`.

## 0.1.5 — 2026-08-25

Windows CI: nested OBS 30.1.2 is configured with `OBS_CMAKE_VERSION=3.0.0` so `libobsConfig.cmake` is actually generated (`2.0.0` was the legacy `cmake/Modules` path). Plugin prefix includes the OBS build tree. macOS CI: `macos-15` + Xcode 16.4 (Xcode 15.2 is gone on GitHub runners).

## 0.1.4 — 2026-08-25

CI: after OBS 30.1.2 builds, `find_package(libobs)` failed because CMake 4.2 dropped the `Development` install component when a second `--component` was passed, and `CMAKE_PREFIX_PATH` was stored as a single `PATH`. Install Development and Windows libs separately; keep the prefix as a list; set `libobs_DIR`.

## 0.1.3 — 2026-08-25

Windows GitHub Actions stays on **Visual Studio 18 2026** (`windows-2025`). OBS 30.1.2 is configured with `ENABLE_SCRIPTING=OFF` and CMake policy CMP0175 OLD so CMake 4.2 can generate that tree. Compiler warnings are not fatal on CI (`CMAKE_COMPILE_WARNING_AS_ERROR` off).

## 0.1.2 — 2026-08-25

CI: install CMake 4.2+ on the Windows runner so the Visual Studio 18 2026 generator works. macOS is `continue-on-error` so a missing Xcode 15.2 image does not block the GitHub Release.

## 0.1.1 — 2026-08-25

First GitHub Actions release after workflows were enabled on the fork. Same plugin as 0.1.0; this tag exists so CI can publish the Windows (and other) artifacts.

## 0.1.0 — 2026-08-25

First tagged snapshot of this fork. No GitHub Release assets were published from this tag (Actions was still disabled).

### Build

- Removed hardcoded `C:/dev/obs-studio` and `C:/dev/obs-deps` CMake paths. Local OBS is found through `CMAKE_PREFIX_PATH`, optional `OBS_STUDIO_DIR` / `OBS_DEPS_DIR`, and `w32-pthreads_DIR`.
- Windows generator stays **Visual Studio 18 2026**. GitHub Actions Windows job uses `windows-2025`.
- LibArchive comes from vcpkg when a toolchain file provides it, otherwise from the original FetchContent helper.

### Documentation

- Replaced the original “stalled” README (still pointing at occ-ai / locaal-ai downloads) with fork-specific docs: features, usage, Auto-Voice, file tracking, and Windows 2026 build notes.
- Documented that the tracked chat file is emptied every time OBS is opened.

### Added

- **Persistent file tracking.** New **Tracked Text File (Input)** and **State File (Memory)** properties. Only bytes after the stored offset are read, instead of re-reading the whole file on every change.
- **Chat file emptied on OBS open.** When the Squawk source is created (OBS startup, or adding the source), the tracked text file is truncated and the state file is written as `0`. A new session always starts from a clean log.
- **Auto-Voice Assignment.** Per-viewer speaker IDs from a limited pool, stored in a memory file.
  - Properties: Total Pool Size, Memory File, Blocked IDs File, Owner Chat Name.
  - Lines of the form `ViewerName: message`.
  - Stream owner always uses the default Speaker ID and is not stored in the memory file.
  - Owner commands: `!change Name`, `!delete Name`.
  - Bypass mode (pool size `0` or no memory file): every line uses the default Speaker ID.
- **OBS tick watcher** (~500 ms) for the tracked file (`CheckForNewTextLines`), replacing the old full-file poll in `InputThread`.

### Fixed

- **Audio stability.** Robotic / distorted OBS monitor playback. Audio is now pushed in 20 ms chunks with continuous timestamps (`os_gettime_ns` / `os_sleepto_ns`) and no idle silence frames.
- **Empty UI fields crashing OBS.** `obs_data_get_string` results are handled so empty paths do not throw `std::logic_error`.
- **Phonetic transcription.** Standalone-letter regex now escapes `\b` (`\\b[a-zA-Z]\\b`), so letters are actually rewritten.
- **Property buttons on current OBS / Qt.** `obs_properties_add_button` replaced with `obs_properties_add_button2`.

### Changed

- File watching was removed from `InputThread`. OBS text-source monitoring, line-by-line, and debounce still work on that path.
- Windows build retargeted to Visual Studio 18 2026, required Qt 6, vcpkg LibArchive, and local OBS/Qt CMake paths.
- `speaker_id` treated as `uint32_t` in the Generate Audio button path.
- Plugin load/unload exported with `MODULE_EXPORT`.
