#!/bin/bash
# cardrefresh.sh [S] : ship the next "POLISH PASS N" what is new card refresh when the card stamp trails the build.
# 2026-10-19: the card check fails once WHATSNEW_VER trails VER by more than 0.15, and the ChatGPT lane read that as
# "another worker will fix it" and slept for two hours. The lane now calls this instead. It does nothing unless the
# card is at least 0.10 behind, and shipq.sh queues it behind any other ship. S = the ship scratchpad (default below).
R="C:/claudecode/dark raiders"
S="${1:-C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad}"
G="$R/dark_raiders.html"; T="$R/tools/handoff/shipkit/mk-cw-cardP31.ps1"
ver=$(grep -o "^var VER='[0-9.]*'" "$G" | grep -o "[0-9][0-9.]*")
wn=$(grep -o "^var WHATSNEW_VER='[0-9.]*'" "$G" | grep -o "[0-9][0-9.]*")
[ -n "$ver" ] && [ -n "$wn" ] || { echo "cardrefresh: no VER or WHATSNEW_VER in the game file"; exit 1; }
awk -v a="$ver" -v b="$wn" 'BEGIN{exit !(a-b>=0.10-1e-9)}' || { echo "cardrefresh: card fine, stamped v$wn, build v$ver"; exit 0; }
n=$(grep -o "^  'POLISH PASS [0-9]*\." "$G" | grep -o "[0-9][0-9]*" | sort -n | tail -1)
[ -n "$n" ] || { echo "cardrefresh: no POLISH PASS line in the card"; exit 1; }
m=$((n+1)); k="cw-cardP$m"
mkdir "$S/cardrefresh.lock" 2>/dev/null || { find "$S/cardrefresh.lock" -maxdepth 0 -mmin +180 -exec rm -rf {} \; 2>/dev/null; mkdir "$S/cardrefresh.lock" 2>/dev/null || { echo "cardrefresh: another refresh is running"; exit 0; }; }
trap 'rm -rf "$S/cardrefresh.lock"' EXIT
sed -e "s/PASS 31\./PASS $m./g" -e "s/PASS 31'/PASS $m'/g" -e "s/cardP31/cardP$m/g" -e "s/polish pass 31\./polish pass $m./" "$T" > "$S/mk-$k.ps1"
grep -q "PASS 31" "$S/mk-$k.ps1" && { echo "cardrefresh: the template still names pass 31 after the rename"; exit 1; }
echo "cardrefresh: card stamped v$wn, build v$ver, shipping $k"
cd "$R" && timeout 7500 bash "$S/shipq.sh" "$k" 2>&1 | tail -4
