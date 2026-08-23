#!/usr/bin/env bash
# Run the demo under Xvfb with the real X11 renderer, wait for the match-end
# popup (which blocks the worker thread), and grab the X root window.
set -u
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
tag=${1:-popup}
scen=${2:-822}
tl=${3:-720}
OUT=$BASE/raw/${tag}_frames
rm -rf "$OUT"; mkdir -p "$OUT"
LOG=$BASE/raw/$tag.log
export SDL_AUDIODRIVER=dummy
export OPENGLAD_CONFIG_DIR=$(mktemp -d)
cd /home/yans/code/openglad
env SDL_VIDEODRIVER=x11 OPENGLAD_DEMO_GRID=1x1 OPENGLAD_DEMO_SEED=7 \
    OPENGLAD_DEMO_CAMPAIGN=modes OPENGLAD_DEMO_SCENARIOS="$scen" \
    OPENGLAD_DEMO_LOCKSTEP=1 OPENGLAD_DEMO_TEAM_SIZE=4 \
    OPENGLAD_DEMO_MATCH_TIME_LIMIT="$tl" \
    OPENGLAD_DEMO_CAPTURE_DIR="$OUT" OPENGLAD_DEMO_CAPTURE_FOCUS=center \
    OPENGLAD_DEMO_CAPTURE_EVERY=60 OPENGLAD_DEMO_MAX_FRAMES=2000 \
    ./build/ci-test/openglad_demo > "$LOG" 2>&1 &
pid=$!
for i in $(seq 1 120); do
    if grep -q "TEAM WINS" "$LOG" 2>/dev/null; then break; fi
    if ! kill -0 $pid 2>/dev/null; then echo "demo exited early"; break; fi
    sleep 1
done
sleep 3
magick import -window root "$BASE/raw/${tag}_x11.png"
echo "grabbed rc=$?"
kill -9 $pid 2>/dev/null
wait $pid 2>/dev/null
tail -3 "$LOG"
