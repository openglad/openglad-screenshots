# AFTER media — read-back log (PR #307, `feat/arena-setup` @ `121716f8`)

Every image below was produced on **2026-09-19** from
`/home/yans/code/openglad/build/ci-test`, built from
`121716f841cb3ca41e9d4c10b132df7d64eb3d5c` with a clean working tree
(`og_git_hash.h` → `"121716f8"`, `OPENGLAD_VERSION_STRING "2.1127"`, no `+`).
Each of the three capture binaries was verified to carry that hash before a
shot was taken. `mainmenu_with_company*.png` prints the stamp on screen.

Every capture went through a production seam — `capture_presented_frame()` /
`capture_frame()` into `UXSHOTS_DIR` for menus, `openglad_demo`'s BMP frame
dump for gameplay, `openglad_text`'s own stdout for the terminal. Nothing was
drawn, retouched or assembled by hand except the caption strips and crops
listed under **Compositions**. Every SDL run used
`SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software`, a
scratch `OPENGLAD_CONFIG_DIR`, and was followed by
`git status --porcelain cfg/` (empty every time).

**I read every image in this directory back before writing this file.** What
follows is what each one actually shows, not what it was supposed to show.

## Measured geometry (SPEC §2.0, lead ruling 16)

Not eyeballed — measured on the raw PPMs by locating the `(228,228,228)`
bevel highlight run on each row:

| Element | Measured span (320×200 frame) | SPEC |
|---|---|---|
| Tab strip, 5 tabs | `12–64 · 73–125 · 134–186 · 195–247 · 256–308` | 54 wide, gap 7, last tab ends on **310** ✓ |
| Knob / door rows | `12–274` (face) → right edge **276** | rows end on 276 ✓ |
| Reverse `<` cells | `280–308` → right edge **310** | cells end on 310 ✓ |
| Panel frame | `9–310` | one right edge ✓ |
| TEAMS team line | swatch `8–17`, `TEAM n` from **26**, seat cell from **70**, census cell from **188** | 26 / 70 / 188 ✓ |
| Footer | `BACK 10–52`, `PREV 224–262`, `NEXT 270–308` | pagers end on 310 ✓ |

The same numbers hold on `setup_step_teams`, `setup_step_rules` and
`setup_step_teams_four_sides`. No overdraw, no clipped glyph and no row that
runs past its edge appears in any shot.

## Single screens (1x = 320×200, `_x4` = 1280×800 nearest-neighbour)

