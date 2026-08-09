# Basketball mode PR media manifest

All captures come from `openglad_demo` (build: `cmake --build --preset ci-test --target openglad_demo`)
running headless, fully seeded, one 320x200 session, one indexed BMP per simulation tick.
Common env for every run:
`SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software OPENGLAD_DEMO_GRID=1x1 OPENGLAD_DEMO_CAMPAIGN=modes OPENGLAD_DEMO_TEAM_SIZE=5 OPENGLAD_DEMO_CAPTURE_DIR=<dir> OPENGLAD_CONFIG_DIR=<fresh dir>`
(frame NNNNN below = dump `frameNNNNN.bmp`, i.e. simulation tick NNNNN+1; runs are
deterministic — identical env reproduces identical frames). Post-processing mirrors
`scripts/media/capture_showcase.sh`: 2x nearest-neighbour upscale; stills via
palettegen/paletteuse to pal8 PNG; GIFs via the two-pass palette chain from the raw
BMPs with 0.08 s per tick (game speed, 12.25 ticks/s) and a short hold on the last frame.

All eight rows below were recaptured 2026-08-09 on the PR #190 head. Two sim
changes landed after the original 2026-08-06 captures — Teams: Match bot-squad
fill (`456fafb7`) and the D28 throw-release refund (`4c695a48`) — so the old
frame windows no longer reproduce on this tree; every window was re-located on
the new timeline by the same announce/ball/hoop frame-scan method, never
spliced. The intended visual deltas from the 2026-08-06 artifacts are the
dedicated hoop sprite (D29: orange rim ring + net, team tick marks) wherever a
rim is in frame, and the net-ripple swish frames at made baskets and dunks.

| file | reproduction | caption |
|------|--------------|---------|
| court-824.png | `OPENGLAD_DEMO_SEED=11 OPENGLAD_DEMO_SCENARIOS=824 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2500`, frame 01206 | CENTER COURT's west hoop: the ball hangs at the top of its arc over the key, its ground shadow marking the landing spot at the shooter's feet, the rim sprite — orange ring, red team ticks, net at rest — waiting on its carpet pad below. |
| court-825.png | `OPENGLAD_DEMO_SEED=5 OPENGLAD_DEMO_SCENARIOS=825 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2200`, frame 00600 | THE PLAYGROUND: cramped half-court walls, short arc, and "BASKET! GREEN +2" going up as the shooter holds the key beside the scored-on rim, its net still mid-ripple. |
| court-826.png | `OPENGLAD_DEMO_SEED=7 OPENGLAD_DEMO_SCENARIOS=826 OPENGLAD_DEMO_CAPTURE_FOCUS=center OPENGLAD_DEMO_CAPTURE_LIMIT=2500`, frame 00033 | FOUR HOOPS: the ball waits on the centre circle at the opening tip while all four bands — red, green, blue, yellow — close in under "BASKETBALL! FIRST TO 21". |
| court-827.png | `OPENGLAD_DEMO_SEED=5 OPENGLAD_DEMO_SCENARIOS=827 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2200`, frame 01610 | THE BANKHOUSE: a shot arcs into the west key past the wing pillars that make straight lanes die and banks live, its ground shadow already down beside the rim sprite on the tile where it will drop. |
| court-828.png | `OPENGLAD_DEMO_SEED=5 OPENGLAD_DEMO_SCENARIOS=828 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2200`, frame 00912 | BENCHWARMERS: a green skeleton substitute holds the west key as the net ripples for "BASKET! GREEN +2", the bone-pile bench that raised it visible in the wall above. |
| shot-arc.gif | `OPENGLAD_DEMO_SEED=11 OPENGLAD_DEMO_SCENARIOS=824 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2500`, frames 01178-01234 @ 0.08 s | A full possession on CENTER COURT: the carry rolls into the west key, the shooter lofts the ball — its ground shadow tracking beneath the arc — and it drops through the rim, the net rippling through its swish frames under "BASKET! GREEN +2". |
| dunk-drive.gif | `OPENGLAD_DEMO_SEED=5 OPENGLAD_DEMO_SCENARIOS=828 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2200`, frames 00458-00521 @ 0.08 s | A bench-raised skeleton catches the dropping rebound, carries the ball overhead down the lane past the closing defense, and walks the rim tile: "DUNK! GREEN +2", the net snapping through its ripple. |
| four-hoops.gif | `OPENGLAD_DEMO_SEED=7 OPENGLAD_DEMO_SCENARIOS=826 OPENGLAD_DEMO_CAPTURE_FOCUS=center OPENGLAD_DEMO_CAPTURE_LIMIT=2500`, frames 00030-00106 @ 0.08 s | Four-team chaos on FOUR HOOPS: the jump-ball scramble at centre court, all four squads brawling for the first possession before the break-out. |

