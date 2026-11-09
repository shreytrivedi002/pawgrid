# AGENTS.md — Project Pawgrid Mobile Game

> **Source of truth:** `docs/PRODUCT_REQUIREMENTS.md` (unaltered handoff PRD, whose internal version is v1.0). The Flutter/Dart implementation decisions below override its Unity/C# architecture references. This file is instructions for AI agents, not a replacement for product requirements.

## Non-negotiable implementation decisions

- Build **one Flutter + Dart app** for iOS and Android. **Do not introduce Unity, C#, Flame, a WebView game runtime or a custom gameplay backend.** Propose an ADR and measured prototype if evidence suggests a change.
- `packages/puzzle_core` is **pure Dart**, deterministic, immutable, independently testable. It contains board rules, solver, validation, explainable hints, difficulty grading and session commands. No `package:flutter`, widgets, plugins, time-zone reads, networking, ad SDKs or storage clients in core.
- Use Flutter widgets, `CustomPainter` where measured useful, semantic grid controls, Flutter animations and optional Rive only after a size/perf spike.
- Use **Riverpod manual providers**, no Riverpod codegen. Persist through SQLite/Drift; Drift-generated database files are the one authorized initial code-generation exception and must be reproducible.
- No login, online dependency, runtime puzzle generation, leaderboard, sync or backend services in MVP. Initial Daily and Journey level packs must be bundled and prevalidated. Store/ads/crash vendor network calls may exist as optional adapters but never block play.

## Execution protocol

1. Before coding, read PRD §0, §4, §8, §11, §12, §14, §16, §20 and §21. Identify relevant requirement IDs and acceptance tests for the task.
2. Implement a **vertical slice** before feature breadth: fixture -> Dart rules -> 5x5 Flutter board -> undo -> SQLite persistence -> accessibility -> release build.
3. Keep code in narrowly scoped modules as defined in PRD §12.2. Separate widget state from pure game rules, isolate vendor SDKs behind `AdGateway`/`PurchaseGateway`/`AnalyticsGateway`, avoid extra state libraries and plugin packages.
4. Any schema/rules change requires tests against `Pawgrid_sample_level.json` via `Pawgrid_reference_solver.py`, negative fixtures, and updated versioned content hashes. Never alter a puzzle solution to force a desired screen state.
5. Every task ends with: changes summary, tests **actually executed**, test output/pass or failure, app-size impact if material, both-platform build status, unmet requirements and actionable next step. Never claim unrun checks passed.
6. Create short ADRs before introducing native plugins, optional backend, Rive, new code generators, or different storage/state architecture. Record dependency version/license, runtime/download footprint and testing outcome.

## Default quality commands (adjust workspaces only as documented)

```bash
# Run at the Flutter app root:
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
# Run inside packages/puzzle_core:
dart test
# Run from the handoff root:
python3 Pawgrid_reference_solver.py Pawgrid_sample_level.json
# When Drift is introduced:
dart run build_runner build --delete-conflicting-outputs
# Android release (with correct secrets/SDK):
flutter build appbundle --release
# macOS/Xcode/iOS signing required:
flutter build ipa --release
```

Also run device integration tests, app-size analysis and native purchase/ads sandbox tests when those features are touched. Standard Flutter integration tests alone may not drive native OS dialogs.

## Merge/release hard stops

- Ambiguous or incorrect puzzle; incorrect hash/region connectivity; unexplainable hints without an allowed deduction.
- Loss of committed progress or duplicate economy grants after kill/restart/replay.
- Ads, purchases, analytics or network calls gating otherwise offline play.
- Accessibility broken for cell focus, enlarged text, region noncolor cues, VoiceOver/TalkBack.
- Undisclosed native SDK/privacy data collection, unverified entitlement rules, or duplicate store purchase grants.
- Claimed iOS readiness without an actual macOS/Xcode signed build and smoke test.
- App-size budget exceeded without measured reason + product owner approval; unresolved critical crash or store compliance issue.

**Implementation order and complete ticket acceptance conditions:** PRD §21. The 30 MB/50 MB size goals are delivered-download **budgets**, not guaranteed baselines. Report measurements and hardware used.
