# Pawgrid 0.5.1+8 — launcher icon update

Prepared 9 November 2026. New midnight/lime icon generated from the existing Moss companion vector, with a lavender orbit and cream sparkle. Android APK and App Bundle built; APK installed with `adb install -r` without clearing data. Android's App info screen visibly displays the new masked icon. App launched again after review.

## Changes and scope

- Android: five legacy PNG densities, five transparent adaptive foreground densities, a midnight background, API 26+ adaptive resources and API 33+ monochrome themed-icon resources. Foreground artwork stays inside the central mask-safe circle.
- iOS: all 15 unique icon files referenced by the unchanged asset catalog updated, including the 1024px marketing icon. These PNGs are RGB-only with no alpha channel; platform masks apply the corners.
- The existing Flutter vector authoring utility remains reproducible with `flutter test tool/render_icon.dart`. It now exports RGB PNGs using standard-library zlib for iOS and retains alpha on Android layers. No new package, native SDK or code generator.
- Version 0.5.1/code 8. Package stays `com.pawgrid.pawgrid`. Gameplay, settings behavior, puzzle content/hashes, saves, schemas and privacy permissions are unchanged. Settings only displays the new version. Maps to visual identity/FR-016; no game-rule revision.

## Checks actually executed

- **Authoring/validation test: 1 passed**, final run. Regenerates every icon; independently decodes each RGB iOS export through Flutter's PNG codec and compares every RGBA pixel with the original render. Checks all nontransparent Android foreground pixels fit the adaptive safe circle.
- **Asset validation: PASS.** Standard-library verification of PNG signatures, dimensions, color types and chunk CRCs: 15 unique iOS RGB files and 10 Android PNGs. Adaptive/themed XML parses successfully. A Pillow-based validation attempt could not run because Pillow is not installed; the independent decoder and standard-library checks above completed instead.
- **Visual review: PASS.** 512px artwork and 48px legacy icon inspected. Android API 35 App info screenshot confirms the installed adaptive icon is visible, recognizable and not clipped. The global Android themed-icon preference was not toggled; its monochrome resource is present in the compiled APK.
- **Analysis/format: PASS.** Final Flutter analysis: no issues. Dart formatting: 25 files, zero changes.
- **Android release checks: PASS.** Correct application ID/version, signature verification and 16 KB ZIP alignment. Compiled launcher XML contains background, foreground and monochrome entries. Save-preserving installation succeeds. No new runtime permission.
- Full gameplay/core suites and game integration tests were **not rerun for this icon-only change**. Their prior 36 Flutter, 22 core and 2 Android passing results are historical evidence in [v0.5](BUILD_REPORT_v0.5.md), not new claims here.

## Artifacts and platform status

- [ARM64 APK](../dist/Pawgrid-android-arm64.apk): **20,710,106 bytes (20.710 MB)**, **+70,080 bytes** over v0.5. SHA-256: `7c38292748eddda5ccb7f57448fabcaa4848533afa5c79ee53437264b39c652d`.
- [Android App Bundle](../dist/Pawgrid-android.aab): **57,014,291 bytes (57.014 MB)**, **+69,535 bytes** over v0.5. SHA-256: `05b67c4ab9485a17978ec0f9677f92f70587483b86f556ffb093b79f9d3ebe66`.
- Android artifacts use the existing development signing certificate. Production signing remains required. Store-delivered download size remains unmeasured.
- Size evidence: `size-v0.5.1/apk-analysis.json`, `snapshot.arm64-v8a.json`, `trace.arm64-v8a.json`.
- **iOS build attempt: FAILED**, exit 1, `Application not configured for iOS`. iOS icon assets are updated and validated, but full Xcode/owner signing and an actual signed device smoke test remain required.
- Hardware: macOS ARM64; Flutter 3.47.5/Dart 3.13.4; Pixel 7 Pro ARM64 Android 15/API 35 emulator, 1440×3120 at density 560. ZIP alignment and emulator review do not certify physical 16 KB-page devices or the full launcher matrix.

Preview: [512px icon](icons-v0.5.1/pawgrid-icon.png), [48px icon](icons-v0.5.1/pawgrid-icon-48.png), [1024px artwork](icons-v0.5.1/pawgrid-icon-1024.png), [installed Android icon](icons-v0.5.1/android-app-info.png).

## Remaining requirements and next step

Requested icon update is complete and installed for Android. Native themed-icon appearance across physical launchers, physical device/accessibility/size/store checks and the existing production release gates remain. Ads/purchases were not touched; native vendor sandbox tests are not applicable. Next platform action: configure full Xcode and owner signing, then build and smoke-test iOS with the updated asset catalog.
