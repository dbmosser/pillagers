#!/bin/bash
# health.sh : one cheap sweep of everything that keeps PILLAGERS moving, fixing the simple things on the spot (2026-10-19, after he
# had to chase me: the ship gate browser was dead for 13 hours and nobody noticed). Run by the coordinator on every check-in.
#   bash tools/health.sh        report + auto-fix          bash tools/health.sh --dry   report only
# Auto-fixes (all safe to repeat): the ship gate Chrome 9346, the dashboard server 8820, the Google bug checker loop
# (ship-review.ps1 -Engine agy), the ChatGPT lane when an o-* job waits. It never touches :8802, never ships, never edits the game.
# Prints "PROBLEM:" lines for what needs the coordinator. ASCII only.
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; C="$H/console"; FIX=1; [ "$1" = --dry ] && FIX=0
SP="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
now=$(date +%s); P=0
prob(){ echo "PROBLEM: $*"; P=$((P+1)); }
up(){ curl -s -m 3 -o /dev/null "http://127.0.0.1:$1/$2" 2>/dev/null; }
procs=$(powershell -NoProfile -Command "Get-CimInstance Win32_Process | ForEach-Object { \$_.CommandLine }" 2>/dev/null | tr -d '\r')
has(){ printf '%s\n' "$procs" | grep -Eq "$1"; }

echo "== health $(date '+%m-%d %H:%M')"
# 1 ships
cd "$R" || exit 1
lt=$(git log -1 --format=%ct master 2>/dev/null); age=$(( (now-lt)/60 ))
echo "last ship: $(git log -1 --format='%s' master | cut -c1-70) ($age min ago)"
[ $age -gt 180 ] && prob "nothing shipped for $((age/60)) h"
# 2 the ship gate browser
if up 9346 json/version; then echo "gate browser 9346: up"
else if [ $FIX = 1 ]; then powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port 9346 >/dev/null 2>&1; up 9346 json/version && echo "gate browser 9346: was down, STARTED" || prob "gate browser 9346 down and would not start"; else prob "gate browser 9346 down"; fi; fi
# 3 the runner
hb="$H/nightly/runner.heartbeat"; if [ -f "$hb" ]; then ha=$(( (now-$(date -r "$hb" +%s))/60 )); echo "runner heartbeat: $ha min ago"; [ $ha -gt 20 ] && prob "runner heartbeat is $ha min old"; else prob "no runner heartbeat file"; fi
# 4 helpers
for f in "$C"/status-*.txt; do l=${f##*status-}; l=${l%.txt}; echo "lane $l: $(head -c 150 "$f" | tr -d '\r\n')"; done
nf=$(find "$C/failed" -name '*.md' -mmin -120 2>/dev/null | wc -l); [ "$nf" -gt 0 ] && prob "$nf job(s) went to failed/ in the last 2 h: $(find "$C/failed" -name '*.md' -mmin -120 -printf '%f ' 2>/dev/null)"
echo "jobs waiting: $(ls "$C/tasks/"*.md 2>/dev/null | wc -l); STOP: $([ -f "$C/STOP" ] && echo ON || echo off)"
# 5 the full test run
cl=$(grep "newly failing" "$H/nightly/nightly.log" 2>/dev/null | tail -1 | grep -o '[0-9]* check(s) newly failing' | head -1)
[ -n "$cl" ] && { echo "full test run: $cl"; n=${cl%% *}; [ "${n:-0}" -gt 10 ] && prob "full test run says $cl"; }
# 6 ChatGPT lane
if has 'codex-lane\.sh'; then echo "chatgpt lane: running ($(head -c 90 "$C/status-o.txt" | tr -d '\r\n'))"
elif ls "$C/tasks/o-"*.md >/dev/null 2>&1 && [ ! -f "$H/codex/STOP" ] && [ ! -f "$C/STOP" ]; then
  if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath 'C:\Program Files\Git\bin\bash.exe' -ArgumentList '\"$SP/start-codex-lane.sh\"' -WindowStyle Hidden" && echo "chatgpt lane: an o- job waited, STARTED"; else prob "chatgpt lane idle with an o- job waiting"; fi
else echo "chatgpt lane: idle (no o- job)"; fi
# 7 Google bug checker
if has 'ship-review\.ps1.*-Engine agy'; then echo "google checker: running ($(head -c 80 "$H/ship-review/status-agy.txt" 2>/dev/null | tr -d '\r\n'))"
else if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','\"C:\claudecode\dark raiders\tools\ship-review.ps1\"','-Engine','agy','-Loop','-EveryMin','20' -WindowStyle Hidden" && echo "google checker: was down, STARTED"; else prob "google checker not running"; fi; fi
# 7b the local AI reviewer (Ollama). 10-19: nothing restarted it, so it sat idle all afternoon. It rests by itself in his PC hours and
# when the PC has under 11 GB free (the model takes about 4 GB of the PC's memory even on the graphics card).
if has 'ship-review\.ps1.*-Engine ollama'; then echo "local AI reviewer: running ($(head -c 90 "$H/ship-review/status-ollama.txt" 2>/dev/null | tr -d '\r\n'))"
else if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','\"C:\claudecode\dark raiders\tools\ship-review.ps1\"','-Engine','ollama','-Loop','-EveryMin','20' -WindowStyle Hidden" && echo "local AI reviewer: was down, STARTED"; else prob "local AI reviewer not running"; fi; fi
grep -hE "BUG|CHECKED" "$H/ship-review/findings.txt" 2>/dev/null | tail -3 | sed 's/^/  checker lead: /' | cut -c1-200
# 8 dashboard
if up 8820 api; then echo "dashboard 8820: up"; else if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath node -ArgumentList 'server.mjs' -WorkingDirectory 'C:\claudecode\dark raiders\tools\devdash' -WindowStyle Hidden"; echo "dashboard 8820: was down, STARTED"; else prob "dashboard down"; fi; fi
# 9 RAM floor
fm=$(powershell -NoProfile -Command "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB)" 2>/dev/null | tr -d '\r'); echo "free RAM: ${fm} GB"; rf=$(grep -m1 "^RAM_FLOOR_GB=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -dc "0-9"); rf=${rf:-6}; [ "${fm:-9}" -lt "$rf" ] && prob "free RAM ${fm} GB is under the ${rf} GB floor (RAM_FLOOR_GB in console/caps.txt)"
# 10 the saved build scripts (tools/pipeline-scratch, his 10-20 "save the 12 build scripts into the GitHub project"). The scratchpad copies
# are the live ones: copy any that changed, never one that looks like it holds a key, and flag the copy so the coordinator commits it.
PSC="$R/tools/pipeline-scratch"; ch=""
for f in "$PSC"/*.sh "$PSC"/*.ps1; do b=${f##*/}; [ -f "$SP/$b" ] || continue; cmp -s "$f" "$SP/$b" && continue
  if grep -Eq 'sk-[A-Za-z0-9_-]{20}|AIza[0-9A-Za-z_-]{30}|gh[po]_[0-9A-Za-z]{30}|xox[abp]-[0-9A-Za-z-]{10}' "$SP/$b"; then prob "the live $b looks like it holds a key: not copied"; continue; fi
  [ $FIX = 1 ] && cp "$SP/$b" "$f"; ch="$ch $b"; done
[ -n "$ch" ] && echo "saved build scripts:$ch $([ $FIX = 1 ] && echo 'refreshed' || echo 'differ')"
[ -n "$(git status --porcelain -- tools/pipeline-scratch 2>/dev/null)" ] && prob "the saved build scripts in tools/pipeline-scratch are not committed"
echo "== $P problem(s)"
