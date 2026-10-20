#!/bin/bash
# itch-daily.sh (2026-10-15, his order: "please push the game to itch once a day so we always have a backup" ... "and to the github").
# Every ship already pushes both (tools/handoff/ship.sh commit pushes itch when BUTLER_API_KEY and ITCH_TARGET are set in his
# Windows user environment; shipone.sh then pushes master). This is the once-a-day catch-up for a push that failed: if itch's
# channel or origin/master is behind the game's VER, push again. The key is read from Windows and passed to butler; never printed.
R="/c/claudecode/dark raiders"; cd "$R" || exit 1
ver=$(grep -m1 "^var VER='" dark_raiders.html | sed "s/var VER='\([0-9.]*\)'.*/\1/")
git fetch -q origin master 2>/dev/null
if [ "$(git rev-parse master)" != "$(git rev-parse origin/master)" ]; then git push -q origin master 2>&1 | tail -1; echo "$(date +%m-%d\ %H:%M) daily: github pushed (was behind)"; else echo "$(date +%m-%d\ %H:%M) daily: github up to date"; fi
BUTLER_API_KEY=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('BUTLER_API_KEY','User')" 2>/dev/null | tr -d '\r\n')
ITCH_TARGET=$(powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('ITCH_TARGET','User')" 2>/dev/null | tr -d '\r\n')
export BUTLER_API_KEY
B=/c/Users/User1/bin/butler.exe
[ -x "$B" ] && [ -n "$BUTLER_API_KEY" ] && [ -n "$ITCH_TARGET" ] || { echo "$(date +%m-%d\ %H:%M) daily: itch not set up"; exit 0; }
have=$("$B" status "$ITCH_TARGET" 2>/dev/null | grep -o -E "v[0-9]+\.[0-9]+" | tail -1)
if [ "$have" = "v$ver" ]; then echo "$(date +%m-%d\ %H:%M) daily: itch up to date (v$ver)"; exit 0; fi
cp dark_raiders.html tools/publish/index.html
powershell -NoProfile -ExecutionPolicy Bypass -File "C:/claudecode/dark raiders/tools/itch-zip.ps1" >/dev/null 2>&1 || { echo "$(date '+%m-%d %H:%M') daily: itch zip did not build, not pushed"; exit 0; }
"$B" push tools/publish/pillagers-web.zip "$ITCH_TARGET" --userversion "v$ver" 2>&1 | tail -1
echo "$(date +%m-%d\ %H:%M) daily: itch was $have, pushed v$ver"
