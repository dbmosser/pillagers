#!/bin/bash
# codex-lane.sh : LANE o. Runs ONE job at a time from tools/handoff/console/tasks with OpenAI Codex (`codex exec`, signed in with the
# owner's ChatGPT Plus plan), through the SAME ship gate as the Claude lanes (preflight.sh, then shipq.sh).
#   bash tools/codex-lane.sh             run (takes the next job, loops: codex -> gate -> feedback, up to MAXRUNS runs per job)
#   bash tools/codex-lane.sh --check     is Codex signed in? is its sandbox working? (nothing secret is printed; exit 1 if not ready)
#   bash tools/codex-lane.sh --dry [JOB] everything except calling Codex: picks a job WITHOUT locking it and prints the paths,
#                                        the exact command and the prompt size
#   bash tools/codex-lane.sh --setup     create or check the lane's private git worktree
# README: tools/handoff/codex/README.md.  Settings: tools/handoff/codex/caps-codex.txt (then console/caps.txt).
#
# DESIGN (2026-10-19), and why:
# - Codex works in its OWN git worktree (C:/claudecode/pillagers-codex, detached at master, reset to master before every run), in
#   Codex's `workspace-write` sandbox (Windows "mxc" mode, no network, writes only inside that worktree). Reading the whole disk is
#   allowed by the sandbox, so Codex can read notes, pictures and the scratchpad examples. It can NOT touch the shared tree, the
#   scratchpad, the ship scripts, dark_raiders.html or the ship lock: shipq.sh and every mk script write into the main repo by absolute
#   path, so only an UNSANDBOXED process can ship, and that process is this script, never Codex. I considered the main repo as cwd
#   with a read-only sandbox + --add-dir: workspace-write there would let Codex edit the shared tracked files, so I did not.
# - Codex writes its change as a draft script (.codex-work/JOB/mk-cw-cx-KEY.ps1) and a list of keys (keys.txt). THIS SCRIPT then
#   copies each mk script into the scratchpad (after a lint), runs the preflight on a private Chrome (port 9359, derived at run time
#   from tools/handoff/preflight.sh so it never drifts), runs `bash shipq.sh KEY`, and feeds any failure log back to Codex in
#   the next message (`codex exec resume THREAD`, or a fresh run if resume fails) while runs remain (MAXRUNS, same idea as
#   console-lane.sh). Photos (tools/uishots.ps1 on camera port 9364) and the critic are also run here, because Codex's sandbox has no
#   Chrome and no localhost.
# - I did not use Codex exec-policy rules to let Codex run the ship scripts itself: a rule "allow" runs outside the sandbox, rules
#   are matched by prefix only (no cw-* wildcard), they live in the owner's ~/.codex or a trusted project layer, and I cannot test
#   them without a sign-in. The lane running the gate gives the same allow-list with less risk. The child runs with
#   --ignore-user-config --ignore-rules so nothing from his own Codex setup (an "always allow" he once clicked) leaks in.
# - API KEYS: OPENAI_API_KEY and CODEX_API_KEY must never exist for the child (Codex gives CODEX_API_KEY precedence over the ChatGPT
#   sign-in, which would bill per token instead of the plan). Every variable whose name looks like a key, token, secret or password is
#   unset for the child (cxenv), and shell_environment_policy keeps such names out of Codex's own shell too.
# - WindowsApps is taken out of the child's PATH: the Store (MSIX) pwsh makes the sandbox fail (openai/codex#35871, and verified here
#   with `codex sandbox`: CreateProcessInSandbox error 5); Windows PowerShell 5.1 works.
# - The prompt goes in on stdin (RULES.md + the Codex addendum + the job is about 25 KB; Windows allows ~32 KB on a command line).
# - Same conventions as console-lane.sh: lane-o.lock (pid, task = the job name, which the other lanes read as "busy"), pick.lock,
#   free()/retry(), status-o.txt, runs.log, TASK DONE -> done/, MAXRUNS runs -> failed/, a STOP file pauses the lane (console/STOP,
#   and codex/STOP). Codex runs also add a zero-cost line to cli-spend.txt so the Claude lanes count them toward MAXRUNS.
# - Not started by tools/nightly.sh yet: the coordinator adds that once he has signed in.

MODE=run; JOBARG=""; L=o
for a in "$@"; do case "$a" in
  --dry) MODE=dry;; --check) MODE=check;; --setup) MODE=setup;; -h|--help) MODE=help;;
  --*) echo "unknown flag $a (try --help)"; exit 2;; *) JOBARG=${a%.md};; esac; done
if [ "$MODE" = help ]; then sed -n '2,8p' "$0" | cut -c3-; exit 0; fi

# ---------------------------------------------------------------- paths (CX_* overrides are for tests only)
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
R=${CX_R:-/c/claudecode/dark raiders}; C=${CX_C:-$R/tools/handoff/console}; X=${CX_X:-$R/tools/handoff/codex}
W=${CX_W:-/c/claudecode/pillagers-codex}
cd "$R" || exit 1
S=${CX_S:-C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad}
WW=$(cygpath -m "$W"); RW=$(cygpath -m "$R")
LK="$C/lane-$L.lock"
mkdir -p "$X/log" "$X/work" 2>/dev/null
cap(){ local v; v=$(grep -m1 "^$1=" "$X/caps-codex.txt" 2>/dev/null | cut -d= -f2- | tr -d '\r '); [ -z "$v" ] && v=$(grep -m1 "^$1=" "$C/caps.txt" 2>/dev/null | cut -d= -f2- | tr -d '\r '); echo "${v:-$2}"; }
say(){ [ "$MODE" = run ] && echo "$(date '+%m-%d %H:%M') $*" > "$C/status-$L.txt"; return 0; }
log(){ echo "$(date '+%F %T') $*" >> "$X/log/lane.log"; }
rd(){ LC_ALL=C tr -d '\000\r' < "$1" | LC_ALL=C sed '1s/^\xef\xbb\xbf//; 1s/^\xff\xfe//'; }   # Codex on Windows may write UTF-16 or BOM files
MODEL=$(cap CODEX_MODEL gpt-6.1-sol); EFFORT=$(cap CODEX_EFFORT high); CAM=$(cap CAMERA_PORT 9364)
PFN=$(cap PREFLIGHT_CHROME_N 9); PFPORT=$((9350+PFN))
# 10-21: the smaller of free RAM and free virtual memory (Windows ran out of virtual memory at 02:19 with 4 GB of RAM free)
freegb(){ if [ -n "$CX_FREEGB" ]; then echo "$CX_FREEGB"; return; fi; powershell -NoProfile -Command "\$o=Get-CimInstance Win32_OperatingSystem; [int]([Math]::Min(\$o.FreePhysicalMemory,\$o.FreeVirtualMemory)/1MB)" 2>/dev/null | tr -dc '0-9'; }
ramwait(){ local floor g i; floor=$(cap RAM_FLOOR_GB 6)
  for i in 1 2 3 4 5 6 7 8 9 10; do g=$(freegb); g=${g:-0}; [ "$g" -ge "$floor" ] && return 0; say "waiting for RAM: $g GB free, need $floor (${name:-codex})"; sleep 60; done; return 1; }

# ---------------------------------------------------------------- the codex program and a clean environment for it
find_codex(){
  if [ -n "$CX_CODEX_BIN" ]; then CXBIN=(bash "$CX_CODEX_BIN"); return 0; fi
  local nd js; nd=$(dirname "$(command -v node 2>/dev/null)"); js="$nd/node_modules/@openai/codex/bin/codex.js"
  if [ -f "$js" ]; then CXBIN=(node "$(cygpath -m "$js")"); return 0; fi
  command -v codex >/dev/null 2>&1 && { CXBIN=(codex); return 0; }
  return 1; }
