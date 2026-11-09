# Pawgrid 0.6.1+10 — artwork and rendering fixes

Prepared 9 November 2026. Corrects the stretched win illustration, abrupt background edge above the game header and uneven board/button contours reported in the screenshots. Android APK and App Bundle built. Final APK installed with `adb install -r`; saved level 2, its 2/4 companions and seed balance remain present. Package: `com.pawgrid.pawgrid`.

## Changes

- Garden and companion painters now use one uniform scale and center the illustration within its available space. Circles stay round and companions retain their proportions in wide, short and constrained panels. Background panels still fill their available space independently. Win artwork takes a responsive 4:3 slot rather than stretching into a fixed 225-pixel height.
- Game backdrop now paints behind the full screen while controls remain inside SafeArea. This removes the abrupt status-bar/header seam without shifting interactive content into cutouts.
- Shared explicit curved paths draw button, panel, gesture-tag and board-frame contours. Border interpolation/value equality preserve normal interaction animations. Android rendering engine is unchanged.
- Board divisions are drawn once per shared edge as filled, pixel-aligned rectangles. This removes overlapping cell borders and uneven line junctions. Region labels, thick boundaries, focus/conflict indicators, cell geometry and semantic controls remain intact.
- System overlay styling is declared at the app level and for app bars. Android retains OS-managed navigation contrast: the transparent-navigation experiment had insufficient icon contrast on this emulator and is not shipped. Native window themes remain unchanged.
- Sound effects, motion graphics, reduced motion, first-launch guide, tap/hold/swipe, Undo, hints, one companion per garden and allowed soft conflicts are retained. No rule, schema, solution, save, reward, dependency, native SDK, permission or asset-download change. No icon regeneration.
- Maps to PRD FR-005/008/016/021, §14.2/14.3 and AC-08/09: stable input, tutorial, visual identity, responsive layout and noncolor accessibility. Catalog digest remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`.

## Tests actually executed

- **44 Flutter tests passed.** [Output](visual-quality-v0.6.1/flutter-tests.log). Includes existing gesture, sound, motion, persistence, tutorial and accessibility/layout tests. Two new rendered-image checks measure companion proportions at 400×300, 420×225, 360×265, 800×180 and 280×300, and verify the mascot silhouette remains centered and square under non-square constraints. These check rendered pixels, not only widget dimensions. An initial overly strict per-pixel comparison was replaced with silhouette bounds that tolerate normal edge antialiasing.
- Existing fixed-playfield tests pass at 320×568, 412×892, 640×360 and 800×1024, including 200% text, 9×9 boards, selected-cell controls, pause and completion. No gameplay scroll/full-screen option was added.
- **22 pure Dart core tests passed.** [Output](visual-quality-v0.6.1/core-tests.log). Catalog validator passes all 298 unique, connected, hash-verified and H1–H5 deducible boards. Unmodified handoff reference fixture passes with one solution `[1, 4, 2, 0, 3]`.
- **Android native visual scenario passed.** [Output](visual-quality-v0.6.1/android-visual-test.log). Runs in isolated `com.pawgrid.pawgrid.tutorialtest`, opens level 2, uses real holds to win, checks square board/header placement and settled animation, then visits Home, Daily and Friends. Five GPU-rendered Flutter-surface captures inspected: [board](visual-quality-v0.6.1/android-board.png), [completion](visual-quality-v0.6.1/android-completion.png), [Home](visual-quality-v0.6.1/android-home.png), [Daily](visual-quality-v0.6.1/android-daily.png), [Friends](visual-quality-v0.6.1/android-friends.png). Driver output includes the binding's additional reporting test; this is one authored app scenario, not multiple independent device cases.
- **Final release smoke passed.** Data-preserving install and launch, retained progress, full-screen status/header/nav contrast inspection, APK ID/version 0.6.1/code 10, signature and 16 KB ZIP alignment. Focused running-process error log is empty. [Release board including OS bars](visual-quality-v0.6.1/android-release-board.png), [release Home](visual-quality-v0.6.1/android-release-home.png).
- **Analysis/format passed.** [Flutter analysis](visual-quality-v0.6.1/analyze.log): no issues. Dart formatting: 36 files, zero changes. Final native themes parse as XML. No audio/ads/purchase adapter change; prior native audio evidence is in [v0.6](BUILD_REPORT_v0.6.md), not counted as a new run.

## Artifacts and platform status

- [ARM64 APK](../dist/Pawgrid-android-arm64.apk): **21,077,095 bytes (21.077 MB)**; unchanged packaged size from v0.6. SHA-256: `4fc9791eba9f298171b7a62b937dd34746561f8174e0faf1022a7a4b2f268f23`.
- [App Bundle](../dist/Pawgrid-android.aab): **57,579,545 bytes (57.580 MB)** upload; **+21,150 bytes** from v0.6. SHA-256: `f58c60c2b0d78a78a632ba06406eaeafbc9ca2bc04b92c4316b37b330313d6ce`.
- Development signing remains in use. Store-delivered download size remains unmeasured; these totals do not certify the delivered-download budget. [Footprint](size-v0.6.1/release-footprint.json) and `size-v0.6.1/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json` retain size evidence.
- **iOS build attempt failed**, exit 1: `Application not configured for iOS`. [Output](visual-quality-v0.6.1/ios-build.log). Shared Flutter fixes are implemented; iOS is not claimed compiled, signed or device-verified.
- Hardware: macOS ARM64; Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560; Android target API 36/min 26. GPU screenshots and widget tests do not replace physical-device performance/accessibility certification.

## Remaining requirements and next step

The reported visual defects are corrected and the Android update is installed. Full Xcode/owner signing and an iOS device smoke test remain the next platform step. Physical Android/iPhone/iPad/launcher/accessibility and frame-time matrix, store-delivered size, human puzzle playtesting and production signing remain public-release gates. No claim of completing every PRD production gate is made by this visual fix.
