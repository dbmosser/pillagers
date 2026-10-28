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
# 10-27: the lanes rest on purpose while the week is over its line; a quiet master is expected then, not a stall
if [ $age -gt 180 ]; then
  rest=1; for x in a b c; do f="$C/status-$x.txt"; { [ -f "$f" ] && [ $(( now - $(stat -c %Y "$f") )) -lt 1800 ] && head -1 "$f" | grep -q '^[0-9-]* [0-9:]* pacing your plan'; } || rest=0; done
  if [ $rest = 1 ]; then echo "nothing shipped for $((age/60)) h: lanes resting, the week is ahead of its line ($(head -1 "$C/status-a.txt" | grep -o 'week [0-9]*% used'))"
  else prob "nothing shipped for $((age/60)) h"; fi
fi
# 2 the ship gate browser
if up 9346 json/version; then echo "gate browser 9346: up"
else if [ $FIX = 1 ]; then powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port 9346 >/dev/null 2>&1; up 9346 json/version && echo "gate browser 9346: was down, STARTED" || prob "gate browser 9346 down and would not start"; else prob "gate browser 9346 down"; fi; fi
# 2b 10-24: the gate browser grows with every ship (2.7 GB after ten ships on 10-24, which held the 10 GB VM at 1 GB free and kept
# the helpers from starting). Over 1500 MB and no ship or gate running: restart it (a fresh one is about 350 MB).
gm=$(powershell -NoProfile -Command "\$t=0; Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -match 'remote-debugging-port=9346(\s|\$)' } | ForEach-Object { \$t+=\$_.WorkingSetSize }; [int](\$t/1MB)" 2>/dev/null | tr -dc '0-9')
if [ "${gm:-0}" -gt 1500 ]; then
  gb=$(powershell -NoProfile -Command "@(Get-CimInstance Win32_Process | Where-Object { \$_.Name -match '^(bash|powershell)\.exe$' -and \$_.CommandLine -match 'shipone\.sh|[^(]ship\.sh|preflight\.sh|gate\.ps1|slicechk\.sh' }).Count" 2>/dev/null | tr -dc '0-9')
  curl -s -m 3 http://127.0.0.1:9346/json 2>/dev/null | grep -q '"url": *"http' && gb=1
  if [ "${gb:-1}" != 0 ]; then echo "gate browser 9346: ${gm} MB, kept (a ship or gate is running)"
  elif [ $FIX = 1 ]; then powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -match 'remote-debugging-port=9346(\s|\$)' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1
    powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port 9346 >/dev/null 2>&1
    up 9346 json/version && echo "gate browser 9346: had grown to ${gm} MB, RESTARTED" || prob "gate browser 9346 restarted after ${gm} MB and did not come back"
  else echo "gate browser 9346: ${gm} MB (over 1500)"; fi; fi
