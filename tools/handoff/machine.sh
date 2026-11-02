#!/bin/bash
# machine.sh : what differs between the machines that run this repo. Sourced at the top of tools/nightly.sh, the lanes, health.sh, checkin.sh
# and onhispc.sh. His order 11-02: "move pillagers html development to the main PC permanently". Everything here is keyed on the computer name
# JUL26, so in the VM (VM_OCT2026) and on the spare PC it sets ON_MAIN=0 and changes nothing. Notes: tools/handoff/console/notes/move/kit.md
#
# On JUL26:
# - CLAUDE_CONFIG_DIR=%USERPROFILE%\.claude-pillagers, exported for this process and its children only, never user-wide. His terminal Claude
#   stays signed in to his work account in %USERPROFILE%\.claude; helpers use their own sign-in here, and the account guard in console-lane.sh,
#   critic.mjs and onhispc.sh all read this one. tools/migrate/main-helper-signin.ps1 is the sign-in.
# - The memory floor is 4 GB (his 10-28 rule for this PC), whatever caps.txt says for the VM: a helper starts at 5 GB free.
# - The Fortnite editor has first call on memory: one helper at a time while it is open (console-lane.sh).
# ASCII only. No output, no process started, when sourced.
case "$(printf '%s' "${COMPUTERNAME:-$(hostname 2>/dev/null)}" | tr 'a-z' 'A-Z')" in JUL26) ON_MAIN=1;; *) ON_MAIN=0;; esac
if [ "$ON_MAIN" = 1 ]; then
  export CLAUDE_CONFIG_DIR="${USERPROFILE:-C:\\Users\\User1}\\.claude-pillagers"
  export CLAUDE_CODE_GIT_BASH_PATH='C:\Program Files\Git\bin\bash.exe'
fi

# machine_floor DEFAULT : the memory floor in GB on this machine (caps.txt RAM_FLOOR_GB is the VM's number)
machine_floor(){ if [ "$ON_MAIN" = 1 ]; then echo 4; else echo "$1"; fi; }

# the same names tools/spare/spare-runner.ps1 EpicGame looks for
machine_epic_count(){ powershell -NoProfile -Command "@(Get-Process -ErrorAction SilentlyContinue | Where-Object { \$_.ProcessName -match '$1' }).Count" 2>/dev/null | tr -dc '0-9'; }
machine_editor_open(){ [ "$(machine_epic_count '^UnrealEditor')" -gt 0 ] 2>/dev/null; }
machine_fortnite_playing(){ [ "$(machine_epic_count '^FortniteClient')" -gt 0 ] 2>/dev/null; }

# how many helper runs are working now: a claude or node process started with the lane rules file, or the Console path's run-api.mjs
machine_helpers_running(){ powershell -NoProfile -Command "@(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { \$_.Name -match '^(claude|node)\.exe\$' -and \$_.CommandLine -match 'append-system-prompt-file.*RULES\.md|run-api\.mjs' }).Count" 2>/dev/null | tr -dc '0-9'; }

# machine_game_holds "GAMING.TXT TEXT" : on JUL26, does gaming=1 really mean he is playing? Returns 0 (hold new work) or 1 (let it start).
# The Dashboard chat found 11-02 that "gaming=1, what=pillagers 0%" held all new work overnight: that line also comes from a Pillagers window
# just sitting in front, and from the Fortnite editor (spare-runner.ps1 PlayNote; tools/migrate/host-night-memory.ps1 reads playing.txt). In the
# VM that was fine, here it would stop development every time he leaves a window open. So on this PC neither of those holds helpers; memory does.
# Still a hold: a program working the graphics card (a real game), a pad, Fortnite itself, Pillagers in front with keyboard or mouse in use.
machine_game_holds(){ local w idle why
  w=$(printf '%s\n' "$1" | sed -n 's/^what=//p' | head -1 | tr -d '\r')
  idle=$(printf '%s\n' "$1" | sed -n 's/^idle=//p' | head -1 | tr -dc '0-9-')
  case "$w" in ''|UnrealEditor*) return 1;; pillagers*) ;; *) return 0;; esac
  why=$(sed -n 's/^why=//p' "$(cygpath -u "${LOCALAPPDATA:-C:/Users/User1/AppData/Local}")/PillagersBridge/share/playing.txt" 2>/dev/null | head -1 | tr -d '\r')
  case "$why" in
    'a game pad') return 0;;
    'the fortnite editor or game') machine_fortnite_playing; return $?;;
    'the game in front') [ "${idle:--1}" -ge 0 ] && [ "${idle:--1}" -le 2 ]; return $?;;
    *) return 1;;
  esac
}
