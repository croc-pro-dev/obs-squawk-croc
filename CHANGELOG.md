# Changelog

All notable changes in **obs-squawk-croc** relative to the original [obs-squawk](https://github.com/royshil/obs-squawk) plugin.

The local clone was compared with [github.com/croc-pro-dev/obs-squawk-croc](https://github.com/croc-pro-dev/obs-squawk-croc) at commit `3b6ec2f`. Tracked source, CMake, and the previous README match that GitHub `master` tree. There were no unpublished source diffs to add. Untracked local-only files (`vcpkg.json`, `SIMDeConfig.cmake`, `master`, build outputs) are machine build helpers/artifacts, not plugin features.

## Unreleased

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
