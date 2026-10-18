#!/bin/bash
# governor.sh : every 60 s read his idle time. Under 600 s he is at the PC: write light.flag, stop the soak loops and their Chromes.
# Over 600 s: remove light.flag and keep the soak (overnight.sh AD) running. Agents read light.flag before starting a Chrome.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; LOG="$S/governor.log"
while true; do
  idle=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/idle.ps1" 2>/dev/null | tail -1 | tr -dc '0-9'); idle=${idle:-0}
  soak=$(powershell -NoProfile -Command "(Get-CimInstance Win32_Process -Filter \"Name='bash.exe'\" | Where-Object { \$_.CommandLine -match 'overnight\.sh' }).Count" 2>/dev/null | tr -dc '0-9')
  if [ "$idle" -lt 600 ]; then
    if [ ! -f "$S/light.flag" ]; then echo "$(date +%H:%M) he is here (idle ${idle}s): LIGHT" >> "$LOG"; fi
    date +%s > "$S/light.flag"
    if [ "${soak:-0}" -gt 0 ]; then
      powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='bash.exe' or Name='powershell.exe'\" | Where-Object { \$_.CommandLine -match 'overnight\.sh|soakloop|soak4k' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }; Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -match 'remote-debugging-port=(9335|9345)\b' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force -ErrorAction SilentlyContinue }" >/dev/null 2>&1
      echo "$(date +%H:%M) soak stopped" >> "$LOG"
    fi
  else
    if [ -f "$S/light.flag" ]; then rm -f "$S/light.flag"; echo "$(date +%H:%M) he is away (idle ${idle}s): FULL" >> "$LOG"; fi
    if [ "${soak:-0}" -eq 0 ]; then (cd "$R" && nohup bash tools/handoff/overnight.sh 21600 AD daylong >/dev/null 2>&1 &); echo "$(date +%H:%M) soak started" >> "$LOG"; fi
  fi
  sleep 60
done
