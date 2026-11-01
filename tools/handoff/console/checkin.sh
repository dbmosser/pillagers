#!/bin/bash
# checkin.sh : the coordinator check-in's steps 1 to 4 in one call, printed short (10-25, his "try to figure out what else you can do
# to be more efficient"). Each check-in used to be four to six tool calls with long outputs in a long chat; this prints only what
# needs a look, then one VERDICT line. Read-only: it starts, stops and changes nothing.
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; C="$H/console"; cd "$R" || exit 1
look=0; say(){ echo "$*"; }; flag(){ echo "LOOK: $*"; look=1; }
hn=$(hostname); st=$(grep -m1 '^status=' /c/PillagersMove/kit/host-stopped.txt 2>/dev/null | cut -d= -f2)
if [ "$hn" = "JUL26" ] || [ "$st" != "stopped" ]; then echo "STOP EVERYTHING: host=$hn host-stopped status=${st:-missing}"; echo "VERDICT: STOP"; exit 0; fi
# 11-01 (CEO): this line said "main PC stopped" every time. It reads host-stopped.txt, the 10-19 hand-over note that says dev moved off
# the main PC to this VM (status=stopped there means "the VM may run the helpers"), not whether the main PC works. Its real state is now
# asked over the bridge (main-status) on the next line.
say "machine: $hn (dev handed over from the main PC 10-19, host-stopped.txt)"
ms=$(timeout 60 node tools/bridge/hostctl.mjs main-status 2>/dev/null | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const j=JSON.parse(s.slice(s.indexOf('{')));const st=((j.runner||{}).status||[]);const g=k=>((st.find(x=>x.startsWith(k+'='))||'').slice(k.length+1));const r=j.receiver8799||{};
console.log([j.ok?'up':'answers but not ok', 'plays v'+((j.play8802||{}).ver||'?')+' on 8802', 'runner '+(g('mode')||'?')+' (heartbeat '+((j.runner||{}).heartbeatAgeSec??'?')+' s)', g('soak')||'soak ?', 'collector 8799 '+(r.up?'up':'DOWN')].join(', '))}catch(e){}})")
if [ -z "$ms" ]; then say "main PC: the bridge did not answer (main PC off or asleep?)"
else say "main PC: $ms"; case "$ms" in *"collector 8799 DOWN"*) flag "the run-report collector (8799) on the main PC is down";; esac
  printf '%s' "$ms" | grep -q 'soak v[0-9.]*: 0 of [1-9]' && flag "main PC 2 player soak passes 0 runs (job 01-260-main-pc-2p-soak-broken)"; fi
