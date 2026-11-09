# ADR 002 — Direct gestures and atomic cross strokes

Accepted 2026-11-08 under the owner's direct input request. This overrides the PRD §5.1 default Mark/Place tabs; PRD content is kept unchanged. No package, plugin, storage architecture or generator is added.

Tap toggles a cross; hold toggles a creature. A moving finger paints a fixed cross value (add if it starts empty, erase if it starts crossed). Revisits never toggle a cell twice. Interpolated hit testing includes cells crossed between sparse pointer events. Givens and existing creatures are protected during strokes. A cancelled stroke does not persist.

One stroke is one immutable core command and one SQLite transaction. Optional positive `group` IDs associate the per-cell history entries belonging to that command. Undo removes the contiguous group atomically. The counter is monotonic across Undo to avoid reusing group IDs.

Session JSON is now schema 2; the reader accepts v1 and v2, validates replay and group contiguity, and retains all prior marks, counters, time and history. A v1 save upgrades on its next normal commit, with the repository's redundant prior payload and recomputed SHA-256. SQLite schema remains 1. Puzzle rules, definitions, catalog version and all canonical content hashes are unchanged and are rechecked with the independent handoff validator. Older binaries cannot be assumed to read new session-v2 snapshots; forward upgrades, not downgrades, are supported.

The controller serializes input behind in-flight saves so a timer save cannot silently drop a gesture. Level-generation guards prevent queued input from affecting a new or restarted game. Stroke previews remain local until the gesture ends; the last durable state is restored if the process dies mid-gesture.

Custom screen-reader actions and keyboard P / Enter / Backspace allow placement, cross marking and clearing without a timed hold. Enlarged boards explicitly switch between painting and moving the viewport. OS and in-app reduced-motion preferences disable tile and victory animations.

Testing includes legacy save migration, grouped undo/erase, 10,000 randomized strokes, pointer interpolation/revisits/cancellation, clue/creature protection, queued inputs, enlarged-board panning, keyboard and custom semantics actions. Device tests use the `pawgridTestApplicationId` Gradle property set through `ORG_GRADLE_PROJECT_pawgridTestApplicationId` to isolate test data from the player's installed package. See the v0.2 update in BUILD_REPORT.md for actual results and measured artifacts.
