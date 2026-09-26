#!/bin/bash
# dryrun.sh PREV NEW: cloud port of tools/handoff/dryrun.ps1. Builds tools/fxdryNN.html (patched game +
# patched fixture) and tools/fxctlNN.html (previous game + patched fixture) from scratch copies of HEAD.
set -e
R="$(cd "$(dirname "$0")/../.." && pwd)"; H="$R/tools/handoff"; PREV=$1; NEW=$2; N2=${NEW:2}
B=/tmp/pillagers-dry; A="$B/dry$PREV"; S="$B/dry$NEW"
if [ ! -f "$A/dark_raiders.html" ]; then mkdir -p "$A/tools"; git -C "$R" show HEAD:dark_raiders.html > "$A/dark_raiders.html"; git -C "$R" show HEAD:tools/mkfixture.ps1 > "$A/tools/mkfixture.ps1"; fi
rm -rf "$S"; mkdir -p "$S/tools"; cp "$A/dark_raiders.html" "$S/"; cp "$A/tools/mkfixture.ps1" "$S/tools/"
for f in p$NEW f$NEW; do out=$("$R/tools/cloud/ps.sh" "$H/$f.ps1" "$S"); echo "$f -> $out"; case "$out" in OK*) ;; *) echo "dryrun: $f did not apply"; exit 1;; esac; done
echo "dry: $(pwsh -NoProfile -File "$S/tools/mkfixture.ps1" -Src "$S/dark_raiders.html" -Dst "$R/tools/fxdry$N2.html" | tail -1)"
echo "ctl: $(pwsh -NoProfile -File "$S/tools/mkfixture.ps1" -Src "$A/dark_raiders.html" -Dst "$R/tools/fxctl$N2.html" | tail -1)"
