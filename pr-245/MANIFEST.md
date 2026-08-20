# PR #245 proof media — `Ball-mode playtest batch` (#218 #219 #220 #221 #225 #233 #235 #244)

Main repo: `openglad/openglad`, branch `fix/ballmode-playtest-batch` @ **6f16ed71**.
"Before" frames come from a `git worktree` at **master 9dac53d6** (the merge base —
every fix in this batch lands on the branch, so master is the single honest "before").

Common prelude for every capture:

```bash
nix develop
cmake --preset ci-test && cmake --build --preset ci-test
export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
export OPENGLAD_CONFIG_DIR=$(mktemp -d)   # fresh per run: the cfg-clobber hazard
```

All captures write to the gitignored `build/media/pr-245/`; only the finished
artifacts below are committed here.

---

## Files

| File | Issue | What it shows | Reproduction |
|---|---|---|---|
| `218_staged_preview_still.png` | #218 (feature) | VIEW LEVEL on `SCEN 820: SOCCER: THE PITCH`. The new preview band renders the **staged** world (the exact world GO adopts) above the census: `MATCH: SOCCER - 2 TEAMS ACTIVE`, `RED TEAM ACTIVE - COMPANY (2)`, `GREEN TEAM ACTIVE - BOT SQUAD (5)`, then the per-team rows. | `UXSHOTS_DIR=build/media/pr-245/raw ./build/ci-test/og_test_basecamp --gtest_filter='UxShots.n_view_level_staged'` then `ffmpeg -i raw/view_level_staged.ppm -vf 'scale=iw*3:ih*3:flags=neighbor' 218_staged_preview_still.png` |
| `218_restage_film.gif` | #218 (feature) | 23 presented frames of the live VIEW LEVEL pane on `SCEN 500: CTF: FIRST BLOOD`. The camera slow-pans the staged pitch; mid-film a TROOPS flip lands **one debounced restage** and the census rebuilds from `BOT SQUAD (5)` to `MATCHED BOTS (2)` — restage, not re-init. | `OG_DUMP_DIR=build/media/pr-245/raw/restage_film ./build/ci-test/og_test_matchup --gtest_filter='CtfUi.view_scenario_staged_pane_shows_the_staged_census'` (every 3rd presented frame lands as PPM), then frames 058–080 through the ffmpeg palettegen/paletteuse chain at 2x nearest, 6 fps. |
| `218_restage_pair.png` | #218 (feature) | The two ends of that film side by side: before the flip (`GREEN TEAM ACTIVE - BOT SQUAD (5)`, 2 census pages) and after one debounced restage (`GREEN TEAM ACTIVE - MATCHED BOTS (2)`, 1 page). | Frames `058.ppm` / `080.ppm` from the run above, 2x nearest, labelled with ImageMagick. |
| `218_foursquare_census_text.png` | **#218 (the bug)** | The headline before/after. `openglad_text` VIEW SCENARIO on `SCEN 822: Soccer: FOURSQUARE` at `TROOPS: FAIR`. **master** prints a start-marker guess (`MATCH: 4 AUTHORED TEAMS` / `MARKERS: 12`) with no squads at all; **6f16ed71** prints the real staged match — `MATCH: SOCCER - 4 TEAMS ACTIVE`, RED = `COMPANY (1)`, GREEN/BLUE/YELLOW = `MATCHED BOTS (1)`, each with its actual seeded fighter. FAIR no longer discards the team count. | `printf '1\n\n5\n10\n2\n822\n6\n6\n3\n\n' \| ./build/ci-test/openglad_text --campaign modes --level 822 --seed 1234` — run once in the branch tree and once in a `git worktree` at master; the two transcripts rendered side by side. |
| `225_pads_in_preview.png` | #225 | The staged preview band of `SCEN 820` at tick 0, 3x: two drumstick item pads sitting mid-pitch. Soccer had no pads at all before this batch. | Crop `303x76+8+16` of `raw/view_level_staged.ppm` (same run as `218_staged_preview_still.png`). |
| `225_item_pads_pair.png` | #225 | Same fixed camera, same seed, same frame index, master vs branch: bare midfield before, food + potion pickups on the pads after. | `OPENGLAD_DEMO_GRID=1x1 OPENGLAD_DEMO_SEED=7 OPENGLAD_DEMO_CAMPAIGN=modes OPENGLAD_DEMO_SCENARIOS=820 OPENGLAD_DEMO_TEAM_SIZE=5 OPENGLAD_DEMO_CAPTURE_FOCUS=center OPENGLAD_DEMO_CAPTURE_EVERY=4 OPENGLAD_DEMO_CAPTURE_LIMIT=400 OPENGLAD_DEMO_MAX_FRAMES=1600 OPENGLAD_DEMO_LOCKSTEP=1 OPENGLAD_DEMO_CAPTURE_DIR=<dir> ./build/ci-test/openglad_demo` in both trees; crop `130x46+72+34` of `frame00005.bmp`, 6x nearest. `CAPTURE_FOCUS=center` pins the camera at map centre, so the two crops are the same world rectangle. |
| `235_varied_squads.png` | #235 (bonus) | Two independent runs of the identical uxshot flow — same level, same company, same code — field different opposing squads (`1x ARCHER Lv 2` vs `1x MAGE Lv 2`). The squad is drawn from the per-match latched seed. | Two runs of the `UxShots.n_view_level_staged` command above; census region (`crop=320:90:0:90`) of each, 3x nearest. |
| `220_244_zoom_split.png` | #220 / #244 (**context only**) | The composed two-pane per-view zoom capture the two fixes operate on: left pane at GAME zoom, right pane at 0.7x, composed exactly as `save_screenshot` composes. **It does not show HP bars or the ball beacon** — see the skip note below. | `PAUSE_SHOTS_DIR=build/media/pr-245/raw ./build/ci-test/og_test_view --gtest_filter='PerViewZoomCapture.*'`, then 2x nearest. |

