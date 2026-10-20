# host-bridge.ps1 : runs and manages the HOST BRIDGE AGENT on the MAIN PC - the small program that lets the VM's Claude ask this PC for the
# fixed Pillagers jobs (see README.md next to this file). The agent runs AS YOU, with no administrator rights. The only part that needs an
# administrator window is the one-time firewall rule (-Firewall), because changing the Windows Firewall always does.
#
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Status     look only: key, Default Switch, firewall rule, is the agent running (changes nothing)
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Start      start the agent now, hidden
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Stop       stop the agent
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Install    put a shortcut in your Startup folder so the agent starts at every logon, then start it now
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Uninstall  stop it and remove the Startup shortcut
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Firewall   add the inbound rule (ADMINISTRATOR window). TCP 8830, only from the Default Switch, only this PC's node.exe
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Firewall -Undo   remove that rule (administrator)
#   -DryRun     with -Firewall: print the rule it would add and change nothing
#   -Port N     listen on a different port (default 8830); must match what the VM uses
#
# SAFETY: the agent binds ONLY to the Hyper-V Default Switch address, so no device on your real network can reach it. The firewall rule limits
# callers to the Default Switch network and to this PC's node.exe. Every request must be signed with the shared key. The agent only ever runs the
# named jobs in jobs.mjs. ASCII only. Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$Status,
  [switch]$Start,
  [switch]$Stop,
  [switch]$Install,
  [switch]$Uninstall,
  [switch]$Firewall,
  [switch]$Undo,
  [switch]$DryRun,
  [int]$Port = 8830
)
$ErrorActionPreference = 'Continue'
$RuleName = 'Pillagers bridge for VM'
$here = $PSScriptRoot
$agent = Join-Path $here 'host-agent.mjs'
$logDir = Join-Path $env:LOCALAPPDATA 'PillagersBridge\logs'
$pidFile = Join-Path $env:LOCALAPPDATA 'PillagersBridge\agent.pid'

function Say([string]$m, [string]$tag = 'INFO') {
  $c = @{ OK='Green'; FAIL='Red'; WARN='Yellow'; DONE='Cyan'; DRY='Gray'; STEP='White' }[$tag]
  if (-not $c) { $c = 'Gray' }
  Write-Host ('{0,-5} {1}' -f $tag, $m) -ForegroundColor $c
}
function Find-Node {
  $c = Get-Command node -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  foreach ($p in @("$env:LOCALAPPDATA\Microsoft\WinGet\Packages\OpenJS.NodeJS.LTS_Microsoft.Winget.Source_8wekyb3d8bbwe\node-v24.20.0-win-x64\node.exe", "$env:ProgramFiles\nodejs\node.exe")) { if (Test-Path -LiteralPath $p) { return $p } }
  return $null
}
function Test-IsAdmin { try { return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) } catch { return $false } }
function Switch-Net {
  try { Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Where-Object { $_.InterfaceAlias -like '*Default Switch*' } | Select-Object -First 1 } catch { $null }
}
function Agent-Proc {
  # Prefer the process that actually holds the listen port (reliable even when the command line cannot be read); fall back to a command-line match.
  try {
    $c = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
    if ($c) { $p = Get-CimInstance Win32_Process -Filter ("ProcessId=" + $c.OwningProcess) -ErrorAction SilentlyContinue; if ($p -and $p.Name -eq 'node.exe') { return $p } }
  } catch { }
  Get-CimInstance Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'host-agent\.mjs' }
}

# ---------------------------------------------------------------- firewall (administrator)
if ($Firewall) {
  $sw = Switch-Net
  if (-not $sw) { Say 'The Hyper-V Default Switch card was not found. Is Hyper-V on and the VM created?' 'FAIL'; exit 2 }
  $prefix = [int]$sw.PrefixLength; $addr = $sw.IPAddress
  # network base, e.g. 192.168.160.0/20. All math in Int64 (the L suffix) so 0xFFFFFFFF is never read as -1.
  $o = $addr -split '\.' | ForEach-Object { [int64]$_ }
  $full = ($o[0] * 16777216L) + ($o[1] * 65536L) + ($o[2] * 256L) + $o[3]
  $mask = if ($prefix -le 0) { 0L } elseif ($prefix -ge 32) { 4294967295L } else { (4294967295L -shl (32 - $prefix)) -band 4294967295L }
  $net = $full -band $mask
  $netStr = ('{0}.{1}.{2}.{3}/{4}' -f (($net -shr 24) -band 255), (($net -shr 16) -band 255), (($net -shr 8) -band 255), ($net -band 255), $prefix)
  $node = Find-Node
  if (-not $node) { Say 'node.exe not found; cannot scope the rule to it. Install Node first.' 'FAIL'; exit 2 }
  Say ('rule "' + $RuleName + '": inbound, allow, TCP ' + $Port + ', only from ' + $netStr + ', only program ' + $node) 'STEP'
  if ($DryRun) { Say 'dry run: nothing changed.' 'DRY'; exit 0 }
  if (-not (Test-IsAdmin)) { Say 'This needs an ADMINISTRATOR window. Right-click PowerShell, Run as administrator, run the same command.' 'FAIL'; exit 3 }
  $existing = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
  if ($Undo) {
    if ($existing) { $existing | Remove-NetFirewallRule; Say 'rule removed. The VM can no longer reach the bridge.' 'DONE' } else { Say 'no such rule; nothing to remove.' 'INFO' }
    exit 0
  }
  if ($existing) { $existing | Remove-NetFirewallRule }
  try {
    New-NetFirewallRule -DisplayName $RuleName -Description 'Lets the Pillagers VM reach the host bridge agent. Remove with host-bridge.ps1 -Firewall -Undo.' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port -RemoteAddress $netStr -Program $node -Profile Any -ErrorAction Stop | Out-Null
    Say ('rule added: TCP ' + $Port + ' inbound, only from ' + $netStr + ', only ' + (Split-Path $node -Leaf)) 'DONE'
  } catch { Say ('could not add the rule: ' + $_.Exception.Message) 'FAIL'; exit 1 }
  exit 0
}

