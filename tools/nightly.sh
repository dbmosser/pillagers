#!/bin/bash
# nightly.sh : puts his idle PC to work, with no Claude usage. His words 2026-10-13: "do whatever you need to do top make my pc resources
# useful for the many hours that they it idle". Runs beside the scratchpad governor.sh (which owns light.flag: present = he is at the PC).
# Every 5 min:
# - When he has been away 30+ min, run each job ONCE per new game HEAD, in order (the corpus only 22:00-07:00, since it holds the ship lock ~2.5 h):
#   (1) the full regression corpus, (2) the local-LLM audits (tools/llm-night.ps1), (3) the input fuzzer (tools/fuzz.ps1, if present).
# - When he comes back, stop the LLM and fuzz jobs at once, unload the model so the GPU is his, and stop a corpus run, freeing its lock.
# - After a job finishes, write the morning summary tools/handoff/nightly/<date>.md, which Claude reads instead of the raw logs.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; N="$R/tools/handoff/nightly"; mkdir -p "$N"; ST="$N/state.txt"; LOG="$N/nightly.log"
OLL="/c/Users/User1/AppData/Local/Programs/Ollama/ollama.exe"
touch "$ST"
get(){ grep -m1 "^$1=" "$ST" | cut -d= -f2-; }
put(){ grep -v "^$1=" "$ST" > "$ST.tmp"; echo "$1=$2" >> "$ST.tmp"; mv "$ST.tmp" "$ST"; }
running(){ powershell -NoProfile -Command "(Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -match '$1' }).Count" 2>/dev/null | tr -dc '0-9'; }
killjob(){ powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { \$_.CommandLine -match '$1' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1; }
summary(){
  d=$(date +%Y-%m-%d); f="$N/$d.md"; L="$R/tools/handoff/llm-night"
  { echo "# Nightly $d (written $(date +%H:%M))"; echo; echo "HEAD $(git -C "$R" log -1 --format='%h %s')"; echo
    echo "## Regression corpus"; c=$(get corpus_file); if [ -n "$c" ] && [ -f "$c" ]; then grep -c 'FAIL' "$c" | sed 's/^/FAIL lines: /'; grep 'FAIL' "$c" | head -20; else echo "not run"; fi; echo
    echo "## Soaks (last lines)"; grep -E 'SOAK|4K' "$R/tools/handoff/daylong.log" 2>/dev/null | tail -4; echo
    echo "## Local LLM"; tail -2 "$L/run.log" 2>/dev/null; echo "leftovers: $(wc -l < "$L/leftovers.txt" 2>/dev/null)"
    echo "text-audit hits: $(grep -c '^L' "$L/text-audit.md" 2>/dev/null)"; grep '^L' "$L/text-audit.md" 2>/dev/null | head -25; echo
    echo "code-sweep hits: $(grep -c '^LINE' "$L/code-sweep.md" 2>/dev/null)"; grep '^LINE' "$L/code-sweep.md" 2>/dev/null | head -25; echo
    echo "## Fuzz"; if [ -f "$R/tools/handoff/fuzz/fuzz.log" ]; then tail -8 "$R/tools/handoff/fuzz/fuzz.log"; else echo "no fuzzer yet"; fi
  } > "$f"
}
echo "$(date '+%m-%d %H:%M') nightly.sh started" >> "$LOG"
away=0
while true; do
  head=$(git -C "$R" rev-parse --short HEAD 2>/dev/null)
  if [ -f "$S/light.flag" ]; then
    away=0
    if [ "$(running 'llm-night\.ps1')" != "0" ] || [ "$(running 'fuzz\.ps1')" != "0" ]; then
      killjob 'llm-night\.ps1|fuzz\.ps1'; "$OLL" stop qwen2.5-coder:32b >/dev/null 2>&1; "$OLL" stop qwen2.5-coder:14b >/dev/null 2>&1
      put llm_head ""; put fuzz_head ""; echo "$(date +%H:%M) he is back: stopped LLM/fuzz, unloaded the model (they rerun when he leaves)" >> "$LOG"; summary
    fi
    if [ "$(running 'corpq\.sh')" != "0" ]; then
      killjob 'corpq\.sh'; o=$(cut -d' ' -f2 "$S/shipq.owner" 2>/dev/null); [ "$o" = "corpus-night" ] && rmdir "$S/shipq.lock" 2>/dev/null
      echo "$(date +%H:%M) he is back: stopped the corpus run and freed its lock" >> "$LOG"; put corpus_head ""
    fi
  else
    away=$((away+5))
    if [ $away -ge 30 ]; then
      if [ "$(running 'corpq\.sh')" = "0" ] && [ "$(running 'llm-night\.ps1')" = "0" ] && [ "$(running 'fuzz\.ps1')" = "0" ]; then
        hr=$((10#$(date +%H))); night=0; { [ $hr -ge 22 ] || [ $hr -lt 7 ]; } && night=1
        if [ $night = 1 ] && [ "$(get corpus_head)" != "$head" ]; then
          out="$S/corpus-night-$(date +%m%d-%H%M).txt"; put corpus_head "$head"; put corpus_file "$out"
          echo "$(date +%H:%M) corpus start at $head" >> "$LOG"
          (bash -c "echo \"\$\$ corpus-night \$(date +%H:%M:%S)\" > '$S/shipq.owner'; exec bash '$S/corpq.sh' '$out'" > /dev/null 2>&1; echo "$(date +%H:%M) corpus done" >> "$LOG") &
        elif [ "$(get llm_head)" != "$head" ]; then
          since=$(get llm_head); put llm_head "$head"
          echo "$(date +%H:%M) llm audits start, since ${since:-whole file}" >> "$LOG"
          (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/llm-night.ps1" -Model qwen2.5-coder:14b ${since:+-Since $since} > /dev/null 2>&1; echo "$(date +%H:%M) llm audits done" >> "$LOG") &
        elif [ -f "$R/tools/fuzz.ps1" ] && [ "$(get fuzz_head)" != "$head" ]; then
          put fuzz_head "$head"; echo "$(date +%H:%M) fuzz start" >> "$LOG"
          (powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/fuzz.ps1" > /dev/null 2>&1; echo "$(date +%H:%M) fuzz done" >> "$LOG") &
        else
          [ "$(get summary_head)" != "$head" ] && { summary; put summary_head "$head"; echo "$(date +%H:%M) summary written" >> "$LOG"; }
        fi
      fi
    fi
  fi
  sleep 300
done
