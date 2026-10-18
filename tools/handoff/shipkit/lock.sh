#!/bin/bash
# lock.sh : take the shared ship lock (blocks until free). Hold it while you edit tools/mkfixture.ps1 or run tools/gate.ps1 yourself,
# then run HELD=1 bash fixq.sh "msg" (commits + rebuilds without re-taking it) and finally bash unlock.sh. Never hold it longer than needed.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
n=0; until mkdir "$S/shipq.lock" 2>/dev/null; do sleep 5; n=$((n+1)); [ $n -gt 1440 ] && { echo "LOCK TIMEOUT"; exit 3; }; done
echo "$PPID ${1:-manual} $(date +%H:%M:%S)" > "$S/shipq.owner"; echo "LOCKED"
