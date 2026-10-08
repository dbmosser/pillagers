#!/bin/bash
# Usage: bash tools/corpus-slices.sh OUT.txt 0 N 120   (N = __REGRESS.length; corpus Chrome on 9344 via tools/cdp.ps1 -Start -Port 9344)
# The corpus in slices, each in a fresh tab, so a long page never builds up and a hung check costs one slice, not the run.
# 2026-10-08 05:15 fix: only a NUMBER is progress. A hung page answers TIMEOUT, which the old loop took as progress and then
# logged as index 0 and restarted the slice from 1. Now a page that will not answer for 6 polls (about 18 minutes) is paused
# with the debugger (pause.ps1), which records the check it was in and the stack, and the next slice starts after that check.
cd "/c/claudecode/dark raiders"
SD="$(dirname "$0")"
OUT="$1"; A=${2:-0}; END=${3:-962}; STEP=${4:-120}
CDP() { powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 "$@" 2>/dev/null | tail -1; }
[ "$5" = append ] || : > "$OUT"
while [ $A -lt $END ]; do
  B=$((A+STEP)); [ $B -gt $END ] && B=$END
  TAG="slice$A"
  CDP -Open "http://localhost:8806/fixture.html?$TAG=1" >/dev/null; sleep 25
  CDP -Match "$TAG=1" -TimeoutSec 30 -Expr "(function(){ __regressBg($A,$B); return 'ok'; })()" >/dev/null
  last=0; still=0; busy=0; done_=0
  while true; do
    sleep 120
    p=$(CDP -Match "$TAG=1" -TimeoutSec 60 -Expr "(function(){ var P=window.__PROG; return P?(P.finished?'DONE':String(P.done)):'none'; })()")
    case "$p" in DONE) done_=1; break;; esac
    if ! [[ "$p" =~ ^[0-9]+$ ]]; then busy=$((busy+1)); [ $busy -ge 6 ] && break; continue; fi; busy=0
    if [ "$p" = "$last" ]; then still=$((still+1)); else still=0; last="$p"; fi
    [ $still -ge 8 ] && break
  done
  if [ $done_ = 1 ]; then
    CDP -Match "$TAG=1" -TimeoutSec 60 -Expr "(function(){ var r=__PROG.res; return '['+$A+','+$B+') '+r.summary+(r.fail.length?' || '+r.fail.map(function(f){ return String(f).slice(0,240); }).join(' || '):''); })()" >> "$OUT"
    NEXT=$B
  else
    st=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$SD/pause.ps1" -Port 9344 -Match "$TAG=1" 2>&1 | tr '\r\n' '  ')
    n=$(echo "$st" | sed -n 's/.*PROG done \([0-9]*\) of.*/\1/p'); [ -z "$n" ] && n=$last
    echo "[$A,$B) STALLED at index $((A+n)) (busy $busy, still $still): $st" | cut -c1-1500 >> "$OUT"
    NEXT=$((A+n+1))
  fi
  id=$(curl -s http://127.0.0.1:9344/json | grep -B4 "$TAG=1" | grep '"id"' | sed 's/.*"id": "\([^"]*\)".*/\1/' | head -1); [ -n "$id" ] && curl -s "http://127.0.0.1:9344/json/close/$id" >/dev/null
  A=$NEXT
done
echo "ALL DONE $(date +%H:%M)" >> "$OUT"
