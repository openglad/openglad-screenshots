# Round-2 media — read-back log (PR #307, `feat/arena-setup` @ `29b59c55`)

Every image and transcript in this directory was produced on **2026-09-20** from
`/home/yans/code/openglad/.claude/worktrees/arena-r2-wp5/build/ci-test`, built from
`29b59c5514f2f558b66f7163a65a9c6dd6e63772` with a clean working tree
(`og_git_hash.h` → `"29b59c55"`, `OPENGLAD_VERSION_STRING "2.1148"`, no `+`).
`r2_cmp_stamp.png` prints both trees' stamps on screen: `V2.1127 121716F8`
(round 1) above `V2.1148 29B59C55` (round 2).

Every capture went through a production seam — `capture_presented_frame()` /
`capture_frame()` into `UXSHOTS_DIR` for the menus, `openglad_text`'s own stdout
for the terminal transcripts. Nothing was drawn, retouched or assembled by hand
except the caption strips and the one strip crop listed under **Compositions**.
Every SDL run used `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy
SDL_RENDER_DRIVER=software`, a scratch `OPENGLAD_CONFIG_DIR`, and was followed
by `git status --porcelain cfg/` (empty every time).

**Update (2026-09-20, after review).** The four-side FILL frames were re-taken
from the worktree at `arena/r2-wp5` commit `a21c4c77` (the build stamps itself
`cf46b31a+`, the commit before the amend; these frames carry no stamp). The
reason: the pair's BEFORE half used to be `setup_step_teams_four_sides`, which
comes from the GO-gate flow's deliberately under-deployed company — DEP 1/2,
ONE fighter, a P2 seat waiting on TEAM 2 — while `_brutal` and `_healed` come
from the FILL flow's two-fighter company. Each frame was right on its own, but
across the pair "one click" silently added a fighter too. The FILL flow now
takes its own BEFORE frames, `_rest` and `_empty`, so the only difference
inside each pair is the click. `_brutal` and `_healed` re-converted
**byte-identical** to the copies taken at `29b59c55`, which is the evidence
that the capture edit changed nothing but the number of frames.

**I read every image in this directory back, at 1x and 4x, before the PR body
was touched.** What follows is what each one actually shows.

The BEFORE half of every pair is round 1's own AFTER set at `121716f8`
(`pr-307/*.png` from commit `9e86f798`), so both halves come from the same
capture seam on the same campaign.

In this repository every file below carries an `r2_` prefix (`zone_default_modes`
is `pr-307/r2_zone_default_modes.png`), so round 1's files at the same names are
untouched and its SHA-pinned links keep resolving.

## Measured geometry (not eyeballed)

Measured on the raw PPMs by locating the `(228,228,228)` bevel-highlight run on
each row:

| Element | Measured span (320×200 frame) | Contract |
|---|---|---|
| Panel frame | `9–310` | one right edge ✓ |
| Tab strip, 5 tabs | `12–64 · 73–125 · 134–186 · 195–247 · 256–308` | 54 wide, gap 7, last tab ends on **310** ✓ |
| Wizard rows | `12–274` → right edge **276** | rows end on 276 ✓ |
| Reverse `<` cells | `280–308` → right edge **310** | cells end on 310 ✓ |
| **The camp's SETUP row** | top bevel at **y=143**, face `12–274` → right edge **276** | the docket grid, unchanged ✓ |
| RULES rows | y=59 and y=71, each with its `<` cell | two rows, the pointer line above them at y=47 ✓ |
| TEAMS rows, four-side arena | SIDES y=91 (`<`), FILL y=103 (`<`), LINEUP y=115 (no cell — it is a door) ✓ |
| GAME rows | first y=47, RANDOM y=131 — eight rows, no pager ✓ |
| ARENA rows | first y=59 (ONE flavour line above them), RANDOM ARENA y=107 ✓ |

**The docket row sits at y=143 on BOTH company sizes** — the 2-hero frame and
the 7-hero frame measure identically. On the 7-hero frame it is directly under
ETA's row; on the 2-hero frame five blank unit slots sit between BETA and it.

**Panel or stray?** It reads as the panel's footer row, not as a stray: it is
inside the panel frame, it wears the same 264-wide bevel the roster rows and
every other docket row wear, and it is the only interactive row in that band.
On the 2-hero frame the gap above it is large but the frame still encloses it.
**Accepted as shipped**; the lever if it is ever judged stray is the roster's
Lua `weight`, not a wider face.

