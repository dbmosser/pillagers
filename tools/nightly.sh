#!/bin/bash
# nightly.sh : THE ALWAYS-ON RUNNER. It puts his PC to work on the game around the clock, with no Claude usage.
# His orders:
# - 2026-10-13: "do whatever you need to do top make my pc resources useful for the many hours that they it idle".
# - 2026-10-15: "cant you use like half my pc for something?"
# - 2026-10-15: "set it up so you are always doing that or something productive with my pc in a low token manner, if you aren't doing
#   anything else and even if i'm at my pc".
# - 2026-10-15: "do whatever you have to in order to continually work on the game and make progress 24 hours a day -- this is RULE NUMBER ONE".
# Every 5 min, whether or not he is at the PC. Nothing in this file reads light.flag (the old "he is at the PC" flag): fuzz.ps1 is
# started with -IgnoreFlag, so the flag cannot stop the robots; the only guards are the RAM floor below and each job's own checks.
# Test Chromes (checked 10-18 against the scripts): up to 13 can be open at once: fuzzers 9331 and 9332, corpus 9344, ship gate 9346,
# preflight one per lane a to h (9351-9358), one screenshot camera (uishots, 9339); each lane's own camera uses 9361-9366, so more if
# several cameras run (that last part is unverified). The old line "at most two test Chromes" was wrong. Jobs:
#   (1) the input fuzzer (tools/fuzz.ps1, Chrome 9331) runs back to back, two hours at a time, with new seeds each run;
#   (2) the full regression corpus (corpq.sh, Chrome 9344): at most every 4 hours AND only on a new game HEAD (corpus_t and corpus_head
#       in state.txt). It does not wait for the ship queue to be idle and takes no ship lock (it tests a frozen copy, tools/fxcorpus.html);
#       one run takes 2.5 to 3.5 hours;
#   (3) the local-LLM audits (tools/llm-night.ps1) once per new HEAD, only with 20+ GB of RAM free (the model holds about 12 GB);
#   (4) once a day, the itch and GitHub backup catch-up (tools/itch-daily.sh);
#   (5) the Console worker LANES (tools/console-lane.sh LANE; the older tools/console-worker.sh is still honoured: lane a waits while it runs).
#       This file starts lanes a, b and c, each one Claude task at a time (a lane with an empty list takes another lane's job). Lanes e and f
#       (CLI_ALWAYS in tools/handoff/console/caps.txt) are started by the lanes themselves and always run on Claude Code on his plan, paced by
#       his real plan usage; when the Console money is used up a, b and c switch to Claude Code too, but only CLI_LANES of them (1) run.
#       Lanes d, g and h are NOT started here: they are
#       session agents that only borrow a preflight Chrome. Status is in tools/handoff/console/status-LANE.txt; a STOP file in
#       tools/handoff/console pauses all lanes;
#   (6) a second fuzzer on Chrome 9332 (8+ GB free) and (7) once a day after 03:00 the review of the day's commits (tools/review-nightly.sh).
# - No new job starts while free RAM is under 6 GB (his floor).
# - Every hour it writes tools/handoff/nightly/<date>.md, which Claude reads instead of the raw logs.
# - ONE COPY: a heartbeat file younger than 10 min means another copy is alive, so this one exits. A Windows scheduled task
#   (tools/runner-start.vbs, every 15 min; task "Pillagers runner", seen Enabled on 10-18) starts it again if it ever dies, with or
#   without a Claude session. tools/party-stop.ps1 disables that task for the party; nothing turns it back on except party-start.ps1.
# - 2026-10-18 (his orders): (8) once an hour tools/stable.sh decides whether a newer version is STABLE and publishes it as
#   http://localhost:8802/stable.html; (9) at 07:00 and 18:00 tools/report.mjs writes the plain morning/evening report with pictures
#   (tools/handoff/reports/); the second fuzzer runs on the corpus copy of the game so one exact version gets both the full test set and
#   30+ robot minutes (what stable.sh needs); each corpus run leaves a .head file beside its output naming the commit it tested.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; N="$R/tools/handoff/nightly"; mkdir -p "$N"; ST="$N/state.txt"; LOG="$N/nightly.log"; HB="$N/runner.heartbeat"
touch "$ST"
if [ -f "$HB" ] && [ $(( $(date +%s) - $(cat "$HB" 2>/dev/null || echo 0) )) -lt 600 ]; then exit 0; fi
date +%s > "$HB"
get(){ grep -m1 "^$1=" "$ST" | cut -d= -f2-; }
put(){ grep -v "^$1=" "$ST" > "$ST.tmp"; echo "$1=$2" >> "$ST.tmp"; mv "$ST.tmp" "$ST"; }
running(){ powershell -NoProfile -Command "@(Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -match '$1' }).Count" 2>/dev/null | tr -dc '0-9'; }
freegb(){ powershell -NoProfile -Command "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB)" 2>/dev/null | tr -dc '0-9'; }
summary(){
  d=$(date +%Y-%m-%d); f="$N/$d.md"; L="$R/tools/handoff/llm-night"
  { echo "# Runner $d (written $(date +%H:%M))"; echo; echo "HEAD $(git -C "$R" log -1 --format='%h %s')"; echo
    echo "## Regression corpus"; c=$(get corpus_file); if [ -n "$c" ] && [ -f "$c" ]; then echo "file: $c"; grep -c 'FAIL' "$c" | sed 's/^/FAIL lines: /'; grep 'FAIL' "$c" | head -20; else echo "not run"; fi; echo
    echo "## Fuzz"; if [ -f "$R/tools/handoff/fuzz/fuzz.log" ]; then grep -E 'FUZZ END|problems=[1-9]' "$R/tools/handoff/fuzz/fuzz.log" | tail -10; else echo "no fuzzer yet"; fi; echo
    echo "## Local LLM"; tail -2 "$L/run.log" 2>/dev/null
    echo "text-audit hits: $(grep -c '^L' "$L/text-audit.md" 2>/dev/null)"; grep '^L' "$L/text-audit.md" 2>/dev/null | head -15
    echo "code-sweep hits: $(grep -c '^LINE' "$L/code-sweep.md" 2>/dev/null)"; grep '^LINE' "$L/code-sweep.md" 2>/dev/null | head -15
  } > "$f"
}
echo "$(date '+%m-%d %H:%M') always-on runner started (pid $$)" >> "$LOG"
while true; do
  date +%s > "$HB"
  head=$(git -C "$R" rev-parse --short HEAD 2>/dev/null)
  if [ "$(get backup_day)" != "$(date +%F)" ]; then put backup_day "$(date +%F)"; bash "$R/tools/itch-daily.sh" >> "$LOG" 2>&1; fi
  ram=$(freegb); [ -z "$ram" ] && ram=0
  if [ "$ram" -ge 6 ]; then
    # (1) the fuzzer, back to back
    fa=$(running 'fuzz\.ps1'); fb=$(running 'fuzz\.ps1.*9332')   # an empty count means the check failed: start nothing
    if [ -n "$fa" ] && [ -n "$fb" ] && [ -f "$R/tools/fuzz.ps1" ] && [ $((fa - fb)) -le 0 ]; then
      echo "$(date +%H:%M) fuzz start at $head" >> "$LOG"
      (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/fuzz.ps1" -Minutes 120 -IgnoreFlag > /dev/null 2>&1; echo "$(date +%H:%M) fuzz done" >> "$LOG") &
    fi
    # (2) the corpus, at most every 4 hours on a new HEAD. 10-17 evening (his "check all your stuff ... other misestimates"): it no
    #     longer waits for 45 min without a ship nor holds the ship lock (3.5 hours on 10-17): corpq.sh tests a frozen fixture copy.
    cl="$S/corpus.lock"; [ -d "$cl" ] && [ $(( $(date +%s) - $(stat -c %Y "$cl") )) -gt 21600 ] && rmdir "$cl" 2>/dev/null
    ct=$(get corpus_t); [ -z "$ct" ] && ct=0
    if [ "$(get corpus_head)" != "$head" ] && [ $(( $(date +%s) - ct )) -ge 14400 ] && mkdir "$cl" 2>/dev/null; then
      out="$S/corpus-$(date +%m%d-%H%M).txt"; put corpus_head "$head"; put corpus_file "$out"; put corpus_t "$(date +%s)"; echo "$head" > "$out.head"
      echo "$(date +%H:%M) corpus start at $head" >> "$LOG"
      (bash "$S/corpq.sh" "$out" > /dev/null 2>&1; rmdir "$cl" 2>/dev/null; echo "$(date +%H:%M) corpus done" >> "$LOG"; summary) &
    fi
    # (3) the local LLM, once per new HEAD, only with plenty of RAM
    if [ "$(get llm_head)" != "$head" ] && [ "$ram" -ge 20 ] && [ "$(running 'llm-night\.ps1')" = "0" ]; then
      since=$(get llm_head); put llm_head "$head"
      echo "$(date +%H:%M) llm audits start, since ${since:-whole file}" >> "$LOG"
      (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/llm-night.ps1" -Model qwen2.5-coder:14b ${since:+-Since $since} > /dev/null 2>&1; echo "$(date +%H:%M) llm audits done" >> "$LOG") &
    fi
    # (5) 2026-10-17, his "yes, build the unattended worker that spends my Console credits": the Console worker
    #     (tools/console-worker.sh) runs one Claude task at a time on his Console credits; it waits quietly until his key is saved
    #     10-17 later, his "max out my pc resources and the claude console resources": three lanes at once (tools/console-lane.sh
    #     a, b, c), one worker each; lane a also waits for an older console-worker.sh run still going
    for ln in a b c; do
      [ "$ln" = a ] && [ "$(running 'console-worker\.sh')" != "0" ] && continue
      if [ -f "$R/tools/console-lane.sh" ] && [ "$(running "console-lane\.sh $ln")" = "0" ]; then
        (bash "$R/tools/console-lane.sh" $ln > /dev/null 2>&1) &
      fi
    done
    # (6) 10-17: a second fuzzer on its own Chrome (9332) with its own seeds, beside the first (9331)
    f2=$(running 'fuzz\.ps1.*9332')
    if [ -f "$R/tools/fuzz.ps1" ] && [ "$f2" = "0" ] && [ "$ram" -ge 8 ]; then
      # 10-18: on the corpus copy of the game (tools/fxcorpus.html, under 12 hours old) so the full test set and the robots meet on one version
      fxarg=""; [ -n "$(find "$R/tools/fxcorpus.html" -mmin -720 2>/dev/null)" ] && fxarg="-Fixture fxcorpus.html"
      echo "$(date +%H:%M) fuzz2 start at $head${fxarg:+ on the corpus copy}" >> "$LOG"
      (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/fuzz.ps1" -Minutes 120 -IgnoreFlag -Port 9332 $fxarg > /dev/null 2>&1; echo "$(date +%H:%M) fuzz2 done" >> "$LOG") &
    fi
  fi
  # (7) 2026-10-17: once a day after 03:00, the half-price code review of the day's game commits (tools/review-nightly.sh)
  if [ "$(get review_day)" != "$(date +%F)" ] && [ "$(date +%H)" -ge 3 ]; then put review_day "$(date +%F)"; (bash "$R/tools/review-nightly.sh" > /dev/null 2>&1) & fi
  # (8) 2026-10-18, his "my play window always loads the latest stable build": once an hour tools/stable.sh checks whether a newer version is
  #     STABLE (finished test run with no new failure + 30 robot minutes on the same version); if so it copies it to stable.html
  #     (http://localhost:8802/stable.html), writes tools/handoff/stable.txt and tags it stable-vNN.NN. It reads only git and the logs.
  stt=$(get stable_t); [ -z "$stt" ] && stt=0
  if [ $(( $(date +%s) - stt )) -ge 3600 ] && [ -f "$R/tools/stable.sh" ]; then put stable_t "$(date +%s)"; (bash "$R/tools/stable.sh" --quiet >> "$LOG" 2>&1) & fi
  # (9) 2026-10-18, his "a plain report of what changed, morning and evening, with pictures": tools/report.mjs (Node, no AI calls) writes
  #     tools/handoff/reports/YYYY-MM-DD-am.html from 07:00 and -pm.html from 18:00; the dashboard links the newest one
  hr=$(date +%H)
  if [ "$hr" -ge 7 ] && [ "$hr" -lt 12 ] && [ "$(get report_am)" != "$(date +%F)" ] && [ -f "$R/tools/report.mjs" ]; then put report_am "$(date +%F)"; (node "$R/tools/report.mjs" --kind am --auto >> "$LOG" 2>&1) & fi
  if [ "$hr" -ge 18 ] && [ "$(get report_pm)" != "$(date +%F)" ] && [ -f "$R/tools/report.mjs" ]; then put report_pm "$(date +%F)"; (node "$R/tools/report.mjs" --kind pm --auto >> "$LOG" 2>&1) & fi
  now=$(date +%s); st=$(get summary_t); [ -z "$st" ] && st=0
  [ $(( now - st )) -ge 3600 ] && { summary; put summary_t "$now"; }
  sleep 300
done
