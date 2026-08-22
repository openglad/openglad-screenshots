# PR proof media — `feature/notification-feedback`

Captured 2026-08-22 on branch `feature/notification-feedback` (tip `7d25f972`,
which includes the review fixes `c4302218`, `6e5576dc`, `7d25f972`) against
master `9dac53d6`. Every branch-side binary was rebuilt at that tip before the
final capture. Everything here is a build output under `build/media/`
(gitignored); nothing was committed and nothing tracked was modified. Publish
from here to `openglad/openglad-screenshots` under `pr-N/`.

`scripts/media/verify_media.py` does **not** apply to this directory — it
verifies a hardcoded list of showcase filenames. Integrity was checked with
`ffprobe` instead (dimensions/frame counts recorded below).

---

## What is captured, and what could not be

Two headless renderers exist that can be driven without a display:

| binary | draws the message feed | draws the score panel / HUD |
|---|---|---|
| `openglad_demo` | **yes** (`viewscreen::display_text` runs inside `screen::redraw`) | **no** |
| `openglad_curses` | yes | yes (`TIME n`) — but **unusable**: it aborts unless the terminal speaks the Kitty keyboard protocol, which neither `tmux` nor `script`'s pty provides |

`openglad_demo` renders with `render_session_frame()`
(`src/platform/sdl/demo.cpp:635`), which calls `s.draw_panels()` + `s.redraw()`
and **never** `score_panel()`. `score_panel()` is reached only from
`src/platform/sdl/game_loop.cpp:359,567`, both behind `deps.enable_render`,
which the demo hardcodes to `false` (`demo.cpp:593`) because its worker threads
simulate and the main thread renders. Confirmed empirically: a diagnostic run
with `enemy_freeze` forced to 4000 produced frames with no HUD text of any kind
(no name/HP row either).

**Consequence:** the demo shows only that the countdown *left* the feed. The
`TIME LEFT: N` HUD cell itself is not in any demo frame, and no other shipping
binary can be driven to render it here:

- `openglad` (SDL) has no non-interactive entry point — `main()` goes straight
  to `intro_main`/`picker_main`; there is no autostart flag or env var (the
  full `OPENGLAD_*` env surface is demo/config only). Driving its menus needs
  the `TESTING`-only `interact()` harness, or a real X display; the machine has
  no `$DISPLAY` and no `Xvfb` (adding one would mean editing tracked
  `flake.nix`).
- `openglad_curses` refuses to start without Kitty-protocol keyboard support
  (`src/platform/curses/curses_terminal.cpp:208`, mandatory, no override flag).

So the HUD cell is shot through the **test-side renderer instead**, which is
the same code path CI asserts on and the same one the campaign-scripting media
already uses for menu stills (`UXSHOTS_DIR` in
`scripts/media/capture_campaign_scripting.sh`). `tests/integration/test_glad_hud.cpp`
brings up a live session, points a viewscreen at a real player walker, calls
`new_score_panel(s, 1)` and reads pixels back with its own
`capture_rendered_frame()` helper (`test_glad_hud.cpp:105`). The harness in
`repro/media_hud_shot.cpp` `#include`s that test file verbatim — so the fixture,
the guards and the frame reader are exactly CI's — and adds two cases that dump
the 320x200 framebuffer as PPM (indices widened from the classic 0..63 VGA
palette through `query_palette_reg`). It is a scratchpad file: nothing was added
to `tests/` and `cmake/OpenGladTests.cmake` was not touched. It links against
the already-built `libog_game_test.a` and the stock
`integration_main.cpp.o`, so the rendering code is the branch build, unmodified.

The `#230` split-view evidence is still not renderable — a targeted
notification is filtered per `viewscreen::global_player_index_`
(`src/interface/screen.cpp`), which needs two seats with *different* global
player indices bound; the HUD fixture can raise `numviews` but every pane is
seat 0, and `openglad_demo` hardcodes `numviews = 1` per session
(`demo.cpp:947`) with grid cells that are independent sessions, not seats. It is
instead proved one layer down, at the sim-event boundary, with `openglad_text`.

---

## How the freeze was staged

