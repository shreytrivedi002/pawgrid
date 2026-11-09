# ADR 005 — Garden capacity with soft conflict warnings

Accepted 2026-11-09 following owner clarification. Supersedes ADR 004's rejection of row, column and touching conflicts. The sole gameplay capacity precheck is one companion per garden. Fixed clues, invalid coordinates and completed sessions retain their input guards.

Policy `garden-capacity-v1` accepts tentative companions in different gardens even if they share a row, column or touch. Those placements remain saved and undoable. Existing visible-rule validation supplies red outlines and warning symbols (with error highlighting enabled), semantic conflict labels and an always-present textual explanation. Clearing/removing/undoing recomputes the warnings. There is no hidden-answer or solver-feasibility check, life loss or automatic correction.

Win predicate territory-v1 is unchanged: exactly N companions, one per row, column and garden, no touching and intact givens. A full set that violates these rules cannot win or grant rewards; hints decline contradictory states. PRD §4.3 soft warnings are restored for lines/touching; garden capacity remains the owner's scoped override. Maps to FR-002/004–007/013/021 and AC-01/02/03/04/09/10 (AC-02's new region conflict is prevented by capacity, legacy region conflicts still load unchanged).

Input policy version changes independently of content rules. Puzzle solutions, content hashes, territory-v1, database/session schemas and the original PRD remain unchanged. No native dependency or architecture change.

Verification covers fixture line/touching warnings without rejection; all fixture pairs checked solely against garden capacity; all 298 boards' initial candidates and valid completions; full conflicting boards not winning or producing hints; touch placement, warning symbols/semantics, saved reopen and Undo; isolated Android tests with textual warnings. Build evidence and platform limitations are in BUILD_REPORT.md.