cleanpath(){ local IFS=:; local out=() p; for p in $PATH; do case "$p" in *[Ww]indows[Aa]pps*) ;; *) out+=("$p");; esac; done; echo "${out[*]}"; }
# cxenv CMD ARGS... : run with every key/token/secret/password variable unset (OPENAI_API_KEY and CODEX_API_KEY above all) and no WindowsApps in PATH
cxenv(){ local a=() v
  for v in $(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' | grep -iE 'key|token|secret|passw|credential|^openai_|^anthropic_|^pillagers_'); do a+=(-u "$v"); done
  env "${a[@]}" -u OPENAI_API_KEY -u CODEX_API_KEY PATH="$(cleanpath)" MSYS_NO_PATHCONV=1 "$@"; }
# login_state : 0 signed in with ChatGPT, 1 not signed in, 2 signed in with an API key (pays per token: not wanted)
login_state(){ local o; o=$( { cd "$W" 2>/dev/null || cd "$R"; } ; cxenv timeout 40 "${CXBIN[@]}" login status 2>&1 ); LOGIN_RC=$?
  LOGIN_TXT=$(printf '%s' "$o" | tr -d '\r' | head -2 | tr '\n' ' ' | sed -E 's/sk-[A-Za-z0-9_*.-]+/sk-***/g; s/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+/<email>/g' | cut -c1-80)
  if [ $LOGIN_RC -eq 0 ]; then printf '%s' "$LOGIN_TXT" | grep -qi 'api key' && return 2; return 0; fi; return 1; }
NEEDS_SIGNIN="needs you: codex is not signed in (run codex once and choose Sign in with ChatGPT)"

# ---------------------------------------------------------------- the private worktree
wt_setup(){
  if [ -e "$W/.git" ]; then
    if git -C "$W" rev-parse --short HEAD >/dev/null 2>&1; then echo "worktree ok: $WW at $(git -C "$W" rev-parse --short HEAD)"; return 0; fi
    echo "$WW exists but is not a working git worktree"; return 1; fi
  if [ -e "$W" ] && [ -n "$(ls -A "$W" 2>/dev/null)" ]; then echo "$WW exists and is not empty: not touching it"; return 1; fi
  git -C "$R" worktree add --detach "$WW" master 2>&1 | grep -v 'Updating files' | tail -3
  git -C "$W" rev-parse --short HEAD >/dev/null 2>&1 || return 1
  echo "worktree created: $WW at $(git -C "$W" rev-parse --short HEAD)"; }
wt_refresh(){ local head gd
  gd=$(git -C "$W" rev-parse --git-dir 2>/dev/null) || { log "worktree missing"; return 1; }
  # SAFETY: checkout -f and clean below must only ever touch a LINKED worktree, never the shared tree
  case "$gd" in */worktrees/*) ;; *) log "refusing to refresh $WW: it is not a linked worktree ($gd)"; return 1;; esac
  [ "$(git -C "$W" rev-parse --show-toplevel 2>/dev/null)" != "$(git -C "$R" rev-parse --show-toplevel 2>/dev/null)" ] || { log "refusing: worktree is the main tree"; return 1; }
  git -C "$W" checkout -q -f --detach master >> "$X/log/wt.err" 2>&1 || { log "worktree checkout failed"; return 1; }
  git -C "$W" clean -fdq -e .codex-work >> "$X/log/wt.err" 2>&1
  head=$(git -C "$R" rev-parse master 2>/dev/null)
  [ "$(git -C "$W" rev-parse HEAD 2>/dev/null)" = "$head" ] || { log "worktree not at master"; return 1; }
  return 0; }
gamever(){ grep -m1 "^var VER='" "$W/dark_raiders.html" 2>/dev/null | sed "s/var VER='\([0-9]*\.[0-9]*\)'.*/\1/"; }
# the preflight for lane o is preflight.sh with one extra case line, made fresh each time so it follows any change to the gate
mkpre(){ local src="$R/tools/handoff/preflight.sh" dst="$X/work/preflight-o.sh"
  [ -f "$src" ] || return 1
  sed -e "s/^case \"\$L\" in a) n=1;;/case \"\$L\" in o) n=$PFN;; a) n=1;;/" "$src" > "$dst"
  grep -q "o) n=$PFN;;" "$dst"; }

if [ "$MODE" = setup ]; then wt_setup; exit $?; fi
find_codex || { echo "codex is not installed (npm i -g @openai/codex)"; [ "$MODE" = run ] && say "needs you: codex is not installed"; exit 1; }

# ---------------------------------------------------------------- --check
if [ "$MODE" = check ]; then
  rc=0
  echo "codex: $(cxenv "${CXBIN[@]}" --version 2>&1 | head -1 | tr -d '\r')"
  login_state; ls=$?
  case $ls in 0) echo "login: SIGNED IN ($LOGIN_TXT)";; 2) echo "login: signed in with an API KEY ($LOGIN_TXT): that bills per token. Run: codex logout, then codex and choose Sign in with ChatGPT"; rc=1;;
    *) echo "login: NOT SIGNED IN ($LOGIN_TXT): run codex once and choose Sign in with ChatGPT"; rc=1;; esac
  p=$( cd "$X/work" && cxenv timeout 120 "${CXBIN[@]}" -c 'windows.sandbox="mxc"' sandbox --permission-profile :workspace -- cmd.exe /d /c "echo MXC_OK" 2>&1 | tr -d '\r' | tail -1 )
  [ "$p" = MXC_OK ] && echo "sandbox: ok (mxc)" || { echo "sandbox: NOT WORKING (said: $p)"; rc=1; }
  for v in OPENAI_API_KEY CODEX_API_KEY; do [ -n "${!v}" ] && echo "note: $v is set in this shell; the lane unsets it for the child" ; done
  if git -C "$W" rev-parse --short HEAD >/dev/null 2>&1; then echo "worktree: ok ($WW at $(git -C "$W" rev-parse --short HEAD), master is $(git -C "$R" rev-parse --short master))"
  else echo "worktree: MISSING ($WW): run bash tools/codex-lane.sh --setup"; rc=1; fi
  mkpre && echo "preflight for lane o: ok (Chrome port $PFPORT)" || { echo "preflight for lane o: CANNOT derive it from tools/handoff/preflight.sh (its case line changed)"; rc=1; }
  [ -f "$C/STOP" ] && echo "STOP file present in console (all lanes paused)"; [ -f "$X/STOP" ] && echo "STOP file present in codex (this lane paused)"
  [ -f "$X/rest-until.txt" ] && echo "resting until $(date -d "@$(cat "$X/rest-until.txt")" '+%F %H:%M')"
  [ $rc = 0 ] && echo "READY" || echo "NOT READY"
  exit $rc; fi

# ---------------------------------------------------------------- pre-run gates (run mode only)
today=$(date +%F); now=$(date +%s); name=""
if [ "$MODE" = run ]; then
  if [ -f "$C/STOP" ] || [ -f "$X/STOP" ]; then say "paused (STOP file)"; exit 0; fi
  re=$(cat "$X/rest-until.txt" 2>/dev/null | tr -dc '0-9')
  if [ -n "$re" ]; then
    if [ "$re" -gt "$now" ]; then
      [ -f "$X/rest-why.txt" ] && why=$(cat "$X/rest-why.txt") || why="codex is resting"
      say "resting: $why, back about $(date -d "@$re" '+%a %H:%M')"; exit 0; fi
    rm -f "$X/rest-until.txt" "$X/rest-why.txt"; fi
  login_state; ls=$?
  [ $ls = 1 ] && { say "$NEEDS_SIGNIN"; exit 0; }
  [ $ls = 2 ] && { say "needs you: codex is signed in with an API key, which bills per token (run codex logout, then codex and choose Sign in with ChatGPT)"; exit 0; }
  mkdir -p "$C/tasks" "$C/done" "$C/failed" "$C/log" "$C/notes"
  # one worker per lane (same lock folder convention as console-lane.sh; other lanes read lane-o.lock/task as the busy list)
  if ! mkdir "$LK" 2>/dev/null; then p=$(cat "$LK/pid" 2>/dev/null); [ -n "$p" ] && kill -0 "$p" 2>/dev/null && exit 0; rm -rf "$LK"; mkdir "$LK" 2>/dev/null || exit 0; fi
  echo $$ > "$LK/pid"
  closepf(){ if curl -s -m 2 "http://127.0.0.1:$PFPORT/json/version" >/dev/null 2>&1; then
      powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='chrome.exe'\" | Where-Object { \$_.CommandLine -match 'remote-debugging-port=$PFPORT( |\$)' -and \$_.CommandLine -match 'pillagers-cdp$PFPORT' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" >/dev/null 2>&1; fi; }
  trap 'rm -rf "$LK"; closepf; if [ -n "$RT_LOCKED" ]; then [ -n "$RT_BAK" ] && cp "$RT_BAK" "$R/tools/mkfixture.ps1"; rt_unlock; fi' EXIT
fi

# ---------------------------------------------------------------- pick a job: o-*.md first, else any free job (console-lane.sh's free()/busy/retry)
busy=""; free(){ while read -r f; do [ -n "$f" ] || continue; printf '%s\n' "$busy" | grep -qxF "$(basename "$f")" || { echo "$f"; return; }; done; }
retry(){ ls "$C/failed/"*.md 2>/dev/null | sort | while read -r f; do n=$(basename "$f" .md)
  grep -qxF "$n" "$C/retried.txt" 2>/dev/null && continue; echo "$n" >> "$C/retried.txt"
  # 10-20: runs are counted in spend.txt AND cli-spend.txt (the plan runs), so rename in both; renaming spend.txt alone gave a retried job 1 run, not 5
  for sf in spend.txt cli-spend.txt; do awk -v n="$n" '$3==n{$3=n"-r2"} {print}' "$C/$sf" > "$C/$sf.$L.tmp" && mv "$C/$sf.$L.tmp" "$C/$sf"; done
  mv "$f" "$C/tasks/" 2>/dev/null && echo "$C/tasks/$n.md"; break; done; }
