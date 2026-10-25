#!/bin/bash
# checkin.sh : the coordinator check-in's steps 1 to 4 in one call, printed short (10-25, his "try to figure out what else you can do
# to be more efficient"). Each check-in used to be four to six tool calls with long outputs in a long chat; this prints only what
# needs a look, then one VERDICT line. Read-only: it starts, stops and changes nothing.
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; C="$H/console"; cd "$R" || exit 1
look=0; say(){ echo "$*"; }; flag(){ echo "LOOK: $*"; look=1; }
hn=$(hostname); st=$(grep -m1 '^status=' /c/PillagersMove/kit/host-stopped.txt 2>/dev/null | cut -d= -f2)
if [ "$hn" = "JUL26" ] || [ "$st" != "stopped" ]; then echo "STOP EVERYTHING: host=$hn host-stopped status=${st:-missing}"; echo "VERDICT: STOP"; exit 0; fi
say "machine: $hn, main PC stopped"
vv=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\PillagersMove\kit\vm-verify.ps1' -NoNetwork 2>&1)
say "vm-verify: $(echo "$vv" | grep -m1 '^SUMMARY' | sed 's/SUMMARY: //')"
echo "$vv" | grep '^\[FAIL' | while read -r l; do echo "LOOK: $l"; done; echo "$vv" | grep -q '^\[FAIL' && look=1
hs=$(bash tools/health.sh 2>&1)
echo "$hs" | grep '^PROBLEM' | grep -v 'full test run says' | while read -r l; do echo "LOOK: $l"; done
echo "$hs" | grep '^PROBLEM' | grep -qv 'full test run says' && look=1
say "$(echo "$hs" | grep -m1 '^full test run:')  (known reds are queued as jobs 113 to 113d)"
for l in a b c; do say "lane $l: $(head -c 140 "$C/status-$l.txt" 2>/dev/null | tr -d '\r\n')"; done
say "$(echo "$hs" | grep -m1 '^jobs waiting')"
ram=$(echo "$hs" | grep -m1 '^free RAM' | tr -dc '0-9'); say "free RAM: ${ram:-?} GB, $(echo "$hs" | grep -m1 '^free virtual' | sed 's/free virtual memory: //') virtual"
[ -n "$ram" ] && [ "$ram" -lt 2 ] && flag "free RAM under 2 GB: stop the newest helper"
pu=$(cat "$C/plan-usage.txt" 2>/dev/null); wk=$(echo "$pu" | awk '{print $2}')
ln=$(grep -ho 'line is at [0-9.]*%' "$C"/status-[abc].txt 2>/dev/null | head -1 | sed 's/line is at //')
say "usage: week ${wk:-?}%, line ${ln:-? (no lane is pacing)}; 5-hour $(echo "$pu" | awk '{print $1}')%"
# 10-25 05:10: 112r reran 6 times in 25 minutes on a wait for a job that did not exist. Flag any job with 4 or more runs in an
# hour, and any job a lane parked in waiting/ for the coordinator.
since=$(date -d '-60 min' '+%m-%d %H:%M'); rr=$(awk -v s="$since" '($1" "$2)>=s && /\$[0-9]/{n=$3; sub(/:$/,"",n); c[n]++} END{for(k in c) if(c[k]>=4) printf "%s (%d runs) ", k, c[k]}' "$C/runs.log" 2>/dev/null)
[ -n "$rr" ] && flag "job(s) rerunning: $rr"
for j in $(grep -o '^- [a-z0-9-]*\.md (parked [0-9-]* [0-9:]* by lane' "$C/waiting/README.md" 2>/dev/null | cut -d' ' -f2 | sort -u); do [ -f "$C/waiting/$j" ] && flag "parked for me: $j ($(grep -F -- "- $j (parked" "$C/waiting/README.md" | tail -1 | cut -d: -f3- | cut -c1-140))"; done
today=$(date +%F); nf=$(find "$C/failed" -type f -newermt "-2 hours" 2>/dev/null | wc -l); [ "$nf" -gt 0 ] && flag "$nf job(s) failed in the last 2 hours: $(ls -t "$C/failed" | head -$nf | tr '\n' ' ')"
rp=$(grep "^$today .*problems=[1-9]" "$H/fuzz/fuzz.log" 2>/dev/null | wc -l); [ "$rp" -gt 0 ] && flag "robots: $rp raid(s) today with problems; newest: $(grep "^$today .*problems=[1-9]" "$H/fuzz/fuzz.log" | tail -1 | cut -c1-120)"
say "robots today: $(grep -c "^$today .* raid [0-9]" "$H/fuzz/fuzz.log" 2>/dev/null) raids, $rp with problems; last: $(tail -1 "$H/fuzz/fuzz.log" | cut -c1-19)"
grep -E "^$(date +%m-%d) |^[0-9][0-9]:[0-9][0-9] " "$H/nightly/nightly.log" 2>/dev/null | tail -60 | grep -iE "fail|error|stuck|not started|hang|timeout" | grep -v "stable: no change" | tail -3 | cut -c1-150 | while read -r l; do echo "night log: $l"; done
say "newest build: $(grep -m1 "^var VER='" dark_raiders.html | sed "s/var VER='\([0-9.]*\)'.*/v\1/"), last commit $(git log -1 --format='%cr')"
[ $look = 1 ] && echo "VERDICT: LOOK (lines above)" || echo "VERDICT: ALL CLEAR"
