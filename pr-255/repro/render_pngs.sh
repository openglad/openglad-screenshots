#!/usr/bin/env bash
# Renders the openglad_text transcripts as side-by-side monospace PNGs.
# Nothing here edits pixels: every panel is `magick label:@<file>` over a text
# file that was itself cut out of a raw capture by the pipelines documented in
# the .txt transcripts.
set -euo pipefail
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
R="$BASE/raw"
T="$BASE/raw/panels"
mkdir -p "$T"

FONT=$(fc-match -f '%{file}' 'DejaVu Sans Mono' 2>/dev/null || true)
[ -f "$FONT" ] || FONT=/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf
BG='#14161b'; FG='#e6e8ec'; ACC='#7fd6a0'; BAD='#ff8686'; TTL='#ffd479'
PS=20

panel () { # panel <txtfile> <outpng> [fillcolor]
  magick -background "$BG" -fill "${3:-$FG}" -font "$FONT" -pointsize "$PS" \
         label:@"$1" -bordercolor "$BG" -border 18 "$2"
}
# Renders a title bar at its NATURAL width first; callers then widen every
# column (body and bar alike) to the widest of them, so a long title is never
# cropped.
titlebar () { # titlebar <out> <minwidth> <text> <color>
  magick -background '#0d0f13' -fill "$4" -font "$FONT" -pointsize 22 \
         label:"$3" -bordercolor '#0d0f13' -border 14 "$1"
  local tw; tw=$(magick identify -format '%w' "$1")
  if [ "$tw" -lt "$2" ]; then
    magick "$1" -background '#0d0f13' -gravity west -extent "${2}x" "$1"
  fi
}
widen () { # widen <png> <width>   (left-aligned, never crops)
  local w; w=$(magick identify -format '%w' "$1")
  [ "$w" -lt "$2" ] && magick "$1" -background "$BG" -gravity northwest -extent "${2}x$(magick identify -format '%h' "$1")" "$1"
  return 0
}

# ============================================================ MATCH SETUP page
awk '/--- MATCH SETUP ---/,/0 = back/' "$R/master_matchsetup_page.raw" \
  | sed 's/[[:space:]]*$//' > "$T/ms_master.txt"
awk '/--- MATCH SETUP ---/,/0 = back/' "$R/branch_matchsetup_page.raw" \
  | sed 's/[[:space:]]*$//' > "$T/ms_branch.txt"
panel "$T/ms_master.txt" "$T/ms_master.png"
panel "$T/ms_branch.txt" "$T/ms_branch.png" "$ACC"
W=$(magick identify -format '%w' "$T/ms_master.png")
W2=$(magick identify -format '%w' "$T/ms_branch.png")
[ "$W2" -gt "$W" ] && W=$W2
magick "$T/ms_master.png" -background "$BG" -gravity west -extent "${W}x" "$T/ms_master.png"
magick "$T/ms_branch.png" -background "$BG" -gravity west -extent "${W}x" "$T/ms_branch.png"
titlebar "$T/ms_h1.png" "$W" "MASTER 25113b61  (merge base)" '#c9ced8'
titlebar "$T/ms_h2.png" "$W" "BRANCH eccb04ea  (+ TIME LIMIT)" "$ACC"
for f in "$T/ms_h1.png" "$T/ms_h2.png" "$T/ms_master.png" "$T/ms_branch.png"; do
  w=$(magick identify -format '%w' "$f"); [ "$w" -gt "$W" ] && W=$w
done
for f in "$T/ms_h1.png" "$T/ms_h2.png"; do
  magick "$f" -background '#0d0f13' -gravity west -extent "${W}x" "$f"
done
widen "$T/ms_master.png" "$W"; widen "$T/ms_branch.png" "$W"
magick "$T/ms_h1.png" "$T/ms_master.png" -append "$T/ms_col1.png"
magick "$T/ms_h2.png" "$T/ms_branch.png" -append "$T/ms_col2.png"
magick "$T/ms_col1.png" \( -size 4x1 xc:'#39404d' -resize "4x$(magick identify -format '%h' "$T/ms_col1.png")\!" \) \
       "$T/ms_col2.png" +append \
       -bordercolor "$BG" -border 10 "$T/ms_body.png"
{ echo "openglad_text  camp -> MATCH SETUP     #241 TIME LIMIT knob"
  echo "\$ printf '1\\n\\n5\\n7\\n4\\n' | ./openglad_text --campaign modes --level 822 --seed 1234"
} > "$T/ms_cap.txt"
magick -background '#0d0f13' -fill "$TTL" -font "$FONT" -pointsize 22 label:@"$T/ms_cap.txt" \
       -bordercolor '#0d0f13' -border 16 -gravity west \
       -extent "$(magick identify -format '%w' "$T/ms_body.png")x" "$T/ms_cap.png"
