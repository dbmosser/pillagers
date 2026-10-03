param([int]$Cdp=9346,[int]$Port=8806,[string]$Dir='C:\claudecode\dark raiders\tools\handoff\shots')
# THE VISUAL PASS (2026-10-02): screenshots of the main screens from headless Chrome at its window size, saved as jpeg in $Dir.
# Title, the Undercroft floor, the backpack on the floor, every station's E window, the raid HUD, the raid backpack, the pause
# box, the run card. Needs tools\cdp.ps1 -Shot.
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
New-Item -ItemType Directory -Force $Dir | Out-Null
function Ev([string]$e,[string]$shot='',[int]$t=60){ if($shot){ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec $t -Shot (Join-Path $Dir $shot) -Expr $e 2>$null } else { powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match "$Port/fixture" -TimeoutSec $t -Expr $e 2>$null } }
(Invoke-RestMethod ("http://127.0.0.1:$Cdp/json")) | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Port*" } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }catch{} }
$t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/fixture.html"); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
for($w=0;$w -lt 120;$w++){ Start-Sleep -Milliseconds 500; $ok=Ev "String(typeof __pinDPR==='function'&&typeof __hubEnter==='function')" '' 5; if($ok -eq 'true'){ break } }
$wait="await new Promise(function(r){ setTimeout(r,700); });"
$close="document.querySelectorAll('.modal.on').forEach(function(m){ m.classList.remove('on'); });"
Ev "(async function(){ __pinDPR(1); $wait return 'title'; })()" 'title.jpg'
Ev "(async function(){ __runPrep(); __hubEnter(); $wait return 'floor'; })()" 'floor.jpg'
Ev "(async function(){ __hubBagSet(true); $wait return 'bag'; })()" 'floor-backpack.jpg'
Ev "(async function(){ __hubBagSet(false); $wait return 'ok'; })()"
$sts=Ev "JSON.stringify(__station().map(function(s){ return s.id; }))"
foreach($id in ($sts | ConvertFrom-Json)){
  Ev "(async function(){ $close var r=__station('$id','KeyE'); $wait return JSON.stringify(r); })()" ("station-"+$id+".jpg")
  Ev "(async function(){ $close var t=document.getElementById('title'); if(t) t.classList.remove('on'); __hubEnter(); $wait return 'closed'; })()"
}
Ev "(async function(){ $close __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); await new Promise(function(r){ setTimeout(r,2500); }); return 'raid'; })()" 'raid-hud.jpg'
Ev "(async function(){ var G=__state(); if(G) G.bagOpen=true; $wait return 'bag'; })()" 'raid-backpack.jpg'
Ev "(async function(){ var G=__state(); if(G) G.bagOpen=false; window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyP',key:'p',bubbles:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyP',key:'p',bubbles:true})); $wait return 'pause'; })()" 'raid-pause.jpg'
Ev "(async function(){ window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyP',key:'p',bubbles:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyP',key:'p',bubbles:true})); $close __endRaid('extract'); $wait return 'card'; })()" 'run-card.jpg'
Ev "(async function(){ __topClear(); $close __hubEnter(); return 'done'; })()"
Get-ChildItem $Dir -Filter *.jpg | ForEach-Object { '{0} {1} KB' -f $_.Name,[math]::Round($_.Length/1KB) }
