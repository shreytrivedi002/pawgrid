# ADR 001 — Flutter offline foundation

Accepted 2026-11-08 under the owner's AGENTS.md implementation decisions.

The handoff PRD describes Unity/C#. The project-level instruction explicitly chooses a single Flutter/Dart app, manual Riverpod providers, and SQLite/Drift. Preserve the PRD unchanged; apply those architecture overrides here.

Use `app/` for the iOS/Android client, `packages/puzzle_core/` for immutable, deterministic Dart models/rules/solver/deductions/session commands, `tools/` for authoring-time content generation and independent validation, and `content/` for the reproducible catalog.

No runtime generation, backend, authentication, tracking, advertising, billing, Rive, external fonts at runtime, or asset generators. AdGateway, PurchaseGateway and AnalyticsGateway have disabled offline implementations until separately configured and verified. No ads/IAP purchase promises in the interface.

## Native dependencies (decision before integration)

Drift (MIT) provides SQLite transactions, schema migrations, a unique reward ledger and durable board snapshots. `drift_flutter` (MIT) supplies the platform connection; its transitive `path_provider` (BSD-3-Clause) resolves app-private storage. SQLite is public domain. Use the package-resolved native SQLite implementation, never a custom platform channel. Drift's reproducible database generator is the sole code-generation exception.

Manual `flutter_riverpod` providers (MIT) own app services and immutable state. `crypto` (BSD-3-Clause) verifies canonical SHA-256 payloads in pure Dart. Built-in Flutter haptics avoid another plugin. Actual pinned versions, licenses, measured release-artifact footprints and executed test outcomes are recorded in `docs/BUILD_REPORT.md` after verification; delivered-download estimates require a store/device build and must not be inferred from a universal APK.

## Product decisions within the authorized scope

Original procedural vector garden artwork and sprout creatures; cream, evergreen and botanical region palette. English first. Free logical hints in this build avoid unconfigured monetization. Collectible cosmetics use only earned seeds. Settings expose local data deletion and accurately state no data leaves this build.

Build 200 Journey puzzles, a fixed dated Daily pack and a size-filtered practice library at authoring time. Every bundled definition needs connected regions, a matching canonical hash, exactly one independent solution and an H1–H5 deduction trace. Machine validation is not human playtest or publication approval. The supplied fixture remains test-only. Human difficulty, legal brand clearance, store accounts, SDK compliance, signed iOS and release signing remain release gates.

## Verified dependency and footprint record

Resolved on 2026-11-08: Flutter 3.47.5 (BSD-3-Clause), Dart 3.13.4 (BSD-3-Clause), flutter_riverpod 3.5.0 (MIT), drift 2.35.3 / drift_dev 2.35.2 / drift_flutter 0.3.1 (MIT), crypto 3.0.8 (BSD-3-Clause), path_provider 2.1.6 (BSD-3-Clause), sqlite3 3.5.2 (MIT Dart wrapper; public-domain SQLite), JNI 1.1.2 and jni_flutter 1.0.4+1 (BSD-3-Clause), build_runner 2.17.1 (BSD-3-Clause). The SQLite Flutter libs EOL packages are transitive compatibility packages; native sqlite3 code assets provide the measured library. Exact graphs are pinned in the lockfiles.

Measured Android ARM64 APK 20,461,486 bytes; native SQLite 1,732,360 bytes; included JNI native files 329,884 bytes. Drift/SQLite Dart code also contributes to the shared app AOT image and cannot be cleanly subtracted without a controlled baseline build. Store-delivered download and iOS footprint are unmeasured. Real SQLite persistence, redundant snapshots, replay idempotency and cosmetic spending tests passed, as did the emulator playthrough and offline force-stop data-retention check. See BUILD_REPORT.md for evidence and the explicit iOS/signing/store gates.
