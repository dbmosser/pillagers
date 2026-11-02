#!/bin/bash
# gate-remote.sh : THE SHIPPER'S HALF OF THE REMOTE GATE (11-02, his orders "move pillagers html development to the main PC permanently" and "use
# the JTPC for pillagers html testing"). With GATE_REMOTE=1 (tools/handoff/console/caps.txt; the environment wins) no Chrome starts on the machine
# that ships. preflight.sh and shipone.sh hand this script a drafted build; it puts the job on the gate-jobs branch, the spare PC's runner runs it
# (tools/spare/gate-job.ps1), and the answer comes back on spare-results as spare/DESKTOP-82BKOP4/gate/ID.txt. Notes: tools/handoff/console/notes/move/remote-gate.md
#   gate-remote.sh on                                  prints 1 when the remote gate is on
#   gate-remote.sh hash-game FILE | hash FILE          the hashes both ends use
#   gate-remote.sh run KIND KEY TAG V NEW DRAFT P F GAME FIX    KIND preflight or ship. Prints the stage lines word for word, for the same tests a
#                                                      local gate gets, and exits 0. Exits 3 with no stage lines when there is no answer it can trust.
#   gate-remote.sh shots SCREENS RES OUT [NOLINT] [RECIPES] [LINTJS] [LINTOPTS]   pictures of the current build, taken on the spare PC, into OUT
# Never passes by default: no answer, a timeout, or an answer that names another draft or base prints REMOTE and exits 3, and the callers stop.
# Waiting: GATE_WAIT_MIN (60) while the spare PC has not started the job (someone is at it, or another job is first), GATE_RUN_MIN (50) once it
# has. The ship lock stays held for that long at most; its owner's pid is alive, so clearstale.sh calls it held.
# A second call for the same draft on the same base joins the job already there and reads a PASS already there; a FAIL is run again.
R="${PILLAGERS_ROOT:-/c/claudecode/dark raiders}"; H="$R/tools/handoff"; SPARE=DESKTOP-82BKOP4
S="${PILLAGERS_SCRATCH:-C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad}"
MAIL=gate-jobs; RES=spare-results; JREF=refs/gate-remote/gate-jobs; RREF=refs/gate-remote/spare-results
WAIT_MIN=${GATE_WAIT_MIN:-60}; RUN_MIN=${GATE_RUN_MIN:-50}; POLL=${GATE_POLL:-20}
export LC_ALL=C
cd "$R" || exit 3
say(){ echo "$*" >&2; if [ -n "$GATE_SAY_FD" ]; then echo "$*" >&"$GATE_SAY_FD"; fi 2>/dev/null; }
no(){ echo "REMOTE: $*"; exit 3; }
nh(){ tr -d '\r' < "$1" | sha256sum | cut -c1-64; }
nhs(){ tr -d '\r' | sed "/^var \(VER_AT\|WHATSNEW_AT\)='/d" | sha256sum | cut -c1-64; }
nhg(){ nhs < "$1"; }
gate_on(){ local v="$GATE_REMOTE"; [ -z "$v" ] && v=$(grep -a '^GATE_REMOTE=' "$H/console/caps.txt" 2>/dev/null | tail -1 | cut -d= -f2 | tr -d '\r '); [ "$v" = 1 ] && echo 1 || echo 0; }
TMPD="${TEMP:-/tmp}/pillagers-gate"

