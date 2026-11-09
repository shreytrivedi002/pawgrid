# Pawgrid build and verification report

Date: 8 November 2026. This is a playable offline game build; it is not a declaration that the PRD's public-store release definition of done has been met.

## Delivered

One Flutter/Dart application with Android and iOS projects, original vector garden/creature artwork, a five-stage tutorial, ten Journey chapter maps, UTC Daily calendar, Practice picker, explainable hints, Mark/Place input, undo, soft conflict explanations, pause/resume, progression, stars, seed ledger, cosmetic companions, statistics, preferences and local deletion.

Content: **298 independently validated boards** — 200 Journey, 68 dated Daily (2026-11-01 through 2027-01-07), 30 Practice. Every board has connected gardens, exactly one reference-solver solution, canonical SHA-256 content hash, and a complete H1–H5 deduction trace. The handoff sample is test-only. Duplicate symmetries are rejected except the two introductory 4×4 boards with teaching givens. Published difficulty labels remain provisional pending human playtesting.

No accounts, runtime generation, gameplay backend, ads, purchases, tracking or online requirements. Release Android manifest has no INTERNET permission. Optional vendor gateway interfaces have disabled implementations. Privacy text matches this build. English is the initial locale. Flutter draws all original artwork; Lora and Nunito Sans are bundled with OFL licenses.

`packages/puzzle_core` is immutable pure Dart and contains no Flutter, I/O, timers, time-zone reads, plugins or vendor/storage clients. The original PRD was copied byte-for-byte to `PRODUCT_REQUIREMENTS.md`; AGENTS.md and ADR 001 document the authorized Flutter architecture override.

## Executed checks and output

- Handoff reference command: **PASS** `fixture-5x5-unique-001`, one solution `[1, 4, 2, 0, 3]`, connected regions, matching canonical hash.
- `python3 tools/validate_catalog.py`: **PASS**, 298 unique, connected, hashed, deductively solved boards; validates saved deduction traces and symmetry uniqueness; synchronizes the mobile catalog, digest and compressed fallback.
- `python3 tools/property_qa.py`: **PASS**, **60,000** seeded layouts, 10,000 at each size 4×4–9×9. Checks connected partitions, exact labels, intended non-touching placements, and independently enumerated satisfiability. These generated test layouts are not shipped as content.
- Pure Dart `dart test`: **10 tests passed**. Includes exact handoff hash/rules, malformed/disconnected/corrupt/ambiguous rejection, all 298 catalog boards and deduction proofs, contradictory-state hint refusal, fixed-given protection, exact undo/save restoration, **100,000 randomized commands**, 72 independent Python exhaustive-enumeration parity cases at 4×4–9×9 (zero/one/multiple solutions), and all eight fixture rotations/reflections.
- Flutter `flutter test`: **10 tests passed**. Includes real SQLite transactions, redundant snapshot recovery, duplicate completion/replay reward protection, no Practice rewards, concurrent cosmetic spend idempotency, file-close/reopen persistence, corrupt catalog rejection, deletion, first-launch tutorial placement/undo, 9×9 semantic controls at 320×568 with 200% text, and home/settings at 200% text.
- Device `flutter test integration_test/game_flow_test.dart -d emulator-5554`: **1 device test passed** in 12 seconds after build/install. Exercises tutorial, placement, Undo, complete, duplicate replay protection, next-level unlock, pause timing and resume, then returns home.
- Real normal-entry Android app: **PASS**, actual force-stop → airplane-mode cold launch → force-stop retained identical committed marks, history, move/undo counts, puzzle hash and seed balance. The recorded board had 46 moves, one undo and 45 history entries. The check compares the existing board and never rewrites its solution or directly modifies save data. See `device-recovery-result.json`.
- `dart format --output=none --set-exit-if-changed .`: **PASS**, zero changes in both app and core after formatting.
- `flutter analyze`, standalone `dart analyze` on app and core: **PASS**, no issues.
- `dart run build_runner build --delete-conflicting-outputs`: **PASS**, Drift bindings generated. Current build_runner reports that the obsolete conflict flag is ignored; the command still regenerates successfully. No other generator was introduced.
- Original vector icon rendering utility: **PASS**, Android density icons, iOS icon sizes and preview generated from the in-game creature source.
- Release APK signing verification: **PASS**, development certificate (`CN=Android Debug`), suitable for local installation only.
- Android 16 KB ZIP alignment: **PASS**, `zipalign -c -P 16 4` (does not substitute for a real 16 KB page-size device test).
- Release native/Flutter error-log scan after launch: **no AndroidRuntime/flutter errors in the inspected log window**.
- `cmp` between copied PRD and handoff PRD: **PASS**, unchanged.

Initial failures were corrected: the widget-test harness needed real asynchronous asset/database work outside its fake clock; the 200% settings test exposed a Flutter Material/ListTile background assertion; both now pass. The first Android release attempt overlapped Flutter test tooling, and a subsequent `--no-pub` attempt retained a debug plugin registrant. In Flutter 3.47.5, `--no-pub` skips native tooling regeneration. Running release builds sequentially with default regeneration fixes the test-only plugin reference. No SDK or generated-plugin source was patched.

