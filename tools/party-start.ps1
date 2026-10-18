# party-start.ps1 : AFTER THE PARTY. Starts everything that tools\party-stop.ps1 stopped, so development carries on by itself.
# His order 2026-10-18: "I'll stop everything myself on 10/30, give me a list of what to stop." The same steps, by hand, are in
# C:\Users\User1\Desktop\dark raiders\party-day-stop-list.md .
#
# One click: double-click tools\party-start.cmd (it runs this file and waits for a key). Or:  powershell -ExecutionPolicy Bypass -File tools\party-start.ps1
#   -DryRun   only print what it WOULD do (changes nothing)
# What it does, in order: removes the stop signs (the helpers' STOP file and the stable-build freeze), switches the "Pillagers runner" scheduled
# task back on, clears left-over locks (only when nothing is running), starts the servers (tools\start-servers.ps1, safe to repeat), starts the runner
# (tools\runner-start.vbs, the same thing the scheduled task does), starts Ollama and the dashboard server. The runner then starts the robots, the
# helpers and the full test run by itself within about 5 minutes.
# ASCII only (PowerShell 5.1 reads .ps1 as ANSI).
param([switch]$DryRun)
$ErrorActionPreference = 'Continue'
$R = 'C:\claudecode\dark raiders'; $H = $R + '\tools\handoff'; $C = $H + '\console'
$S = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$me = $PID
function Say([string]$t) { Write-Host $t }
function Snap() { $script:all = @(Get-CimInstance Win32_Process) }
function Pick([string]$name, [string]$rx) { @($script:all | Where-Object { $_.ProcessId -ne $me -and $_.Name -ieq $name -and $_.CommandLine -and ($_.CommandLine -match $rx) }) }
$rxRunner = '^(?!.*\s-c\s).*nightly\.sh"?\s*$'
$rxLane   = '^(?!.*\s-c\s).*(console-lane\.sh"? [a-f]|console-worker\.sh)"?\s*$'
function Listening([int]$port) {
  try { $c = New-Object System.Net.Sockets.TcpClient; $iar = $c.BeginConnect('127.0.0.1', $port, $null, $null); $ok = $iar.AsyncWaitHandle.WaitOne(1500) -and $c.Connected; $c.Close(); return $ok } catch { return $false }
}
function Step([string]$text, [scriptblock]$act) {
  if ($DryRun) { Say ('  [would do] ' + $text) } else { & $act; Say ('  [done] ' + $text) }
}

Say ''
Say '=== PARTY START (everything back on) ==='
if ($DryRun) { Say '(dry run: nothing will be changed)' }
Snap

Say '1. Remove the stop signs'
Step 'helpers may work again (tools\handoff\console\STOP removed)' { Remove-Item -LiteralPath ($C + '\STOP') -Force -ErrorAction SilentlyContinue }
Step 'the stable build may move again (tools\handoff\stable.freeze removed)' { Remove-Item -LiteralPath ($H + '\stable.freeze') -Force -ErrorAction SilentlyContinue }

Say '2. Switch the scheduled task back on'
Step 'the "Pillagers runner" task (restarts the runner by itself every 15 minutes) is enabled' { & schtasks.exe /Change /TN 'Pillagers runner' /ENABLE 2>&1 | Out-Null }

Say '3. Clear left-over locks (only the ones nothing is using)'
if ((Pick 'bash.exe' $rxRunner).Count -eq 0) { Step 'old runner heartbeat removed (so the new runner does not think another copy is alive)' { Remove-Item -LiteralPath ($H + '\nightly\runner.heartbeat') -Force -ErrorAction SilentlyContinue } }
else { Say '  [skip] a runner is already running, heartbeat kept' }
if ((Pick 'bash.exe' 'corpq\.sh|corpus-slices\.sh').Count -eq 0) { Step 'old full-test-run lock removed' { Remove-Item -LiteralPath ($S + '\corpus.lock') -Recurse -Force -ErrorAction SilentlyContinue } }
if ((Pick 'bash.exe' $rxLane).Count -eq 0) { Step 'old helper locks removed' {
    Get-ChildItem -LiteralPath $C -Directory -Filter 'lane-*.lock' -ErrorAction SilentlyContinue | ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }
    Remove-Item -LiteralPath ($C + '\pick.lock') -Recurse -Force -ErrorAction SilentlyContinue } }

Say '4. Servers (the play server on :8802 is left alone if it is up; missing test servers are started)'
Step 'tools\start-servers.ps1 ran' { & powershell.exe -NoProfile -ExecutionPolicy Bypass -File ($R + '\tools\start-servers.ps1') | ForEach-Object { Say ('     ' + $_) } }

Say '5. Ollama (the local AI)'
$ollama = $env:LOCALAPPDATA + '\Programs\Ollama\ollama app.exe'
if (@($script:all | Where-Object { $_.Name -match '^(ollama|ollama app)\.exe$' }).Count -gt 0) { Say '  [skip] Ollama is already running' }
elseif (Test-Path -LiteralPath $ollama) { Step 'Ollama started' { Start-Process -FilePath $ollama -WindowStyle Hidden } }
else { Say '  [skip] Ollama is not installed where expected' }

Say '6. The dashboard window server (port 8820)'
if (Listening 8820) { Say '  [skip] the dashboard server is already answering' }
else { Step 'the dashboard server started' { Start-Process -FilePath 'node' -ArgumentList 'server.mjs' -WorkingDirectory ($R + '\tools\devdash') -WindowStyle Hidden } }

Say '7. The runner (it starts the robots, the helpers and the full test run by itself)'
if ((Pick 'bash.exe' $rxRunner).Count -gt 0) { Say '  [skip] a runner is already running' }
else { Step 'the runner started (tools\runner-start.vbs)' { Start-Process -FilePath 'wscript.exe' -ArgumentList ('"' + $R + '\tools\runner-start.vbs"') } }

if (-not $DryRun) {
  Say ''
  Say 'Waiting 20 seconds, then checking...'
  Start-Sleep -Seconds 20
  Snap
  Say ''
  Say '=== CHECK ==='
  function Row([string]$what, [bool]$ok, [string]$note) { if ($ok) { Say ('  RUNNING       ' + $what) } else { Say ('  NOT YET       ' + $what + ' ' + $note) } }
  Row 'runner (nightly.sh)' ((Pick 'bash.exe' $rxRunner).Count -gt 0) '(if still not running in 15 minutes, the scheduled task starts it)'
  Row 'play server :8802' (Listening 8802) '(run tools\start-servers.ps1)'
  Row 'dashboard server :8820' (Listening 8820) ''
  Row 'test server :8806' (Listening 8806) ''
  Say '  The robots, the helpers and the full test run appear within about 5 to 10 minutes (the runner looks every 5 minutes).'
  Say '  Look at the PILLAGERS DEV window: "Background runner" should say Running.'
  Say ''
  Say 'Not done by this script: in the Claude app, resume the scheduled task "pillagers-watchdog" if you paused it, and tell Claude the party is over.'
}
