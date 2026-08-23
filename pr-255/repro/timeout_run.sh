#!/usr/bin/env bash
# #241 zero-sentinel proof: drive openglad_text's MATCH SETUP page to a chosen
# TIME LIMIT face, launch the level, and tick until the world reports game_ended.
#
# usage: timeout_run.sh <bin> <level> <time_presses> <tick_budget> <out.raw>
#   time_presses: how many times to press MATCH SETUP row 4
#                 0 = MAP (zero sentinel -> the level manifest's own limit)
#                 1 = 5M (3600) | 2 = 10M (7200) | 3 = 15M | 4 = 20M
#
# key decode: 1=Begin New Game, <blank>=default company name, 5=Ready(->Team Build),
# 7=Camp, 4=MATCH SETUP, 2 x4=TARGET SCORE map->1->3->5->10 (raised so the CLOCK
# decides the match, not the score), 4 xN=TIME LIMIT cycle, 0=back, 0=back,
# 10=Scenario, 2=Set Level, <level>, 8=Back, 6=GO!
set -euo pipefail
BIN="$1"; LEVEL="$2"; TPRESS="$3"; BUDGET="$4"; OUT="$5"

export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software

TIMEKEYS=""
for ((i=0;i<TPRESS;i++)); do TIMEKEYS="${TIMEKEYS}4\n"; done

cfg=$(mktemp -d)
printf "1\n\n5\n7\n4\n2\n2\n2\n2\n${TIMEKEYS}0\n0\n10\n2\n${LEVEL}\n8\n6\ntick ${BUDGET}\nevents\nquit\n" \
  | OPENGLAD_CONFIG_DIR="$cfg" timeout 900 "$BIN" --campaign modes --level "$LEVEL" --seed 1234 \
  > "$OUT" 2>&1
rm -rf "$cfg"