if [ "$MODE" = run ]; then
  for i in $(seq 1 30); do mkdir "$C/pick.lock" 2>/dev/null && break; [ -n "$(find "$C/pick.lock" -maxdepth 0 -mmin +1 2>/dev/null)" ] && rm -rf "$C/pick.lock"; sleep 2; done
fi
busy=$(for d in "$C"/lane-*.lock; do [ "$d" = "$LK" ] && continue; cat "$d/task" 2>/dev/null; echo; done)
t=""
if [ -n "$JOBARG" ]; then [ -f "$C/tasks/$JOBARG.md" ] && t="$C/tasks/$JOBARG.md"
else
  t=$(ls "$C/tasks/$L-"*.md 2>/dev/null | sort | free)
  # 2026-10-19: only o-* jobs for now. Taking any free job let Codex grab Claude lanes' UI jobs (12, 14) and burn their runs, and jobs that
  # rewrite mkfixture checks need a Claude lane (Codex cannot edit the shared tree). Set CX_ANY=1 (env or caps-codex.txt) to allow any free job again.
  [ -z "$t" ] && [ "${CX_ANY:-$(cap CX_ANY 0)}" = 1 ] && t=$(ls "$C/tasks/"*.md 2>/dev/null | sort | free)
  [ -z "$t" ] && [ "$MODE" = run ] && t=$(retry)
fi
if [ "$MODE" = run ]; then [ -n "$t" ] && basename "$t" > "$LK/task"; rm -rf "$C/pick.lock"; fi
if [ -z "$t" ]; then [ "$MODE" = run ] && say "no tasks left"; echo "no job to take${JOBARG:+ ($JOBARG not found in tasks)}"; exit 0; fi
name=$(basename "$t" .md)

# ---------------------------------------------------------------- work folders, prompt, command
WD="$W/.codex-work/$name"      # Codex's own output folder (inside its workspace)
LS="$X/work/$name"             # the lane's private state for this job (shipped keys etc.): Codex cannot touch it
sub(){ sed -e "s|@JOB@|$name|g" -e "s|@W@|$WW|g" -e "s|@MAIN@|$RW|g" -e "s|@S@|$S|g" "$1"; }
prompt_fresh(){  # $1 = lane message (may be empty)
  echo "Your task id is $name. Your lane is o. You run in Codex (codex exec) in a sandbox, not in Claude Code: the CODEX ADDENDUM after the rules says which tools and steps differ and tells you where to put your files. Game version at the start of this run: v$(gamever)."
  echo; echo "===== RULES.md ====="; rd "$C/RULES.md"
  echo; echo "===== CODEX ADDENDUM (RULES-codex.md; it wins where it differs from RULES.md) ====="; sub "$X/RULES-codex.md" | tr -d '\r'
  echo; echo "===== YOUR TASK: $name ====="; rd "$t"
  [ -d "$WD" ] && [ -n "$(ls -A "$WD" 2>/dev/null)" ] && { echo; echo "Files from your earlier runs of this job are in .codex-work/$name/ (read them and continue from them)."; }
  [ -n "$1" ] && { echo; echo "===== MESSAGE FROM THE LANE ====="; printf '%s\n' "$1"; }; }
# cx_args MODE : fills CXA with the codex arguments (MODE = fresh | resume THREAD)
cx_args(){
  CXA=( --json --skip-git-repo-check --ignore-user-config --ignore-rules -m "$MODEL"
    -c 'approval_policy="never"' -c 'sandbox_mode="workspace-write"' -c 'windows.sandbox="mxc"'
    -c 'sandbox_workspace_write.network_access=false' -c 'shell_environment_policy.ignore_default_excludes=false'
    -c 'web_search="disabled"' -c 'check_for_update_on_startup=false' -c 'analytics.enabled=false' -c "model_reasoning_effort=\"$EFFORT\""
    --disable browser_use --disable browser_use_external --disable browser_use_full_cdp_access --disable computer_use --disable in_app_browser
    --disable multi_agent --disable multi_agent_v2 --disable plugins --disable apps --disable remote_plugin --disable image_generation --disable hooks )
}

if [ "$MODE" = dry ]; then
  cx_args; mkdir -p "$X/log"; pf="$X/log/dry-prompt.txt"; prompt_fresh "" > "$pf"
  echo "DRY RUN (nothing locked, nothing started, codex not called)"
  echo "job it would take: $name   (list: $C/tasks, $(ls "$C/tasks/"*.md 2>/dev/null | wc -l) waiting; busy elsewhere: $(printf '%s' "$busy" | grep -c .))"
  echo "workspace (private git worktree): $WW   exists: $([ -e "$W/.git" ] && echo yes || echo NO, run: bash tools/codex-lane.sh --setup)   at: $(git -C "$W" rev-parse --short HEAD 2>/dev/null)  master: $(git -C "$R" rev-parse --short master 2>/dev/null)  game: v$(gamever)"
  echo "codex output folder: $WW/.codex-work/$name   lane state: $LS   logs: $X/log/$name-STAMP.jsonl and .last.txt   runs: $X/runs.txt"
  echo "ship gate: preflight $X/work/preflight-o.sh (from tools/handoff/preflight.sh, Chrome $PFPORT), then bash $S/shipq.sh KEY; camera port $CAM"
  echo "status file: $C/status-$L.txt   lock: $LK   STOP files: $C/STOP $X/STOP ($([ -f "$C/STOP" ] && echo present || echo absent) / $([ -f "$X/STOP" ] && echo present || echo absent))"
  echo "model: $MODEL  effort: $EFFORT  max runs per job: $(cap MAXRUNS 5)  one run cut after $(cap RUN_MIN 45) min"
  echo "prompt: $(wc -c < "$pf") bytes ($(wc -l < "$pf") lines) on stdin, saved to $pf   (the command line itself is short; Windows allows ~32 KB)"
  echo "env for the child: PATH without WindowsApps ($(cleanpath | tr ':' '\n' | wc -l) of $(echo "$PATH" | tr ':' '\n' | wc -l) entries kept); unset: OPENAI_API_KEY CODEX_API_KEY + every name matching key/token/secret/passw/credential ($(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' | grep -ciE 'key|token|secret|passw|credential|^openai_|^anthropic_|^pillagers_') found now)"
  printf 'command (fresh run), run in %s:\n  ' "$WW"; printf '%q ' "${CXBIN[@]}" exec -C "$WW" -s workspace-write -o "$(cygpath -m "$X")/log/$name-STAMP.last.txt" "${CXA[@]}" -; echo "< prompt > $X/log/$name-STAMP.jsonl"
  printf 'command (follow-up after a gate result):\n  '; printf '%q ' "${CXBIN[@]}" exec resume -o "$(cygpath -m "$X")/log/$name-STAMP.last.txt" "${CXA[@]}" THREAD_ID -; echo "< message"
  mkpre && echo "preflight derivation: ok" || echo "preflight derivation: FAILED (preflight.sh case line changed)"
  [ -f "$X/rest-until.txt" ] && echo "note: resting until $(date -d "@$(cat "$X/rest-until.txt")" '+%F %H:%M')"
  exit 0; fi

# ================================================================ RUN MODE
secs_max=$(( $(cap RUN_MIN 45) * 60 )); MAXR=$(cap MAXRUNS 5); PICMAX=$(cap PIC_ROUNDS 3); OKSC=$(cap CRITIC_OK 4)
mkdir -p "$LS" "$X/log" "$C/log"; touch "$LS/shipped.txt" "$LS/installed.txt"
st=$(date +%s)
wt_setup > /dev/null 2>&1; [ -e "$W/.git" ] || { say "needs you: the codex worktree $WW could not be made (bash tools/codex-lane.sh --setup)"; exit 0; }
mkpre || { say "needs you: tools/handoff/preflight.sh changed shape; the codex lane cannot derive its preflight"; exit 0; }
n0=$(cat "$C/spend.txt" "$C/cli-spend.txt" 2>/dev/null | grep -c " $name$")
left=$(( MAXR - n0 )); [ "$left" -lt 1 ] && left=1

fb=""; tid=""; sc=""; PICS=(); it=0; idle=0; picrounds=$(cat "$LS/picrounds.txt" 2>/dev/null); picrounds=${picrounds:-0}; r=""; lastclaim=""
appendfb(){ fb="${fb}${fb:+
}$1"; }
append_new(){ [ -s "$1" ] || return 0; mkdir -p "$(dirname "$2")"; { [ -n "$3" ] && { echo; echo "$3"; }; rd "$1"; echo; } >> "$2"; : > "$1"; }
harvest(){ append_new "$WD/notes-new.md" "$C/notes/$name.md" "--- codex run $(date '+%F %H:%M') ---"
  append_new "$WD/questions-new.md" "$C/questions.md" ""; append_new "$WD/alarms-new.md" "$C/alarms.md" ""; append_new "$WD/changes-new.md" "$C/notes/ui/changes.md" ""; }
