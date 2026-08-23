#!/usr/bin/env bash
set -euo pipefail
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
FONT=/nix/store/37c8di1dc9zp4xfb1pzqdg1gbpbkniw5-dejavu-fonts-2.37/share/fonts/truetype/DejaVuSans-Bold.ttf
FONTR=/nix/store/37c8di1dc9zp4xfb1pzqdg1gbpbkniw5-dejavu-fonts-2.37/share/fonts/truetype/DejaVuSans.ttf
W=640
label() { # label <in.png> <line1> <line2> <out.png>
  magick "$1" -background '#111111' -fill '#f2f2f2' -font "$FONT" -pointsize 20 \
    label:"$2" +swap -gravity center -append \
    -background '#111111' -fill '#bdbdbd' -font "$FONTR" -pointsize 16 \
    label:"$3" -append "$4"
}
label "$BASE/still-720-wins-banner.png" \
  "TIME LIMIT = 720 ticks (1 minute: the clamp floor)" \
  "tick 720: BLUE TEAM WINS! - the match ends on the knob's tick" \
  "$BASE/tmp_left.png"
label "$BASE/still-mapdefault-tick720-still-playing.png" \
  "TIME LIMIT = MAP (soccer 822 authors 10800 ticks)" \
  "tick 720: same match, still being played" \
  "$BASE/tmp_right.png"
magick "$BASE/tmp_left.png" "$BASE/tmp_right.png" +append -background '#111111' \
  -bordercolor '#111111' -border 12 "$BASE/tmp_pair.png"
magick -background '#111111' -fill '#f2f2f2' -font "$FONT" -pointsize 22 \
  label:"Match TIME LIMIT knob (#241): soccer 822, same save, same roster" \
  -gravity center -extent "$(magick identify -format '%w' "$BASE/tmp_pair.png")x44" \
  "$BASE/tmp_head.png"
magick -background '#111111' -fill '#9e9e9e' -font "$FONTR" -pointsize 15 \
  label:"Both runs are byte-identical frame for frame through tick 719; they first differ at tick 720. There is no on-screen countdown - by design." \
  -gravity center -extent "$(magick identify -format '%w' "$BASE/tmp_pair.png")x34" \
  "$BASE/tmp_foot.png"
magick "$BASE/tmp_head.png" "$BASE/tmp_pair.png" "$BASE/tmp_foot.png" -append \
  "$BASE/compare-720-vs-map-tick720.png"
rm -f "$BASE"/tmp_left.png "$BASE"/tmp_right.png "$BASE"/tmp_pair.png "$BASE"/tmp_head.png "$BASE"/tmp_foot.png
magick identify "$BASE/compare-720-vs-map-tick720.png"
