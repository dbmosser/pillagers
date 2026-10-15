# trycheck.ps1 -Key uicN : builds a control (HEAD) fixture and a patched fixture from mk-KEY.ps1, runs the draft check on both in my own Chrome (port 9341)
param([string]$Key,[int]$Port=9341)
$ErrorActionPreference='Stop'
$S='C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$R='C:\claudecode\dark raiders'
$src=Join-Path $env:TEMP 'uic-try-src.html'
$json=Join-Path $env:TEMP ("uic-try-$Key.json")
cmd /c ("git -C `"$R`" show HEAD:dark_raiders.html > `"$src`"")
& powershell -NoProfile -ExecutionPolicy Bypass -File "$S\mk-$Key.ps1" -Src $src -Out $json | Out-Null
$d=[IO.File]::ReadAllText($json) | ConvertFrom-Json
$t=[IO.File]::ReadAllText($src).Replace("`r",'')
foreach($e in @($d.edits)){ $i=$t.IndexOf([string]$e.anchor); if($i -lt 0){ throw 'anchor missing in the HEAD source' }; $t=$t.Substring(0,$i)+[string]$e.replacement+$t.Substring($i+([string]$e.anchor).Length) }
$new=Join-Path $env:TEMP 'uic-try-new.html'
[IO.File]::WriteAllText($new,$t,(New-Object Text.UTF8Encoding $false))
& powershell -NoProfile -ExecutionPolicy Bypass -File "$R\tools\mkfixture.ps1" -Src $src -Dst "$R\tools\shots\uic-try-ctrl.html" | Out-Null
& powershell -NoProfile -ExecutionPolicy Bypass -File "$R\tools\mkfixture.ps1" -Src $new -Dst "$R\tools\shots\uic-try-new.html" | Out-Null
$c=([string]$d.check).Trim().TrimEnd(',').Replace("v:'VER'","v:'0.00'")
[IO.File]::WriteAllText("$R\tools\shots\uic-try-chk.js",('('+$c+').run()'),(New-Object Text.UTF8Encoding $false))
$cdp="$R\tools\cdp.ps1"
try{ Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null }catch{ & powershell -NoProfile -ExecutionPolicy Bypass -File $cdp -Start -Port $Port -Profile "$env:TEMP\pillagers-uic-$Port" | Out-Null }
foreach($w in 'ctrl','new'){
  $u="http://localhost:8809/shots/uic-try-$w.html?t="+(Get-Date).Ticks
  $tab=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Port/json/new?"+$u) -TimeoutSec 10
  $ok=$false
  for($i=0;$i -lt 60;$i++){ Start-Sleep -Milliseconds 700; try{ $r=& powershell -NoProfile -ExecutionPolicy Bypass -File $cdp -Port $Port -Match "uic-try-$w" -Expr "(document.readyState==='complete'&&typeof window.__deploy==='function'&&typeof window.__gx==='function')?'up':'wait'" -TimeoutSec 20; if("$r".Trim() -eq 'up'){ $ok=$true; break } }catch{} }
  Start-Sleep -Milliseconds 2500
  if(-not $ok){ Write-Output "$w : the fixture never booted"; continue }
  $res=& powershell -NoProfile -ExecutionPolicy Bypass -File $cdp -Port $Port -Match "uic-try-$w" -Expr "fetch('/shots/uic-try-chk.js?t='+Date.now()).then(function(r){ return r.text(); }).then(function(t){ return Promise.resolve(window.__gx(t)).then(function(v){ return v===null?'PASS (null)':String(v); }); })" -TimeoutSec 120
  Write-Output "$w : $res"
  try{ Invoke-RestMethod ("http://127.0.0.1:$Port/json/close/"+$tab.id) -TimeoutSec 5 | Out-Null }catch{}
}
