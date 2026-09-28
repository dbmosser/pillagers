#!/bin/bash
# Poll shard titles; stop when every shard is done or stuck (title unchanged for STUCK seconds).
STUCK=${1:-240}; MAX=${2:-2400}; PORTS=${3:-"9336 9337 9338 9339"}
declare -A last since state
t0=$(date +%s)
while :; do
  left=0; now=$(date +%s)
  for p in $PORTS; do
    [ -n "${state[$p]}" ] && continue
    ti=$(curl -s -m 5 http://127.0.0.1:$p/json | grep -o '"title": "shard[^"]*"' | head -1 | sed 's/"title": //')
    if [[ "$ti" == *done* ]]; then state[$p]="done $ti"; continue; fi
    if [ "$ti" != "${last[$p]}" ]; then last[$p]="$ti"; since[$p]=$now
    elif [ $((now-${since[$p]})) -gt $STUCK ]; then state[$p]="STUCK $ti"; continue; fi
    left=$((left+1))
  done
  [ $left -eq 0 ] && break
  [ $((now-t0)) -gt $MAX ] && break
  sleep 20
done
for p in $PORTS; do
  echo "$p ${state[$p]:-UNFINISHED ${last[$p]}}"
  if [[ "${state[$p]}" == done* ]]; then
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\cdp.ps1" -Port $p -Match shard -TimeoutSec 60 -Expr "(function(){var p=window.__PROG||{},q=p.res;return q?('fail '+q.fail.length+': '+q.fail.map(function(f){return f.slice(0,170)}).join(' || ')):'no result'})()" 2>/dev/null | cut -c1-1500
  fi
done