# commits on the gate-jobs branch with a private index: the working tree, the current branch and the real index of this copy are never touched.
#   mail add ID FILE::NAME...   or   mail del ID
mail(){ local op=$1 id=$2; shift 2; local k parent tmp ok
  mkdir -p "$TMPD" || return 1
  for k in 1 2 3 4 5 6 7 8; do
    git fetch -q origin "+refs/heads/$MAIL:$JREF" 2>/dev/null
    parent=$(git rev-parse -q --verify "$JREF" 2>/dev/null)
    tmp=$(cygpath -m "$TMPD/idx.$$"); rm -f "$tmp"
    (
      export GIT_INDEX_FILE="$tmp"
      if [ -n "$parent" ]; then git read-tree "$parent" || exit 1; fi
      # jobs past their time are nobody's now
      git ls-files -- gate/jobs | cut -d/ -f3 | sort -u | while read -r j; do
        e=$(git show "$parent:gate/jobs/$j/job.txt" 2>/dev/null | tr -d '\r' | sed -n 's/^expires=//p')
        if [ -n "$e" ] && [ "$e" -lt "$(date +%s)" ]; then git ls-files -- "gate/jobs/$j" | while read -r f; do git update-index --force-remove "$f"; done; fi
      done
      if [ "$op" = add ]; then
        for c in "$@"; do b=$(git hash-object -w --no-filters "${c%%::*}") || exit 1; git update-index --add --cacheinfo "100644,$b,gate/jobs/$id/${c##*::}" || exit 1; done
      else
        git ls-files -- "gate/jobs/$id" | while read -r f; do git update-index --force-remove "$f"; done
      fi
      tree=$(git write-tree) || exit 1
      if [ -n "$parent" ]; then
        [ "$(git rev-parse "$parent^{tree}")" = "$tree" ] && exit 0
        c=$(git commit-tree "$tree" -p "$parent" -m "gate: $op $id")
      else
        c=$(git commit-tree "$tree" -m "gate: $op $id")
      fi
      [ -n "$c" ] && git push -q origin "$c:refs/heads/$MAIL" 2>/dev/null
    ); ok=$?
    rm -f "$tmp" "$tmp.lock"
    [ "$ok" = 0 ] && return 0
    sleep $((k+RANDOM%5))
  done
  return 1; }

# the commit the spare PC can fetch that holds this game and fixture: HEAD, or the newest one GitHub has with the same two files, or HEAD after a push
pick_base(){ local h mb w
  for w in 1 2 3; do
    git update-index -q --refresh >/dev/null 2>&1
    [ -z "$(git status --porcelain dark_raiders.html tools/mkfixture.ps1)" ] && break
    [ "$w" = 3 ] && return 1
    say "the game or fixture has uncommitted changes (a ship going on?); looking again in 60 s"; sleep "${SHIP_DIRTY_WAIT:-60}"
  done
  git fetch -q origin master 2>/dev/null || return 2
  h=$(git rev-parse HEAD)
  if git merge-base --is-ancestor "$h" origin/master; then echo "$h"; return 0; fi
  mb=$(git merge-base "$h" origin/master)
  if [ -n "$mb" ] && [ "$(git rev-parse "$mb:dark_raiders.html")" = "$(git rev-parse "$h:dark_raiders.html")" ] && [ "$(git rev-parse "$mb:tools/mkfixture.ps1")" = "$(git rev-parse "$h:tools/mkfixture.ps1")" ]; then echo "$mb"; return 0; fi
  git push -q origin master 2>/dev/null; git fetch -q origin master 2>/dev/null
  if git merge-base --is-ancestor "$h" origin/master; then echo "$h"; return 0; fi
  return 2; }

res_fetch(){ git fetch -q origin "+refs/heads/$RES:$RREF" 2>/dev/null; }
res_of(){ git show "$RREF:spare/$SPARE/gate/$1.txt" 2>/dev/null | tr -d '\r'; }
fld(){ printf '%s\n' "$1" | sed -n "/^--- stages\$/q;s/^$2=//p" | head -1; }
stages(){ printf '%s\n' "$1" | sed -n '/^--- stages$/,/^--- end$/p' | sed '1d;$d'; }

