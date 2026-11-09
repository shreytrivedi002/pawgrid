# Pawgrid interaction and visual update

Owner request: 8 November 2026. Replace the default Mark/Place tabs with tap for cross, hold for creature, and drag to paint/erase crosses. Make the app feel like a garden game. The owner delegated design choices; no design approval gate.

Guidance: Anthropic's frontend-design skill, read from its official repository after skill-directory discovery. Apply its subject-specific composition, typography and deliberate feedback principles in Flutter. No web runtime or new native dependency.

## Design plan

Palette: morning sky #DFF4F5, deep forest #214C43, clover #6FA34A, sunflower #F4BE50, warm timber #B87842, blossom #DF7D94. Nunito Sans at heavy weights carries playful game headings and controls. Region colors stay readable and lettered. Home opens on the garden scene and a prominent Play control; the board sits in a timber frame with compact level/progress HUD and tactile tools. Existing chapter/story content stays original.

Critique of the old design: cream/serif editorial typography, repeated flat cards and tracked uppercase headings made the UI feel like a lifestyle app. Replace those treatments with garden scenery, warm raised controls, strong rounded typography and actual game progress. Keep the board legible and use motion only after player actions; no endless particle loops or bright flashing.

## Input contract and acceptance

Maps to FR-004–006, FR-014, FR-021 and AC-02/04/08/09/10; §4 puzzle rules and all content remain unchanged. The user overrides §5.1's default mode tabs.

- Tap toggles a cross; hold toggles a creature. A hold never also adds a cross.
- Start a drag on empty to paint crosses, or on a cross to erase. Every visited mutable non-creature cell changes at most once per stroke, including cells crossed between sparse pointer events. Fixed clues and creatures are skipped.
- One completed stroke is one immutable command, one save and one Undo. Cancelled gestures commit nothing. Existing v1 saves load without rewriting marks or progress; session JSON v2 stores optional history groups. SQLite schema and puzzle content/hash versions do not change.
- Screen-reader custom actions and keyboard actions provide placement/clear without holding. The 9 November update removes enlargement and panning; the board and tools fit in a fixed playfield.
- Reduced motion (including the OS preference), large text, row-major semantic focus, noncolor garden cues, offline play and exact committed saves remain supported.

Verification: core batch/undo/migration/negative fixtures; pointer tap/hold/paint/erase/revisit/cancel/fast-drag/zoom tests; SQLite save/reopen; emulator integration on a separate test application ID so existing player data stays untouched; Android release APK/AAB and size analysis; iOS status documented honestly.

## 9 November refinement

The owner's latest clarification uses garden-only capacity: a second companion in a garden is blocked, while row/column/touching conflicts remain placed with visible warnings and explanations. [ADR 005](adr/005-garden-capacity-soft-conflicts.md) supersedes prior input restrictions. No puzzle definition changes. The guide shares the board's width and center; all main play, pause and completion controls fit without scrolling, including compact layouts and enlarged text. Optional selected-cell controls provide a precise-input alternative on small 9×9 boards.

Each action receives bounded feedback: a hold-charge ring, companion hop/squash and sparkles, drawn crosses, shrinking erased marks, rejection shake/halo, reactive companion and win flowers. Motion respects reduced-motion preferences and stops while paused. Native testing caught and fixed the final-hold release after the win screen disposes the board; a dedicated regression covers that handoff.
