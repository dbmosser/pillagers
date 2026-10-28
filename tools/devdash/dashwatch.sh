#!/usr/bin/env bash
# devdash/dashwatch.sh : the Dashboard Correspondent chat's free watcher (10-27, his order to "manage the Pillagers Dev Dashboard and
# keep it current"). Runs in that chat's background (run_in_background), looks every 10 minutes at no AI cost, and exits with one
# line only when the dashboard needs a look, which wakes the chat. Never edit this file while it runs: write a .new, bash -n, mv over.
#   DASH DOWN      8820 has not answered for 3 looks (the runner restarts it within 5 minutes, so this means it keeps failing)
#   PAGE BROKEN    index.html changed and its script no longer parses
#   SERVER CRASH   a new line in pillagers-dashboard-crash.log (TEMP)
#   EDITED         another chat committed a change under tools/devdash (review it, keep the page in his plain words)
R="/c/claudecode/dark raiders"; D="$R/tools/devdash"; CRASH="$TEMP/pillagers-dashboard-crash.log"
last_commit=$(git -C "$R" log -1 --format=%H -- tools/devdash 2>/dev/null)
page_m=$(stat -c %Y "$D/index.html" 2>/dev/null); crash_n=$(cat "$CRASH" 2>/dev/null | wc -l); down=0
while true; do
  sleep 600
  if curl -s -m 10 "http://127.0.0.1:8820/api" | node -e "let b='';process.stdin.on('data',c=>b+=c).on('end',()=>{JSON.parse(b)})" 2>/dev/null; then down=0; else down=$((down+1)); fi
  [ "$down" -ge 3 ] && { echo "DASH DOWN: 8820 silent or bad JSON for 3 looks ($(date +%H:%M))"; exit 0; }
  m=$(stat -c %Y "$D/index.html" 2>/dev/null)
  if [ "$m" != "$page_m" ]; then
    page_m=$m
    node -e "const t=require('fs').readFileSync(process.argv[1],'utf8');new Function(t.match(/<script>([\s\S]*)<\/script>/)[1])" "$D/index.html" 2>/dev/null || { echo "PAGE BROKEN: index.html script does not parse ($(date +%H:%M))"; exit 0; }
  fi
  n=$(cat "$CRASH" 2>/dev/null | wc -l)
  [ "$n" -gt "$crash_n" ] && { echo "SERVER CRASH: $(tail -1 "$CRASH" | cut -c1-300)"; exit 0; }
  c=$(git -C "$R" log -1 --format=%H -- tools/devdash 2>/dev/null)
  if [ -n "$c" ] && [ "$c" != "$last_commit" ]; then
    s=$(git -C "$R" log -1 --format=%s "$c" | cut -c1-200); last_commit=$c
    case "$s" in devdash:*) ;; *) echo "EDITED: $(git -C "$R" log -1 --format=%h "$c") $s"; exit 0 ;; esac
  fi
done
