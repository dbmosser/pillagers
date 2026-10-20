#!/bin/bash
# detached start of lane o (survives the Claude window closing)
cd "/c/claudecode/dark raiders" || exit 1
echo "=== $(date '+%m-%d %H:%M:%S') start" >> tools/handoff/codex/log/console.txt
bash tools/codex-lane.sh >> tools/handoff/codex/log/console.txt 2>&1
echo "=== $(date '+%m-%d %H:%M:%S') exit $?" >> tools/handoff/codex/log/console.txt
