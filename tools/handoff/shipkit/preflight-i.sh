#!/bin/bash
# preflight.sh LANE cw-KEY : the ship gate WITHOUT the ship lock (2026-10-17, his "is there a way to use more of my pc resources to
# speed/improve development?"). On the morning of 10-17 the one real gate saw about 25 STOPs for 2 ships. Each worker lane now
# has its own Chrome (a 9351, b 9352, c 9353) and private file names (pfa, pfb, pfc), and runs the gates of shipone.sh up to the
# older checks: the mk script, the build patch, the check patch, the parse check, the new check twice on the drafted build, the
# control failing on the current build, and the newest 80 older checks. Nothing in the repo changes. PASS: queue it with shipq.sh.
S="C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad"
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; L=$1; K=$2
case "$L" in a) n=1;; b) n=2;; c) n=3;; d) n=4;; e) n=5;; f) n=6;; g) n=7;; h) n=8;; i) n=9;; *) echo "usage: preflight.sh a|b|c|d|e|f|g|h cw-KEY"; exit 2;; esac
T="pf$L"; CDP=$((9350+n))
die(){ echo "PREFLIGHT FAIL ($K): $*"; exit 1; }
pw(){ powershell -NoProfile -ExecutionPolicy Bypass "$@" 2>&1; }
cleanup(){ rm -f "$H/p$T.ps1" "$H/f$T.ps1" "$R/tools/fxdry$T.html" "$R/tools/fxctl$T.html"; rm -rf "$TEMP/pillagers-dry/pf$T"; }
trap cleanup EXIT
[ -f "$S/mk-$K.ps1" ] || die "no mk-$K.ps1 in the scratchpad"
cd "$R" || exit 1
ver=$(grep -m1 "^var VER='" dark_raiders.html | sed "s/var VER='\([0-9]*\)\.\([0-9]*\)'.*/\1\2/"); NEW=$((ver+1)); V="${NEW:0:2}.${NEW:2}"
mk=$(pw -File "$(cygpath -w "$S/mk-$K.ps1")"); echo "$mk" | grep -q "written" || die "the mk script failed: $(echo "$mk" | tail -c 500)"
g=$(pw -File "$(cygpath -w "$H/drafts/gen-draft-pf.ps1")" -Key "$K" -New "$NEW" -Out "$T"); echo "$g" | grep -q "^generated" || die "gen-draft: $(echo "$g" | tail -c 400)"
dr=$(pw -File "$(cygpath -w "$H/dryrun-pf.ps1")" -Tag "$T")
echo "$dr" | grep -q "^p$T -> OK" || die "the build patch did not apply: $(echo "$dr" | grep "^p$T" | cut -c1-400)"
echo "$dr" | grep -q "^f$T -> OK" || die "the check patch did not apply: $(echo "$dr" | grep "^f$T" | cut -c1-400)"
curl -s -m 5 "http://127.0.0.1:$CDP/json/version" > /dev/null || { pw -File "$(cygpath -w "$R/tools/cdp.ps1")" -Start -Port $CDP -Profile "$(cygpath -w "$TEMP")\pillagers-cdp$CDP" > /dev/null; sleep 4; }
gt=$(pw -File "$(cygpath -w "$R/tools/gate.ps1")" -NN "$T" -V "$V" -Cdp $CDP)
echo "$gt" | grep -q "^parse: PASS" || die "parse check: $(echo "$gt" | head -3 | cut -c1-300)"
echo "$gt" | grep -q "^dry fxdry$T check $V: PASS / PASS" || die "the new check does not pass twice on the drafted build: $(echo "$gt" | grep '^dry' | cut -c1-400)"
c=$(echo "$gt" | grep "^control fxctl$T check $V:"); [ -z "$c" ] && die "no control result"
echo "$c" | grep -q "check $V: PASS\|check $V: SKIP\|NO CHECK\|TIMEOUT" && die "the control did not fail, so the check cannot tell the old build from the new: $c"
rc=$(pw -File "$(cygpath -w "$H/recent.ps1")" -NN "$T" -Cdp $CDP)
echo "$rc" | grep -q "^recent: 0 new" || die "an older check fails on the drafted build: $(echo "$rc" | head -4 | cut -c1-400)"
echo "PREFLIGHT PASS ($K) as v$V: queue it now with shipq.sh"
