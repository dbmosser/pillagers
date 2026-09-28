# Eight suite shards: cdp port, server port, from, to. Starts servers 8811-8814 and Chromes if missing, opens each shard.
$root='C:\claudecode\dark raiders'; $c="$root\tools\cdp.ps1"
foreach($sp in 8811,8812,8813,8814){
  try{ Invoke-WebRequest -Uri "http://localhost:$sp/shard.html" -UseBasicParsing -TimeoutSec 2 | Out-Null }
  catch{ $line='-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "'+$root+'\tools\serve.ps1" -Root "'+$root+'\tools" -Port '+$sp; Start-Process -FilePath 'powershell.exe' -ArgumentList $line -WindowStyle Hidden | Out-Null }
}
Start-Sleep 3
$R=@(@(9336,8804,0,115),@(9337,8805,115,230),@(9338,8806,230,345),@(9339,8807,345,460),@(9340,8811,460,575),@(9341,8812,575,690),@(9342,8813,690,805),@(9343,8814,805,1000))
foreach($r in $R){
  try{ Invoke-RestMethod ("http://127.0.0.1:{0}/json/version" -f $r[0]) -TimeoutSec 2 | Out-Null }catch{ powershell -NoProfile -ExecutionPolicy Bypass -File $c -Start -Port $r[0] -Profile ("$env:TEMP\pillagers-cdp"+$r[0]) | Out-Null }
  (Invoke-RestMethod ("http://127.0.0.1:{0}/json" -f $r[0])) | Where-Object { $_.type -eq 'page' } | ForEach-Object { try{ Invoke-RestMethod ("http://127.0.0.1:{0}/json/close/{1}" -f $r[0],$_.id) -TimeoutSec 10 | Out-Null }catch{} }
  $t=Invoke-RestMethod -Method Put -Uri ("http://127.0.0.1:{0}/json/new?http://localhost:{1}/shard.html?a={2}%26b={3}" -f $r[0],$r[1],$r[2],$r[3]); Invoke-RestMethod ("http://127.0.0.1:{0}/json/activate/{1}" -f $r[0],$t.id) | Out-Null
  "opened {0} on {1}: {2}-{3}" -f $r[0],$r[1],$r[2],$r[3]
}
