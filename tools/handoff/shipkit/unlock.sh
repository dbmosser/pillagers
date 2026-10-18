#!/bin/bash
# unlock.sh : release the shared ship lock. 2026-10-18: two ships ran at once at 15:00 because anyone could release the lock, even
# while a ship held it (a waiting loop's lock.sh timed out and its unlock.sh freed the running ship's lock). The lock is now released
# only when its owner (the pid in shipq.owner) has ended or is the caller's own shell; a lock held by a live ship stays.
# FORCE=1 bash unlock.sh releases it anyway (only after checking no ship is running).
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
[ -d "$S/shipq.lock" ] || { echo "was not locked"; exit 0; }
read -r op ok ot < "$S/shipq.owner" 2>/dev/null
if [ -z "$FORCE" ] && [ -n "$op" ] && [ "$op" != "$PPID" ] && kill -0 "$op" 2>/dev/null; then
  echo "NOT UNLOCKED: the lock belongs to a running process $op ($ok since $ot)"; exit 4
fi
rmdir "$S/shipq.lock" 2>/dev/null && echo "UNLOCKED" || echo "was not locked"
