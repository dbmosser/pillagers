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
L=${1:-a}   # 10-17 LANES (his "max out ... the claude console resources"): one worker per lane at once; lane a = tasks named 0-9*, lane b = b-*, lane c = c-*
LK="$C/lane-$L.lock"   # one worker per lane: a lock folder holding the pid (Git Bash pids do not show in Windows process lists)
# 10-18 06:10: CLI_ALWAYS lanes (e.g. e) always run on Claude Code on his plan, beside the Console lanes (his weekly usage was at 1%
# with the week 4% gone). The runner starts only a, b and c, so each of those starts any CLI_ALWAYS lane that is not running.
for x in $(grep -m1 "^CLI_ALWAYS=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr "," "  "); do
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
  "Edit($PR/tools/mkfixture.ps1)"
  "Bash(bash $S/shipq.sh cw-*)" "Bash(bash $S/shipdraft.sh *)" "Bash(bash $S/fixq.sh *)" "Bash(bash $S/genP.sh *)"
  "Bash(bash $S/runchk.sh *)" "Bash(bash $S/lock.sh)" "Bash(bash $S/unlock.sh)" "Bash(bash $S/clearstale.sh)"
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File $S/mk-cw-*)"
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9346)"
  "Bash(git status:*)" "Bash(git log:*)" "Bash(git diff:*)" "Bash(git show:*)"
  "Bash(bash tools/handoff/preflight.sh *)" "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 *)"
  "Bash(node tools/console-sdk/critic.mjs *)" )
mkdir -p "$C/tasks" "$C/done" "$C/failed" "$C/log" "$C/notes"
[ -f "$C/STOP" ] && { echo "$(date '+%m-%d %H:%M') paused (STOP file)" > "$C/status-$L.txt"; exit 0; }
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
  grep -qxF "$n" "$C/retried.txt" 2>/dev/null && continue; echo "$n" >> "$C/retried.txt"
  awk -v n="$n" '$3==n{$3=n"-r2"} {print}' "$C/spend.txt" > "$C/spend.$L.tmp" && mv "$C/spend.$L.tmp" "$C/spend.txt"
  mv "$f" "$C/tasks/" 2>/dev/null && echo "$C/tasks/$n.md"; break; done; }
