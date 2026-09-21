# Round-3 media — read-back log (PR #307, `feat/arena-setup` @ `cb1b0f22`)

Round 3 is one maintainer ruling: **the SETUP wizard's cyclers turn forward
only.** The `<` reverse cell is gone from every wizard row, the right-click
reverse is gone with it, and the terminals' `N- steps a wheel back` grammar is
retired — the prompt reads `Setup # [1-N] (0 = back): ` again. Nothing else on
these screens moved.

So this round does not re-take the whole set. It re-takes only the frames that
**showed a `<` cell**, rebuilds the three compositions that embedded one, and
re-drives the three `openglad_text` transcripts that printed the retired
prompt. Every other round-2 file in this directory is still the truth and is
still what the PR body links; `READBACK-round2.md` remains the record for
those.

New files carry the suffix `-r3` (`r3-` for the transcripts) so every round-2
link keeps resolving.

## Provenance

The SDL frames were captured on **2026-09-21** from
`/home/yans/code/openglad/build/ci-test`, tree `feat/arena-setup` @
`cb1b0f22` (clean), through the production capture seam
(`og_test_matchup --gtest_filter='MatchSetupUi.*'` → `capture_frame()` into
`UXSHOTS_DIR`), with `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
SDL_RENDER_DRIVER=software`. The binary that dumped them was built from the
working tree that became `b38d7bfd` (it stamps itself `1cacefb7+`); `cb1b0f22`
adds documentation and one gate row on top of `b38d7bfd` and changes no
rendered pixel. The transcripts were produced by `openglad_text` built and
stamped `cb1b0f22`, each in its own scratch `HOME` / `OPENGLAD_CONFIG_DIR`,
driven by the **same `.stdin` files round 2 used** (copied beside each one);
`git status --porcelain cfg/` was empty afterwards.

Compositions use the repository's own recipe — `caption` + `side_by_side` from
`scripts/media/capture_pr292.sh`, ImageMagick `label:` strips at pointsize 18
on `#202028`, halves smushed 6 px apart. **Self-check:** running that recipe on
round 2's own halves reproduces the shipped `r2_cmp_rules.png`
**byte-identically** (`compare -metric AE` = 0), so the only difference in the
files below is the frames themselves and the tree label in the strip.

## Measured, not eyeballed

The retired cell column is `x = 280..308`, right edge 310. Cropping
`x = 277..309` between the tab strip and the panel floor (`y = 56..140`) and
counting unique colours:

| Frame | round 2 | round 3 |
|---|---|---|
| `setup_step_rules` | 11 | **1** |
| `setup_step_teams` | 11 | **1** |
| `setup_step_teams_four_sides_rest` | 10 | **1** |
| `setup_step_teams_four_sides_brutal` | — | **1** |
| `setup_step_teams_four_sides_empty` | 10 | **1** |
| `setup_step_teams_four_sides_healed` | — | **1** |

One flat colour across the whole band: no cell face, no bevel, no glyph. The
row faces are unchanged at `12..274` (right edge 276) — round 3 removed the
column, it did not widen the rows into it.

Each `_x4` file is an exact nearest-neighbour ×4 of its 1x sibling (verified,
AE = 0 for all six), so reading the 4x back reads the 1x back.

A whole-frame diff against round 2 says the same thing from the other side:
`setup_step_game` and `setup_arena_paged` and `setup_go_gated` are **AE = 0**
— byte-identical, because they never carried a cell — while
`setup_step_arena`, `setup_step_match` and `setup_joiner_rules` differ only in
where the keyboard-highlight rectangle sits. None of those needed re-shipping.

## What I see in each new frame