Notes: `OPENGLAD_DEMO_TEAM_SIZE=5` fields the red roster (the mode's lazy first-tick
init would otherwise leave team 0 empty for one tick and the spectator client ends the
match). Boss focus follows the strongest green bot, which the mode's AI director keeps
near the play. No made three-pointer occurred in the five recaptured matches either,
so shot-arc.gif again shows a made inside-the-arc jumper (2 points). The ball's
black-cored ground shadow (sprite frame keyed to the ball's height) still shows
whenever the ball is airborne and marks where it will land. The 826 centre-camera
rows show no rim: the four goals sit at the wall carpets of a 656x656 px court,
outside any 320x200 window that holds the centre circle. Determinism: an independent
second run of the 824 recipe reproduced all 2500 frame dumps byte-identical
(diff -rq clean), so every announce lands on the same tick on any rerun.

## Hoop sprite refresh (D29-D32, PR #190)

Captured 2026-08-09 on the PR #190 head — the same tree and timeline as the
rows above (run A is the very run behind court-824.png and shot-arc.gif; run B
differs from the court-826/four-hoops run only in its `boss` camera focus).
Same common env as above; two runs:

- run A: `OPENGLAD_DEMO_SEED=11 OPENGLAD_DEMO_SCENARIOS=824 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2500`
- run B: `OPENGLAD_DEMO_SEED=7 OPENGLAD_DEMO_SCENARIOS=826 OPENGLAD_DEMO_CAPTURE_FOCUS=boss OPENGLAD_DEMO_CAPTURE_LIMIT=2500`

The rim renders basketball-orange (static fire-ramp 232-235); team identity is
the four compass tick marks in the 248-255 remap band. Crops are stated as
`WxH+X+Y` on the native 320x200 dump; stills go through the same
palettegen/paletteuse chain as above.

| file | reproduction | caption |
|------|--------------|---------|
| hoop-idle-824.png | run A, frames 00450 (crop 110x96+10+2) + 01650 (crop 110x96+164+43), 4x, hstack | CENTER COURT's two rims at rest, one crop per goal: red-tick and green-tick rims idle on their carpet pads (one 320x200 window cannot hold both — the hoops sit 608 px apart). |
| hoop-swish-824.png | run A, frame 01213, 2x full frame | "BASKET! GREEN +2" on the board while the scored-on rim's net holds swish frame 2 — stretched deep and narrow, mid-ripple — on the west carpet. |
| hoop-swish-strip-824.png | run A, frames 01208/01210/01212/01213/01214/01215/01217/01219/01221, 44x40 rim crops, 5x | The whole made-basket ripple: net at rest, pushed wide (frame 1), stretched narrow (frame 2), snap-back overshoot (frame 3), settle. |
| hoop-clang-824.png | run A, frame 01155, 2x full frame | A missed shot clangs off the west rim: the ring flashes gold-bright (clang frame 4) as the ball pops away over the key. |
| hoop-clang-strip-824.png | run A, frames 01152/01154/01155/01156/01157/01158/01159/01161/01163, 44x40 rim crops, 5x | Idle rim, four bright gold-flecked clang ticks (frame 4), dim after-flash (frame 5), recovery. |
| hoop-tints-826.png | run B, frames 00892 (crop 100x88+114+29), 00190 (100x88+186+23), 00443 (100x88+179+101), 01180 (100x88+3+29), 4x, 2x2 | FOUR HOOPS, all four goals: red, green, blue and yellow tick tints on live rims (656x656 px court — no single 320x200 frame holds four rims, so one crop per goal). |
| hoop-frames.png | `python3` render of `campaigns/modes/packs/modes.core/sprites/hoop.png`: 6 frames x (neutral + 4 team tints via the walkputbuffer remap p>247 -> teamcolor+(255-p)) over cobble/carpet/hardwood grounds, 4x | Generator-truth sprite sheet: idle, swish 1-3, clang bright/dim, per team tint — the art the engine draws before camera and court get involved. |

Note on D32 item (5), "826 two-team partial spawn": not capturable by
`openglad_demo` — the activation clamp reads the lobby `team_count`
(`og.match_setting`, world `ctf_requested_team_count`), which is save-file
state the demo bootstraps to Auto with no env override, and Auto activates all
four authored anchor teams on shipped 826. The behavior is pinned by unit test
`ModesBasketball.hoop_partial_spawn_two_of_four` (exactly two rims spawn, nil
for both dead goals); `hoop-frames.png` stands in as the fifth visual.
