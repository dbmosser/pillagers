#!/bin/bash
# fixq.sh "MESSAGE" : commit an edit to tools/mkfixture.ps1 (older checks retargeted so they hold on the old AND the new build),
# rebuild the fixture and clear the dry folders, holding the same lock as shipq.sh so no ship runs in the middle.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; LK="$S/shipq.lock"; M="$1"
[ -z "$M" ] && { echo "usage: fixq.sh MESSAGE"; exit 2; }
if [ "$HELD" != 1 ]; then n=0; until mkdir "$LK" 2>/dev/null; do sleep 5; n=$((n+1)); [ $n -gt 1440 ] && { echo "LOCK TIMEOUT"; exit 3; }; done
trap 'rmdir "$LK" 2>/dev/null' EXIT; fi
cd "$R" || exit 1
[ -z "$(git status --porcelain tools/mkfixture.ps1)" ] && { echo "NOTHING TO COMMIT in tools/mkfixture.ps1"; exit 1; }
git add tools/mkfixture.ps1 && git commit -q -m "fixture: $M

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" || { echo "COMMIT FAILED"; exit 1; }
echo "committed $(git log -1 --format=%h)"
powershell -NoProfile -ExecutionPolicy Bypass -File tools/mkfixture.ps1 2>&1 | tail -2
rm -rf "$TEMP/pillagers-dry/"dry*
echo "FIXTURE REBUILT"