keys_list(){ [ -f "$WD/keys.txt" ] && rd "$WD/keys.txt" | sed 's/#.*//; s/^[ \t]*//; s/[ \t]*$//' | grep -v '^$' | head -6; }
screens_list(){ [ -f "$WD/shots.txt" ] && rd "$WD/shots.txt" | head -1 | tr -d ' \t' | grep -E '^[0-9A-Za-z,_-]{1,120}$'; }

# ---- the Codex process
kill_orphans(){ powershell -NoProfile -Command "Get-CimInstance Win32_Process | Where-Object { \$_.Name -match '^(codex|node)(\.exe)?\$' -and \$_.CommandLine -match 'pillagers-codex' -and \$_.CommandLine -match ' exec' } | ForEach-Object { Stop-Process -Id \$_.ProcessId -Force }" >/dev/null 2>&1; }
run_codex(){  # run_codex fresh|resume PROMPTFILE [image files...] -> JSONL LAST ERRF RC
  local mode=$1 pf=$2; shift 2; local imgs=() i stamp; for i in "$@"; do imgs+=("--image=$(cygpath -m "$i")"); done
  stamp=$(date +%m%d-%H%M%S); JSONL="$X/log/$name-$stamp.jsonl"; LAST="$X/log/$name-$stamp.last.txt"; ERRF="$X/log/$name-$stamp.err"; cx_args
  if [ "$mode" = resume ]; then
    ( cd "$W" && cxenv timeout -k 30 "$secs_max" "${CXBIN[@]}" exec resume -o "$(cygpath -m "$LAST")" "${CXA[@]}" "${imgs[@]}" "$tid" - < "$pf" > "$JSONL" 2> "$ERRF" )
  else
    ( cd "$W" && cxenv timeout -k 30 "$secs_max" "${CXBIN[@]}" exec -C "$WW" -s workspace-write -o "$(cygpath -m "$LAST")" "${CXA[@]}" "${imgs[@]}" - < "$pf" > "$JSONL" 2> "$ERRF" )
  fi
  RC=$?; [ $RC = 124 ] || [ $RC = 137 ] && kill_orphans; return 0; }
# parse the reset time out of "try again at 3:41 PM" / "try again in 2 hours 5 minutes" / "...at Oct 23rd, 2026 4:12 PM"
parse_reset(){ local t="$1" m s e d h mi
  m=$(printf '%s' "$t" | grep -oiE 'try again in [^.]*' | head -1)
  if [ -n "$m" ]; then
    d=$(printf '%s' "$m" | grep -oiE '[0-9]+ *day' | grep -oE '[0-9]+' | head -1); h=$(printf '%s' "$m" | grep -oiE '[0-9]+ *hour' | grep -oE '[0-9]+' | head -1); mi=$(printf '%s' "$m" | grep -oiE '[0-9]+ *min' | grep -oE '[0-9]+' | head -1)
    s=$(( ${d:-0}*86400 + ${h:-0}*3600 + ${mi:-0}*60 )); [ "$s" -gt 0 ] && { echo $(( $(date +%s) + s + 120 )); return; }; fi
  m=$(printf '%s' "$t" | grep -oiE 'try again at [^.]*[.]?' | head -1 | sed -E 's/^try again at //I; s/[.]$//; s/([0-9])(st|nd|rd|th)\b/\1/')
  if [ -n "$m" ]; then e=$(date -d "$m" +%s 2>/dev/null)
    if [ -n "$e" ]; then [ "$e" -le "$(date +%s)" ] && e=$((e+86400)); echo $((e+120)); return; fi; fi; }
classify(){  # sets CLASS = ok | limit | login | timeout | crash ; also ERRTXT
  local ev tc; tc=$(grep -c '"turn.completed"' "$JSONL" 2>/dev/null); ev=$(grep -E '^\{ *"type" *: *"(error|turn\.failed)"' "$JSONL" 2>/dev/null | head -6 | cut -c1-700)
  ERRTXT="$ev $(tail -c 1500 "$ERRF" 2>/dev/null | tr -d '\r')"
  if [ "${tc:-0}" -gt 0 ]; then CLASS=ok; return; fi
  if printf '%s' "$ERRTXT" | grep -qiE "usage limit|hit your .*limit|rate.?limit|too many requests|quota|usage_limit_reached"; then CLASS=limit; return; fi
  if printf '%s' "$ERRTXT" | grep -qiE "not logged in|log ?in again|sign in|signed in|unauthorized|401|authentication|refresh token|auth.json|invalid.*token"; then CLASS=login; return; fi
  if [ "$RC" = 124 ] || [ "$RC" = 137 ]; then CLASS=timeout; return; fi
  [ -s "$LAST" ] && { CLASS=ok; return; }
  CLASS=crash; }
rest_until(){ echo "$1" > "$X/rest-until.txt"; echo "$2" > "$X/rest-why.txt"; }
tokens(){ local t p
  t=$(grep '"turn.completed"' "$JSONL" 2>/dev/null | grep -o '"\(input\|output\)_tokens": *[0-9]*' | awk -F'[:"]' '{k=$2; v=$NF+0; s[k]+=v} END{printf "in=%d out=%d", s["input_tokens"], s["output_tokens"]}')
  p=$(grep 'rate_limits' "$JSONL" 2>/dev/null | tail -1 | grep -o '"used_percent": *[0-9.]*' | grep -o '[0-9.]*$' | tr '\n' '/' | sed 's|/$||')   # best effort: only if Codex reports its limits
  echo "$t${p:+ limit_pct=$p}"; }
claim_of(){ local l; l=$(rd "$LAST" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -1 | sed 's/[*`_ ]//g' | tr 'a-z' 'A-Z')
  case "$l" in TASKDONE|TASKDONE.) echo DONE;; TASKPARTIAL*) echo PARTIAL;; TASKWAITING*) echo WAITING;; *) echo NONE;; esac; }
waiting_on(){ rd "$LAST" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -1 | grep -o 'TASK WAITING: *[a-z0-9][a-z0-9-]\{2,60\}' | sed 's/^TASK WAITING: *//'; }

# ---- the gate for one key. returns 0 shipped, 1 Codex must fix (fb has why), 2 not Codex's fault (wait / lane problem)
lint_mk(){ local f=$1 k=$2 bad
  if LC_ALL=C tr -d '\000' < "$f" | LC_ALL=C grep -q -P '[^\x00-\x7F]'; then echo "it contains non-ASCII characters (Windows PowerShell 5.1 misreads them): ASCII only, write [char]0x2019 style escapes if you need one"; return 1; fi
  bad=$(rd "$f" | grep -n -iE 'Invoke-WebRequest|Invoke-RestMethod|\biwr\b|\bcurl(\.exe)?\s+(-|http)|\bwget\b|Start-Process|Remove-Item|Rename-Item|Move-Item|Copy-Item|\bgit(\.exe)?\s+(push|reset|checkout|clean|commit|add|rm|stash|rebase|worktree)|Invoke-Expression|\biex\b|DownloadString|DownloadFile|EncodedCommand|Set-ExecutionPolicy|schtasks|Stop-Process|taskkill|auth\.json|\.codex|OPENAI|CODEX_|API_KEY|PILLAGERS_|\.ssh|Out-File|Set-Content|Add-Content|\[Environment\]::SetEnvironmentVariable' | head -3)
  [ -n "$bad" ] && { echo "it uses something a change script must not use: $(echo "$bad" | tr '\n' ' ' | cut -c1-300)"; return 1; }
  bad=$(rd "$f" | grep -n 'WriteAll' | grep -v 'draft-' | head -2)
  [ -n "$bad" ] && { echo "it writes a file that is not the draft json: $(echo "$bad" | cut -c1-200)"; return 1; }
  rd "$f" | grep -q "draft-$k\.json" || { echo "it never writes draft-$k.json"; return 1; }
  return 0; }