| File | What I see in it |
|---|---|
| `zone_default_modes` | Base Camp on `modes`, scen 300, 2 deployed. Readout `CLEARED 0/40`. Three docket rows: `GAME: TEAM DEATHMATCH - 0/6 CLEARED >`, `ARENA: THE CIRCLE - 4 TEAMS, TO 20 >`, `RANDOM ARENA - ANY GAME, ANY ARENA`. Roster below (ALPHA, BETA, both team 1). Seat rail `P1 WASD` + three `ADD PLAYER`. Strip: `BACK · SETUP · SCENARIO · NETWORK · GO`. No BOOK, no STAMPED, no MATCH SETUP row. |
| `setup_step_game` | Tabs `[GAME] ARENA TEAMS RULES MATCH`, GAME pressed-in and bracketed. Line `CLEARED: 0 OF 40.` Seven game rows, each `NAME - n/m CLEARED >`. The keyboard highlight (yellow outline) sits on **SOCCER** — the current game, because line B reads `SCEN 820: SOCCER: THE..`. Footer `BACK` and `NEXT` only: no PREV on the first step. |
| `setup_step_arena` | `GAME [ARENA] TEAMS RULES MATCH`. Two campaign lines: `KICK THE BALL INTO THEIR GOAL.` / `NEXT UNCLEARED: THE PITCH.` Four green arena rows; `THE PITCH - 2 SIDES, 3 GOALS  [CURRENT]` is highlighted. Footer `BACK · PREV · NEXT`. |
| `setup_step_teams` | `[TEAMS]` pressed-in. Two swatched team lines: red square + `TEAM 1  P1 WASD` + `2 FIGHTERS`; green square + `TEAM 2` + `3 BOTS`. Campaign line `STRONG ADDS A FIGHTER, BRUTAL TWO.` Rows `FILL: STRONG - NONE TO BRUTAL` (highlighted, with its `<` cell at 280–308) and `LINEUP - FILL PER TEAM, MAP UNITS >`. No SIDES row — the arena authors two sides. 3 bots is STRONG on a 2-human side (H+1). |
| `setup_step_teams_four_sides` | scen 822 FOURSQUARE, `DEP 1/2`. Four swatched lines: `TEAM 1  P1 WASD  1 FIGHTER`, `TEAM 2  P2 ↑←↓→` with the census cell **dimmed** reading `NEEDS 1 FIGHTER`, `TEAM 3  2 BOTS`, `TEAM 4  2 BOTS`. Two campaign lines. Rows `SIDES: 4 - 2, 3, 4`, `FILL: STRONG`, `LINEUP`, each with its `<` cell. This is the SIDES row appearing only where the arena authors more than two sides. |
| `setup_step_rules` | `[RULES]`. Eight cycler rows — SCORE, TIME LIMIT, RESPAWNS, SPAWN DELAY, PERMADEATH, GENERATORS, DIFFICULTY, INFINITE GOLD — each `NAME: VALUE - hint` with its own `<` cell. Row pitch 12 px, all eight inside the panel, nothing clipped. |
| `setup_step_match` | `[MATCH]`. Line `SOCCER: THE PITCH`; two swatched census rows `RED TEAM  ACTIVE - COMPANY (2)` and `GREEN TEAM  ACTIVE - MATCHED BOTS (3) STRONG`; the eight rules two per line in exactly the RULES spellings; then `VIEW LEVEL - THE ARENA AND EVERY TEAM >` and a **green** `GO` bar. Footer has `BACK · PREV` and no NEXT. |
| `setup_go_gated` | scen 822, `DEP 1/2`, four census rows. GO is **not** green: it is the dimmed face `GO - DEPLOY FOR EVERY PLAYER`. The reason rides the button; nothing else on the screen changed. |
| `setup_joiner_rules` | Line B reads `JOINED: 2 PLAYERS / 2 MACHINES` — a networked joiner. `[RULES]` is up, and the knob rows are **gone**: the caption `THE HOST SETS THESE FOR EVERYONE.` then the same eight rules as read-only text, two per line. One row survives, `CROSS CONTROL: OWN - OWN, ALL`, and it has no `<` cell. NEXT carries the keyboard highlight. |
| `setup_arena_paged` | scen 507, a CTF page with more arenas than one window: `< >` pagers on the first row's right and `2/2` beneath them, three arena rows with `[CURRENT]` on `DUNGEON OF STARS`. The pagers end on 310 like the cells. |
| `scenario_band` | SCENARIO subscreen. `SET CAMPAIGN  MULTIPLAYER ARENAS`, `SET LEVEL  SCEN 820: SOCCER: THE PITCH`, then `VIEW LEVEL · PROGRESS · LINEUP`, then empty space where the `SCORE: MAP` row used to be, then `BACK`. The empty band is the deliberate consequence of `ctf_capture_limit` having one home (SETUP → RULES). |
| `campaign_card_modes` | The campaign browser with `MULTIPLAYER ARENAS` selected (row 5 of 8) and its card on the right: title `MULTIPLAYER ARENAS`, `V1`, the four-colour icon, `YOUR POWER: 21 / SUGGESTED POWER: 60`, `0 OUT OF 40 COMPLETED`, `BY OPENGLAD`, and the description `SEVEN GAMES, FORTY ARENAS: TEAM DEATHMATCH, CAPTURE THE FLAG, ONSLAUGHT, MUTANT, SOCCER, BASKETBALL` with `MORE` for the rest. |
| `view_level_staged` | VIEW LEVEL on a staged 820. The pitch render, then `MATCH: SOCCER - 2 TEAMS ACTIVE`, `RED TEAM  ACTIVE - COMPANY (2)`, `GREEN TEAM  ACTIVE - MATCHED BOTS (3) STRONG`, `SEATS: CO-OP`, `P1 YOU - RED TEAM`, and the red team's two named fighters. Pager `1/2`. |
| `lineup_820_fresh` | LINEUP on a fresh 820. `TEAM 1 POWER 5182  P1 WASD` / `FILL: STRONG` / `1 FIGHTER`; `TEAM 2  NO SEAT` / `FILL: STRONG` / **`2 BOTS`**; teams 3 and 4 `FILL: NONE` / `EMPTY`. The dealt STRONG and its two bodies, with no knob touched. |
| `mainmenu_with_company` | The main menu with the build stamp `V2.1127 121716F8` bottom-centre. This is the provenance for every other file here. |

## Compositions