# waits for the answer. Sets ANSWER. Returns 1 with TIMEOUT_WHY when the time is up.
wait_answer(){ local id=$1 tip seen="" st ep age tr gt msg="" last="" lastT=0 now t waited=0 runS=0 runT=0 prev
  prev=$(date +%s); ANSWER=""
  while :; do
    tip=$(git ls-remote origin "refs/heads/$RES" 2>/dev/null | cut -f1)
    if [ -n "$tip" ] && [ "$tip" != "$seen" ]; then
      seen=$tip; res_fetch
      ANSWER=$(res_of "$id")
      if [ -n "$ANSWER" ] && printf '%s\n' "$ANSWER" | grep -q '^done=1$'; then return 0; fi
      ANSWER=""
      st=$(git show "$RREF:spare/$SPARE/status.txt" 2>/dev/null | tr -d '\r')
      ep=$(printf '%s\n' "$st" | sed -n 's/^epoch=//p'); tr=$(printf '%s\n' "$st" | sed -n 's/^test_run=//p'); gt=$(printf '%s\n' "$st" | sed -n 's/^gate=//p')
      age=$(( ($(date +%s) - ${ep:-0}) / 60 )); runS=0
      if [ "$age" -ge 30 ]; then msg="waiting for the spare pc: no report from it for $age minutes"
      elif ! printf '%s\n' "$st" | grep -q '^gate_cap=1'; then msg="waiting for the spare pc: its runner does not have the remote gate yet"
      elif [ "${gt%% *}" = running ] && [ "$(printf '%s' "$gt" | cut -d' ' -f2)" = "$id" ]; then msg="the spare pc is running this job"; runS=1
      elif [ "${gt%% *}" = running ]; then msg="waiting for the spare pc: it is checking another draft first"
      else case "$tr" in paused*) msg="waiting for the spare pc: someone is using it";; *) msg="waiting for the spare pc to pick the job up";; esac; fi
    fi
    now=$(date +%s); t=$((now-prev)); prev=$now
    if [ "$runS" = 1 ]; then runT=$((runT+t)); else waited=$((waited+t)); runT=0; fi
    if [ -n "$msg" ] && { [ "$msg" != "$last" ] || [ $((now-lastT)) -ge 300 ]; }; then
      say "$msg"
      [ "$msg" != "$last" ] && echo "$(date +%H:%M) ${KEYNAME:-gate}: $msg" >> "$S/shipq.log" 2>/dev/null
      last=$msg; lastT=$now
    fi
    if [ "$waited" -ge $((WAIT_MIN*60)) ]; then TIMEOUT_WHY="${msg:-no word from the spare pc} (after $WAIT_MIN minutes)"; return 1; fi
    if [ "$runT" -ge $((RUN_MIN*60)) ]; then TIMEOUT_WHY="the spare pc ran the job for over $RUN_MIN minutes"; return 1; fi
    sleep "$POLL"
  done; }

check_answer(){ local a=$1 want k v
  while read -r k want; do
    v=$(fld "$a" "$k")
    if [ "$v" != "$want" ]; then echo "REMOTE: refused the result: it names $k=$v, this job is $k=$want"; return 3; fi
  done
  if [ "$(fld "$a" host)" != "$SPARE" ]; then echo "REMOTE: refused the result: it came from $(fld "$a" host)"; return 3; fi
  if ! printf '%s\n' "$a" | tail -1 | grep -q '^done=1$'; then echo "REMOTE: refused the result: it is cut off"; return 3; fi
  return 0; }

submit(){ local id=$1 jf=$2; shift 2; mail add "$id" "$jf::job.txt" "$@" || no "could not put the job on GitHub"; say "job $id is with the spare pc"; }

