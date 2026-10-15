#!/bin/bash
# gate.sh KEY [--base REV] [--draft FILE] [--recent N] : the cloud twin of tools/handoff/shipone.sh up to (not including) the ship.
# Gates, stopping at the first that fails, then prints one line:  PASS v<NEW> (<KEY>)   or   STOP v<NEW> (<KEY>): <why>
#   gen     apply draft-KEY.json to a COPY of the game at REV (default HEAD) and its check to a COPY of tools/mkfixture.ps1 (gate.py)
#   parse   parsecheck on the patched game
#   new     the new check PASSES twice on the new build
#   control the new check FAILS (not SKIP) on the previous build, same patched fixture
#   recent  the newest N (default 80) older checks: none may fail on the new build that passes on the previous build
#   verify  __verifySafe holds the seed 4242 fingerprint (ents 85/374, containers 165/593)
# Writes only tools/fx0dry-KEY.html, tools/fx0ctl-KEY.html (gitignored) and /tmp/pillagers-gate-KEY; never edits, commits or pushes the repo.
# Env: GATE_KEEP=1 keeps the fixtures, CHECK_MS per-check limit.
KEY=$1; shift; BASE=HEAD; DRAFT=; N=80
while [ $# -gt 0 ]; do case "$1" in --base) BASE=$2; shift 2;; --draft) DRAFT=$2; shift 2;; --recent) N=$2; shift 2;; *) echo "unknown arg $1"; exit 2;; esac; done
R="$(cd "$(dirname "$0")/../.." && pwd)"; cd "$R"; D="node tools/cloud/run.mjs"; W=/tmp/pillagers-gate-$KEY; DRY=fx0dry-$KEY.html; CTL=fx0ctl-$KEY.html
T0=$(date +%s); t(){ echo "  [$(( $(date +%s) - T0 ))s] $*"; }; V="?"
stop(){ echo "STOP v$V ($KEY): $*"; [ -n "$GATE_KEEP" ] || rm -f "tools/$DRY" "tools/$CTL"; exit 1; }
rm -rf "$W"; mkdir -p "$W"
g=$(python3 tools/cloud/gate.py "$KEY" --base "$BASE" ${DRAFT:+--draft "$DRAFT"} --out "$W") || { echo "$g"; stop "gen: ${g#STOP: }"; }
echo "$g"; read V PV < "$W/version.txt"; t "gen"
pwsh -NoProfile -File "$W/mkfixture.ps1" -Src "$W/dry.html" -Dst "$R/tools/$DRY" | tail -1 | grep -q 'written: True' || stop "the dry fixture did not build"
pwsh -NoProfile -File "$W/mkfixture.ps1" -Src "$W/prev.html" -Dst "$R/tools/$CTL" | tail -1 | grep -q 'written: True' || stop "the control fixture did not build"
t "fixtures built"
p=$($D parse "$DRY") || stop "parse check: $(echo "$p" | head -3 | tr '\n' ' ')"; echo "parse: $p"; t "parse"
c=$($D check "$DRY" "$V" 2); echo "$c" | sed 's/^/new: /' | cut -c1-300
[ "$(echo "$c" | grep -c '^run [12]: PASS$')" = 2 ] || stop "the new check does not pass twice on the new build"; t "new check x2"
c=$($D check "$CTL" "$V" 1); echo "$c" | sed 's/^/control: /' | cut -c1-300
echo "$c" | grep -q '^run 1: FAIL' || stop "the control did not FAIL (the check must fail on v$PV)"; t "control fails"
# the last N checks on both builds, and the fingerprint, side by side (3 browsers on 4 cores)
$D recent2 "$DRY" "$N" "$V" > "$W/recent-dry.txt" 2>&1 & p1=$!
$D recent2 "$CTL" "$N" "$V" > "$W/recent-ctl.txt" 2>&1 & p2=$!
$D verify "$DRY" > "$W/verify.txt" 2>&1 & p3=$!
wait $p1; r1=$?; wait $p2; r2=$?; wait $p3; r3=$?
[ $r1 = 0 ] && [ $r2 = 0 ] || stop "a recent check stalled: $(grep -h 'TIMEOUT\|driver error' "$W"/recent-*.txt | head -2 | cut -c1-200)"
python3 - "$W" <<'PY' || stop "an older check fails on the new build: $(cat "$W/regress.txt" | head -3 | tr '\n' ' ' | cut -c1-500)"
import json,sys,re
w=sys.argv[1]
def load(f):
    for l in open(f):
        if l.startswith('RECENT '): return json.loads(l[7:])
    raise SystemExit(2)
d,c=load(w+'/recent-dry.txt'),load(w+'/recent-ctl.txt')
new=[k+': '+v for k,v in d.items() if k not in c]
open(w+'/regress.txt','w').write('\n'.join('REGRESS '+x for x in new))
print('recent: %d fail on the new build, %d on the previous build, %d new failures' % (len(d),len(c),len(new)))
for x in new: print('  REGRESS '+x[:200])
sys.exit(1 if new else 0)
PY
t "recent $N"
cat "$W/verify.txt" | tail -1 | cut -c1-300
[ $r3 = 0 ] || stop "__verifySafe did not pass"
grep -q '"ents":{"0":85,"1":374},"containers":{"0":165,"1":593}' "$W/verify.txt" || stop "the seed 4242 fingerprint moved"
t "verifySafe"
python3 -c "import re;s=open('$W/dry.html',encoding='utf-8').read();open('$W/g.js','w').write('\n;\n'.join(re.findall(r'<script\b[^>]*>([\s\S]*?)</script>',s)))"
node --check "$W/g.js" || stop "node --check"
[ -n "$GATE_KEEP" ] || rm -f "tools/$DRY" "tools/$CTL"
echo "PASS v$V ($KEY): total $(( $(date +%s) - T0 ))s"
