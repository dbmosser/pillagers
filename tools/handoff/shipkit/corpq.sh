#!/bin/bash
# corpq.sh OUT.txt : the full regression corpus on corpus Chrome 9344. Prints the FAIL lines at the end. Takes 2.5 to 3.5 hours.
# 10-17 evening (his "check all your stuff to see if there are other misestimates like this"): it used to HOLD THE SHIP LOCK the
# whole time (3.5 hours on 10-17, 12:53 to 16:23), so no helper could ship. It now tests a frozen copy of the fixture
# (tools/fxcorpus.html, taken at the start), so ships can rebuild tools/fixture.html meanwhile, and it takes no lock. Its Chrome
# (9344) has its own profile, so its storage never meets the gate Chrome's.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; OUT="${1:-$S/corpus-belt.txt}"
cd "$R" || exit 1
cp -f tools/fixture.html tools/fxcorpus.html || { echo "NO FIXTURE TO COPY"; exit 1; }
export FX=fxcorpus.html
curl -s --max-time 3 http://127.0.0.1:9344/json/version >/dev/null || powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9344 -Profile "$TEMP/pillagers-cdp9344" >/dev/null
powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 -Open "http://localhost:8806/fxcorpus.html?count=1" >/dev/null; sleep 30
N=$(powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 -Match "count=1" -TimeoutSec 60 -Expr "String(window.__REGRESS?window.__REGRESS.length:0)" 2>/dev/null | tail -1 | tr -dc '0-9')
[ -z "$N" -o "$N" = "0" ] && { echo "COULD NOT READ THE CORPUS SIZE"; exit 1; }
echo "corpus: $N checks on $(git log -1 --format=%h) -> $OUT"
bash tools/corpus-slices.sh "$OUT" 0 "$N" 120
echo "--- FAILS:"; grep -i "FAIL\|threw\|TIMEOUT" "$OUT" | head -40