vv=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -File 'C:\PillagersMove\kit\vm-verify.ps1' -NoNetwork 2>&1)
say "vm-verify: $(echo "$vv" | grep -m1 '^SUMMARY' | sed 's/SUMMARY: //')"
# 11-01 (CEO): the collector on 8799 runs on the MAIN PC (main-status above checks it), so vm-verify's "port 8799 answers" FAIL in the VM is a false alarm
vf=$(echo "$vv" | grep '^\[FAIL' | grep -v 'port 8799 answers')
[ -n "$vf" ] && { while read -r l; do echo "LOOK: $l"; done <<< "$vf"; look=1; }
hs=$(bash tools/health.sh 2>&1)
echo "$hs" | grep '^PROBLEM' | grep -v 'full test run says' | while read -r l; do echo "LOOK: $l"; done
echo "$hs" | grep '^PROBLEM' | grep -qv 'full test run says' && look=1
rj=$(for f in "$C/tasks/"*-reds.md; do [ -f "$f" ] && basename "$f" | sed 's/-.*//'; done | paste -sd' ')
say "$(echo "$hs" | grep -m1 '^full test run:')  (red-fix jobs waiting: ${rj:-none})"
for l in a b c; do say "lane $l: $(head -c 140 "$C/status-$l.txt" 2>/dev/null | tr -d '\r\n')"; done
say "$(echo "$hs" | grep -m1 '^jobs waiting')"
ram=$(echo "$hs" | grep -m1 '^free RAM' | tr -dc '0-9'); say "free RAM: ${ram:-?} GB, $(echo "$hs" | grep -m1 '^free virtual' | sed 's/free virtual memory: //') virtual"
[ -n "$ram" ] && [ "$ram" -lt 2 ] && flag "free RAM under 2 GB: stop the newest helper"
pu=$(cat "$C/plan-usage.txt" 2>/dev/null); wk=$(echo "$pu" | awk '{print $2}')
# 11-01 (CEO): the line came only from a lane status that was pacing, so it said "line ?" most of the time. It is now worked out here
# from caps.txt the same way tools/console-lane.sh does (WEEK_RESET, PLAN_TARGET, PLAN_LINE_END, PLAN_LINE_START/FROM/TARGET).
cap(){ v=$(grep -m1 "^$1=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r '); echo "${v:-$2}"; }
nw=$(date +%s); WR=$(date -d "$(cap WEEK_RESET 2026-10-25T05:00:00Z)" +%s); while [ "$nw" -ge "$WR" ]; do WR=$((WR+604800)); done; ws=$((WR-604800))
tg=$(cap PLAN_TARGET 85); ln=$(awk -v r="$WR" -v n="$nw" -v t="$tg" 'BEGIN{printf "%.1f", (1-(r-n)/604800)*t}')
le=""; [ -n "$(cap PLAN_LINE_END "")" ] && le=$(date -d "$(cap PLAN_LINE_END "")" +%s 2>/dev/null)
lst=""; [ -n "$(cap PLAN_LINE_START "")" ] && lst=$(date -d "$(cap PLAN_LINE_START "")" +%s 2>/dev/null)
if [ -n "$le" ] && [ "$le" -gt "$ws" ] && [ "$le" -lt "$WR" ]; then
  ln=$(awk -v s="$ws" -v e="$le" -v n="$nw" -v t="$tg" 'BEGIN{f=(n-s)/(e-s); if(f>1)f=1; if(f<0)f=0; printf "%.1f", f*t}')
  if [ -n "$lst" ] && [ "$lst" -ge "$ws" ] && [ "$lst" -lt "$le" ]; then tg=$(cap PLAN_LINE_TARGET "$tg")
    ln=$(awk -v s="$lst" -v e="$le" -v n="$nw" -v t="$tg" -v f0="$(cap PLAN_LINE_FROM 0)" 'BEGIN{f=(n-s)/(e-s); if(f>1)f=1; if(f<0)f=0; printf "%.1f", f0+f*(t-f0)}'); fi; fi
pa=$(( (nw - $(echo "$pu" | awk '{print $3+0}')) / 60 ))
say "usage: week ${wk:-?}%, the ${tg}% line is at $ln% now; 5-hour $(echo "$pu" | awk '{print $1}')% (read $pa min ago)"
# 11-01 (CEO): plan-usage.txt (session %, week %, epoch) sat 5 h old while the lanes waited; flag it over 3 hours
[ "$pa" -gt 180 ] && flag "plan-usage.txt is $((pa / 60)) h old (lanes refresh it only when one gets past the RAM and memory checks)"
# 10-25 05:10: 112r reran 6 times in 25 minutes on a wait for a job that did not exist. Flag any job with 4 or more runs in an
# hour, and any job a lane parked in waiting/ for the coordinator.
since=$(date -d '-60 min' '+%m-%d %H:%M'); rr=$(awk -v s="$since" '($1" "$2)>=s && /\$[0-9]/{n=$3; sub(/:$/,"",n); c[n]++} END{for(k in c) if(c[k]>=4) printf "%s (%d runs) ", k, c[k]}' "$C/runs.log" 2>/dev/null)
[ -n "$rr" ] && flag "job(s) rerunning: $rr"
# 11-01 (CEO): 06:34 to 07:47, 42 runs at $0 each spent a job's try before anyone saw it; flag 3 or more $0 runs in the last hour
z0=$(awk -v s="$since" '($1" "$2)>=s && (/, \$0(\.0+)?$/ || /\$0 run ended/)' "$C/runs.log" 2>/dev/null | wc -l)
[ "$z0" -ge 3 ] && flag "$z0 runs at \$0 in the last hour (budget, sign-in or usage limit?): $(awk -v s="$since" '($1" "$2)>=s && (/, \$0(\.0+)?$/ || /\$0 run ended/)' "$C/runs.log" | tail -1 | cut -c1-120)"
# 11-01 (CEO): jobs parked in waiting/ for more than 48 h, by name (10 sat there 2 to 11 days unseen)
ow=$(find "$C/waiting" -maxdepth 1 -name '*.md' ! -name README.md -mmin +2880 2>/dev/null | sed 's#.*/##' | sort | paste -sd' ')
[ -n "$ow" ] && flag "waiting/ over 48 h: $ow"
for j in $(grep -o '^- [a-z0-9-]*\.md (parked [0-9-]* [0-9:]* by lane' "$C/waiting/README.md" 2>/dev/null | cut -d' ' -f2 | sort -u); do [ -f "$C/waiting/$j" ] && flag "parked for me: $j ($(grep -F -- "- $j (parked" "$C/waiting/README.md" | tail -1 | cut -d: -f3- | cut -c1-140))"; done
today=$(date +%F); nf=$(find "$C/failed" -type f -newermt "-2 hours" 2>/dev/null | wc -l); [ "$nf" -gt 0 ] && flag "$nf job(s) failed in the last 2 hours: $(ls -t "$C/failed" | head -$nf | tr '\n' ' ')"
rp=$(grep "^$today .*problems=[1-9]" "$H/fuzz/fuzz.log" 2>/dev/null | wc -l); [ "$rp" -gt 0 ] && flag "robots: $rp raid(s) today with problems; newest: $(grep "^$today .*problems=[1-9]" "$H/fuzz/fuzz.log" | tail -1 | cut -c1-120)"
say "robots today: $(grep -c "^$today .* raid [0-9]" "$H/fuzz/fuzz.log" 2>/dev/null) raids, $rp with problems; last: $(tail -1 "$H/fuzz/fuzz.log" | cut -c1-19)"
grep -E "^$(date +%m-%d) |^[0-9][0-9]:[0-9][0-9] " "$H/nightly/nightly.log" 2>/dev/null | tail -60 | grep -iE "fail|error|stuck|not started|hang|timeout" | grep -v "stable: no change" | tail -3 | cut -c1-150 | while read -r l; do echo "night log: $l"; done
# 10-27 night: the spare PC finished a full run every 1.5 h all day, each with 8 to 12 newly red checks, and nothing here said so (the
# "stable: no change" lines are filtered above), so stable sat at v34.53 for 19 hours. (Spare PC robot hangs are left out: on its 4 threads
# under a full run most are the machine choking, not the game; stable.mjs already weighs robot problems per version.)
nb=$(sed -n '/^Checks that are newly red/,$p' "$H/stable-status.txt" 2>/dev/null | grep -c "^  v")
[ "${nb:-0}" -gt 0 ] && flag "$nb newly red check(s) block stable ($(grep -m1 "^Latest stable" "$H/stable-status.txt" | cut -c1-50)): outdated ones go in tools/handoff/stable-known-red.txt, real ones become fix jobs"
# 10-27 night: Codex (lane o) takes only o-* jobs, sat near 2% of its week with 5 days left, and said "no tasks left" while 30+ fix jobs
# waited for Claude. Flag it whenever fewer than 5 o-* jobs are queued while its week has room. The meter is the newest line of
# codex/limits.txt (codex-lane.sh adds one after every Codex run: week %, 5-hour %, week reset). No line yet means no meter, so just flag
# under 5. A week 90% or more used is no room; a reset time already past means the week turned over, so the old percent is stale (room).
nq=$(ls "$C/tasks/"o-*.md 2>/dev/null | wc -l); xl=$(tail -1 "$H/codex/limits.txt" 2>/dev/null)
xw=$(echo "$xl" | grep -o 'week=[0-9.]*' | head -1 | cut -d= -f2); xr=$(echo "$xl" | grep -o 'week_resets=[0-9-]* [0-9:]*' | head -1 | cut -d= -f2)
[ -n "$xr" ] && [ "$(date -d "$xr" +%s 2>/dev/null || echo 9999999999)" -le "$(date +%s)" ] && xw=""
say "codex: $nq o-* job(s) queued, week ${xw:-?}% used${xr:+ (resets $xr)}"
xroom=1; [ -n "$xw" ] && awk -v w="$xw" 'BEGIN{exit !(w+0>=90)}' && xroom=0
[ "${nq:-0}" -lt 5 ] && [ "$xroom" = 1 ] && flag "Codex has only $nq o-* job(s) queued (under 5)${xw:+ and its week is $xw% used}: rename more fix jobs that need no fixq or mkfixture retarget, no live measuring, soak or saved profile to o-NAME.md in tasks/, party ones first"
say "newest build: $(grep -m1 "^var VER='" dark_raiders.html | sed "s/var VER='\([0-9.]*\)'.*/v\1/"), last commit $(git log -1 --format='%cr')"
[ $look = 1 ] && echo "VERDICT: LOOK (lines above)" || echo "VERDICT: ALL CLEAR"
