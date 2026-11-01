#!/bin/bash
# review-nightly.sh : once a day (tools/nightly.sh starts it after 03:00), the half-price code review of the day's shipped game
# changes on his Console credits (tools/console-sdk/review-batch.mjs). The key is read from his Windows variable, never printed.
R="/c/claudecode/dark raiders"; C="$R/tools/handoff/console"; cd "$R" || exit 1; mkdir -p "$C/review"
[ -f "$C/STOP" ] && exit 0
# 11-01 (CEO): the Console credit has been empty since 10-26 and the batch was refused every night ("credit balance is too low"). While
# console-empty says "always" or this month (the lanes' own switch to his plan), skip it with one line in the nightly log.
ce=$(cat "$C/console-empty" 2>/dev/null | tr -d '\r\n ')
if [ "$ce" = always ] || [ "$ce" = "$(date +%Y-%m)" ]; then echo "$(date '+%m-%d %H:%M') review: skipped, the Console credit is empty (console-empty says $ce)" >> "$R/tools/handoff/nightly/nightly.log"; exit 0; fi
k=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PILLAGERS_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
[ -z "$k" ] && exit 0
ws=$(grep -m1 '^WORKSPACE_ID=' "$C/caps.txt" | cut -d= -f2 | tr -d '\r ')
ANTHROPIC_API_KEY="$k" CW_WS="$ws" node "$R/tools/console-sdk/review-batch.mjs" >> "$C/review/review.log" 2>&1