No stock level can produce an AI-cast FREEZE TIME under `openglad_demo`:

- `openglad_demo` builds its team-0 crew by matching the level's enemy levels
  (`spawn_random_player_team`, `demo.cpp:443`), and a mage's magic points are
  `10 + 3 * intelligence` with `intelligence = 16 * level`
  (`guy::get_mp_bonus`, `packs/core/families/living-03-mage.lua:68`), i.e. 490
  at level 10 against FREEZE TIME's `mp_cost = 500`.
- A scan of every `.fss` in the repo puts the highest authored enemy level at
  **12**, in `campaigns/tryxian/scen/scen114.fss` and `scen115.fss` only; the
  whole gladiator campaign tops out at 10. Runs on tryxian 114/115 with a
  padded roster (`OPENGLAD_DEMO_TEAM_SIZE=120`) produced no cast inside 2000
  ticks, and an A/B needs the freeze on the *same tick* in both builds anyway.

So the freeze is staged by a capture-only level script, `repro/freezeshow-freeze.lua`,
mounted through a throwaway campaign package in a scratch config dir. Its two
lines are exactly what `freeze_time()` in `packs/core/families/living-03-mage.lua`
executes on a player-team cast:

```lua
og.set_enemy_freeze(152)          -- 20 + 11 * 12, one level-12 mage cast
og.set_palette(1)
og.emit_event(C.EVENT_SET_PALETTE, 1)
```

The engine cannot tell the difference: both the master feed push
(`src/gameplay/game_world.cpp`, pre-branch) and the branch HUD cell
(`src/interface/score_panel.cpp:draw_freeze_countdown`) read only
`world.enemy_freeze`. The script also emits two ordinary notifications
("THE GATE GRINDS OPEN", 40 ticks; "REINFORCEMENTS SIGHTED", 90 ticks) as
stand-ins for real gameplay messages, so the countdown line is seen hopping up
a row as they expire.

The campaign package is `build/ci-test/builtin/gladiator.glad` unzipped, with
`packs/freezeshow.lab/scripts/freeze.lua` added and rezipped as
`<scratch>/showcfg-{branch,master}/campaigns/freezeshow.glad`. Campaign packages
are resolved as `get_user_path() + "campaigns/<id>.glad"`
(`src/resources/io/platform_io_common.cpp:296`), so pointing
`OPENGLAD_CONFIG_DIR` at a scratch dir keeps the repo untouched.

---

## Files

### `#232a` — the countdown's new home: the score-panel HUD cell

Rendered by `repro/media_hud_shot.cpp` (see above). Frames are the real
`new_score_panel()` output over a cleared buffer, so they show the HUD overlay
alone — no scenery behind it.

| file | what it shows |
|---|---|
| `232-timeleft-hud-cell-branch.png` | 640x400. Full-screen pane, `enemy_freeze = 152` (one level-12 mage cast). `TIME LEFT: 152` sits left-anchored in the bottom-left column, under the score box's `SPC: CHARGE` row and clear of the feed band, with the classic HUD (name, HP/MP bars, TEAM/FOES) drawn around it. |
| `232-timeleft-hud-cell-2digit-branch.png` | 640x400. The same pane at `enemy_freeze = 88`. |
| `232-timeleft-hud-cell-counts-in-place.png` | 528x392. The bottom-left corner at 152 / 88 / 7 / 0, stacked and labelled. The cell's x and y never move — only the digits change — and at 0 it is gone. This is the exact contrast with the master feed line, which re-centres on every repaint and hops rows. |
| `232-timeleft-hud-cell-narrow-columns-branch.png` | 640x800. The `6e5576dc` placement rules in a 3-way `PREF_VIEW_PANELS` split: at 88 each 100px column shows the short `T: 88` form that clears the radar block; at 300 the short form no longer fits and the cell draws nothing rather than overlap the radar. |
| `232-timeleft-hud-cell-quadrants-branch.png` | 640x400. Four 159x99 quadrant panes at 88 — each pane gets its own cell, clear of its own feed band and radar. |