## Android build and size

- **Release APK: PASS**, installed and launched on the emulator with prior data preserved. Stable copy: `../dist/Pawgrid-android-arm64.apk`.
- **Release AAB: PASS**, `../dist/Pawgrid-android.aab`. Both artifacts use development signing; owner release signing and Play configuration remain mandatory.
- APK: **20,461,486 bytes (20.46 MB decimal)**, Flutter reports 20.5 MB. AAB: approximately **56.5 MB** across architectures; this is the bundle upload size, not a device download size.
- Device-delivered store download has **not** been measured. The 30 MB/50 MB budgets in AGENTS.md are delivered-download budgets; an APK under 30 MB is encouraging evidence, not a store-download pass or an approved exception.
- Size analysis is in `size/apk-analysis.json`, `size/snapshot.arm64-v8a.json`, `size/trace.arm64-v8a.json` and `size/release-footprint.json`.
- ARM64 native baseline: Flutter engine 11,747,864 bytes; Dart app AOT 5,637,000 bytes. Native SQLite 1,732,360 bytes; all included JNI libraries total 329,884 bytes. Bundled fonts are 799,152 bytes, catalog plus fallback occupy 159,059 compressed APK bytes. This is the first measured build, so no previous-app delta is available.
- Package: `com.pawgrid.pawgrid`, version 0.1.0+1; compile/target API **36**, min API **26**. Release manifest does not request network, ads identifiers, tracking, location or notification permissions; the only listed permission is Android's generated app-private dynamic-receiver permission.
- Emulator: existing Pixel 7 Pro AVD, `sdk_gphone64_arm64`, **Android 15 / API 35**, 1440×3120 at density 560; host macOS ARM64. Not a physical-device certification.
- One ADB cold Activity launch measured **1,013 ms**. This is an Activity launch measurement, not a p50/p95 install-to-play benchmark.
- One release memory snapshot: total PSS **100,245 KB**, RSS **200,928 KB**. No one-hour leak, battery or thermal study is claimed.
- Screenshots: `screenshots/android-release-home.png`, `screenshots/android-release-board.png`.

APK SHA-256: `e0fe9f75fecbdf5abc41b59b244506e7f89473877870e9ca5b3a8258c68150ad`.

AAB SHA-256: `432114b04ba53ddab1e440f4574f7cf175d035538064600462fafa2aa8019e82`.

## iOS status

The iOS project and 15.0 deployment target are present. Full Xcode is absent: `xcodebuild -version` fails because the selected directory is `/Library/Developer/CommandLineTools`. No Apple development team, signing profile, signed IPA or iOS device smoke test is available. `flutter build ipa --release` was actually executed and exited 1 with **“Application not configured for iOS”** after SDK artifact setup. The generated Xcode project exists; Flutter could not resolve an iOS buildable application in this environment. Full Xcode and owner signing must be configured and the command rerun. No signed IPA was produced. **iOS readiness is not claimed.**

## Requirement coverage and remaining release gates

Implemented/exercised offline scope maps to **FR-001–FR-016, FR-020–FR-021 and FR-024**, with these qualifications: FR-003/010 still need human editorial/playtest approval; FR-013 uses free explanation/apply hints rather than configured credits/rewarded ads; FR-016 currently has three companions and chapter maps, not the full commissioned art/audio inventory; FR-020 is English only; FR-021 has automated semantics/large-text checks and native accessibility-tree inspection, not a completed human TalkBack/VoiceOver study.

**FR-017–FR-019 and FR-022–FR-023 are not full store integrations**: no consent SDK, ad network, store purchase processing, remote-config provider or analytics/crash vendor is configured. Local conservative defaults and disabled gateway interfaces keep play offline and private. No purchases or ad rewards are advertised. These omissions are explicit, not product-owner-approved production exceptions.

Before public release:

1. Install full Xcode with the required iOS SDK, configure owner signing and build a signed IPA; smoke-test on iPhone and iPad. Configure owner Android release signing / Play App Signing.
2. Human-playtest/approve the content and difficulty curve, including late 9×9 boards; assess near-duplicate shapes and chapter pacing. The Daily pack needs an explicit future maintenance/replacement plan after 2027-01-07; outside coverage the app offers Practice rather than inventing a date's puzzle.
3. Complete physical Android/iPhone/iPad and real TalkBack/VoiceOver, large-text, low-storage, background/interruption and 16 KB page-size tests. Test at API 26 and API 36, not only this API 35 emulator.
4. Decide and implement any release-mandatory consent-aware diagnostics/ads/IAP through the gateways, with new SDK ADRs, disclosures and native sandbox testing. Keep them nonblocking and avoid selling ad removal while forced ads are absent.
5. Final brand clearance, support/legal URLs and policy text, licensed production art/audio/localization, human accessibility testing, store metadata, privacy audit, signed distribution and launch monitoring remain PRD §20 gates.

Actionable next step: use the installed Android build for playtesting; the engineering blocker for validating the second platform is full Xcode plus owner signing.
