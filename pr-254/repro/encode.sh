#!/usr/bin/env bash
# Encode the pr-notif media from the two BMP frame dumps (branch + master).
set -euo pipefail

SCR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="${1:-/home/yans/code/openglad/build/media/pr-notif}"
FONT=/nix/store/37c8di1dc9zp4xfb1pzqdg1gbpbkniw5-dejavu-fonts-2.37/share/fonts/truetype/DejaVuSansMono.ttf
mkdir -p "$OUT"
FF=(ffmpeg -hide_banner -loglevel error -y)

# --- Single-run GIFs: every 2nd tick, 2x nearest-neighbour, 12 fps ---------
one_gif() { # one_gif <framedir> <out.gif>
  local dir=$1 out=$2 pal="$SCR/pal.png"
  "${FF[@]}" -framerate 24 -pattern_type glob -i "$dir/*.bmp" \
      -vf "select='not(mod(n,2))',setpts=N/12/TB,scale=iw*2:ih*2:flags=neighbor,palettegen=reserve_transparent=0" "$pal"
  "${FF[@]}" -framerate 24 -pattern_type glob -i "$dir/*.bmp" -i "$pal" \
      -lavfi "[0:v]select='not(mod(n,2))',setpts=N/12/TB,scale=iw*2:ih*2:flags=neighbor[x];[x][1:v]paletteuse=dither=none" \
      -loop 0 -r 12 "$out"
  rm -f "$pal"
}

one_gif "$SCR/show_master" "$OUT/232-timeleft-feed-jitter-master.gif"
one_gif "$SCR/show_branch" "$OUT/232-timeleft-feed-clean-branch.gif"

# --- Stacked A/B GIF: top 104 rows of each frame, labelled ----------------
pal="$SCR/pal2.png"
STACK="[0:v]select='not(mod(n,2))',setpts=N/12/TB,crop=320:104:0:0,scale=iw*2:ih*2:flags=neighbor,\
drawtext=fontfile=$FONT:text='master — TIME LEFT rides the message feed':x=8:y=6:fontsize=15:fontcolor=white:box=1:boxcolor=black@0.75:boxborderw=4[m];\
[1:v]select='not(mod(n,2))',setpts=N/12/TB,crop=320:104:0:0,scale=iw*2:ih*2:flags=neighbor,\
drawtext=fontfile=$FONT:text='branch — feed carries only real messages':x=8:y=6:fontsize=15:fontcolor=white:box=1:boxcolor=black@0.75:boxborderw=4[b];\
[m][b]vstack=inputs=2"
"${FF[@]}" -framerate 24 -pattern_type glob -i "$SCR/show_master/*.bmp" \
           -framerate 24 -pattern_type glob -i "$SCR/show_branch/*.bmp" \
    -lavfi "${STACK},palettegen=reserve_transparent=0" "$pal"
"${FF[@]}" -framerate 24 -pattern_type glob -i "$SCR/show_master/*.bmp" \
           -framerate 24 -pattern_type glob -i "$SCR/show_branch/*.bmp" -i "$pal" \
    -lavfi "${STACK}[s];[s][2:v]paletteuse=dither=none" -loop 0 -r 12 \
    "$OUT/232-timeleft-master-vs-branch.gif"
rm -f "$pal"

# --- Stills ---------------------------------------------------------------
still() { # still <bmp> <out.png> [crop]
  local crop=${3:-}
  local vf="scale=iw*2:ih*2:flags=neighbor,split[a][b];[a]palettegen=reserve_transparent=0[p];[b][p]paletteuse=dither=none"
  [ -n "$crop" ] && vf="crop=$crop,$vf"
  "${FF[@]}" -i "$1" -vf "$vf" -frames:v 1 -update 1 -compression_level 9 "$2"
}

still "$SCR/show_master/frame00100.bmp" "$OUT/232-feed-master-tick100.png"
still "$SCR/show_branch/frame00100.bmp" "$OUT/232-feed-branch-tick100.png"

# Three master crops stacked: the countdown hopping a row and shifting
# horizontally as its digit count drops (ticks 45 / 100 / 140).
for t in 00045 00100 00140; do
  "${FF[@]}" -i "$SCR/show_master/frame$t.bmp" \
      -vf 'crop=320:56:0:0,scale=iw*2:ih*2:flags=neighbor' -frames:v 1 -update 1 "$SCR/hop_$t.png"
done
magick "$SCR/hop_00045.png" "$SCR/hop_00100.png" "$SCR/hop_00140.png" -append \
       "$OUT/232-feed-master-row-hop.png"

ls -l "$OUT"