magick "$T/ms_cap.png" "$T/ms_body.png" -append "$BASE/match_setup_page.png"

# ================================================ #247 preview vs launch pair
mkfair () { # mkfair <build-label> <out.txt>
  local b="$1"
  { echo "PREVIEW  (3 = View Scenario)"
    echo
    awk '/^--- SCEN 822/,/Press Enter to continue/' "$R/${b}_FAIR_preview.raw" \
      | grep -v 'Press Enter'
    echo
    echo "LAUNCH   (8 = Back, 6 = GO!, then tick 10 / census)"
    echo
    grep -o '"team_counts":\[[^]]*\]' "$R/${b}_FAIR_launch.raw" | head -1 \
      | sed 's/^/  {"cmd":"census","tick":10,/; s/$/,.../'
  } | sed 's/[[:space:]]*$//' > "$2"
}
mkfair master "$T/p247_master.txt"
mkfair branch "$T/p247_branch.txt"
panel "$T/p247_master.txt" "$T/p247_master.png" '#ffb3b3'
panel "$T/p247_branch.txt" "$T/p247_branch.png" "$ACC"
W=$(magick identify -format '%w' "$T/p247_master.png")
W2=$(magick identify -format '%w' "$T/p247_branch.png"); [ "$W2" -gt "$W" ] && W=$W2
H=$(magick identify -format '%h' "$T/p247_master.png")
H2=$(magick identify -format '%h' "$T/p247_branch.png"); [ "$H2" -gt "$H" ] && H=$H2
magick "$T/p247_master.png" -background "$BG" -gravity northwest -extent "${W}x${H}" "$T/p247_master.png"
magick "$T/p247_branch.png" -background "$BG" -gravity northwest -extent "${W}x${H}" "$T/p247_branch.png"
titlebar "$T/p247_h1.png" "$W" "MASTER 25113b61 -- launch != preview" '#ffb3b3'
titlebar "$T/p247_h2.png" "$W" "BRANCH eccb04ea -- preview == launch" "$ACC"
for f in "$T/p247_h1.png" "$T/p247_h2.png"; do w=$(magick identify -format '%w' "$f"); [ "$w" -gt "$W" ] && W=$w; done
for f in "$T/p247_h1.png" "$T/p247_h2.png"; do magick "$f" -background '#0d0f13' -gravity west -extent "${W}x" "$f"; done
widen "$T/p247_master.png" "$W"; widen "$T/p247_branch.png" "$W"
magick "$T/p247_h1.png" "$T/p247_master.png" -append "$T/p247_col1.png"
magick "$T/p247_h2.png" "$T/p247_branch.png" -append "$T/p247_col2.png"
magick "$T/p247_col1.png" \( -size 4x1 xc:'#39404d' -resize "4x$(magick identify -format '%h' "$T/p247_col1.png")\!" \) \
       "$T/p247_col2.png" +append -bordercolor "$BG" -border 10 "$T/p247_body.png"
BW=$(magick identify -format '%w' "$T/p247_body.png")
sed -n '/THE MATRIX/,/the bot sides the staged match filled/p' "$BASE/247_preview_vs_launch.txt" \
  | grep -v '^=' | sed 's/[[:space:]]*$//' > "$T/p247_matrix.txt"
magick -background '#191d24' -fill "$FG" -font "$FONT" -pointsize 20 label:@"$T/p247_matrix.txt" \
       -bordercolor '#191d24' -border 18 -gravity west -extent "${BW}x" "$T/p247_matrix.png"
{ echo "#247  openglad_text: the staged preview and the launched world disagreed"
  echo "scen 822 Soccer: FOURSQUARE   seed 1234   TROOPS: FAIR"
} > "$T/p247_cap.txt"
magick -background '#0d0f13' -fill "$TTL" -font "$FONT" -pointsize 22 label:@"$T/p247_cap.txt" \
       -bordercolor '#0d0f13' -border 16 -gravity west -extent "${BW}x" "$T/p247_cap.png"
magick "$T/p247_cap.png" "$T/p247_body.png" "$T/p247_matrix.png" -append "$BASE/247_preview_vs_launch.png"

