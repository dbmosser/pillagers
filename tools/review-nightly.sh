#!/bin/bash
# review-nightly.sh : once a day (tools/nightly.sh starts it after 03:00), the half-price code review of the day's shipped game
# changes on his Console credits (tools/console-sdk/review-batch.mjs). The key is read from his Windows variable, never printed.
R="/c/claudecode/dark raiders"; C="$R/tools/handoff/console"; cd "$R" || exit 1; mkdir -p "$C/review"
[ -f "$C/STOP" ] && exit 0
k=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PILLAGERS_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
[ -z "$k" ] && exit 0
ws=$(grep -m1 '^WORKSPACE_ID=' "$C/caps.txt" | cut -d= -f2 | tr -d '\r ')
ANTHROPIC_API_KEY="$k" CW_WS="$ws" node "$R/tools/console-sdk/review-batch.mjs" >> "$C/review/review.log" 2>&1