case "$1" in
on) gate_on; exit 0;;
hash) nh "$2"; exit 0;;
hash-game) nhg "$2"; exit 0;;
run)
  KIND=$2; KEY=$3; TAG=$4; V=$5; NEW=$6; DRAFT=$7; PF=$8; FF=$9; GAME=${10}; FIX=${11}; KEYNAME=$KEY
  case "$KIND" in preflight|ship) ;; *) no "unknown kind $KIND";; esac
  for f in "$DRAFT" "$PF" "$FF" "$GAME" "$FIX"; do [ -f "$f" ] || no "no file $f"; done
  BASE=$(pick_base); rc=$?
  [ "$rc" = 1 ] && no "the game or fixture has uncommitted changes"
  [ -z "$BASE" ] && no "this copy's game is not on GitHub and could not be pushed"
  DS=$(nh "$DRAFT"); PS=$(nh "$PF"); FS=$(nh "$FF"); GS=$(nhg "$GAME"); XS=$(nh "$FIX")
  SAFE=$(printf '%s' "$KEY" | tr -c 'A-Za-z0-9_-' '_' | cut -c1-40)
  ID0="$KIND-$SAFE-$(printf '%s\n' "$KIND" "$KEY" "$TAG" "$V" "$NEW" "$BASE" "$DS" "$PS" "$FS" "$GS" "$XS" | sha256sum | cut -c1-12)"
  mkdir -p "$TMPD"; JF="$TMPD/job.$$.txt"; trap 'rm -f "$JF"' EXIT
  res_fetch; git fetch -q origin "+refs/heads/$MAIL:$JREF" 2>/dev/null
  ID=""; ANSWER=""
  for n in "" -r2 -r3 -r4 -r5 -r6 -r7 -r8 -r9; do
    a=$(res_of "$ID0$n")
    if [ -n "$a" ]; then
      if [ "$(fld "$a" result)" = PASS ]; then ID="$ID0$n"; ANSWER=$a; break; fi
      continue
    fi
    ID="$ID0$n"; break
  done
  [ -z "$ID" ] && no "nine tries of this draft on this base already failed"
  if [ -z "$ANSWER" ]; then
    e=$(git show "$JREF:gate/jobs/$ID/job.txt" 2>/dev/null | tr -d '\r' | sed -n 's/^expires=//p')
    if [ -n "$e" ] && [ "$e" -gt "$(date +%s)" ]; then say "joining job $ID, already with the spare pc"
    else
      { echo "id=$ID"; echo "kind=$KIND"; echo "key=$KEY"; echo "tag=$TAG"; echo "v=$V"; echo "new=$NEW"; echo "base=$BASE"; echo "draft_sha=$DS"; echo "p_sha=$PS"; echo "f_sha=$FS"; echo "game_sha=$GS"; echo "fix_sha=$XS"; echo "from=$(hostname)"; echo "submitted=$(date +%s)"; echo "expires=$(( $(date +%s) + (WAIT_MIN+RUN_MIN)*60 ))"; } > "$JF"
      submit "$ID" "$JF" "$DRAFT::draft.json" "$PF::p.ps1" "$FF::f.ps1"
    fi
    wait_answer "$ID" || { mail del "$ID"; no "$TIMEOUT_WHY"; }
  fi
  a=$ANSWER
  mail del "$ID"
  if [ "$(fld "$a" infra)" = 1 ]; then echo "REMOTE: the spare pc could not run it: $(fld "$a" reason)"; exit 3; fi
  check_answer "$a" <<CHK || exit 3
id $ID
kind $KIND
key $KEY
tag $TAG
v $V
new $NEW
base $BASE
draft_sha $DS
p_sha $PS
f_sha $FS
game_sha $GS
fix_sha $XS
CHK
  stages "$a"
  echo "REMOTE VERIFIED $ID base=$BASE draft=$DS spare=$(fld "$a" result): $(fld "$a" reason)"
  exit 0;;
