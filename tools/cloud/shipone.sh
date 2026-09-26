#!/bin/bash
# shipone.sh PREV NEW: the whole gated ship for one drafted build, stopping at the first failed gate.
# dry run -> parse PASS on fxdry, new check PASS x2 on fxdry and FAIL (not SKIP) on fxctl -> apply ->
# parse PASS, new check PASS x2 and __verifySafe fingerprint on fixture.html -> commit -> push.
set -e
R="$(cd "$(dirname "$0")/../.." && pwd)"; cd "$R"; PREV=$1; NEW=$2; N2=${NEW:2}; V="${NEW:0:2}.${NEW:2}"; D=tools/cloud/run.mjs
for f in p f d a cm; do e=ps1; [ $f = d -o $f = a -o $f = cm ] && e=txt; [ -f tools/handoff/$f$NEW.$e ] || { echo "GATE: missing $f$NEW.$e"; exit 1; }; done
LC_ALL=C grep -qP '[^\x00-\x7F]' tools/handoff/p$NEW.ps1 tools/handoff/f$NEW.ps1 && { echo "GATE: patch script not ASCII"; exit 1; }
rm -rf /tmp/pillagers-dry; tools/cloud/dryrun.sh $PREV $NEW
node $D parse fxdry$N2.html || { echo "GATE: dry parse"; exit 1; }
node $D check fxdry$N2.html $V 2 || { echo "GATE: dry check"; exit 1; }
out=$(node $D check fxctl$N2.html $V 1 || true); echo "$out"
echo "$out" | grep -q '^run 1: FAIL' || { echo "GATE: control did not FAIL"; exit 1; }
tools/cloud/ship.sh start $PREV $NEW
node $D parse fixture.html || { echo "GATE: fixture parse"; exit 1; }
node $D check fixture.html $V 2 || { echo "GATE: fixture check"; exit 1; }
vs=$(node $D verify fixture.html) || { echo "$vs"; echo "GATE: verifySafe"; exit 1; }; echo "$vs"
echo "$vs" | grep -q '"ents":{"0":85,"1":374},"containers":{"0":165,"1":593}' || { echo "GATE: fingerprint moved"; exit 1; }
python3 -c "import re;s=open('dark_raiders.html',encoding='utf-8').read();open('/tmp/g.js','w').write('\n;\n'.join(re.findall(r'<script\b[^>]*>([\s\S]*?)</script>',s)))"
node --check /tmp/g.js || { echo "GATE: node --check"; exit 1; }
tools/cloud/ship.sh commit $NEW cm$NEW.txt
for i in 1 2 3 4; do git push -q origin master && break; sleep $((2**i)); done
echo "SHIPPED v$V"
