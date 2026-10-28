#!/bin/bash
# onhispc.sh NN.NN [KEY] : done means on his screen (his feedback 10-27: "stuff you told me you did, you didn't do").
# Waits up to 4 minutes for his main PC's 8802 to serve build NN.NN or newer (tools/bridge main-status, about 2 s a call),
# prints ON HIS PC or NOT ON HIS PC, and logs one line per build with the week's real plan use (claude -p "/usage", free), so
# the cost of a build can be read off console/onhispc.txt. shipq.sh runs it after every SHIPPED, outside the ship lock.
# Never say a build is done without its ON HIS PC line.
V=$1; K=${2:-}; R="/c/claudecode/dark raiders"; C="$R/tools/handoff/console"; OUT="$C/onhispc.txt"
[ -z "$V" ] && { echo "usage: onhispc.sh NN.NN [KEY]"; exit 2; }
want=$(echo "$V" | awk -F. '{printf "%d", $1*100+$2}'); t0=$(date +%s); got=""; hit=0
for i in $(seq 1 16); do
  got=$(cd "$R" && timeout 30 node tools/bridge/hostctl.mjs main-status 2>/dev/null | node -e '
    let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s),p=j.play8802||{};
    process.stdout.write(p.servesFileOnDisk===false?"stale-"+(p.ver||"?"):(p.ver||""))}catch(e){}})')
  g=$(echo "$got" | awk -F. '/^[0-9]+\.[0-9]+$/{printf "%d", $1*100+$2}')
  [ -n "$g" ] && [ "$g" -ge "$want" ] && { hit=1; break; }
  sleep 15
done
dt=$(( $(date +%s) - t0 ))
# the week's plan use: the lanes' file when it is under 5 minutes old, else ask (same command and same atomic write as console-lane.sh)
PU="$C/plan-usage.txt"
if [ -z "$(find "$PU" -mmin -5 2>/dev/null)" ]; then
  u=$(cd "$R" && MSYS_NO_PATHCONV=1 env -u ANTHROPIC_API_KEY timeout 90 claude -p "/usage" --output-format json 2>/dev/null | grep -o 'Current session: [0-9]*% used\|Current week (all models): [0-9]*% used' | grep -o '[0-9]*%' | tr -d '%' | tr '\n' ' ')
  set -- $u; [ -n "$2" ] && echo "$1 $2 $(date +%s)" > "$PU.ship.tmp" && mv -f "$PU.ship.tmp" "$PU"; fi
read ses wk _ < "$PU" 2>/dev/null
if [ $hit = 1 ]; then
  echo "$(date '+%m-%d %H:%M') v$V ${K:+$K }on his pc after ${dt}s (8802 serves $got) week ${wk:-?}%" >> "$OUT"
  echo "ON HIS PC v$V: his 8802 serves $got (${dt}s after the ship). He reloads to play it."
else
  echo "$(date '+%m-%d %H:%M') v$V ${K:+$K }NOT on his pc after ${dt}s (8802 serves ${got:-no answer}) week ${wk:-?}%" >> "$OUT"
  echo "$(date '+%m-%d %H:%M') v$V ${K:+($K) }not on his main PC after 4 min (8802 serves ${got:-no answer}); see tools/bridge main-status" >> "$C/alarms.md"
  echo "NOT ON HIS PC v$V: his 8802 serves ${got:-no answer} after ${dt}s. Do not call it done; the line is in alarms.md."
  exit 1
fi