shots)
  SCR=$2; RS=$3; OUT=$4; NOL=$5; REC=$6; LJS=$7; LOP=$8; KEYNAME="shots"
  [ "$REC" = "-" ] && REC=""; [ "$LJS" = "-" ] && LJS=""; [ "$LOP" = "-" ] && LOP=""   # uishots.ps1 sends - for empty: Windows PowerShell 5.1 drops empty arguments
  OUTU=$(cygpath -u "$OUT"); mkdir -p "$OUTU" || no "cannot make $OUT"
  BASE=$(pick_base); rc=$?
  [ "$rc" = 1 ] && no "the game or fixture has uncommitted changes"
  [ -z "$BASE" ] && no "this copy's game is not on GitHub and could not be pushed"
  ex=(); hs=""
  if [ -n "$REC" ]; then ex+=("$(cygpath -u "$REC")::recipes.json"); hs="$hs $(nh "$(cygpath -u "$REC")")"; fi
  if [ -n "$LJS" ]; then ex+=("$(cygpath -u "$LJS")::lint.js"); hs="$hs $(nh "$(cygpath -u "$LJS")")"; fi
  ID0="shots-$(printf '%s\n' "$SCR" "$RS" "$NOL" "$LOP" "$hs" "$BASE" | sha256sum | cut -c1-12)"
  mkdir -p "$TMPD"; JF="$TMPD/job.$$.txt"; trap 'rm -f "$JF"' EXIT
  res_fetch; git fetch -q origin "+refs/heads/$MAIL:$JREF" 2>/dev/null
  ID=""; ANSWER=""
  for n in "" -r2 -r3 -r4 -r5 -r6 -r7 -r8 -r9; do
    a=$(res_of "$ID0$n")
    if [ -n "$a" ]; then
      if [ "$(fld "$a" result)" = PASS ]; then ID="$ID0$n"; ANSWER=$a; break; fi
      continue
    fi
    ID="$ID0$n"; break
  done
  [ -z "$ID" ] && no "nine tries of these pictures already failed"
  if [ -z "$ANSWER" ]; then
    e=$(git show "$JREF:gate/jobs/$ID/job.txt" 2>/dev/null | tr -d '\r' | sed -n 's/^expires=//p')
    if [ -n "$e" ] && [ "$e" -gt "$(date +%s)" ]; then say "joining job $ID, already with the spare pc"
    else
      { echo "id=$ID"; echo "kind=shots"; echo "key=shots"; echo "tag=shots"; echo "v="; echo "new="; echo "base=$BASE"; echo "screens=$SCR"; echo "res=$RS"; echo "nolint=$NOL"; echo "lintopts=$LOP"; echo "from=$(hostname)"; echo "submitted=$(date +%s)"; echo "expires=$(( $(date +%s) + (WAIT_MIN+RUN_MIN)*60 ))"; } > "$JF"
      submit "$ID" "$JF" "${ex[@]}"
    fi
    wait_answer "$ID" || { mail del "$ID"; no "$TIMEOUT_WHY"; }
  fi
  a=$ANSWER; mail del "$ID"
  if [ "$(fld "$a" infra)" = 1 ]; then echo "REMOTE: the spare pc could not run it: $(fld "$a" reason)"; exit 3; fi
  if [ "$(fld "$a" base)" != "$BASE" ] || [ "$(fld "$a" id)" != "$ID" ] || [ "$(fld "$a" host)" != "$SPARE" ]; then no "refused the result: it names another job"; fi
  stages "$a"
  [ "$(fld "$a" result)" = PASS ] || no "$(fld "$a" reason)"
  git -c core.autocrlf=false archive "$RREF" "spare/$SPARE/gate/$ID-shots" | (cd "$OUTU" && tar -xf - --strip-components=4) || no "could not bring the pictures back"
  echo "REMOTE VERIFIED $ID base=$BASE pictures in $OUT"
  exit 0;;
*) echo "usage: gate-remote.sh on | hash FILE | hash-game FILE | run KIND KEY TAG V NEW DRAFT P F GAME FIX | shots SCREENS RES OUT [NOLINT] [RECIPES] [LINTJS] [LINTOPTS]"; exit 2;;
esac
