# Pause a page that will not answer (a hung check), print its stack and, read on the paused frame, which corpus check it was in. Then resume.
param([int]$Port=9344,[string]$Match='slice',[int]$TimeoutSec=40)
$ErrorActionPreference='Stop'
$tabs=Invoke-RestMethod -Uri "http://127.0.0.1:$Port/json" -TimeoutSec 5
$t=$tabs | Where-Object { $_.type -eq 'page' -and $_.url -like "*$Match*" } | Select-Object -First 1
if(-not $t){ 'NO TARGET'; exit 1 }
$ws=New-Object System.Net.WebSockets.ClientWebSocket
$ct=[Threading.CancellationToken]::None
$ws.ConnectAsync([Uri]$t.webSocketDebuggerUrl,$ct).Wait()
function Send($id,$method,$params){ $o=@{id=$id;method=$method}; if($params){ $o.params=$params }; $j=$o | ConvertTo-Json -Depth 6 -Compress; $b=[Text.Encoding]::UTF8.GetBytes($j); $ws.SendAsync((New-Object ArraySegment[byte] -ArgumentList (,$b)),[Net.WebSockets.WebSocketMessageType]::Text,$true,$ct).Wait() }
function Recv(){ $buf=New-Object byte[] 1048576; $ms=New-Object IO.MemoryStream; do{ $seg=New-Object ArraySegment[byte] -ArgumentList (,$buf); $task=$ws.ReceiveAsync($seg,$ct); if(-not $task.Wait(3000)){ return $null }; $r=$task.Result; $ms.Write($buf,0,$r.Count) } while(-not $r.EndOfMessage); return [Text.Encoding]::UTF8.GetString($ms.ToArray()) }
Send 1 'Debugger.enable' @{}
Send 2 'Debugger.pause' @{}
$deadline=(Get-Date).AddSeconds($TimeoutSec); $got=$false
while((Get-Date) -lt $deadline){
  $m=Recv; if(-not $m){ continue }
  if($m -like '*"method":"Debugger.paused"*'){
    $o=$m | ConvertFrom-Json
    $i=0; foreach($f in $o.params.callFrames){ if($i -ge 14){ break }; ('{0} {1} line {2}' -f $i,$f.functionName,($f.location.lineNumber+1)); $i++ }
    $cf=$o.params.callFrames[0].callFrameId
    Send 5 'Debugger.evaluateOnCallFrame' @{callFrameId=$cf;expression="(window.__PROG?('PROG done '+__PROG.done+' of '+__PROG.total+' range '+__PROG.range+' cur '+String(__PROG.cur).slice(0,160)):'no __PROG')";returnByValue=$true}
    $d2=(Get-Date).AddSeconds(8)
    while((Get-Date) -lt $d2){ $m2=Recv; if($m2 -and $m2 -like '*"id":5*'){ $o2=$m2 | ConvertFrom-Json; [string]$o2.result.result.value; break } }
    $got=$true; break
  }
}
if(-not $got){ 'no pause event within '+$TimeoutSec+' s' }
Send 3 'Debugger.resume' @{}
Start-Sleep -Milliseconds 300
Send 4 'Debugger.disable' @{}
Start-Sleep -Milliseconds 300
try{ $ws.CloseAsync([Net.WebSockets.WebSocketCloseStatus]::NormalClosure,'',$ct).Wait(2000) | Out-Null }catch{}