# 10-18 08:10: two lanes picked the same job in the same second; picking is now one lane at a time (pick.lock, stale after 60 s)
for i in $(seq 1 30); do mkdir "$C/pick.lock" 2>/dev/null && break; [ -n "$(find "$C/pick.lock" -maxdepth 0 -mmin +1 2>/dev/null)" ] && rm -rf "$C/pick.lock"; sleep 2; done
busy=$(for d in "$C"/lane-*.lock; do [ "$d" = "$LK" ] && continue; cat "$d/task" 2>/dev/null; echo; done)
if [ "$L" = a ]; then t=$(ls "$C/tasks/"[0-9]*.md 2>/dev/null | sort | free); else t=$(ls "$C/tasks/$L-"*.md 2>/dev/null | sort | free); fi
[ -z "$t" ] && t=$(ls "$C/tasks/"*.md 2>/dev/null | sort | free)
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
    set -- $u; [ -n "$2" ] && echo "$1 $2 $(date +%s)" > "$PU"; fi
  read ses wk _ < "$PU" 2>/dev/null
  [ -z "$wk" ] && { echo "$(date '+%m-%d %H:%M') cannot read your plan usage yet; waiting" > "$C/status-$L.txt"; exit 0; }
  WR=$(date -d "$(cap WEEK_RESET 2026-10-25T05:00:00Z)" +%s); nw=$(date +%s); while [ "$nw" -ge "$WR" ]; do WR=$((WR+604800)); done
  line=$(awk -v r="$WR" -v n="$nw" -v t="$(cap PLAN_TARGET 85)" 'BEGIN{printf "%.1f", (1-(r-n)/604800)*t}')
  boost=0; case ",$(cap CLI_BOOST ""),," in *",$L,"*) boost=5;; esac
  # 10-19 18:30, his "forget about the pacing rule ... I don't care if you blow my usage quicker than the reset" and "I just don't want to
  # spend more tokens bc we are moving faster": PLAN_PACE=0 drops the weekly line (helpers run whenever they can); the 5-hour stop stays
  # so a helper never locks the chat out, and a helper starts only with RAM_FLOOR_GB+1 free (each one adds about 1 GB).
  if { [ "$(cap PLAN_PACE 1)" != 0 ] && awk -v w="$wk" -v l="$line" -v b="$boost" 'BEGIN{exit !(w+b>=l)}'; } || [ "$ses" -ge "$(cap PLAN_SESSION_MAX 75)" ]; then
    if [ "$(cap PLAN_PACE 1)" = 0 ]; then echo "$(date '+%m-%d %H:%M') resting: the 5-hour window is at $ses% (helpers stop at $(cap PLAN_SESSION_MAX 75)%); week $wk% used" > "$C/status-$L.txt"
    else echo "$(date '+%m-%d %H:%M') pacing your plan: week $wk% used (the 85% line is at $line% now), 5-hour window $ses%" > "$C/status-$L.txt"; fi; exit 0; fi
  rf=$(( $(cap RAM_FLOOR_GB 6) + 1 )); g=$(powershell -NoProfile -Command "[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB)" 2>/dev/null | tr -dc '0-9')
  [ "${g:-0}" -lt "$rf" ] && { echo "$(date '+%m-%d %H:%M') waiting for RAM: ${g:-0} GB free, a helper starts at $rf; $name kept" > "$C/status-$L.txt"; exit 0; }
  echo "$(date '+%m-%d %H:%M') running $name on Claude Code (your plan: week $wk% of the $line% line, 5-hour $ses%)" > "$C/status-$L.txt"
  st=$(date +%s)
  ( cd "$R" && env -u ANTHROPIC_API_KEY claude -p "Your task id is $name. Your lane is $L. You run in Claude Code: run every command with the Bash tool (never the PowerShell tool), use Read (it also shows pictures; it replaces view_image), Grep, Glob, Write, Edit and Bash, with each Bash command typed exactly in a form your rules list. $(cat "$t")" \
      --append-system-prompt "$(cat "$C/RULES.md")" --model "$(cap CLI_MODEL sonnet)" --output-format json --max-turns "$(cap CLI_TURNS 150)" \
      --allowedTools "${ALLOW[@]}" > "$out" 2> "$C/log/$name-$stamp.err" < /dev/null )
  cost=$(grep -o '"total_cost_usd":[0-9.eE+-]*' "$out" | tail -1 | cut -d: -f2); cost=${cost:-0}
  if awk -v c="$cost" 'BEGIN{exit !(c+0==0)}'; then
    if grep -qi 'authenticate\|oauth\|not logged in\|/login' "$out"; then w="waiting for you to sign in to Claude Code once (terminal: claude, then /login)"
    elif grep -qi 'limit' "$out"; then w="your plan's usage limit is reached; waiting"; else w="Claude Code run ended before any work (see $(basename "$out"))"; fi
    echo "$(date '+%m-%d %H:%M') $w; $name kept" | tee -a "$C/runs.log" > "$C/status-$L.txt"; exit 0; fi
  echo "$today $cost $name" >> "$C/cli-spend.txt"
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
echo "$today $cost $name" >> "$C/spend.txt"
fi
n=$(cat "$C/spend.txt" "$C/cli-spend.txt" 2>/dev/null | grep -c " $name$")
if grep -q 'TASK DONE' "$out"; then mv "$t" "$C/done/"; r=done
elif [ "$n" -ge "$(cap MAXRUNS 3)" ]; then mv "$t" "$C/failed/"; r=failed
else r="partial (run $n of $(cap MAXRUNS 3))"; fi
echo "$(date '+%m-%d %H:%M') $name: $r, \$$cost" | tee -a "$C/runs.log" > "$C/status-$L.txt"
# 10-17 evening (his "check all your stuff to see if there are other misestimates"): the runner looks only every 5 minutes, so a
# helper sat idle up to 5 minutes between jobs. A run that did real work (a minute or more) starts the next job at once.
if [ $(( $(date +%s) - st )) -ge 60 ]; then rm -rf "$LK"; trap - EXIT; exec bash "$0" "$L"; fi
