#!/bin/bash
# stable.sh : checks the newest finished test runs and, when a version qualifies as STABLE, publishes it. All the logic is in
# tools/stable.mjs (Node, no AI calls); this wrapper takes a lock so two checks never overlap, then runs it.
# His order 2026-10-18: "Tag builds as stable vs. intermediate/bridge; my play window always loads the latest stable build."
#
# STABLE means all three (plain words):
#   1. it was shipped through the gate (a git commit "vNN.NN: ...");
#   2. the full overnight test set (corpus) ran to the end on exactly that version and no check newly failed;
#   3. the crash-hunting robots (fuzz) played 30+ minutes on exactly that version with no problem.
# When one qualifies and is newer than the current stable, this script
#   - copies that exact version of the game to  C:\claudecode\dark raiders\stable.html   (served by :8802 as the address below),
#   - writes tools/handoff/stable.txt (version and time) and appends tools/handoff/stable-history.log,
#   - adds a git tag stable-vNN.NN on that version's commit.
# HIS PLAY ADDRESS:  http://localhost:8802/stable.html   (same server and same saves as http://localhost:8802/dark_raiders.html,
#   which keeps serving the newest build and is NOT changed by this script).
# Why it is not stuck when a screen is redesigned: see tools/handoff/stable-status.txt (what blocks) and the optional list
#   tools/handoff/stable-known-red.txt (prefix per line, e.g. v29.10, for a red check that is only an out-of-date test).
# A file tools/handoff/stable.freeze stops all promotions (the party-day scripts make it).
#
# Usage:  bash tools/stable.sh            full report on screen
#         bash tools/stable.sh --quiet    one log line (the runner uses this, once an hour)
#         bash tools/stable.sh --dry      judge only, write nothing
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; cd "$R" || exit 1
LK="$H/stable.lock"
if ! mkdir "$LK" 2>/dev/null; then
  if [ -n "$(find "$LK" -maxdepth 0 -mmin +15 2>/dev/null)" ]; then rm -rf "$LK"; mkdir "$LK" 2>/dev/null || exit 0
  else echo "$(date '+%m-%d %H:%M') stable: another check is running, skipped"; exit 0; fi
fi
trap 'rmdir "$LK" 2>/dev/null' EXIT
NODE=$(command -v node)
[ -z "$NODE" ] && NODE="/c/Users/User1/AppData/Local/Microsoft/WinGet/Packages/OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe/node-v24.20.0-win-x64/node.exe"
if [ "$1" = "--quiet" ]; then echo -n "$(date '+%m-%d %H:%M') "; fi
"$NODE" "$R/tools/stable.mjs" "$@" || echo "$(date '+%m-%d %H:%M') stable: the check failed to run (see the error above)"
