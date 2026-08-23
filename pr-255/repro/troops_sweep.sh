#!/usr/bin/env bash
# #247 TROOPS sweep: preview census vs launch census, openglad_text, scen 822 seed 1234.
# usage: troops_sweep.sh <path-to-openglad_text> <label> <outdir>
# Each of ALL / OWN / FAIR is run twice: once to the VIEW SCENARIO preview,
# once through GO! to a live 10-tick census.
set -euo pipefail
BIN="$1"; LABEL="$2"; OUT="$3"
mkdir -p "$OUT"

export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software

# key decode: 1=Begin New Game, <blank>=default company name, 5=Ready(->Team Build),
# 10=Scenario, 2=Set Level, 822=level id, 6=TROOPS toggle (ALL->OWN->FAIR),
# 3=View Scenario (+blank for "press enter"), 8=Back, 6=GO!
for state in ALL OWN FAIR; do
  case "$state" in
    ALL)  TOG="" ;;
    OWN)  TOG="6\n" ;;
    FAIR) TOG="6\n6\n" ;;
  esac

  cfg=$(mktemp -d)
  printf "1\n\n5\n10\n2\n822\n${TOG}3\n\n" \
    | OPENGLAD_CONFIG_DIR="$cfg" timeout 120 "$BIN" --campaign modes --level 822 --seed 1234 \
    > "$OUT/${LABEL}_${state}_preview.raw" 2>&1
  rm -rf "$cfg"

  cfg=$(mktemp -d)
  printf "1\n\n5\n10\n2\n822\n${TOG}8\n6\ntick 10\ncensus\nquit\n" \
    | OPENGLAD_CONFIG_DIR="$cfg" timeout 120 "$BIN" --campaign modes --level 822 --seed 1234 \
    > "$OUT/${LABEL}_${state}_launch.raw" 2>&1
  rm -rf "$cfg"
done
