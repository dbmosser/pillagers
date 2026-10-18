# party-stop.ps1 : PARTY DAY. Stops everything that runs in the background for developing Pillagers, in the safest order, then prints a
# check table. His order 2026-10-18: "I'll stop everything myself on 10/30, give me a list of what to stop." The same steps, by hand, are in
# C:\Users\User1\Desktop\dark raiders\party-day-stop-list.md . To start everything again afterwards: tools\party-start.ps1 .
#
# One click: double-click tools\party-stop.cmd (it runs this file and waits for a key). Or:  powershell -ExecutionPolicy Bypass -File tools\party-stop.ps1
#   -WaitMinutes N  how long to let a helper or a ship finish by itself before stopping the helper (default 20)
#   -KeepDashboard  leave the PILLAGERS DEV window's server running
#   -DryRun         only print what it WOULD stop (changes nothing)
# It keeps running on purpose: the play server on :8802 (the party plays on http://localhost:8802/stable.html) and the collector on :8799.
# It never touches his own Chrome (only headless test Chromes on ports 93xx), never edits the game, never deletes data.
# ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
param([int]$WaitMinutes = 20, [switch]$KeepDashboard, [switch]$DryRun)
$ErrorActionPreference = 'Continue'
$R = 'C:\claudecode\dark raiders'; $H = $R + '\tools\handoff'; $C = $H + '\console'
$S = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$me = $PID
function Say([string]$t) { Write-Host $t }
function Snap() { $script:all = @(Get-CimInstance Win32_Process) }
function Pick([string]$name, [string]$rx) {
  @($script:all | Where-Object { $_.ProcessId -ne $me -and $_.Name -ieq $name -and $_.CommandLine -and ($_.CommandLine -match $rx) })
}
function PickAny([string[]]$names, [string]$rx) { $o = @(); foreach ($n in $names) { $o += Pick $n $rx }; $o }
function Kill([object[]]$procs, [string]$what) {
  $procs = @($procs | Where-Object { $_ })
  if ($procs.Count -eq 0) { Say ('  [skip] ' + $what + ': not running'); return }
  foreach ($p in $procs) {
    if ($DryRun) { Say ('  [would stop] ' + $what + ' (process ' + $p.ProcessId + ')') }
    else { & taskkill.exe /F /T /PID $p.ProcessId 2>&1 | Out-Null }
  }
  if (-not $DryRun) { Say ('  [stopped] ' + $what + ' (' + $procs.Count + ' process(es))') }
}
# ---- the groups, found by what is in their command lines
$rxRunner = '^(?!.*\s-c\s).*nightly\.sh"?\s*$'
$rxLane   = '^(?!.*\s-c\s).*(console-lane\.sh"? [a-f]|console-worker\.sh)"?\s*$'
$rxApi    = 'run-api\.mjs|review-batch\.mjs|critic\.mjs|balance\.mjs|Your task id is'
$rxShip   = 'shipq\.sh|shipone\.sh|shipdraft\.sh|fixq\.sh|preflight\.sh|[\\/]ship\.sh|gate\.ps1|mkfixture\.ps1|uishots\.ps1'
$rxFuzz   = 'fuzz\.ps1'
$rxCorpus = 'corpq\.sh|corpus-slices\.sh'
$rxLlm    = 'llm-night\.ps1'
function TestChromes() { @($script:all | Where-Object { $_.Name -ieq 'chrome.exe' -and $_.CommandLine -and $_.CommandLine -match '--headless' -and $_.CommandLine -match 'remote-debugging-port=93\d\d(\s|"|$)' }) }
function PlayServers() {
  $o = @()
  foreach ($p in (Pick 'powershell.exe' 'serve\.ps1')) {
    $port = 8802; if ($p.CommandLine -match '-Port\s+"?(\d+)') { $port = [int]$Matches[1] }
    if ($port -eq 8802) { $o += $p }
  }
  $o
}
function TestServers() {   # the test shards (everything except the play server on 8802) and the image sink
  $o = @()
  foreach ($p in (Pick 'powershell.exe' 'serve\.ps1')) {
    $port = 8802; if ($p.CommandLine -match '-Port\s+"?(\d+)') { $port = [int]$Matches[1] }
    if ($port -ne 8802) { $o += $p }
  }
  $o += Pick 'powershell.exe' 'capture\.ps1'
  $o
}

