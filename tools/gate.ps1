# The dry-run gates of the ship flow in headless Chrome (added 2026-09-27; tools\cdp.ps1 -Start first).
#   powershell -File tools\gate.ps1 -NN 48 -V 16.48
# 1. parsecheck.html?f=fxdryNN.html reads PASS. 2. check V passes twice on fxdryNN. 3. check V FAILS (not SKIP) on fxctlNN.
# Mode -Fix runs step 2 on fixture.html plus __verifySafe (the seed 4242 fingerprint) after ship.sh start.
param([string]$NN,[string]$V,[switch]$Fix,[int]$Port=8806)
$c=Join-Path $PSScriptRoot 'cdp.ps1'
function Ev([string]$m,[string]$e,[int]$t=180){ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Match $m -Expr $e -TimeoutSec $t }
function OpenWait([string]$url,[string]$m,[string]$ready){
  (Invoke-RestMethod http://127.0.0.1:9333/json) | Where-Object { $_.url -like "*$m*" } | ForEach-Object { Invoke-RestMethod ("http://127.0.0.1:9333/json/close/"+$_.id) | Out-Null }
  $t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:9333/json/new?"+$url); Invoke-RestMethod ("http://127.0.0.1:9333/json/activate/"+$t.id) | Out-Null
  for($i=0;$i -lt 60;$i++){ Start-Sleep -Milliseconds 500; $r=Ev $m $ready 10; if($r -eq 'true'){ return } }
  Write-Output "TIMEOUT loading $url"
}
$run="(function(){ var t=__REGRESS.find(function(x){return x.v==='$V'}); if(!t) return 'NO CHECK $V'; var o=[]; for(var k=0;k<2;k++){ __runPrep(); __topClear(); var r; try{ r=t.run(); }catch(e){ r='threw '+e; } o.push(r?String(r).slice(0,300):'PASS'); } return o.join(' / '); })()"
if($Fix){
  OpenWait "http://localhost:$Port/fixture.html" "$Port/fixture" "String(typeof __REGRESS!=='undefined'&&typeof __verifySafe==='function')"
  "fixture.html check ${V}: " + (Ev "$Port/fixture" $run)
  "verifySafe: " + (Ev "$Port/fixture" "Promise.resolve(__verifySafe()).then(function(r){ return JSON.stringify({pass:r.pass,ents:r.ents,containers:r.containers,fail:r.fail}); })" 300)
  exit 0
}
OpenWait "http://localhost:$Port/parsecheck.html?f=fxdry$NN.html" "parsecheck" "String(/parse check/.test(document.title))"
"parse: " + (Ev 'parsecheck' 'document.title')
OpenWait "http://localhost:$Port/fxdry$NN.html" "fxdry$NN" "String(typeof __REGRESS!=='undefined')"
"dry fxdry$NN check ${V}: " + (Ev "fxdry$NN" $run)
OpenWait "http://localhost:$Port/fxctl$NN.html" "fxctl$NN" "String(typeof __REGRESS!=='undefined')"
"control fxctl$NN check ${V}: " + (Ev "fxctl$NN" $run)