| File | What it is |
|---|---|
| `cmp_s1_basecamp.png` | S1 side-by-side, 4x each half. BEFORE: `BOOK 0/40`, `GAME: … 0/6 STAMPED`, `FIELD: THE CIRCLE`, `RANDOM SCENARIO - ANY GAME, ANY FIELD`, a fourth row `MATCH SETUP - 4-WAY, FAIR, MAP >`, strip `… DIFFICULTY …`. AFTER: `CLEARED 0/40`, `GAME: … 0/6 CLEARED`, `ARENA:`, `RANDOM ARENA - ANY GAME, ANY ARENA`, no fourth row, strip `… SETUP …`. Same roster, same seat rail, same GO. |
| `cmp_s1_strip_x4.png` | The command strip alone, 4x, stacked. `BACK · DIFFICULTY · SCENARIO · NETWORK · GO` over `BACK · SETUP · SCENARIO · NETWORK · GO`. Same five rects; only the second word moved. |
| `cmp_s2_setup.png` | S2. BEFORE: the Camp's MATCH SETUP page — `CAMP: MATCH SETUP` on line B, page line `MAP SCORE.`, four Lua knob rows (`TEAMS: 4`, `FILL: FAIR`, `TARGET SCORE: MAP`, `TIME LIMIT: MAP`), no cells, `BACK` alone. AFTER: the wizard's TEAMS step on 820 with tabs, swatched team lines in columns, the campaign's line, `FILL: STRONG` with its `<` cell, the LINEUP door, and `BACK · PREV · NEXT`. |
| `cmp_s5_go_x4.png` | The gated GO row alone at 4x: `GO - DEPLOY FOR EVERY PLAYER` on the dimmed face. |
| `cmp_s6_scenario.png` | S6. BEFORE has `SCORE: MAP` on the y=140 row and the title `MULTIPLAYER GAME MODES`; AFTER has no knob row and the title `MULTIPLAYER ARENAS`. Everything else is pixel-for-pixel the same screen. |
| `cmp_s7_text.png` | S7 as text, because **no BEFORE screenshot of the campaign card can be produced** (see the panel's own note). The `campaign.yaml` title and description, before beside after. |
| `cmp_s8_text.png` | S8 as text: `scen820.fss`'s briefing before and after — the rules text identical, `PLAY ON, CONTENDERS.` → `PLAY ON.`, `-- THE GAMESMASTER` gone — plus the measured statement that all 40 `.fss` diffs are confined to the description block. |
| `cmp_s9_transcript.png` | The terminal client's own output: the GAME step's seven rows, the TEAMS step reading `TEAM 2 GREEN  2 BOTS` beside `FILL: STRONG`, and the MATCH step stating the whole match. The full transcript is `after-text-flow.txt`. |
| `cmp_s10_lineup.png` | S10. BEFORE is LINEUP on scen 300 at `FILL: FAIR` with `NO MAP UNITS` in every census cell (the base tree had no 820 LINEUP shot); AFTER is LINEUP on a fresh 820 with `FILL: STRONG` and `2 BOTS`. The caption strips name both arenas — this pair is not the same level and says so. |
| `cmp_s10_census_x4.png` | TEAM 2's band alone at 4x: `FILL: STRONG` · `MAP UNITS` (dimmed) · `2 BOTS`. |
| `cmp_s11_viewlevel.png` | S11. Same staged 820, same two-fighter company. BEFORE: `MATCHED BOTS (2) FAIR`. AFTER: `MATCHED BOTS (3) STRONG`. The two pitch previews are **not** the same render — the AFTER half is panned so the top wall row and the left wall column are in frame (`magick compare`: 20143 differing pixels, 31 % of the 320x200 frame). See gap 8: the pan is wall-clock, not staging. The census lines are the comparison. |
| `cmp_s11_census_x4.png` | The census lines of that pair alone at 4x, stacked, so the `(2) FAIR` → `(3) STRONG` change reads column for column. |
| `cmp_s13_soccer.png` | Two frames of the same seeded soccer demo (seed 1337, `TEAM_SIZE=1`), left `OPENGLAD_DEMO_FILL=2` (FAIR), right `=4` (BRUTAL). **Both halves are the kickoff**: the red fighter, the ball on the centre spot, and the bots — one green on the left, **three** on the right. FAIR is frame 0 and BRUTAL frame 8, because `CAPTURE_FOCUS=boss` follows a bot and the FAIR run's camera leaves the kickoff at frame 6, while frame 8 is the earliest BRUTAL frame with all three bots inside the window; the caption names each. (The first composition of this pair used the FAIR run's later camera, which had wandered to the top wall with no human and no ball in frame — it is replaced by this one.) The FAIR half is labelled as the count the base tree gives at *every* FILL — a claim measured in `after-fill-census.txt`, not asserted from the picture. |
| `cmp_s13_basketball.png` | The same pair on 824, **both halves at frame 0** — the same tick, the same framing. Left: the red human, the orange ball and one green bot. Right: the same tick with three. |
| `cmp_s14_stamp_x4.png` | The build stamps, stacked: `V2.1076 AAEAB2D7` over `V2.1127 121716F8`. This is the provenance pair for the whole set. |

## Animations

