#!/usr/bin/env bash
# Builds the shipped .txt transcripts from the raw openglad_text captures in raw/.
# Every block is preceded by the exact command that produced it. Distillation of
# the multi-megabyte `tick` JSON array is done with the grep pipelines shown
# inline in each transcript -- nothing is retyped by hand.
set -euo pipefail
BASE=/home/yans/code/openglad/build/media/pr-match-knobs
R="$BASE/raw"
BR=/home/yans/code/openglad/build/ci-test/openglad_text
MB=/tmp/claude-1000/-home-yans-code-openglad/00f90a3e-8657-4a2d-aceb-64d359cbd596/scratchpad/mb-master/build/mb-test/openglad_text

TICKS='grep -o "{\"tick\":[0-9]*,\"level_done\":[^}]*}"'
WINS='grep -o "{\"tick\":[0-9]*,\"kind\":8,[^}]*\"text\":\"[^\"]*\"}"'

# ---------------------------------------------------------------- 2b: the page
{
cat <<'HDR'
================================================================================
 TEXT CLIENT "MATCH SETUP" PAGE -- merge base vs branch          (#241)
 merge base : master 25113b61   binary: <mb-worktree>/build/mb-test/openglad_text
 branch     : feature/match-knobs-timelimit eccb04ea  binary: build/ci-test/openglad_text
 env        : SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
              OPENGLAD_CONFIG_DIR=$(mktemp -d)   (fresh per run)
================================================================================

--- MASTER 25113b61 -----------------------------------------------------------
$ printf '1\n\n5\n7\n4\n' | ./openglad_text --campaign modes --level 822 --seed 1234
  (1 = Begin New Game, <blank> = default company name, 5 = Ready -> Team Build,
   7 = Camp, 4 = MATCH SETUP)

HDR
awk '/--- MATCH SETUP ---/,/0 = back/' "$R/master_matchsetup_page.raw"
cat <<'HDR'

--- BRANCH eccb04ea -----------------------------------------------------------
$ printf '1\n\n5\n7\n4\n' | ./openglad_text --campaign modes --level 822 --seed 1234

HDR
awk '/--- MATCH SETUP ---/,/0 = back/' "$R/branch_matchsetup_page.raw"
cat <<'HDR'

Three knob rows become four. The new row's faces are MAP / 5 / 10 / 15 / 20m,
i.e. the cycle 0 / 3600 / 7200 / 10800 / 14400 ticks (720 ticks = 1 minute);
MAP is the zero sentinel, meaning "the level manifest's own limit".
HDR
} > "$BASE/match_setup_page.txt"

# ------------------------------------------------------- 2: the #247 pair/table
{
cat <<'HDR'
================================================================================
 #247  TEXT PICKER: THE PREVIEW AND THE LAUNCH DISAGREED
 scen 822 (Soccer: FOURSQUARE), seed 1234, one human company member
 merge base : master 25113b61        branch : feature/match-knobs-timelimit eccb04ea
 env        : SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
              OPENGLAD_CONFIG_DIR=$(mktemp -d)   (fresh per run)
 driver     : repro/troops_sweep.sh <binary> <label> raw/
================================================================================

 key decode: 1 = Begin New Game | <blank> = default company name
             5 = Ready -> Team Build | 10 = Scenario | 2 = Set Level | 822
             6 = TROOPS toggle (ALL -> OWN -> FAIR)
             3 = View Scenario (the PREVIEW)  |  8 = Back, 6 = GO! (the LAUNCH)

 preview: $ printf '1\n\n5\n10\n2\n822\n<toggles>3\n\n'  | ./openglad_text --campaign modes --level 822 --seed 1234
 launch : $ printf '1\n\n5\n10\n2\n822\n<toggles>8\n6\ntick 10\ncensus\nquit\n' | ./openglad_text --campaign modes --level 822 --seed 1234

================================================================================
 THE MATRIX -- what the preview promised vs what the launch actually built
================================================================================

HDR
printf '  %-6s | %-8s | %-22s | %-24s | %s\n' BUILD TROOPS "PREVIEW says" "LAUNCH team_counts" AGREE
printf '  %-6s-+-%-8s-+-%-22s-+-%-24s-+-%s\n' "------" "--------" "----------------------" "------------------------" "-----"
for b in master branch; do
  for s in ALL OWN FAIR; do
    prev=$(grep -o 'GREEN TEAM  ACTIVE - [A-Z ]*([0-9])' "$R/${b}_${s}_preview.raw" | head -1 | sed 's/GREEN TEAM  ACTIVE - //')
    cens=$(grep -o '"team_counts":\[[^]]*\]' "$R/${b}_${s}_launch.raw" | head -1 | sed 's/"team_counts"://')
    pn=$(echo "$prev" | grep -o '([0-9])' | tr -d '()')
    ln=$(echo "$cens" | cut -d, -f2)
    if [ "$pn" = "$ln" ]; then agree="yes"; else agree="NO  <-- #247"; fi
    printf '  %-6s | %-8s | %-22s | %-24s | %s\n' "$b" "$s" "$prev" "$cens" "$agree"
  done
done
cat <<'HDR'

  (team_counts is [red, green, blue, yellow, ...]; red = your 1 company member,
   the other three are the bot sides the staged match filled.)

================================================================================
 THE HEADLINE PAIR -- TROOPS: FAIR, verbatim
================================================================================

--- MASTER 25113b61, PREVIEW -------------------------------------------------
$ printf '1\n\n5\n10\n2\n822\n6\n6\n3\n\n' | ./openglad_text --campaign modes --level 822 --seed 1234
HDR
awk '/^--- SCEN 822/,/Press Enter to continue/' "$R/master_FAIR_preview.raw"
cat <<'HDR'

--- MASTER 25113b61, LAUNCH (the same knobs, GO!) ----------------------------
$ printf '1\n\n5\n10\n2\n822\n6\n6\n8\n6\ntick 10\ncensus\nquit\n' | ./openglad_text --campaign modes --level 822 --seed 1234
HDR
grep -o '{"cmd":"census".*"crew"' "$R/master_FAIR_launch.raw" | sed 's/,"named".*/ .../'
cat <<'HDR'
  ^ the preview promised MATCHED BOTS (1) per side; the launch built 5 per side.

--- BRANCH eccb04ea, PREVIEW -------------------------------------------------
$ printf '1\n\n5\n10\n2\n822\n6\n6\n3\n\n' | ./openglad_text --campaign modes --level 822 --seed 1234
HDR
awk '/^--- SCEN 822/,/Press Enter to continue/' "$R/branch_FAIR_preview.raw"
cat <<'HDR'

--- BRANCH eccb04ea, LAUNCH (the same knobs, GO!) ----------------------------
$ printf '1\n\n5\n10\n2\n822\n6\n6\n8\n6\ntick 10\ncensus\nquit\n' | ./openglad_text --campaign modes --level 822 --seed 1234
HDR
grep -o '{"cmd":"census".*"crew"' "$R/branch_FAIR_launch.raw" | sed 's/,"named".*/ .../'
cat <<'HDR'
  ^ preview and launch now agree: 1 matched bot per side.
HDR
} > "$BASE/247_preview_vs_launch.txt"

# ------------------------------------------- 3: the zero-sentinel timeout proof
{
cat <<'HDR'
================================================================================
 #241  TIME LIMIT KNOB -- THE ZERO SENTINEL, ON SOCCER
 branch feature/match-knobs-timelimit eccb04ea, scen 822 (Soccer: FOURSQUARE), seed 1234
 TARGET SCORE raised to 10 so the CLOCK decides the match, not the score.
 env    : SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy SDL_RENDER_DRIVER=software
          OPENGLAD_CONFIG_DIR=$(mktemp -d)   (fresh per run; the knob state
          persists through the camp autosave, so a stale config dir would leak
          the previous run's knob into the next one)
 driver : repro/timeout_run.sh <bin> <level> <time_presses> <tick_budget> <out.raw>
================================================================================

 $ printf '1\n\n5\n7\n4\n2\n2\n2\n2\n<TIMEKEYS>0\n0\n10\n2\n822\n8\n6\ntick <N>\nevents\nquit\n' \
     | ./openglad_text --campaign modes --level 822 --seed 1234

 key decode: 7 = Camp, 4 = MATCH SETUP, then on that page
             2 x4  = TARGET SCORE  map -> 1 -> 3 -> 5 -> 10
             4 xN  = TIME LIMIT    MAP -> 5M -> 10M -> 15M -> 20M   (<TIMEKEYS>)
             0, 0  = back to Team Build, 10 = Scenario, 2 = Set Level, 822,
             8 = Back, 6 = GO!, then the tick/events protocol.

 distilled with:
   grep -o '{"tick":[0-9]*,"level_done":[^}]*}'        <raw> | tail -1
   grep -o '{"tick":[0-9]*,"kind":8,[^}]*"text":"[^"]*"}' <raw> | tail -1

HDR
for row in "1 5000 5M 3600" "2 9000 10M 7200" "0 13000 MAP 10800"; do
  set -- $row; press=$1; budget=$2; face=$3; want=$4
  case "$face" in 5M) f=time5m;; 10M) f=time10m;; MAP) f=timemap;; esac
  raw="$R/branch_soccer822_${f}.raw"
  echo "--------------------------------------------------------------------------------"
  echo "TIME LIMIT: $face   (repro/timeout_run.sh \$BIN 822 $press $budget raw/$(basename $raw))"
  echo "  knob row as the client rendered it after the presses:"
  echo "      $(grep -o '   4. TIME LIMIT: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
  echo "      $(grep -o '   2. TARGET SCORE: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
  echo "  last three tick records before the loop broke:"
  grep -o '{"tick":[0-9]*,"level_done":[^}]*}' "$raw" | tail -3 | sed 's/^/      /'
  echo "  the mode's own announcement, from the events log:"
  grep -o '{"tick":[0-9]*,"kind":8,[^}]*"text":"[^"]*"}' "$raw" | tail -1 | sed 's/^/      /'
  echo
