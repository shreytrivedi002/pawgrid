# Pawgrid 0.4.0+6 — one easy guided first game

Prepared 9 November 2026. Android APK/AAB compiled. The APK was installed with `adb install -r` and launched without clearing the existing player's package. Historical evidence: [v0.3.2](BUILD_REPORT_v0.3.2.md) and earlier reports.

## Changes

First-time players enter one easy, bundled 4×4 garden with two fixed companions. A welcome introduces the goal; five short, action-driven steps teach tap for a cross, swipe across two cells, whole-swipe Undo, hold for a companion and the final placement. Copy explains one friend per row, column and lettered garden, with no touching even at corners. Gold outlines, pointer symbols, semantic target labels and written coordinates identify the relevant tiles. See [walkthrough design](FIRST_GARDEN.md).

The instructions advance after saved player actions, without placing tokens for the player or restricting ordinary input. The previous garden-capacity-only blocking and soft row/column/touching warnings remain. Skip guide is available. Step and skip preferences use existing SQLite-backed settings. Reopening an unfinished first game retains its committed board and lesson step; completing the first garden prevents automatic tutorial entry on later launches. Existing players with first-level progress are not interrupted. Short layouts/enlarged text use compact guidance and a full readable help dialog.

Maps to FR-008/005/006/021 and PRD §7.1, §4.3, with existing Undo/layout/accessibility acceptance coverage. The owner's request consolidates the practical introduction into one game; later tutorial-tier levels stay in Journey. The original PRD is preserved. No puzzle solution/definition/hash, win rule, input policy, database/session schema, native dependency or network behavior changed. The script is bound to the unchanged first-level hash so it cannot silently coach a different board.

## Checks actually executed

- **Flutter: 36 tests passed.** Three new tests exercise the complete tap/swipe/Undo/hold/hold walkthrough at normal text on 412×892 and 200% text on 320×568, persisted step, widget/session reopen, full instruction dialog, completion, suppression after completion, and persisted skipping. Existing gesture, soft conflict, SQLite/reward, keyboard/semantic actions, reduced-motion, final-hold disposal and fitted-layout tests pass.
- **Pure Dart: 22 tests passed.** Rules/negative fixtures, garden-only capacity, soft conflicts, all 298 definitions/deductions, independent solver parity/symmetries, randomized commands/strokes and immutable save/Undo checks.
- **Android integration: 2 tests passed.** Fresh-install walkthrough: 8 seconds after installation, all five steps, win and next garden with no coach. Normal gameplay: 51 seconds, including legal guesses, garden capacity, soft row/column/touch warnings, save/reopen/Undo, solving/replay ledger and pause/resume. Both ran in isolated `com.pawgrid.pawgrid.tutorialtest`; APK ID was inspected. The first run's cleanup attempted a stale cached test ID and reported an uninstall failure; the later run cleaned up the actual test package. Final native package inventory showed only the player's primary package remaining.
- **Static analysis: PASS**, final Flutter analysis reports no issues. **Format: PASS**, 25 app Dart files, zero changes.
- **Reference verifier: PASS**, unique `[1,4,2,0,3]`, connected regions and valid content hash.
- **Catalog: PASS**, 298 unique, connected, hash-verified, H1–H5 deducible boards: 200 Journey, 68 Daily, 30 Practice. Digest unchanged: `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. PRD byte comparison unchanged.
- **Android release: PASS**, primary ID `com.pawgrid.pawgrid`, version 0.4.0/code 6, min API 26/target 36; signature and 16 KB ZIP alignment verified. No INTERNET/ad ID/location/notification permission. Save-preserving update and launch succeeded; release-process native/Flutter startup error scan was empty. Alignment is not physical 16 KB-device certification.

Early checks caught a new listener lint and an enlarged-text instruction row consuming too much board space. Both were corrected; final analysis, complete walkthroughs and full suite pass. No failed assertions were suppressed.

## Artifacts, sizes and platforms

- [Android ARM64 APK](../dist/Pawgrid-android-arm64.apk): **20,462,010 bytes (20.462 MB)**, **132 bytes larger** than v0.3.2. SHA-256: `62ef22b4b435017c4fc458bff7534ad31f0869757d56654f614e6f4eed7445e7`.
- [Android App Bundle](../dist/Pawgrid-android.aab): **56,805,895 bytes (56.806 MB)**, **34,501 bytes larger** than v0.3.2. SHA-256: `18e6c1cf30324101538820357a2fa1218e15987f589b314c25c9dea00a2f593a`.
- Both use the existing development certificate; production signing remains required. Store-delivered size is unmeasured; local APK/upload size does not certify delivered-download budgets.
- Size analysis: `size-v0.4/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **iOS attempt: FAILED**, exit 1, `Application not configured for iOS`. Full Xcode and owner signing remain unavailable. No signed IPA or iOS smoke test is claimed.
- Hardware: macOS ARM64, Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 AVD, 1440×3120 at density 560. Widget tests supplement the emulator; no physical-device certification.

## Remaining requirements and next step

The requested first-game tutorial is complete and the Android update is ready for playtesting on a fresh profile. Existing progress is preserved; it is not reset to demonstrate onboarding. Human novice playtesting is still needed to validate comprehension. Physical TalkBack/VoiceOver/device/performance/low-storage checks, store-delivered measurements, human content/difficulty approval, production signing and final art/audio/localization/legal review remain launch gates. Widget reopen/persisted preferences are tested; a new tutorial-specific OS force-stop campaign is not claimed. Ads/purchases/analytics remain disabled; native vendor sandbox tests are not applicable.

Next platform action: install full Xcode, configure owner signing and run a signed iOS device smoke test.
