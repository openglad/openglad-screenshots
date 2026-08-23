# PR #255 proof media — `Match knobs govern every launch` (#241 #247)

Main repo: `openglad/openglad`, branch `feature/match-knobs-timelimit` @ **d467acad**.
Merge base / "before" build: master **25113b61**, from a `git worktree` detached at
that commit with its own build dir (`build/mb-test/`). Every master-side column in
the pairs below came from that binary, not from a remembered baseline.

Per-set build SHAs (they differ because the branch tip moved mid-capture; the
later commit is a capture-flow *test* change only):

| Set | What | Built at |
|---|---|---|
| **A** — SDL/Lua camp-page stills + GIF | `og_test_matchup`, `og_test_basecamp` | **d467acad** (branch tip) |
| **B** — `openglad_text` transcripts and their rendered panels | `openglad_text` (branch) / `openglad_text` (master worktree) | **eccb04ea** / **25113b61** |
| **C** — rendered match-end frames | `openglad_demo` + the `repro/` harness | **eccb04ea**, all three demo runs **re-verified at d467acad** (identical results) |

Common prelude for every capture:

```bash
nix develop
cmake --preset ci-test && cmake --build --preset ci-test
export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
export OPENGLAD_CONFIG_DIR=$(mktemp -d)   # fresh per run: the cfg-clobber hazard
```

All captures wrote to the gitignored `build/media/pr-match-knobs/`; nothing tracked
was modified and no `save/` directory was ever created in the repo (every flow
writes its company save into the per-run `OPENGLAD_CONFIG_DIR`). Only the finished
artifacts below are committed here.

---

## Files

### `#241` — the TIME LIMIT knob, on screen

| File | Issue | What it shows | Reproduction |
|---|---|---|---|
| `zone_submenu_match_setup.png` | #241 | 960x600. The Lua MATCH SETUP page at rest with **four** full-width knob rows: `TEAMS: AUTO`, `TARGET SCORE: MAP`, `TROOPS: ALL`, and the new `TIME LIMIT: MAP - MAP, 5, 10, 15, 20M`. No row highlighted — this is the fourth row existing and wearing MAP on a fresh match. | `UXSHOTS_DIR=build/media/pr-match-knobs/setA/raw ./build/ci-test/og_test_matchup --gtest_filter='CampaignZoneUi.zzz_uxr_capture_modes_match_setup_page'`, then `ffmpeg -i raw/zone_submenu_match_setup.ppm -vf 'scale=iw*3:ih*3:flags=neighbor' <out>.png` |
| `uxr_match_setup_time.png` | #241 | 960x600. The knob actually moved: banner line reads **`CLOCK: 5 MINUTES.`**, row 3 boxed yellow reading `TIME LIMIT: 5M - MAP, 5, 10, 15, 20M`. MAP → 5M is 0 → 3600 ticks. | Same run, `raw/uxr_match_setup_time.ppm`. |
| `uxr_match_setup_cycled.png` | #241 (context) | 960x600. The pre-existing TEAMS capture, kept as the before-state: banner `TEAMS: 2.`, row 0 boxed, the TIME LIMIT row still at MAP. | Same run, `raw/uxr_match_setup_cycled.ppm`. |
| `uxr_match_setup_time_cycle.gif` | #241 | 640x400, 24 frames, 6.25 fps, 4.000 s. Frames 1–8 hold the settled page (`TEAMS: 2.`, highlight on row 0, row 3 = `TIME LIMIT: MAP`); around frame 9–12 the banner flips to `CLOCK: 5 MINUTES.`, the highlight jumps to row 3 and the row reads `TIME LIMIT: 5M`; held to frame 24. **Honest limit:** the click both steps the value *and* moves the box, so no frame exists showing row 3 highlighted while still reading MAP — do not caption this as "the row highlighted, then cycled". | `mkdir -p <dir> && OG_DUMP_DIR=<dir> ./build/ci-test/og_test_matchup --gtest_filter='CampaignZoneUi.zzz_uxr_capture_modes_match_setup_page'` (124 frames), cut frames 080–103, ffmpeg palettegen/paletteuse at 2x nearest, 6.25 fps. |
| `scenario_match_band.png` | #241 (a deliberate *absence*) | 960x600. The SDL SCENARIO screen's y=140 match band holding **exactly three** cells on the 30/120/210 grid: `TEAMS: AUTO` \| `TROOPS: ALL` \| `LIMIT: MAP`. There is **no time cell**. The band was deliberately left at three: the grid is geometrically full and the standing "no rule twins" ruling keeps knobs in one home — the clock knob lives on the Lua MATCH SETUP page, which all three clients render. A screenshot cannot prove intent, so that reason is stated here rather than implied. | `UXSHOTS_DIR=<dir> ./build/ci-test/og_test_basecamp --gtest_filter='UxShots.n_view_level_staged'`, `raw/view_level_staged.ppm`, 3x nearest. |