---

## Determinism note

`diff -rq` of an independent rerun does **not** reproduce the staged-preview
stills byte-for-byte, and that is by design, not flake:

* the preview camera is a wall-clock slow-pan (`SDL_GetTicks` tri-wave), so the
  band content shifts between runs — 17745 of 64000 pixels differ, almost all
  inside the band rows y16..91;
* the bot squad is drawn from the per-match latched seed, so the census's
  opposing-squad row differs between runs (that difference is exactly
  `235_varied_squads.png`).

Everything else is stable: outside the band and outside the squad row, the two
runs agree pixel-for-pixel (panel frame, headings, team-fill lines, pager,
buttons). The demo captures (`225_item_pads_pair.png`) **are** byte-deterministic
for a fixed env line — that is the `openglad_demo` contract.

---

## Skipped captures, and why

* **#219 — closed-goal announcement.** Unreachable with existing tooling. The
  announcement fires when the ball enters an authored goal belonging to an
  *inactive* team, which needs fewer active teams than authored goals.
  `openglad_demo` has no match-knob env (`init_session_game` writes a fresh
  default save0 and sets only `numplayers`/`scen_num`/`current_campaign`), so it
  always runs at `TEAMS: Auto`; Auto resolves to the authored count. I verified
  every ball level's staged team count — 820/821/823/824/825 author 2 teams and
  822 (FOURSQUARE) authors 4, and in each case Auto activates every authored
  goal. The plan's fallback was a new `zz_capture_*` scene in `og_test_game_core`
  that sets `save_data.ctf_team_count` before `glad_init()`; that is a test
  change, out of scope for this capture pass. Behaviour is covered by
  `tests/unit/test_modes_soccer.cpp`.
* **#220 / #244 — zoomed beacon and HP-bar height.** No existing capture seam
  renders HP bars or a mode beacon into a *presented* zoomed frame.
  `openglad_demo` can never produce one: it pins the world canvas classic
  (`demo.cpp` `set_world_canvas_pinned_classic(true)`, which forces
  `n_view = n_min` in `viewscreen::resize`) and overwrites `graphics/zoom` to
  `1.0`. The only zoomed presented-composition seam is
  `PerViewZoomCapture.composed_capture_presents_windows_on_slots`, which draws a
  synthetic checker world with no HUD — captured above as context. The plan's
  recipe was to *extend* that test with damaged fighters, a beacon,
  `view_zoom_step_ = 5` and `new_score_panel`; that is a test change, out of
  scope. Both fixes are pinned by exact pixel assertions:
  `GameLoop.zoom_half_mini_hp_bar_height_matches_pane_ratio`,
  `RenderEffects.mini_health_bar_height_matches_classic_at_zoom_one` (#244) and
  `PerViewZoomHud.beacon_pulse_tracks_ball_at_zoom_step_5` (#220).
* **#221 — AI corpse persistence.** No usable frame found. `openglad_demo` is a
  spectator with no way to steer the camera to a death site (`center` pins the
  map centre, `boss` follows one fighter) and no match knobs, and the corpse is
  only visible between a bot's death and its respawn firing. I ran master and
  branch at matched seeds under both focus modes (4 runs, ~1000 ticks each) and
  scanned every frame for blood-ramp pixels and for temporary static blobs; the
  only temporary blobs isolated were goal-announcement text, not corpses. The
  plan's fallback was a `gameplay_rec` scene with an explicit `FAMILY_CLERIC`
  roster — again a test change, out of scope. Behaviour is covered by the tests
  landed with commits `b8610ea3` / `2649a23f`.
* **Host/joiner same-generation pixel-diff pair.** There is no SDL flow that
  drives a host picker and a joiner picker to VIEW LEVEL in one process, so
  there are no two stills to diff. The stronger claim is already asserted
  directly in `tests/integration/test_picker_network_client.cpp`, which pins
  that host and joiner `staged_keyframe_bytes()` return the **same bytes** for a
  generation — byte-equality, not RMSE.

## Finding turned up while capturing (not a media issue)

`openglad_text`'s launch ignores the TROOPS knob. With `TROOPS: FAIR` set and
still displayed after the launch returns, the launched world on `SCEN 822`
fields `team_counts [1,5,5,5]` — legacy 5-bot squads — while the client's own
VIEW SCENARIO preview for the same save and seed promises `MATCHED BOTS (1)` per
team. `TROOPS: ALL` and `TROOPS: OWN` give the identical `[1,5,5,5]`, and master
behaves the same way, so this is pre-existing rather than a regression in this
batch. It does mean the text client's "preview == launch" property does not hold
for that knob.

```bash
printf '1\n\n5\n10\n2\n822\n6\n6\n8\n6\ntick 10\ncensus\nquit\n' \
  | ./build/ci-test/openglad_text --campaign modes --level 822 --seed 1234
```
