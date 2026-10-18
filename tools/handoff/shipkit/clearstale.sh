#!/bin/bash
# clearstale.sh : the ONLY way to clear the ship lock. Never rmdir shipq.lock yourself.
# Why (2026-10-12 22:50): lock.sh records the PID of the short shell that called it, which exits at once, so a manual lock
# always LOOKS dead; two agents each "cleared a stale lock" and both shipped as v24.90 (5099cc66 holds the wrong build).
# Rules: a shipq lock (owner key is a build key, PID is the shipq.sh process that lives for the whole ship) is stale only
# when that PID is gone. A manual lock (lock.sh, fixq, a gate rerun) is stale only when the lock is older than 20 minutes.
# Clears are serialized by a second mkdir mutex and logged to shipq.log, so two callers can never both clear and both take.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
LK="$S/shipq.lock"; LOG="$S/shipq.log"
[ -d "$LK" ] || { echo "lock free"; exit 0; }
mkdir "$S/shipq.clearing" 2>/dev/null || { echo "another clear is running; wait and retry"; exit 3; }
trap 'rmdir "$S/shipq.clearing" 2>/dev/null' EXIT
read -r pid key since < "$S/shipq.owner" 2>/dev/null
age=$(( $(date +%s) - $(stat -c %Y "$LK" 2>/dev/null || date +%s) ))
manual=0; case "$key" in manual|*lock*|*fixq*|*gate*|*held*) manual=1;; esac
if [ "$manual" = 0 ] && [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then echo "HELD by $key (pid $pid alive, ${age}s): not stale"; exit 1; fi
if [ "$manual" = 1 ] && [ "$age" -lt 1200 ]; then echo "HELD manually by $key for ${age}s (stale only after 1200 s): not stale"; exit 1; fi
if [ "$manual" = 0 ] && [ "$age" -lt 120 ]; then echo "HELD by $key for ${age}s (too young to judge): not stale"; exit 1; fi
rmdir "$LK" 2>/dev/null && { echo "$(date +%H:%M) CLEARSTALE: cleared the lock of $key (pid $pid, ${age}s)" >> "$LOG"; echo "cleared ($key, ${age}s)"; exit 0; }
echo "could not clear"; exit 2
