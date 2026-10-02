#!/bin/bash
# Overnight low-token load: four loops in parallel for SECS seconds, each batch only when 6 GB of RAM is free.
#   A: two-player soaks (9335/8809)  B: bot raids sector 0 (9336/8804)  C: bot raids sector 1 (9337/8805)  D: 4K drawing soak (9345/8803)
# Appends one line per batch to tools/handoff/overnight.log and prints a summary with failures only at the end.
SECS=${1:-32400}; LOOPS=${2:-ABCD}; LOGNAME=${3:-overnight}; END=$(( $(date +%s) + SECS ))
H="C:\claudecode\dark raiders\tools\handoff"; HU="/c/claudecode/dark raiders/tools/handoff"; LOG="$HU/$LOGNAME.log"
: > "$LOG"
avail(){ powershell -NoProfile -Command "[math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue)" 2>/dev/null | tr -dc '0-9'; }
ok(){ [ "$(date +%s)" -lt "$END" ] && [ "$(avail)" -ge 6000 ]; }
loopA(){ while [ "$(date +%s)" -lt "$END" ]; do if ok; then
  S=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$H\soakloop.ps1" -Runs 3 -Soak 180 -Cdp 9335 -Port 8809 2>/dev/null)
  echo "$(date +%H:%M) SOAK $(echo "$S" | grep -c '"pass":true')/$(echo "$S" | grep -c '^run')" >> "$LOG"
  echo "$S" | grep '"pass":false' | sed "s/^/$(date +%H:%M) SOAKFAIL /" | cut -c1-1100 >> "$LOG"
  else sleep 300; fi; done; }
loopB(){ local sd=10000; while [ "$(date +%s)" -lt "$END" ]; do if ok; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "$H\botsweep.ps1" -Cdp 9336 -Port 8804 -From $sd -N 200 -Map 0 >/dev/null 2>&1
  r=$(bash "$HU/watchbots.sh" 1500 "9336" | grep '^{'); echo "$(date +%H:%M) BOTS0 from $sd $r" | cut -c1-600 >> "$LOG"; sd=$((sd+200))
  else sleep 300; fi; done; }
loopC(){ local sd=20000; while [ "$(date +%s)" -lt "$END" ]; do if ok; then
  powershell -NoProfile -ExecutionPolicy Bypass -File "$H\botsweep.ps1" -Cdp 9337 -Port 8805 -From $sd -N 60 -Map 1 >/dev/null 2>&1
  r=$(bash "$HU/watchbots.sh" 1500 "9337" | grep '^{'); echo "$(date +%H:%M) BOTS1 from $sd $r" | cut -c1-600 >> "$LOG"; sd=$((sd+60))
  else sleep 300; fi; done; }
loopE(){ while [ "$(date +%s)" -lt "$END" ]; do if ok; then
  S=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$H\soakloop.ps1" -Runs 3 -Soak 180 -Cdp 9338 -Port 8807 2>/dev/null)
  echo "$(date +%H:%M) SOAK $(echo "$S" | grep -c '"pass":true')/$(echo "$S" | grep -c '^run')" >> "$LOG"
  echo "$S" | grep '"pass":false' | sed "s/^/$(date +%H:%M) SOAKFAIL /" | cut -c1-1100 >> "$LOG"
  else sleep 300; fi; done; }
loopD(){ while [ "$(date +%s)" -lt "$END" ]; do if ok; then
  r=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$H\soak4k.ps1" -Raids 30 -Sec 20 -Cdp 9345 2>/dev/null | tail -1); echo "$(date +%H:%M) 4K $r" | cut -c1-400 >> "$LOG"
  else sleep 300; fi; done; }
for L in A B C D E; do case "$LOOPS" in *$L*) loop$L & ;; esac; done; wait
s=$(grep -c ' SOAK ' "$LOG"); sp=$(grep ' SOAK ' "$LOG" | awk '{split($3,a,"/"); p+=a[1]; t+=a[2]} END{print p"/"t}')
echo "overnight: two-player soak sessions passed $sp in $s batches"
echo "bot raids: sector 0 $(grep -c BOTS0 "$LOG") batches, sector 1 $(grep -c BOTS1 "$LOG") batches, batches with errors: $(grep 'BOTS' "$LOG" | grep -vc '"errs":\[\]')"
echo "4K: $(grep -c ' 4K ' "$LOG") batches, lowest fps line: $(grep ' 4K ' "$LOG" | grep -o 'lowest [0-9]*' | sort -k2 -n | head -1), with errors: $(grep ' 4K ' "$LOG" | grep -c ERRORS)"
grep 'SOAKFAIL\|ERRORS' "$LOG" | cut -c1-300 | head -12; grep 'BOTS' "$LOG" | grep -v '"errs":\[\]' | cut -c1-400 | head -6
