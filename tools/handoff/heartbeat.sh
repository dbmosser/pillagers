#!/bin/bash
# A working Claude session runs this in the background: it stamps tools/handoff/heartbeat.txt every 5 minutes and dies
# with the session, so a stale stamp tells the hourly watchdog that nobody is working.
F="/c/claudecode/dark raiders/tools/handoff/heartbeat.txt"
while :; do date -Iseconds > "$F"; sleep 300; done
