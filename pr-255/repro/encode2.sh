#!/usr/bin/env bash
set -euo pipefail
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
RAW=$BASE/raw
WORK=$(mktemp -d); trap 'rm -rf -- "$WORK"' EXIT
FFMPEG=(ffmpeg -hide_banner -loglevel error -y)

emit() { local list=$1 dir=$2 dur=$3 first=$4 last=$5 step=$6 i
    for ((i = first; i <= last; i += step)); do
        printf "file '%s/%05d.ppm'\nduration %s\n" "$dir" "$i" "$dur" >> "$list"; done; }
hold() { printf "file '%s/%05d.ppm'\nduration %s\n" "$2" "$3" "$4" >> "$1"; }
encode_gif() { local list=$1 out=$2 final=$3 palette="$WORK/p.png"
    "${FFMPEG[@]}" -f concat -safe 0 -i "$list" -vf 'scale=iw*2:ih*2:flags=neighbor,palettegen' "$palette"
    "${FFMPEG[@]}" -f concat -safe 0 -i "$list" -i "$palette" \
      -lavfi '[0:v]scale=iw*2:ih*2:flags=neighbor[x];[x][1:v]paletteuse=dither=none' -final_delay "$final" "$out"
    rm -f -- "$palette"; }
still2x() { "${FFMPEG[@]}" -i "$1" \
    -vf 'scale=iw*2:ih*2:flags=neighbor,split[a][b];[a]palettegen=reserve_transparent=0[p];[b][p]paletteuse=dither=none' \
    -frames:v 1 -update 1 -compression_level 9 "$2"; }

# 1. The knob run's last two minutes of match, ending ON the announcement.
list=$WORK/a.ffconcat; : > "$list"
emit "$list" "$RAW/tl720" 0.10 601 717 2
hold "$list" "$RAW/tl720" 719 0.20
hold "$list" "$RAW/tl720" 720 3.0
encode_gif "$list" "$BASE/timelimit-720-wins-banner.gif" 300

# 2. Control: identical match, knob unset (map's own 10800), same window and
#    on past the knob tick.
list=$WORK/b.ffconcat; : > "$list"
emit "$list" "$RAW/tlmap" 0.10 601 717 2
hold "$list" "$RAW/tlmap" 720 1.0
emit "$list" "$RAW/tlmap" 0.10 722 898 4
hold "$list" "$RAW/tlmap" 900 2.0
encode_gif "$list" "$BASE/timelimit-mapdefault-control.gif" 200

still2x "$RAW/tl720/00720.ppm" "$BASE/still-720-wins-banner.png"
still2x "$RAW/tl720/00719.ppm" "$BASE/still-720-tick719-last-playing-frame.png"
still2x "$RAW/tlmap/00720.ppm" "$BASE/still-mapdefault-tick720-still-playing.png"
still2x "$RAW/tlmap/00900.ppm" "$BASE/still-mapdefault-tick900-still-playing.png"
ls -l "$BASE"/timelimit-720-wins-banner.gif "$BASE"/timelimit-mapdefault-control.gif "$BASE"/still-720-*.png "$BASE"/still-mapdefault-*.png
