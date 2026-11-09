# Project Pawgrid - Engineering Handoff

Prepared 8 November 2026. This is a design specification and reference validation fixture, **not** a completed mobile game or deployable Unity project.

## Files

- `Pawgrid_iOS_Android_Product_Requirements_Document.md` - product, gameplay, game logic, technical architecture, analytics, monetization, legal/policy considerations, launch and QA.
- `Pawgrid_sample_level.json` - unique 5x5 sample board, SHA-256 canonical content hash, solution; test-only and **not** approved production content.
- `Pawgrid_reference_solver.py` - minimal Python 3 standard-library rules/connected-region/unique-solution/hash validator that production C# code should match.

## Validate the sample

From the directory containing these files:

```bash
python3 Pawgrid_reference_solver.py Pawgrid_sample_level.json
```

Expected output:

```text
PASS: fixture-5x5-unique-001 - 1 unique solution, connected regions, content hash valid
Solution columns by row: [1, 4, 2, 0, 3]
```

## First development milestone

Build the pure C# rules engine in Unity 6.3 LTS; match the fixture above; create and validate 30 new original levels; then implement the puzzle renderer and durable session state before monetization or art polishing.

## Important caveats

Meowdoku was researched as a **market reference**. Use no Meowdoku branding, art, screenshots, curated levels or code in the new app. The "Project Pawgrid" codename is not a trademark clearance. Product metrics, timeline, monetization tests and difficulty scores are hypotheses until measured. Platform submission rules should be reverified immediately before release.