**Proves:** the countdown is drawn as a fixed HUD cell that updates in place,
and the post-review placement rules (feed-band clamp, radar-column reservation,
short form, give-up) behave as described.
**Caveat:** rendered through the test-side entry point, not through
`game_frame`'s render half — the drawing function, the view geometry and the
frame reader are identical, but there is no gameplay scenery behind the overlay.

### `#232b` — the countdown leaves the message feed

| file | what it shows |
|---|---|
| `232-timeleft-master-vs-branch.gif` | **the headline artifact.** 640x416, 85 frames, 7.1 s. Top strip = master, bottom = branch, same seed, same level, same tick range. Master's feed carries a `TIME LEFT: N` line that repaints every 10 ticks; the branch's feed carries only the two real messages. |
| `232-timeleft-feed-jitter-master.gif` | 640x400, 85 frames, 7.1 s. Master alone, full frame. `TIME LEFT` slides horizontally (the feed centres each line, so 152 → 90 → 20 changes the line width) and hops from row 3 to row 2 to row 1 as the real messages expire above it. |
| `232-timeleft-feed-clean-branch.gif` | 640x400, 85 frames, 7.1 s. Branch alone, identical run: the feed shows the two real messages and nothing else for the whole 152-tick freeze. |
| `232-feed-master-row-hop.png` | 640x336. Master frames at ticks 45 / 100 / 140 stacked: `TIME LEFT: 110` on row 2, then `TIME LEFT: 60` and `TIME LEFT: 20` on row 1, each at a different x. This is the jitter in one still. |
| `232-feed-master-tick100.png` | 640x400. Master, tick 100, full frame. |
| `232-feed-branch-tick100.png` | 640x400. Branch, tick 100, full frame — the same moment with a clean feed. |
| `repro/232-feed-{master,branch}-tick100.bmp` | the raw 320x200 indexed BMPs the game wrote, next to everything derived from them. |

**Proves:** the per-10-tick `TIME LEFT` notification is gone from the feed on
the branch, and shows the churn it used to cause on master.
**Does not prove:** that the branch draws the countdown somewhere else — the
`#232a` stills above cover that.

### `#230` — notifications addressed to one seat

| file | what it shows |
|---|---|
| `230-potion-target-branch-vs-master.png` | 819x267. Rendered side-by-side of the two `openglad_text --protocol` `events` dumps below. |
| `230-potion-events-branch.jsonl` | branch: two potion toasts, `"target": 0` and `"target": 1` — one per drinking seat. |
| `230-potion-events-master.jsonl` | master: the same two toasts with no addressee field at all (every view receives both). |

**Proves:** `og.emit_notification(..., 0, eater)` in
`packs/core/lib/treasure_consumables.lua` now stamps the eater's global player
index onto the event, and it survives to the client boundary.
**Does not prove:** the per-view filtering itself (`screen.cpp:250`) — that needs
a two-viewscreen render, which no headless binary provides. Covered by
`tests/integration/test_view_funcs.cpp` and `tests/unit/test_script_hooks.cpp`.

### `repro/`

| file | purpose |
|---|---|
| `freezeshow-freeze.lua` | the `#232b` staging level script (see above) |
| `potionlab-potion.lua` | the `#230` staging level script: at tick 20 it drops a level-3 `core:speed_potion` on top of every team-0 walker, so the shared potion tail fires immediately |
| `media_hud_shot.cpp` | the `#232a` throwaway harness: includes `tests/integration/test_glad_hud.cpp` verbatim and adds two PPM-dumping cases |
| `encode.sh` | the ffmpeg/magick chain for the `#232b` GIFs and stills |

---

## Exact commands

Build (branch tree, already present):

```bash
cmake --build --preset ci-test --target openglad_demo -j
```

Master comparison build (throwaway worktree, removed afterwards):

```bash
git worktree add <scratch>/master-media master
cd <scratch>/master-media
cmake --preset ci-test
cmake --build --preset ci-test --target openglad_demo -j 8
cmake --build --preset ci-test --target openglad_text -j 8
```

Stage the `#232` campaign package (identically for both sides):