# ================================================== #241 zero sentinel, soccer
runcol () { # runcol <raw> <out.txt> <face>
  local raw="$1"
  { echo "$(grep -o '   4. TIME LIMIT: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
    echo "$(grep -o '   2. TARGET SCORE: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
    echo
    echo "last tick records:"
    grep -o '{"tick":[0-9]*,"level_done":[^}]*}' "$raw" | tail -3 \
      | sed 's/,"level_done":0//; s/,"ending":0//; s/^/  /'
    echo
    echo "events, final line:"
    grep -o '{"tick":[0-9]*,"kind":8,[^}]*"text":"[^"]*"}' "$raw" | tail -1 \
      | sed 's/,"kind":8,"a":0,"b":0,"target":-1//; s/^/  /'
  } | sed 's/[[:space:]]*$//' > "$2"
}
build_row () { # build_row <outpng> <caption-file> <col-spec...>  cols: raw:title:color
  local out="$1"; shift
  local cap="$1"; shift
  local i=0 maxw=0 maxh=0 cols=()
  for spec in "$@"; do
    IFS='|' read -r raw title color <<< "$spec"
    runcol "$raw" "$T/rc$i.txt"
    panel "$T/rc$i.txt" "$T/rc$i.png" "$color"
    w=$(magick identify -format '%w' "$T/rc$i.png"); h=$(magick identify -format '%h' "$T/rc$i.png")
    [ "$w" -gt "$maxw" ] && maxw=$w; [ "$h" -gt "$maxh" ] && maxh=$h
    cols+=("$i|$title|$color"); i=$((i+1))
  done
  for c in "${cols[@]}"; do
    IFS='|' read -r idx title color <<< "$c"
    titlebar "$T/rh$idx.png" "$maxw" "$title" "$color"
    w=$(magick identify -format '%w' "$T/rh$idx.png"); [ "$w" -gt "$maxw" ] && maxw=$w
  done
  local parts=()
  for c in "${cols[@]}"; do
    IFS='|' read -r idx title color <<< "$c"
    magick "$T/rc$idx.png" -background "$BG" -gravity northwest -extent "${maxw}x${maxh}" "$T/rc$idx.png"
    magick "$T/rh$idx.png" -background '#0d0f13' -gravity west -extent "${maxw}x" "$T/rh$idx.png"
    magick "$T/rh$idx.png" "$T/rc$idx.png" -append "$T/rcol$idx.png"
    parts+=("$T/rcol$idx.png")
  done
  local sepH; sepH=$(magick identify -format '%h' "${parts[0]}")
  local args=("${parts[0]}")
  for ((k=1;k<${#parts[@]};k++)); do
    magick -size 4x"$sepH" xc:'#39404d' "$T/sep$k.png"
    args+=("$T/sep$k.png" "${parts[$k]}")
  done
  magick "${args[@]}" +append -bordercolor "$BG" -border 10 "$T/rbody.png"
  local bw; bw=$(magick identify -format '%w' "$T/rbody.png")
  magick -background '#0d0f13' -fill "$TTL" -font "$FONT" -pointsize 22 label:@"$cap" \
         -bordercolor '#0d0f13' -border 16 -gravity west -extent "${bw}x" "$T/rcap.png"
  magick "$T/rcap.png" "$T/rbody.png" -append "$out"
}

{ echo "#241  TIME LIMIT: the zero sentinel   soccer scen 822, seed 1234, TARGET SCORE 10"
  echo "same seed, same field -- only the knob differs. MAP = 0 ticks = \"use the level's own limit\"."
} > "$T/cap_soccer.txt"
build_row "$BASE/241_zero_sentinel_soccer.png" "$T/cap_soccer.txt" \
  "$R/branch_soccer822_time5m.raw|TIME LIMIT: 5M   -> ends 3600|#8fd0ff" \
  "$R/branch_soccer822_time10m.raw|TIME LIMIT: 10M  -> ends 7200|#c3a6ff" \
  "$R/branch_soccer822_timemap.raw|TIME LIMIT: MAP  -> ends 10800 (manifest)|$ACC"

{ echo "#241  CTF level 500, seed 1234, TARGET SCORE 10 -- the knob now governs CTF's clock"
  echo "master compared level_tick against the mode's own constant; the branch resolves knob -> manifest -> default."
} > "$T/cap_ctf.txt"
build_row "$BASE/241_ctf500_time_limit.png" "$T/cap_ctf.txt" \
  "$R/branch_ctf500_time5m.raw|TIME LIMIT: 5M  -> clock cuts it at 3600|#8fd0ff" \
  "$R/branch_ctf500_timemap.raw|TIME LIMIT: MAP -> runs past 3600, score ends it 4291|$ACC"

# Normalise to 8-bit RGB (magick defaults to 16-bit here, which triples the
# file size for no visible gain).  Explicit list: other capture sets drop pal8
# game frames into the same directory and must not be re-encoded here.
OUTS=("$BASE/match_setup_page.png" "$BASE/247_preview_vs_launch.png" \
      "$BASE/241_zero_sentinel_soccer.png" "$BASE/241_ctf500_time_limit.png")
for f in "${OUTS[@]}"; do magick "$f" -depth 8 PNG24:"$f"; done

echo "rendered:"
for f in "${OUTS[@]}"; do echo "  $f  $(magick identify -format '%wx%h %[bit-depth]bit' "$f")  $(stat -c%s "$f") bytes"; done
