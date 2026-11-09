# First garden walkthrough

Owner request: make the first game an easy, understandable tutorial. This replaces the minimal title-only introduction with one guided game. FR-008/005/006/021 and PRD §7.1/§4.3; existing acceptance coverage for Undo, offline play, large text and noncolor cues remains.

The unchanged bundled journey-001 (4×4, two fixed companions) is coached through five player actions: tap an impossible cell in row 1; swipe its remaining two empty cells; Undo the whole swipe; hold the forced cell in row 3; hold the final forced cell in row 4. Copy explains one friend per row, column and lettered garden, and no touching even at corners. Targets have an amber outline, pointer symbol, semantic target label and written coordinates. The two final cells follow visible deductions from existing givens; no puzzle is modified or randomly generated.

There is a welcome, a skip control, standard Undo/Rules and free input throughout. Larger text and short layouts use compact guidance with a full readable instruction dialog. No forced placement or hidden-answer rejection is introduced. Existing garden-capacity-only blocking and soft line/touch warnings stay in force.

The step and skip preference use existing SQLite-backed settings; incomplete lessons reopen the original committed board without resetting it. Finishing the first garden suppresses future auto-entry. Existing players with first-level progress are not interrupted. The original PRD remains unchanged; later tutorial-tier boards remain playable Journey content.

No dependency, storage schema, session format, rules, puzzle definition, solution or content hash changes. No analytics/network gate. The authored script is bound to journey-001's verified hash and disables itself if that definition changes. Native and automated test/build evidence is in BUILD_REPORT.md.
