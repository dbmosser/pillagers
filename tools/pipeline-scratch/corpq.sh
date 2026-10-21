#!/bin/bash
# corpq.sh OUT.txt : the full regression corpus on corpus Chrome 9344. Prints the FAIL lines at the end. Takes 2.5 to 3.5 hours.
# 10-17 evening (his "check all your stuff to see if there are other misestimates like this"): it used to HOLD THE SHIP LOCK the
# whole time (3.5 hours on 10-17, 12:53 to 16:23), so no helper could ship. It now tests a frozen copy of the fixture
# (tools/fxcorpus.html, taken at the start), so ships can rebuild tools/fixture.html meanwhile, and it takes no lock. Its Chrome
# (9344) has its own profile, so its storage never meets the gate Chrome's.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; OUT="${1:-$S/corpus-belt.txt}"
cd "$R" || exit 1
# 10-21 10:40 (coordinator): a run starts only when it can finish in peace. The check lives here as well as in nightly.sh because the
# runner reads its loop once at start, while this file is read fresh for every run. It refuses:
#  - with under 5 GB free (the smaller of free RAM and free virtual memory): its Chrome takes 2 to 4 GB, and the 07:04 run on the 10 GB
#    day VM took it to 0.7 GB free and stopped the robots and two helpers;
#  - from 02:30 to 06:30: a run takes 2.5 to 3.5 hours and must be over before the VM hands its night memory back at 06:00 (answer 45 a;
#    the 06:03 low-memory event of 10-21 was that handback).
# A refused run leaves no file and tells the runner when to try again (corpus_t, corpus_head in state.txt): in 30 minutes from 22:00 to
# 02:30, else at 22:30, just before the night memory comes in at 23:00. nightly.log gets a line only when the reason changes.
# CORPUS_FORCE=1 skips the check (a run started by hand). CQ_STATE, CQ_RF and CQ_LOG point the writes elsewhere for a test.
if [ -z "$CORPUS_FORCE" ]; then
  fg=$(powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; [int]([Math]::Min(\$o.FreePhysicalMemory,\$o.FreeVirtualMemory)/1MB)" 2>/dev/null | tr -dc '0-9')
  hm=$((10#$(date +%H%M))); why=""; key=""
  [ "${fg:-0}" -lt 5 ] && { why="${fg:-0} GB free, it needs 5"; key="memory"; }
  [ "$hm" -ge 230 ] && [ "$hm" -lt 630 ] && { why="${why:+$why; }it could not finish before the 06:00 memory handback"; key="${key}clock"; }
  if [ -n "$why" ]; then
    rm -f "$OUT" "$OUT.head"
    if [ "$hm" -ge 2200 ] || [ "$hm" -lt 230 ]; then nx=$(( $(date +%s) + 1800 )); nt="in 30 minutes"; else nx=$(date -d "22:30" +%s); nt="at 22:30"; fi
    ST="${CQ_STATE:-$R/tools/handoff/nightly/state.txt}"
    case "$OUT" in "$S"/corpus-*) [ -f "$ST" ] && grep -v '^corpus_head=\|^corpus_t=' "$ST" > "$ST.cq" && echo "corpus_t=$(( nx - 14400 ))" >> "$ST.cq" && mv -f "$ST.cq" "$ST";; esac
    RF="${CQ_RF:-$S/corpus-refused.txt}"
    [ "$(cat "$RF" 2>/dev/null)" = "$key" ] || { echo "$key" > "$RF"; echo "$(date +%H:%M) corpus not started: $why; next try $nt" >> "${CQ_LOG:-$R/tools/handoff/nightly/nightly.log}"; }
    echo "NOT STARTED: $why"; exit 0
  fi
  rm -f "${CQ_RF:-$S/corpus-refused.txt}"
fi
cp -f tools/fixture.html tools/fxcorpus.html || { echo "NO FIXTURE TO COPY"; exit 1; }
export FX=fxcorpus.html
powershell -NoP -ep Bypass -File tools/cdp.ps1 -Port 9344 -Close >/dev/null; powershell -NoP -ep Bypass -File tools/cdp.ps1 -Start -Port 9344 -Profile "$TEMP/pillagers-cdp9344" >/dev/null #10-21     
powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 -Open "http://localhost:8806/fxcorpus.html?count=1" >/dev/null; sleep 30
N=$(powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 -Match "count=1" -TimeoutSec 60 -Expr "String(window.__REGRESS?window.__REGRESS.length:0)" 2>/dev/null | tail -1 | tr -dc '0-9')
[ -z "$N" -o "$N" = "0" ] && { echo "COULD NOT READ THE CORPUS SIZE"; exit 1; }
# 10-20 00:05: the count tab stayed open the whole run (about 300 MB of the 10 GB VM for 3.5 hours); close it once the size is read
id=$(curl -s -m 5 http://127.0.0.1:9344/json | grep -B4 "fxcorpus.html?count=1" | grep '"id"' | sed 's/.*"id": "\([^"]*\)".*/\1/' | head -1); [ -n "$id" ] && curl -s -m 5 "http://127.0.0.1:9344/json/close/$id" >/dev/null
echo "corpus: $N checks on $(git log -1 --format=%h) -> $OUT"
bash tools/corpus-slices.sh "$OUT" 0 "$N" 120
echo "--- FAILS:"; grep -i "FAIL\|threw\|TIMEOUT" "$OUT" | head -40
