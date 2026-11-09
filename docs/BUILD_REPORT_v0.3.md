# Pawgrid 0.3.0+3 — strict placement and animated fixed playfield

Prepared 9 November 2026. The updated Android APK is installed on the running emulator using a save-preserving update. APK/AAB are in `../dist/`. Historical evidence: [v0.2](BUILD_REPORT_v0.2.md), [v0.1](BUILD_REPORT_v0.1.md). These remain development-signed local playtest builds.

## Changes and requirement mapping

New companions must occupy their verified solution tile and satisfy garden, row, column and no-touch constraints. A garden accepts at most one new companion. Rejected attempts explain why and animate the tile without adding a companion, move, history entry or penalty. Holding an existing mutable companion removes it. The shared placement policy is deterministic pure Dart and applies to touch, keyboard and semantic placement. [ADR 003](adr/003-strict-placement-fixed-playfield.md) records the owner's scoped override of tentative companion placement. The original PRD remains byte-for-byte unchanged.

Tap toggles a cross; hold places/removes a companion; swipe paints or erases crosses with one Undo per stroke. Tap/Hold/Swipe share the board's width and center. Enlargement and panning are removed. The board, HUD, status and tools fit without scrolling; landscape uses a side panel. Pause and completion also fit. Optional selected-cell controls provide previous/next, place, mark and clear without precise holds. Help/hint sheets, settings and collection/history lists may scroll.

Bounded action feedback includes hold-charge rings, companion hop/squash/rotation, sparkles, drawn crosses, shrinking erased marks, rejection halo/shake, reactive companion expressions and the existing win flowers. OS/in-app reduced motion is respected; board animations stop while paused. No new dependency, native SDK, network call or puzzle content was added.

Maps to FR-002/004–007/014/021 and AC-01/04/08/09. The owner's decision supersedes acceptance assumptions about keeping newly conflicting companions on the board. Puzzle definitions, win predicates, solver, hints and hashes remain unchanged.

## Save compatibility and content

SQLite schema v1 and session JSON v2 are unchanged. Legacy v1/v2 snapshots load without silently deleting committed marks/history. Older invalid tentative companions can be removed; new placements use the strict policy. Contradictory-save fixtures still verify exact loading/removal. No solution was altered to obtain a screen state.

All 298 bundled boards remain: 200 Journey, 68 fixed UTC Daily, 30 Practice. Catalog SHA-256 remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`.

The existing profile showed 46 seeds, 9/20 completed gardens and Peaches selected after updating. Continue opened Level 10 successfully. The player was interacting during final visual review, so screenshots are observations of the live app, not a controlled comparison of marks. Automated device testing used the separate `com.pawgrid.pawgrid.gesturetest` package and did not reset or solve the player's package.

## Checks actually executed

- **Pure Dart: 20 tests passed.** Fixture/hash/negative tests, independent Python parity vectors, symmetries, catalog deductions, 100,000 randomized commands, 10,000 randomized strokes, grouped Undo/serialization and v1 compatibility. Five placement tests cover wrong tiles without mutation, duplicate gardens, line/touching conflicts, legacy removal and solving all 298 boards with at most one companion per garden.
- **Flutter: 30 tests passed.** SQLite/reward integrity; touch/drag/erase/cancellation, fixed clues, queued saves, keyboard/custom semantic actions; strict rejection; fitted layouts; bounded/reduced-motion reactions. Six layout scenarios cover 320×568 at 100%/200% text, 9×9 with selected-cell controls, 412×892, 640×360 landscape and 800×1024 at 200%. Guide/board alignment, visible controls and last-cell bounds are asserted. Compact pause/completion are checked at 200%.
- **Android integration: 1 test passed**, 18 seconds after installation. Rejected placement leaves no token/move; valid holds, swipe/Undo, final winning hold, replay reward idempotency, next garden, pause/resume and navigation pass.
- **Analysis/format: PASS.** Flutter and pure Dart analysis report no issues. Final format checks: app 22 files, core 10 files, zero changes.
- **Independent handoff reference/catalog: PASS.** Expected unique `[1,4,2,0,3]`, matching hash and connected gardens; all 298 catalog/hash/deduction/symmetry checks pass. Final catalog digest unchanged; PRD comparison identical.
- **Release visual/error inspection: PASS.** Installed screenshot reviewed: guide centered, no enlargement, board and tools visible. Release-process native/Flutter error scan returned no errors. A native UI hierarchy dump during live interaction could not reach idle; accessibility claims rely on passing widget/custom-action checks, not that failed dump.
- **APK inspection: PASS.** Primary ID `com.pawgrid.pawgrid`, version 0.3.0/code 3, min API 26/target API 36; signature verification and 16 KB ZIP alignment pass. No INTERNET, ad ID, location or notification permission, only the generated app-private receiver permission. ZIP alignment is not a physical 16 KB-device test.

The first native run caught an animation-controller call after the winning hold disposed the board before finger release. Mounted guards fixed it. A dedicated regression disposes the board with the finger still down; the final full suite and native rerun pass. A new-test lint was corrected before clean analysis.

## Artifacts, sizes and platforms

- **Android APK: PASS**, [ARM64 APK](../dist/Pawgrid-android-arm64.apk), **20,461,802 bytes (20.462 MB)**, 316 bytes smaller than v0.2.
- **Android AAB: PASS**, [App Bundle](../dist/Pawgrid-android.aab), **56,776,274 bytes (56.776 MB)**, 85,469 bytes larger than v0.2. This is a multi-architecture upload artifact.
- **Delivered-download budget: unmeasured.** Local APK/AAB sizes do not certify store-delivered size. Analysis: `size-v0.3/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **Signing:** existing Android Debug certificate. Production signing remains required.
- **iOS: FAILED / unverified.** `flutter build ipa --release` exits 1, `Application not configured for iOS`. `xcodebuild -version` confirms CommandLineTools without full Xcode. No signed IPA or iOS smoke test is claimed.
- **Hardware/tooling:** macOS ARM64; Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560. Automated layouts supplement the emulator; no physical-device certification.

APK SHA-256: `e90990c1ebc86f99a2b70bd8556fa33ff65befa3ca9ca642d9daab5291d681ff`.

AAB SHA-256: `fb7e2da94446faf88268864a2a098ac25baf726d4fc1859c8179b6cdae5d89c1`.

Visual evidence: [garden home](screenshots-v0.3/home.png), [live playfield](screenshots-v0.3/board.png).

## Remaining requirements and next step

The requested Android update is complete and installed. Physical TalkBack/VoiceOver validation, low-storage faults, physical device/performance/battery/thermal coverage, delivered-download measurements, human content/difficulty approval and production art/audio/localization/legal review remain release gates. No new force-stop campaign or physical frame-time benchmark is claimed. Animation tests verify bounded reactions and reduced motion, not physical-device 60 fps.

Ads, purchases and analytics remain disabled and do not block offline play; their native sandbox tests are not applicable to this change. The next platform step is full Xcode installation, owner signing and an actual signed iOS build/device smoke test. The Android release is ready for playtesting.
