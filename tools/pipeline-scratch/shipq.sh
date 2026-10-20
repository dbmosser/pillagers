#!/bin/bash
# shipq.sh KEY : ship one draft through the gate, queued behind any other ship.
# Waits for the lock, reads VER from the game file to choose PREV and NEW, regenerates the draft from
# scratchpad mk-KEY.ps1 against the current HEAD, runs shipone.sh on gate Chrome 9346, cleans the
# leftovers of a STOP, releases the lock and prints the last lines. Safe for several callers at once.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; K=$1; LK="$S/shipq.lock"; LOG="$S/shipq.log"
[ -z "$K" ] && { echo "usage: shipq.sh KEY"; exit 2; }
[ -f "$S/mk-$K.ps1" ] || { echo "NO mk-$K.ps1 in the scratchpad"; exit 2; }
sleep 6   # 10-15: a fair queue; a chain that calls again at once no longer beats callers polling every 5 s
n=0; until mkdir "$LK" 2>/dev/null; do sleep 5; n=$((n+1)); [ $n -gt 1440 ] && { echo "LOCK TIMEOUT (2 h)"; exit 3; }; done
trap 'rmdir "$LK" 2>/dev/null' EXIT
echo "$$ $K $(date +%H:%M:%S)" > "$S/shipq.owner"
cd "$R" || exit 1
ver=$(grep -m1 "^var VER='" dark_raiders.html | sed "s/var VER='\([0-9]*\)\.\([0-9]*\)'.*/\1\2/")
v=$ver; nw=$((v+1))
if ! powershell -NoProfile -ExecutionPolicy Bypass -File "$S/mk-$K.ps1" >/dev/null 2>"$S/mkerr-$K.txt"; then
  m="$(date +%H:%M) $K: MK FAIL $(head -c 600 "$S/mkerr-$K.txt" | tr '\r\n' '  ')"; echo "$m" >> "$LOG"; echo "$m"; exit 1
fi
out=$(GATE_CDP=9346 bash tools/handoff/shipone.sh "$K" "$v" "$nw" 2>&1 | grep -v '^warning')
if echo "$out" | grep -q "^SHIPPED"; then
  echo "$(date +%H:%M) $K: SHIPPED v${nw:0:2}.${nw:2}" >> "$LOG"; echo "$out" | tail -4
else
  echo "$(date +%H:%M) $K: STOP $(echo "$out" | grep "^STOP" | tail -1 | cut -c1-300)" >> "$LOG"
  rm -f tools/handoff/a$nw.txt tools/handoff/cm$nw.txt tools/handoff/d$nw.txt tools/handoff/f$nw.ps1 tools/handoff/p$nw.ps1; rm -rf "$TEMP/pillagers-dry/dry$nw"
  echo "$out" | tail -12
fi
