# Is it the real run's own script? The same two slices through an exact copy of tools/corpus-slices.sh (its port changed to 9345, its name changed so the runner doesn't take it for a run), at the runner's class. Stops for a gate job, a pause or a full run. Deletes its browser and profile.
param([int[]]$Slices=@(600,360))
$here=Split-Path -Parent $MyInvocation.MyCommand.Path; $Port=9345; $R='C:\claudecode\dark raiders'; $Prof=Join-Path $env:TEMP "pillagers-cdp$Port"
$st='C:\PillagersSpare\state.txt'; $log='C:\PillagersSpare\runner.log'; $n0=(Get-Content $log).Count; $bash='C:\Program Files\Git\bin\bash.exe'; $out=Join-Path $here 'timing\scaffold.txt'
function Busy(){ $s=Get-Content $st; if(@($s | Where-Object { $_ -cmatch '^gate_id=.' }).Count){ return 'gate job' }; if(@($s | Where-Object { $_ -cmatch '^pause_why=.' }).Count){ return 'pause' }; if(@(Get-Content $log | Select-Object -Skip $n0 | Where-Object { $_ -match 'full test run started|gate job \S+ started|paused:' }).Count){ return 'runner event' }; return '' }
$b=Busy; if($b){ "not started: $b"; exit 1 }
(Get-Process -Id $PID).PriorityClass=[Diagnostics.ProcessPriorityClass]::BelowNormal
$env:FX='fxcorpus.html'; $env:CS_PROFILE=$Prof
$why=''
foreach($a in $Slices){
  & powershell -NoProfile -ExecutionPolicy Bypass -File "$R\tools\cdp.ps1" -Start -Port $Port -Profile $Prof | Out-Null
  $f=($out -replace '\.txt$',"-$a.txt") -replace '\\','/'
  $t0=Get-Date
  $p=Start-Process -FilePath $bash -PassThru -WindowStyle Hidden -WorkingDirectory $R -ArgumentList @(('"'+(Join-Path $here 'priv-slices.sh').Replace('\','/')+'"'),('"'+$f+'"'),[string]$a,[string]($a+120),'120')
  while(-not $p.HasExited){ Start-Sleep -Seconds 5; $why=Busy; if($why){ & taskkill.exe /PID $p.Id /T /F | Out-Null; break } }
  "slice $a wall $([int]((Get-Date)-$t0).TotalSeconds) s (includes the 25 s wait): $((Get-Content $f -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object { $_.Substring(0,[Math]::Min(70,$_.Length)) }))"
  & powershell -NoProfile -ExecutionPolicy Bypass -File "$R\tools\cdp.ps1" -Close -Port $Port | Out-Null
  if($why){ "stopped: $why"; break }
}
Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match "remote-debugging-port=$Port(\s|$)" } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2; Remove-Item -LiteralPath $Prof -Recurse -Force -ErrorAction SilentlyContinue
'done'
