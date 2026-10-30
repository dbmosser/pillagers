#!/bin/bash
# console-lane.sh LANE : runs ONE Claude task from its lane, billed to his Claude Console (API) credits and never to his subscription.
# His order 2026-10-17: "how can i use my claude console credits to improve the game?", then "ok can you just do all this?",
# then "yes, build the unattended worker that spends my Console credits".
# - The key is his Windows user variable PILLAGERS_API_KEY, which he saves himself. It is read here, given only to this run's
#   claude, and never printed. It is NOT named ANTHROPIC_API_KEY, so his desktop app keeps using his subscription.
# - --bare: auth is strictly the API key (his subscription login is never read), with no hooks and no auto-memory.
#   --strict-mcp-config with no config: no MCP servers, so no browser tools.
# - LOCKED DOWN (--permission-mode dontAsk): anything not on the ALLOW list below is refused. The worker may read anything, write
#   only its own mk-cw-* scripts, its notes and the old checks file, and run only the project's ship and test scripts. It
#   cannot edit the game file, run other commands, or touch the network except through those scripts.
# - Tasks are tools/handoff/console/tasks/*.md, taken first by name. A run ending in TASK DONE moves its task to done/; after
#   3 runs without it, the task moves to failed/. Every run logs to log/ and adds its cost to spend.txt.
# - Caps (caps.txt): RUN_USD per run (--max-budget-usd) and DAY_USD per day. His Console monthly spend limit is the hard cap.
# - A file named STOP in tools/handoff/console pauses it. The always-on runner (tools/nightly.sh) starts it every 5 min when
#   it is not running and 6 GB of RAM are free.
R="/c/claudecode/dark raiders"; C="$R/tools/handoff/console"; cd "$R" || exit 1
# 10-27: caps.txt vanished from this folder twice this morning (cause not found) and every lane sat at "$0.00 allowed"; put the committed copy back
[ -f "$C/caps.txt" ] || { git show HEAD:tools/handoff/console/caps.txt > "$C/caps.txt.tmp" 2>/dev/null && mv -f "$C/caps.txt.tmp" "$C/caps.txt" && echo "$(date '+%m-%d %H:%M') caps.txt was missing at a lane start; put back from git" >> "$C/caps-restored.log"; }
L=${1:-a}   # 10-17 LANES (his "max out ... the claude console resources"): one worker per lane at once; lane a = tasks named 0-9*, lane b = b-*, lane c = c-*
LK="$C/lane-$L.lock"   # one worker per lane: a lock folder holding the pid (Git Bash pids do not show in Windows process lists)
# 10-18 06:10: CLI_ALWAYS lanes (e.g. e) always run on Claude Code on his plan, beside the Console lanes (his weekly usage was at 1%
# with the week 4% gone). The runner starts only a, b and c, so each of those starts any CLI_ALWAYS lane that is not running.
for x in $(grep -m1 "^CLI_ALWAYS=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr ",
" "  "); do
  [ "$x" = "$L" ] || [ -d "$C/lane-$x.lock" ] || (bash "$0" "$x" > /dev/null 2>&1 &); done
if ! mkdir "$LK" 2>/dev/null; then p=$(cat "$LK/pid" 2>/dev/null); [ -n "$p" ] && kill -0 "$p" 2>/dev/null && exit 0; rm -rf "$LK"; mkdir "$LK" 2>/dev/null || exit 0; fi
echo $$ > "$LK/pid"; trap 'rm -rf "$LK"' EXIT
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
M="C:/Users/User1/.claude/projects/C--Users-User1-Desktop-dark-raiders/memory"
PS="//c/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
# 10-19 VM: C:/Users/User1 is a junction to the VM own profile and Claude Code checks a write against the resolved path, so every
# mk-cw-* write was refused ("permission not granted") until the same rules also name that real path (on the main PC it is the same path).
PV="/$(cygpath -u "${USERPROFILE:-C:/Users/User1}" 2>/dev/null)${PS#//c/Users/User1}"
PR="//c/claudecode/dark raiders"
ALLOW=( "Read" "Grep" "Glob"
  "Write($PS/mk-cw-*)" "Edit($PS/mk-cw-*)" "Write($PV/mk-cw-*)" "Edit($PV/mk-cw-*)"
  "Write($PR/tools/handoff/console/notes/**)" "Edit($PR/tools/handoff/console/notes/**)"
  "Write($PR/tools/handoff/console/questions.md)" "Edit($PR/tools/handoff/console/questions.md)"
  "Write($PR/tools/handoff/console/alarms.md)" "Edit($PR/tools/handoff/console/alarms.md)"
  "Edit($PR/tools/mkfixture.ps1)"
  "Bash(bash $S/shipq.sh cw-*)" "Bash(bash $S/shipdraft.sh *)" "Bash(bash $S/fixq.sh *)" "Bash(bash $S/genP.sh *)"
  "Bash(bash $S/runchk.sh *)" "Bash(bash $S/lock.sh)" "Bash(bash $S/unlock.sh)" "Bash(bash $S/clearstale.sh)"
  "Bash(bash $S/slicechk.sh *)"   # 10-20 (job 58b): checks run in order in one page on the lane's own Chrome, to find a check that leaks state
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File $S/mk-cw-*)"
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9346)"
  "Bash(git status:*)" "Bash(git log:*)" "Bash(git diff:*)" "Bash(git show:*)"
  "Bash(bash tools/handoff/preflight.sh *)" "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 *)"
  "Bash(node tools/console-sdk/critic.mjs *)" )
