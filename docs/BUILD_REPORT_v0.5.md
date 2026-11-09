# Pawgrid 0.5.0+7 — Figma visual remake

Prepared 9 November 2026. The Android APK and App Bundle compile successfully. APK installed using `adb install -r` without clearing the primary package and launched for review. Previous evidence: [v0.4](BUILD_REPORT_v0.4.md).

## Result and feature precedence

The [provided Figma Make reference](https://www.figma.com/make/b3T6aCDtXHXdMij9xeSqnG/Upgrade-Game-UI-Design) was inspected across home, gameplay, Journey, Daily, Friends and settings. Native Flutter now uses its midnight navy surfaces, cream typography, lime actions, lavender accents, pastel board colors, rounded outlined panels, capsule navigation and floating-island garden direction. Space Grotesk and DM Sans are bundled offline from Google's official font repository with their OFL licenses and in-app license entries. Floating-island artwork is CustomPainter vector drawing using the current equipped companion; later chapters retain a night accent. No WebView or remote runtime assets.

Latest application features take precedence over older Figma content. Keep 200 Journey levels, 68 UTC Daily boards, 30 Practice puzzles; tap cross / hold companion / swipe paint/erase; grouped Undo; garden-capacity-only blocking with soft row/column/touching warnings; guided first game and skip/resume; timer, pause, hints, progression, idempotent rewards, existing companion identities/prices, save/recovery and the full settings/accessibility/privacy controls. Do not restore Figma's obsolete Place/Mark tabs, 80-level pack or smaller settings panel. The fitted gameplay screen remains free of scrolling/enlargement. Home and secondary lists retain scrolling.

See [design mapping](FIGMA_REDESIGN.md). No core, solver, rule, puzzle/solution/hash, database/session schema or provider architecture changes. No native dependency or runtime network behavior added. The PRD stays unchanged. Requirement coverage: FR-005/008/009/011/012/014/016/021 and AC-04/08/09/10.

## Verification actually executed

- **Flutter: 36 tests passed**, final full suite after card refinements. Includes complete tutorial with skip/reopen, gestures and grouped Undo, garden-only capacity and soft warnings, saved reopen, SQLite/reward integrity, keyboard/custom semantic actions, reduced motion, final-hold disposal and small-screen/200%-text/landscape layouts. A footer overflow found during enlarged-text checks was corrected before the final passing run.
- **Pure Dart: 22 tests passed**, including unchanged rules/negative fixtures, all 298 boards/deductions, solver parity/symmetry, randomized commands/strokes and immutable save/Undo.
- **Android integration: 2 tests passed** in isolated `com.pawgrid.pawgrid.tutorialtest`: fresh tutorial to next garden (7 seconds after installation); gameplay (37 seconds) covering exploratory placement, all soft-conflict types, garden-capacity rejection, save/reopen/Undo, solving/replay rewards and pause/resume. The player's package was not reset or solved for testing.
- **Analysis/format: PASS.** Flutter analysis reports no issues. Final format check: 25 Dart files, zero changes.
- **Reference fixture/catalog: PASS.** Independent Python sample validator gives unique `[1,4,2,0,3]`, valid hash and connected regions. All 298 catalog boards are unique, connected, hash-verified and H1–H5 deducible. Digest unchanged: `353c9d8eb68306f90823a0b4f3824480d68a18593543df15a2a3647507342d31`. PRD comparison identical.
- **Contrast calculations:** cream text/navy 15.08:1; muted text/panel 6.54:1; dark text/lime CTA 14.42:1; dark board ink over all nine base garden fills at least 6.84:1. These measurements do not replace physical assistive-reader studies.
- **Installed release review: PASS.** Actual home, play card and saved board screenshots inspected; current marks opened without mutation. Guide remains centered and board/tools fit on one screen. Release-process Android/Flutter error scan returned no errors. Other screens inherit the same design system; no full physical-device visual certification is claimed.
- **APK inspection: PASS.** Primary package `com.pawgrid.pawgrid`, version 0.5.0/code 7, min API 26/target 36; signature verification and 16 KB ZIP alignment pass. No INTERNET/ad ID/location/notification permission, only the generated app-private receiver permission. ZIP alignment is not a physical 16 KB-page device test.

The previous temporary SDK was missing. Archive fetches failed, so Flutter 3.47.5 was restored from official source tag `6a19cca56475dbfba1478ee68d7bd0c2ef891da1`, with its standard engine/Dart downloads. No SDK source was patched and no dependency upgrade was introduced.

## Artifacts, size and platforms

- [ARM64 APK](../dist/Pawgrid-android-arm64.apk): **20,640,026 bytes (20.640 MB)**, **+178,016 bytes** over v0.4, including the two offline fonts. SHA-256: `7b24b07c80e4d69e04945182d90c24cb274fedd9984575a6f4556a7a18551b9b`.
- [App Bundle](../dist/Pawgrid-android.aab): **56,944,756 bytes (56.945 MB)**, **+138,861 bytes** over v0.4. SHA-256: `2613342b364504167d9c738420daea080bfa159232a82a5a3fb3817526e62686`.
- Both artifacts use the existing Android development certificate; production signing remains required. Local APK/upload size does not certify store-delivered download budgets; delivered size remains unmeasured.
- Size evidence: `size-v0.5/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **iOS build attempt: FAILED**, exit 1, `Application not configured for iOS`. `xcodebuild -version` confirms CommandLineTools without full Xcode. No signed IPA or iOS smoke test is claimed.
- Hardware/tooling: macOS ARM64, Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560.

Visual evidence: [home](screenshots-v0.5/home.png), [next-puzzle card](screenshots-v0.5/play-card.png), [saved board](screenshots-v0.5/board.png).

## Remaining gates and next step

Requested visual remake is complete and installed for Android playtesting. Physical TalkBack/VoiceOver/device/performance/low-storage checks, store-delivered size, human content/difficulty/design usability approval, production signing and final brand/legal/art/audio/localization review remain release gates. No new force-stop, battery/thermal or physical frame-time campaign is claimed. Ads/purchases/analytics remain disabled; native vendor sandbox tests are not applicable.

Next platform action remains full Xcode installation, owner signing and a signed iOS device smoke test. Review the installed Android remake against the linked Figma while exercising the latest features.
