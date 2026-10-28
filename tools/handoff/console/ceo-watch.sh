#!/bin/bash
# ceo-watch.sh : the CEO chat's watcher (10-27 night, his "why only once every 2 hours? how did you get to that number?").
# The 2-hour check-in is the CEO's full review; between reviews a problem could sit for up to 2 hours. This runs checkin.sh every
# 10 minutes with no AI cost and EXITS (waking the CEO chat, which runs it with run_in_background) only when a problem line appears
# that it has not reported before: a LOOK or STOP line of checkin.sh, or a new line in console/alarms.md. Quiet = no output, no cost.
# State (what was already reported, alarms.md size) lives in console/ceo-watch.state; delete it to report everything again.
R="/c/claudecode/dark raiders"; C="$R/tools/handoff/console"; ST="$C/ceo-watch.state"; EVERY=${1:-600}
touch "$ST"
al0=$(grep -m1 '^alarms=' "$ST" | cut -d= -f2); [ -z "$al0" ] && al0=$(wc -c < "$C/alarms.md" 2>/dev/null || echo 0)
while true; do
  new=""
  # new alarm lines since the last look
  al=$(wc -c < "$C/alarms.md" 2>/dev/null || echo 0)
  if [ "$al" -gt "$al0" ]; then new+=$(tail -c +$((al0+1)) "$C/alarms.md" | grep -v '^\s*$' | sed 's/^/ALARM: /')$'\n'; fi
  [ "$al" -lt "$al0" ] && al0=$al
  al0=$al
  # LOOK / STOP lines of the check-in, each reported once (digits ignored, so "1 time(s)" and "2 time(s)" count as the same line)
  ck=$(cd "$R" && timeout 300 bash "$C/checkin.sh" 2>/dev/null | grep -E '^(LOOK|STOP):')
  while IFS= read -r l; do
    [ -z "$l" ] && continue
    k=$(echo "$l" | sed 's/[0-9]\+/N/g' | cut -c1-160)
    grep -qxF "seen=$k" "$ST" || { new+="$l"$'\n'; echo "seen=$k" >> "$ST"; }
  done <<< "$ck"
  # keep the alarms offset for the next run of the watcher
  { grep -v '^alarms=' "$ST"; echo "alarms=$al0"; } > "$ST.tmp" && mv -f "$ST.tmp" "$ST"
  if [ -n "$(echo "$new" | tr -d '[:space:]')" ]; then echo "CEO WATCH $(date '+%m-%d %H:%M'): new problem(s)"; echo "$new" | grep -v '^\s*$' | cut -c1-300; exit 0; fi
  sleep "$EVERY"
done
