param([int]$Runs=6,[int]$Soak=120,[int]$Cdp=9335,[int]$Port=8809)
$c='C:\claudecode\dark raiders\tools\cdp.ps1'
function Ev([string]$e,[int]$t=60){ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Port $Cdp -Match $Port -TimeoutSec $t -Expr $e 2>$null }
$out=@()
for($k=1;$k -le $Runs;$k++){
  (Invoke-RestMethod http://127.0.0.1:$Cdp/json) | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Port*" } | ForEach-Object { Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/close/"+$_.id) | Out-Null }
  $t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Cdp/json/new?http://localhost:$Port/nettest.html?f=fixture.html%26soak="+$Soak); Invoke-RestMethod ("http://127.0.0.1:$Cdp/json/activate/"+$t.id) | Out-Null
  Start-Sleep 14; Ev "(document.getElementById('wipe').click(),'w')" | Out-Null; Start-Sleep 15
  Ev "(function(){var b=document.getElementById('runsame');return b.disabled?'nr':(b.click(),'go')})()" | Out-Null
  $end=(Get-Date).AddSeconds($Soak+240)
  while((Get-Date) -lt $end){ Start-Sleep 20; if((Ev "window.__NETTEST_SAME?'done':'run'") -eq 'done'){ break } }
  $out += ("run $k " + (Ev "(function(){var n=window.__NETTEST_SAME;if(!n) return 'NOT FINISHED';var s=n.rep.soak||{};return JSON.stringify({pass:n.pass,bad:n.bad.map(function(b){return b.slice(0,/^pad loot/.test(b)?800:120)}),errors:s.errors,saved:s.saved,drops:s.drops,fps:s.minFramesPerSec,soakSec:s.sec,ended:n.rep.soakEnded||'',endA:n.rep.soakEndA||0,endC:n.rep.soakEndC||0,sl:n.pass?0:((document.getElementById('log')||{}).textContent||'').split(String.fromCharCode(10)).filter(function(x){return /^(shots|feed)/.test(x)}).slice(0,6)})})()" 90))
}
$out
