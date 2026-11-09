# PROJECT PAWGRID
## Product Requirements Document (PRD) - iOS and Android Logic Puzzle Game

**Status:** Build-ready proposed specification / v1.0  
**Prepared:** 8 November 2026  
**Product type:** Free-to-play, offline-first, single-player, casual logic puzzle  
**Platforms:** iOS (iPhone, iPad) and Android (phones, tablets)  
**Reference / research subject:** *Meowdoku: Brain Puzzle Games* by Oakever Games  
**Product codename:** Project Pawgrid (not a cleared consumer-facing trademark)  
**Document owner:** Product / game design  
**Intended readers:** Founder, game designer, mobile engineers, backend engineers, QA, art, audio, growth, analytics, legal/privacy, publishing  
**Source of truth:** This document defines the proposed **new** game. Anything identified as a competitor observation is **not** a claim about our app and must not be copied blindly.

---

### Quick navigation

[Executive decision](#0-executive-decision-and-implementation-contract) | [Competitor intelligence](#1-competitor-intelligence-market-demand-and-opportunity) | [Goals](#2-goals-non-goals-and-success-definition) | [Phases](#3-product-scope-and-release-phases) | [Formal rules](#4-core-puzzle-rules---formal-normative-specification) | [UX](#5-human-interaction-and-ux-rules) | [Modes](#6-modes-and-progression) | [Screens](#7-onboarding-and-screen-by-screen-specification) | [Generator/solver](#8-puzzle-generation-solving-publishing-and-difficulty-qa) | [Economy](#9-progression-collectibles-economy-and-rewards) | [Monetization](#10-monetization-and-ad-fairness-policy) | [Requirements](#11-user-stories-acceptance-criteria-and-requirement-ids) | [Architecture](#12-technical-architecture-and-technology-choices) | [Analytics](#13-data-analytics-and-experiments) | [Platform](#14-device-platform-security-and-operational-requirements) | [Art](#15-visual-identity-content-art-and-audio-production-brief) | [QA](#16-qa-strategy-and-test-matrix) | [Schedule](#17-delivery-team-milestones-and-dependencies) | [Launch](#18-launch-preparation-and-storefront-operations) | [Risks](#19-risks-assumptions-and-trade-offs) | [Definition of done](#20-release-definition-of-done) | [Implementation](#21-developer-setup--implementation-order) | [Sources](#22-external-sources--research-audit-trail)

---

## 0. Executive decision and implementation contract

Build a lightweight, original, cat-and-garden-themed **territory-placement** logic game in which a player places one friendly creature token per row, per column, and per irregular colored garden region; tokens may not touch, including diagonally. All playable levels must have **exactly one valid solution**, be validated before publication, and preferably be solvable with transparent human-style deductions. Launch with offline story levels, daily puzzles, undo/notes/hints, optional reward ads, satisfying achievements, and polished accessibility on iOS and Android. Add leaderboard and cloud sync only after proving the core puzzle loop.

**Product differentiation (mandatory, not optional polish):**
1. **Trustworthy logic:** validated unique-solution grids, deterministic solver, difficulty grading, and explainable hints that tell players *why* a move follows from the rules.
2. **Respectful, calm play:** the default Zen Journey never interrupts an active board with ads, never forces a player to guess, and does not punish exploratory note-taking. Hearts apply only to a separate opt-in Challenge mode, post-MVP.
3. **Distinct identity and progression:** original creatures, garden habitats, color-plus-pattern regions, unlockable cosmetic scenes, accessibility, and a clearly different interface from Meowdoku.

**Non-negotiable engineering acceptance:** the same pure C# rules/solver library runs on client, server validation tools, level generation, and automated test fixtures; every production level ships with a checksum and an evidence record that its rules, uniqueness, and difficulty were verified. **No externally advertised leaderboard claim** until a secure online timed mode is actually implemented.

**A note on legality:** Mechanics such as row/column constraints are common abstract game rules; copying a competitor's title, icon, art, UI composition, copywriting, curated levels, or distinctive presentation is not acceptable. Apple specifically warns against copycat apps [S9]. Commission original art and clear the final name and assets before store submission.

### Status legend

- **Observed:** Supported by official store listings, third-party rankings, or public reviews. It describes the reference game, not the proposed product.
- **Specified:** A product decision for this proposed game; engineering should implement it as written unless change-controlled.
- **Hypothesis:** An unvalidated business, pricing, metric, scheduling, or usability assumption requiring experiment or sign-off.
- **Future:** Explicitly out of MVP.

### Approval gates / unresolved business choices

These can be decided without blocking an initial prototype, but require owner sign-off before production content or store submission: final brand/name, initial launch regions/languages, ages and advertising policy, ad mediation vendor contracts, exact local IAP prices, UA budget, launch content volume, and whether optional social/online features are justified by retention.

---

## 1. Competitor intelligence, market demand, and opportunity

### 1.1 What Meowdoku actually is (verified, as researched 8 November 2026)

The official Apple App Store and Google Play listings describe a logic puzzle (marketed as a Sudoku/Minesweeper hybrid) in which players place exactly one cat in each **colored region**, with no two cats sharing the same row or column and no cats touching, including diagonally. The listings describe **double-tapping** to place cats, a **three-mistake/heart mechanic**, offline play, daily puzzles, and global leaderboard ambitions/features. The iOS listing advertises in-app subscriptions; Android indicates ads and in-app purchases [S1][S2].

**Important nuance:** The actual combinatorial mechanic is more precisely a *Queens-style, region-constrained non-attacking placement puzzle* than classical 9x9 Sudoku or Minesweeper. It is not necessary to implement number Sudoku, 3x3 Sudoku subgrids, mines, or a traditional Minesweeper loss grid. Unverified screenshots on fan sites that show extra rules or modes must not override official gameplay rules.

### 1.2 Evidence of demand, not evidence of easy profitability

- Sensor Tower reported **Meowdoku! as No. 1 worldwide for mobile game download growth in June 2026** [S3]. This is **download growth**, not gross revenue.
- As checked on 7 November 2026, third-party chart services ranked Meowdoku No. 1 among US free Google Play puzzle games; Google Play's official public listing showed **10M+ installs** in its public install band [S2][S4]. Exact counts and third-party estimates differ by method and timestamp.
- The US iOS App Store showed Meowdoku near/at the top of the casual chart and hundreds of thousands of ratings when researched [S1]. These dynamic rankings are snapshots, not fixed facts.
- Several public Android and iOS reviews praise the puzzle but criticize ad frequency, trapped/misleading ads, repetitive boards, and occasionally disputed solution validity [S5][S6]. Reviews are anecdotal and should be treated as qualitative signals rather than prevalence estimates.
- Third-party **revenue estimates are inconsistent and do not necessarily include ads**. Do not infer net profit or ROI from downloads, ranks, or one modeled revenue screen.

### 1.3 Competitive comparison

| Dimension | Meowdoku observed | Project Pawgrid specified |
|---|---|---|
| Core logic | One token per row, column, colored region; no touching | Same generic abstract constraint family, independently implemented |
| Interaction | Double-tap cat placement advertised | Explicit Mark / Place input mode, configurable direct tap and double-tap |
| Errors | Advertised three hearts | Zen mode: no life penalty; Challenge mode later |
| Puzzles | Progressive levels, daily puzzles | Curated difficulty ladder, verified uniqueness, daily seeded puzzles |
| Assistance | Hints implied in screenshots/reviews | Explainable, progressive logical hints; optional paid cosmetic help never required |
| Connectivity | Offline play advertised | Levels and saves fully offline; network features additive |
| Ads | Monetized via ads and subscriptions | No in-board interstitials; soft caps and always clear opt-in rewarded ads |
| Variety | Cat/pastel grid theme | Original garden chapters, distinct creatures and mechanics progression |
| Trust | Some reviews dispute board fairness | Immutable published level manifests and automated QA proofs |
| Competition | Leaderboards in listing | Offline personal best MVP; fair online challenge leaderboard after launch |

### 1.4 Audience and job-to-be-done

**Primary:** adults 18-44 who enjoy daily short logic challenges on mobile; sessions of about 2-8 minutes.  
**Secondary:** students and older casual players who prefer calm brainteasers, accessible UI, and offline commuting play.  
**Motivations:** feel clever after deducing a forced move; relax without racing; build a routine; collect cute but original visuals.  
**Avoid:** misleading IQ claims, forced pressure, unclear rules, excessive ads, random guessing as a requirement.

**JTBD:** "When I have a few minutes, give me a fair puzzle I can understand quickly, solve through reasoning, and feel good about completing without interruptions."

### 1.5 Positioning and elevator pitch

**Working proposition:** *Make every creature feel at home. One peaceful puzzle at a time.*  
**Genre:** spatial deduction / region-placement / casual brain puzzle.  
**Key promise:** every puzzle is logical, uniquely solvable, explainable, and playable offline.

**Creative distinctness requirement:** Original name; bespoke garden and woodland creatures; new shapes, typography, transitions, tab navigation, collectibles, level layouts, app icon, and tutorial voice. The final branding must not mention "Meowdoku" in App Store title/subtitle/keywords unless a lawyer explicitly approves legitimate nominative use; prefer no reference in storefront metadata.

---

## 2. Goals, non-goals, and success definition

### 2.1 MVP outcomes

1. Publish a polished single codebase game to both App Store and Google Play with iPhone/iPad/Android layouts.
2. Demonstrate that at least 95% of surveyed test players understand all three core rules without outside help after onboarding (hypothesis/acceptance test).
3. Prove that 100% of shipped boards pass deterministic schema, connected-region, exact-one-solution, and solvability tests.
4. Deliver a fully offline path from install to at least 200 sequential levels plus the current 30-day daily pack (subject to final scope gate).
5. Ship instrumentation, privacy/consent, monetization guardrails, a safe way to disable ads, and crash reporting without blocking offline play.
6. Support restoration of progress after process death and operating-system backgrounding with no lost moves.

### 2.2 Business hypotheses and initial performance gates

Targets below are **proposed experiment gates**, not benchmark claims about Meowdoku or guaranteed outcomes. Review after soft launch and adjust by channel and geography.

| Metric | Soft-launch target/hypothesis | Diagnostic action |
|---|---:|---|
| Tutorial completion rate | >= 80% of first-open sessions | Rewrite unclear tutorial step; inspect drop-offs |
| First full puzzle completion | >= 75% of players who start level 1 | Simplify first 10 levels |
| D1 retention | >= 30% | Improve first-day delight and perceived fairness |
| D7 retention | >= 10% | Improve daily loop, difficulty pacing, meta rewards |
| D30 retention | >= 4% | Test content cadence and habit features |
| Crash-free user sessions | >= 99.8% | Release blocker below gate |
| Invalid production puzzles | exactly 0 | Stop publishing; rollback puzzle catalog |
| Ad-reported negative experience | < 1% of monetized sessions | Disable problematic network/placement |
| Median first meaningful interaction | < 30 s after first launch | Reduce upfront screens |
| Median puzzle duration | 90 s - 6 min by designed difficulty | Regrade content if outside bracket |

**North-star metric:** weekly *meaningful solved puzzles per active player* (deduplicated actual completed boards, excluding debug and answer-reveal). Use completion plus D7 retention as quality counterweights, not raw ad impressions.

### 2.3 Out of scope at initial launch

Real-time multiplayer, chat, user-created/public levels, blockchain/NFTs, AI-generated art, constant-online requirement, combat, betting, seasons/battle passes, aggressive subscriptions, friend lists, unmoderated social feeds, geolocation, personalized profiling, and any claims of medical/cognitive benefit. Global competitive leaderboards and account linking are **phase 2**, not required for offline MVP.

---

## 3. Product scope and release phases

| Phase | Deliverables | Must-have / optional |
|---|---|---|
| P0 - technical prototype | 5x5-9x9 board renderer, input system, shared solver, generator, save/load, 30 test levels, on-device build | Must |
| P1 - MVP soft launch | Complete tutorial, Journey 200 levels, 30-day daily pack, hints, undo, notes, chapters, stats, settings, accessibility, analytics, crash reporting, consent, rewarded ads, one-time ad removal, iOS/Android release pipeline | Must |
| P1.1 - launch hardening | 100+ additional validated levels, localization, remote content updates, A/B flags, better visual effects, app store assets, moderation of ads | Must for scaled acquisition |
| P2 - retention expansion | Weekly events, collectibles/skins, personal goal streaks, new puzzle mechanics that maintain solver guarantees, optional cloud sync | Optional |
| P3 - competitive | Server-validated daily time challenge, global/friends leaderboards, secure replay verification, achievements | Optional pending economics |

**Scope safety:** If schedule slips, cut shop decoration, events, leaderboards, and cosmetic complexity before cutting solver QA, accessibility, save reliability, privacy, or original branding.

---

## 4. Core puzzle rules - formal normative specification

### 4.1 Coordinate definitions

- Board size `N x N`; 0-based coordinates `(row, col)`, each in `[0, N-1]`.
- Initial MVP board sizes: `N = 4..9`, with levels chiefly 5..8. `N=4` only for tutorial; `N=9` reserved for experts and tablets/zoom. Configuration can later support 10+ after usability testing.
- Exactly `N` **regions** identified by integer IDs `0..N-1`. Every one of the `N*N` cells belongs to exactly one region; regions may have unequal cell counts. Production regions must be orthogonally connected (4-neighbor connectivity) and preferably visually distinguishable without relying on color alone.
- Every token occupies exactly one cell. A token is a "creature"; concept art can represent unique friendly garden animals, not the reference game's cat artwork.
- Player cell state is one of `UNKNOWN`, `EXCLUDED`, `TOKEN`. Given/fixed cells (tutorials) have separate immutable metadata.

### 4.2 Win condition (ruleset `territory-v1`)

Let `x[r,c]` equal 1 if a token occupies cell `(r,c)`, otherwise 0. All must hold:

**R1 - Row uniqueness:** For every row `r`, `sum(c=0..N-1, x[r,c]) = 1`.  
**R2 - Column uniqueness:** For every column `c`, `sum(r=0..N-1, x[r,c]) = 1`.  
**R3 - Region uniqueness:** For every region ID `k`, `sum((r,c) with region[r,c]=k, x[r,c]) = 1`.  
**R4 - No touching:** For any two distinct token cells `(r1,c1)` and `(r2,c2)`, `max(abs(r1-r2), abs(c1-c2)) > 1`. This includes diagonals; rows/columns are already covered by R1/R2.  
**R5 - Exactly N tokens:** Follows from R1 but must also be directly asserted during validation.  
**R6 - Fixed givens:** If a level has a given TOKEN or EXCLUDED cell, it cannot be changed by normal play and must be consistent with the solution.

**Definition of touching:** Chebyshev distance <=1 between two distinct tokens. With one token per row and column, the only additional conflict to check incrementally is the diagonal gap between neighboring rows: `abs(colAtRow[r]-colAtRow[r+1]) == 1`. A chess queen-like diagonal attack at distances beyond one row **does not** matter; the rule is **adjacency**, not a global queen diagonal rule.

**No classic Sudoku 3x3 constraint.** Region boundaries, not fixed 3x3 blocks, supply the third uniqueness condition.

### 4.3 Valid and invalid placement behavior

- **Default Zen / Journey:** Each placement is tentative. Immediately show violations of **visible rules** (duplicate row, column, region, touching) as soft warnings if `Error highlighting` is on; do **not** subtract lives. Show success only when the full board satisfies R1-R6. Because levels are unique, a valid completed board equals the canonical solution.
- **Never label a currently nonconflicting token as "wrong" only because it differs from a hidden answer.** It may be a logically poor guess; immediate hidden-answer penalties create unfairness in an explanatory puzzle.
- **Timed Challenge (P3):** All 3 rules apply. Correctness checked only at validated submission; optional strict penalty settings must be disclosed in mode description.
- On a conflicting click, keep the player's tentative choice if they have soft-validation enabled, but highlight the conflict. An accessible text hint must explain which rule is broken.
- Block token placement on `GIVEN_EXCLUDED` cells and on `GIVEN_TOKEN` cells already occupied, with a gentle sound/haptic and no mutation.
- Marking a cell excluded does not alter token count. Clearing a token returns the cell to UNKNOWN, not automatically EXCLUDED.
- Player may complete a board without marking all non-token squares X. Only token positions determine win.

### 4.4 Sample **verified** 5x5 puzzle

**Region grid:** letters are region labels (colors/patterns); every letter must contain one token.

```text
       c0 c1 c2 c3 c4
r0      A  A  B  B  B
r1      A  A  C  B  B
r2      D  C  C  B  B
r3      D  C  E  E  E
r4      D  C  E  E  E
```

**Unique solution:** `(r0,c1) [A]`, `(r1,c4) [B]`, `(r2,c2) [C]`, `(r3,c0) [D]`, `(r4,c3) [E]`; corresponding columns-by-row `[1,4,2,0,3]`. All row/column/region and no-touch rules pass. The machine-readable fixture `Pawgrid_sample_level.json` is separately supplied; this sample was enumerated with a backtracking verifier (solution count 1). This sample is an engineering fixture and **not** necessarily the first tutorial board. Its optional `difficultyScore` is provisional and **not** a human-grade approval; `approvalStatus=fixture_only` prevents direct publication.

### 4.5 Board state model

```text
enum CellMark { Unknown=0, Excluded=1, Token=2 }
enum GameMode { Journey, Daily, Practice, Challenge }
enum GamePhase { Loading, Tutorial, InProgress, Paused, Checking, Won, Abandoned }

struct PuzzleDefinition {
  string levelId;
  int contentVersion;
  string rulesetVersion;      // territory-v1
  int n;
  int[] regions;              // n*n, row major, IDs 0..n-1
  GivenCell[] givens;         // optional; cell index and fixed mark
  int[] solutionColumnsByRow; // secure authoritative solution for offline hinting
  string difficulty;          // tutorial/easy/medium/hard/expert
  int difficultyScore;        // 0-100 from human-style solver
  string contentHash;         // SHA-256 over canonical invariant fields
}

struct PuzzleSession {
  string sessionId, levelId, puzzleHash;
  GameMode mode;
  CellMark[] marks;
  bool[] isGiven;
  int moveCount, undoCount, hintCount, conflictCount;
  long activeElapsedMs;
  long lastSavedUtcMs;
  GamePhase phase;
  Move[] history;             // capped and compacted
}
```

**Canonical normalization:** Hashing uses UTF-8 JSON with alphabetically sorted keys, no whitespace (`separators=(",", ":")`), and deterministic integer encoding. The exact hash payload is the object containing only `contentVersion`, `givens`, `levelId`, `n`, `regions`, `rulesetVersion`, and `solutionColumnsByRow`; `contentHash` and presentation-only metadata are excluded. SHA-256 hex digest is stored in `contentHash`. Save includes a session schema version and CRC/checksum to detect partial writes. No runtime dependence on Unity objects in the domain layer.

---

## 5. Human interaction and UX rules

### 5.1 Default input (designed to avoid accidental placements)

- Tap once on a cell in `Mark` mode: cycle `UNKNOWN -> EXCLUDED -> UNKNOWN`; tapping an existing TOKEN in Mark mode replaces it with EXCLUDED as one undoable action. In `Place` mode: toggle `UNKNOWN/EXCLUDED -> TOKEN -> UNKNOWN`; `EXCLUDED -> TOKEN` is allowed and becomes undoable.
- Two large, mutually exclusive buttons above the board: **X Mark** and **Creature Place**. Selected mode survives level retry and can be changed under settings.
- Optional `Quick input` setting: long-press on any mutable cell to toggle TOKEN; tap to toggle X. Haptic preview and confirmation when available. Optional `Double tap to place` accessibility preference, off by default.
- Tap a cell while input is animated: only first input accepted until animation resolves (typically <=120 ms), preventing double-apply. Do not infer a double-tap on one tap with OS assistive settings.
- Undo reverses exactly the most recent atomic change, including an optional auto-exclusion group, without an ad or currency cost. Redo available in expanded tools (MVP optional).
- Reset requires confirmation if progress exists; it resets mutable marks and time, preserves level identity and original givens, and can be undone only if snapshot retained (default reset is final after confirmation).
- Auto-X (optional off by default): after placing a token, visual overlay indicates all cells logically incompatible **under the chosen tentative token**. Do not permanently modify player marks unless the player enables `Apply auto-X`. Undo must revert an entire batch atomically.

### 5.2 Visual rules and error states

- Region fill has a distinct accessible color *and* an optional pattern or region-outline identifier. Minimum 1.5dp grid lines (density aware) and 3dp region boundary strokes at typical screen sizes.
- Tokens pop with an original squash-and-settle animation (180-250 ms; reduced motion alternative). Warning is distinct from "wrong answer".
- Top HUD: level name / difficulty, `Placed k / N`, pause, and optional elapsed time. Rule tray can expand to show three rule icons with text.
- When a row, column, or region is complete, light up its subtle border; conflicts get striped warning outline and accessible explanatory status.
- The solution check runs after token changes, not after pure X marks; should return in < 16 ms for N <= 9 on supported devices.
- On win: reveal a friendly creature animation, chapter progress, personal time, optional collectable reward, then **Next**. Any rewarded ads shown on completion are opt-in and never required to proceed.

### 5.3 Animation/audio/haptics

| Event | Visual | Audio | Haptic |
|---|---|---|---|
| X mark | Pencil slash animation | soft click | light |
| Token place | gentle bounce | short plink | light |
| Rule conflict | non-flashing striped border + text | muted soft note | warning, if supported |
| Useful hint | highlight relevant row/region with pulsing outline | one chime | light |
| Solve | slow flourish, short confetti substitute petals | 1-2 sec success motif | success |
| Undo | reverse micro-animation | optional click | none |

Sound effects and music must respect OS silent mode, device volume, accessibility, and individual in-game toggles. Default music muted after first launch unless player opts in; avoid sudden/loud sounds.

---

## 6. Modes and progression

### 6.1 Journey (MVP default)

- Linear path with chapters of 20 levels each. Launch target: **10 chapters x 20 validated levels = 200 levels**.
- First 5 stages: interactive instruction and guaranteed progress, no ads. Stages 6-15: easy 5x5 and 6x6. After stage 16: graduated 6x6 to 8x8, with expert 9x9 not earlier than chapter 7.
- Unlock next level when current is won; previously finished levels replayable from chapter map. If content pack update changes IDs, older completed IDs remain retained and mapped.
- New chapter visuals are genuine art differentiation, not changes to the fundamental rules until P2.
- Reward: first solve `10 seeds` (soft cosmetic currency), replay `0`, first clean solve no hint `+2 seeds`; reward ceiling per level `12` to avoid inflation.
- Stars: 1 for complete, +1 for no hints, +1 for active time under level-specific target. There is **no loss of progression for failing star thresholds**; stars are just mastery signals.
- No random unlock or energy wait after failure.

### 6.2 Daily Garden (MVP)

- One daily puzzle for each calendar date, available to play from the daily calendar. Difficulty ramps by weekday or deterministic schedule; every player in the same global challenge date receives the **same canonical puzzle ID and version**.
- **Clock model:** day = UTC date for globally comparable daily identity; show local-date labeling separately. For offline users, bundle at least 30 future UTC-date daily puzzles and 7 prior, then refresh opportunistically when online. Never generate diverging local daily boards for the same date.
- Save ability to resume; one first completion per daily ID earns reward. Replay for practice but cannot farm rewards.
- Streak: number of consecutive UTC-date puzzles first solved. A missed day breaks strict streak. A transparent one-day grace mechanic may be tested later, but no manipulative countdown copy. Missing offline days reconciles via signed first-completion timestamps with reasonable tolerance; device-clock fraud never awards competitive ranking.
- Daily record: best no-hint active time, hint count, completion flag. Personal history works offline. Global leaderboard is **not** promised in MVP.
- Local notification is opt-in, default off. Maximum once per day at user-selected local time; never nag after user skips or turns off reminders.

### 6.3 Practice (MVP)

- Choose board size 5..9 and difficulty (Easy/Medium/Hard); unlimited locally generated puzzles from prevalidated seeds or embedded packs; unsynced sessions do not grant unlimited currency or count toward ranked daily records.
- Preferred production strategy: prevalidated seed library rather than uncontrolled on-device generation; if generating locally, run exactly the same validation and grading rules and display fallback content if no acceptable puzzle found.
- Same hints and undo as Journey; no forced time pressure.

### 6.4 Timed Challenge (future P3)

- Optional mode explicitly marked competitive. Timer, visible rules, no hints and no answer reveal; leaderboard results require server-signed challenge, online start/end and replay checks. Players who decline online access keep all offline modes.
- No hearts default. An optional "three-strikes" skill variant may be A/B tested **only after** fairness tests; never penalize a legal exploratory token simply because it differs from the canonical solution before it becomes provably forced.
- Server leaderboard scores are not automatically derived from potentially editable offline client timestamps.

---

## 7. Onboarding and screen-by-screen specification

### 7.1 First launch funnel

1. Splash <=2 seconds on typical target hardware -> local version check and content verification.
2. Immediately enter playable tutorial; **no required login, paywall, ad, or notification gate**.
3. Tutorial 1 (4x4): "Only one creature in each row"; guide player through placement and show row count.
4. Tutorial 2 (4x4): "Only one in each column"; guide safe elimination.
5. Tutorial 3 (5x5): "Each colored garden gets one"; highlight region membership with pattern.
6. Tutorial 4 (5x5): "Creatures need space"; demonstrate diagonal touching conflict and how to mark X.
7. Tutorial 5: free attempt with lightweight contextual nudge only if stalled >=30 active seconds; completing enters Journey.
8. After at least two completed non-tutorial levels: optionally ask for audio/haptic preference; ad/privacy consent only at first monetized interaction where required by law, or before initiating SDK requests as platform rules require.

**Tutorial instrumentation:** `tutorial_started`, `tutorial_step_completed`, `tutorial_error`, `tutorial_skipped`, `tutorial_finished` with step ID, duration and help_count. Skipping must be available after first explanatory screen.

### 7.2 UI inventory and acceptance

| Screen / overlay | Required elements | Acceptance behavior |
|---|---|---|
| Splash/loading | original identity, progress/fallback | recovers if remote service unavailable |
| Tutorial | grid, spotlight, text/voice optional, skip | 4 rules taught; fully offline |
| Home | Continue, Journey, Daily, Practice, Collection, Settings | resume in <= 2 taps |
| Journey map | chapter cards, locked/unlocked levels, stars | reachable to last started level |
| Puzzle | grid, HUD, input modes, undo, hints, pause | responsive at 60 FPS target; fully accessible |
| Rule help | illustrated examples per rule | not blocking save; no hidden rule |
| Pause | continue, settings, restart, quit to map | active time stops in app background |
| Hint drawer | hint tier, cost/rewarded option, why | consented ads only; grants on callback |
| Completion | stars, elapsed time, seeds, Next/Replay | never blocks next puzzle on ad |
| Failed load | retry/local fallback, support link | not lose progress |
| Daily calendar | dates, status, streak, play | fixed UTC puzzle mapping |
| Practice picker | difficulty, size, play | deterministic safe content selection |
| Collection | original unlockables, preview, equip | cosmetic-only |
| Stats | solved, clean solves, longest streak, median time | offline accurate; accessible |
| Settings | language, audio, haptics, patterns, motion, input, privacy, support | persisted, native platform navigation |
| Shop | ad-removal IAP and Restore | explicit localized price and disclosure |
| Consent/privacy | platform/region appropriate controls | ads never requested when not allowed |
| Offline status | local badge only where useful | never blocks Journey |
| Delete data | confirmation and impact explanation | erase local data and queued exports; server deletion when applicable |
| Legal/support | privacy, terms, version, contact, ad-report route | external URL securely opened |

### 7.3 Navigation invariants

- Android back button: close topmost modal -> puzzle pause (not instant abandon) -> map -> home; on home, standard OS exit handling.
- iOS swipe-back/gesture: respect safe areas; never accidentally discard an active board. Dynamic Island/notch, iPad multitasking, Android gesture bar and foldable layout responsive.
- Modals cannot overlap indefinitely; loader timeout and all action buttons have disabled/busy state.
- No surprise paywall on return from system settings, ad dismissal, phone call, background resume, or win.

---

## 8. Puzzle generation, solving, publishing and difficulty QA

This section is **normative**. Puzzles should never be hand-assembled and shipped without solver verification. The solver must be independent of any visuals or animations.

### 8.1 Generator design - two-stage verified process

**Step A - construct a valid underlying token arrangement.** Select a permutation `p` of columns `0..N-1`, one per row, with `abs(p[r]-p[r+1]) > 1` for each `r=0..N-2`. A seeded Fisher-Yates shuffle with backtracking or precomputed permissible permutations can accomplish this. For `N=4..9`, enumeration or constrained random sampling is viable. Fail safely if no permutation available for an unsupported board size.

**Step B - construct N connected regions.** Initialize each region `k` with the single solution cell `(row=k, col=p[k])`. Grow regions through randomized adjacent unallocated cells until all `N*N` cells are assigned. Every new cell inherits an orthogonally adjacent region ID, preserving connectivity. Ensure each region's seed is its **only** solution token. Maintain preferred area balance (`min>=2`, `max<=ceil(0.45*N*N)` as a tunable aesthetic criterion); allow legitimate narrow or irregular shapes but reject hard-to-see regions.

**Step C - count solutions.** Solve constraints from scratch with **only** the displayed region grid and given clues, not with the original seed. Stop after 2 solutions: `0` => invalid; `1` => unique; `>=2` => ambiguous and reject. Never solve with a hidden extra constraint absent from the tutorial.

**Step D - logical grade.** Apply human-level deterministic deduction rules (below). If the logical solver stalls before a solution, mark as **unrated/guess-required** and reject for Journey/Daily. Assign difficulty score based on strongest strategy required, propagation iterations, branching exposure (which must be 0 for publishable Journey), and measured mobile tester performance.

**Step E - quality filters.** Reject repeated near-identical shapes, extremely tiny visually confusable regions, full-board rotational duplicates in nearby levels, excessive single-cell trivial regions, layouts needing zoom beyond device limits, and high color-collision scores under simulated color vision deficiency. Run manual visual review on selected high-difficulty content.

**Step F - publish.** Persist canonical manifest containing level ID, ruleset version, authoring seed, region array, givens, solution, logical deduction trace, difficulty, audit hash, author/reviewer, and content revision. Store assets in content-addressed bundles. Every item passes CI verification prior to approval.

### 8.2 Solution enumerator - reference pseudocode

```text
CountSolutions(board, stopAfter = 2):
    n = board.n
    seenSolutions = []
    // Place one token per row; col and region IDs cannot repeat.
    dfs(row, colsMask, regionsMask, previousCol, chosenCols):
        if len(seenSolutions) >= stopAfter: return
        if row == n:
            if givensSatisfied(chosenCols) and
               allRegionsRepresented(regionsMask):
                seenSolutions.add(copy(chosenCols))
            return
        for col in candidateColumnOrder(row):
            rid = board.regionAt(row, col)
            if (colsMask has col) or (regionsMask has rid): continue
            if previousCol != NONE and abs(col - previousCol) <= 1: continue
            if violatesGiven(row, col): continue
            if anyForwardCheckFails(row, col, nextRowCandidates, freeRegions): continue
            chosenCols.push(col)
            dfs(row+1, colsMask|bit(col), regionsMask|bit(rid), col, chosenCols)
            chosenCols.pop()
    dfs(0, 0, 0, NONE, [])
    return seenSolutions
```

**Why this works:** Since each row has exactly one token, a solution is a permutation; column uniqueness follows from a columns bitmask. Region uniqueness follows from a region bitmask. The only additional touching conflict can be diagonal adjacency between immediately adjacent rows, tested by the previous column difference. On completion, exactly N tokens and exactly N represented regions satisfy all rules. `anyForwardCheckFails` is an optimization and must never discard an actually feasible branch; enable only once covered by property tests. Reference tests can disable pruning entirely.

**Complexity:** Worst-case factorial in N (`O(N!)` base enumeration), dramatically reduced by constraints and early second-solution exit. N<=9 permits routine offline validation, but the editor pipeline should enforce generation timeouts and cache accepted puzzles. The production mobile game does **not** search for a solution on each animation frame.

### 8.3 Human-style deduction engine

Represent for each cell a candidate boolean `canContainToken`. A cell is logically excluded if it conflicts with a placed/given token or would violate already-satisfied row, column, or region counts. Repeatedly propagate:

- **H1 - Direct exclusion:** When a token is confirmed, exclude remaining cells in its row, column, region, and all eight neighboring cells.
- **H2 - Single candidate (row/column/region):** If exactly one candidate remains in a row, column or region, it is forced.
- **H3 - Locked region-to-line:** If every candidate for a region lies in a single row or column, other regions' candidates in that line can be excluded.
- **H4 - Locked line-to-region:** If all candidates in one row/column are in a single region, other cells of that region can be excluded.
- **H5 - Adjacent-row exclusion:** If all placements of a token in row `r` conflict diagonally with candidate positions in adjacent row `r+1`, prune those pairs. Generalized local candidate arc consistency may be used for harder levels.
- **H6 - Hall set / matching logic (hard):** Treat rows-to-columns and rows-to-regions as bipartite exact assignments. If a subset of K rows has candidates in only K columns, remove those columns from all other rows; similarly for regions.
- **H7 - Proof by contradiction (expert optional):** To avoid guessing, temporarily assume a candidate and prove all branches lead to contradiction; return an explanation that one candidate is impossible. Only permit this for expert-rated puzzles and label explanation clearly.

The grader records which tactic produces each forced move. If no move can be explained by allowed difficulty tactics, reject the puzzle or reclassify it (do not invent a hint). The UI hint system uses this trace to explain logical necessity, not to highlight arbitrary canonical answer cells.

### 8.4 Difficulty and content pacing (initial hypothesis)

| Tier | N | Permitted hint logic | Target unscripted solve time | Typical Journey span |
|---|---|---|---|---|
| Tutorial | 4-5 | H1-H2, scripted givens | 30-90 sec | 1-5 |
| Easy | 5-6 | H1-H3 | 1-3 min | 6-35 |
| Medium | 6-7 | H1-H5 | 2-5 min | 36-110 |
| Hard | 7-8 | H1-H6 | 4-8 min | 111-170 |
| Expert | 8-9 | H1-H7, explicit proof explanation | 6-12 min | 171-200 |

These are editorial starting points; refine using empirical time-to-complete, hint rate, abandonment and user testing. A good increasing difficulty curve is not simply increasing N. Track region shape complexity, forced-move depth, candidate density, pattern familiarity, and unusually hard transitions.

### 8.5 Content recurrence and duplication controls

For every board, compute canonical hashes under all eight square symmetries (rotations/reflections) after normalizing region IDs by first appearance, plus signature features (`N`, region area vector, solution pattern). Prevent exact symmetry duplicates in the same content set, and rate-limit shape-near-duplicates within a trailing 20-level window. Deterministically rebuild all packs from source JSON; authoring tool saves only accepted, signed versions. Daily puzzles from fixed manifests, not only `seed = date`, so generator algorithm changes never rewrite a past day's board.

### 8.6 Content operations and incident response

- Content editing workflow: `Draft -> Validated -> Playtested -> Approved -> Published -> Deprecated`. Require code-owner and designer approvals for a published puzzle pack.
- Content versioning: `levelId` stable; `revision` monotonically increases; `hash` changes when rules/content changes. Existing session bound to original content hash until finished; if a broken level is withdrawn, offer verified replacement and preserve previously earned progress.
- Critical incident: verified invalid/ambiguous daily puzzle -> disable the bad manifest via remotely cached kill-switch for online users, select known-good fallback; offline users retain last verified cached pack. Record an explicit incident timestamp and send no punishments.
- On-device generator timeout: at `maxAttempts=500` or `elapsed>1,500ms` on low-end test device, choose prevalidated fallback; never freeze rendering.

### 8.7 Puzzle hint system - deterministic and explainable

**Hint ladder:**
1. **Nudge (free; limited to 2 per level):** identify a row/column/region with a forced deduction and explain the relevant rule, without placing anything.
2. **Elimination (cost 1 hint credit OR optional rewarded ad):** mark one logically impossible cell with an animation; if the player has contradictory marks, explain why it cannot be used.
3. **Reveal a forced placement (cost 2 hint credits OR optional rewarded ad):** reveal one **provably forced** token and show a concise explanation from the deduction trace; never charge without delivering a valid result.

**Hint selection:** Recompute candidates from immutable puzzle definition and current tentative state. If the current marks are contradictory, explain/undo the contradiction first; never offer a random forced-placement hint from an inconsistent state. If player marks are consistent but no H1-H6 deduction exists, explain "Try clearing a tentative placement" or show an H7 expert proof if enabled. Reveal only if the deduction is valid under all remaining solutions of the **visible** current board constraints. Hints can never make a valid unique puzzle unsolvable.

**Hint credit source:** 3 free credits after tutorial; +1 per 5 first-time Journey wins; optional rewarded ad, with a daily cap. Hints are earned/optional and not needed to finish any level. Debits are atomic and reversed if the ad or hint operation fails.

---

## 9. Progression, collectibles, economy, and rewards

### 9.1 Soft currency (Garden Seeds)

Garden Seeds are **non-withdrawable**, non-tradable cosmetic progression points. They cannot be converted to fiat money, cryptocurrency, real prizes, or competitive advantages. Earned from first solves and daily milestones; spent on themes, creature portraits, board frames, and background garden objects (no gameplay power). Balance must be monotonic and nonnegative with idempotent transactions.

**Economy V1 configuration (hypotheses):**

| Action | Reward / cost | Frequency guard |
|---|---:|---|
| First Journey solve | +10 seeds | once per level ID |
| Clean Journey solve | +2 seeds | once per level ID |
| First daily solve | +20 seeds | once per global UTC day |
| Tutorial complete | +30 seeds | once per install/account |
| Basic creature skin | 80 seeds | one-time permanent unlock |
| Premium garden palette | 150 seeds | one-time permanent unlock |
| Optional video for daily bonus | +10 seeds | at most 1/day, only opt-in |
| Replay a solved level | 0 | unlimited replay, no farming |

No purchasable loot boxes, randomized cash-equivalent prizes, or gameplay-locking consumables in MVP. If future monetized virtual currency is considered, review laws/platform billing first.

### 9.2 Collection system

- MVP: at least 12 unique creature cosmetics and 6 original garden boards, each with normal and high-contrast theme variants.
- Cosmetics are independent from puzzle solutions; no creatures with variable collision footprints.
- All cosmetic thumbnails carry readable text labels; no dependence on hue.
- Unlock celebrations last <=2 sec and may be skipped. Collections must not obscure primary puzzle navigation.
- Reward grants occur once via transaction ID: `first-solve:{accountId}:{levelId}` or `daily:{accountId}:{utcDate}`. Local and server ledgers reconcile idempotently.

### 9.3 Achievements and streaks

Launch achievement examples: first solve; solve 10; no-hint solve 10; daily puzzles 7 days (not necessarily consecutive if achievement says "7 days"); solve at least one expert puzzle; enable high-contrast mode (optional recognition, never manipulate). Maintain an offline-achievement store; native Game Center/Play Games achievements can mirror them only after the online integrations are tested.

---

## 10. Monetization and ad fairness policy

### 10.1 Principles

Free-to-play gameplay must remain coherent with no purchase and no account. Monetization should not degrade the very short logic-play sessions. **Do not copy Meowdoku's observed subscription offers by default**; their pricing does not establish an optimal offer for this game. Never hide an ad behind a game button, prevent app exit, show misleading OS-security warnings, or use ads that repeatedly force open store pages. Blocklist/remove bad creative networks promptly. For underage or unknown-age users, apply the strictest relevant default until product/legal decides distribution policy.

### 10.2 MVP ad placements

| Placement | Trigger | Policy | Priority |
|---|---|---|---|
| Rewarded hint | Player taps explicit "Watch ad for 1 hint" | Grant only on SDK earned-reward callback; fallback when no fill | MVP |
| Rewarded daily seeds | Player taps "Watch ad for +10 seeds" | max 1/day, optional | MVP/experiment |
| Interstitial | Completion screen transition *only*, after cooldown | **Disabled during initial soft launch**; later experiment with max 1/3 wins, >=180 sec between interstitials, never first 10 levels, never within puzzle | Post-soft-launch |
| Banner | None | avoid covering board and small screens | Out of scope |
| App open ad | None | no first-run ad | Out of scope |
| Forced mid-board ad | Forbidden | preserve puzzle flow | Forbidden |

In all cases, failure to load/dismiss/reward an ad must **never** lose a puzzle, trap the user, or halt offline gameplay. Set SDK timeouts (e.g. 8s load/30s watchdog only for UI state, not prematurely interrupting legitimate ad playback); show safe native close/back controls once SDK permits. Block known deceptive categories and report incidents to network mediation vendors.

### 10.3 In-app purchase

**Recommended first paid offer:** **Remove Forced Ads Forever** (non-consumable entitlement). Launch price *hypothesis* USD $4.99 (localized and A/B tested **within platform policy**); this removes interstitials if introduced. Rewarded ads remain optional choices, never required. If initial product has **zero** forced ads, do not promote an ad-removal product misleadingly; ship the offer only when it has clear real value, or instead offer a **Supporter Pack** with disclosed cosmetics and no forced-ad entitlement until relevant.

IAP workflow:
1. Tap shop tile -> display native localized price, exactly what is unlocked and refund/restore context.
2. Invoke **StoreKit via Unity IAP** on iOS / **Google Play Billing via Unity IAP** on Android (or audited native wrappers); payment completed by storefront.
3. Validate transaction/entitlement using store APIs/server verification where network is available; client records a pending purchase if temporarily offline, verifies when service resumes, and provides store-native restore behavior.
4. Use idempotency key from store transaction identifier. No duplicate grants on replay/restore. Honor revocations/refunds when signaled by store.
5. `Restore purchases` in Settings/Shop. For anonymous cross-device restores use platform entitlement restored from the same store account; do not promise automatic cross-platform transfer without account linking and a server entitlement authority.

**Subscriptions are NOT in MVP.** They should only be introduced if there is genuinely ongoing differentiated value (e.g., monthly content packs, extras) and transparent billing, cancellation and renewal disclosures. Apple/Google both require truthful recurring value and clarity [S8][S11].

### 10.4 Monetization business model - formulas, not invented forecasts

```
DAU = daily active unique players
ad_impressions = DAU * sessions_per_DAU * eligible_ads_per_session * fill_rate
ad_revenue_usd = ad_impressions / 1000 * realized_eCPM_usd
IAP_gross_usd = purchasers * mean_transaction_value_usd
net_revenue_usd = ad_revenue_after_network_share + IAP_net_after_store_fees_refunds_taxes
UA_payback_days = acquisition_cost_per_install / net_contribution_per_daily_cohort_user
LTV_30 = sum(day=0..29, cohort_net_revenue_day / original_cohort_installs)
```

Storefront payout, network cut, taxes, geography, consent, paid traffic, and true retention must be modeled from actual cohorts. Do **not** mix store IAP estimates with ad revenue; a puzzle app with millions of downloads is not necessarily profitable.

---

## 11. User stories, acceptance criteria, and requirement IDs

### 11.1 Functional requirements

| ID | Priority | Requirement | Verification / definition of done |
|---|---|---|---|
| FR-001 | P0 | Offline puzzle open, place token and complete | Start in airplane mode, solve, no API dependencies |
| FR-002 | P0 | Deterministic solver and all four constraints | Exhaustive truth tests 4x4-6x6; property-based 7x7-9x9 |
| FR-003 | P0 | Only unique approved content enters production | CI rejects invalid/ambiguous/unrated levels |
| FR-004 | P0 | Undo a single user mutation atomically | undo/redo invariants and save-after-undo test |
| FR-005 | P0 | Mark and Place modes | input hit-testing and accessibility tests |
| FR-006 | P0 | Session saves after every stateful move | force-kill in any phase -> resume exact board |
| FR-007 | P0 | Complete without all X marks | token-only valid board triggers win |
| FR-008 | P1 | Five-step first-launch tutorial | completion funnel, skip, retry, assistive reader |
| FR-009 | P1 | Journey map and chapter unlock | solved 1 unlocks 2, replay does not farm currency |
| FR-010 | P1 | 200 launch levels | approved count and content coverage gate |
| FR-011 | P1 | Daily UTC puzzle calendar | same date -> same ID/version across devices |
| FR-012 | P1 | Practice selection | validated level for size/difficulty or safe fallback |
| FR-013 | P1 | Explainable hint ladder | every hint accompanied by valid explanation trace |
| FR-014 | P1 | Accurate active elapsed time | background/pause excluded, restore correct |
| FR-015 | P1 | Reward and seed ledger | no duplicate grants under retry/network replay |
| FR-016 | P1 | Original cosmetics and chapters | distinct art license, unlock/equip persistence |
| FR-017 | P1 | Privacy & consent preferences | test EU/UK/US/other and consent withdrawal |
| FR-018 | P1 | Rewarded ad integration | callback-only reward, safe no-fill and close |
| FR-019 | P1 | Secure IAP flow | buy, cancel, restore, refund, offline pending |
| FR-020 | P1 | Internationalized text | no hardcoded user-facing strings in game logic |
| FR-021 | P1 | Screen-reader and colorblind accessibility | complete one tutorial/puzzle without relying on color |
| FR-022 | P1 | Remote-config feature flags with safe local defaults | network outage does not break core game |
| FR-023 | P1 | Analytics/crash diagnostics with appropriate consent | schema validations and privacy checks |
| FR-024 | P1 | Clear account/local deletion flow | local clear; server delete if linked |
| FR-025 | P2 | Cloud sync across signed-in devices | deterministic conflict resolution tests |
| FR-026 | P2 | Weekly thematic events | event schedule with offline fallback |
| FR-027 | P3 | Secure ranked online challenge | replay validated server-side, verified leaderboard |

### 11.2 Detailed acceptance scenarios (Given/When/Then)

**AC-01: Valid completion** - Given a published unique 5x5 board and exactly five token placements satisfying R1-R6, when the last token is placed, then phase becomes `Won` exactly once, reward is granted once, and a `level_completed` event is emitted once.

**AC-02: Visible conflict without unfair penalty** - Given two tokens in the same colored region but different rows/columns, when `Error highlighting` is enabled, then both tokens are outlined with region-specific explanation; no hidden-solution penalty or life loss occurs.

**AC-03: Diagonal adjacency** - Given token `(2,2)` and a proposed token `(3,3)`, when placed, then conflict R4 appears. Given `(2,2)` and `(4,4)` with no other conflicts, R4 alone must **not** flag them as touching.

**AC-04: Undo and recovery** - Given three moves, when the user undoes the third and force-kills the app, then reopen shows exactly two applied moves, correct stats, and no duplicate rewards.

**AC-05: Offline daily** - Given a signed/verifiable cached puzzle for `2026-11-08`, when launching offline on UTC 2026-11-08, then that date's puzzle is accessible; if not cached, show informative offline fallback Practice mode rather than inventing a different ranked daily.

**AC-06: Rewarded ad failure** - Given user taps an explicit opt-in ad and SDK returns no-fill/timeout, then no credits are deducted and puzzle remains playable; closing ad without earned callback does not grant reward.

**AC-07: Purchase restore** - Given a valid completed remove-ads transaction, when reinstalling on same store account and using Restore, then entitlement is restored once and forced ads remain disabled; a revoked purchase cannot remain entitled after verification.

**AC-08: Layout** - Given 9x9 board on smallest supported device and large accessibility text, then all cells remain individually tappable via board zoom or scrolling/pan, HUD and modal can be read, no action is obscured by notch/gesture bar.

**AC-09: Color independence** - Given grayscale/monochromacy simulation, player can distinguish all regions by boundary thickness, texture labels and selection highlighting.

**AC-10: Contradictory save** - Given player marks put board into conflict and closes app, when reopen then the tentative markings persist, conflicting rule is explained, and user can undo/reset; state is never silently rewritten to the intended solution.

**AC-11: Puzzle integrity incident** - Given a live pack has a corrupt hash, when bootstrapping, then client rejects it and loads the latest known-good pack; it never accepts the corrupt definition or deletes progress.

**AC-12: Consent revocation** - Given user withdraws personalized ads permission, then future ad requests use updated privacy configuration and no prohibited tracking occurs; ability to play remains unchanged.

---

## 12. Technical architecture and technology choices

### 12.1 Recommended stack

| Layer | Choice | Rationale |
|---|---|---|
| Cross-platform client | **Unity 6.3 LTS, C#**, 2D UI Toolkit/uGUI as evaluated in spike | One codebase, proven iOS/Android ecosystem, 2D effects, ads/IAP SDKs, long-term support [S12] |
| Puzzle domain engine | Pure .NET/C# library without Unity dependencies | deterministic shared solver, fast headless tests, reuse on server |
| Local state | SQLite (via tested Unity-compatible provider) or robust binary/JSON atomic store | offline-first save, migrations, reward ledger |
| Level/content format | Versioned JSON editor source -> immutable compressed Addressables/catalog | signed manifests, content hotfixes, cache, localization |
| Analytics/crashes | Firebase Analytics + Crashlytics (region/consent configured) | standard mobile diagnostics and funnels |
| Remote settings | Firebase Remote Config + local safe defaults | release flags, ad caps, tutorial experiments |
| Backend (thin) | Firebase Cloud Functions (TypeScript or .NET-compatible Cloud Run if sharing solver) + Firestore + Cloud Storage | optional cloud, dailies, entitlements, admin controls |
| Authentication | No account required at launch; anonymous Firebase Auth only if backend session necessary; later Apple/Google sign-in | frictionless offline onboarding |
| Ads | Google Mobile Ads Unity plugin + UMP (or audited alternative mediation abstraction) | rewarded formats, region consent [S10] |
| Billing | Unity IAP with StoreKit 2/Google Play Billing tested adapter, verification service | platform-compliant digital sales |
| Notifications | Native local notifications via Unity mobile notifications plugin | private, opt-in daily reminder |
| CI/CD | GitHub Actions / Unity Build Automation, fastlane where supported | deterministic builds, signed distribution |
| Monitoring | Firebase Crashlytics, Cloud Logging, BigQuery exports | crash and backend observability |
| Project tracking | GitHub issues + milestone boards | independent reviewable features |

**Alternative:** Flutter + Flame is viable for a simple 2D grid if the team is more experienced with Dart and wants native-like UI. However, this PRD assumes **Unity/C#** to keep puzzle code and mobile game monetization integrations together. Re-evaluate based on team expertise, binary size, engine terms, SDK maturity, and device benchmarks. Avoid adopting unmaintained Unity plug-ins for iOS 26/Android 16.

### 12.2 Client logical modules

```text
AppBootstrap
  |- ConfigurationManager (defaults, remote config, feature flags)
  |- ContentCatalog (bundled packs, integrity, updates, fallback)
  |- PlatformServices (iOS/Android wrappers, permissions)
  |- PuzzleDomain
  |    |- RulesValidator
  |    |- ExactSolver
  |    |- HumanDeductionEngine
  |    |- DifficultyScorer
  |    |- HintService
  |- SessionController (state machine, timers, undo, save)
  |- ProgressionService (unlock, rewards, achievements, streak)
  |- EconomyLedger (idempotent grants and spending)
  |- UIRenderer (grid, screen navigation, animations, accessibility)
  |- AdService (consent -> request -> show -> reward callback)
  |- PurchaseService (store adapter -> verify -> entitlement)
  |- TelemetryService (consent-aware event queue)
  |- SyncService (optional, nonblocking)
  |- ErrorRecovery and SafeMode
```

Each module has an interface and a fake/test implementation. The puzzle domain must have no network, ad, analytics, engine-scene, or entitlement dependencies.

### 12.3 Persistence model

**Local logical tables/records** (SQLite keys illustrative):

- `settings(key PRIMARY KEY, json_value, modified_at)`
- `level_progress(level_id PRIMARY KEY, revision, stars, first_completed_at, best_active_ms, no_hint_best, reward_claimed)`
- `sessions(session_id PRIMARY KEY, level_id, puzzle_hash, marks_blob, history_blob, mode, active_ms, state, updated_at)`
- `daily_progress(utc_date PRIMARY KEY, puzzle_id, completed, first_completed_at, best_active_ms, hints_used, reward_claimed)`
- `wallet_transactions(tx_id PRIMARY KEY, amount, reason, source_id, state, occurred_at)`
- `entitlements(product_id PRIMARY KEY, platform, transaction_id, verified_at, expires_at, status)`
- `collection_unlocks(asset_id PRIMARY KEY, unlocked_at, equipped)`
- `content_manifest_cache(manifest_hash PRIMARY KEY, downloaded_at, verified, path)`
- `telemetry_queue(event_id PRIMARY KEY, payload, created_at, consent_basis)`

**Atomic save sequence:** update in-memory session -> append durable journal/transaction -> flush atomic DB commit -> emit noncritical telemetry. If write fails, inform player with locally retriable error, do not report a false successful save. Keep redundant previous-good snapshot and DB migration version. On Android process death, iOS force-quit, low storage, and airplane mode, restore the last committed move exactly.

### 12.4 Optional server data model (no online dependency for play)

```text
users/{uid}
  platformIds, locale, createdAt, lastSeenAt, consentVersion, accountStatus
users/{uid}/progress/{levelId}
  stars, firstCompletedAt, bestActiveMs, revision, sourceDeviceId
users/{uid}/ledger/{transactionId}
  delta, reason, proofRef, serverCommittedAt
users/{uid}/entitlements/{productId}
  platform, storeTransactionId, valid, verifiedAt, revokedAt
catalogs/{catalogVersion}
  manifestHash, minAppVersion, packUrls, publishedAt, active
challenges/{utcDate}
  puzzleId, puzzleHash, rulesetVersion, startAt, endAt, status
challenges/{utcDate}/scores/{uid}
  verifiedActiveMs, verifiedAt, replayHash, integrityFlags
supportReports/{reportId}
  anonymizedDiagnostic, category, adNetworkMetadata, status
```

**Security:** Firestore rules block any client from writing arbitrary currency balances, verified entitlements, global catalog entries, or leaderboard scores. Only backend functions with authenticated authorization and idempotency may award server rewards; local offline rewards are tentative until reconciled if cloud features are enabled. Admin writers separated from player clients; audit logs for every catalog publish and economy rule change.

### 12.5 API contracts for future sync / online features

MVP can omit these HTTP surfaces if all are unnecessary; the interfaces are defined now to avoid architecture rewrites. APIs use JSON, Bearer auth, TLS, rate limits, idempotency IDs, content hashes, and explicit versioning.

**GET `/v1/config`** -> `{configVersion, minClientVersion, flags, ads:{rewardCapDaily, interstitialEnabled}, catalogs:[{version,sha256,url}], serverUtcMs}`. Cached fallback always present.

**GET `/v1/daily?date=YYYY-MM-DD`** -> `{utcDate, puzzleId, rulesetVersion, puzzleHash, contentPackVersion, expiresAt}`. Validates allowed UTC date; no client-submitted replacement board.

**POST `/v1/progress/batch`** request `{deviceId, clientSequence, events:[{eventId, levelId, puzzleHash, outcome, activeMs, hintsUsed, completedAtUtc}]}`; response `{acceptedEventIds, rejected:[{eventId,code}], authoritativeProgressRevision}`. Reward claims must be verified or marked provisional; replayed event IDs never double-grant.

**POST `/v1/purchases/verify`** `{store, productId, transactionId, verificationPayload, clientRequestId}` -> `{entitlementStatus, expiresAt, serverReceiptId}`. Server fetches authoritative transaction status from Apple/Google; never trusts a client boolean. Never log/store raw purchase secrets in clear text.

**POST `/v1/challenges/start`** (P3) -> `{runId, challengeId, puzzleHash, serverStartMs, expiryMs, signedToken}`.  
**POST `/v1/challenges/submit`** (P3) -> `{runId, signedToken, replay:[{seq,cell,action,relativeMs}], claimedElapsedMs, finalMarksHash}`; server verifies challenge and replay, calculates eligible rank and returns `{status, validatedMs, rank?}`.

**POST `/v1/privacy/delete`** for linked users; token-bound deletion request, safe irreversible delete or legal retention exception explanation. Provide download/export if legally required and feasible.

**Error envelope:** `{error:{code,messageKey,retryable,correlationId}}`, stable machine-readable codes. Example errors: `PUZZLE_HASH_MISMATCH`, `OFFLINE_UNAVAILABLE`, `ENTITLEMENT_PENDING`, `RUN_EXPIRED`, `CONSENT_REQUIRED`, `RATE_LIMITED`, `VERSION_UNSUPPORTED`.

### 12.6 Sync and conflicts (P2)

- Account linking optional and explicit; never silently tie unlinked personal gameplay to advertising identifiers.
- For completed levels: merge via set union of level IDs, maximum stars, minimum valid best active time per level **subject to compatible revision and rules**. For currencies: server ledger is authoritative, never `max(balance)` or additive totals from duplicate offline events.
- In-progress same level across two devices: retain most recently updated **user-selected** session after a compare view; do not merge mutually inconsistent token marks automatically.
- During prolonged offline operation, all core play and cosmetics already unlocked remain accessible; queued mutations sync with exponential backoff and idempotent event IDs. If denied/conflicted, preserve local state and explain discrepancy, no silent data loss.

### 12.7 Fair leaderboard design (P3)

- To claim a global ranked best time, require an authenticated online challenge with server-issued signed run ID and fixed board hash. Start and submit on an online connection.
- Server recomputes all replay moves using shared validation and accepts only a valid end configuration; enforce monotonic sequence/time, action rate bounds, run expiration, single run submission, and reasonable active-time constraints. Reject altered board, impossible moves if ranked rules disallow them, modified ruleset, and reused nonce.
- Server's wall clock bounds the run; client `activeElapsedMs` is *advisory* because wall clock can include network delay. Define fairness: if backgrounding occurs, run forfeited or timer continues in competitive mode, disclosed before start.
- Device emulation and sophisticated tampering remain possible; rate-limit suspicious scores and mark them pending audit. Never describe anti-cheat as impossible to defeat.
- Player nickname must be moderated or use platform-provided safe alias; provide report/block for any user-visible custom names.

---

## 13. Data analytics and experiments

### 13.1 Event taxonomy (schema V1)

All events carry `event_id`, `event_time_utc`, `anonymous_install_id` (random first-party ID only where permitted), `app_version`, `platform`, `build`, `locale`, `ruleset_version`, `consent_state`, and `experiment_assignments`. Do not capture names, email, full IP, contacts, raw ad ID without lawful basis, freeform user-entered text, or a complete move trace in generic analytics. Pseudonymous identifiers must honor consent and deletion.

| Event | Trigger | Key properties |
|---|---|---|
| `first_open_completed` | first game ready | source, duration_ms |
| `tutorial_started` | initial tutorial | tutorial_version |
| `tutorial_step_completed` | step advances | step_id, duration_ms, mistakes |
| `tutorial_finished` | all or skip | steps_done, skipped |
| `level_started` | Journey/Daily/Practice board opens | level_id, mode, n, difficulty, revision |
| `cell_marked` | sampled 1 in 10 moves, privacy dependent | action_type, mode, n; no raw row/col by default |
| `rule_conflict_shown` | warning displayed | rule_id, mode |
| `hint_requested` | hint initiated | tier, balance, reward_option |
| `hint_delivered` | valid hint applied | tier, deduction_type, credit_cost |
| `hint_failed` | invalid/unavailable | failure_code |
| `level_completed` | first solve or replay | level_id, mode, duration_ms, hints, undo_count, replay, stars |
| `level_abandoned` | exit before completion | progress_ratio, active_ms, reason |
| `daily_opened` | calendar opened | selected_date |
| `daily_completed` | first daily solve | utc_date, duration_ms, streak_days |
| `ad_request` | SDK loads | placement, consent_mode, adapter |
| `ad_show` | ad becomes visible | placement, network |
| `ad_reward_earned` | reward callback | placement, reward_id |
| `ad_failure` | ad error | placement, adapter, error_code |
| `ad_report` | user reports misleading/stuck ad | network, creative_id_if_available, category |
| `shop_viewed` | shop opened | source |
| `purchase_started` | store launched | product_id, price_tier_if_allowed |
| `purchase_completed` | verified entitlement | product_id, store, currency, localized_price |
| `purchase_failed` | rejected/cancelled | reason, product_id |
| `consent_updated` | privacy preference changes | policy_version, consent_categories |
| `notification_opt_in` | user grants | time_of_day |
| `content_validation_failed` | invalid pack/hash | pack_id, error_code |
| `app_exception` | handled fatal/nonfatal | error_code, module, stack redacted |

**Event semantics:** Emit `level_completed` exactly once per completed session. `replay` distinguishes repeated solves; `first_solve` in property set drives progression. Events queue offline with bounded retention (e.g. max 2,000 events or 7 days; delete oldest safely under pressure) and are dispatched only when legal consent/config allows.

### 13.2 Key dashboards

1. Acquisition-to-tutorial-to-first-win funnel by source, OS, app version, locale.
2. Retention D1/D7/D30 by install cohort (same definition for 24h vs calendar cohorts; document before reporting), organic vs paid.
3. Puzzle difficulty heatmap: level attempt, completion, active time, hint use, conflict counts, quit rate.
4. Ad funnel: consent -> request -> fill -> show -> earned callback, ad complaints and failure by network/creative.
5. Purchase funnel: offer view -> start -> verified conversion -> refunds/restore.
6. Technical health: crash-free sessions, ANR rate, bootstrap failures, content integrity, local-save recovery.
7. Economic health: cohort ARPDAU, ad eCPM, LTV, CAC, payback, country/platform split, paid UA spend separate from revenue.

### 13.3 Initial experiment roadmap

| Experiment | Variation | Success guardrail |
|---|---|---|
| Input | Mark/Place buttons vs long-press quick mode | fewer accidental tokens, tutorial completion |
| Tutorial | 5 guided boards vs 3 guided boards | first-win and 7-day retention, not just skip rate |
| Hint | generic clue vs explainable why | fewer quits without reducing mastery |
| Daily nudge | no prompt vs user-chosen local reminder | opt-out rate, D7, complaint rate |
| Ads | rewarded-only vs soft-capped win-screen interstitial (after soft launch) | **D7 must not materially decline**, bad-ad reports and IAP impact |
| Cosmetics | chapter-specific reward vs pooled store | return sessions and cosmetic equip rate |

**Experiment assignment:** deterministic per consented install ID or account ID with a salt/version, mutually exclusive arms. Log assignment before exposure, define primary metric, minimum sample, stop rules, and exclusion rules. Never tune harmful ad frequency solely to short-term revenue.

---

## 14. Device, platform, security, and operational requirements

### 14.1 Platform/version baseline - verified requirements as of 8 November 2026

- **iOS distribution:** App Store Connect currently requires builds made with **Xcode 26 or later using iOS/iPadOS 26 SDK or later** for uploads beginning 28 April 2026 [S7]. This describes the **build SDK**, not the minimum iOS OS install target. Proposed minimum supported runtime: iOS/iPadOS **15.0+** (subject to actual Unity/SDK compatibility tests and device market coverage), with iPhone and iPad layouts.
- **Android distribution:** Since 31 August 2026, **new Google Play apps and updates must target Android 16 / API level 36 or later** [S13]. Proposed minimum runtime Android **8.0 / API 26** (reassess minSdk vs supported ad/IAP providers and low-end testing). Target SDK and minimum SDK are distinct concepts.
- **Store packaging:** Android App Bundle `.aab` signed via Play App Signing; iOS App Store archive via Xcode/Transporter/TestFlight. Use a unique bundle ID/application ID owned by the company, e.g. `com.company.pawgrid` as an example only.
- **Orientation:** portrait primary. Tablets/foldables support responsive board and side-panel layout; landscape is optional for first release but should degrade gracefully if OS forces orientation.
- **Distribution regions:** choose legal launch regions explicitly. Initial release languages: English, Hindi, and Spanish only if localization review can be done well; do not ship machine-translated legal text unreviewed. English-only is safer than low-quality translated rules if budget constrained.
- **Age rating:** complete each storefront's current questionnaire accurately. Because of third-party ads, privacy, and monetization, never assume an "Everyone" label will automatically apply in every locale. Do not target children without age-appropriate ad/privacy review.

### 14.2 Nonfunctional requirements (acceptance targets)

| Requirement | Target | How to test |
|---|---|---|
| Start time | cold start to playable bundled board p50 <= 3s, p95 <= 6s on target median hardware | real-device startup traces |
| Responsiveness | 60 FPS on mainstream devices; >=30 FPS during animations on lowest supported cohort | device profiler and automated interactions |
| Input latency | feedback <= 100 ms on simple tap, validation <= 16 ms on N<=9 | frame instrumentation |
| Package size | Android compressed download <= 100 MB target; iOS compressed <= 150 MB target (hypothesis) | actual store build artifacts; strip engine/assets |
| Runtime memory | <= 250 MB typical low-end device target, no memory leak in 1h continuous play | Android Studio / Instruments |
| Network | 100% Journey/Daily pre-cached content playable offline; purchases/ads degrade gracefully | airplane mode test matrix |
| Save durability | zero lost completed levels/moves under tested process death | fault injection |
| Crash-free sessions | >=99.8% | Crashlytics weekly cohort |
| ANR | <=0.1% user-perceived ANR sessions on Android | Play vitals |
| Battery/thermal | no sustained high CPU/GPU use on static board; throttle animations background | long-session thermal profiling |
| Accessibility | all controls have semantic names/focus, dynamic text, color-independent regions, reduced motion, haptic/audio toggles | TalkBack/VoiceOver, color simulation |
| Security | no embedded secrets, no plaintext sensitive tokens, signed content, transport TLS | security checklist and scans |
| Reliability | safe on no-fill ads, corrupted cache, storage full, clock change, network transitions | chaos tests |
| Privacy | minimized data, consent enforcement, deletion and storefront labels accurate | privacy audit |
| Localization | no truncation for supported locales, logical reading order | screenshot tests incl. RTL smoke if enabled |

**Unity rendering:** Evaluate uGUI with TextMeshPro for predictable low-device UI and Unity UI Toolkit in a one-week spike. Choose one production renderer. Canvas/grid virtualization and pooled UI elements avoid per-cell `Instantiate` at each tap. No heavy real-time scene effects or excess draw calls for a static grid.

### 14.3 Accessibility details

- Ensure tap targets generally >=44x44 pt (iOS) / >=48x48 dp (Android) for action buttons; for 8x8 or 9x9 cells, provide board zoom/pan or enlarged selection inspector where grid cell size would fall below comfortable accessible touch size.
- Full VoiceOver/TalkBack puzzle navigation must expose `Row 3, column 5, region C, excluded` and announce candidate/conflict state without reading region only as a color.
- Regions use colors + noncolor labels/patterns/high-contrast boundaries; avoid relying solely on 5-9 close pastel shades.
- Dynamic text scaling for menus and dialogs, larger HUD switch, left-handed layout optional, reduced-motion/no-flash mode, audio descriptions of hint explanations.
- Screen-reader focus order row-major on grid, optional jump to next unfilled row and region. Explain error in plain language, e.g. "This garden already has a creature".
- Provide accessible alternative to double-tap or long-press. Never make precision gestures mandatory.

### 14.4 Privacy and ads compliance

- iOS: show App Tracking Transparency (ATT) prompt only when app/SDK actually intends to perform ATT-defined tracking; no tracking until permission. Privacy manifests and App Store privacy disclosures must describe first-party and third-party SDK data collection [S14]. The game works without ATT acceptance.
- EEA/UK/Switzerland: use a compliant consent management platform and Google UMP or equivalent, request consent status at appropriate startup points, surface `Privacy options` where required, and ensure ads are requested only when legal basis/SDK consent state allows [S10]. Consent withdrawal must affect subsequent ad calls.
- Android: accurately complete Google Play Data Safety and ads disclosures; use current UMP/Google Play SDK policies. Avoid collecting Advertising ID unless needed and permissioned.
- Obtain legal review for applicable US state privacy laws, children's privacy, and data retention. A game that is attractive to minors needs careful ad category filtering and age segmentation, even if primary positioning targets adults.
- Minimum data: level progress, random install ID where lawful, coarse technical diagnostics, entitlement state. No geolocation, contacts, call logs, biometric data, or user profile required.
- Define retention before launch: raw nonfatal logs 30-90 days as operational policy hypothesis; analytics aggregates per provider retention; delete on consent revoke where required. Privacy policy must reflect actual vendor stack.
- Implement a **Report bad ad** form that records network and creative ID if SDK exposes them, plus optional screenshot voluntarily supplied by user. Never ask for security credentials or bank details.

### 14.5 Security requirements

- No API keys with privileged write access in app binary; public Firebase app config is not a secret but must be protected by strict security rules. Secure build secrets in CI secret storage.
- Use platform keychain/Keystore for authentication credentials and sensitive receipts. Offline game state need not contain personally identifying data and can be app-private with integrity checks.
- Verify downloaded puzzle manifests via SHA-256 and signed server catalog; `rulesetVersion` and `minAppVersion` compatibility checks. Checksum alone detects corruption; cryptographic signature or trusted transport prevents intentional malicious replacement.
- Restrict backend admin endpoints using least-privilege service identities; log approvals and changes. Rate-limit challenge start/submission and purchase verification.
- Prevent reward abuse via deterministic local ledger and authoritative server reconciliation; do not attempt invasive device fingerprinting to fight benign cheating in a casual puzzle.
- Provide incident kill switches: disable a misbehaving ad placement, rollback bad catalog, disable online leaderboard, force safe mode, disable problematic third-party adapter without a new store binary when SDK design permits.

### 14.6 Observability and on-call runbook

**Alerts:** daily crash-free below 99.8%; new app version start failures >2%; invalid puzzle hash >0.05%; reward ad callback mismatch >0.5%; purchase-verification failure spikes; server error rate >2% for 5m; abnormal complaint volume by ad network. Thresholds are initial targets to tune.

**Response:** rollback Remote Config, disable placement, freeze content release, notify support, preserve anonymized logs, reproduce using content hash and OS, release signed catalog hotfix or binary patch. App never needs emergency internet merely to open a verified bundled puzzle.

---

## 15. Visual identity, content art, and audio production brief

### 15.1 Creative direction (proposed, subject to artist exploration)

**Theme:** botanical pocket gardens. A tiny creature finds its own nook in an irregularly tiled garden. It should feel hand-crafted, tactile and cozy, with strong readable geometry. This is deliberately **not** a pink/white cat-face replica of Meowdoku.

**Suggested palette:** warm ivory `#F8F4EA`, dark ink `#243B38`, fern green `#84B98B`, terracotta `#CB826B`, muted gold `#D6B15E`, lake blue `#7CAEC4`, lilac `#A798C8`, all tested for sufficient contrast; 9 regions require variants with clear distinct border patterns, not just these six hues.

**UI style:** spacious organic cards, subtle paper texture, crisp vector outlines, low-contrast animation backgrounds, original iconography, and distinct navigation from reference. Use system legibility standards rather than ornate text for rules.

### 15.2 Asset inventory

| Asset type | Launch quantity (hypothesis) | Production notes |
|---|---:|---|
| App icon | 1 base + A/B tests for store | own illustration, no reference icon resemblance |
| Creature mascots | 12 | vector or high-res raster, 2-3 simple poses each |
| Garden themes | 6 | board, border, background, high-contrast variant |
| Chapter illustrations | 10 | optimized for mobile, original motifs |
| UI icons | 30-45 | scalable SVG/source plus raster pipeline if needed |
| Tutorial illustrations | 8-12 | examples of row, column, region, adjacency |
| UI animations | 10-15 | reduced-motion equivalents |
| SFX | 10-15 | permissive license or commissioned |
| Music | 2-3 optional loops | original, licensed worldwide, loopable and low key |
| Store screenshots | device families for iOS and Android | actual gameplay, localization variants |
| Promo creatives | 10-20 variants for soft launch | real puzzle logic, no deceptive 'IQ score' claims |

All source assets must be versioned, license documented, and hand-off include layered originals. Avoid downloading and editing screenshots/art from Meowdoku or third-party clone websites. If using AI to assist ideation, ensure commercial rights and originality review before final production.

### 15.3 Minimal wireframe layout (not a copied screenshot)

```text
+--------------------------------------+
|  <  Garden 2 / Level 12      Pause    |
|  Easy                  Tokens 2 / 6  |
|--------------------------------------|
| [ Rules: row | column | garden | gap ]|
|                                      |
|      A  A  B  B  C  C                |
|      A  D  D  B  C  C                |
|      A  D  E  E  E  C                |
|      F  F  E  E  C  C                |
|      F  F  F  E  B  B                |
|      A  A  F  F  B  B                |
|                                      |
|       X Mark     Creature Place      |
|                                      |
|   Undo        Hint          Rules    |
|       [Progress / garden flourish]   |
+--------------------------------------+
```

**This is a layout sketch only**, not a valid puzzle. It is explicitly **not** suitable as level data; production UI must load validated JSON fixtures. Placement of buttons, cell sizing, and modal spacing must be refined in device design prototypes.

---

## 16. QA strategy and test matrix

### 16.1 Automated correctness suites

- **Reference solver:** unpruned exhaustive enumeration for N=4..6. Cross-check optimized solver on generated region arrays for N=4..9. Stop-after-two and full-solution-count must agree where feasible.
- **Property-based:** for each supported N, generate 10,000 valid seed layouts, build partition, assert connectivity, one seed per region, exact N labels, no unassigned cells, and nonzero intended solution count. Only accept single-solution boards.
- **Metamorphic:** applying any board rotation/reflection and relabeling region IDs preserves solution count; remap solution coordinates accordingly. Saves and hashes remain canonical under consistent declared transform handling.
- **Rule adversarial:** same row, same column, same region, horizontal/vertical touching, diagonal touching, nonadjacent diagonal, zero tokens, N-1 tokens, N+1 tokens, 2x2 overlap, inconsistent givens, missing/extra region, disconnected region, malformed hash, duplicate ID.
- **Logical hint proof:** every revealed "forced" token exists in every solution consistent with actual visible constraints; every excluded cell is impossible under those constraints. Inject contradictory marks and assert hint service safely declines/reframes.
- **State machine:** 100k randomized sequences of mark/place/undo/restart/background/save/load; replayed history exactly matches final board and ledger grants are idempotent.
- **Clock simulation:** UTC day boundary, daylight-saving local changes, manually shifted device clock, timezone switching, offline gaps, leap day 2028, date rollover while board open.
- **Content QA:** all published JSON packs schema validated, signed, uniqueness asserted, logical trace complete, chapter difficulty distribution checked; hard reject before deployment.

### 16.2 Device and OS test matrix

| Group | Minimum representative devices | Tests |
|---|---|---|
| iPhone small | iPhone SE-class/small screen on supported iOS | board fit, 9x9 zoom, safe area |
| iPhone modern | 2 device generations with notch/Dynamic Island | gestures, memory, battery |
| iPad | compact/regular size and split view where supported | responsive panel, text |
| Android low-end | 2-4 GB RAM, 720p, Android 8-11 where supported | cold start, 30 FPS, storage failure |
| Android modern | Android 14-16, high refresh rate | ads/billing, insets, edge-to-edge |
| Android large | tablet/foldable emulator + one physical | resize, rotate, split-screen |
| Accessibility | VoiceOver/TalkBack, large text, color filter, reduced motion | solve full board without color |
| Network | offline, slow 2G, DNS failure, VPN, captive portal | no freezes, graceful retry |
| Billing/ads | sandbox stores, ad test devices, consent test geographies | compliant and robust flows |

### 16.3 Manual playtesting

- Recruit at least 30 external target users across first-time and experienced logic puzzlers (hypothesis), including accessibility testers.
- Record understanding without explanation, mistaken interpretation of diagonal touching, time spent, accidental placements, annoyance caused by ads, hint comprehension and perceived difficulty fairness.
- Run blind comparative preference test between two **original** UI prototypes. Do not present Meowdoku screenshots as prototypes of the proposed product.
- Define a puzzle as "unfair" if multiple users can produce a plausible alternative configuration under displayed rules; immediately re-run solver and inspect hidden assumptions.

### 16.4 Sample test vectors

| ID | Input | Expected |
|---|---|---|
| T1 | 5x5 companion fixture with `[1,4,2,0,3]` columns by row | `Win=true`, `SolutionCount=1` |
| T2 | two tokens `(0,1)`, `(1,2)` | `R4 diagonal_touch` and possibly other region/line rule depending on board |
| T3 | tokens `(0,0)`, `(2,2)` with otherwise nonconflicting row/col/region | no R4 touching conflict |
| T4 | two tokens same row at columns 0 and 4 | R1 conflict |
| T5 | same colored region, different row/column, not touching | R3 conflict |
| T6 | valid full token solution with no Xs | win must succeed |
| T7 | replay same first-win event 10 times | exactly one reward transaction |
| T8 | force-kill after third move | restored state = all three committed moves |
| T9 | change phone timezone near UTC midnight | same UTC daily board ID |
| T10 | simulate ad reward callback twice | one credit granted |

---

## 17. Delivery team, milestones, and dependencies

### 17.1 Suggested team for an independent studio

- 1 product owner/game designer (rules, economy, difficulty pacing, user tests).
- 2 Unity/C# client engineers (UI/gameplay and platform/ads/IAP).
- 1 gameplay/algorithm engineer (generation, solver, level tooling, content QA); can be one of the two Unity engineers if experienced.
- 0.5-1 backend/DevOps engineer (thin services, analytics, release automation, optional until P2).
- 1 2D illustrator/UI motion designer (contract or part time).
- 1 QA engineer/testing contractor (automation and device matrix).
- Shared audio, localization, legal/privacy, App Store publishing and growth support.

**Note:** Roles are effort categories, not a mandate to hire every role full-time. At least two independent people should review solver/content integrity before launch.

### 17.2 Example 14-week execution plan (estimate, not a guarantee)

| Weeks | Milestone | Exit artifact |
|---|---|---|
| 1-2 | Rules/visual exploration + architecture + Unity/Xcode/API 36 spike | playable 5x5 prototype, architecture review, name clearance search |
| 3-4 | Solver, generator, editor, 30 unique puzzles, core save/input | headless tests, fixture suite, low-end build |
| 5-6 | Tutorials, Journey, chapter progression, difficulty grading | onboarding study, 100 validated levels |
| 7-8 | Daily, Practice, hints, stats, accessibility | offline vertical slice, all major screens |
| 9-10 | Art/audio, cosmetics, analytics/consent, ads/IAP | monetized build with sandbox tests |
| 11-12 | 200+ approved levels, iOS/Android QA, translations, content signing | release candidate, full store compliance packet |
| 13 | Closed TestFlight + Google Play closed test | retention/usability/crash review |
| 14 | Soft launch in approved region(s), rollback plan | staged release, monitored dashboard |

Timeline assumes stable requirements, licensed art capacity, timely review accounts and working platform SDKs. If fewer engineers are available, stretch timeline or remove optional surfaces; never shortcut QA. **Advertising/UA scale should wait** until organic D1/D7, conversion and technical metrics warrant it.

### 17.3 Work breakdown and ticket epics

| Epic | Dependencies | Representative tickets |
|---|---|---|
| E01 Domain rules | none | region model; win predicate; no-touch; test vectors |
| E02 Generator and editor | E01 | seeded permutation; contiguous fill; uniqueness counter; grade trace; content manifest |
| E03 Unity board/input | E01 | grid pooling; mark/place; undo; haptics; safe area; zoom |
| E04 Save and progression | E03 | local atomic DB; migrations; Chapter map; stars; ledger |
| E05 Tutorial/hints | E01/E02/E03 | 5 tutorial steps; explanation strings; hint cost; accessibility |
| E06 Daily/practice | E02/E04 | UTC pack selection; history; safe fallback; streak |
| E07 Meta cosmetics | E04 | catalog, purchase with seeds, equip, UI |
| E08 Platform SDKs | E03 | analytics; Crashlytics; privacy; ads; billing; store review |
| E09 Content production | E02 | approve 200 puzzles; localized rules; signs; pack exports |
| E10 Testing/release | all | CI tests; builds; accessibility; QA devices; ASO; deployment |
| E11 Post-launch sync | E04/E08 | account linking, Firestore rules, conflict resolution |
| E12 Ranked challenge | E01/E08/E11 | replay audit, challenge endpoints, anti-cheat, leaderboard |

### 17.4 Development governance

- Code merges require unit tests and reviewer approval; no solver change without exhaustive fixture comparison and reproducibility report.
- Every API schema/event name has an owner and compatibility version.
- Feature flags and ads/IAP settings have rollback values stored in local defaults; remote config cannot alter base win rules for already-started levels.
- Weekly sign-off: correctness, usable content count, performance, legal/IP, analytics, scope and rollout readiness.

---

## 18. Launch preparation and storefront operations

### 18.1 Store readiness checklist

**Both stores:** unique brand and trademark review; company-owned developer accounts, privacy policy and terms pages; support address; age-rating questionnaires; data handling disclosure; ad network filtering; marketing claims checked; screenshot and preview truthfulness; localized pricing; attribution licenses for all media; signed release artifacts; crash-free smoke; recovery tests; support/feedback process; incident escalation owner.

**iOS:** Xcode 26+/iOS 26 SDK build, correct deployment target and architectures; StoreKit sandbox purchases and restore; ATT/consent if tracking; app privacy details + privacy manifests; App Store Connect IAP product metadata, reviewer notes, TestFlight device coverage; Game Center entitlement only if used [S7][S8][S14].

**Android:** `.aab` with **target API 36+**, Play App Signing, 64-bit support and current Play SDK requirements, Play Billing sandbox and refund tests, Data Safety form, ads declaration, content rating, proper background behavior, pre-launch report, Play Console closed-testing requirements as applicable to account type [S13].

**Store creative:** actual puzzle screenshots; headlines such as "One creature per garden" and "Reason it out, anywhere"; no false difficulty/brain training efficacy claims; no Meowdoku keyword stuffing or confusingly similar icon [S9].

### 18.2 Staged rollout and thresholds

- Stage 0 internal: 30 real devices, 100 test sessions across crash/restore/ad/billing/consent edge cases; zero known blocker.
- Stage 1 closed beta: 100-300 opt-in testers, two weeks worth of puzzle feedback, fix every confirmed ambiguous level.
- Stage 2 soft launch: 1-2 selected markets where compliance/support and test spend are feasible; staged Play rollout and iOS phased release if approved.
- Stage 3 expand only after 7-day cohort stability and launch gates; monitor daily and pause new paid acquisition after severe negative reviews or metric regression.

**Hard stop conditions:** puzzle with >1 valid solution, content corrupted without safe fallback, unresolved purchase mischarge, severe privacy/consent defect, game progress loss, ad trapping players, crashes exceeding agreed threshold, unauthorized copied art/name, or missing platform target requirements.

---

## 19. Risks, assumptions, and trade-offs

| Risk | Impact | Mitigation |
|---|---|---|
| App Store rejects lookalike/copycat | Critical | distinct branding/identity/UX/content, independent art review [S9] |
| Ambiguous levels / guessing | Critical | uniqueness + human solver + manual QA, no forced hidden-answer penalty |
| Ad overload lowers retention | High | rewarded-first, no in-play interstitial, experiment guardrails, creative reports |
| Poor creative/UA unit economics | High | cohort LTV and CAC measurement, do not scale on installs alone |
| Content generator monotony | High | novelty signatures, chapter art, manual curated selection, trace-based difficulty |
| Unity SDK/OS compatibility | High | early Xcode 26/API 36 builds, pin verified packages, device matrix |
| Crash/save loss on process death | Critical | atomic persistence, snapshot fallback, automated kill tests |
| Privacy/SDK data mismatch | Critical | vendor SDK audit, consent enforcement, published Data Safety/App privacy accuracy |
| Counterfeit leaderboards | Medium | defer online ranks until signed replay infrastructure |
| Subscription resentment | Medium | no MVP subscription; only add genuine recurring content if tested |
| Low-end screen readability | High | high-contrast region patterns and accessible zoom |
| Offline date manipulation | Medium | offline streaks local/unranked; challenge dates trusted server-side |
| Asset production delay | Medium | design system first; placeholder originals can be replaced with reviewed originals |
| Vendor lock-in | Medium | interfaces for ads/purchases/analytics; content and logic independent |

### 19.1 Decisions explicitly not supported by available evidence

Do not assume: Meowdoku's actual ad fill rate, CPM, net profit, retention, UA spending, cohort LTV, difficulty-generation algorithm, backend stack, hidden game source code, full live-ops event calendar, or all currently live challenge types. Public screenshot aggregators often mix versions or unofficial sites. The market evidence validates *interest in the format*, not guaranteed commercial viability for a new entrant.

---

## 20. Release definition of done

A production release can be called **feature-complete** only if all of the following are satisfied:

- [ ] Each FR-001 through FR-024 has test evidence, or written scoped exception approved by product/security owner.
- [ ] Exactly one valid solution for **every** published level, with full content hash manifest and deducible-solution grade.
- [ ] At least 200 levels + correct cached daily puzzle coverage according to approved scope.
- [ ] Rules work across 4x4 to 9x9 with correct adjacency semantics; no Sudoku 3x3 rule accidentally present.
- [ ] Full offline install -> tutorial -> Journey completion -> save/return flow passes.
- [ ] All first-run screens, tutorial, and core board usable via accessible labels and color-independent boundaries.
- [ ] iPhone/iPad/Android physical-device test matrix passed and launch crash-free metric met.
- [ ] No forced ad during puzzle; ad no-fill and close never block game; bad creative reporting exists.
- [ ] Billing flows verified for buy/cancel/restore/refund and entitlement persistence.
- [ ] Privacy/consent/data disclosure/store SDK age and target OS policies audited for launch regions.
- [ ] All brand/art/audio licensing and Apple copycat avoidance review complete.
- [ ] Dashboards, release flags, support, incident rollback, and staged deployment in place.
- [ ] TestFlight/App Store review and Play Console review artifacts are truthful and final.

**Engineering handoff files:** `Pawgrid_sample_level.json` provides a verified 5x5 fixture, and `Pawgrid_reference_solver.py` provides a standard-library, executable independent level validator. Both are included in the companion handoff ZIP. The reference validator proves rule/uniqueness correctness, not human difficulty.

**Engineering handoff rule:** No developer should infer an unmentioned mechanic from Meowdoku screenshots. If a feature or rule is not explicitly specified here, implement a safe, minimal variant and log a product decision. Player-visible puzzle logic is exclusively section 4 plus the deterministic ruleset version.

---

## 21. Developer setup / implementation order

1. Create a mono-repo with `/client-unity`, `/core-puzzle`, `/tools-level-editor`, `/content`, `/cloud-functions` (optional), `/test-fixtures`, `/docs` and CI workflows. Keep `.meta` files committed for Unity; large licensed assets in LFS if justified.
2. Bootstrap Unity 6.3 LTS with Android/iOS build modules, IL2CPP as needed, iOS build on macOS with Xcode 26+, Android SDK/NDK and API 36 build support. Confirm the chosen Unity patch and plug-ins compile before content work.
3. Implement `PuzzleDefinition` canonical parser/schema validator and pure `RulesValidator` (no Unity references). Write exact sample fixture tests.
4. Implement `ExactSolver`, generator, region connectivity checks, canonical duplicate detection, grading and proof traces. Validate 200 initial puzzles before polishing UX.
5. Implement `PuzzleSession` reducer with immutable `Move` commands and atomic persistence. Prove force-kill recovery and undo.
6. Render grid with region outlines and token/X marks; prototype accessible input and dynamic cell sizes. Add original design system.
7. Add tutorial, Journey map, Daily, Practice, hints and progress ledger. Bake 30-day daily manifests.
8. Add settings, localization, instrumentation, consent-aware SDK initialization, ad wrapper, entitlement wrapper and recoverable purchase flow.
9. Run automated property tests, real device QA, accessibility study, soft launch cohort measurement, and explicit go/no-go approval.

### 21.1 First sprint backlog - tasks with completion artifacts

| Task | Artifact | Completion test |
|---|---|---|
| `CORE-01` rules predicate | `RulesValidator.cs` | 100% T1-T6 |
| `CORE-02` count solver | `ExactSolver.cs` | cross-check exhaustive 4-6 |
| `CORE-03` seed/region builder | `LevelGenerator.cs` | always connected, exactly N |
| `CORE-04` hash/schemas | `PuzzleDefinition.cs` + JSON schema | corrupted pack rejected |
| `CORE-05` logical grader | `DeductionEngine.cs` | explanation proves every forced move |
| `APP-01` board interaction | playable Unity scene | 4x4-9x9 + accessible hit boxes |
| `APP-02` reducer/undo | `SessionReducer.cs` | 100k randomized move tests |
| `APP-03` local save | `SaveRepository.cs` | app kill/restart exact restore |
| `OPS-01` CI build | signed test Android/iOS builds | no manual undocumented secrets |
| `CONTENT-01` first levels | 30 vetted JSON fixtures | uniqueness proof and human QA |

---

## 22. External sources / research audit trail

These sources were reviewed on **8 November 2026**. Their contents, rankings, and public counts can change. Source citations support the **reference-game observations and policy facts** only; they are not claims that the proposed game currently exists or earns revenue.

- **[S1] Official App Store - Meowdoku! by Oakever Games:** https://apps.apple.com/us/app/meowdoku/id6761760135  
  Gameplay description, 3 hearts, double tap, offline/daily, leaderboard claim, subscription SKU list, iOS listing.
- **[S2] Official Google Play - Meowdoku by Oakever Games:** https://play.google.com/store/apps/details?id=com.oakever.meowdoku&hl=en-US  
  Android description, ads/IAP presence, publisher, public install band.
- **[S3] Sensor Tower, July 2026 report covering June 2026:** https://develop.sensortower.com/blog/top-10-worldwide-mobile-games-by-revenue-and-downloads-in-june-2026  
  Meowdoku ranked first in mobile game *download growth*, not overall revenue.
- **[S4] AppsXray US Google Play free puzzle chart:** https://appsxray.com/charts?category=GAME_PUZZLE  
  Third-party dynamic rankings, used only as chart snapshot.
- **[S5] Google Play public ratings/reviews:** https://play.google.com/store/apps/details?gl=us&id=com.oakever.meowdoku  
  Qualitative ads/repetition complaints; not statistically representative.
- **[S6] iOS review page:** https://apps.apple.com/in/app/meowdoku/id6761760135?platform=iphone&see-all=reviews  
  Qualitative player reports of ads and puzzle concerns.
- **[S7] Apple upcoming app upload requirements:** https://developer.apple.com/news/upcoming-requirements/  
  Xcode 26+ with iOS 26+ SDK requirement for uploaded apps since April 2026.
- **[S8] Apple App Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/  
  IAP, subscriptions, completeness, privacy and review rules.
- **[S9] Apple Guideline 4.1 copycats:** https://developer.apple.com/help/app-review/guideline-reference/4-1-prevent-copycat-rejection  
  Avoid imitation, name/icon confusion and third-party material.
- **[S10] Google AdMob Unity UMP & EU disclosure:** https://developers.google.com/admob/unity/privacy/gdpr  
  Regional user consent requirements and SDK use.
- **[S11] Google Play Developer Program Policy - subscriptions:** https://support.google.com/googleplay/android-developer/answer/18265346  
  Transparent recurrent value and billing requirements.
- **[S12] Unity 6 LTS official release support:** https://unity.com/releases/unity-6/support  
  Unity 6.3 LTS reference; always check the chosen patch version compatibility.
- **[S13] Google Play target API level policy:** https://support.google.com/googleplay/android-developer/answer/11926878?hl=en-US  
  API 36+ for new mobile app submissions and updates since August 31, 2026.
- **[S14] Apple privacy and data use:** https://developer.apple.com/app-store/user-privacy-and-data-use/  
  ATT, data collection disclosures, SDK privacy manifests.
- **[S15] Apple GameKit / Game Center:** https://developer.apple.com/documentation/GameKit  
  Optional future native leaderboards.
- **[S16] Google Play Games Services for Unity:** https://developer.android.com/games/pgs/unity/overview  
  Optional future native leaderboards / saved games.

---

## Appendix A - Configuration defaults (tune by Remote Config with conservative fallback)

```json
{
  "appConfigVersion": 1,
  "rulesetVersion": "territory-v1",
  "journeyInitialLevelCount": 200,
  "journeyLevelsPerChapter": 20,
  "boardSizes": { "min": 4, "max": 9 },
  "daily": { "timezone": "UTC", "futureDaysBundled": 30, "priorDaysBundled": 7, "notificationEnabledByDefault": false },
  "timing": { "excludeBackgroundTime": true, "excludePauseTime": true },
  "input": { "defaultMode": "Mark", "quickInputEnabledByDefault": false, "autoXEnabledByDefault": false },
  "hint": { "freeNudgeLimitPerLevel": 2, "tutorialGrantCredits": 3, "revealCost": 2, "eliminationCost": 1 },
  "ads": { "rewardedHintsEnabled": true, "rewardedSeedsDailyCap": 1, "interstitialEnabled": false, "interstitialMinimumLevel": 11, "minLevelsBetweenInterstitials": 3, "interstitialCooldownSeconds": 180 },
  "shop": { "paidSubscriptionsEnabled": false, "removeForcedAdsVisible": false },
  "online": { "mandatoryLogin": false, "cloudSyncEnabled": false, "rankedLeaderboardEnabled": false },
  "accessibility": { "patternRegionsEnabled": true, "reduceMotionRespectsOS": true },
  "rewards": { "firstJourneySolveSeeds": 10, "cleanSolveBonusSeeds": 2, "firstDailySolveSeeds": 20, "tutorialSeeds": 30 }
}
```

**Config fail-safe:** if Remote Config is missing/corrupt, use bundled values above. Make ads/interstitial changes only through feature gates with clearly audited defaults; remote config must never circumvent platform consent.

## Appendix B - Suggested JSON schema core invariants

```text
PuzzleDefinition JSON (logical schema constraints):
  levelId: string, unique within catalog, 1..80 characters
  contentVersion: positive integer
  rulesetVersion: exactly "territory-v1" for this PRD
  n: integer, 4 <= n <= 9
  regions: array of n arrays, each n integers in [0, n-1]
  givens: array of {row, col, mark} with mark in ["Token","Excluded"]
  difficulty: enum ["tutorial", "easy", "medium", "hard", "expert"]
  difficultyScore: integer in [0,100]
  solutionColumnsByRow: n integers, exactly one valid column per row
  solutionCount: exactly 1 on approved packs
  contentHash: SHA-256 of canonical invariant fields
  generatorVersion: string
  sourceSeed: integer or base64 seed bytes

Validate:
  all n labels present and orthogonally connected
  each region includes exactly one solution token
  solution columns are a permutation with no adjacent-row diagonal gap 1
  givens agree with solution and cannot force a contradiction
  independent solver finds exactly one solution
  deduction engine verifies all published non-tutorial boards under allowed tactics
```

## Appendix C - Change control and remaining product questions

| Question | Default decision in this PRD | Decision owner / timing |
|---|---|---|
| Final game name? | "Project Pawgrid" is codename, not cleared | founder + legal before brand assets |
| Theme? | original garden / creature identity | founder + art before UI implementation |
| Initial countries? | controlled soft launch, 1-2 markets | growth + legal before beta |
| Full launch language set? | English first, quality-checked Hindi/Spanish optional | product/localization before store content |
| Interstitials? | off at launch; experiment post-soft-launch | product + growth after D7 data |
| Nonconsumable supporter offer? | only if real value and fully supported | product + monetization before IAP review |
| Online leaderboard? | not MVP, avoid fraud/clock fairness claims | product/backend after D7 proof |
| Cross-device sync? | not MVP; fully offline core | product/backend after launch |
| Exact number of release puzzles? | 200 Journey + 30 future daily + 7 prior | product + content lead at P1 scope lock |
| User accounts? | not required | product/privacy before P2 |

**End of PRD v1.0.**