```bash
mkdir -p <scratch>/show/src && cd <scratch>/show/src
unzip -q <build>/ci-test/builtin/gladiator.glad
mkdir -p packs/freezeshow.lab/scripts
cp repro/freezeshow-freeze.lua packs/freezeshow.lab/scripts/freeze.lua
zip -qr <scratch>/showcfg-branch/campaigns/freezeshow.glad .
cp <scratch>/showcfg-branch/campaigns/freezeshow.glad \
   <scratch>/showcfg-master/campaigns/freezeshow.glad
```

Capture (run once per side, swapping `$BIN` and `$CFG`):

```bash
env SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software \
    OPENGLAD_DEMO_GRID=1x1 \
    OPENGLAD_DEMO_SEED=1 \
    OPENGLAD_DEMO_CAMPAIGN=freezeshow \
    OPENGLAD_DEMO_SCENARIOS=1 \
    OPENGLAD_DEMO_TEAM_SIZE=6 \
    OPENGLAD_DEMO_CAPTURE_DIR=<scratch>/show_{branch,master} \
    OPENGLAD_DEMO_CAPTURE_FOCUS=player \
    OPENGLAD_DEMO_CAPTURE_EVERY=1 \
    OPENGLAD_DEMO_CAPTURE_LIMIT=170 \
    OPENGLAD_CONFIG_DIR=<scratch>/showcfg-{branch,master} \
    $BIN
```

Encode: `bash repro/encode.sh <output-dir>` (two-pass `palettegen`/`paletteuse`,
2x nearest-neighbour upscale, every 2nd tick at 12 fps).

`#230` transcripts (once per side):

```bash
printf 'tick 40\nevents\nquit\n' | \
  OPENGLAD_CONFIG_DIR=<scratch>/potcfg $BIN_TEXT \
  --campaign potionlab --level 1 --team 0,0 --protocol
```

`#232a` HUD-cell shots. Build `og_test_view` first so its objects and
`libog_game_test.a` are current, then compile the scratch harness with the same
flags CMake uses for `test_glad_hud.cpp` (lift them out of
`build/ci-test/compile_commands.json`) and link it against the stock
`integration_main.cpp.o` plus the same libraries the `og_test_view` link line
names (`ninja -t commands og_test_view | tail -1`):

```bash
cmake --build --preset ci-test --target og_test_view -j 8

g++ <flags from compile_commands.json for test_glad_hud.cpp> \
    -o <scratch>/media_hud_shot.o -c repro/media_hud_shot.cpp

g++ -g build/ci-test/CMakeFiles/og_test_view.dir/tests/integration/integration_main.cpp.o \
    <scratch>/media_hud_shot.o -o build/ci-test/og_media_hud \
    build/ci-test/libog_game_test.a <libs from the og_test_view link line>

# run from the repo root; the binary must sit in build/ci-test so it finds the
# staged runtime assets (pix/, sound/, packs/, builtin/) beside itself
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software \
  HUD_SHOT_DIR=<scratch>/out ./build/ci-test/og_media_hud \
  --gtest_filter='GladHud.media_*'
```

The PPMs then go through the same `palettegen`/`paletteuse` still chain as
everything else, at 2x (full frames) or 4x (the corner crops) nearest-neighbour.

## Repo state

`cfg/` is clean and was never touched: every run used `OPENGLAD_CONFIG_DIR`
pointed at a scratch directory (the HUD harness picks its own temp user path),
and the demo runs had their cwd outside the repo. The master worktree was
removed with `git worktree remove --force`.

No tracked file was modified. The HUD harness lives in the scratchpad (copied
here as `repro/media_hud_shot.cpp`); `tests/` and `cmake/OpenGladTests.cmake`
were only read. Its binary was written to `build/ci-test/og_media_hud`
(gitignored) because the runtime assets are staged there, and removed afterward.

One note on timing: an earlier pass of this capture ran while a concurrent fix
agent had uncommitted work in this checkout. That work is now committed as
`c4302218`, `6e5576dc` and `7d25f972`, and **every artifact here was recaptured
from binaries rebuilt at `7d25f972`** — the demo frames, the `#230` transcript
and the HUD stills alike. The master side (`9dac53d6`) is unchanged and was
reused from its original build.
