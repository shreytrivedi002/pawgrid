# ADR 004 — Allow exploration under visible rules

Superseded by [ADR 005](005-garden-capacity-soft-conflicts.md): only garden capacity blocks a tentative placement.

Accepted 2026-11-09 following the owner's correction: legal guesses must be allowed even when they differ from the hidden solution. Supersedes ADR 003's solution-based placement restriction.

The input policy is `visible-rules-v1`. New companions are blocked only by duplicate garden, row or column, adjacent touching (including corners), fixed clues, invalid coordinates or completed sessions. A locally nonconflicting guess is accepted even if no complete solution remains. No solution lookup, solver feasibility check, automatic correction or hidden-answer feedback occurs during placement. Undo/removal lets players reconsider. One companion per garden remains enforced.

This restores PRD §4.3's prohibition on judging nonconflicting tokens against the hidden answer. The owner's earlier request to reject visible rule violations remains in force instead of the PRD's optional soft warnings. Maps to FR-002/004–007/021 and AC-01/02/03/04/10. Layout, gestures and animations remain as in ADR 003.

No puzzle win rule, definition, canonical content hash, database schema or save format changes. Existing marks and history load unchanged. The input policy identifier is versioned independently from territory-v1 and contentVersion; puzzle hashes need no revision. No dependencies or plugins are added.

Regression coverage proves a non-answer, solver-dead-end guess is accepted, removable and undoable; all 298 boards accept exactly the initially visible-rule legal cells; all fixture exploratory pairs agree with visible conflicts; touch, keyboard and semantic actions allow legal non-answer moves. Isolated Android testing covers save/reopen and rejection of an occupied garden. Build results and measurements are recorded in BUILD_REPORT.md.
