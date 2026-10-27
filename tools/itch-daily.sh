#!/bin/bash
# itch-daily.sh : puts the newest build on itch (and, once a day, makes sure GitHub master is not behind).
# - 2026-10-15, his order: "please push the game to itch once a day so we always have a backup" ... "and to the github".
# - 2026-10-25: ships stopped pushing itch themselves (his "is pushing all this to itch and GitHub needed for every single build?").
# - 2026-10-27, his order: "Itch should also always get the latest build if that is feasible". tools/nightly.sh now runs this with
#   --itch in the background whenever the committed build has a VER itch does not have yet (itch-ver.txt), at most once per 10 minutes,
#   so itch follows each ship within about 10 minutes without holding the ship lock. Without --itch (once a day) it also pushes GitHub.
# It reads the build from the last commit, not the working file: a ship writes its draft into dark_raiders.html before it commits.
# The key is read from Windows and passed to butler; never printed.
R="/c/claudecode/dark raiders"; cd "$R" || exit 1
N="$R/tools/handoff/nightly"; IV="$N/itch-ver.txt"; LK="$N/itch.lock"
ts(){ date '+%m-%d %H:%M'; }
lab=daily; [ "$1" = "--itch" ] && lab=itch
if [ "$lab" = daily ]; then
  git fetch -q origin master 2>/dev/null
  if [ "$(git rev-parse master)" != "$(git rev-parse origin/master)" ]; then git push -q origin master 2>&1 | tail -1; echo "$(ts) daily: github pushed (was behind)"; else echo "$(ts) daily: github up to date"; fi
fi
# one copy at a time, so two runs never build the zip at once; a lock older than 30 minutes is left from a dead run
if [ -d "$LK" ] && [ $(( $(date +%s) - $(stat -c %Y "$LK" 2>/dev/null || echo 0) )) -ge 1800 ]; then rmdir "$LK" 2>/dev/null; fi
mkdir "$LK" 2>/dev/null || { echo "$(ts) $lab: another itch push is running"; exit 0; }
trap 'rmdir "$LK" 2>/dev/null' EXIT
ver=$(git show HEAD:dark_raiders.html 2>/dev/null | grep -m1 "^var VER='" | sed "s/var VER='\([0-9.]*\)'.*/\1/")
[ -n "$ver" ] || { echo "$(ts) $lab: no build number in the last commit, itch not pushed"; exit 0; }
BUTLER_API_KEY=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('BUTLER_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
ITCH_TARGET=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('ITCH_TARGET','User')" 2>/dev/null | tr -d '\r\n')
# 10-26: the page moved to pillagers.itch.io/pillagers; the old name in his variable answers "invalid game", so map it here.
ITCH_TARGET=${ITCH_TARGET/pillagersv1306/pillagers}
export BUTLER_API_KEY
B=/c/Users/User1/bin/butler.exe
[ -x "$B" ] && [ -n "$BUTLER_API_KEY" ] && [ -n "$ITCH_TARGET" ] || { echo "$(ts) $lab: itch not set up"; exit 0; }
have=$("$B" status "$ITCH_TARGET" 2>/dev/null | grep -o -E "v[0-9]+\.[0-9]+" | tail -1)
if [ "$have" = "v$ver" ]; then echo "$ver" > "$IV"; echo "$(ts) $lab: itch up to date (v$ver)"; exit 0; fi
mkdir -p tools/publish
git show HEAD:dark_raiders.html > tools/publish/index.html 2>/dev/null || { echo "$(ts) $lab: could not copy the build, itch not pushed"; exit 0; }
powershell -NoProfile -ExecutionPolicy Bypass -File "C:/claudecode/dark raiders/tools/itch-zip.ps1" >/dev/null 2>&1 || { echo "$(ts) $lab: itch zip did not build, not pushed"; exit 0; }
# a ship that commits meanwhile copies its own build into tools/publish; push only a zip that holds the build named in --userversion
zv=$(unzip -p tools/publish/pillagers-web.zip index.html 2>/dev/null | grep -m1 "^var VER='" | sed "s/var VER='\([0-9.]*\)'.*/\1/")
[ "$zv" = "$ver" ] || { echo "$(ts) $lab: the zip held v${zv:-?} instead of v$ver, not pushed (next try in 10 minutes)"; exit 0; }
out=$("$B" push tools/publish/pillagers-web.zip "$ITCH_TARGET" --userversion "v$ver" 2>&1); rc=$?
echo "$out" | tail -1
# 10-26: says FAILED when butler did not take the build (it said "pushed" whatever happened)
if [ $rc -ne 0 ]; then echo "$(ts) $lab: itch push FAILED (still $have, v$ver not pushed)"; exit 0; fi
echo "$ver" > "$IV"
echo "$(ts) $lab: itch was $have, pushed v$ver"