Say ''
Say '=== PARTY STOP ==='
if ($DryRun) { Say '(dry run: nothing will be changed)' }
Snap

# ---- 1. tell everything not to start new work
Say '1. Stop signs (no new work starts)'
if (-not $DryRun) {
  New-Item -ItemType File -Force -Path ($C + '\STOP') | Out-Null
  New-Item -ItemType File -Force -Path ($H + '\stable.freeze') | Out-Null
}
Say '  [ok] helpers paused (tools\handoff\console\STOP) and the stable build frozen (tools\handoff\stable.freeze)'

# ---- 2. the runner and its schedule, so nothing is restarted behind our back
Say '2. The always-on runner'
if (-not $DryRun) { & schtasks.exe /Change /TN 'Pillagers runner' /DISABLE 2>&1 | Out-Null }
Say '  [ok] the "Pillagers runner" scheduled task is switched off'
Kill (Pick 'bash.exe' $rxRunner) 'the runner (nightly.sh)'
if (-not $DryRun) { Remove-Item -LiteralPath ($H + '\nightly\runner.heartbeat') -Force -ErrorAction SilentlyContinue }

# ---- 3. let the helpers and any ship in progress finish by themselves (up to -WaitMinutes)
Say ('3. Letting helpers and ships finish by themselves (up to ' + $WaitMinutes + ' minutes)')
$deadline = (Get-Date).AddMinutes($WaitMinutes)
while (-not $DryRun) {
  Snap
  $busyApi = @(PickAny @('node.exe', 'claude.exe') $rxApi)
  $busyShip = @(PickAny @('bash.exe', 'powershell.exe') $rxShip)
  if ($busyApi.Count -eq 0 -and $busyShip.Count -eq 0) { Say '  [ok] no helper is working and no ship is in progress'; break }
  if ((Get-Date) -gt $deadline) { Say ('  [time is up] still going: ' + $busyApi.Count + ' helper process(es), ' + $busyShip.Count + ' ship process(es)'); break }
  Say ('  ... waiting: ' + $busyApi.Count + ' helper run(s), ' + $busyShip.Count + ' ship process(es) (' + [int](($deadline - (Get-Date)).TotalMinutes) + ' min left)')
  Start-Sleep -Seconds 30
}
Snap
Say '4. The helpers'
Kill (PickAny @('node.exe', 'claude.exe') $rxApi) 'helper runs (Claude working on a job)'
Kill (Pick 'bash.exe' $rxLane) 'helper lanes (console-lane.sh a, b, c, e, f)'
if (-not $DryRun) {
  Start-Sleep -Seconds 2
  Get-ChildItem -LiteralPath $C -Directory -Filter 'lane-*.lock' -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
  Remove-Item -LiteralPath ($C + '\pick.lock') -Recurse -Force -ErrorAction SilentlyContinue
}
$ship = @(PickAny @('bash.exe', 'powershell.exe') $rxShip)
if ($ship.Count -gt 0) { Say ('  [WARNING] a ship is still in progress (' + $ship.Count + ' process(es)). It was NOT stopped, so no half-saved game file is left. Wait a few minutes and run this again, or ask Claude.') }

