# Starts every local server the project needs and reports what is listening.
# Safe to re-run: a port that already answers is left alone.
#
# Run this at the START of every session. The servers do not survive a machine
# restart or a session ending, and the first Daniel knows about it is that his
# play link does not work.
param([string]$Root = 'C:\claudecode\dark raiders')

$serve     = Join-Path $Root 'tools\serve.ps1'
$collector = Join-Path $Root 'tools\collector.ps1'
$capture   = Join-Path $Root 'tools\capture.ps1'
$tools     = Join-Path $Root 'tools'

function Test-Port([int]$Port, [string]$Path) {
  try {
    $r = Invoke-WebRequest -Uri "http://localhost:$Port/$Path" -UseBasicParsing -TimeoutSec 2
    return ($r.StatusCode -eq 200)
  } catch { return $false }
}

function Start-Bg([string]$Script, [string[]]$ScriptArgs) {
  # Two traps here, both of which failed SILENTLY and reported "starting"
  # followed by DOWN:
  #   1. Do not name this parameter $Args. That is a PowerShell automatic
  #      variable and the parameter never binds, so the server launches with no
  #      -Root and no -Port and dies.
  #   2. Every path contains a space ("dark raiders") and Start-Process does not
  #      reliably quote array elements, so build one explicitly quoted string.
  $line = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' + $Script + '"'
  foreach ($a in $ScriptArgs) {
    if ($a -match '^-') { $line += ' ' + $a } else { $line += ' "' + $a + '"' }
  }
  Start-Process -FilePath 'powershell.exe' -ArgumentList $line -WindowStyle Hidden | Out-Null
}

# 8802: the project folder. THIS IS DANIEL'S PLAY LINK.
if (Test-Port 8802 'dark_raiders.html') { "8802 play        already up" }
else { Start-Bg $serve @('-Root', $Root, '-Port', '8802'); "8802 play        starting" }

# 8800: the tools folder, for the test fixture. Separate origin on purpose, so
# test writes land in their own localStorage and never touch his real profile.
if (Test-Port 8800 'fixture.html') { "8800 fixture     already up" }
else { Start-Bg $serve @('-Root', $tools, '-Port', '8800'); "8800 fixture     starting" }

# 8799: telemetry. The game POSTs each run here and it lands in exports/.
if (Test-Port 8799 '') { "8799 collector   already up" }
else { Start-Bg $collector @('-Root', $Root, '-Port', '8799'); "8799 collector   starting" }

# 8779: image sink, so a rendered frame can be written to disk and looked at.
Start-Bg $capture @()

Start-Sleep -Seconds 3
""
"--- listening ---"
"8802 play        " + $(if (Test-Port 8802 'dark_raiders.html') { 'OK  http://localhost:8802/dark_raiders.html' } else { 'DOWN' })
"8800 fixture     " + $(if (Test-Port 8800 'fixture.html')      { 'OK  http://localhost:8800/fixture.html' }      else { 'DOWN (run tools\mkfixture.ps1 first)' })
"8799 collector   " + $(if (Test-Port 8799 '')                  { 'OK' }                                          else { 'DOWN' })
