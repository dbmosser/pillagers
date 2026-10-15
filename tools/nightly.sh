#!/bin/bash
# nightly.sh : THE ALWAYS-ON RUNNER. It puts his PC to work on the game around the clock, with no Claude usage.
# His orders:
# - 2026-10-13: "do whatever you need to do top make my pc resources useful for the many hours that they it idle".
# - 2026-10-15: "cant you use like half my pc for something?"
# - 2026-10-15: "set it up so you are always doing that or something productive with my pc in a low token manner, if you aren't doing
#   anything else and even if i'm at my pc".
# - 2026-10-15: "do whatever you have to in order to continually work on the game and make progress 24 hours a day -- this is RULE NUMBER ONE".
# Every 5 min, whether or not he is at the PC (about half the PC: at most two test Chromes of its own):
#   (1) the input fuzzer (tools/fuzz.ps1, Chrome 9331) runs back to back, two hours at a time, with new seeds each run;
#   (2) the full regression corpus (corpq.sh, Chrome 9344) once per new game HEAD, when the ship queue has been idle 45 min
#       (it holds the ship lock about 2.5 h);
#   (3) the local-LLM audits (tools/llm-night.ps1) once per new HEAD, only with 20+ GB of RAM free (the model holds about 12 GB);
#   (4) once a day, the itch and GitHub backup catch-up (tools/itch-daily.sh).
# - No new job starts while free RAM is under 6 GB (his floor).
# - Every hour it writes tools/handoff/nightly/<date>.md, which Claude reads instead of the raw logs.
# - ONE COPY: a heartbeat file younger than 10 min means another copy is alive, so this one exits. A Windows scheduled task
#   (tools/runner-start.vbs, every 15 min) starts it again if it ever dies, with or without a Claude session.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; N="$R/tools/handoff/nightly"; mkdir -p "$N"; ST="$N/state.txt"; LOG="$N/nightly.log"; HB="$N/runner.heartbeat"
touch "$ST"
if [ -f "$HB" ] && [ $(( $(date +%s) - $(cat "$HB" 2>/dev/null || echo 0) )) -lt 600 ]; then exit 0; fi
date +%s > "$HB"
get(){ grep -m1 "^$1=" "$ST" | cut -d= -f2-; }
put(){ grep -v "^$1=" "$ST" > "$ST.tmp"; echo "$1=$2" >> "$ST.tmp"; mv "$ST.tmp" "$ST"; }
running(){ powershell -NoProfile -Command "(Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -match '$1' }).Count" 2>/dev/null | tr -dc '0-9'; }
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
    if [ -f "$R/tools/fuzz.ps1" ] && [ "$(running 'fuzz\.ps1')" = "0" ]; then
      echo "$(date +%H:%M) fuzz start at $head" >> "$LOG"
      (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/fuzz.ps1" -Minutes 120 -IgnoreFlag > /dev/null 2>&1; echo "$(date +%H:%M) fuzz done" >> "$LOG") &
    fi
    # (2) the corpus, once per new HEAD, when nothing has shipped for 45 min and the lock is free
    qidle=$(( $(date +%s) - $(git -C "$R" log -1 --format=%ct 2>/dev/null || echo 0) ))
    if [ "$(get corpus_head)" != "$head" ] && [ $qidle -ge 2700 ] && [ ! -d "$S/shipq.lock" ] && [ "$(running 'corpq\.sh')" = "0" ]; then
      out="$S/corpus-$(date +%m%d-%H%M).txt"; put corpus_head "$head"; put corpus_file "$out"
      echo "$(date +%H:%M) corpus start at $head" >> "$LOG"
      (bash -c "echo \"\$\$ corpus-night \$(date +%H:%M:%S)\" > '$S/shipq.owner'; exec bash '$S/corpq.sh' '$out'" > /dev/null 2>&1; echo "$(date +%H:%M) corpus done" >> "$LOG"; summary) &
    fi
    # (3) the local LLM, once per new HEAD, only with plenty of RAM
    if [ "$(get llm_head)" != "$head" ] && [ "$ram" -ge 20 ] && [ "$(running 'llm-night\.ps1')" = "0" ]; then
      since=$(get llm_head); put llm_head "$head"
      echo "$(date +%H:%M) llm audits start, since ${since:-whole file}" >> "$LOG"
      (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/llm-night.ps1" -Model qwen2.5-coder:14b ${since:+-Since $since} > /dev/null 2>&1; echo "$(date +%H:%M) llm audits done" >> "$LOG") &
    fi
  fi
  now=$(date +%s); st=$(get summary_t); [ -z "$st" ] && st=0
  [ $(( now - st )) -ge 3600 ] && { summary; put summary_t "$now"; }
  sleep 300
done
