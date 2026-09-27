# One-shot DevTools call into a headless browser on this PC (added 2026-09-27: the Browser pane throttles when hidden).
# Start the browser once:
#   powershell -File tools\cdp.ps1 -Start            (headless Chrome, 1920x1080, its own profile, port 9333)
# Open a page:     powershell -File tools\cdp.ps1 -Open "http://localhost:8804/shard.html"
# Evaluate:        powershell -File tools\cdp.ps1 -Match 8804 -Expr "window.__PROG.done"
# The expression may be a promise; a non-string result comes back as JSON.
param([int]$Port=9333,[switch]$Start,[string]$Open='',[string]$Match='',[string]$Expr='document.title',[int]$TimeoutSec=120,
      [string]$Profile="$env:TEMP\pillagers-cdp")
$ErrorActionPreference='Stop'
if($Start){
  $exe='C:\Program Files\Google\Chrome\Application\chrome.exe'
  if(-not (Test-Path $exe)){ $exe='C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
  $a='--headless=new --window-size=1920,1080 --force-device-scale-factor=1 --remote-debugging-port='+$Port+
     ' --user-data-dir="'+$Profile+'" --no-first-run --no-default-browser-check --disable-background-timer-throttling'+
     ' --disable-renderer-backgrounding --disable-backgrounding-occluded-windows --autoplay-policy=no-user-gesture-required about:blank'
  Start-Process -FilePath $exe -ArgumentList $a | Out-Null
  for($i=0;$i -lt 40;$i++){ try{ Invoke-RestMethod "http://127.0.0.1:$Port/json/version" -TimeoutSec 2 | Out-Null; Write-Output "browser up on $Port"; exit 0 }catch{ Start-Sleep -Milliseconds 250 } }
  Write-Output 'browser did not start'; exit 1
}
if($Open){ $t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:$Port/json/new?"+$Open) -TimeoutSec 5; Write-Output ('opened '+$t.id+' '+$Open); exit 0 }
$tabs=Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json" -TimeoutSec 5
$t=$tabs | Where-Object { $_.type -eq 'page' -and ($Match -eq '' -or $_.url -like "*$Match*") } | Select-Object -First 1
if(-not $t){ Write-Output 'NO TARGET'; exit 1 }
$ws=New-Object System.Net.WebSockets.ClientWebSocket
$ct=[Threading.CancellationToken]::None
$ws.ConnectAsync([Uri]$t.webSocketDebuggerUrl,$ct).Wait()
$js='(async()=>{ const v=await ('+$Expr+'); return (typeof v==="string")?v:JSON.stringify(v); })()'
$msg=@{id=1;method='Runtime.evaluate';params=@{expression=$js;returnByValue=$true;awaitPromise=$true}} | ConvertTo-Json -Depth 5 -Compress
$bytes=[Text.Encoding]::UTF8.GetBytes($msg)
$ws.SendAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$bytes)),[System.Net.WebSockets.WebSocketMessageType]::Text,$true,$ct).Wait()
$buf=New-Object byte[] 1048576; $ms=New-Object System.IO.MemoryStream; $txt=''
$deadline=(Get-Date).AddSeconds($TimeoutSec)
while($true){
  $task=$ws.ReceiveAsync((New-Object 'ArraySegment[byte]' -ArgumentList (,$buf)),$ct)
  $left=[int][Math]::Max(1,($deadline-(Get-Date)).TotalMilliseconds)
  if(-not $task.Wait($left)){ Write-Output 'TIMEOUT'; exit 1 }
  $ms.Write($buf,0,$task.Result.Count)
  if($task.Result.EndOfMessage){ $txt=[Text.Encoding]::UTF8.GetString($ms.ToArray()); $ms.SetLength(0); if($txt -match '"id":1[,}]'){ break } }
}
$ws.Dispose()
$o=$txt | ConvertFrom-Json
if($o.result.exceptionDetails){ Write-Output ('EXCEPTION: '+$o.result.exceptionDetails.exception.description); exit 1 }
Write-Output $o.result.result.value
