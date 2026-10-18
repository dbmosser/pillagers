#!/bin/bash
# waitship.sh N : wait up to N seconds for a new shipq.log line about my keys, print it
cd "C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
L0=$(wc -l < shipq.log); t=0
while [ $t -lt ${1:-100} ]; do
  if tail -n +$((L0+1)) shipq.log | grep -qE "(coop9|coop1[0-2]|firefit|evalert|firelook|rvw2|goldlook):"; then break; fi
  sleep 5; t=$((t+5))
done
tail -n +$((L0+1)) shipq.log | cut -c1-230
echo "-- lines now $(wc -l < shipq.log), waited $t s; $(date +%H:%M)"
