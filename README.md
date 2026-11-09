# Pawgrid

A calm, fully offline garden logic game for Android and iOS, implemented in **Flutter + Dart**. One sprout creature per row, column and irregular lettered garden; creatures must not touch, including diagonally. Distant diagonals are allowed.

## Play

Flutter **3.47.5**, Dart **3.13.4**, Android SDK/API **36**, NDK **28.2.13676358**, Java **21** were used for this build. The Android runtime minimum is API 26; iOS deployment target is 15.0. `pubspec.lock` files pin the resolved dependencies. `tools/flutterw` enters the app folder automatically and uses an installed SDK, `$FLUTTER_SDK`, or the temporary SDK installed for this task.

```sh
./tools/flutterw pub get
./tools/flutterw run -d emulator-5554
```

**Tap** a tile to add/remove a cross. **Hold** to place/remove a creature. **Swipe** from an empty tile to paint crosses, or from a crossed tile to erase them. Creatures and fixed clues are skipped during a swipe. One Undo reverses the entire stroke. Marking is tentative, Undo is free, and hints explain a deduction. The board, centered gesture guide and tools fit on one screen without enlargement or scrolling. Each garden accepts at most one companion. Placements that share a row, column or touch are allowed and saved with warning outlines, symbols and a rule explanation; remove or Undo them when rethinking. The hidden solution never judges a guess. All rules must be satisfied to finish. Fixed clues stay locked. Optional **Selected-cell controls** in Settings provide previous/next, place, mark and clear actions without precise holds. Screen-reader Actions and keyboard P / Enter / Backspace also support placing, marking and clearing. Back pauses; every committed move is saved. First launch opens one easy 4×4 guided garden: tap a cross, swipe two cells, Undo, then hold to settle the last two companions. Gold target tiles, row/column directions and short explanations teach the rules. Guide progress is saved; Skip guide is available, and completed players go straight to their garden. Larger text uses compact guidance with full instructions behind the help button.

## Included

- 200 Journey puzzles across ten chapters; 68 fixed UTC-date Daily boards (2026-11-01 to 2027-01-07); 30 Practice boards covering 5×5 through 9×9.
- Offline save/resume, immutable undo, pause/background-aware timing, unique-solve progression, stars, idempotent seed grants and three original cosmetic companions.
- Figma-derived midnight/lime design, Space Grotesk and DM Sans fonts, floating-island garden home, lavender board frame, tactile tools, hold-charge feedback, companion hops, animated cross strokes/erasing, rejection wobble and bounded flower celebration. Original Flutter-drawn scenery, vector launcher artwork and bundled OFL fonts. No runtime font or asset downloads.
- Original offline sound effects for marks, placement, swipes, Undo, warnings, hints and wins; persisted sound/volume controls, native silent-mode and background handling. Bounded garden blooms, stroke ribbons, island reveal and orbital petal win graphics.
- Color-independent garden letters/boundaries, semantic cell labels, large-text layouts, selected-cell controls, reduced motion, contrast and haptic preferences.
- SQLite/Drift transactions, checksummed current/previous snapshots, whole-catalog integrity verification and a compressed known-good fallback.
- No login, backend, runtime puzzle generation, ads, billing, tracking, notifications or network dependency in the shipping app.

The content is machine-validated and still requires human playtesting and editorial difficulty approval before public release. This is a playable offline build, not a claim that all PRD store-launch gates are complete. See [build evidence and remaining release work](docs/BUILD_REPORT.md).

## Layout and requirements

- `app/` — Flutter client and Android/iOS projects; manual Riverpod providers, SQLite persistence, UI.
- `packages/puzzle_core/` — pure Dart immutable definitions/session commands, rules, exact solver, H1–H5 deductions and grading. No Flutter, I/O, storage, time or network imports.
- `content/` — canonical, versioned and hashed level catalog.
- `tools/` — deterministic authoring generator and independent validator. Never bundled as app logic.
- `test-fixtures/` — unchanged handoff fixture; never published as a playable level.
- `docs/PRODUCT_REQUIREMENTS.md` — byte-for-byte copy of the original PRD. `AGENTS.md` and ADR 001 override its Unity/C# architecture instructions with Flutter/Dart.

## Checks

Run Flutter commands from `app/` (or use `tools/flutterw` from this root). Do not run Flutter tests and Android release builds concurrently: both write the generated native plugin registrant. After a debug/test build, run release commands with default tooling regeneration; `--no-pub` can retain a debug registrant containing a test-only plugin in Flutter 3.47.5.

```sh
python3 tools/validate_catalog.py
python3 Pawgrid_iOS_Android_Development_Handoff/Pawgrid_reference_solver.py test-fixtures/Pawgrid_sample_level.json
./tools/flutterw analyze
./tools/flutterw test
ORG_GRADLE_PROJECT_pawgridTestApplicationId=com.pawgrid.pawgrid.gesturetest ./tools/flutterw test integration_test/game_flow_test.dart -d emulator-5554
ORG_GRADLE_PROJECT_pawgridTestApplicationId=com.pawgrid.pawgrid.tutorialtest ./tools/flutterw test integration_test/audio_motion_test.dart -d emulator-5554
# From packages/puzzle_core:
dart test
# From app:
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --target-platform android-arm64 --analyze-size
flutter build appbundle --release
flutter build ipa --release
```

Drift's database binding is the sole authorized generator. Regenerate with the command above and commit its output. Flutter regenerates platform plugin registrants itself. Catalog authoring: `python3 tools/build_catalog.py`, then `python3 tools/validate_catalog.py`; the latter verifies the reference solver, deductions and symmetry uniqueness, synchronizes assets, and rebuilds the fallback/digest. Every content change needs a new catalog version and updated hashes.

Midnight/lime launcher icons reuse the original companion vector, with legacy, adaptive and Android themed variants plus RGB-only iOS sizes. Generate them using `./tools/flutterw test tool/render_icon.dart`. Font license files are bundled and registered in the in-app license page.

Generate the eight original bundled sound effects with `python3 tools/build_audio.py`. Audio uses optional native OS adapters; no extra package or runtime download is needed. See [audio/motion decision](docs/adr/006-offline-sound-and-motion.md) and the current [build report](docs/BUILD_REPORT.md) for device verification and measured footprint.

## Distribution

Android builds currently use the Flutter development signing key so they can be installed locally. Configure an owner-controlled keystore/Play App Signing before distribution. There are no store credentials or private keys in source. iOS requires full Xcode, CocoaPods/appropriate Flutter plugin setup, a development team and signing; this Mac currently has only Apple command-line tools. Do not advertise iOS readiness until an actual signed build and device smoke test pass.
