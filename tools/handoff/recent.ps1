param([string]$NN,[int]$N=80,[int]$Cdp=9344)
# Runs the newest $N checks (except the new one) on fxdry$NN and fxctl$NN and prints any check that fails on the drafted
# build but not on the control: a check this build broke. Prints REGRESS lines, then a count.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
$e="(function(){ var o={}, R=__REGRESS.slice().sort(function(a,b){ return parseFloat(b.v)-parseFloat(a.v); }).slice(0,$N+1), i, t, r; for(i=1;i<R.length;i++){ t=R[i]; try{ __runPrep(); __topClear(); r=t.run(); }catch(x){ r='threw '+x; } if(r&&String(r).indexOf('SKIP')!==0&&!(r&&typeof r.then==='function')) o[t.v]=String(r).slice(0,160); } return JSON.stringify(o); })()"
# 2026-10-18: a tab that is not in front runs its JavaScript many times slower in the headless test Chrome (Windows lowers it), so the
# 80-check run on fxdry timed out while fxctl was in front (dry=TIMEOUT stopped every ship from 11:48). Each page is brought to the front first.
function Front([string]$m){ try{ (Invoke-RestMethod http://127.0.0.1:$Cdp/json) | Where-Object { $_.type -eq "page" -and $_.url -like "*$m*" } | Select-Object -First 1 | ForEach-Object { Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$_.id) | Out-Null }; Start-Sleep -Milliseconds 300 }catch{} }
Front "fxdry$NN"
$d=powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "fxdry$NN" -TimeoutSec 400 -Expr $e 2>$null
Front "fxctl$NN"
$k=powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "fxctl$NN" -TimeoutSec 400 -Expr $e 2>$null
try{ $dj=$d | ConvertFrom-Json; $kj=$k | ConvertFrom-Json }catch{ "RECENT ERROR: dry=$d ctl=$k"; exit 1 }
$cnt=0
foreach($p in $dj.PSObject.Properties){ if(-not $kj.PSObject.Properties[$p.Name]){ "REGRESS $($p.Name): $($p.Value)"; $cnt++ } }
"recent: $cnt new failures in the newest $N checks"