done
cat <<'HDR'
--------------------------------------------------------------------------------
 5M  -> game_ended at tick  3600  (= 3600, the knob)
 10M -> game_ended at tick  7200  (= 7200, the knob)
 MAP -> game_ended at tick 10800  (= mode_levels.lua [822].time_limit = 10800)

 MAP is not "no limit" and it is not a fourth hard-coded number: it is the zero
 sentinel resolving to the level manifest's own value. Same seed, same field,
 three different endings, each landing on its knob's tick exactly.
HDR
} > "$BASE/241_zero_sentinel_soccer.txt"

# --------------------------------------------------- 4: CTF, the fixed manifest
{
cat <<'HDR'
================================================================================
 #241  TIME LIMIT ON CTF -- THE FIXED MANIFEST PATH, IN ANGER
 branch feature/match-knobs-timelimit eccb04ea, level 500 (CTF), seed 1234,
 TARGET SCORE 10.

 CTF was the one mode that did not read a limit from anywhere. On master
 25113b61, mode_ctf_impl.lua:447 reads

     if level_tick >= T.time_limit_ticks then

 where T.time_limit_ticks is the mode's own tuning constant, 14400 (line 57) --
 the level manifest row was never consulted. On this branch, line 452 reads

     if level_tick >= match.resolve_time_limit(row, T.time_limit_ticks) then

 so CTF now goes through the same resolver as every other mode: knob first,
 then the manifest row, then the mode's own default. (Every shipped CTF level
 happens to be authored at 14400 too, so on master the two numbers coincided
 and the bug stayed latent; it becomes visible the moment a knob exists.)

 Both runs below are the same match from the same seed -- only the TIME LIMIT
 face differs. There is no master half of this pair: master has no knob to set.
 driver : repro/timeout_run.sh <bin> 500 <time_presses> <tick_budget> <out.raw>
