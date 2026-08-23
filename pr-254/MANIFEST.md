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

## Provenance (all `#232` media, recaptured 2026-08-23)

Every `#232` artifact now comes from ONE pipeline: `repro/media_shots.cpp`, a
throwaway gtest harness that `#include`s `tests/integration/test_game_loop.cpp`
verbatim and runs REAL gameplay (gladiator scen1, level-4 crew) headlessly
under SDL dummy video via `game_frame_with_result(enable_render=false)`, then
renders each frame for capture with the production pair the demo binary never
runs: `s->redraw()` (world, sprites, radar, message feed) followed by
`new_score_panel(s, 1)` (the classic HUD, including the branch's TIME LEFT
cell). Frames dump as 320x200 P6 PPM through `gameplay_rec::dump_screen`.

The identical harness ran on the branch tip and on a master worktree at the
merge base `18adcafd`, same seed, same tick count (174), so every A/B is
like-for-like. The freeze is staged at tick 10 (`enemy_freeze = 150` on the
authoritative server world and the display mirror — the same two writes a real
FREEZE TIME cast performs); two genuine feed messages are injected at ticks 55
and 105 on both sides. The master strips incidentally catch issue #231 live:
"THE WAY IS CLEAR -- YOU MAY EXIT" fires mid-freeze with FOES: 12 on screen;
the branch strips show no such prompt.

A previous capture set rendered the score panel over a cleared buffer in
`PREF_VIEW_PANELS` — a 100px-column layout no shipping code path can select
(`PREF_VIEW` is only ever `PREF_VIEW_FULL`; the classic HUD needs >=121px). Its
narrow-column overlap was real geometry of that unreachable layout, not a
branch defect, and the capture was withdrawn. The real 3- and 4-way splits are
overlap-free, as the recaptured split-screen stills show.

## Files

### `#232` — the countdown moves from the message feed to the HUD

| file | shows |
|---|---|
| `232-timeleft-master-vs-branch.gif` | THE A/B: same seeded run, stacked. Master: countdown rides the feed, plus the #231 false way-clear prompt. Branch: feed carries only real messages; TIME LEFT counts in place on the HUD. |
| `232-timeleft-hud-branch.gif` | branch solo run, full frame — the cell counting down in place during live gameplay. |
| `232-timeleft-feed-jitter-master.gif` | master feed close-up — the countdown line hops rows and re-centers as digits drop. |
| `232-feed-master-row-hop.png` | three labelled master feed strips (ticks 20/60/148) — the hop in stills. |
| `232-feed-tick100-master-vs-branch.png` | the same tick on both builds, full frames, stacked. |
| `232-timeleft-hud-cell-branch.png` | branch still: world + radar + feed + the HUD cell, one frame. |
| `232-timeleft-hud-cell-counts-in-place.png` | HUD-cell crops at ticks 20/60/110/155/168 — same x/y, only digits change, gone at 0. |
| `232-timeleft-hud-cell-real-3way-branch.png` | REAL 3-player split (PREF_VIEW_FULL), distinct heroes (SOLDIER/ELF/MAGE), per-pane cells, no overlap. |
| `232-timeleft-hud-cell-quadrants-branch.png` | real 4-player quadrants (adds ARCHER), per-pane cells. |

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

| file | role |
|---|---|
| `media_shots.cpp` | the one `#232` harness (see Provenance). Build: compile with `test_game_loop.cpp`'s flags from `build/ci-test/compile_commands.json`, link `integration_main.cpp.o` + the `og_test_game_core` link line with the harness object placed BEFORE the archives. Run per case: `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software OG_FX_CAPTURE_DIR=<dir> ./og_media_shots --gtest_filter='MediaShots.<case>'` from `build/ci-test` (staged assets live beside the binary). Cases: `solo_run` (174 frames), `three_way`, `four_way`. |
| `potionlab-potion.lua`, `freezeshow-freeze.lua` | the earlier demo-based staging scripts; `potionlab` remains the `#230` captures' provenance. |

GIF/still assembly: ffmpeg palettegen/paletteuse, 2x nearest-neighbour, every
2nd frame at 12 fps; labels live in a padded band ABOVE the frame so they can
never cover game UI.

## Repo state

Captured at branch `feature/notification-feedback` and master-worktree
`18adcafd` with clean trees; `cfg/` untouched; nothing committed to the main
repo — finished artifacts go to `openglad/openglad-screenshots` `pr-254/`.
