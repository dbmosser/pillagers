#!/bin/bash
# rr.sh MINV STUCK: run every check with v >= MINV on fixture.html in Chrome 9344 one at a time; the title names the current check.
MINV=${1:-16.40}; STUCK=${2:-300}
C="C:\claudecode\dark raiders\tools\cdp.ps1"
for i in $(seq 1 30); do sleep 1; r=$(powershell -NoProfile -ExecutionPolicy Bypass -File "$C" -Port 9344 -Match 8806/fixture -TimeoutSec 10 -Expr "String(typeof __REGRESS!=='undefined')" 2>/dev/null); [ "$r" = "true" ] && break; done
powershell -NoProfile -ExecutionPolicy Bypass -File "$C" -Port 9344 -Match 8806/fixture -TimeoutSec 20 -Expr "(function(){ var R=__REGRESS.filter(function(t){ return parseFloat(t.v)>=$MINV; }).sort(function(a,b){ return parseFloat(b.v)-parseFloat(a.v); }), i=0, o=[]; window.__RR={o:o,n:R.length,done:false}; function step(){ if(i>=R.length){ __RR.done=true; document.title='RR done '+R.length; return; } var t=R[i]; document.title='RR '+i+'/'+R.length+' at '+t.v; var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(x){ r='threw '+x; } if(r&&typeof r.then==='function') r=null; if(r&&String(r).indexOf('SKIP')!==0) o.push(t.v+': '+String(r).slice(0,220)); i++; setTimeout(step,0); } setTimeout(step,0); return 'started '+R.length; })()" 2>/dev/null
last=""; since=$(date +%s)
while :; do
  sleep 10; ti=$(curl -s -m 5 http://127.0.0.1:9344/json | grep -o '"title": "RR[^"]*"' | head -1)
  [[ "$ti" == *done* ]] && break
  if [ "$ti" != "$last" ]; then last="$ti"; since=$(date +%s); elif [ $(( $(date +%s)-since )) -gt $STUCK ]; then echo "STUCK $ti"; exit 0; fi
done
powershell -NoProfile -ExecutionPolicy Bypass -File "$C" -Port 9344 -Match 8806/fixture -TimeoutSec 60 -Expr "__RR.n+' checks from $MINV up: '+(__RR.o.join(' || ')||'all pass')" 2>/dev/null | cut -c1-3000
