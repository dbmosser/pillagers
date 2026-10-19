# Elevated helper the owner starts once (one Yes click) before leaving. For up to -Hours it watches
# out\runner-request.txt and runs ONLY these fixed kit commands (no free-form commands, no arguments taken
# from the request): push-files, push-files-final, push-pack. Everything is logged to out\runner.log.
# It changes nothing by itself and exits at the deadline or when out\runner-stop.txt appears.
param([int]$Hours = 12)
$ErrorActionPreference = 'Continue'
$out = Join-Path $PSScriptRoot 'out'
New-Item -ItemType Directory -Force -Path $out | Out-Null
$log = Join-Path $out 'runner.log'
$req = Join-Path $out 'runner-request.txt'
$stop = Join-Path $out 'runner-stop.txt'
$allowed = @{
  'push-files'       = @{ file = 'host-push-files.ps1'; args = @() }
  'push-files-final' = @{ file = 'host-push-files.ps1'; args = @('-Final') }
  'push-pack'        = @{ file = 'push-pack.ps1'; args = @() }
}
function Say($m) { Add-Content -Path $log -Value ((Get-Date).ToString('MM-dd HH:mm:ss') + ' ' + $m) }
$deadline = (Get-Date).AddHours($Hours)
Say "runner up (elevated), pid $PID, until $($deadline.ToString('MM-dd HH:mm'))"
Remove-Item $stop -ErrorAction SilentlyContinue
while ((Get-Date) -lt $deadline -and -not (Test-Path $stop)) {
  if (Test-Path $req) {
    $key = ((Get-Content $req -TotalCount 1) -as [string]).Trim()
    Remove-Item $req -Force
    if ($allowed.ContainsKey($key)) {
      $a = $allowed[$key]; $f = Join-Path $PSScriptRoot $a.file
      Say "RUN $key -> $($a.file) $($a.args -join ' ')"
      $p = Start-Process powershell.exe -ArgumentList (@('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"' + $f + '"')) + $a.args) -Wait -PassThru -WindowStyle Minimized
      Say "END $key exit $($p.ExitCode)"
    } else { Say "REFUSED unknown request '$key'" }
  }
  Start-Sleep -Seconds 5
}
Say 'runner exit'
