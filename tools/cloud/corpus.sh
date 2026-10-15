#!/bin/bash
# corpus.sh [FILE] [SHARDS] [OUTDIR]: the full __REGRESS corpus in SHARDS parallel run.mjs seq shards (default fixture.html, 3).
# A shard that hits a TIMEOUT is restarted on a fresh page at the next index, so one stalled check costs one check, not the shard.
# Writes OUTDIR/shard-N.txt (raw) and prints the merged failing list. Env CHECK_MS = per-check limit (default 120000).
R="$(cd "$(dirname "$0")/../.." && pwd)"; F=${1:-fixture.html}; K=${2:-3}; O=${3:-/tmp/corpus}; mkdir -p "$O"; rm -f "$O"/shard-*.txt
N=$(node "$R/tools/cloud/run.mjs" eval "$F" 'String(__REGRESS.length)' | tail -1); S=$(( (N + K - 1) / K ))
echo "corpus: $N checks in $K shards of $S ($(date -u +%H:%M:%S))"
shard(){ local a=$1 b=$2 out=$3 t0=$(date +%s)
  while [ $a -lt $b ]; do
    node "$R/tools/cloud/run.mjs" seq "$F" $a $b >> "$out" 2>&1
    t=$(grep -o 'TIMEOUT at index [0-9]*' "$out" | tail -1 | grep -o '[0-9]*$')
    [ -n "$t" ] && [ "$t" -ge "$a" ] && { a=$((t+1)); echo "  (restart at $a)" >> "$out"; } || break
  done; echo "SHARD_SECONDS $(( $(date +%s) - t0 ))" >> "$out"; }
for i in $(seq 0 $((K-1))); do a=$((i*S)); b=$(( (i+1)*S )); [ $b -gt $N ] && b=$N; shard $a $b "$O/shard-$i.txt" & done; wait
grep -h '^  v\|^SHARD\|^PASS\|^FAIL' "$O"/shard-*.txt
