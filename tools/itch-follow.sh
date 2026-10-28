#!/bin/bash
# itch-follow.sh : keeps itch on the newest build, about a minute after each ship.
# - 2026-10-27, his "please make sure itch is always getting the latest version" (the same day as "Itch should also always get the latest
#   build if that is feasible"): the runner looked only every 5 minutes and tried at most once per 10, so itch trailed a ship by up to
#   about 16 minutes (20:15 that night: itch v35.24, the game v35.26). tools/nightly.sh now starts this in the background whenever it is
#   not running. It looks at the last commit every 30 seconds and runs tools/itch-daily.sh --itch (lock, zip, butler, itch-ver.txt) as
#   soon as that commit holds a build itch does not have. After a try that did not get itch there, it waits 5 minutes. It ends itself
#   after 55 minutes so a newer copy of this file takes over; the runner starts the next one on its next pass.
R="/c/claudecode/dark raiders"; cd "$R" || exit 1
N="$R/tools/handoff/nightly"; IV="$N/itch-ver.txt"; LK="$N/itch-follow.lock"
# one follower at a time; it touches its lock every pass, so a lock untouched for 15 minutes is left from a dead one
if [ -d "$LK" ] && [ $(( $(date +%s) - $(stat -c %Y "$LK" 2>/dev/null || echo 0) )) -ge 900 ]; then rmdir "$LK" 2>/dev/null; fi
mkdir "$LK" 2>/dev/null || exit 0
trap 'rmdir "$LK" 2>/dev/null' EXIT
trap 'exit 0' TERM INT
end=$(( $(date +%s) + 3300 )); seen=; retry=0
while [ "$(date +%s)" -lt "$end" ]; do
  touch "$LK"
  h=$(git rev-parse -q HEAD 2>/dev/null)
  if [ -n "$h" ] && { [ "$h" != "$seen" ] || { [ "$retry" -gt 0 ] && [ "$(date +%s)" -ge "$retry" ]; }; }; then
    seen=$h; retry=0
    ver=$(git show HEAD:dark_raiders.html 2>/dev/null | grep -m1 "^var VER='" | sed "s/var VER='\([0-9.]*\)'.*/\1/")
    if [ -n "$ver" ] && [ "$ver" != "$(tr -d '\r\n ' < "$IV" 2>/dev/null)" ]; then
      timeout 600 bash "$R/tools/itch-daily.sh" --itch
      [ "$ver" = "$(tr -d '\r\n ' < "$IV" 2>/dev/null)" ] || retry=$(( $(date +%s) + 300 ))
    fi
  fi
  sleep 30
done
