# Pawgrid 0.3.1+4 — visible-rule placement correction

Prepared 9 November 2026. Corrected Android APK installed with `adb install -r`; existing player data was not cleared. The release was launched successfully. Historical reports: [v0.3](BUILD_REPORT_v0.3.md), [v0.2](BUILD_REPORT_v0.2.md), [v0.1](BUILD_REPORT_v0.1.md).

## Behavior and requirements

The previous input guard incorrectly rejected a locally legal guess merely because it differed from the hidden solution. That check and its “Not this tile” feedback are removed. Any nonconflicting mutable tile now accepts a companion, including a guess that leads to a later dead end. Only visible row/column/garden duplication, adjacent touching (including corners), fixed clues, bounds and completed-session guards block new input. Players can rethink with hold-to-remove or Undo.

Touch, keyboard, selected-cell controls and screen-reader actions share the corrected pure Dart `visible-rules-v1` policy. One companion per garden remains enforced. Help and README explain the corrected behavior. Layout, animations, cross gestures and grouped Undo remain unchanged. [ADR 004](adr/004-visible-rule-placement.md) supersedes ADR 003's hidden-answer restriction and restores PRD §4.3's explicit rule against judging nonconflicting guesses by a hidden answer. The owner's visible-conflict rejection requirement remains in force instead of optional soft warnings. Maps to FR-002/004–007/021 and AC-01/02/03/04/10.

No win rule, puzzle definition, content version/hash, schema or save format changes. Input policy versioning is separate from `territory-v1`. Existing marks/history are preserved. The PRD is unchanged. No new dependency, plugin, native SDK or network behavior.

## Checks actually executed

- **Core: 21 tests passed.** Includes a non-answer guess with no possible completion that is nevertheless accepted, removable and undoable; every fixture exploratory pair agrees exactly with visible conflicts; every initial candidate on all 298 boards is accepted iff it obeys visible constraints; all boards still solve with at most one companion per garden. Existing negative fixtures, hash/schema, independent Python parity/symmetry, randomized commands/strokes and save/Undo checks pass.
- **Flutter: 30 tests passed.** Real hold accepts a non-answer move and Undo restores it. Keyboard and actual custom screen-reader action also accept non-answer placement. Duplicate-garden rejection, persistence/rewards, swipe/cancel/erase/Undo, fixed clues, final-hold disposal, reduced motion and all small-screen/200%-text/landscape layouts pass.
- **Android integration: 1 test passed**, 23 seconds after installation. A non-answer hold is accepted, saved and reopened unchanged; a second companion in its garden is rejected without a move; Undo removes the guess. Completion/replay rewards, next garden, swipe/Undo and pause/resume also pass. Automation uses `com.pawgrid.pawgrid.gesturetest`, separate from the player's package.
- **Static checks: PASS.** Flutter and pure Dart analysis: no issues. Formatting: 22 app files and 10 core files, zero changes.
- **Reference fixture: PASS.** Unique `[1,4,2,0,3]`, connected regions and valid hash via the independent Python reference solver.
- **Catalog: PASS.** All 298 unique, connected, hash-verified, H1–H5 deducible boards; 200 Journey, 68 Daily, 30 Practice. Digest remains `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. PRD byte comparison unchanged.
- **Android release: PASS.** Primary package `com.pawgrid.pawgrid`, version 0.3.1/code 4, min API 26/target 36; signature verification and 16 KB ZIP alignment pass. No INTERNET/ad ID/location/notification permission. Installed successfully without clearing data; release-process native/Flutter startup error scan returned no errors.

## Artifacts, size and platform status

- [Android ARM64 APK](../dist/Pawgrid-android-arm64.apk): **20,461,802 bytes (20.462 MB)**, exactly the same packaged size as v0.3. SHA-256: `afb2a08d37ff29ebb5733c400bcc0c2dbc195151f425d488f83ffe9597ae0dc5`.
- [Android App Bundle](../dist/Pawgrid-android.aab): **56,773,905 bytes (56.774 MB)**, 2,369 bytes smaller than v0.3. SHA-256: `7a1b3ae021f86ce079d1cbffcdef80802c552256742b5b9082564def98afa98b`.
- Both Android builds use the existing development certificate. Owner-controlled production signing remains required. Download budgets are store-delivered measurements, not these upload/local sizes; delivered size is unmeasured.
- Size analysis: `size-v0.3.1/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **iOS build attempt: FAILED**, exit 1, `Application not configured for iOS`. Full Xcode/signing remain unavailable; no signed IPA or iOS smoke test is claimed.
- Hardware: macOS ARM64; Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 AVD, Android 15/API 35, 1440×3120 at density 560. No physical-device certification.

## Remaining requirements and next step

The placement correction is complete and installed for Android playtesting. No player puzzle was solved/reset for testing. The next platform step remains full Xcode installation, owner signing and a signed iOS device smoke test. Existing production gates remain: physical accessibility/device/performance/low-storage checks, delivered-download measurements, human content/difficulty approval, production signing and final brand/legal/art/audio/localization review. Ads/purchases/analytics remain disabled; native vendor tests are not applicable to this correction. Historical visual evidence is in the v0.3 report; this behavior fix makes no new visual redesign claim.