ship_key(){
  local k=$1 mk="$WD/mk-$1.ps1" dst="$S/mk-$1.ps1" why pf out i wait
  grep -qxF "$k" "$LS/shipped.txt" 2>/dev/null && return 0
  [[ "$k" =~ ^cw-cx-[a-z0-9][a-z0-9-]{1,40}$ ]] || { appendfb "Key '$k' is not allowed. Keys must look like cw-cx-name (lower case letters, digits, dashes). Fix keys.txt."; return 1; }
  [ -f "$mk" ] || { appendfb "keys.txt lists $k but .codex-work/$name/mk-$k.ps1 does not exist."; return 1; }
  if grep -q ": SHIPPED" <(grep " $k: " "$S/shipq.log" 2>/dev/null) && grep -qxF "$k" "$LS/installed.txt"; then echo "$k" >> "$LS/shipped.txt"; return 0; fi
  why=$(lint_mk "$mk" "$k") || { appendfb "The lane refused mk-$k.ps1: $why"; return 1; }
  if [ -e "$dst" ] && ! grep -qxF "$k" "$LS/installed.txt"; then appendfb "The key $k is already used by another helper. Rename it (a new cw-cx- key) in keys.txt and the file name and the draft file name."; return 1; fi
  LC_ALL=C tr -d '\000' < "$mk" | LC_ALL=C sed '1s/^\xff\xfe//; 1s/^\xef\xbb\xbf//' > "$dst" || { appendfb "lane problem: could not copy the mk script to the scratchpad"; return 2; }
  grep -qxF "$k" "$LS/installed.txt" || echo "$k" >> "$LS/installed.txt"
  ramwait || { say "waiting for RAM before the gate ($name)"; return 2; }
  say "gate: preflight $k ($name, codex)"
  for i in 1 2 3 4; do
    pf=$(cd "$R" && timeout $(( $(cap PREFLIGHT_MIN 25) * 60 )) bash "$X/work/preflight-o.sh" o "$k" 2>&1 | tail -12 | cut -c1-700); echo "$pf" > "$X/log/$name-$k.preflight.txt"
    printf '%s\n' "$pf" | grep -q '^PREFLIGHT PASS' && break
    # 2026-10-19: a stale what is new card is nobody's job, so waiting for "another worker" slept two hours. Ship the refresh, retry.
    if printf '%s\n' "$pf" | grep -qiE 'stamped v[0-9.]+, .*behind'; then
      say "gate: the what is new card is stale, shipping a card refresh first ($k, $name)"
      bash "$R/tools/handoff/shipkit/cardrefresh.sh" "$S" >> "$X/log/cardrefresh.txt" 2>&1; sleep 30; continue; fi
    if printf '%s\n' "$pf" | grep -qiE 'uncommitted changes'; then
      say "gate: waiting for another worker ($k, $name)"; sleep 240; continue; fi
    # 2026-10-19 (o-04 burned 5 runs): the preflight Chrome ($PFPORT) not answering is the lane's problem, not Codex's. Restart it and
    # try again; if it still will not answer, put the job back without spending a Codex run.
    if printf '%s\n' "$pf" | grep -qiE 'Unable to connect to the remote server|actively refused|json/version'; then
      if [ $i -lt 4 ]; then log "preflight browser $PFPORT not answering ($k), restarting it"; closepf; sleep 3
        powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port $PFPORT -Profile "$(cygpath -w "$TEMP")\pillagers-cdp$PFPORT" >/dev/null 2>&1; sleep 3; continue; fi
      say "gate: preflight browser $PFPORT will not answer ($name); the job waits, no run spent"; return 2; fi
    appendfb "PREFLIGHT FAILED for $k. Fix .codex-work/$name/mk-$k.ps1 (or its check) and finish again. The gate said:
$(printf '%s\n' "$pf" | tail -8)"; return 1
  done
  printf '%s\n' "$pf" | grep -q '^PREFLIGHT PASS' || { say "gate: $k waits on another worker's change ($name)"; return 2; }
  for i in $(seq 1 $(( $(cap SHIP_RETRIES 3) + 1 ))); do
    say "gate: shipping $k ($name, codex)"
    # 2026-10-19: the gate browser (shipq.sh ships on Chrome 9346) can be down after a restart; Codex may not start it from its sandbox,
    # so the lane does, the same command the Claude lanes are allowed (console-lane.sh). Without this every run failed "Unable to connect".
    curl -s -m 3 http://127.0.0.1:9346/json/version >/dev/null 2>&1 || { log "gate browser (9346) was down, starting it"; powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port 9346 >/dev/null 2>&1; }
    out=$(timeout 7500 bash "$S/shipq.sh" "$k" 2>&1 | tail -14 | cut -c1-700); echo "$out" > "$X/log/$name-$k.ship.txt"
    printf '%s\n' "$out" | grep -q '^SHIPPED' && { echo "$k" >> "$LS/shipped.txt"; SHIPPED_NOW+=("$k"); log "$name shipped $k: $(printf '%s\n' "$out" | grep '^SHIPPED' | head -1)"; return 0; }
    if printf '%s\n' "$out" | grep -qi 'uncommitted changes'; then sleep 90; continue; fi
    if printf '%s\n' "$out" | grep -qiE 'stamped v[0-9.]+, .*behind'; then bash "$R/tools/handoff/shipkit/cardrefresh.sh" "$S" >> "$X/log/cardrefresh.txt" 2>&1; sleep 30; continue; fi
    break
  done
  if printf '%s\n' "$out" | grep -qiE 'uncommitted changes|stamped v[0-9.]+, .*behind'; then say "gate: $k waits on another worker's change ($name)"; return 2; fi
  appendfb "The ship gate STOPPED $k (nothing shipped). Fix it and finish again; keep the same key. The gate said:
$(printf '%s\n' "$out" | tail -9)"; return 1; }

# ---- Codex's fixture-retarget.json (RULES-codex.md step 5). 2026-10-19 night: the rules promised this step but the lane never had it, so
#      o-03 and o-06 handed over retargets only the coordinator could apply. Trial first, lock last: the edited copy builds a trial fixture
#      from the committed game and its checks run in the lane's own Chrome ($PFPORT) with no lock held; only a passing file takes the ship
#      lock, and then only to copy, commit and rebuild. Sets RT_HOLD (keys that wait; * = all of them) and RT_DONE (the commit).
#      returns 0 nothing to do or applied, 1 Codex must fix it (fb has why), 2 not Codex's fault (its keys wait, no run spent on it)
RT_LOCKED=""; RT_BAK=""; RT_PAGE="fx0rt-codex.html"
rt_unlock(){ bash "$S/unlock.sh" >> "$LS/retarget-lock.txt" 2>&1; RT_LOCKED=""; }
rt_checks(){  # rt_checks LIST OUT : each check in LIST once on the trial fixture in Chrome $PFPORT, 25 per tab. 0 ran, 2 browser trouble
  local l=$1 o=$2 vs chunk js tag id i=0 n sec; sec=$(cap RETARGET_RUN_SEC 330); : > "$o"; mapfile -t vs < "$l"; n=${#vs[@]}
  curl -s -m 3 "http://127.0.0.1:$PFPORT/json/version" >/dev/null 2>&1 || { powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Start -Port $PFPORT -Profile "$(cygpath -w "$TEMP")\pillagers-cdp$PFPORT" >/dev/null 2>&1; sleep 3; }
  curl -s -m 3 "http://127.0.0.1:$PFPORT/json/version" >/dev/null 2>&1 || return 2
  while [ $i -lt $n ]; do
    chunk=("${vs[@]:$i:25}"); js=$(printf "'%s'," "${chunk[@]}"); tag="rt$i$$"
    id=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Port $PFPORT -Open "http://localhost:8806/$RT_PAGE?$tag=1" 2>/dev/null | tr -d '\r' | awk '/^opened/{print $2}')
    [ -n "$id" ] || return 2
    sleep 20
    timeout $((sec + 60)) powershell -NoProfile -ExecutionPolicy Bypass -File "$R/tools/cdp.ps1" -Port $PFPORT -Match "$tag=1" -TimeoutSec "$sec" -Expr "(function(){ var vs=[${js%,}], out=[]; vs.forEach(function(V){ var t=__REGRESS.find(function(x){return x.v===V}); if(!t){ out.push(V+': NO CHECK'); return; } var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } out.push(V+': '+(r?String(r).slice(0,300):'PASS')); }); return out.join('\n'); })()" 2>/dev/null | tr -d '\r' >> "$o"
    curl -s -m 5 "http://127.0.0.1:$PFPORT/json/close/$id" >/dev/null 2>&1
    i=$((i+25))
  done
  echo "ALL DONE" >> "$o"; return 0; }
apply_retarget(){
  local js="$WD/fixture-retarget.json" ap="$LS/retarget-applied.txt" out="$LS/mkfixture-retarget.ps1" game="$LS/game-head.html"
  local lst="$LS/retarget-run.txt" res="$LS/retarget-result.txt" trial="$R/tools/$RT_PAGE" pl st run why n h0 h1 bad miss v c pat tries=0
  RT_HOLD=""; RT_DONE=""
  [ -f "$js" ] || return 0
  touch "$ap"
  # the keys that wait if this fails (none listed: all of them wait)
  RT_HOLD=$(node "$X/retarget.mjs" keys "$js" 2>/dev/null | tr -d '\r')
  [ -z "$RT_HOLD" ] && RT_HOLD="*"
  while :; do
    tries=$((tries+1))
    # 10-20 00:25: o-01 lost three passes in a row (00:09, 00:14, 00:19) to ships that had mkfixture.ps1 open; wait up to 5 minutes for them
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do [ -z "$(git -C "$R" status --porcelain tools/mkfixture.ps1)" ] && break; say "retarget: waiting for another ship to finish with tools/mkfixture.ps1 ($name)"; sleep 20; done
    [ -n "$(git -C "$R" status --porcelain tools/mkfixture.ps1)" ] && { say "retarget: tools/mkfixture.ps1 is being edited by another worker; $name's keys wait"; return 2; }
    h0=$(git -C "$R" hash-object tools/mkfixture.ps1)
    pl=$(node "$X/retarget.mjs" plan "$js" "$R/tools/mkfixture.ps1" "$ap" "$out" 2>&1); echo "$pl" > "$LS/retarget-plan.txt"
    st=$(printf '%s\n' "$pl" | sed -n 's/^STATUS //p' | head -1)
    case "$st" in
      nothing) RT_HOLD=""; return 0;;
      ok) ;;
      refused) appendfb "The lane REFUSED fixture-retarget.json: tools/mkfixture.ps1 is unchanged and nothing was committed. Fix the file and end again:
$(printf '%s\n' "$pl" | sed -n 's/^MSG /- /p' | head -8)"; return 1;;
      *) log "retarget plan failed for $name: $(printf '%s' "$pl" | tail -3 | tr '\n' ' ' | cut -c1-300)"; say "retarget: the lane's planner failed ($name); its keys wait"; return 2;;
    esac
    run=$(printf '%s\n' "$pl" | sed -n 's/^RUN //p' | head -1); why=$(printf '%s\n' "$pl" | sed -n 's/^WHY //p' | head -1)
    n=$(printf '%s\n' $run | grep -c .)
    if [ "$n" -gt "$(cap RETARGET_MAX_CHECKS 30)" ]; then appendfb "fixture-retarget.json would run $n checks; the most per file is $(cap RETARGET_MAX_CHECKS 30). Keep the first part in the file, end again, and send the rest in a later file."; return 1; fi
    # 1. the trial: the edited copy builds a fixture from the committed game; the checks run there (no lock, the lane's own Chrome)
    ramwait || { say "retarget: waiting for RAM ($name)"; return 2; }
    say "retarget: trying $name's fixture edit on a trial copy ($n checks)"
    git -C "$R" show HEAD:dark_raiders.html > "$game" 2>/dev/null || { say "retarget: could not read the committed game ($name); its keys wait"; return 2; }
    rm -f "$trial"
    ( cd "$R" && timeout 900 powershell -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$out")" -Src "$(cygpath -w "$game")" -Dst "$(cygpath -w "$trial")" ) > "$LS/retarget-build.txt" 2>&1
    if [ ! -s "$trial" ]; then appendfb "The edited tools/mkfixture.ps1 did not build a fixture (nothing was committed). PowerShell said:
$(tail -6 "$LS/retarget-build.txt" | cut -c1-300)"; return 1; fi
    bad=$(node "$X/retarget.mjs" jscheck "$trial" 2>&1)
    if ! printf '%s\n' "$bad" | grep -q '^JS ok'; then rm -f "$trial"; appendfb "The edited fixture does not compile (nothing was committed): $(printf '%s' "$bad" | cut -c1-400)"; return 1; fi
    if [ "$n" -gt 0 ]; then
      printf '%s\n' $run > "$lst"
      rt_checks "$lst" "$res" || { rm -f "$trial"; say "retarget: the lane's browser $PFPORT will not answer ($name); its keys wait, no run spent"; return 2; }
      miss=""; for v in $run; do grep -q "^$v: " "$res" || miss="$miss $v"; done
      if [ -n "$miss" ]; then rm -f "$trial"; log "retarget checks for $name came back incomplete (no answer for$miss)"; say "retarget: the trial checks did not all answer ($name); its keys wait"; return 2; fi
      # 10-20 (o-19): a check id may carry a letter (8.58h), and a check that answers 'SKIP: ' (a retired feature, a pane limit) counts as
      # held, but only when the edit adds no 'SKIP: ' text of its own, so a retarget can never turn a red check into a skip.
      pat='^[0-9]+\.[0-9]+[a-z]*: PASS$|^ALL DONE$|^$'
      [ "$(grep -o 'SKIP: ' "$out" | wc -l)" -le "$(grep -o 'SKIP: ' "$R/tools/mkfixture.ps1" | wc -l)" ] && pat='^[0-9]+\.[0-9]+[a-z]*: (PASS$|SKIP: )|^ALL DONE$|^$'
      bad=$(grep -vE "$pat" "$res" | head -8 | cut -c1-300)
      if [ -n "$bad" ]; then rm -f "$trial"; appendfb "A retargeted check FAILED on a trial build of the current game (v$(gamever)): tools/mkfixture.ps1 is unchanged and nothing was committed. Make it hold on the old AND the new build, then end again:
$bad"; return 1; fi
    fi
    rm -f "$trial"
    # 2. the lock, only to copy, commit and rebuild; if the fixture file moved while the trial ran, plan and try once more
    bash "$S/lock.sh" "codex-retarget-$name" > "$LS/retarget-lock.txt" 2>&1
    grep -q '^LOCKED' "$LS/retarget-lock.txt" || { say "retarget: the ship lock did not come free ($name); its keys wait"; return 2; }
    RT_LOCKED=1
    h1=$(git -C "$R" hash-object tools/mkfixture.ps1)
    if [ "$h1" != "$h0" ] || [ -n "$(git -C "$R" status --porcelain tools/mkfixture.ps1)" ]; then
      rt_unlock; [ $tries -lt 2 ] && continue
      say "retarget: tools/mkfixture.ps1 keeps changing under $name; its keys wait"; return 2; fi
    RT_BAK="$LS/mkfixture-before.ps1"; cp "$R/tools/mkfixture.ps1" "$RT_BAK"; cp "$out" "$R/tools/mkfixture.ps1"
    if ! git -C "$R" commit -q -m "fixture: codex retarget for $name: $(printf '%s' "$why" | cut -c1-80)" -- tools/mkfixture.ps1 > "$LS/retarget-commit.txt" 2>&1; then
      cp "$RT_BAK" "$R/tools/mkfixture.ps1"; RT_BAK=""; rt_unlock
      log "retarget commit failed for $name: $(tail -3 "$LS/retarget-commit.txt" | tr '\n' ' ' | cut -c1-300)"; say "retarget: the commit failed ($name); its keys wait"; return 2; fi
    RT_BAK=""; c=$(git -C "$R" log -1 --format=%h)
    ( cd "$R" && timeout 900 powershell -NoProfile -ExecutionPolicy Bypass -File tools/mkfixture.ps1 ) > "$LS/retarget-rebuild.txt" 2>&1
    rm -rf "$TEMP/pillagers-dry/"dry*
    rt_unlock
    { printf '%s\n' "$pl" | sed -n 's/^FILEHASH /file /p'; printf '%s\n' "$pl" | sed -n 's/^EDITHASH /edit /p'; } >> "$ap"
    RT_HOLD=""; RT_DONE="$c"; log "$name retarget applied in $c (checks: ${run:-none})"
    appendfb "Your fixture-retarget.json is in: commit $c.${run:+ Checks $run passed on a trial build of v$(gamever) first.}"
    return 0
  done; }

# ---- pictures and critic (the lane does these: Codex has no Chrome)
shoot(){  # shoot before|after SCREENS
  local sfx=$1 sc=$2 out="tools/handoff/console/notes/shots/$name-$1"
  ramwait || return 1
  say "pictures: $sfx $name (screens $sc, camera $CAM)"
  ( cd "$R" && timeout 900 powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 -Screens "$sc" -Out "$out" -Res 1080 -Port "$CAM" ) > "$X/log/$name-$sfx.camera.txt" 2>&1
  ls "$R/$out/"*-1080.jpg >/dev/null 2>&1; }
critic_round(){  # sets CRITWORST, CRITP (count of P0/P1), CRITTXT, PICS (absolute after-picture paths)
  local a b out sc; CRITWORST=9; CRITP=0; CRITTXT=""; PICS=()
  for a in $(ls "$R/tools/handoff/console/notes/shots/$name-after/"*-1080.jpg 2>/dev/null | head -4 | sed "s|^$R/||"); do
    b="${a/-after\//-before/}"; PICS+=("$R/$a")
    if [ -f "$R/$b" ]; then pair=("$b" "$a"); else pair=("$a"); fi
    out=$(cd "$R" && CW_TASK="$name" timeout 600 node tools/console-sdk/critic.mjs "${pair[@]}" 2>&1 | head -c 3000)
    sc=$(printf '%s' "$out" | grep -o '"score": *[0-9]' | head -1 | grep -o '[0-9]')
    CRITP=$(( CRITP + $(printf '%s' "$out" | grep -oE '"sev": *"P[01]"' | wc -l) ))
    [ -n "$sc" ] && [ "$sc" -gt 0 ] && [ "$sc" -lt "$CRITWORST" ] && CRITWORST=$sc
    CRITTXT="${CRITTXT}critic on $(basename "$a") (score ${sc:-none}):
$out
"
  done; }

