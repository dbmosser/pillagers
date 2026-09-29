#!/bin/bash
# Waits for botsweep pages (title 'botsweep ... done') on the given Chromes, or a title frozen for STUCK s, then prints results.
STUCK=${1:-900}; PORTS=${2:-"9336 9337"}
declare -A last since state
while :; do
  left=0; now=$(date +%s)
  for p in $PORTS; do
    [ -n "${state[$p]}" ] && continue
    ti=$(curl -s -m 5 http://127.0.0.1:$p/json | grep -o '"title": "botsweep[^"]*"' | head -1)
    if [[ "$ti" == *done* ]]; then state[$p]=done; continue; fi
    if [ "$ti" != "${last[$p]}" ]; then last[$p]="$ti"; since[$p]=$now
    elif [ $((now-${since[$p]})) -gt $STUCK ]; then state[$p]="STUCK $ti"; continue; fi
    left=$((left+1))
  done
  [ $left -eq 0 ] && break
  sleep 30
done
for p in $PORTS; do
  echo "$p ${state[$p]}"
  powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\cdp.ps1" -Port $p -Match fixture -TimeoutSec 60 -Expr "JSON.stringify({map:__BS.map,done:__BS.done,over:__BS.over,errs:__BS.errs.slice(0,12)})" 2>/dev/null | cut -c1-2500
done