# 3 the runner
hb="$H/nightly/runner.heartbeat"; if [ -f "$hb" ]; then ha=$(( (now-$(date -r "$hb" +%s))/60 )); echo "runner heartbeat: $ha min ago"; [ $ha -gt 20 ] && prob "runner heartbeat is $ha min old"; else prob "no runner heartbeat file"; fi
# 4 helpers
for f in "$C"/status-*.txt; do l=${f##*status-}; l=${l%.txt}; echo "lane $l: $(head -c 150 "$f" | tr -d '\r\n')"; done
nf=$(find "$C/failed" -name '*.md' -mmin -120 2>/dev/null | wc -l); [ "$nf" -gt 0 ] && prob "$nf job(s) went to failed/ in the last 2 h: $(find "$C/failed" -name '*.md' -mmin -120 -printf '%f ' 2>/dev/null)"
echo "jobs waiting: $(ls "$C/tasks/"*.md 2>/dev/null | wc -l); STOP: $([ -f "$C/STOP" ] && echo ON || echo off)"
# 5 the full test run
# 10-27 night (CEO chat): the newest full run is the first line under "Newest test runs" in stable-status.txt (the spare PC runs it); nightly.log held a stale VM run and showed 12 newly failing while the newest run had 0
cl=$(sed -n '/^Newest test runs/{n;p;q}' "$H/stable-status.txt" 2>/dev/null | sed -n 's/.*corpus-\([0-9-]*\) *\(v[0-9.]*\).*new \([0-9]*\).*/\3 check(s) newly failing (run \1 on \2)/p')
[ -z "$cl" ] && cl=$(grep "newly failing" "$H/nightly/nightly.log" 2>/dev/null | tail -1 | grep -o '[0-9]* check(s) newly failing' | head -1)
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
la=$(grep -m1 '^LOCAL_AI=' "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -dc 01)
if [ "$la" != 1 ]; then
  # 10-28: retired (caps.txt LOCAL_AI=0): a model load took the main PC to 0.2-1.8 GB free and none of its hits was real
  if has 'ship-review\.ps1.*-Engine ollama' && [ $FIX = 1 ]; then powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { \$_.ProcessId -ne \$PID -and \$_.CommandLine -match 'ship-review\.ps1.*-Engine ollama' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" >/dev/null 2>&1; echo "local AI reviewer: retired 10-28 (caps LOCAL_AI=0), stopped"
  else echo "local AI reviewer: retired 10-28 (caps LOCAL_AI=0)"; fi
elif has 'ship-review\.ps1.*-Engine ollama'; then echo "local AI reviewer: running ($(head -c 90 "$H/ship-review/status-ollama.txt" 2>/dev/null | tr -d '\r\n'))"
else if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath powershell.exe -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File','\"C:\claudecode\dark raiders\tools\ship-review.ps1\"','-Engine','ollama','-Loop','-EveryMin','20' -WindowStyle Hidden" && echo "local AI reviewer: was down, STARTED"; else prob "local AI reviewer not running"; fi; fi
grep -hE "BUG|CHECKED" "$H/ship-review/findings.txt" 2>/dev/null | tail -3 | sed 's/^/  checker lead: /' | cut -c1-200
# 8 dashboard
if up 8820 api; then echo "dashboard 8820: up"; else if [ $FIX = 1 ]; then powershell -NoProfile -Command "Start-Process -FilePath node -ArgumentList 'server.mjs' -WorkingDirectory 'C:\claudecode\dark raiders\tools\devdash' -WindowStyle Hidden"; echo "dashboard 8820: was down, STARTED"; else prob "dashboard down"; fi; fi
# 9 RAM floor
# 10-20 (coord-01): his notes and run reports from the main PC (tools/fetch-notes.mjs, every 5 min from the runner)
nf="$H/notes-fetch.txt"; [ -f "$nf" ] && echo "notes from the main PC: $(head -1 "$nf" | tr -d '' | cut -c1-160)"
# 10-20: the spare PC (tools/spare/, his "16gb ram, it can stay on and connected"); it is his machine, so a quiet one is a WAIT, never a fix here
ss="$H/spare-status.txt"
if [ ! -f "$ss" ] || grep -q "not set up yet\|no spare PC has reported" "$ss"; then echo "WAIT: spare PC not set up yet (his steps: tools/handoff/console/for-you.md)"
elif grep -q "QUIET" "$ss"; then echo "WAIT: spare PC quiet: $(head -1 "$ss" | cut -c1-160)"
# 10-28: it reports in but tests nothing new (77 hours on v34.13, 10-22 to 10-25, unflagged); tools/spare/spare-import.mjs writes STALLED
elif grep -q "^STALLED" "$ss"; then prob "spare PC stalled (it reports in but tests nothing new): $(head -1 "$ss" | sed 's/; [A-Z0-9_-]* last seen.*//' | cut -c1-260)"
else echo "spare PC: $(head -1 "$ss" | cut -c1-170)"; fi
# 10-28: the main PC runner (tools/spare/spare-runner.ps1, idle mode on JUL26) also keeps his 8802, the party copy and the bridge up, and
# a new runner it cannot read is not taken (it goes on with the old one): a silent runner, or one not on master's copy 20 minutes after
# that file changed, is a PROBLEM. runner= is the first 8 of the SHA256 of the CRLF checkout there.
ms=$(git -C "$R" cat-file blob "refs/spare-import/spare-results:spare/JUL26/status.txt" 2>/dev/null | tr -d '\r')
if [ -n "$ms" ]; then
  kv(){ printf '%s\n' "$ms" | sed -n "s/^$1=//p" | head -1; }
  me=$(kv epoch | tr -dc 0-9); ma=$(( (now - ${me:-0}) / 60 )); mr=$(kv runner | tr -dc 0-9A-F)
  mh=$(git -C "$R" show "master:tools/spare/spare-runner.ps1" 2>/dev/null | sed 's/$/\r/' | sha256sum | cut -c1-8 | tr a-f A-F)
  mt=$(git -C "$R" log -1 --first-parent --format=%ct master -- tools/spare/spare-runner.ps1 2>/dev/null)
  echo "main PC runner: $(kv test_run | cut -c1-60), robots $(kv robots), $(kv ram_free_gb) GB free, runner $mr, $ma min ago"
  [ "$ma" -gt 30 ] && prob "main PC runner silent for $ma min (it keeps 8802, the party copy and the bridge up)"
  [ "$ma" -le 30 ] && [ -n "$mh" ] && [ "$mr" != "$mh" ] && ! kv test_run | grep -q "^running" && [ $(( now - ${mt:-$now} )) -gt 1200 ] && prob "main PC runner is not on master's copy (it runs $mr, master is $mh): a new runner it could not read, or no update"
  [ -f "$H/spare/perf-4k.txt" ] && echo "4K two windows on the main PC card: $(head -1 "$H/spare/perf-4k.txt" | cut -c1-220)"
fi
fm=$(powershell -NoProfile -Command "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB)" 2>/dev/null | tr -d '\r'); echo "free RAM: ${fm} GB"; rf=$(grep -m1 "^RAM_FLOOR_GB=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -dc "0-9"); rf=${rf:-6}; [ "${fm:-9}" -lt "$rf" ] && prob "free RAM ${fm} GB is under the ${rf} GB floor (RAM_FLOOR_GB in console/caps.txt)"
# 10-21: virtual memory too. At 02:19 Windows ran out of it (31.5 of 31.9 GB) with 4 GB of RAM free and both robots hung.
fv=$(powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; '{0} {1}' -f [int](\$o.FreeVirtualMemory/1MB), [int](\$o.TotalVirtualMemorySize/1MB)" 2>/dev/null | tr -d '\r'); echo "free virtual memory: ${fv% *} GB of ${fv#* } GB"; [ "${fv% *}" -lt "$rf" ] 2>/dev/null && prob "free virtual memory ${fv% *} GB is under the ${rf} GB floor: Windows may refuse new programs (see the System log, event 2004)"
ve=$(powershell -NoProfile -Command "@(Get-WinEvent -FilterHashtable @{LogName='System'; Id=2004; StartTime=(Get-Date).AddHours(-2)} -ErrorAction SilentlyContinue).Count" 2>/dev/null | tr -dc '0-9'); [ "${ve:-0}" -gt 0 ] && prob "Windows ran low on virtual memory ${ve} time(s) in the last 2 h (System log event 2004)"
# 10 the saved build scripts (tools/pipeline-scratch, his 10-20 "save the 12 build scripts into the GitHub project"). The scratchpad copies
# are the live ones: copy any that changed, never one that looks like it holds a key, and flag the copy so the coordinator commits it.
PSC="$R/tools/pipeline-scratch"; ch=""
for f in "$PSC"/*.sh "$PSC"/*.ps1; do b=${f##*/}; [ -f "$SP/$b" ] || continue; cmp -s "$f" "$SP/$b" && continue
  if grep -Eq 'sk-[A-Za-z0-9_-]{20}|AIza[0-9A-Za-z_-]{30}|gh[po]_[0-9A-Za-z]{30}|xox[abp]-[0-9A-Za-z-]{10}' "$SP/$b"; then prob "the live $b looks like it holds a key: not copied"; continue; fi
  [ $FIX = 1 ] && cp "$SP/$b" "$f"; ch="$ch $b"; done
[ -n "$ch" ] && echo "saved build scripts:$ch $([ $FIX = 1 ] && echo 'refreshed' || echo 'differ')"
[ -n "$(git status --porcelain -- tools/pipeline-scratch 2>/dev/null)" ] && prob "the saved build scripts in tools/pipeline-scratch are not committed"
echo "== $P problem(s)"