# ---- camera-recipes.json (RULES-codex.md "Pictures"). 2026-10-20: the rules promised it but the lane never read the file, so o-04, o-05
#      and o-07 to o-10 shipped and then sat in waiting/ asking for their two-window pictures. The first 6 screens of the file, no BEFORE.
recipes_file(){ local f; for f in "$WD/camera-recipes.json" "$WD/"*camera-recipes.json; do [ -f "$f" ] && { echo "$f"; return; }; done; }
shoot_recipes(){  # shoot_recipes FILE ROUND -> pictures in notes/shots/NAME-recipes-ROUND, the camera's words in log/NAME-recipes-ROUND.camera.txt
  local out="tools/handoff/console/notes/shots/$name-recipes-$2" cl="$LS/recipes.json" names lg="$X/log/$name-recipes-$2.camera.txt"
  rd "$1" > "$cl"
  names=$(node -e "try{const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));console.log((j.screens||[]).slice(0,6).map(x=>x&&x.name).filter(x=>typeof x==='string'&&/^[A-Za-z0-9_.-]{1,80}$/.test(x)).join(','))}catch(e){console.log('')}" "$cl" 2>/dev/null | tr -d '\r')
  [ -n "$names" ] || { echo "the recipe file has no readable screens (JSON with a screens list, each with a name of letters, digits, dots, dashes)" > "$lg"; return 1; }
  say "pictures: recipe round $2 for $name (screens $names, camera $CAM)"
  ( cd "$R" && timeout 1500 powershell -NoProfile -ExecutionPolicy Bypass -File tools/uishots.ps1 -Recipes "$(cygpath -w "$cl")" -Screens "$names" -Out "$out" -Res 1080 -Port "$CAM" ) > "$lg" 2>&1
  ls "$R/$out/"*-1080.jpg >/dev/null 2>&1; }
critic_recipes(){  # critic_recipes ROUND : sets CRITWORST, CRITP, CRITTXT, PICS; each picture alone (a recipe screen has no BEFORE)
  local a out sc; CRITWORST=9; CRITP=0; CRITTXT=""; PICS=()
  for a in $(ls "$R/tools/handoff/console/notes/shots/$name-recipes-$1/"*-1080.jpg 2>/dev/null | head -6 | sed "s|^$R/||"); do
    PICS+=("$R/$a")
    out=$(cd "$R" && CW_TASK="$name" timeout 600 node tools/console-sdk/critic.mjs "$a" 2>&1 | head -c 3000)
    sc=$(printf '%s' "$out" | grep -o '"score": *[0-9]' | head -1 | grep -o '[0-9]')
    CRITP=$(( CRITP + $(printf '%s' "$out" | grep -oE '"sev": *"P[01]"' | wc -l) ))
    [ -n "$sc" ] && [ "$sc" -gt 0 ] && [ "$sc" -lt "$CRITWORST" ] && CRITWORST=$sc
    CRITTXT="${CRITTXT}critic on $(basename "$a") (score ${sc:-none}):
$out
"
  done; }

