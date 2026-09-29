#!/bin/bash
# Low-token polish pass: two-player soaks then bot crash sweeps; prints one summary plus details of failures only.
H="C:\claudecode\dark raiders\tools\handoff"; SL="C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad\soakloop.ps1"
[ -f "$(cygpath -u "$SL")" ] || SL="$H\soakloop.ps1"
curl -s -m 3 http://127.0.0.1:9335/json/version >/dev/null || powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\cdp.ps1" -Start -Port 9335 -Profile "$TEMP\pillagers-cdp9335" >/dev/null 2>&1
S=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$SL" -Runs ${1:-6} -Soak 180 2>/dev/null)
np=$(echo "$S" | grep -c '"pass":true'); nt=$(echo "$S" | grep -c '^run')
echo "two-player soak: $np of $nt passed"; echo "$S" | grep '"pass":false' | cut -c1-600
powershell -NoProfile -ExecutionPolicy Bypass -File "$H\botsweep.ps1" -Cdp 9336 -Port 8804 -From ${2:-7000} -N 200 -Map 0 >/dev/null 2>&1
powershell -NoProfile -ExecutionPolicy Bypass -File "$H\botsweep.ps1" -Cdp 9337 -Port 8805 -From ${2:-7000} -N 100 -Map 1 >/dev/null 2>&1
bash "C:/claudecode/dark raiders/tools/handoff/watchbots.sh" 1200 "9336 9337" | grep '^{' | cut -c1-600
for p in 9335 9336 9337; do for id in $(curl -s -m 3 http://127.0.0.1:$p/json | grep -B3 '"type": "page"' | grep -o '"id": "[^"]*"' | cut -d'"' -f4); do curl -s -m 3 http://127.0.0.1:$p/json/close/$id >/dev/null; done; done