| File | What it is |
|---|---|
| `soccer_brutal.gif` | 42 frames of `openglad_demo` on modes/820, seed 1337, `TEAM_SIZE=1 FILL=4 CAPTURE_FOCUS=boss`, 2x nearest, 1.6 MB. Opens on the kickoff banner `TEAMS MATCHED (LIMIT) / SOCCER: FIRST TO 3` with one red fighter and three green bots around the ball, then follows the bot that takes it downfield. |
| `basketball_brutal.gif` | The same recipe on 824, 62 frames, 1.8 MB. `TEAMS MATCHED (LIMIT) / BASKETBALL: FIRST TO 21`, the orange human and three green bots, the jump ball, then a basket. |
| `soccer_brutal_still.png` / `basketball_brutal_still.png` | Frame 10 / frame 20 of those runs at 2x — the single frames the GIFs open on. |

## Text evidence

| File | What it is |
|---|---|
| `after-text-flow.txt` | 224-line `openglad_text` transcript of the host walk, with the stdin ordinals and the menu-depth diagram. The BEFORE file is 445 lines. |
| `after-text-flow.stdin` | The exact stdin that produced it (15 lines). |
| `after-fill-census.txt` | The #305 numbers: 16 protocol runs, the route, the raw `census` lines, and the honest limit carried over from the BEFORE file. |

## Gaps, stated plainly

1. **No BEFORE screenshot for S7 (campaign card) or S8 (briefing).** Base
   `aaeab2d7` has no capture point in the campaign browser, and the level
   intro has none anywhere. Both ship as text panels quoting the exact bytes.
   Producing the S7 image would mean adding a capture point to the read-only
   `og-before` worktree and building `og_test_basecamp` there.
2. **No BEFORE demo GIF.** `OPENGLAD_DEMO_FILL` is new in this PR, and
   `openglad_demo` is not built in the `og-before` worktree (only
   `og_test_matchup` is; the rest would be a fresh link chain). The S13 pairs
   therefore compare FAIR against BRUTAL **on this build**, which is the same
   count the base tree gives at every FILL — measured in
   `after-fill-census.txt`, not inferred.
3. **S10's two halves are different arenas** (300 before, 820 after). The
   base tree has no LINEUP shot on 820. The captions say so.
4. `setup_step_teams_ball` / `setup_match_ball` were captured and then
   dropped: they are the same two screens as `setup_step_teams` /
   `setup_step_match` with only the keyboard highlight moved.
5. **The soccer pair's two banners differ**: the FAIR half reads
   `TEAMS MATCHED`, the BRUTAL half `TEAMS MATCHED (LIMIT)` (both basketball
   halves read `(LIMIT)`). `(LIMIT)` is the pre-existing matcher announce —
   `campaigns/modes/packs/modes.core/lib/mode_match.lua:500-517` fires it when
   the first power solve clamped at either end — and it is not a #305 signal:
   it says the power solve hit a bound, never that the body count was capped.
   The body count that FILL bought is the one the census reports.
6. **`zone_default_modes.png` / `_x4.png` are byte-identical to the wave-3
   preview copies** under `media/wp7-preview/`. That is not a substitution:
   `work/ppm-after/zone_default_modes.ppm` carries this capture session's
   23:21 mtime and `work/shoot_after.log` records its
   `zz_capture_default_zone_across_campaigns` run on the `121716f8` binary. Nothing
   in wave 4 touched Base Camp and the renderer is deterministic, so the same
   screen produced the same bytes.
7. **The SCENARIO screen's empty band** (`scenario_band`, and the right half
   of `cmp_s6_scenario.png`) is where the `SCORE: MAP` row used to be. That
   is the shape SPEC §8 prescribes — `ctf_capture_limit` now has one surface
   — but it is the one place a reviewer's eye will stop, and it is shipped
   deliberately rather than overlooked.
8. **The S11 pair's two pitch previews sit at different pan phases.** The
   VIEW LEVEL band's camera does **not** centre on the staged units: it is a
   deterministic wall-clock ping-pong over `query_timer()`
   (`preview_pan_offset`, `src/interface/ui/picker_team_build.cpp:941`, spent
   at `:1078` as `visuals.topx` and `:1079` as `visuals.topy`), ~55 ms per
   pixel horizontally. That whole region is **byte-identical** between
   `aaeab2d7` and `121716f8` (`diff` over the two files' pan blocks is
   empty), so the phase difference is the wall-clock moment each frame was
   grabbed and nothing else — not the third bot, not a layout change. The
   band's own code comment says the same: "tests assert band content, never
   pan phase." The comparison this pair is for — `(2) FAIR` → `(3) STRONG` —
   is unaffected, and `cmp_s11_census_x4.png` isolates it.
