# Pawgrid 0.6.0+9 — sound and motion

Prepared 9 November 2026. Android APK and App Bundle built successfully. The APK is installed on the running emulator using a data-preserving update and launches with existing progress. Package remains `com.pawgrid.pawgrid`.

## Changes and requirements

- Eight original bundled effects: cross, erase, companion, swipe, Undo, soft warning, hint and win. Each committed command produces one cue; one swipe/Undo does not produce a cue per tile. Rejected garden-capacity attempts receive a soft warning. Visible conflicts can sound a warning; legal exploratory guesses are never compared with the answer.
- Saved sound switch, volume slider and preview in Settings. Default sound on at 70%, with additional native headroom. Mute, zero volume, pause and background stop voices; resume does not replay old cues. Audio failure cannot interrupt input, persistence or rewards.
- Placement blooms and garden traces, cross/erase rings, swipe and Undo ribbons, companion reactions, floating-island entrance and orbital petal/star win flourish. New board effects last 760 ms, island reveal 1 second and celebration 1.8 seconds. They settle without idle loops, preserve hit geometry and honor app/OS reduced motion. Background TickerMode suspends Flutter motion.
- Optional native OS audio gateway: Android SoundPool (four voices), iOS AVAudioPlayer with ambient audio session. No added package, native plugin dependency, recording/network permission, SDK, generator framework, background music or runtime download. [ADR 006](adr/006-offline-sound-and-motion.md) records the decision before implementation.
- Reproducible original tones via `python3 tools/build_audio.py`, using only the standard library. Eight mono 22.05 kHz/16-bit PCM WAVs total **152,500 bytes**. No third-party recordings or license dependency. Native frameworks are OS-provided; system audio overhead is unmeasured.
- PRD §5.3/§15 audio/feedback; FR-005 input, FR-008 tutorial, FR-014 lifecycle, FR-016 visual identity, FR-021 accessibility. Regression checks support AC-04 recovery and AC-08/09/10 layout, color independence and tentative-conflict persistence. Current gestures, first-launch guide, one companion per garden, allowed soft conflicts, fitted board, schemas and reward policy remain intact. Session epoch is transient UI state only.
- Catalog SHA-256 remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. No puzzle, solution or rule revision.

## Checks actually executed

- **Flutter: 42 passed.** Existing layout/accessibility/gesture/storage/progression tests plus six new tests for cue classification, timer/reopen suppression, one cue per saved command, persisted mute/volume, audio failure, foreground/pause behavior, stable hit rectangles and finite/reduced motion. An initial disposal-time provider access error was fixed by retaining the gateway; the complete suite then passed. [Output](feedback-v0.6/flutter-tests.log).
- **Pure Dart core: 22 passed.** Includes all 298 puzzles, deduction proofs, randomized session/save/undo commands, negative cases and independent solver vectors.
- **Catalog/reference: PASS.** Validator: 298 unique, connected, hash-verified, H1–H5 deducible boards (200 Journey, 68 Daily, 30 Practice). Handoff reference solver: fixture-5x5-unique-001, one solution `[1, 4, 2, 0, 3]`, connected regions and valid hash.
- **Android integration: 3 passed**, sequential runs in isolated package `com.pawgrid.pawgrid.tutorialtest`. [Audio/motion](feedback-v0.6/android-audio-motion.log): eight samples loaded and eight playback streams accepted with OS muted=false; explicit stop, zero volume, sound settings, committed command feedback, pause, reduced motion, animated win and settled completion passed. Existing [fresh tutorial](feedback-v0.6/android-tutorial.log) and [game/save/reward flow](feedback-v0.6/android-game-flow.log) also passed. Playback submission is verified; a human listening assessment is not claimed.
- **WAV validation: PASS.** Expected format, non-clipping peaks (-15.3 to -9.5 dBFS before effect/native gain) and quiet boundaries. All eight are bundled uncompressed for SoundPool descriptors; device loading verified.
- **Analysis/format: PASS.** Flutter analysis: no issues. Dart formatting: 32 files, zero changes. [Analysis](feedback-v0.6/analyze.log).
- **Release checks: PASS.** Correct ID/version 0.6.0/code 9, valid APK signature and 16 KB ZIP alignment. Manifest has only the existing app-specific non-exported receiver permission; no new microphone/internet/runtime permission. `adb install -r` succeeds, release launches, retained progression/balance is visible, and focused process error log is empty. [Home](feedback-v0.6/android-home.png) and [sound settings](feedback-v0.6/android-sound-settings.png) visually reviewed.

## Artifacts and platform status

- [ARM64 APK](../dist/Pawgrid-android-arm64.apk): **21,077,095 bytes (21.077 MB)**, **+366,989 bytes** over v0.5.1. SHA-256: `dd6c7078e84c07172fedc808faabf96f0754cb077093e3e2ec3db51a3d1b28b0`.
- [Android App Bundle](../dist/Pawgrid-android.aab): **57,558,395 bytes (57.558 MB)** upload, **+544,104 bytes** over v0.5.1. SHA-256: `d63fe15fafcac4ee409ef7f324b1eb68df1f7d7aa98b17ba8da1c817bd69e967`.
- Both use the existing development signing certificate. Store-delivered download size is **unmeasured**; APK/upload totals do not certify PRD download budgets. [Footprint](size-v0.6/release-footprint.json), `size-v0.6/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json` retain measurements.
- **iOS release attempt: FAILED**, exit 1, `Application not configured for iOS`. [Output](feedback-v0.6/ios-build.log). The iOS audio adapter is implemented but not compiled/type-checked by full Xcode or device-tested. A separate Swift parser attempt encountered duplicate SwiftBridging modules in this command-line-tools environment and supplies no successful validation claim.
- Hardware: macOS ARM64; Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560; Android target API 36/min 26, iOS target 15.0. Physical frame-time, audio latency, power, memory and 16 KB-page performance are unmeasured.

## Remaining requirements and next step

Requested Android sound/motion update is complete, built and installed. Next platform step: full Xcode/owner signing, signed iOS build, then physical audio/silent-switch/interruption smoke testing. Physical Android audio/ringer/headphone checks, TalkBack/VoiceOver completion, small-device/performance matrix, human puzzle playtesting, store-delivered size and production signing remain release gates. Ads/purchases were not touched; vendor sandbox tests are not applicable. Previous icon evidence: [v0.5.1](BUILD_REPORT_v0.5.1.md).
