#!/usr/bin/env bash
# usage: run_demo.sh <tag> <scen> <timelimit|0> <every> <start> <maxframes> [extra env...]
set -u
tag=$1; scen=$2; tl=$3; every=$4; start=$5; maxf=$6; shift 6
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
OUT=$BASE/raw/$tag
rm -rf "$OUT"; mkdir -p "$OUT"
export SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
export OPENGLAD_CONFIG_DIR=$(mktemp -d)
cd /home/yans/code/openglad
tlenv=(OPENGLAD_DEMO_MATCH_TIME_LIMIT="$tl")
if [ "$tl" = "unset" ]; then tlenv=(); fi
env OPENGLAD_DEMO_GRID=1x1 OPENGLAD_DEMO_SEED=7 OPENGLAD_DEMO_CAMPAIGN=modes \
    OPENGLAD_DEMO_SCENARIOS="$scen" OPENGLAD_DEMO_LOCKSTEP=1 \
    "${tlenv[@]}" \
    OPENGLAD_DEMO_CAPTURE_DIR="$OUT" OPENGLAD_DEMO_CAPTURE_FOCUS=center \
    OPENGLAD_DEMO_CAPTURE_EVERY="$every" OPENGLAD_DEMO_CAPTURE_START="$start" \
    OPENGLAD_DEMO_MAX_FRAMES="$maxf" "$@" \
    timeout -s KILL 240 ./build/ci-test/openglad_demo > "$BASE/raw/$tag.log" 2>&1
echo "exit=$?  frames=$(ls "$OUT" | wc -l)"
