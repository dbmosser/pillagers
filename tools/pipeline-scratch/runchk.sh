#!/bin/bash
# runchk.sh LISTFILE OUTFILE : run each check v in LISTFILE once on the shipped fixture, in Chrome 9346 on :8806, 25 per tab. HOLD THE LOCK.
R="/c/claudecode/dark raiders"; cd "$R" || exit 1
L="$1"; O="$2"; : > "$O"
CDP() { powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9346 "$@" 2>/dev/null | tail -n +1; }
mapfile -t VS < "$L"
i=0; n=${#VS[@]}
while [ $i -lt $n ]; do
  chunk=("${VS[@]:$i:25}"); js=$(printf "'%s'," "${chunk[@]}"); TAG="kz$i"
  CDP -Open "http://localhost:8806/fixture.html?$TAG=1" >/dev/null; sleep 20
  CDP -Match "$TAG=1" -TimeoutSec 1200 -Expr "(function(){ var vs=[${js%,}], out=[]; vs.forEach(function(V){ var t=__REGRESS.find(function(x){return x.v===V}); if(!t){ out.push(V+': NO CHECK'); return; } var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } out.push(V+': '+(r?String(r).slice(0,300):'PASS')); }); return out.join('\n'); })()" >> "$O"
  id=$(curl -s http://127.0.0.1:9346/json | grep -B4 "$TAG=1" | grep '"id"' | sed 's/.*"id": "\([^"]*\)".*/\1/' | head -1); [ -n "$id" ] && curl -s "http://127.0.0.1:9346/json/close/$id" >/dev/null
  i=$((i+25))
done
echo "ALL DONE" >> "$O"
