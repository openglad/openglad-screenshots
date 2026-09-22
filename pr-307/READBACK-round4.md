# Round-4 media — read-back log (PR #307, `feat/arena-setup` @ `c2b0f753`)

Round 4 is three maintainer rulings, all about how a wizard row **looks** and
how a long list **pages**:

1. **Arena rows are plain.** The SETUP wizard painted its ARENA rows green.
   Green now marks one thing on these screens — the row that starts the match.
2. **Every row is full width.** The 30 px cell column that used to close the
   right rail of the wizard panel *and* of the Base Camp docket is gone; a row
   runs from the one left edge to the one right edge, 48 glyphs.
3. **The side pager pair became a pager ROW.** `<` `>` in the right rail are
   replaced by a last row — `MORE ARENAS - n/2  >` on the wizard's ARENA page,
   `MORE - n/m  >` on a Base Camp docket — and a paged window **opens on the
   window holding the `[CURRENT]` row**, keeping a browsed window until the
   current row moves.

Nothing else moved. New files carry the suffix `-r4`, so every round-2 and
round-3 link in the PR body keeps resolving; `READBACK-round2.md` and
`READBACK-round3.md` remain the record for the files they describe.

## Provenance

The SDL frames were captured on **2026-09-22** from
`/home/yans/code/openglad/build/ci-test`, tree `feat/arena-setup` @
`c2b0f753` (clean), through the production capture seam
(`og_test_matchup --gtest_filter='MatchSetupUi.*'` and the zone capture
points → `capture_frame()` into `UXSHOTS_DIR`), with `SDL_VIDEODRIVER=dummy
SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software`.

Every `_x4-r4` file is an exact nearest-neighbour ×4 of its 1x sibling
(`compare -metric AE` = 0 for all 17 pairs), so reading the 4x back reads the
1x back.

Compositions use the repository's own recipe — `caption` + `side_by_side` from
`scripts/media/capture_pr292.sh`, ImageMagick `label:` strips at pointsize 18
on `#202028`, halves smushed 6 px apart. **Self-check:** running that recipe
on round 3's own halves reproduces the shipped `cmp_rules-r3.png`
**byte-identically** (`compare -metric AE` = 0), so the only differences in
the files below are the frames themselves and the tree label in the strip.

## Measured, not eyeballed

### The rows grew to the right edge, and only to the right

One scanline through a row's top bevel, `setup_step_rules`:

| | left | row face | right |
|---|---|---|---|
| round 3 | `12` bevel `C4C4C4` | `A4A4A4` to **274** | `275` shadow, then a dead rail `276..309` |
| round 4 | `12` bevel `C4C4C4` | `A4A4A4` to **308** | `309` shadow, panel edge `310` |

The keyboard-highlight rectangle (`E4E400`) moved with it: its right edge
reads `x = 276` in round 3 and `x = 310` in round 4. The left edge is
**identical** in both — round 4 widened the right side only. The same
measurement on the Base Camp docket (`zone_default_modes`): the SETUP row's
top bevel ran `12..274` in round 2 and runs `12..308` now, with the bottom
shadow at `13..309`.

This matches `src/interface/ui/picker_sdl_defs.h`: `kSetupRowX = 12`,
`kSetupRowW = 298`, `kSetupRightEdge = 310`, `kSetupRowLabelChars = 48`,
static-asserted equal to `kBaseCampZoneActionRowWidth`.

### Green is GO's alone

Counting `#008000` pixels over the whole frame:

| Frame | green px |
|---|---|
| `setup_step_arena`, round 1 | 7327 |
| `setup_step_arena`, round 4 | **0** |
| `setup_step_match`, round 4 | 2346 — the GO row, and nothing else |
| `zone_camp_westlands_fork`, round 4 | 4202 — a campaign's own docket rows, which *do* launch |

So the wizard's list rows lost their green and the launch faces kept theirs.

### `setup_joiner_rules` was not re-taken

`compare -metric AE` against its round-2 file is **0** — byte-identical. A
joiner's RULES step is a caption plus one packed text line; it never drew a
row, so it never had a cell column to lose. The PR body still links the
round-2 file.

## What I see in each new frame

