#!/bin/bash
# shipone.sh KEY PREV NEW : the strict one-build chain for a reviewed draft in tools/handoff/drafts/draft-KEY.json.
# Stops at the first gate that does not hold. Uses gate Chrome 9335 and :8806.
K=$1; PREV=$2; NEW=$3; GCDP=${GATE_CDP:-9344}   # GATE_CDP=9346 to ship on a second gate Chrome while 9344 is busy
R="/c/claudecode/dark raiders"; H="$R/tools/handoff"; D="$H/drafts"
V="${NEW:0:2}.${NEW:2}"; NN="${NEW:2}"
ps(){ powershell -NoProfile -ExecutionPolicy Bypass "$@" 2>&1; }
die(){ echo "STOP $NEW ($K): $*"; [ -n "$STARTED" ] && undo; exit 1; }
# 10-21 02:23: verifySafe timed out (Windows was out of virtual memory) AFTER ship.sh start had written v33.57 into the tree, and
# nothing put it back, so every ship STOPped on "uncommitted changes" for 40 minutes. A stop after the start now saves the drafted
# build as a patch and puts the four files it wrote back at HEAD.
undo(){ cd "$R" || return; local p="$H/console/log/unshipped-$NEW-$K-$(date +%m%d-%H%M).patch"
  git diff -- dark_raiders.html tools/mkfixture.ps1 DESIGN.md AUDIT.md > "$p" 2>/dev/null
  git checkout -q -- dark_raiders.html tools/mkfixture.ps1 DESIGN.md AUDIT.md && echo "undone: the tree is back at HEAD (the drafted build is in $p)"; }
cd "$R" || exit 1
[ -n "$(git status --porcelain dark_raiders.html tools/mkfixture.ps1)" ] && die "the game or fixture has uncommitted changes"
NOW=$(powershell -NoProfile -Command "(Get-Content -Raw '$(cygpath -w "$D/draft-$K.json")' | ConvertFrom-Json).now")
[ -z "$NOW" ] && die "no now text"
g=$(ps -File "$(cygpath -w "$D/gen-draft.ps1")" -Key "$K" -New "$NEW"); echo "gen: $g"
echo "$g" | grep -q "^generated" || die "gen-draft failed"
dr=$(ps -File "$(cygpath -w "$H/dryrun.ps1")" -Prev "$PREV" -New "$NEW"); echo "$dr" | tail -4
echo "$dr" | grep -q "^p$NEW -> OK" || die "the build patch did not apply"
echo "$dr" | grep -q "^f$NEW -> OK" || die "the check patch did not apply"
gt=$(ps -File "$(cygpath -w "$R/tools/gate.ps1")" -NN "$NN" -V "$V" -Cdp $GCDP); echo "$gt" | cut -c1-400
echo "$gt" | grep -q "^parse: PASS" || die "parse check"
echo "$gt" | grep -q "^dry fxdry$NN check $V: PASS / PASS" || die "new check does not pass twice on the drafted build"
c=$(echo "$gt" | grep "^control fxctl$NN check $V:")
[ -z "$c" ] && die "no control result"
echo "$c" | grep -q "check $V: PASS\|check $V: SKIP\|NO CHECK\|TIMEOUT" && die "control did not fail: $c"
rc=$(ps -File "$(cygpath -w "C:/claudecode/dark raiders/tools/handoff/recent.ps1")" -NN "$NN" -Cdp $GCDP); echo "$rc" | cut -c1-300
echo "$rc" | grep -q "^recent: 0 new" || die "an older check fails on the drafted build: $(echo "$rc" | head -3)"
STARTED=1; bash "$H/ship.sh" start "$PREV" "$NEW" 2>&1 | tail -6
fx=$(ps -File "$(cygpath -w "$R/tools/gate.ps1")" -Fix -V "$V" -Cdp $GCDP); echo "$fx" | cut -c1-400
echo "$fx" | grep -q "check $V: PASS / PASS" || die "the new check fails on the shipped fixture"
echo "$fx" | grep -q '"pass":true' || die "verifySafe did not pass"
echo "$fx" | grep -q '"ents":{"0":85,"1":374}' || die "entity fingerprint moved"
echo "$fx" | grep -q '"containers":{"0":165,"1":593}' || die "container fingerprint moved"
cd "$H" && bash ship.sh commit "$NEW" "cm$NEW.txt" 2>&1 | tail -3
git -C "$R" log -1 --format=%s | grep -q "^v$V:" || die "the save step did not commit v$V (10-19: a missing tools/publish folder let SHIPPED print with nothing saved)"
cd "$R" && git push -q origin master 2>&1 | tail -2
echo "SHIPPED v$V ($K): $(git log --oneline -1)"
