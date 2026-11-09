# Pawgrid 0.3.2+5 — garden capacity with soft conflicts

Prepared 9 November 2026. Android APK installed with `adb install -r` and launched; existing player data was not cleared. Earlier evidence: [v0.3.1](BUILD_REPORT_v0.3.1.md), [v0.3](BUILD_REPORT_v0.3.md), [v0.2](BUILD_REPORT_v0.2.md), [v0.1](BUILD_REPORT_v0.1.md).

## Changes

The only gameplay capacity precheck is now **one companion per garden**. Row, column and touching conflicts are accepted and saved as tentative moves. The companions remain on the board with red outlines and warning symbols when error highlighting is enabled; an accessible status message explains the rule. Clearing, hold-removal or Undo recomputes the warning. No hidden-answer check or solver-feasibility check is used during placement, and no life penalty is applied. Fixed clues, coordinates and completed-session guards remain.

Winning still requires exactly N companions satisfying all row, column, garden, no-touch and given rules. A full set with conflicts cannot win. Hints decline contradictory states. Gesture controls, animations, one-screen layout and grouped swipe Undo remain intact.

Pure Dart input policy is versioned `garden-capacity-v1`; [ADR 005](adr/005-garden-capacity-soft-conflicts.md) supersedes earlier placement restrictions. Maps to FR-002/004–007/013/021 and AC-01/02/03/04/09/10. PRD §4.3 soft warnings are restored for row/column/touching; the owner's one-per-garden restriction remains the scoped exception. No new dependency, plugin or architecture change.

No puzzle definition, solution, win rule, canonical hash, catalog content version, database schema or save format changed. Input-policy versioning is separate from territory-v1. Existing marks/history load unchanged, including older conflicting saves. The original PRD is unchanged.

## Checks actually executed

- **Pure Dart: 22 tests passed.** Fixture row/column/touching placements remain applied, serialize, Undo and remove correctly while visible conflicts are detected. Every fixture pair is rejected only for garden capacity. All 298 boards' initial candidates obey only the garden precheck, and every valid canonical completion still wins. A full conflicting set does not win and yields no hint. Negative fixtures, randomized command/stroke, independent Python parity, symmetry and integrity checks also pass.
- **Flutter: 33 tests passed.** Three new real-hold tests cover row, column and diagonal-touching placements in separate gardens. Both companions remain; outline, warning symbol and semantic conflict label appear; saved-session reopen retains the conflict; Undo removes the second companion and warning. Existing duplicate-garden, legal non-answer, fixed-clue, keyboard, screen-reader action, persistence/reward, swipe/Undo, animation, final-hold and small-screen/200%-text/landscape tests pass.
- **Android integration: 1 test passed**, 36 seconds after installation. Each row/column/touching pair stays placed with the correct textual warning and both warning symbols; conflicts survive save/reopen and clear after Undo. Garden capacity remains blocked without an added move. Non-answer guesses, completion, replay reward idempotency, next garden, swipe/Undo and pause/resume pass. Automation uses isolated `com.pawgrid.pawgrid.gesturetest`; the player's package was not reset or solved.
- **Static/format checks: PASS.** Flutter and pure Dart analysis: no issues. App 22 files and core 10 files: zero formatting changes.
- **Independent reference: PASS.** Python handoff verifier reports one unique solution `[1,4,2,0,3]`, connected regions and a valid hash.
- **Catalog: PASS.** 298 unique, connected, hash-verified, H1–H5 deducible boards: 200 Journey, 68 Daily, 30 Practice. Digest remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. PRD byte comparison unchanged.
- **Android release: PASS.** Correct primary application ID, version 0.3.2/code 5, API 26 minimum/36 target, signature verification and 16 KB ZIP alignment. No INTERNET/ad-ID/location/notification permission. Save-preserving installation and launch succeed; release-process native/Flutter startup error scan returned no errors. ZIP alignment does not certify a physical 16 KB-page device.

## Artifacts, size and platforms

- [ARM64 Android APK](../dist/Pawgrid-android-arm64.apk): **20,461,878 bytes (20.462 MB)**, **76 bytes larger** than v0.3.1. SHA-256: `98384a69314971af223d17ad4962da75346e0be9fffcf1ce3223878dfae54ff6`.
- [Android App Bundle](../dist/Pawgrid-android.aab): **56,771,394 bytes (56.771 MB)**, **2,511 bytes smaller** than v0.3.1. SHA-256: `ce954551682362028f0924704e588faa0dde9dbf923f0fc0c8ecf58d1032e969`.
- Both Android builds use the existing development certificate. Production signing remains required. Store-delivered size is unmeasured; these are local APK/upload sizes, not delivered-download budget certification.
- Size evidence: `size-v0.3.2/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **iOS attempt: FAILED**, exit 1, `Application not configured for iOS`. Full Xcode and owner signing remain unavailable; no signed IPA or iOS smoke test is claimed.
- Hardware/tooling: macOS ARM64, Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560. No physical-device performance or accessibility certification.

## Remaining requirements and next step

The requested Android behavior is complete and installed for playtesting. Existing production gates remain: physical TalkBack/VoiceOver/device/performance/low-storage checks, store-delivered measurements, human content/difficulty approval, production signing and final art/audio/localization/legal review. No new force-stop, battery or thermal campaign is claimed. Ads/purchases/analytics remain disabled; native vendor sandbox tests are not applicable to this update.

Next platform action: install full Xcode, configure owner signing, then produce a signed iOS build and device smoke test. The Android game is ready to test garden-only blocking and exploratory conflict warnings.