**The mode-token mismatch is visible and is accepted (R2-D4).** The camp row
reads `SETUP - TEAM DEATHMATCH: THE CIRCLE  >` / `SETUP - SOCCER: THE PITCH  >`
— the scenario's own title, the same bytes line B prints two rows above it —
while the GAME step one click away reads `TEAM DEATHMATCH - 6 ARENAS`. Both
spellings are on screen in `r2_cmp_basecamp.png` and `setup_step_game_x4.png`
and they do not clash: the camp row agrees with the line above it.

**No `CLEARED` appears in any round-2 frame.** I checked every one.

## Single screens (1x = 320×200, `_x4` = 1280×800 nearest-neighbour)

| File | What I see in it |
|---|---|
| `zone_default_modes` | Base Camp on `modes`, scen 300, DEP 2/2. The panel's y=33 band is the classic `DEPLOY TEAM NAME CLASS LV EXP` heading — the roster leads. ALPHA and BETA, then blank unit slots, then ONE row at the panel's foot: `SETUP - TEAM DEATHMATCH: THE CIRCLE  >`. No readout, no GAME/ARENA/RANDOM rows. Rail `P1 WASD` + three `ADD PLAYER`. Strip: `BACK · DIFFICULTY · SCENARIO · NETWORK · GO`. |
| `zone_default_modes_full_roster` | The same camp with eight heroes (DEP 8/8, line-B pager `1/2`) on scen 820. Seven roster rows (ALPHA…ETA), the keyboard highlight on ALPHA, and the SETUP row at y=143 reading `SETUP - SOCCER: THE PITCH  >`. The row keeps its place; nothing is clipped or pushed out. |
| `setup_step_game` | `[GAME]` pressed in and bracketed. **No `Cleared:` line.** Seven game rows reading `<GAME> - N ARENAS  >` and, LAST, `RANDOM - ANY GAME, ANY ARENA` (no ` >`, because it acts rather than descends). The keyboard highlight is on SOCCER, the current game. Footer `BACK` and `NEXT`, no PREV. |
| `setup_step_arena` | `[ARENA]`. **One** line, the game's own: `KICK THE BALL INTO THEIR GOAL.` Four green arena rows; `THE PITCH … [CURRENT]` is highlighted; **THE MUDBOWL (821) is a played arena on this company and carries no tail at all.** Last row `RANDOM ARENA - ANY ARENA OF THIS GAME`, grey because it is an action. |
| `setup_step_teams` | Two swatched team lines (`TEAM 1 P1 WASD 2 FIGHTERS`, `TEAM 2 3 BOTS`), the campaign line, then `FILL: STRONG - WEAK TO BRUTAL` with its `<` cell and the LINEUP door. No SIDES row — the arena authors two sides. **The note reads `WEAK TO BRUTAL`**: NONE is off this wheel. |
| `setup_step_teams_four_sides` | The GO-gate flow's 822, DEP **1/2**, ONE fighter: four swatched lines, TEAM 2 dimmed `NEEDS 1 FIGHTER`, TEAM 3 and 4 `2 BOTS`, `SIDES: 4`, `FILL: STRONG - WEAK TO BRUTAL`. A different company from the three below, so it is **not** used as any pair's BEFORE any more; it stays as the GO-gating witness. |
| `setup_step_teams_four_sides_rest` | The FILL flow's 822, DEP **2/2**, `2 FIGHTERS`: `3 BOTS` on TEAM 2, 3 and 4 (a fresh ball arena deals STRONG, and STRONG is one more than the humans), `SIDES: 4`, `FILL: STRONG - WEAK TO BRUTAL`, LINEUP. The highlight is still on the `[TEAMS]` tab — nothing has been clicked on this step yet. |
| `setup_step_teams_four_sides_brutal` | The same company one FILL click later: `FILL: BRUTAL` (highlighted), and **TEAM 2, 3 and 4 all read `4 BOTS`** against the same `2 FIGHTERS`. `SIDES: 4` unchanged, `DEP 2/2` unchanged. Every AI side moved, by one body each. This is the reported bug, closed. |
| `setup_step_teams_four_sides_empty` | The trap itself, same company: every band wheeled to NONE on the LINEUP page. `SIDES: 1`, `FILL: NONE - WEAK TO BRUTAL`, and `NO FIGHTERS` on TEAM 2, 3 and 4. (The first take of this frame showed the stale BRUTAL census under `FILL: NONE`; the capture now waits for the queued restage, and this one is settled.) |
| `setup_step_teams_four_sides_healed` | One FILL click out of that collapse: `SIDES: 4`, `FILL: WEAK`, and `2 BOTS` on all three AI sides — not one side, and not a collapse to SIDES 2. |
| `setup_step_rules` | `[RULES]`. The pointer line `RESPAWNS AND THE REST: THE BASE CAMP DIFFICULTY.` (48 glyphs, last glyph inside the panel's 310 edge), then exactly two cycler rows, `SCORE: MAP - MAP, 1, 3, 5, 10` and `TIME LIMIT: MAP - MAP, 5 TO 20 MIN`, each with its `<` cell. Nothing else on the step. |
| `setup_step_match` | `[MATCH]`. `SOCCER: THE PITCH`; two swatched census rows; and **all four rules lines survive** — `SCORE`/`TIME LIMIT`, `RESPAWNS`/`SPAWN DELAY`, `PERMADEATH`/`GENERATORS`, `DIFFICULTY`/`INFINITE GOLD`. The recap still states the whole match (R2-3). Then `VIEW LEVEL …  >` and a green `GO`. |
| `setup_go_gated` | The MATCH step on 822, DEP 1/2: `SOCCER: FOURSQUARE`, **four** swatched census rows (`MATCHED BOTS (2) STRONG` on green, blue and yellow), all four rules lines, and `GO - DEPLOY FOR EVERY PLAYER` on the dimmed face. The gating is unchanged by round 2, and this frame is a second witness that the MATCH recap kept every rule line. |
| `setup_joiner_rules` | Line B `JOINED: 2 PLAYERS / 2 MACHINES`. `[RULES]` with **zero rows** (measured: no row bevel anywhere in the panel): the caption `THE HOST SETS THESE FOR EVERYONE.` and ONE packed line, `SCORE: MAP  TIME LIMIT: MAP`. The CROSS CONTROL row is gone — its read-only home is the strip's DIFFICULTY door. |
| `setup_arena_paged` | scen 508, the CTF page's **window 2/2**: pagers `< >` at the first row's right, `2/2` under them, `CENTWHEIT MANOR … [CURRENT]`, `CROSSFIRE`, and `RANDOM ARENA - ANY ARENA OF THIS GAME` last. This is R2-R4 photographed: with eleven rows at eight per window the roll row lands on the second page. |
| `progress_modes` | SCENARIO → PROGRESS on the modes company: header `ARENAS: 3`, rows `300 -------`, `820 CURRENT`, `821 -------`, and a **`GO` button on every row**. 821 is a played arena and reads `-------`, not CLEARED. The `3` is the ACCESSIBLE set, the screen's own pre-existing listing rule (see the PR body). |
| `progress_gladiator` | The same screen on `gladiator`, for contrast: `LEVEL PROGRESS: 1 CLEARED OF 3 DISCOVERED`, a green `CLEARED` status on level 1 and its `VISIT` / `REPLAY` pair. Classic campaigns keep every progress word. |
| `campaign_card_modes` | The SET CAMPAIGN browser with MULTIPLAYER ARENAS selected; the card reads `YOUR POWER: 21 / SUGGESTED POWER: 60`, **`40 ARENAS`** (round 1: `0 OUT OF 40 COMPLETED`), `BY OPENGLAD`. |
| `scenario_band` | The SCENARIO subscreen on the modes company: `SET CAMPAIGN  MULTIPLAYER ARENAS`, `SET LEVEL  SCEN 820: SOCCER: THE PITCH`, then `VIEW LEVEL · PROGRESS · LINEUP` and BACK. Unchanged by round 2; the empty band where `SCORE: MAP` used to sit is round 1's. |
| `mainmenu_with_company` | The main menu with the stamp `V2.1148 29B59C55`. Provenance for everything here. |

## Compositions

Caption strips are ImageMagick `label:` bands appended under each frame; the
frames themselves are untouched.

| File | Shape |
|---|---|
| `r2_cmp_basecamp` | round-1 `zone_default_modes_x4` beside round-2's |
| `r2_cmp_strip_x4` | the command strip alone, cropped `320x30+0+172` at 4x, round 1 stacked over round 2 (`SETUP` → `DIFFICULTY`) |
| `r2_cmp_game` | round-1 `setup_step_game_x4` beside round-2's |
| `r2_cmp_arena` | round-1 `setup_step_arena_x4` beside round-2's |
| `r2_cmp_rules` | round-1 `setup_step_rules_x4` (eight rows) beside round-2's (two rows + the pointer line) |
| `r2_cmp_teams_four_sides` | `_rest` beside `_brutal`: ONE company (IRON KETTLE, 822, DEP 2/2, 2 FIGHTERS), ONE click apart. `3 BOTS` × 3 / STRONG → `4 BOTS` × 3 / BRUTAL. Both halves are this tip; the round-1 tree never captured a four-side arena after a FILL click, so the bug's before-state is evidenced by the text census, and this pair shows the fixed behaviour rather than a cross-tree diff. |
| `r2_cmp_teams_trap` | `_empty` beside `_healed`, the same company again: `SIDES: 1` / `FILL: NONE` / `NO FIGHTERS` × 3 → `SIDES: 4` / `FILL: WEAK` / `2 BOTS` × 3, one click. |
| `r2_cmp_campaign_card` | round-1 card beside round-2's |
| `r2_cmp_stamp` | the two main menus stacked, stamps visible |

## Text records (`openglad_text`, stdin piped, fresh `HOME` per run)

| File | Drive | What it proves |
|---|---|---|
| `r2-census-822.txt` (`.stdin`) | `1`, blank, `5`, `7` Camp, `1` SETUP, `5` SOCCER, `3` FOURSQUARE, `2` FILL, `0`,`0`, `12` Lineup, `1`,`3`,`5`,`7`, blank, `7`,`1`,`9` Next: TEAMS, `2` FILL, `0`,`0`, `12`,`12`, `6` GO, `census` | 822 at rest `SIDES: 4 / FILL: STRONG`, `2 BOTS` on teams 2, 3 and 4; one FILL turn → `FILL: BRUTAL`, `3 BOTS` on all three; every band to NONE → `SIDES: 1 / FILL: NONE`, `NO FIGHTERS` on all three; ONE more FILL turn → `SIDES: 4 / FILL: WEAK`, `1 BOT` on all three. Every AI side moves together, in both directions. |
| `r2-census-300.txt` (`.stdin`) | the same, on `1` TEAM DEATHMATCH / `1` THE CIRCLE, with two wheel steps per band | 300 at rest `SIDES: 4 / FILL: FAIR`, `1 BOT` ×3; one turn → `FILL: STRONG` on all four bands (TDM buys power, not bodies, so the COUNT stays 1 — the FILL WORD is what moves); all-NONE → `SIDES: 1 / FILL: NONE`; one turn → `SIDES: 4 / FILL: WEAK`, `1 BOT` ×3. |
| `r2-text-camp-setup-random.txt` (`.stdin`) | `1`, blank, `5`, `7` Camp, `1` SETUP, `8` RANDOM, `0`, `1`, `5` SOCCER, `5` RANDOM ARENA, … | the camp's ONE row `1. SETUP - TEAM DEATHMATCH: THE CIRCLE  >`; the GAME step's `8. RANDOM - any game, any arena` answering `Level set to Team Deathmatch: BLOODGLADE.`; the camp row restating the new match; the ARENA page's `5. RANDOM ARENA - any arena of this game` answering `Level set to Soccer: BONEYARD CUP.`; `[CURRENT]` moving with it; and Team Build listing 12 items with no `Setup`. The three `Cannot open level file … scen1.fss` lines at the top are the pre-existing noise a brand-new company makes before its first campaign level is set; they are not round-2 behaviour. |

## What is NOT here, and why

- **No joiner terminal transcript.** `configure_networking` is a stub on the
  text client and the shared `MenuLabelContext` always answers host, so there
  is no joiner surface to drive there. The joiner's read-only wizard is an SDL
  surface: `setup_joiner_rules`.
- **No round-1 four-side-after-FILL frame.** The round-1 tree captured that
  arena only at rest, so the bug's before-state is evidenced by the FB §1.3
  transcript and by the prose, not by a photograph.
- **The screenshots are a TWO-fighter company; the text census is a ONE-human
  one.** Bodies count off the humans (STRONG = humans + 1, BRUTAL = humans +
  2), so the same click reads 3 → 4 BOTS in the frames and 2 → 3 in the
  transcript. The PR body says so where both are quoted.