### `#241` — the knob decides the match (text client, in anger)

| File | Issue | What it shows | Reproduction |
|---|---|---|---|
| `241_zero_sentinel_soccer.png` + `.txt` | #241 | 1984x491. Three columns, one per TIME LIMIT face — branch, soccer scen 822, seed 1234, TARGET SCORE raised to 10 so the *clock* decides. 5M: ticks 3598/3599 `game_ended:false`, **3600 true**, `{"tick":3600,"text":"YELLOW TEAM WINS!"}`. 10M: **7200**. MAP: **10800** — which is exactly `[822].time_limit` in `mode_levels.lua`, so MAP resolves to the manifest, not a fourth hard-coded number. | `repro/timeout_run.sh <openglad_text> 822 <presses> <tick_budget> <out.raw>` with presses 1/2/0 and budgets 5000/9000/13000; panels rendered by `repro/render_pngs.sh`, transcripts cut by `repro/make_transcripts.sh`. |
| `241_ctf500_time_limit.png` + `.txt` | #241 | 1488x491. CTF level 500, seed 1234, TARGET SCORE 10 — same match, only the knob differs. `5M`: **the clock cuts it at 3600** (GREEN on 8/10, `GREEN TEAM WINS!`). `MAP`: the cut is **removed** — the identical match runs past 3600 and is decided by **score at 4291**. **Honest limit, stated on the image and in the transcript:** the MAP half proves the 3600 cut was removed, *not* that CTF's 14400 manifest value was reached. CTF's manifest arm is proven by a unit fixture, not by this capture (see "Skipped captures"). | `repro/timeout_run.sh <openglad_text> 500 1 5000 raw/branch_ctf500_time5m.raw` and `... 500 0 6000 raw/branch_ctf500_timemap.raw`. |
| `match_setup_page.png` + `.txt` | #241 | 1136x491. The text client's MATCH SETUP page, master vs branch. Master: three rows, prompt `Camp # [1-3]`. Branch: a fourth row `4. TIME LIMIT: MAP - map, 5, 10, 15, 20m`, prompt widened to `[1-4]`. Both still print the same rules line `Auto sides, map score, all.` — the render does not claim the note text changed. | `printf '1\n\n5\n7\n4\n' \| ./openglad_text --campaign modes --level 822 --seed 1234`, run once per build. |

### `#241` — the knob decides the match (rendered frames)

