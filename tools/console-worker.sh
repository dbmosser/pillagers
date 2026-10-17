#!/bin/bash
# console-worker.sh : runs ONE Claude task, billed to his Claude Console (API) credits and never to his subscription.
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
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
M="C:/Users/User1/.claude/projects/C--Users-User1-Desktop-dark-raiders/memory"
PS="//c/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
PR="//c/claudecode/dark raiders"
ALLOW=( "Read" "Grep" "Glob"
  "Write($PS/mk-cw-*)" "Edit($PS/mk-cw-*)"
  "Write($PR/tools/handoff/console/notes/**)" "Edit($PR/tools/handoff/console/notes/**)"
  "Write($PR/tools/handoff/console/questions.md)" "Edit($PR/tools/handoff/console/questions.md)"
  "Edit($PR/tools/mkfixture.ps1)"
  "Bash(bash $S/shipq.sh cw-*)" "Bash(bash $S/shipdraft.sh *)" "Bash(bash $S/fixq.sh *)" "Bash(bash $S/genP.sh *)"
  "Bash(bash $S/runchk.sh *)" "Bash(bash $S/lock.sh)" "Bash(bash $S/unlock.sh)" "Bash(bash $S/clearstale.sh)"
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File $S/mk-cw-*)"
  "Bash(powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9346)"
  "Bash(git status:*)" "Bash(git log:*)" "Bash(git diff:*)" "Bash(git show:*)" )
mkdir -p "$C/tasks" "$C/done" "$C/failed" "$C/log" "$C/notes"
[ -f "$C/STOP" ] && { echo "$(date '+%m-%d %H:%M') paused (STOP file)" > "$C/status.txt"; exit 0; }
cap(){ v=$(grep -m1 "^$1=" "$C/caps.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r '); echo "${v:-$2}"; }
RUN_USD=$(cap RUN_USD 4); DAY_USD=$(cap DAY_USD 15); today=$(date +%F)
spent=$(awk -v d="$today" '$1==d {s+=$2} END {printf "%.2f", s+0}' "$C/spend.txt" 2>/dev/null); spent=${spent:-0}
if awk -v s="$spent" -v c="$DAY_USD" 'BEGIN{exit !(s+0>=c+0)}'; then
  echo "$(date '+%m-%d %H:%M') day cap reached (\$$spent of \$$DAY_USD)" > "$C/status.txt"; exit 0; fi
t=$(ls "$C/tasks/"*.md 2>/dev/null | sort | head -1)
[ -z "$t" ] && { echo "$(date '+%m-%d %H:%M') no tasks left" > "$C/status.txt"; exit 0; }
k=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PILLAGERS_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
[ -z "$k" ] && { echo "$(date '+%m-%d %H:%M') waiting for his key (Windows user variable PILLAGERS_API_KEY)" > "$C/status.txt"; exit 0; }
name=$(basename "$t" .md); stamp=$(date +%m%d-%H%M); out="$C/log/$name-$stamp.json"
left=$(awk -v s="$spent" -v c="$DAY_USD" -v r="$RUN_USD" 'BEGIN{x=c-s; if(x>r)x=r; printf "%.2f", x}')
echo "$(date '+%m-%d %H:%M') running $name (cap \$$left; spent today \$$spent of \$$DAY_USD)" > "$C/status.txt"
# his key is account-wide (sk-ant-usr), so the API wants the workspace named in a header: WORKSPACE_ID in caps.txt (not a secret)
ws=$(cap WORKSPACE_ID "")
# 10-17: his Max plan's monthly API credits cover the plain Claude API but not Claude Code, and the Agent SDK runs the Claude Code
# engine: both said "Credit balance is too low" while a plain API call worked. So the run is tools/console-sdk/run-api.mjs, a small
# agent loop on the plain API whose own code enforces the same lockdown as ALLOW above. Prices (per million tokens) are estimates
# for the run cap only (P_IN, P_OUT, P_CR, P_CW in caps.txt); the Console's spend limit is the real cap.
ANTHROPIC_API_KEY="$k" CW_WS="$ws" CW_S="$S" CW_TASK="$name" CW_PROMPT_FILE="$t" CW_RULES="$C/RULES.md" CW_BUDGET="$left" \
  CW_MODEL="$(cap MODEL claude-sonnet-5-5)" CW_P_IN="$(cap P_IN 3)" CW_P_OUT="$(cap P_OUT 15)" CW_P_CR="$(cap P_CR 0.3)" CW_P_CW="$(cap P_CW 3.75)" \
  node "$R/tools/console-sdk/run-api.mjs" > "$out" 2> "$C/log/$name-$stamp.err" < /dev/null
k=""
cost=$(grep -o '"total_cost_usd":[0-9.eE+-]*' "$out" | tail -1 | cut -d: -f2); cost=${cost:-0}
# a refused key or empty credits costs nothing and is not a try at the task: say so and leave the task where it is
if grep -q '"terminal_reason":"api_error"' "$out" && awk -v c="$cost" 'BEGIN{exit !(c+0==0)}'; then
  echo "$(date '+%m-%d %H:%M') API error before any work (check the key and the Console credits); $name kept" | tee -a "$C/runs.log" > "$C/status.txt"; exit 0; fi
echo "$today $cost $name" >> "$C/spend.txt"
n=$(grep -c " $name$" "$C/spend.txt")
if grep -q 'TASK DONE' "$out"; then mv "$t" "$C/done/"; r=done
elif [ "$n" -ge 3 ]; then mv "$t" "$C/failed/"; r=failed
else r="partial (run $n of 3)"; fi
echo "$(date '+%m-%d %H:%M') $name: $r, \$$cost" | tee -a "$C/runs.log" > "$C/status.txt"
