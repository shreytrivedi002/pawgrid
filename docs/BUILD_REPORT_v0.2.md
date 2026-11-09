# Pawgrid 0.2.0+2 — gestures and game UI

Prepared 8 November 2026. Updated APK/AAB are in `../dist/` and the release APK is installed on the existing Android emulator. This is a local playtest build with development signing. The [v0.1 report](BUILD_REPORT_v0.1.md) preserves the original build evidence and release-gate history; its artifact hashes are historical.

## Changes

The owner's request replaces the default mode tabs: **tap for a cross, hold for a creature, swipe to paint or erase crosses**. Starting on empty paints; starting on a cross erases. Interpolated hit testing covers cells crossed by fast movements. Revisits do not toggle a tile repeatedly. Creatures and givens are protected during swipes. Cancelled strokes commit nothing. One completed swipe is one core command, save and Undo.

Input is serialized behind pending SQLite saves so timer commits do not drop rapid inputs. Screen-reader Actions can place/remove a creature, mark/remove a cross, or clear a tile. Keyboard P / Enter / Backspace provides the same alternatives. Enlarged boards have an explicit Move board switch to separate painting from panning. Tutorial copy and the on-board guide explain the new gestures; the obsolete Quick placement preference was removed.

The visual update replaces the editorial cream/serif presentation with rounded heavy type, an illustrated sky/meadow/cottage scene, selected companion, chapter progress, a prominent gold Play button, a timber board frame, pastel raised tools, creature placement animation and a bounded flower celebration. OS/in-app reduced motion and noncolor garden labels remain supported. All new art is original Flutter vector drawing; no new dependencies, plugins, network calls or downloaded runtime assets were added.

Design guidance came from Anthropic's official [frontend-design skill](https://github.com/anthropics/skills/tree/main/skills/frontend-design), discovered through the skill directory and read before implementation. See [design decisions](DESIGN_UPDATE.md) and [session/gesture ADR](adr/002-gesture-strokes-and-session-v2.md).

## Save compatibility and content integrity

Session JSON is v2, with optional per-command history group IDs. The reader accepts v1 and v2 and retains previous marks, time, counters and undo history. Save payload checksums are recomputed during normal commits and redundant previous snapshots remain available. SQLite schema stays v1. No puzzle solution, region, rule or canonical content hash changed. Forward save upgrades are supported; downgrading to an older app is not promised.

All 298 boards remain bundled: 200 Journey, 68 fixed UTC Daily, 30 Practice. Catalog SHA-256 remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. The sample fixture remains test-only.

The release was installed with `adb install -r`, without clearing the original package. Native inspection before and after the update showed the existing **46-seed balance** retained. The updated home displayed **9/20 completed gardens**, continued Level 10, and retained the selected Peaches companion. The existing save opened successfully in the new release without a recovery/error message. Device integration tests ran as `com.pawgrid.pawgrid.gesturetest`, separately from the player's package.

## Checks actually executed

- **Pure Dart: 15 tests passed.** Existing handoff fixture, hash/rules, all 298 boards/deductions, negative fixtures, 72 independent exhaustive Python parity vectors, eight symmetries, 100,000 randomized session commands; plus grouped paint/erase/undo/serialization, v1 compatibility, invalid group rejection and 10,000 randomized strokes.
- **Flutter: 19 tests passed.** Real SQLite, duplicate rewards, spending, corrupt snapshots/catalogs, deletion, tutorial hold placement/undo, 9×9 semantics and small-screen 200% text; touch tap/hold, sparse/revisited drags, erase, cancellation, clue/creature protection, queued taps, explicit zoom panning, keyboard input and actual custom semantic-action invocation.
- **Device integration: 1 test passed**, 15 seconds after installation. Real hold placements, swipe across several cells and whole-stroke Undo, solving, replay reward protection, next-level unlock and pause/resume timing. Test package ID verified from the APK before installation.
- **SQLite file-close/reopen: PASS.** A grouped swipe is restored exactly after closing the database and opening the file again, and one Undo restores the state preceding the whole swipe.
- **Static checks: PASS**, `flutter analyze` and `dart analyze` on the core report no issues. Formatting check reports zero changed files.
- **Independent sample: PASS**, expected unique `[1,4,2,0,3]`, connected gardens and matching hash. `tools/validate_catalog.py`: **PASS**, all 298 boards/hash/deduction/symmetry checks; catalog digest unchanged.
- **Native release inspection: PASS**, screenshots visually reviewed; accessible cell labels include row, column, garden and mark; native/Flutter error-log scan returned no errors in the inspected window.
- **Android 16 KB ZIP alignment: PASS**, `zipalign -c -P 16 4`. This is not a physical 16 KB page-size-device test.
- **Release permissions:** no INTERNET, advertising ID, location or notification permission. Only the generated app-private dynamic-receiver permission is listed.

Early compile checks caught a missing semantics import; it was corrected before final passing tests. Final checks did not leave failures suppressed or tests skipped.

## Artifacts, size and platforms

- **Android APK: PASS**, `../dist/Pawgrid-android-arm64.apk`, **20,462,118 bytes (20.462 MB)**. The v0.1 baseline was 20,461,486 bytes: **+632 bytes** for the complete update. ELF alignment/padding and removed old UI code mean per-component AOT changes need not equal APK size changes.
- **Android AAB: PASS**, `../dist/Pawgrid-android.aab`, **56,690,805 bytes (56.691 MB)** multi-architecture upload. Both artifacts use the existing development signing certificate; owner-controlled production signing is still required.
- **Store-delivered download: unmeasured.** APK/upload sizes do not certify the delivered-download budgets.
- **iOS: build attempt FAILED**, `flutter build ipa --release` exits 1, `Application not configured for iOS`. Full Xcode is still absent (`xcodebuild -version` identifies command-line tools only), and owner signing is unavailable. No signed IPA or iOS smoke test is claimed.
- Hardware: Pixel 7 Pro AVD, ARM64 Android 15/API 35, 1440×3120 at density 560, on macOS ARM64. Large-text widget checks also use 320×568 at 200% text. These are emulator/automated checks, not physical-device certification.
- Size analysis: `size-v0.2/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`. No new native SDK was introduced; there is no new runtime network footprint.

APK SHA-256: `fa3ff9291c2552a81cbd3981ccee60c80c8c68cbb2897f6461b2d52113700b86`.

AAB SHA-256: `42addd63524160106351a98d996b99cf45f036b6992b9234762f6960e8121b60`.

Visual review: [home](screenshots-v0.2/home.png), [board](screenshots-v0.2/board.png).

## Remaining requirements and next step

This request addresses FR-004–006, FR-014 and FR-021 with AC-04/08/09/10 coverage; §4 rules and content stay intact. Physical TalkBack/VoiceOver user studies, low-storage fault tests, the full physical-device matrix and delivered-download measurements remain release gates. No claim is made that this update reran the baseline one-hour/battery/thermal or real force-stop campaign; new grouped history is covered by core, widget, SQLite reopen and device interaction tests.

The existing store-launch gates remain: full Xcode/iOS signing/device smoke; production Android signing; human content/difficulty approval; final brand/legal/support/localization/art/audio review; and any desired consent-aware analytics, ads or purchases through the disabled gateway interfaces. Those vendor features stay disabled and do not block play.

Next action: playtest the installed gesture update. The concrete blocker to validating iOS is installing full Xcode and configuring owner signing.