================================================================================

HDR
for row in "1 5000 5M" "0 6000 MAP"; do
  set -- $row; press=$1; budget=$2; face=$3
  case "$face" in 5M) f=time5m;; MAP) f=timemap;; esac
  raw="$R/branch_ctf500_${f}.raw"
  echo "--------------------------------------------------------------------------------"
  echo "TIME LIMIT: $face   (repro/timeout_run.sh \$BIN 500 $press $budget raw/$(basename $raw))"
  echo "      $(grep -o '   4. TIME LIMIT: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
  echo "      $(grep -o '   2. TARGET SCORE: [A-Z0-9]* - .*' "$raw" | tail -1 | sed 's/^ *//')"
  echo "  last three tick records:"
  grep -o '{"tick":[0-9]*,"level_done":[^}]*}' "$raw" | tail -3 | sed 's/^/      /'
  echo "  last four announcements:"
  grep -o '{"tick":[0-9]*,"kind":8,[^}]*"text":"[^"]*"}' "$raw" | tail -4 | sed 's/^/      /'
  echo
done
cat <<'HDR'
--------------------------------------------------------------------------------
 5M  -> the clock cuts the match at tick 3600 with GREEN on 8/10; GREEN TEAM WINS
        on the lead.
 MAP -> the identical match runs on past 3600 and is decided by the SCORE at
        tick 4291, when GREEN takes the 10th flag. It never reaches level 500's
        manifest limit of 14400, which is the honest reading of this pair: MAP
        removed the 3600 cut, it did not add one of its own.
HDR
} > "$BASE/241_ctf500_time_limit.txt"

echo "wrote:"
ls -la "$BASE"/*.txt