mkdir -p "$C/tasks" "$C/done" "$C/failed" "$C/log" "$C/notes"
[ -f "$C/STOP" ] && { echo "$(date '+%m-%d %H:%M') paused (STOP file)" > "$C/status-$L.txt"; exit 0; }
[ -f "$C/STOP-claude" ] && { echo "$(date '+%m-%d %H:%M') paused (STOP-claude: his 10-30 order, Codex only for 2 player fixes)" > "$C/status-$L.txt"; exit 0; }
cap(){ v=$(grep -m1 "^$1=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r '); echo "${v:-$2}"; }
RUN_USD=$(cap RUN_USD 4); DAY_USD=$(cap DAY_USD 15); today=$(date +%F)
spent=$(awk -v d="$today" '$1==d {s+=$2} END {printf "%.2f", s+0}' "$C/spend.txt" 2>/dev/null); spent=${spent:-0}
if awk -v s="$spent" -v c="$DAY_USD" 'BEGIN{exit !(s+0>=c+0)}'; then
  echo "$(date '+%m-%d %H:%M') day cap reached (\$$spent of \$$DAY_USD)" > "$C/status-$L.txt"; exit 0; fi
# 10-17, his "claude console resets nov 1 so ideally we'd pace the $200 between now and launch, which is halloween": the day's
# share is what is left of TOTAL_USD over the days to END_DATE, released evenly through the day (one hour ahead), so the workers
# and the gate move all day instead of spending the day's share in its first hour.
TOTAL=$(cap TOTAL_USD 190); END=$(cap END_DATE 2026-10-31)
before=$(awk -v d="$today" '$1<d {s+=$2} END {printf "%.2f", s+0}' "$C/spend.txt" 2>/dev/null)
dl=$(( ( $(date -d "$END" +%s) - $(date -d "$today" +%s) ) / 86400 + 1 )); [ "$dl" -lt 1 ] && dl=1
mins=$(( 10#$(date +%H) * 60 + 10#$(date +%M) + 60 ))
read DAY_USD allow < <(awk -v t="$TOTAL" -v b="${before:-0}" -v d="$dl" -v m="$mins" -v g="$DAY_USD" 'BEGIN{c=(t-b)/d; if(c<0)c=0; if(c>g)c=g; a=c*m/1440; if(a>c)a=c; printf "%.2f %.2f", c, a}')
if [ "$(cap PACE 1)" != 0 ] && awk -v s="$spent" -v a="$allow" 'BEGIN{exit !(s+0>=a+0)}'; then   # 10-17 13:55 his "you can spend it all today ... just spend it efficiently": PACE=0 turns the pacing off
  echo "$(date '+%m-%d %H:%M') pacing: spent \$$spent today, \$$allow allowed by now (\$$DAY_USD for today, $dl days to $END)" > "$C/status-$L.txt"; exit 0; fi
# 10-18 04:40, his "I shouldn't have had to ask" (two helpers sat idle with empty lists while lane a had five jobs waiting): a lane
# never takes a job another lane is running (each lock names its job), an idle lane takes the next job from any list, and when every
# list is empty a job that ran out of tries gets one more round, once (retried.txt).
busy=$(for d in "$C"/lane-*.lock; do [ "$d" = "$LK" ] && continue; cat "$d/task" 2>/dev/null; echo; done)
free(){ while read -r f; do [ -n "$f" ] || continue; printf '%s\n' "$busy" | grep -qxF "$(basename "$f")" || { echo "$f"; return; }; done; }
retry(){ ls "$C/failed/"*.md 2>/dev/null | sort | while read -r f; do n=$(basename "$f" .md)
  case "$n" in o-*) continue;; esac   # 10-20 04:25: o-* jobs are the Codex lane's (tools/codex-lane.sh); a Claude lane never retries or picks them
  grep -qxF "$n" "$C/retried.txt" 2>/dev/null && continue; echo "$n" >> "$C/retried.txt"
  # 10-20: runs are counted in spend.txt AND cli-spend.txt (the plan runs), so rename in both; renaming spend.txt alone gave a retried job 1 run, not 5
  for sf in spend.txt cli-spend.txt; do awk -v n="$n" '$3==n{$3=n"-r2"} {print}' "$C/$sf" > "$C/$sf.$L.tmp" && mv "$C/$sf.$L.tmp" "$C/$sf"; done
  mv "$f" "$C/tasks/" 2>/dev/null && echo "$C/tasks/$n.md"; break; done; }
# 10-19 night (b-30 spent its last two runs, 12 and 18 seconds, only to say it waited on c-02, then went to failed/): a run that ends
# TASK WAITING: OTHER-TASK-ID parks the job in blocked/ and does not count as a try (its spend line says NAME-wait). It comes back to
# tasks/ once no list or lane holds the other job any more, or after BLOCK_MAX_H hours. release() runs at every pick, RAM or not.
# 10-22 (coordinator): waiting/ counts as holding it too, as the jobs say ("in tasks/, waiting/ or running"); before, 86i was let out every pick, Codex parked it again at once, and lane o never reached the jobs behind it.
# 10-25 05:10 (coordinator): 112r ran 6 times in 25 minutes (about $1.10) on TASK WAITING lines that named a job no list held
# (113b-camera-career-stage, then itself): release() let it out at the next pick every time, and a wait was never a try. Now a wait
# on "coordinator" parks the job in waiting/ (lanes never pick there) with a line in waiting/README.md and alarms.md, and a wait
# on a job that no list or other lane holds, or on itself, counts as a try like a partial run (heldby).
wotarget(){ grep -o 'TASK WAITING: *[a-z0-9][a-z0-9-]\{2,60\}' "$out" 2>/dev/null | tail -1 | sed 's/^TASK WAITING: *//'; }
heldby(){ case "$1" in coordinator*) return 0;; esac; [ "$1" = "$name" ] && return 1
  { ls "$C/tasks/"*"$1"*.md "$C/waiting/"*"$1"*.md "$C/blocked/"*"$1"*.md 2>/dev/null | grep -v "/$name\.md\$"
    for d in "$C"/lane-*.lock; do [ "$d" = "$LK" ] && continue; cat "$d/task" 2>/dev/null; echo; done | grep -F -- "$1"; } | grep -q .; }
stag(){ local w; w=$(wotarget); [ -n "$w" ] && ! grep -q 'TASK DONE' "$out" 2>/dev/null && heldby "$w" && echo "$name-wait" || echo "$name"; }
release(){ local f n on age; for f in "$C/blocked/"*.md; do [ -f "$f" ] || continue; n=$(basename "$f" .md); on=$(tr -d '\r\n ' < "$C/blocked/$n.on" 2>/dev/null)
  age=$(( ( $(date +%s) - $(stat -c %Y "$f") ) / 3600 ))
  if [ -n "$on" ] && [ "$age" -lt "$(cap BLOCK_MAX_H 6)" ] && { ls "$C/tasks/"*"$on"*.md >/dev/null 2>&1 || ls "$C/waiting/"*"$on"*.md >/dev/null 2>&1 || printf '%s\n' "$busy" | grep -qF -- "$on"; }; then continue; fi
  mv "$f" "$C/tasks/" && rm -f "$C/blocked/$n.on" && echo "$(date '+%m-%d %H:%M') $n: back in tasks/ (it waited on ${on:-nothing named}, ${age} h)" >> "$C/runs.log"; done; }
# 10-18 08:10: two lanes picked the same job in the same second; picking is now one lane at a time (pick.lock, stale after 60 s)
for i in $(seq 1 30); do mkdir "$C/pick.lock" 2>/dev/null && break; [ -n "$(find "$C/pick.lock" -maxdepth 0 -mmin +1 2>/dev/null)" ] && rm -rf "$C/pick.lock"; sleep 2; done
busy=$(for d in "$C"/lane-*.lock; do [ "$d" = "$LK" ] && continue; cat "$d/task" 2>/dev/null; echo; done)
release
if [ "$L" = a ]; then t=$(ls "$C/tasks/"[0-9]*.md 2>/dev/null | sort | free); else t=$(ls "$C/tasks/$L-"*.md 2>/dev/null | sort | free); fi
[ -z "$t" ] && t=$(ls "$C/tasks/"*.md 2>/dev/null | grep -v "/o-[^/]*\.md$" | sort | free)   # 10-20 04:25: lane c picked o-02-corpus-green (a Codex job) once the queue ran short; 10-27 night: the pattern now matches every o-*.md (lettered names like o-120e-name.md slipped through the old o-NN- form)
[ -z "$t" ] && t=$(retry)
[ -n "$t" ] && basename "$t" > "$LK/task"; rm -rf "$C/pick.lock"
[ -z "$t" ] && { echo "$(date '+%m-%d %H:%M') no tasks left" > "$C/status-$L.txt"; exit 0; }
name=$(basename "$t" .md); stamp=$(date +%m%d-%H%M); out="$C/log/$name-$stamp.json"
# 10-18 04:50, his "when console money runs out can't we use normal Claude Code?": once this month's Console spend reaches TOTAL_USD,
# or the Console said the credit is gone (console-empty names the month), the lanes run on Claude Code on his Max plan instead.
# That plan is the same weekly usage his own sessions use and must last to the weekly reset (his hard rule 10-18), so only
# CLI_LANES lanes run (default 1, lane a, which takes any job) and at most CLI_DAY_USD of API-equivalent cost a day (claude -p
# reports it), released evenly through the day. Its costs go to cli-spend.txt, so spend.txt stays the real Console bill.
month=$(date +%Y-%m); mspent=$(awk -v m="$month" 'substr($1,1,7)==m {s+=$2} END {printf "%.2f", s+0}' "$C/spend.txt")
# 10-18, his "can't you make it so they pull the actual number instead of guessing??": the REAL Console spend (balance.mjs reads the
# cost report with an Admin key he creates, PILLAGERS_ADMIN_KEY) replaces the estimate when under 3 hours old; refreshed every 20 min.
RS="$C/real-spend.json"
if [ -z "$(find "$RS" "$C/real-spend.err" -mmin -20 2>/dev/null)" ]; then timeout 60 node "$R/tools/console-sdk/balance.mjs" > "$C/real-spend.err" 2>&1 && rm -f "$C/real-spend.err"; fi
if [ -n "$(find "$RS" -mmin -180 2>/dev/null)" ]; then rs=$(grep -o "\"month\":\"$month\",\"month_usd\":[0-9.]*" "$RS"); [ -n "$rs" ] && mspent=${rs##*:}; fi
ENGINE=api; ALWAYS=0
case ",$(cap CLI_ALWAYS "")," in *",$L,"*) ENGINE=cli; ALWAYS=1;; esac
[ "$(cat "$C/console-empty" 2>/dev/null | tr -d '\r\n ')" = "$month" ] && ENGINE=cli
awk -v s="$mspent" -v t="$TOTAL" 'BEGIN{exit !(s+0>=t+0)}' && ENGINE=cli
if [ $ENGINE = cli ]; then
  [ "$(cap CLI 1)" = 0 ] && { echo "$(date '+%m-%d %H:%M') Console money used up for $month; the Claude Code engine is off (CLI=0)" > "$C/status-$L.txt"; exit 0; }
  # 10-19, his "Is that going to work if Claude isn't signed in on this pc?": this PC is about to be signed in to his WORK account. A
  # helper runs only when Claude Code here is signed in to his Pillagers account (sha256 of its email in PLAN_ACCOUNT_SHA; the repo is
  # public, so never the address itself). Otherwise it stays off rather than bill the wrong account.
  want=$(cap PLAN_ACCOUNT_SHA "")
  if [ -n "$want" ]; then
    em=$(cd "$R" && MSYS_NO_PATHCONV=1 env -u ANTHROPIC_API_KEY timeout 60 claude auth status 2>/dev/null | grep -o '"email": *"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/' | tr 'A-Z' 'a-z')
    [ "$(printf '%s' "$em" | sha256sum | cut -c1-64)" = "$want" ] || { echo "$(date '+%m-%d %H:%M') helpers off: Claude Code on this machine is not signed in to your Pillagers account${em:+ (it is signed in to another one)}; $name kept" > "$C/status-$L.txt"; exit 0; }
  fi
  nl=$(cap CLI_LANES 1)
  if [ $ALWAYS = 0 ] && { { [ "$nl" -lt 2 ] && [ "$L" != a ]; } || { [ "$nl" -lt 3 ] && [ "$L" = c ]; }; }; then
    echo "$(date '+%m-%d %H:%M') resting: Console money used up, $nl helper(s) run on your plan" > "$C/status-$L.txt"; exit 0; fi
  # 10-18, his "really we should pace for like 85% because i want to use the account for other stuff too" and "can't you make it so
  # they pull the actual number instead of guessing??": the REAL plan usage (claude -p "/usage", which costs nothing) paces these
  # lanes. Weekly use must stay under PLAN_TARGET% (85) of the share of the week gone, and the 5-hour window under PLAN_SESSION_MAX%,
  # so he always has room. CLI_BOOST lanes (f) run only while the week is 5 or more points under that line.
  PU="$C/plan-usage.txt"
  if [ -z "$(find "$PU" -mmin -5 2>/dev/null)" ]; then
    u=$(cd "$R" && MSYS_NO_PATHCONV=1 env -u ANTHROPIC_API_KEY timeout 90 claude -p "/usage" --output-format json 2>/dev/null | grep -o 'Current session: [0-9]*% used\|Current week (all models): [0-9]*% used' | grep -o '[0-9]*%' | tr -d '%' | tr '\n' ' ')
    # 10-21 08:55: written to a temp file and moved, so a lane reading it while another writes never sees it empty (lane c 08:47)
    set -- $u; [ -n "$2" ] && echo "$1 $2 $(date +%s)" > "$PU.$L.tmp" && mv -f "$PU.$L.tmp" "$PU"; fi
  read ses wk _ < "$PU" 2>/dev/null
  [ -z "$wk" ] && { echo "$(date '+%m-%d %H:%M') cannot read your plan usage yet; waiting" > "$C/status-$L.txt"; exit 0; }
  WR=$(date -d "$(cap WEEK_RESET 2026-10-25T05:00:00Z)" +%s); nw=$(date +%s); while [ "$nw" -ge "$WR" ]; do WR=$((WR+604800)); done
  line=$(awk -v r="$WR" -v n="$nw" -v t="$(cap PLAN_TARGET 85)" 'BEGIN{printf "%.1f", (1-(r-n)/604800)*t}')
  # 10-25, his "The game needs to be as ready as possible by Friday night": PLAN_LINE_END (a time inside this week) moves the end of the
  # even line from the reset to that time, same PLAN_TARGET%, so the week's work lands before the party; after it the line holds there.
  le=""; [ -n "$(cap PLAN_LINE_END "")" ] && le=$(date -d "$(cap PLAN_LINE_END "")" +%s 2>/dev/null); ws=$((WR-604800))
  if [ -n "$le" ] && [ "$le" -gt "$ws" ] && [ "$le" -lt "$WR" ]; then
    line=$(awk -v s="$ws" -v e="$le" -v n="$nw" -v t="$(cap PLAN_TARGET 85)" 'BEGIN{f=(n-s)/(e-s); if(f>1)f=1; if(f<0)f=0; printf "%.1f", f*t}'); fi
  # 10-27, his "Keep shipping. Pace for 90% use by Friday afternoon": PLAN_LINE_START (inside this week, before PLAN_LINE_END) starts the
  # line at PLAN_LINE_FROM% (the week's use when he said it) and climbs evenly to PLAN_LINE_TARGET% at PLAN_LINE_END, then holds there.
  tg=$(cap PLAN_TARGET 85); lst=""; [ -n "$(cap PLAN_LINE_START "")" ] && lst=$(date -d "$(cap PLAN_LINE_START "")" +%s 2>/dev/null)
  if [ -n "$lst" ] && [ -n "$le" ] && [ "$lst" -ge "$ws" ] && [ "$lst" -lt "$le" ] && [ "$le" -lt "$WR" ]; then
    tg=$(cap PLAN_LINE_TARGET "$tg")
    line=$(awk -v s="$lst" -v e="$le" -v n="$nw" -v t="$tg" -v f0="$(cap PLAN_LINE_FROM 0)" 'BEGIN{f=(n-s)/(e-s); if(f>1)f=1; if(f<0)f=0; printf "%.1f", f0+f*(t-f0)}'); fi
  boost=0; case ",$(cap CLI_BOOST ""),," in *",$L,"*) boost=5;; esac
  # 10-19 18:30, his "forget about the pacing rule ... I don't care if you blow my usage quicker than the reset" and "I just don't want to
  # spend more tokens bc we are moving faster": PLAN_PACE=0 drops the weekly line (helpers run whenever they can); the 5-hour stop stays
  # so a helper never locks the chat out, and a helper starts only with RAM_FLOOR_GB+1 free (each one adds about 1 GB).
  # 10-24, his "Go ahead and blow the 4% of usage between now and 1am reset, then after reset pace back up to spend 80% over the next
  # week": until PLAN_BURN_UNTIL the weekly line is off (helpers run whenever they can); after it PLAN_PACE=1 holds an even line to
  # PLAN_TARGET% (80) by the next reset. PLAN_WEEK_MAX stops them near the top of the week, so the chat is never locked out.
  pace=$(cap PLAN_PACE 1); bu=$(cap PLAN_BURN_UNTIL ""); [ -n "$bu" ] && [ "$nw" -lt "$(date -d "$bu" +%s 2>/dev/null || echo 0)" ] && pace=0
  if [ "$wk" -ge "$(cap PLAN_WEEK_MAX 100)" ]; then
    echo "$(date '+%m-%d %H:%M') resting: the week is at $wk% (helpers stop at $(cap PLAN_WEEK_MAX 100)% so the chat keeps room)" > "$C/status-$L.txt"; exit 0; fi
  if { [ "$pace" != 0 ] && awk -v w="$wk" -v l="$line" -v b="$boost" 'BEGIN{exit !(w+b>=l)}'; } || [ "$ses" -ge "$(cap PLAN_SESSION_MAX 75)" ]; then
    if [ "$pace" = 0 ]; then echo "$(date '+%m-%d %H:%M') resting: the 5-hour window is at $ses% (helpers stop at $(cap PLAN_SESSION_MAX 75)%); week $wk% used" > "$C/status-$L.txt"
    else echo "$(date '+%m-%d %H:%M') pacing your plan: week $wk% used (the ${tg}% line is at $line% now), 5-hour window $ses%" > "$C/status-$L.txt"; fi; exit 0; fi
  # 10-24, his yes to "the VM gets the extra memory whenever you are away": while he is back at the main PC and it takes its memory back
  # (gaming.txt vmback=1 from tools/migrate/host-night-memory.ps1, under 10 minutes old), no new helper starts, so each one that finishes
  # frees memory the VM can hand back. Running helpers go on.
  gt=$(timeout 25 node "$R/tools/bridge/hostctl.mjs" share-get name=gaming.txt 2>/dev/null | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>{try{const j=JSON.parse(s);if(j.ok&&j.base64)process.stdout.write(Buffer.from(j.base64,'base64').toString('utf8'))}catch(e){}})" | tr -d '\r')
  if printf '%s\n' "$gt" | grep -q '^vmback=1$'; then
    ck=$(printf '%s\n' "$gt" | sed -n 's/^checked=//p' | head -1); cks=$(date -d "$ck" +%s 2>/dev/null || echo 0)
    if [ $(( $(date +%s) - cks )) -lt 600 ]; then echo "$(date '+%m-%d %H:%M') waiting: he is back at the main PC and it is taking its memory back; $name kept" > "$C/status-$L.txt"; exit 0; fi
  fi
  # 10-21: the smaller of free RAM and free virtual memory (Windows ran out of virtual memory at 02:19 with 4 GB of RAM free)
  rf=$(( $(cap RAM_FLOOR_GB 6) + 1 )); g=$(powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; [int]([Math]::Min(\$o.FreePhysicalMemory,\$o.FreeVirtualMemory)/1MB)" 2>/dev/null | tr -dc '0-9')
  # 10-28 09:47: the codex lane sat at "waiting for RAM: 0 GB free" while a test Chrome left by an ended preflight (9358, 2.9 GB, two game
  # pages) and six idle ones held the memory. Before a lane waits for RAM it closes LEFTOVER test Chromes (tools/close-leftover-test-chromes.ps1:
  # a pillagers-cdp temp profile on 9331-9399, over 45 min old, no gate or test script using its port), logs each close in runs.log and
  # reads memory again.
  sweepchromes(){ local o; o=$(timeout 90 powershell -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$R/tools/close-leftover-test-chromes.ps1")" 2>/dev/null | tr -d '\r')
    printf '%s\n' "$o" | grep '^closed' | while IFS= read -r l; do echo "$(date '+%m-%d %H:%M') lane $L: $l" >> "$C/runs.log"; done
    printf '%s\n' "$o" | grep -q '^closed' || return 1; sleep 3
    g=$(powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; [int]([Math]::Min(\$o.FreePhysicalMemory,\$o.FreeVirtualMemory)/1MB)" 2>/dev/null | tr -dc '0-9'); return 0; }
  [ "${g:-0}" -lt "$rf" ] && sweepchromes
  [ "${g:-0}" -lt "$rf" ] && { echo "$(date '+%m-%d %H:%M') waiting for RAM: ${g:-0} GB free, a helper starts at $rf; $name kept" > "$C/status-$L.txt"; exit 0; }
  # 10-20 00:10: lanes a and b both saw 3 GB free in the same second and both started (2.2 GB left). A new helper's memory shows only
  # after a minute or two, so one lane starts at a time: start.lock holds the others back for 2 minutes, then anyone may clear it.
  # 10-24 14:50: a lane whose job ended in seconds (a TASK PARTIAL rerun of 105) took the lock at every 5-minute tick, so lanes b and c
  # sat out 10 minutes with the VM free. A lane that finds the lock now waits it out once (staggered per lane) and checks memory again.
  for try in 1 2; do
    [ -n "$(find "$C/start.lock" -maxdepth 0 -mmin +2 2>/dev/null)" ] && rm -rf "$C/start.lock"
    mkdir "$C/start.lock" 2>/dev/null && break
    [ $try = 2 ] && { echo "$(date '+%m-%d %H:%M') waiting: another helper is just starting (memory check again in a few minutes); $name kept" > "$C/status-$L.txt"; exit 0; }
    echo "$(date '+%m-%d %H:%M') waiting: another helper is just starting (trying again in about 2 minutes); $name kept" > "$C/status-$L.txt"
    sleep $((125 + 15 * ($(printf '%d' "'$L") - 97)))
    g=$(powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; [int]([Math]::Min(\$o.FreePhysicalMemory,\$o.FreeVirtualMemory)/1MB)" 2>/dev/null | tr -dc '0-9')
    [ "${g:-0}" -lt "$rf" ] && sweepchromes
    [ "${g:-0}" -lt "$rf" ] && { echo "$(date '+%m-%d %H:%M') waiting for RAM: ${g:-0} GB free, a helper starts at $rf; $name kept" > "$C/status-$L.txt"; exit 0; }
  done
  echo "$(date '+%m-%d %H:%M') running $name on Claude Code (your plan: week $wk% of the $line% line, 5-hour $ses%)" > "$C/status-$L.txt"
  st=$(date +%s)
  # 10-21 02:52: job 85a (11.7 KB) plus RULES.md (21 KB) on the command line passed Windows' 32 KB limit ("env: 'claude': Argument
  # list too long") and the run never started. The job text now goes in on stdin and the rules as a file (tested 10-21 02:58).
  # 10-25, his ask "other sources of waste you can reduce?": measured on 58 helper runs, a helper starts at about 53k tokens and
  # rereads its whole conversation on every step (average 108k a step), and Sonnet 5.5 has a 1M window, so it never summarized.
  # CLAUDE_CODE_AUTO_COMPACT_WINDOW=150000 was meant to summarize at about 117k, but 10-25 05:11 to 05:21 jobs 114 and 115
  # summarized at about 50k, three times in a row, and stopped with "Autocompact is thrashing" ($1.91, tries given back). The
  # program sizes a job from the bytes of its messages, and a picture read with Read is hundreds of KB, so UI jobs look huge. So
  # early summarizing is OFF: the default here is 1000000 (the model default, no early summary). Do not lower it for jobs that read
  # pictures.
  # Helpers never use MCP tools (--strict-mcp-config) or the coordinator memory index (DISABLE_AUTO_MEMORY, which also keeps
  # helpers out of that folder): together a step starts at 39k instead of 52k (measured 10-25 in a helper-like setting).
  # 10-27 night (CEO chat, his "figure out an efficient escalation plan to figure out which model to use"): the model climbs with the tries.
  # runs.log 10-17..10-27: 63 of 100 finished jobs were done on run 1 and 15 on run 2, while 26 jobs failed after up to 5 Sonnet runs and
  # $29 of their $47 went to runs 3 to 5 that changed nothing. So runs 1-2 are Sonnet, every later run is Opus (caps ESC_*), and a job file
  # whose first 5 lines say "model: opus" starts on Opus (the coordinator marks crashes and party breakers that way).
  pr=$(cat "$C/spend.txt" "$C/cli-spend.txt" 2>/dev/null | grep -c " $name$")
  lm=$(cap CLI_MODEL sonnet); le=$(cap CLI_EFFORT high)
  if [ "$pr" -ge "$(cap ESC_AFTER 2)" ] || head -5 "$t" | grep -qi "^model: *opus"; then lm=$(cap ESC_MODEL opus); le=$(cap ESC_EFFORT high); fi
  sed -i "s/ on Claude Code (/ on Claude Code, $lm $le, run $((pr+1)) (/" "$C/status-$L.txt" 2>/dev/null
  ( cd "$R" && printf '%s' "Your task id is $name. Your lane is $L. You run in Claude Code: run every command with the Bash tool (never the PowerShell tool), use Read (it also shows pictures; it replaces view_image), Grep, Glob, Write, Edit and Bash, with each Bash command typed exactly in a form your rules list. $(cat "$t")" | env -u ANTHROPIC_API_KEY CLAUDE_CODE_AUTO_COMPACT_WINDOW="$(cap CLI_COMPACT 1000000)" CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 claude -p \
      --append-system-prompt-file "$(cygpath -m "$C/RULES.md")" --model "$lm" --effort "$le" --output-format json --max-turns "$(cap CLI_TURNS 150)" --strict-mcp-config \
      --allowedTools "${ALLOW[@]}" > "$out" 2> "$C/log/$name-$stamp.err" )
  cost=$(grep -o '"total_cost_usd":[0-9.eE+-]*' "$out" | tail -1 | cut -d: -f2); cost=${cost:-0}
  if awk -v c="$cost" 'BEGIN{exit !(c+0==0)}'; then
    if grep -qi 'authenticate\|oauth\|not logged in\|/login' "$out"; then w="waiting for you to sign in to Claude Code once (terminal: claude, then /login)"
    elif grep -qi 'limit' "$out"; then w="your plan's usage limit is reached; waiting"; else w="Claude Code run ended before any work (see $(basename "$out"))"; fi
    echo "$(date '+%m-%d %H:%M') $w; $name kept" | tee -a "$C/runs.log" > "$C/status-$L.txt"; exit 0; fi
  echo "$today $cost $(stag)" >> "$C/cli-spend.txt"
else
k=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PILLAGERS_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
[ -z "$k" ] && { echo "$(date '+%m-%d %H:%M') waiting for his key (Windows user variable PILLAGERS_API_KEY)" > "$C/status-$L.txt"; exit 0; }
left=$(awk -v s="$spent" -v c="$DAY_USD" -v r="$RUN_USD" 'BEGIN{x=c-s; if(x>r)x=r; printf "%.2f", x}')
echo "$(date '+%m-%d %H:%M') running $name (cap \$$left; spent today \$$spent of \$$DAY_USD)" > "$C/status-$L.txt"
# his key is account-wide (sk-ant-usr), so the API wants the workspace named in a header: WORKSPACE_ID in caps.txt (not a secret)
ws=$(cap WORKSPACE_ID "")
# 10-17: his Max plan's monthly API credits cover the plain Claude API but not Claude Code, and the Agent SDK runs the Claude Code
# engine: both said "Credit balance is too low" while a plain API call worked. So the run is tools/console-sdk/run-api.mjs, a small
# agent loop on the plain API whose own code enforces the same lockdown as ALLOW above. Prices (per million tokens) are estimates
# for the run cap only (P_IN, P_OUT, P_CR, P_CW in caps.txt); the Console's spend limit is the real cap.
st=$(date +%s)
ANTHROPIC_API_KEY="$k" CW_WS="$ws" CW_S="$S" CW_LANE="$L" CW_TASK="$name" CW_PROMPT_FILE="$t" CW_RULES="$C/RULES.md" CW_BUDGET="$left" \
  CW_MODEL="$(cap MODEL claude-sonnet-5-5)" CW_P_IN="$(cap P_IN 3)" CW_P_OUT="$(cap P_OUT 15)" CW_P_CR="$(cap P_CR 0.3)" CW_P_CW="$(cap P_CW 3.75)" \
  node "$R/tools/console-sdk/run-api.mjs" > "$out" 2> "$C/log/$name-$stamp.err" < /dev/null
k=""
cost=$(grep -o '"total_cost_usd":[0-9.eE+-]*' "$out" | tail -1 | cut -d: -f2); cost=${cost:-0}
# a refused key or empty credits costs nothing and is not a try at the task: say so and leave the task where it is
if grep -q '"terminal_reason":"api_error"' "$out" && awk -v c="$cost" 'BEGIN{exit !(c+0==0)}'; then
  grep -qi 'credit' "$out" && echo "$month" > "$C/console-empty"   # the next run switches to Claude Code
  echo "$(date '+%m-%d %H:%M') API error before any work (check the key and the Console credits); $name kept" | tee -a "$C/runs.log" > "$C/status-$L.txt"; exit 0; fi
echo "$today $cost $(stag)" >> "$C/spend.txt"
fi
# 10-24: the run is over, so this lane's preflight Chrome closes (preflight.sh starts it on 9350+lane number and keeps it for the
# job's next preflight). Left open after the job it held 140 to 320 MB with nobody using it and took the 10 GB VM under 2 GB free
# (09:46 port 9353 after job 99, 12:16 port 9351 after job 101). The next preflight starts a fresh one.
pcp=$((9350 + $(printf '%d' "'$L") - 96))
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -match 'remote-debugging-port=$pcp(\s|\$)' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" > /dev/null 2>&1
n=$(cat "$C/spend.txt" "$C/cli-spend.txt" 2>/dev/null | grep -c " $name$")
wo=$(wotarget); nw=
if [ -n "$wo" ] && ! grep -q 'TASK DONE' "$out" && ! heldby "$wo"; then nw="; it waited on $wo, which no list or other lane holds, so the run counts as a try"; wo=; fi
if [ -n "$wo" ] && ! grep -q 'TASK DONE' "$out"; then
  case "$wo" in
    coordinator*) why=$(grep -o 'TASK WAITING: [^"\\]*' "$out" | tail -1 | cut -c15-320); mkdir -p "$C/waiting"
      mv "$t" "$C/waiting/" && echo "- $name.md (parked $(date '+%m-%d %H:%M') by lane $L): $why" >> "$C/waiting/README.md" && echo "$(date '+%m-%d %H:%M') $name (lane $L) waits on the coordinator: $why" >> "$C/alarms.md"
      r="waiting on the coordinator, parked in waiting/ (not counted as a try)";;
    *) mkdir -p "$C/blocked"; mv "$t" "$C/blocked/" && touch "$C/blocked/$name.md" && echo "$wo" > "$C/blocked/$name.on"; r="waiting on $wo, parked in blocked/ (not counted as a try)";;
  esac
elif grep -q 'TASK DONE' "$out"; then mv "$t" "$C/done/"; r=done
elif [ "$n" -ge "$(cap MAXRUNS 3)" ]; then mv "$t" "$C/failed/"; r=failed$nw
else r="partial (run $n of $(cap MAXRUNS 3))$nw"; fi
echo "$(date '+%m-%d %H:%M') $name: $r, \$$cost" | tee -a "$C/runs.log" > "$C/status-$L.txt"
# 10-17 evening (his "check all your stuff to see if there are other misestimates"): the runner looks only every 5 minutes, so a
# helper sat idle up to 5 minutes between jobs. A run that did real work (a minute or more) starts the next job at once.
if [ $(( $(date +%s) - st )) -ge 60 ]; then rm -rf "$LK"; trap - EXIT; exec bash "$0" "$L"; fi
