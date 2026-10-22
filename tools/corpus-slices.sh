#!/bin/bash
# Usage: bash tools/corpus-slices.sh OUT.txt 0 N 120   (N = __REGRESS.length; corpus Chrome on 9344 via tools/cdp.ps1 -Start -Port 9344)
# The corpus in slices, each in a fresh tab (since 10-21 a fresh browser), so a long page never builds up and a hung check costs one slice, not the run.
# 2026-10-08 05:35: a poll waits up to 150 s, because some checks run 70 s or more without yielding (v8.82, the sims) and a
# 60 s poll landing inside them read as a hang. A check is called hung only after 5 polls in a row (about 22 min) get no number.
# 2026-10-08 05:15 fix: only a NUMBER is progress. A hung page answers TIMEOUT, which the old loop took as progress and then
# logged as index 0 and restarted the slice from 1. Now a page that will not answer for 6 polls (about 18 minutes) is paused
# with the debugger (pause.ps1), which records the check it was in and the stack, and the next slice starts after that check.
cd "${PILLAGERS_ROOT:-/c/claudecode/dark raiders}"   # 10-22: the main PC's idle runs use their own copy (tools/spare/spare-runner.ps1)
SD="$(dirname "$0")"
OUT="$1"; A=${2:-0}; END=${3:-962}; STEP=${4:-120}
CDP() { powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9344 "$@" 2>/dev/null | tail -1; }
[ "$5" = append ] || : > "$OUT"
FIRST=$A
while [ $A -lt $END ]; do
  B=$((A+STEP)); [ $B -gt $END ] && B=$END
  TAG="slice$A"
  # 10-21 (coordinator, coord-02): a fresh corpus Chrome for every slice after the first. A fresh tab is not enough: the browser's
  # graphics process grows with every tab (2.8 GB over the 10-20 23:00 run) and took the VM out of virtual memory at 02:19, 03:25 and
  # 04:12, and the robot hang it caused at 02:21 keeps v33.17 out of stable. A clean close is not a crash, so Chrome does not restart in
  # its faster-growing crash mode. Same profile folder, so the storage the checks see is as before. CS_FRESH=0 keeps one browser.
  if [ $A -gt $FIRST ] && [ "${CS_FRESH:-1}" = 1 ]; then
    CDP -Close >/dev/null
    for t_ in 1 2; do powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Start -Port 9344 -Profile "${CS_PROFILE:-$TEMP/pillagers-cdp9344}" >/dev/null 2>&1
      curl -s --max-time 3 http://127.0.0.1:9344/json/version >/dev/null && break; sleep 5; done
  fi
  CDP -Open "http://localhost:8806/${FX:-fixture.html}?$TAG=1" >/dev/null; sleep 25
  CDP -Match "$TAG=1" -TimeoutSec 30 -Expr "(function(){ __regressBg($A,$B); return 'ok'; })()" >/dev/null
  last=0; still=0; busy=0; done_=0
  while true; do
    sleep 120
    p=$(CDP -Match "$TAG=1" -TimeoutSec 150 -Expr "(function(){ var P=window.__PROG; return P?(P.finished?'DONE':String(P.done)):'none'; })()")
    case "$p" in DONE) done_=1; break;; esac
    if ! [[ "$p" =~ ^[0-9]+$ ]]; then busy=$((busy+1)); [ $busy -ge 5 ] && break; continue; fi; busy=0
    if [ "$p" = "$last" ]; then still=$((still+1)); else still=0; last="$p"; fi
    [ $still -ge 8 ] && break
  done
  if [ $done_ = 1 ]; then
    # 10-20 (coord-09, o-02's alarm): a long description no longer cuts off the reason: the id and the text after the last ' -> ' are
    # always kept, only the description between them is shortened.
    # 2026-10-08: this read once answered TIMEOUT (a late timer still busy on the page) and the slice's result was lost; try 3 times.
    res=""; for try_ in 1 2 3; do res=$(CDP -Match "$TAG=1" -TimeoutSec 150 -Expr "(function(){ var r=__PROG.res; return '['+$A+','+$B+') '+r.summary+(r.fail.length?' || '+r.fail.map(function(f){ var s=String(f).split(String.fromCharCode(13)).join(' ').split(String.fromCharCode(10)).join(' '), k=s.lastIndexOf(' -> '); if(k<0) return s.slice(0,240); var h=s.slice(0,k); return (h.length>140?h.slice(0,140)+'...':h)+s.slice(k,k+400); }).join(' || '):''); })()"); case "$res" in \[*) break;; esac; sleep 20; done
    echo "${res:-[$A,$B) result could not be read}" >> "$OUT"
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
