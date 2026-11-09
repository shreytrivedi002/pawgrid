# ADR 003 — Strict placement and a fixed animated playfield

Placement policy superseded by [ADR 004](004-visible-rule-placement.md) following owner clarification. Layout and motion decisions remain in effect.

Accepted 2026-11-09 under the owner's explicit request: restrict wrong tiles, allow at most one companion per garden, center the gesture guide against the board, remove enlargement, fit the game controls without scrolling and make moves more animated.

This changes the input policy from tentative Zen placement in PRD §4.3/§5.1 to **strict-placement-v1**: a new companion must occupy the verified solution tile and satisfy visible row/column/garden/no-touch constraints. The win rules, puzzle solutions, catalog version and canonical hashes stay unchanged. The PRD is preserved unchanged; this direct owner decision is the scoped override. Core placement policy remains deterministic pure Dart. Rejected placements add no token, history entry, reward debit or life penalty. Explanations distinguish an occupied garden/line, touching and a wrong home. Removing an existing mutable companion remains possible, including an older tentative save; old committed marks/history are not silently erased.

All user placement paths (hold, keyboard and screen-reader action) use the same core guard. The grouped cross/erase command and exact undo semantics remain. Existing v1/v2 snapshots remain readable; no database or session schema change is needed.

The main puzzle and completion/pause controls use constrained, responsive layouts without scrolling. The board and centered gesture chips share the same width. Board enlargement/panning controls are removed. Large boards remain individually semantic and keyboard reachable; an optional selected-cell control strip provides a non-precision alternative on small screens. Help/settings/history lists may scroll as appropriate; there is no scrolling main playfield.

Motion is driven by user actions: hold charge, creature hop/squash, cross drawing/erasing, small sparkles, a rejection wobble, companion reactions, undo transitions and win flowers. Animations are bounded, stop while paused/backgrounded, and respect OS/in-app reduced motion. No Rive, native plugin or new dependency.

Maps to FR-002/004–007/014/021 and AC-01/04/08/09. The stricter policy supersedes the old acceptance assumption that a new visibly-conflicting tentative token remains on the board. Legacy negative save fixtures remain tested for exact load/removal. Verification includes strict-placement negative tests, unchanged reference fixture/catalog integrity, single-screen layout bounds, gesture/accessibility regression tests and isolated Android integration tests. Both-platform status and measured package sizes go in BUILD_REPORT.md.
