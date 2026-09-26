#!/bin/bash
# ps.sh SCRIPT.ps1 [TARGETROOT]: runs a Windows handoff .ps1 under pwsh with its
# C:\claudecode\dark raiders paths pointed at TARGETROOT (default: this repo).
# Only a temp copy is rewritten; the original stays as his PC runs it.
R="$(cd "$(dirname "$0")/../.." && pwd)"; T="${2:-$R}"
tmp=$(mktemp --suffix=.ps1)
sed -e "s#C:\\\\claudecode\\\\dark raiders\\\\tools\\\\mkfixture.ps1#$T/tools/mkfixture.ps1#g" \
    -e "s#C:\\\\claudecode\\\\dark raiders\\\\dark_raiders.html#$T/dark_raiders.html#g" "$1" > "$tmp"
grep -q 'C:\\claudecode' "$tmp" && { echo "ps.sh: unmapped Windows path left in $1"; grep -n 'C:\\claudecode' "$tmp" | head -3; rm -f "$tmp"; exit 1; }
pwsh -NoProfile -File "$tmp"; rc=$?; rm -f "$tmp"; exit $rc