| File | What I see in it |
|---|---|
| `setup_step_game-r4` | `[GAME]` pressed in. Eight full-width grey rows, the last `RANDOM - ANY GAME, ANY ARENA`; the others `TEAM DEATHMATCH - 6 ARENAS  >` down to `FREE FOR ALL - 6 ARENAS  >`. The yellow highlight is on SOCCER and closes on the panel's right edge. No cell column, no green, no `Cleared` line. |
| `setup_step_arena-r4` | `[ARENA]` pressed in, `KICK THE BALL INTO THEIR GOAL.`, then five plain rows: THE PITCH (highlighted, `[CURRENT]`), THE MUDBOWL, FOURSQUARE, BONEYARD CUP, and `RANDOM ARENA - ANY ARENA OF THIS GAME` last. Four arenas + RANDOM fit, so no pager row. |
| `setup_arena_paged_window_1-r4` | CTF, `SCEN 508`, window **1/2**: FIRST BLOOD, A BORDER FORT, CASTLE CORNER, THE OUTPOST, RIVER RUN (highlighted), TRIAD, THE UNDERPASS — seven arenas — and the last row `MORE ARENAS - 1/2  >`. Eight rows, the ceiling. |
| `setup_arena_paged-r4` | The same page as the wizard **opens** it: window **2/2**, because `CENTWHEIT MANOR  [CURRENT]` lives on it. DUNGEON OF STARS, CENTWHEIT MANOR `[CURRENT]`, CROSSFIRE, `RANDOM ARENA`, then `MORE ARENAS - 2/2  >`. Highlight on the `[ARENA]` tab — the step was entered, not clicked into. |
| `setup_step_teams-r4` | 820, DEP 2/2. Two swatched team lines (`TEAM 1 P1 WASD / 2 FIGHTERS`, `TEAM 2 / 3 BOTS`), the campaign line, then `FILL: STRONG - WEAK TO BRUTAL` (highlighted, full width) and `LINEUP - FILL PER TEAM, MAP UNITS  >`. No SIDES row — the arena authors two sides. |
| `setup_step_rules-r4` | `[RULES]` pressed in, the pointer line `RESPAWNS AND THE REST: THE BASE CAMP DIFFICULTY.`, and exactly two full-width rows: `SCORE: MAP - MAP, 1, 3, 5, 10` (highlighted) and `TIME LIMIT: MAP - MAP, 5 TO 20 MIN`. |
| `setup_step_match-r4` | `[MATCH]` pressed in. The recap: the arena, two swatched team lines, then SCORE/TIME LIMIT, RESPAWNS/SPAWN DELAY, PERMADEATH/GENERATORS, DIFFICULTY/INFINITE GOLD — every rule line, as the step that states the whole match. Then `VIEW LEVEL - THE ARENA AND EVERY TEAM  >` and a **green, full-width GO** with the highlight on it. |
| `setup_step_teams_four_sides_rest-r4` | 822 FOURSQUARE, DEP 2/2, `2 FIGHTERS`; `3 BOTS` on TEAM 2, 3 and 4 (the arena's own STRONG deal); `SIDES: 4 - 2, 3, 4`; `FILL: STRONG - WEAK TO BRUTAL`; LINEUP. Highlight still on the `[TEAMS]` tab. |
| `setup_step_teams_four_sides_brutal-r4` | The same company one FILL click later: `FILL: BRUTAL` highlighted, **`4 BOTS` on TEAM 2, 3 and 4** against the same `2 FIGHTERS`. Every AI side moved by one body. |
| `setup_step_teams_four_sides_empty-r4` | The trap: every band wheeled to NONE in LINEUP. `NO FIGHTERS` ×3, `SIDES: 1`, `FILL: NONE`. Highlight on `BACK` (the LINEUP door returns focus there). |
| `setup_step_teams_four_sides_healed-r4` | One FILL click out of that collapse: `SIDES: 4`, `FILL: WEAK`, `2 BOTS` on all three AI sides. |
| `zone_default_modes-r4` | Base Camp on Multiplayer Arenas: the roster, and one full-width docket row `SETUP - TEAM DEATHMATCH: THE CIRCLE  >` at the foot of the panel — plain grey, closing on the panel edge. Strip: BACK · DIFFICULTY · SCENARIO · NETWORK · GO. |
| `zone_default_modes_full_roster-r4` | The same camp with seven heroes and `DEP 8/8`, roster page 1/2: the SETUP row keeps its place at the foot of the panel and its full width. |
| `zone_camp_westlands_fork-r4` | A **classic** campaign's docket, paged: two green launch rows (`THE HIDDEN REFUGE  [CURRENT]`, `THE HIGH PASS - SOUTH, OVER SNOW`) over `MORE - 1/3  >`. The window opens here because `[CURRENT]` is on it. Green survives where a row launches. |
| `zone_camp_longseason-r4` | The Long Season's spring docket: `MUD PAY - KILL WORK  [CURRENT]` (green), `TAKE AN ADVANCE - 700 NOW, 900 AT TOLL`, `KETTLE'S STORES - CRATES FOR THIS JOB  >` (highlighted). Three units fit above the roster, so **no** pager row on this state. |
| `setup_go_gated-r4` | The MATCH step with GO **gated**: 822, `DEP 1/2`, so the GO row reads `GO - DEPLOY FOR EVERY PLAYER` on a dark, un-green face — the one row that would launch, saying why it will not. `VIEW LEVEL` above it is a normal row. |

## Compositions

| File | Shape |
|---|---|
| `cmp_basecamp-r4` | Round 1's camp (`CLEARED 0/40`, three docket rows, a SETUP slot on the strip) beside round 4's (one full-width `SETUP - TEAM DEATHMATCH: THE CIRCLE  >`, DIFFICULTY back on the strip). Strips: `BEFORE  ROUND 1  PR #307 @ 121716f8` / `AFTER  ROUND 4  PR #307 @ c2b0f753`. |
| `cmp_game-r4` | Round 1's GAME step (`CLEARED: 0 OF 40.`, `0/6 CLEARED` per row) beside round 4's (arena counts, `RANDOM` last, full-width rows). |
| `cmp_arena-r4` | The green one. Round 1: `NEXT UNCLEARED: THE PITCH.` over four **green** arena rows. Round 4: no pointer line, five plain full-width rows, `RANDOM ARENA` last. |
| `cmp_rules-r4` | Round 1's eight rows each with a `<` cell in the right rail, beside round 4's pointer line + two full-width rows. |
| `cmp_teams_four_sides-r4` | `_rest-r4` beside `_brutal-r4`: ONE company (IRON KETTLE, 822, DEP 2/2, 2 FIGHTERS), ONE click apart. `3 BOTS` ×3 / STRONG → `4 BOTS` ×3 / BRUTAL. Both halves are this tip. |
| `cmp_teams_trap-r4` | `_empty-r4` beside `_healed-r4`, same company: `SIDES: 1` / `FILL: NONE` / `NO FIGHTERS` ×3 → `SIDES: 4` / `FILL: WEAK` / `2 BOTS` ×3, one click. |
| `cmp_arena_paged-r4` | **New.** The CTF ARENA page's two windows side by side: window 1/2 (seven arenas over `MORE ARENAS - 1/2  >`) beside window 2/2 — the one the wizard opens on, because `CENTWHEIT MANOR  [CURRENT]` is on it. Strips name the windows, not trees; both halves are this tip. |

## Not re-taken, and why

- **`setup_joiner_rules`** — AE = 0 against round 2 (measured above).
- **The PROGRESS screen, the campaign card, the build stamps, the gameplay
  pairs (`cmp_s10` / `cmp_s11` / `cmp_s13`) and the `openglad_text`
  transcripts.** Round 4 changed a row's rect, its face colour and where a
  pager lives; none of those surfaces carries a wizard row, and the terminal
  clients never drew the cell column at all. The round-2 and round-3 files
  remain the truth and remain what the PR body links.

## One consequence, flagged for the maintainer

A pager ROW costs a row. A Base Camp docket that pages now shows **one fewer
unit per window** than it did with the side `<` `>` pair. The visible case is
The Long Season's **Settlement Day**, whose docket opens on the window holding
its `[CURRENT]` row and therefore shows that row alone above `MORE - 2/3  >`,
with `DRAW YOUR PAY` one click behind. The fix is content, not code: give that
state's docket a third unit, at the cost of a roster row.