| File | Issue | What it shows | Reproduction |
|---|---|---|---|
| `timelimit-720-wins-banner.gif` | #241 | 640x400, 61 frames, 9.12 s. The final stretch (ticks 601–720, every 2nd) of a soccer 822 match with the full single-player HUD. **The last frame is tick 720 and carries the in-world `BLUE TEAM WINS!` banner**, held 3 s. `save.time_limit = 720` — the same field MATCH SETUP, the lobby and the demo env all write. There is no countdown clock on screen; none exists. | `OG_TL_DIR=<dir> OG_TL_LIMIT=720 OG_TL_SCEN=822 OG_TL_FROM=600 ./repro/og_timelimit_shot` (built by `repro/build.sh`), then `repro/encode2.sh`. |
| `still-720-wins-banner.png` | #241 | 640x400 pal8. Tick 720 standalone: `BLUE TEAM WINS!` in yellow across the top of the viewport, HUD `TEAM: 3 / FOES: 14`. | `repro/encode2.sh`, from `tl720/00720.ppm`. |
| `still-720-tick719-last-playing-frame.png` | #241 | 640x400 pal8. The same run one tick *before* the buzzer — same scene, no banner. Pairs with the still above to place the announcement exactly on tick 720. | `tl720/00719.ppm`. |
| `still-mapdefault-tick720-still-playing.png` | #241 | 640x400 pal8. **The control** at the same tick index: identical save, roster and scenario at `save.time_limit = 0` (MAP; soccer 822 authors 10800). No banner, `FOES: 13`, `SC: 409` — still being played. The two runs' dumped frames are **byte-identical from tick 601 through 719 and first differ at 720** (md5-verified). | `OG_TL_LIMIT=0` run, `tlmap/00720.ppm`. |
| `still-mapdefault-tick900-still-playing.png` | #241 | 640x400 pal8. The control 180 ticks past the knob's deadline: ball upper-left, fighters spread, `FOES: 15 / SC: 630`. | `tlmap/00900.ppm`. |
| `compare-720-vs-map-tick720.png` | #241 | 1304x547. The two tick-720 stills side by side with captions; footer states the byte-identity through 719 and that there is no on-screen countdown, by design. Only captions and the black backing were added — neither game frame was retouched. | `repro/compose.sh`. |
| `still-3600-score-win-tick2228.png` | #241 (**honest caveat**) | 640x400 pal8. Same harness, same scenario, `save.time_limit = 3600` (the 5M face). The match ended at **tick 2228, before the clock**, by score: `SOLDIER SLAIN / OWN GOAL! BLUE +1 / BLUE TEAM WINS!`. **The knob is a cap on match length, not a fixed length** — a score win still ends the match first. Do not read "5M" as "five-minute matches". | `OG_TL_LIMIT=3600` run of the same harness. |
| `demo-timelimit-720-final-stretch.gif` | #241 | 640x400, 60 frames, 8.42 s. The **shipping-binary** seam: `openglad_demo` + `OPENGLAD_DEMO_MATCH_TIME_LIMIT=720`, soccer 822, seed 7, spectator view (no HUD), ticks 600–719 — ending on the last frame `openglad_demo` ever renders. **This GIF does not contain the winner banner**: the demo is a non-`TESTING` binary and the level-end popup blocks the sim tick before the winning frame can be rendered (see "Skipped captures"). Its evidence is the run boundary — exactly 719 rendered frames, then the log prints `VICTORY!, SOCCER: RED TEAM WINS! / Moving on to 823`. | `repro/run_demo.sh knob720 822 720 1 0 800 OPENGLAD_DEMO_TEAM_SIZE=4`, then `repro/encode.sh`. |
| `demo-still-knob720-tick719.png` | #241 | 640x400 pal8. The demo's last rendered frame of the knob=720 run (`frame00718` = tick 719). Byte-identical (md5) to the control run's frame at the same index, so it doubles as the "same frame index" side of the demo pair. | `repro/encode.sh`, `knob720/frame00718.bmp`. |
| `demo-still-control-tick1200.png` | #241 | 640x400 pal8. Demo control run (`OPENGLAD_DEMO_MATCH_TIME_LIMIT` unset, same seed/scenario/team size) at tick 1200 — 480 ticks past the knob's deadline, match still running. Its log line reads `1200 sim ticks, 1200 rendered frames` with no ending. | `repro/run_demo.sh control 822 unset 1 0 1200 OPENGLAD_DEMO_TEAM_SIZE=4`. |
| `demo-still-knob1440-tick1439.png` | #241 (weak, kept for the count) | 640x400 pal8. `OPENGLAD_DEMO_MATCH_TIME_LIMIT=1440` renders exactly 1439 frames; this is the last of them. The spectator camera happens to sit on an empty stretch of pitch — **its value is the frame count (1439 = knob−1), not the scene.** Lean on the count and the log line, not the picture. | `repro/run_demo.sh knob1440 822 1440 1 0 1600 OPENGLAD_DEMO_TEAM_SIZE=4`. |
| `timelimit-run-evidence.txt` | #241 | The plain-text spine of all of the above: the three `openglad_demo` run tails, the md5 byte-identity results, the three harness stdout lines (`720 → match ended after tick 720`; `0 → ended=0 last_tick=901`; `3600 → match ended after tick 2228`), and the branch SHA the captures ran against. | — |

### `#247` — the text client's GO launches the world its preview promised

| File | Issue | What it shows | Reproduction |
|---|---|---|---|
| `247_preview_vs_launch.png` + `.txt` | **#247 (the bug)** | 1616x1248. Top: two verbatim columns for `TROOPS: FAIR`, scen 822, seed 1234. **Master 25113b61** — preview reads `GREEN/BLUE/YELLOW TEAM ACTIVE - MATCHED BOTS (1)` with `1x MAGE Lv 3` per side, launch census `team_counts [1,5,5,5,0,0,0,0]`. **Branch eccb04ea** — the *identical* preview text, census `[1,1,1,1,0,0,0,0]`. Bottom: the full six-row matrix. ALL and OWN agree on both builds (`BOT SQUAD (5)` → `[1,5,5,5]`); only master's FAIR disagrees. The AGREE column is computed by the render script from the two captured numbers, not typed in. | `repro/troops_sweep.sh <openglad_text> <branch\|master> raw/` in each tree. Single case: `printf '1\n\n5\n10\n2\n822\n6\n6\n8\n6\ntick 10\ncensus\nquit\n' \| ./openglad_text --campaign modes --level 822 --seed 1234`. |