# ---------------------------------------------------------------- stop
if ($Stop -or $Uninstall) {
  $p = Agent-Proc
  if ($p) { $p | ForEach-Object { try { Stop-Process -Id $_.ProcessId -Force; Say ('stopped the agent (pid ' + $_.ProcessId + ')') 'DONE' } catch { Say ('could not stop pid ' + $_.ProcessId + ': ' + $_.Exception.Message) 'WARN' } } }
  else { Say 'the agent was not running.' 'INFO' }
  if ($Uninstall) {
    $lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'Pillagers bridge.lnk'
    if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force; Say ('removed the Startup shortcut: ' + $lnk) 'DONE' } else { Say 'no Startup shortcut to remove.' 'INFO' }
  }
  if (-not $Start) { exit 0 }
}

# ---------------------------------------------------------------- status
if ($Status) {
  $node = Find-Node
  Say ('node: ' + ($(if ($node) { $node } else { 'NOT FOUND' }))) $(if ($node) { 'OK' } else { 'FAIL' })
  $keyFile = Join-Path $env:LOCALAPPDATA 'PillagersBridge\key.txt'
  $haveKey = $false; try { if ((Get-Content -LiteralPath $keyFile -Raw -ErrorAction Stop).Trim() -match '^[0-9a-fA-F]{64}$') { $haveKey = $true } } catch { }
  Say ('shared key: ' + $(if ($haveKey) { 'present (' + $keyFile + ')' } else { 'MISSING - run setup-key.ps1' })) $(if ($haveKey) { 'OK' } else { 'FAIL' })
  $sw = Switch-Net
  Say ('Default Switch: ' + $(if ($sw) { $sw.IPAddress + '/' + $sw.PrefixLength } else { 'not up' })) $(if ($sw) { 'OK' } else { 'WARN' })
  $fw = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue
  Say ('firewall rule "' + $RuleName + '": ' + $(if ($fw) { 'present (' + $fw.Enabled + ')' } else { 'NOT there - run -Firewall in an administrator window' })) $(if ($fw) { 'OK' } else { 'WARN' })
  $p = Agent-Proc
  Say ('agent running: ' + $(if ($p) { 'yes (pid ' + (@($p)[0].ProcessId) + ')' } else { 'no' })) $(if ($p) { 'OK' } else { 'INFO' })
  if ($node -and $haveKey) { & $node $agent --status 2>$null | Out-Null }
  exit 0
}

# ---------------------------------------------------------------- start / install
$node = Find-Node
if (-not $node) { Say 'node.exe not found. Install Node first.' 'FAIL'; exit 1 }
$keyFile = Join-Path $env:LOCALAPPDATA 'PillagersBridge\key.txt'
$haveKey = $false; try { if ((Get-Content -LiteralPath $keyFile -Raw -ErrorAction Stop).Trim() -match '^[0-9a-fA-F]{64}$') { $haveKey = $true } } catch { }
if (-not $haveKey) { Say 'No shared key yet. Run setup-key.ps1 first (no administrator needed).' 'FAIL'; exit 1 }

if ($Install) {
  $startup = [Environment]::GetFolderPath('Startup')
  $lnk = Join-Path $startup 'Pillagers bridge.lnk'
  $vbs = Join-Path $here 'start-agent-hidden.vbs'
  $vbsBody = 'Set s = CreateObject("WScript.Shell") : s.Run "' + ($node -replace '"', '""') + ' ""' + ($agent -replace '"', '""') + '"" --port ' + $Port + '", 0, False'
  Set-Content -LiteralPath $vbs -Value $vbsBody -Encoding Ascii
  try {
    $sh = New-Object -ComObject WScript.Shell
    $l = $sh.CreateShortcut($lnk)
    $l.TargetPath = 'wscript.exe'
    $l.Arguments = '"' + $vbs + '"'
    $l.WorkingDirectory = $here
    $l.Description = 'Starts the Pillagers host bridge agent at logon. Remove with host-bridge.ps1 -Uninstall.'
    $l.WindowStyle = 7
    $l.Save()
    Say ('Startup shortcut created: ' + $lnk) 'DONE'
  } catch { Say ('could not create the Startup shortcut: ' + $_.Exception.Message) 'FAIL' }
}

# start now (hidden) if not already running
if (Agent-Proc) { Say 'the agent is already running.' 'INFO'; exit 0 }
if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
try {
  $p = Start-Process -FilePath $node -ArgumentList @("`"$agent`"", '--port', "$Port") -WorkingDirectory $here -WindowStyle Hidden -PassThru
  Set-Content -LiteralPath $pidFile -Value $p.Id -Encoding Ascii
  Start-Sleep -Milliseconds 800
  if (Agent-Proc) { Say ('agent started (pid ' + $p.Id + '). Log: ' + (Join-Path $logDir 'host-agent.log')) 'DONE' }
  else { Say 'the agent did not stay up; check the log.' 'FAIL'; exit 1 }
} catch { Say ('could not start the agent: ' + $_.Exception.Message) 'FAIL'; exit 1 }
exit 0