| File | What I see in it |
|---|---|
| `setup_step_rules-r3` | `[RULES]` pressed in. The pointer line `RESPAWNS AND THE REST: THE BASE CAMP DIFFICULTY.`, then exactly two rows — `SCORE: MAP - MAP, 1, 3, 5, 10` (highlighted) and `TIME LIMIT: MAP - MAP, 5 TO 20 MIN`. To the right of them: nothing. Footer `BACK` / `PREV` / `NEXT` unchanged. |
| `setup_step_teams-r3` | 820, DEP 2/2. Two swatched team lines (`TEAM 1 P1 WASD 2 FIGHTERS`, `TEAM 2 3 BOTS`), the campaign line `STRONG ADDS A FIGHTER, BRUTAL TWO.`, then `FILL: STRONG - WEAK TO BRUTAL` (highlighted) and the `LINEUP … >` door. No SIDES row — the arena authors two sides. No cell beside FILL. |
| `setup_step_teams_four_sides_rest-r3` | 822 FOURSQUARE, DEP 2/2, `2 FIGHTERS`; `3 BOTS` on TEAM 2, 3 and 4 (the arena's own STRONG deal); `SIDES: 4 - 2, 3, 4`; `FILL: STRONG - WEAK TO BRUTAL`; LINEUP. The highlight is still on the `[TEAMS]` tab — nothing clicked on this step yet. |
| `setup_step_teams_four_sides_brutal-r3` | The same company one FILL click later: `FILL: BRUTAL` highlighted and **`4 BOTS` on TEAM 2, 3 and 4** against the same `2 FIGHTERS`. `SIDES: 4` and `DEP 2/2` unchanged. Every AI side moved by one body. |
| `setup_step_teams_four_sides_empty-r3` | The trap: every band wheeled to NONE in LINEUP. `NO FIGHTERS` on TEAM 2, 3 and 4, `SIDES: 1`, `FILL: NONE`. The keyboard highlight sits on `BACK` (it did in round 2 too — the LINEUP door returns focus there). |
| `setup_step_teams_four_sides_healed-r3` | One FILL click out of that collapse: `SIDES: 4`, `FILL: WEAK`, `2 BOTS` on all three AI sides. Not one side, and not a collapse to SIDES 2. |

## Compositions

| File | Shape |
|---|---|
| `cmp_rules-r3` | round-1 `setup_step_rules_x4` (eight rows, eight `<` cells) beside round 3's (pointer line + two rows, no cells). Strips: `BEFORE  ROUND 1  PR #307 @ 121716f8` / `AFTER  ROUND 3  PR #307 @ cb1b0f22`. The BEFORE half is byte-for-byte the file round 2 used. |
| `cmp_teams_four_sides-r3` | `_rest-r3` beside `_brutal-r3`: ONE company (IRON KETTLE, 822, DEP 2/2, 2 FIGHTERS), ONE click apart. `3 BOTS` ×3 / STRONG → `4 BOTS` ×3 / BRUTAL. Both halves are this tip; round 1 never captured a four-side arena after a FILL click, so this pair shows the fixed behaviour rather than a cross-tree diff. Strips unchanged from round 2. |
| `cmp_teams_trap-r3` | `_empty-r3` beside `_healed-r3`, same company: `SIDES: 1` / `FILL: NONE` / `NO FIGHTERS` ×3 → `SIDES: 4` / `FILL: WEAK` / `2 BOTS` ×3, one click. Strips unchanged from round 2. |

## Text records, re-driven on this tip

Same `.stdin` files, same flows, `openglad_text` @ `cb1b0f22`.

| File | What changed against its `r2-` twin |
|---|---|
| `r3-census-822.txt` | Diffed line for line against `r2-census-822.txt`: the **only** differences are the randomly generated company name (`GREY BADGER CREW` → `IRON CROW BAND`, and the `P1 GRE` → `P1 IRO` seat tag it derives) and the prompt, `Setup # [1-N] (0 = back, N- steps a wheel back):` → `Setup # [1-N] (0 = back):`. Every census number the PR body quotes is unchanged: 822 at rest `SIDES: 4 / FILL: STRONG` with `2 BOTS` ×3, one turn → BRUTAL `3 BOTS` ×3, all-NONE → `SIDES: 1 / FILL: NONE`, one turn from there → `SIDES: 4 / FILL: WEAK`, `1 BOT` ×3. |
| `r3-census-300.txt` | Same: name and prompt only. 300's rows are unchanged — the counts stay at 1 BOT (team deathmatch buys power, not bodies) while the FILL word moves on all four bands together. |
| `r3-text-camp-setup-random.txt` | This one is a **roll**, so its content legitimately differs: the GAME step's `8. RANDOM - any game, any arena` answered `Level set to Onslaught: THE MARCHES.` this time (round 2 rolled Team Deathmatch: BLOODGLADE), and the SOCCER page's `5. RANDOM ARENA - any arena of this game` answered `Level set to Soccer: FOURSQUARE.`. Everything the PR body claims from it still reads off the page: the camp's ONE row (`1. SETUP - ONSLAUGHT: THE MARCHES  >`, then `1. SETUP - SOCCER: FOURSQUARE  >` after the second roll), the RANDOM rows sitting LAST on their pages, Team Build listing 12 items with no `Setup`, and no prompt anywhere offering a step back. Because this roll landed on an Onslaught arena before the SOCCER page was opened, no `[CURRENT]` tail shows on that page — round 2's transcript happened to show one; the tail itself is unchanged and is photographed in `r2_setup_step_arena_x4.png`. |

## Not re-taken, and why

- **The camp, GAME, ARENA, MATCH, the joiner's RULES, the paged CTF ARENA, the
  GO gate, PROGRESS, the campaign card, the full roster.** None of them ever
  drew a `<` cell (proved above by AE = 0 or by a highlight-only diff), so
  round 2's files are still the truth.
- **`r2_cmp_stamp.png`.** It stacks round 1's main menu over round 2's and
  still documents those two trees, which is where the body cites it. The
  round-3 frames' provenance is this file's first section instead.
