param([string]$NN,[int]$N=80,[int]$Cdp=9344)
# Runs the newest $N checks (except the new one) on fxdry$NN and fxctl$NN and prints any check that fails on the drafted
# build but not on the control: a check this build broke. Prints REGRESS lines, then a count.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
$e="(function(){ var o={}, R=__REGRESS.slice().sort(function(a,b){ return parseFloat(b.v)-parseFloat(a.v); }).slice(0,$N+1), i, t, r; for(i=1;i<R.length;i++){ t=R[i]; try{ __runPrep(); __topClear(); r=t.run(); }catch(x){ r='threw '+x; } if(r&&String(r).indexOf('SKIP')!==0&&!(r&&typeof r.then==='function')) o[t.v]=String(r).slice(0,160); } return JSON.stringify(o); })()"
$d=powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "fxdry$NN" -TimeoutSec 400 -Expr $e 2>$null
$k=powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "fxctl$NN" -TimeoutSec 400 -Expr $e 2>$null
try{ $dj=$d | ConvertFrom-Json; $kj=$k | ConvertFrom-Json }catch{ "RECENT ERROR: dry=$d ctl=$k"; exit 1 }
$n=0
foreach($p in $dj.PSObject.Properties){ if(-not $kj.PSObject.Properties[$p.Name]){ "REGRESS $($p.Name): $($p.Value)"; $n++ } }
"recent: $n new failures in the newest $N checks"
