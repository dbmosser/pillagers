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
  # 10-28 (morning cost check): every wake re-reads the whole CEO chat, and most wakes overnight were Codex notes that needed nothing.
  # A camera-critic HUD note (critic + hud, no P0, no request, no failure) goes straight to notes/hud-critic-inbox.md for the HUD lane,
  # and a plain "shipped / ON HIS PC confirmed / camera limit" close-out is only logged; anything else still wakes the CEO.
  if [ "$al" -gt "$al0" ]; then
    while IFS= read -r l; do
      [ -z "$(echo "$l" | tr -d '[:space:]')" ] && continue
      # 10-29 07:30 (CEO): urgent words wake first; a critic note about existing UI outside the task (route, carry forward, UI owner,
      # outside this) goes to the HUD inbox even when it says P0 or please include; a linked review wakes only when Codex marks it synced.
      if echo "$l" | grep -qiE 'not on his|needs you|crash|freez|\bhang(s|ing)?\b|linked review needed: synced|coordinator action|doc(umentation)? handoff|went to failed'; then new+="ALARM: $l"$'\n'
      elif echo "$l" | grep -qi 'critic' && echo "$l" | grep -qiE 'hud|ui|outside th|route|carry|owner|existing|inherited'; then echo "- $(date '+%m-%d %H:%M') (auto from alarms.md): $(echo "$l" | cut -c1-600)" >> "$C/notes/hud-critic-inbox.md"
      elif echo "$l" | grep -qiE 'P0|please (run|include|confirm|return)|fail'; then new+="ALARM: $l"$'\n'
      elif echo "$l" | grep -qiE 'on his pc confirmed|camera (limit|cap) (is )?reached|no further (mechanic|camera)'; then :
      else new+="ALARM: $l"$'\n'; fi
    done < <(tail -c +$((al0+1)) "$C/alarms.md")
  fi
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
