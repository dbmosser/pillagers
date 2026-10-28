# close-test-chromes.ps1 : closes leftover headless TEST Chromes (10-27 night; his direct yes in the CEO chat to closing leftover test browsers
# and stuck test programs without asking). Only a chrome.exe started with --headless and a --remote-debugging-port between 9300 and 9399
# counts (cdp.ps1, uishots.ps1, soak4k.ps1, the lanes' preflight Chromes 9351-9358). His own Chrome, the Browser pane and 8802 are never touched.
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\close-test-chromes.ps1 -List          (show them, close nothing)
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\close-test-chromes.ps1 -Port 9351,9354
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\close-test-chromes.ps1 -All           (every test Chrome; a running gate on one of them fails)
param([int[]]$Port = @(), [switch]$All, [switch]$List)
$roots = @(Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object {
  $c = [string]$_.CommandLine
  $c -match '--headless' -and $c -notmatch '--type=' -and $c -match '--remote-debugging-port=93\d\d\b'
} | ForEach-Object {
  $p = [int]([regex]::Match([string]$_.CommandLine, '--remote-debugging-port=(\d+)').Groups[1].Value)
  [PSCustomObject]@{ Pid = $_.ProcessId; Port = $p; MB = [int]($_.WorkingSetSize / 1MB) }
})
if ($List -or (-not $All -and $Port.Count -eq 0)) {
  if ($roots.Count -eq 0) { 'no test Chromes running' } else { $roots | Sort-Object Port | ForEach-Object { "test Chrome port $($_.Port) pid $($_.Pid) $($_.MB) MB" } }
  return
}
$pick = if ($All) { $roots } else { @($roots | Where-Object { $Port -contains $_.Port }) }
if ($pick.Count -eq 0) { 'nothing to close'; return }
foreach ($r in $pick) {
  & taskkill.exe /PID $r.Pid /T /F 2>&1 | Out-Null
  Start-Sleep -Milliseconds 300
  if (Get-Process -Id $r.Pid -ErrorAction SilentlyContinue) { "port $($r.Port) pid $($r.Pid) STILL RUNNING" } else { "closed test Chrome port $($r.Port) (pid $($r.Pid))" }
}
