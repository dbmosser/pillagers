#!/bin/bash
# render.sh PAGE.html OUT.png [WIDTH HEIGHT] : takes a picture of a local page with ONE short-lived headless Chrome.
# A lock folder keeps it to one Chrome at a time (the VM is short of RAM by day). It opens only file:// pages, never a server, never port 8802.
set -u
PAGE="$1"; OUT="$2"; W="${3:-1920}"; H="${4:-1080}"
HERE="$(cd "$(dirname "$0")" && pwd)"
LOCK="$HERE/.render.lock"
CHROME='/c/Program Files/Google/Chrome/Application/chrome.exe'
n=0; until mkdir "$LOCK" 2>/dev/null; do sleep 1; n=$((n+1)); if [ $n -gt 180 ]; then echo "render: lock busy for 3 minutes, removing it"; rmdir "$LOCK" 2>/dev/null; fi; done
trap 'rmdir "$LOCK" 2>/dev/null' EXIT
PW="$(cygpath -w "$(cd "$(dirname "$PAGE")" && pwd)/$(basename "$PAGE")")"
OW="$(cygpath -w "$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")")"
PROF="$(cygpath -w "$HERE")\.chrome-prof"
URL="file:///$(echo "$PW" | sed 's#\#/#g; s# #%20#g')"
rm -f "$OUT"
timeout 90 "$CHROME" --headless=new --disable-gpu --hide-scrollbars --no-first-run --no-default-browser-check \
  --user-data-dir="$PROF" --allow-file-access-from-files --force-device-scale-factor=1 \
  --window-size="$W,$H" --virtual-time-budget=8000 --screenshot="$OW" "$URL" 2>&1 | grep -v external_registry | tail -3
if [ -s "$OUT" ]; then echo "render: wrote $OUT"; else echo "render: FAILED for $PAGE"; exit 1; fi