Captured census lines, verbatim, one per file (re-derived per file — see the
process note under Provenance):

```
master_ALL   [1,5,5,5,0,0,0,0]    branch_ALL   [1,5,5,5,0,0,0,0]
master_OWN   [1,5,5,5,0,0,0,0]    branch_OWN   [1,5,5,5,0,0,0,0]
master_FAIR  [1,5,5,5,0,0,0,0]    branch_FAIR  [1,1,1,1,0,0,0,0]   <-- #247
```

### `repro/`

| File | Role |
|---|---|
| `troops_sweep.sh` | the #247 ALL/OWN/FAIR preview-and-launch sweep (each state run twice: once to VIEW SCENARIO, once through GO! to a 10-tick census). Commented with the keystroke decode. |
| `timeout_run.sh` | drive MATCH SETUP to a chosen TIME LIMIT face, launch, and tick until the world reports `game_ended`. Commented with the keystroke decode (`0`=MAP, `1`=5M, `2`=10M, …). |
| `make_transcripts.sh` | cuts the four shipped `.txt` transcripts out of the raw captures, with the exact grep pipeline printed above each block. Nothing is retyped by hand. |
| `render_pngs.sh` | renders the four text-client panels — `magick label:@<file>` over those transcripts, `+append`, caption bars. **No pixel editing anywhere.** |
| `timelimit_shot.cpp` + `build.sh` | the throwaway harness that produced the banner frames. It writes `save.time_limit` directly, calls `glad_init()`, ticks with `game_frame_with_result`, dumps every tick as PPM, and — the point — renders 12 more frames *after* the match ends, which is where the announcement lives. `build.sh` compiles it against the already-built `ci-test` artifacts (`libog_game_test.a` + the existing `integration_main.cpp.o`); it modifies no repo file and adds nothing to CMake. Env: `OG_TL_DIR` (required), `OG_TL_LIMIT`, `OG_TL_SCEN`, `OG_TL_FROM`, `OG_TL_MAX`. |
| `run_demo.sh` | the `openglad_demo` driver (`OPENGLAD_DEMO_MATCH_TIME_LIMIT`, `GRID=1x1`, `SEED=7`, `LOCKSTEP=1`, `CAPTURE_FOCUS=center`). **`OPENGLAD_DEMO_TEAM_SIZE` is mandatory for modes levels** — without it `init_session_game` finds no living non-team-0 walkers at load time (modes field their fighters later, from `on_load`), team 0 is empty, tick 1 reports `YOUR MEN ARE CRUSHED!`, and the run hangs with zero frames. |
| `encode.sh` / `encode2.sh` | GIF and 2x-still encoders for the demo frames (BMP) and the harness frames (PPM) respectively: ffmpeg concat, `scale=iw*2:ih*2:flags=neighbor`, `palettegen`/`paletteuse=dither=none`. |
| `compose.sh` | the side-by-side + caption compositor for `compare-720-vs-map-tick720.png`. |
| `grab_popup.sh` | **the attempt that failed** — run the demo under Xvfb with the real X11 renderer and grab the root window at the blocking match-end popup. `popup_dialog` does call `buffer_to_screen` every 10 ms, but that present is issued from the demo's worker thread and never reaches the display; the grab contains only the pre-win game frame. Kept so nobody retries it. |

---

## Provenance and determinism

**The raws are not shipped.** The 18 unedited `openglad_text` stdout captures and
the three demo/harness frame directories total ~301 MB (the soccer MAP capture
alone is 1.1 MB because `cmd_tick` emits one JSON record per simulated tick with
no cap; the frame dirs are thousands of BMP/PPM). They are fully regenerable from
`repro/` with the commands in the table above. The md5s of the text raws as
captured, for anyone comparing a regeneration:

```
90496f801a790f3b4ad41193a825374c  branch_ALL_launch.raw
96289128d273a9f5cbc472a7f0b5ae26  branch_ALL_preview.raw
9d1f283c67f04c00b88e1093c8ef7ff3  branch_FAIR_launch.raw
304d628e66b03b3f8fab7ccf7ae9b09f  branch_FAIR_preview.raw
3b935fde2437a83d71809e2ad69a59da  branch_OWN_launch.raw
16e32bfbcf8b440661f17f4901162c11  branch_OWN_preview.raw
b3361392838d3e8a225cae4291f3f7e6  branch_ctf500_time5m.raw
37680b5001f589b1a8ed7b2d4b244625  branch_ctf500_timemap.raw
23da9c76c8f283f9f94f18da58527788  branch_matchsetup_page.raw
03dc67f6327c801c96d557e42a9046d1  branch_soccer822_time10m.raw
b443d01ab0c319509d4a40bea0a04557  branch_soccer822_time5m.raw
e132ede17b261c14ecc9110b7fa64883  branch_soccer822_timemap.raw
16ff4fac4d018dffc9c1af5474381c79  master_ALL_launch.raw
be22bd5c7b8788bb6f44809a1ccf7c56  master_ALL_preview.raw
94daa154032ca31eb25e434859e72d60  master_FAIR_launch.raw
c9f9427cb09ad34ffeaa401d8d39bb88  master_FAIR_preview.raw
a6cd6eb1d9bbbe30d59bcd3577292ed1  master_OWN_launch.raw
66a1fd42dc45be998de3a87507bba62a  master_OWN_preview.raw
12dc1add98ec4515e65fae19e4652c42  master_matchsetup_page.raw
```

**Text transcripts: header churn, simulation identity.** Two identical
`openglad_text` invocations do **not** produce byte-identical files, and that is
header churn, not sim nondeterminism. Exactly two things vary: (a) the `mktemp`
config-dir path echoed during campaign restore, and (b) the randomly generated
default company name (`RIVER VIPER GUILD` etc.), seeded off wall clock rather than
off `--seed`. The **tick block is byte-identical across reruns** — md5 of
`grep -o '{"tick":[0-9]*,"level_done":[^}]*}' <raw>`:

```
branch_soccer822_time5m    cf61c342b745e16ca1489905429f55b8
branch_soccer822_time10m   2176a545f0607f316a0046cfb81ca01e
branch_soccer822_timemap   ecab8733b59b1b341a2eed93cd6905be
branch_ctf500_time5m       2fa3c5061900829e8150d5be98d7d6be
branch_ctf500_timemap      91f61078f2a39ac6004b48af24858379
```

**UXSHOTS stills are not byte-reproducible.** The VIEW LEVEL preview is a
wall-clock slow-pan (`SDL_GetTicks` tri-wave) on a per-match latched seed, so
`scenario_match_band.png`'s shield/backdrop pixels shift between runs and the
opposing squad is redrawn from the latched seed. The panel frame, headings, knob
rows and band text are stable — which is all any caption above relies on.

**The demo and harness frames ARE byte-deterministic** for a fixed env line (the
`openglad_demo` contract), which is what makes the md5 byte-identity claims
above — knob run vs control, frame for frame up to the ending tick — meaningful.

**The harness matches and the demo matches are DIFFERENT matches** (different
roster and team composition). Do not describe the two artifact sets as the same
run; within each set the control pairing is exact and md5-verified.

**Process note.** An early attempt to tabulate the six #247 census lines used
`paste <(ls …) <(grep -h … *.raw)`, which mis-paired the rows and produced the
exact *inverse* of the truth. Every row in the matrix is re-derived from its own
file by a per-file loop. Any table built by zipping two independently-globbed
streams should be treated as unverified.

**Integrity check.** `scripts/media/verify_media.py` does not apply here (it
verifies a hardcoded showcase list). Every file above was measured with `ffprobe`
and every image and GIF was read back — GIFs by extracting their frames and
viewing them — before being claimed. Recorded dimensions:

| File | Dimensions | Frames / format |
|---|---|---|
| `241_ctf500_time_limit.png` | 1488x491 | rgb24 |
| `241_zero_sentinel_soccer.png` | 1984x491 | rgb24 |
| `247_preview_vs_launch.png` | 1616x1248 | rgb24 |
| `match_setup_page.png` | 1136x491 | rgb24 |
| `compare-720-vs-map-tick720.png` | 1304x547 | rgb24 |
| `scenario_match_band.png` | 960x600 | rgb24 |
| `uxr_match_setup_cycled.png` | 960x600 | rgb24 |
| `uxr_match_setup_time.png` | 960x600 | rgb24 |
| `zone_submenu_match_setup.png` | 960x600 | rgb24 |
| `demo-still-control-tick1200.png` | 640x400 | pal8 |
| `demo-still-knob1440-tick1439.png` | 640x400 | pal8 |
| `demo-still-knob720-tick719.png` | 640x400 | pal8 |
| `still-3600-score-win-tick2228.png` | 640x400 | pal8 |
| `still-720-tick719-last-playing-frame.png` | 640x400 | pal8 |
| `still-720-wins-banner.png` | 640x400 | pal8 |
| `still-mapdefault-tick720-still-playing.png` | 640x400 | pal8 |
| `still-mapdefault-tick900-still-playing.png` | 640x400 | pal8 |
| `demo-timelimit-720-final-stretch.gif` | 640x400 | 60 frames, 50/7 fps, 8.42 s |
| `timelimit-720-wins-banner.gif` | 640x400 | 61 frames, 50/7 fps, 9.12 s |
| `uxr_match_setup_time_cycle.gif` | 640x400 | 24 frames, 25/4 fps, 4.000 s |

---

## Skipped captures, and why

* **No HUD countdown — by design, not an omission.** There is deliberately no
  on-screen match clock in this PR, so no artifact here shows a timer ticking
  down. (The score panel's `TIME LEFT` cell is the *freeze* counter, #232.) Every
  caption therefore says "the match ends at the knob tick", never "the clock runs
  out". A reviewer expecting a visible timer will not find one.
* **`openglad_demo` structurally cannot film the winner banner.** It is built
  without `-DTESTING` (`openglad_demo` links `og_game`, not `og_game_test`), so
  when a mode declares a winner the client's game-flow dispatch runs
  `screen::endgame → results_screen → show_scripted_mode_ending_popup →
  popup_dialog` — a modal input loop, running inside the worker thread's sim tick
  while the main thread waits on the workers' `done_cv`. Under the dummy driver no
  key ever arrives: the process deadlocks and must be killed (the demo runs exit
  137). The last frame the demo ever renders is the tick *before* the buzzer, so
  the in-world `X TEAM WINS!` notification — dispatched in the same tick, right
  before the popup — never reaches a rendered frame. This is pre-existing demo
  behaviour (any level end hangs it), not a branch defect. The banner frames
  therefore come from `repro/timelimit_shot.cpp`, a throwaway harness linked
  against the already-built `TESTING` engine. It is **not** reproducible from a
  clean checkout without those two scratch files; the natural permanent home would
  be a `zz_capture_*` scene in `tests/integration/test_game_loop.cpp`, which would
  also be a real regression test for the knob. The Xvfb/X11 route to photograph
  the blocking popup was tried and failed (`repro/grab_popup.sh`).
* **CTF's manifest arm is proven by a unit fixture, not by a capture.**
  `241_ctf500_time_limit.png` shows the knob governing CTF's clock (5M cuts at
  3600; MAP removes the cut) — its MAP half is then decided by *score* at 4291 and
  never reaches level 500's authored 14400. Demonstrating the manifest arm visually
  would need a CTF level whose match cannot end on score inside 14400. It is
  instead pinned directly by `ModesCtf.short_manifest_time_limit_is_honored` and
  `ModesCtf.time_limit_knob_overrides_the_manifest_row` in `og_unit_modes`, which
  run against a fixture level authoring `time_limit = 120` (`tests/modes_pack_fixture.h`).
  Note also that the master-side defect is **latent, not observable**: master's
  `mode_ctf_impl.lua:447` compares against the mode's own constant
  `T.time_limit_ticks` (14400) and never consults the manifest row — but every
  shipped CTF level is authored at 14400 too, so the two numbers coincide. It
  becomes observable only once a knob exists. A claim that master "ignored the
  level's limit" with a visible consequence would be overclaiming.
* **No joiner-side per-knob copy-block capture.** Enumeration tests for a joiner
  receiving each knob don't exist for *any* knob (pre-existing class), and there is
  no headless flow that drives a host picker and a joiner picker in one process.
  The knob's wire trip is covered by the lobby/snapshot/replay round-trip tests
  instead.
* **No curses-client page still.** The curses client renders the same Lua MATCH
  SETUP page as the text and SDL clients (that is the point of the single home),
  and the text pair above already shows the page gaining its fourth row. A third
  rendering of the same page would add nothing.

## Repo state

Captured on branch `feature/match-knobs-timelimit` and a master worktree at
`25113b61`, both with clean trees; `cfg/` untouched; nothing committed to the main
repo beyond `d467acad` (the capture-flow test change, which is part of the PR).
`git status --porcelain` empty at finish.