# ================================================================ the loop: codex -> harvest -> gate -> feedback
say "running $name (codex, run $((n0+1)) of $MAXR)"
log "start $name n0=$n0 left=$left"
prevkeys=$(keys_list)
while [ "$it" -lt "$left" ]; do
  it=$((it+1))
  if [ -f "$C/STOP" ] || [ -f "$X/STOP" ]; then say "paused (STOP file); $name kept"; r="stopped"; break; fi
  wt_refresh || { say "needs you: the codex worktree cannot be refreshed (see $X/log/wt.err); $name kept"; r="stopped"; break; }
  mkdir -p "$WD"
  # 2026-10-19 night: a job that ended "waiting" (the gate or the retarget could not run, not Codex's fault) used to spend a fresh Codex
  # run on its next pick before the lane even retried. Now the first pass retries the gate with the files as they are, and runs no Codex.
  GO=""
  if [ "$it" = 1 ] && [ -s "$LS/waiting.txt" ]; then
  GO=1; it=0; claim=$(cat "$LS/waiting.txt"); lastclaim=$claim; rm -f "$LS/waiting.txt"; CLASS=ok; tid=$(cat "$LS/thread.txt" 2>/dev/null); RESUME_NEXT=1
  log "$name: gate-only pass (it waited last time), no codex run"; say "gate: retrying $name's waiting keys (no codex run)"
  else
  pfile="$X/log/$name-prompt-$it.txt"; mode=fresh; imgs=("${PICS[@]}"); PICS=(); sc=""
  if [ -n "$tid" ] && { [ "$it" -gt 1 ] || [ -n "$RESUME_NEXT" ]; }; then RESUME_NEXT=""; mode=resume; { echo "The workspace was refreshed to the newest master (game v$(gamever)). Your files in .codex-work/$name/ are as you left them."; printf '%s\n' "$fb"; echo; echo "Continue. End with the line TASK DONE or TASK PARTIAL: what remains."; } > "$pfile"
  else prompt_fresh "$fb" > "$pfile"; fi
  [ "$mode" = fresh ] && imgs=()
  say "running $name (codex, run $((n0+it)) of $MAXR)"
  t0=$(date +%s); run_codex "$mode" "$pfile" "${imgs[@]}"; dt=$(( $(date +%s) - t0 )); classify
  if [ "$mode" = resume ] && { [ "$CLASS" = crash ] || { [ "$CLASS" = login ] && [ $dt -lt 30 ]; }; }; then   # resume failed: one fresh run with the whole story
    log "resume failed for $name ($CLASS), trying a fresh run"; prompt_fresh "$fb" > "$pfile"; mode=fresh
    t0=$(date +%s); run_codex fresh "$pfile"; dt=$(( $(date +%s) - t0 )); classify; fi
  newtid=$(grep -o '"thread_id": *"[^"]*"' "$JSONL" 2>/dev/null | head -1 | sed 's/.*: *"\(.*\)"/\1/'); [ -n "$newtid" ] && { tid=$newtid; echo "$tid" > "$LS/thread.txt"; }
  case "$CLASS" in
    limit)
      e=$(parse_reset "$ERRTXT"); [ -z "$e" ] && e=$(( $(date +%s) + $(cap REST_DEFAULT_MIN 60) * 60 ))
      rest_until "$e" "codex usage limit"; say "resting: codex usage limit, back about $(date -d "@$e" '+%a %H:%M'); $name kept"
      echo "$(date '+%F %H:%M') $name ${dt}s usage-limit (not counted) back $(date -d "@$e" '+%F %H:%M')" >> "$X/runs.txt"; r="limit"; break;;
    login)
      say "$NEEDS_SIGNIN; $name kept"; echo "$(date '+%F %H:%M') $name ${dt}s not-signed-in (not counted)" >> "$X/runs.txt"; r="login"; break;;
    crash)
      f=$(( $(cat "$X/fails.txt" 2>/dev/null | tr -dc '0-9') + 1 )); echo "$f" > "$X/fails.txt"; m=$(( f * 10 )); [ $m -gt 60 ] && m=60
      rest_until $(( $(date +%s) + m * 60 )) "codex runs are failing ($f in a row, see $(basename "$JSONL"))"
      say "codex run ended before any work (see log/$(basename "$ERRF")); $name kept; trying again in $m min"
      echo "$(date '+%F %H:%M') $name ${dt}s crash rc=$RC (not counted)" >> "$X/runs.txt"; r="crash"; break;;
  esac
  rm -f "$X/fails.txt"
  # a counted run: work was done (or the run hit its time cut)
  claim=$(claim_of); lastclaim=$claim; wo=""; [ "$claim" = WAITING ] && wo=$(waiting_on)
  # 10-19 night: a run that ends TASK WAITING: OTHER-TASK-ID is not a try (spend line NAME-wait); the job parks in blocked/ below
  if [ -n "$wo" ]; then echo "$today 0.0000 $name-wait" >> "$C/cli-spend.txt"; else echo "$today 0.0000 $name" >> "$C/cli-spend.txt"; fi
  echo "$(date '+%F %H:%M') $name ${dt}s $CLASS $claim $(tokens) run=$((n0+it))" >> "$X/runs.txt"
  git -C "$W" status --porcelain -uno 2>/dev/null | head -5 > "$X/log/$name-edits-in-copy.txt"
  harvest
  fi
  fb=""; SHIPPED_NOW=(); gate=0; keys=$(keys_list); sc=$(screens_list)
  [ "$CLASS" = timeout ] && appendfb "Your last run was cut after $(cap RUN_MIN 45) minutes. Whatever is in .codex-work/$name was kept. Finish in fewer steps."
  rtg=0; RT_HOLD=""; RT_DONE=""
  [ -f "$WD/fixture-retarget.json" ] && { apply_retarget; rtg=$?; }
  if [ -n "$keys" ]; then
    first_unshipped=$(for k in $keys; do grep -qxF "$k" "$LS/shipped.txt" || { echo "$k"; break; }; done)
    # BEFORE pictures: once, before the first ship of this job
    if [ -n "$sc" ] && [ -n "$first_unshipped" ] && [ ! -d "$R/tools/handoff/console/notes/shots/$name-before" ]; then shoot before "$sc" || appendfb "(The lane could not take the BEFORE pictures: see log/$name-before.camera.txt.)"; fi
    for k in $keys; do
      if [ $rtg != 0 ] && { [ "$RT_HOLD" = "*" ] || printf '%s\n' $RT_HOLD | grep -qxF "$k"; }; then continue; fi
      ship_key "$k"; g=$?
      [ $g = 0 ] && continue
      gate=$g; break
    done
  fi
  if [ $rtg != 0 ] && [ -n "$keys" ]; then
    held=$(for k in $keys; do grep -qxF "$k" "$LS/shipped.txt" && continue; { [ "$RT_HOLD" = "*" ] || printf '%s\n' $RT_HOLD | grep -qxF "$k"; } && echo "$k"; done | tr '\n' ' ')
    [ -n "$held" ] && appendfb "Not shipped yet, they wait on the fixture retarget: $held"; fi
  [ $gate = 0 ] && [ $rtg != 0 ] && gate=$rtg
  [ ${#SHIPPED_NOW[@]} -gt 0 ] && appendfb "Shipped: ${SHIPPED_NOW[*]} (game now v$(grep -m1 "^var VER='" "$R/dark_raiders.html" 2>/dev/null | sed "s/var VER='\([0-9]*\.[0-9]*\)'.*/\1/"))."
  if [ $gate = 2 ]; then r="waiting"; break; fi          # not Codex's fault: leave the job and try later
  if [ -n "$wo" ] && [ $gate = 0 ]; then r="blocked"; break; fi   # Codex says the rest waits on another task: park it, spend no more runs
  if [ $gate = 0 ]; then
    need=0
    if [ ${#SHIPPED_NOW[@]} -gt 0 ] && [ -n "$sc" ] && [ "$picrounds" -lt "$PICMAX" ]; then
      picrounds=$((picrounds+1)); echo "$picrounds" > "$LS/picrounds.txt"
      if shoot after "$sc"; then critic_round
        appendfb "PICTURES (screens $sc) are in $RW/tools/handoff/console/notes/shots/$name-before/ and $name-after/ (the newest ones are attached; open them with your image viewer). CRITIC, round $picrounds of $PICMAX:
$CRITTXT"
        [ "$CRITWORST" -lt "$OKSC" ] && [ "$CRITP" -gt 0 ] && need=1
      else appendfb "(The lane could not take the AFTER pictures: see log/$name-after.camera.txt.)"; fi
    fi
    rfile=$(recipes_file); CAM_DONE=""
    if [ -n "$rfile" ]; then
      rver=$(grep -m1 "^var VER='" "$R/dark_raiders.html" 2>/dev/null | sed "s/var VER='\([0-9]*\.[0-9]*\)'.*/\1/")
      rkey="$(rd "$rfile" | sha256sum | cut -c1-16) v$rver"; camr=$(cat "$LS/camrounds.txt" 2>/dev/null); camr=${camr:-0}
      if [ "$rkey" != "$(cat "$LS/camkey.txt" 2>/dev/null)" ] && [ "$camr" -lt "$(cap CAMERA_ROUNDS 4)" ]; then   # a changed file or a new version
        # short of memory: the job waits (no Codex run, no round used) and its next pick starts with the gate-only pass
        ramwait || { say "pictures: waiting for RAM before $name's recipe round"; r="waiting"; break; }
        camr=$((camr+1)); echo "$camr" > "$LS/camrounds.txt"; echo "$rkey" > "$LS/camkey.txt"; CAM_DONE=1
        if shoot_recipes "$rfile" "$camr"; then critic_recipes "$camr"
          appendfb "RECIPE PICTURES (round $camr of $(cap CAMERA_ROUNDS 4), $(basename "$rfile") on v$rver) are in $RW/tools/handoff/console/notes/shots/$name-recipes-$camr/ (the newest are attached; open them with your image viewer). The camera said:
$(tail -c 1500 "$X/log/$name-recipes-$camr.camera.txt")
CRITIC:
$CRITTXT"
          [ "$CRITWORST" -lt "$OKSC" ] && [ "$CRITP" -gt 0 ] && need=1
        else appendfb "(The lane could not take the recipe pictures, round $camr. The camera said: $(tail -c 1200 "$X/log/$name-recipes-$camr.camera.txt"))"; fi
      fi
    fi
    if [ "$claim" = DONE ] && [ $need = 0 ]; then r=done; break; fi
    if [ "$claim" = DONE ] && [ $need = 1 ]; then appendfb "You said TASK DONE, but the critic is below $OKSC on a screen with P0/P1 findings. Fix them (new key) unless a finding would reverse one of his rulings or the finish lines in RULES.md say this screen is good enough; then end with TASK DONE."; idle=0
    else
      if [ -n "$GO" ] || [ ${#SHIPPED_NOW[@]} -gt 0 ] || [ -n "$RT_DONE" ] || [ -n "$CAM_DONE" ]; then idle=0; else idle=$((idle+1)); fi
      # 2026-10-19 (o-01 and o-04 each spent 3 runs asking the lane for pictures and fixture edits after they shipped): once this job has
      # shipped, a run that ships nothing and drafts no new key means only lane-side steps are left. Park it in waiting/, spend no more runs.
      if [ "$idle" -ge 1 ] && [ -s "$LS/shipped.txt" ] && [ "$keys" = "$prevkeys" ]; then r="parked"; break; fi
      [ "$idle" -ge 2 ] && { r="partial-idle"; break; }
      appendfb "You ended with ${claim}. Continue with what remains of the task; when everything is shipped end with TASK DONE."
    fi
  else
    idle=0
  fi
  prevkeys=$keys
done

# ---- the end of this job's turn
n=$(cat "$C/spend.txt" "$C/cli-spend.txt" 2>/dev/null | grep -c " $name$")
case "$r" in
  parked)   # 2026-10-19: shipped, only lane-side steps left (pictures, fixture retargets, two-window checks); the coordinator finishes it
    final="parked"; mv "$t" "$C/waiting/"
    { echo; echo "Lane note $(date '+%F %H:%M'): shipped $(tr '
' ' ' < "$LS/shipped.txt" 2>/dev/null)and parked: only lane-side steps are left. Codex's last words:"; tail -c 700 "$LAST" 2>/dev/null; echo; } >> "$C/waiting/$(basename "$t")"
    echo "$(date '+%m-%d %H:%M') $name: shipped, parked in waiting/ (lane-side steps left), codex" | tee -a "$C/runs.log" > "$C/status-$L.txt";;
  blocked)   # 10-19 night: TASK WAITING: the console lanes' release() puts it back in tasks/ once the other task is gone (or after BLOCK_MAX_H)
    final="waiting on $wo"; mkdir -p "$C/blocked"; mv "$t" "$C/blocked/" && touch "$C/blocked/$(basename "$t")" && echo "$wo" > "$C/blocked/$name.on"
    echo "$(date '+%m-%d %H:%M') $name: waiting on $wo, parked in blocked/ (not counted as a try), codex" | tee -a "$C/runs.log" > "$C/status-$L.txt";;
  limit|login|crash|stopped|waiting)   # the job stays where it is; the status line was written where it happened
    final="$r"; echo "$(date '+%m-%d %H:%M') $name: codex $r; kept (runs so far: $n of $MAXR)" >> "$C/runs.log"
    [ "$r" = waiting ] && { echo "${lastclaim:-NONE}" > "$LS/waiting.txt"; say "gate waiting on another worker; $name kept (codex)"; };;
  *)
    if [ "$r" = done ]; then mv "$t" "$C/done/"; final=done
    elif [ "$n" -ge "$MAXR" ]; then mv "$t" "$C/failed/"; final=failed
    else final="partial (run $n of $MAXR)"; fi
    echo "$(date '+%m-%d %H:%M') $name: $final, codex" | tee -a "$C/runs.log" > "$C/status-$L.txt";;
esac
log "end $name: $final"
# a run that did real work (a minute or more) starts the next job at once, as console-lane.sh does; never after a rest or a stop
if [ -z "$CX_NOCHAIN" ] && [ $(( $(date +%s) - st )) -ge 60 ] && [ "$r" != limit ] && [ "$r" != login ] && [ "$r" != crash ] && [ "$r" != stopped ] && [ "$r" != waiting ]; then
  rm -rf "$LK"; trap - EXIT; exec bash "$SELF"; fi
