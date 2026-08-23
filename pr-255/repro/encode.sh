#!/usr/bin/env bash
set -euo pipefail
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
RAW=$BASE/raw
WORK=$(mktemp -d)
trap 'rm -rf -- "$WORK"' EXIT
FFMPEG=(ffmpeg -hide_banner -loglevel error -y)

emit() { # emit <list> <dir> <dur> <first> <last> <step>
    local list=$1 dir=$2 dur=$3 first=$4 last=$5 step=$6 i
    for ((i = first; i <= last; i += step)); do
        printf "file '%s/frame%05d.bmp'\nduration %s\n" "$dir" "$i" "$dur" >> "$list"
    done
}
hold() { printf "file '%s/frame%05d.bmp'\nduration %s\n" "$2" "$3" "$4" >> "$1"; }

encode_gif() { # <list> <out.gif> <final-delay-cs>
    local list=$1 out=$2 final=$3 palette="$WORK/palette.png"
    "${FFMPEG[@]}" -f concat -safe 0 -i "$list" \
        -vf 'scale=iw*2:ih*2:flags=neighbor,palettegen' "$palette"
    "${FFMPEG[@]}" -f concat -safe 0 -i "$list" -i "$palette" \
        -lavfi '[0:v]scale=iw*2:ih*2:flags=neighbor[x];[x][1:v]paletteuse=dither=none' \
        -final_delay "$final" "$out"
    rm -f -- "$palette"
}
still2x() {
    "${FFMPEG[@]}" -i "$1" \
        -vf 'scale=iw*2:ih*2:flags=neighbor,split[a][b];[a]palettegen=reserve_transparent=0[p];[b][p]paletteuse=dither=none' \
        -frames:v 1 -update 1 -compression_level 9 "$2"
}

# 1. knob=720 final stretch: ticks 600..719 (frames 00599..00718), every 2nd.
list=$WORK/knob.ffconcat; : > "$list"
emit "$list" "$RAW/knob720" 0.10 599 716 2
hold "$list" "$RAW/knob720" 718 2.5
encode_gif "$list" "$BASE/demo-timelimit-720-final-stretch.gif" 250

# 2. control (knob unset): ticks 600..1200, every 10th, same seed/scenario.
list=$WORK/ctrl.ffconcat; : > "$list"
emit "$list" "$RAW/control" 0.10 599 1189 10
hold "$list" "$RAW/control" 1199 2.5
encode_gif "$list" "$BASE/demo-timelimit-unset-control.gif" 250

# 3. Stills.
still2x "$RAW/knob720/frame00718.bmp"  "$BASE/demo-still-knob720-tick719.png"
still2x "$RAW/control/frame01199.bmp"  "$BASE/demo-still-control-tick1200.png"
still2x "$RAW/knob1440/frame01438.bmp" "$BASE/demo-still-knob1440-tick1439.png"
ls -l "$BASE"/*.gif "$BASE"/*.png
