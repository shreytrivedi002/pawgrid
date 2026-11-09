# Figma design remake — 9 November 2026

Reference: https://www.figma.com/make/b3T6aCDtXHXdMij9xeSqnG/Upgrade-Game-UI-Design

The shared Make preview was inspected in the browser: home, gameplay, Journey, Daily, Friends and settings. Rendered typography confirms Space Grotesk headings, DM Sans body; background #191B2B and cream #F4F1E8. The Flutter remake uses midnight surfaces, lime action buttons, lavender accents, pastel gardens, outlined rounded cards, capsule navigation and vector floating-island garden artwork. Fonts are bundled offline from google/fonts with their OFL licenses. Existing companion identities/costs remain authoritative; the illustration is native Flutter CustomPainter art, not a WebView or remote image.

Feature precedence is explicit: the current implementation wins over old prototype content. Keep tap cross / hold companion / swipe paint-erase and whole-stroke Undo, garden-only capacity rejection with soft row/column/touch warnings, one-screen fitted playfield, 200 Journey + 68 Daily + 30 Practice, tutorial, timer, hints, progression/ledger, cosmetics, SQLite saves/recovery and every accessibility/privacy setting. Do not restore prototype Place/Mark tabs, an 80-level limit, an older companion price or a reduced settings dialog.

No core rules, catalog definitions/hashes, session/database schemas, architecture or native plugins change. FR-005/008/009/011/012/014/016/021 and AC-04/08/09/10 guide regression checks. Full test, size and both-platform build evidence belongs in BUILD_REPORT.md.