# ---- 5-8. the robots, the full test run, the local AI, the nightly review
Snap
Say '5. The crash-hunting robots (fuzz.ps1)'
Kill (Pick 'powershell.exe' $rxFuzz) 'the robots'
Say '6. The full test run (corpus)'
Kill (Pick 'bash.exe' $rxCorpus) 'the full test run'
if (-not $DryRun) { Remove-Item -LiteralPath ($S + '\corpus.lock') -Recurse -Force -ErrorAction SilentlyContinue }
Say '7. The local AI (Ollama)'
Kill (Pick 'powershell.exe' $rxLlm) 'the overnight AI audit (llm-night.ps1)'
Kill (@($script:all | Where-Object { $_.ProcessId -ne $me -and $_.Name -match '^(ollama|ollama app|ollama_llama_server)\.exe$' })) 'Ollama (the local AI program)'
Say '8. The hidden test browsers (Chrome on ports 9331-9399) and test servers'
Start-Sleep -Seconds 1
Snap
Kill (TestChromes) 'hidden test Chromes (robots, test run, quality line, helpers practice browsers)'
Kill (TestServers) 'test servers (8800, 8803-8811) and the picture sink'
if (-not $KeepDashboard) {
  Say '9. The dashboard window server'
  Kill (Pick 'node.exe' 'server\.mjs\s*$') 'dashboard server (port 8820)'
}

# ---- the check table
if (-not $DryRun) {
  Start-Sleep -Seconds 3
  Snap
  Say ''
  Say '=== CHECK: every line should say STOPPED, and the two KEPT lines should say running ==='
  function Row([string]$what, [object[]]$procs) {
    $procs = @($procs | Where-Object { $_ })
    if ($procs.Count -eq 0) { Say ('  STOPPED       ' + $what) } else { Say ('  STILL RUNNING ' + $what + ' (process ' + (($procs | ForEach-Object { $_.ProcessId }) -join ', ') + ')') }
  }
  Row 'runner (nightly.sh)' (Pick 'bash.exe' $rxRunner)
  Row 'helper lanes' (Pick 'bash.exe' $rxLane)
  Row 'helper runs' (PickAny @('node.exe', 'claude.exe') $rxApi)
  Row 'ship in progress' (PickAny @('bash.exe', 'powershell.exe') $rxShip)
  Row 'robots' (Pick 'powershell.exe' $rxFuzz)
  Row 'full test run' (Pick 'bash.exe' $rxCorpus)
  Row 'local AI audit' (Pick 'powershell.exe' $rxLlm)
  Row 'Ollama' (@($script:all | Where-Object { $_.Name -match '^(ollama|ollama app|ollama_llama_server)\.exe$' }))
  Row 'hidden test Chromes' (TestChromes)
  Row 'test servers' (TestServers)
  if (-not $KeepDashboard) { Row 'dashboard server' (Pick 'node.exe' 'server\.mjs\s*$') }
  $t = & schtasks.exe /Query /TN 'Pillagers runner' /FO LIST 2>&1 | Out-String
  if ($t -match 'Disabled') { Say '  STOPPED       scheduled task "Pillagers runner" (disabled)' } else { Say '  STILL ON      scheduled task "Pillagers runner" (run: schtasks /Change /TN "Pillagers runner" /DISABLE)' }
  $play = @(PlayServers)
  if ($play.Count -gt 0) { Say '  KEPT (running) play server on :8802  -> party address http://localhost:8802/stable.html' } else { Say '  !! the play server on :8802 is NOT running: double-click tools\start-servers.ps1 (or run it) before the party' }
  if ((Pick 'powershell.exe' 'collector\.ps1').Count -gt 0) { Say '  KEPT (running) collector on :8799 (saves the party runs into exports\)' } else { Say '  note: the collector on :8799 is not running (party runs are then not saved to exports\); tools\start-servers.ps1 starts it' }
  Say ''
  Say 'Two things this script cannot do for you:'
  Say '  - In the Claude app, pause the scheduled task "pillagers-watchdog" (sidebar: Scheduled) and close any Claude session that is still working on Pillagers.'
  Say '  - Windows may restart the servers and Ollama when you log in again; that is fine (the runner and the helpers stay off).'
  Say 'To start everything again after the party: tools\party-start.ps1'
}
