# host-play-relay.ps1 : the PAD ROUTE on the MAIN PC. Runs play-relay.mjs (a small Node program, no administrator needed) so that Chrome on the
# main PC can open  http://localhost:8802/dark_raiders.html  while the game server runs inside the VM. The Xbox pads stay plugged into the main PC
# and work as they do today, because the page opens on this PC at "localhost".
#
# Run it in a NORMAL PowerShell window (no administrator):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Status
#   -Status            look only: is the relay running, does it find the VM, are the VM's ports answering, what is installed (changes nothing)
#   -Install           (switch-over day, AFTER host-stop.ps1) put a shortcut in your Startup folder so the relay starts at every logon, put a
#                      desktop shortcut "Pillagers play" that opens the game address in Chrome, then start the relay now (-NoStart skips that)
#   -Uninstall         stop the relay and remove exactly the two shortcuts -Install made
#   -Start / -Stop     start the relay hidden / stop it
#   -SetVmAddress IP   write the VM's address into C:\Users\User1\AppData\Local\PillagersMove\vm-address.txt (only needed when the name
#                      <computer name>.mshome.net is not found; the relay re-reads the file by itself, no restart)
#   -VmHost ADDRESS    give the relay an address for this start only (beats everything else)
#   -Ports SPEC        which ports to relay. Default 8802,8799. A TEST relay that does not touch 8802:  -Start -Ports 18802:8802
#                      (listens on 18802 here, forwards to the VM's real game server on port 8802; then open http://localhost:18802/dark_raiders.html.
#                      That page is a different "site" for the browser, so it has its own saved data. The game still posts run reports to
#                      localhost:8799, which is the main PC's own collector until the switch-over.)
#   -Force             -Start/-Install normally want host-stop.ps1 to have been run (a valid host-stopped.txt); -Force skips that one check.
#                      It never overrides "the port is already in use".
#   -NoDesktopShortcut / -NoStartupShortcut / -NoStart   leave that part out of -Install
#   -AtLogon           used by the Startup shortcut: quiet, and does nothing unless host-stopped.txt says stopped
#   -DryRun            only print what would be done (changes nothing)
#
# SAFETY: the relay listens on 127.0.0.1 only, so nothing on the network can reach it. It refuses to start when its port is taken, so it can never
# take over the main PC's own play server (8802) while that still runs. -Install refuses while the main PC's own 8802 server runs or host-stop.ps1
# has not been run. Nothing here changes Windows, firewall or security settings, and no key or password is read.
# The Startup shortcut is called "Play relay (VM)" on purpose (no "Pillagers" in the name): host-stop.ps1 switches off Startup shortcuts that
# have Pillagers in the name, and this one must survive a second run of it.
# Exit codes: 0 done / looks fine, 1 error, 2 refused (a rule above), 3 the relay did not come up.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$Install,
  [switch]$Uninstall,
  [switch]$Start,
  [switch]$Stop,
  [switch]$Status,
  [string]$SetVmAddress = '',
  [string]$VmHost = '',
  [string]$Ports = '',
  [switch]$NoStart,
  [switch]$NoDesktopShortcut,
  [switch]$NoStartupShortcut,
  [switch]$AtLogon,
  [switch]$Force,
  [switch]$DryRun
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'host-play-relay'

$RelayJs     = Join-Path $PSScriptRoot 'play-relay.mjs'
$StartVbs    = Join-Path $PSScriptRoot 'play-relay-start.vbs'
$RelayLog    = Join-Path $PSScriptRoot 'logs\play-relay.log'
$StatusFile  = Join-Path $script:StateDir 'play-relay.status.json'
$InstallFile = Join-Path $script:StateDir 'play-relay-install.json'
$PartyFile   = Join-Path $script:StateDir 'party-copy.json'
$AddrDir     = Split-Path -Path $script:HostStage -Parent
$AddrFile    = Join-Path $AddrDir 'vm-address.txt'
$StartupDir  = [Environment]::GetFolderPath('Startup')
$DesktopDir  = [Environment]::GetFolderPath('Desktop')
$StartupLnk  = Join-Path $StartupDir 'Play relay (VM).lnk'
$DesktopLnk  = Join-Path $DesktopDir 'Pillagers play.lnk'
$DesktopUrl  = Join-Path $DesktopDir 'Pillagers play.url'
$PlayUrl     = 'http://localhost:8802/dark_raiders.html'
$DefaultPorts = '8802,8799'

# ------------------------------------------------------------------ pure helpers (unit-tested without running the script)
function Test-PortSpecText {
  # '8802,8799' or '18802:8802' (listen:target), comma separated. Ports 1024-65535 to listen on.
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
  $seen = @{}
  foreach ($part in ($Text -split ',')) {
    $p = $part.Trim()
    if ($p -notmatch '^(\d{1,5})(:(\d{1,5}))?$') { return $false }
    $l = [int]$Matches[1]
    $t = $l
    if ($Matches[3]) { $t = [int]$Matches[3] }
    if ($l -lt 1024 -or $l -gt 65535 -or $t -lt 1 -or $t -gt 65535) { return $false }
    if ($seen.ContainsKey($l)) { return $false }
    $seen[$l] = $true
  }
  return $true
}

function Get-ListenPorts {
  param([string]$Text)
  $out = @()
  foreach ($part in ($Text -split ',')) { $p = $part.Trim(); if ($p -match '^(\d{1,5})') { $out += [int]$Matches[1] } }
  return @($out)
}

function Test-HostToken {
  # an IPv4 address or a plain host name (letters, digits, dot, dash, underscore); nothing else is ever passed on to the relay
  param([string]$Text)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $false }
  $t = $Text.Trim()
  if ($t -match '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') { foreach ($i in 1..4) { if ([int]$Matches[$i] -gt 255) { return $false } }; return $true }
  if ($t.Length -gt 253) { return $false }
  if ($t -match '^[0-9.]+$') { return $false }
  return ($t -match '^[A-Za-z0-9]([A-Za-z0-9_.-]*[A-Za-z0-9])?$')
}

function Test-PrivateIPv4 {
  param([string]$Text)
  if ($Text -notmatch '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') { return $false }
  $a = [int]$Matches[1]; $b = [int]$Matches[2]; $c = [int]$Matches[3]; $d = [int]$Matches[4]
  if ($a -gt 255 -or $b -gt 255 -or $c -gt 255 -or $d -gt 255 -or $a -eq 0) { return $false }
  if ($a -eq 10 -or $a -eq 127) { return $true }
  if ($a -eq 172 -and $b -ge 16 -and $b -le 31) { return $true }
  if ($a -eq 192 -and $b -eq 168) { return $true }
  if ($a -eq 169 -and $b -eq 254) { return $true }
  return $false
}

function ConvertFrom-ProbeLines {
  # the "key=value" lines printed by: node play-relay.mjs --probe
  param([string[]]$Lines)
  $h = @{}
  foreach ($l in $Lines) { if ($l -match '^([A-Za-z][A-Za-z0-9_.]*)=(.*)$') { $h[$Matches[1]] = $Matches[2].Trim() } }
  return $h
}

# ------------------------------------------------------------------ small helpers
function Find-Node {
  $c = Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c -and $c.Source) { return [string]$c.Source }
  foreach ($p in @('C:\Program Files\nodejs\node.exe', ($env:LOCALAPPDATA + '\Programs\nodejs\node.exe'), ($env:LOCALAPPDATA + '\Microsoft\WinGet\Links\node.exe'))) {
    if (Test-Path -LiteralPath $p) { return $p }
  }
  return ''
}

function Test-LocalPortOpen {
  param([int]$Port)
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $iar = $c.BeginConnect('127.0.0.1', $Port, $null, $null)
    $ok = $iar.AsyncWaitHandle.WaitOne(700) -and $c.Connected
    return [bool]$ok
  } catch { return $false } finally { try { $c.Close() } catch { } }
}

function Get-RelayProcs {
  return @(Get-CimInstance -ClassName Win32_Process -Filter "Name='node.exe'" -ErrorAction SilentlyContinue |
      Where-Object { $_.CommandLine -and ($_.CommandLine -match 'play-relay\.mjs') -and ($_.CommandLine -notmatch '--probe|--help|play-relay\.test') })
}

function Read-RelayStatus {
  if (-not (Test-Path -LiteralPath $StatusFile)) { return $null }
  try { return (Get-Content -LiteralPath $StatusFile -Raw | ConvertFrom-Json) } catch { return $null }
}

function Test-MarkerSaysStopped {
  # The light check used for starting the relay: host-stopped.txt exists, says stopped, belongs to this PC and its check= line is right.
  # (The strict Test-HostStopped from host-common also compares the git HEAD and looks for running helpers; that is for -Install.)
  $mp = Get-MarkerPath
  if (-not (Test-Path -LiteralPath $mp)) { return [pscustomobject]@{ Ok = $false; Why = 'host-stopped.txt does not exist (host-stop.ps1 has not been run)' } }
  $kv = Read-KeyValueFile $mp
  if ($kv['status'] -ne 'stopped') { return [pscustomobject]@{ Ok = $false; Why = ('host-stopped.txt says status="' + $kv['status'] + '"') } }
  if ((-not $kv['computer']) -or ($kv['computer'] -ine $env:COMPUTERNAME)) { return [pscustomobject]@{ Ok = $false; Why = 'host-stopped.txt belongs to another PC' } }
  if (-not $kv['check']) { return [pscustomobject]@{ Ok = $false; Why = 'host-stopped.txt has no check= line' } }
  if ($kv['check'] -ne (Get-MarkerCheck @(Get-Content -LiteralPath $mp))) { return [pscustomobject]@{ Ok = $false; Why = 'host-stopped.txt was changed by hand' } }
  return [pscustomobject]@{ Ok = $true; Why = '' }
}

function Test-PartyCopyRunning {
  # party-host-copy.ps1 -Start writes state\party-copy.json with the process ids of the frozen copy's servers
  if (-not (Test-Path -LiteralPath $PartyFile)) { return $false }
  try {
    $j = Get-Content -LiteralPath $PartyFile -Raw | ConvertFrom-Json
    if ($j.state -ne 'running') { return $false }
    foreach ($id in @($j.pids)) { if ($id -and (Get-Process -Id ([int]$id) -ErrorAction SilentlyContinue)) { return $true } }
  } catch { }
  return $false
}

function Find-Chrome {
  foreach ($p in @(($env:ProgramFiles + '\Google\Chrome\Application\chrome.exe'), (${env:ProgramFiles(x86)} + '\Google\Chrome\Application\chrome.exe'), ($env:LOCALAPPDATA + '\Google\Chrome\Application\chrome.exe'))) {
    if ($p -and (Test-Path -LiteralPath $p)) { return $p }
  }
  return ''
}

function Read-Shortcut {
  param([string]$Path)
  try {
    $sh = New-Object -ComObject WScript.Shell
    $l = $sh.CreateShortcut($Path)
    return [pscustomobject]@{ Target = [string]$l.TargetPath; Args = [string]$l.Arguments }
  } catch { return $null }
}

function New-ShortcutFile {
  param([string]$Path, [string]$Target, [string]$Arguments, [string]$WorkDir, [int]$Style, [string]$Description)
  $sh = New-Object -ComObject WScript.Shell
  $l = $sh.CreateShortcut($Path)
  $l.TargetPath = $Target
  $l.Arguments = $Arguments
  if ($WorkDir) { $l.WorkingDirectory = $WorkDir }
  $l.WindowStyle = $Style
  $l.Description = $Description
  $l.Save()
}

function Get-RelayLogTail {
  param([int]$Lines = 6)
  if (-not (Test-Path -LiteralPath $RelayLog)) { return @() }
  try { return @(Get-Content -LiteralPath $RelayLog -Tail $Lines -ErrorAction Stop) } catch { return @() }
}

function Save-InstallState {
  param([hashtable]$Data)
  if ($DryRun) { return }
  $Data['time'] = (Get-Date).ToString('s')
  Write-AsciiFile -Path $InstallFile -Text ($Data | ConvertTo-Json -Depth 4)
}

# ------------------------------------------------------------------ what the relay will be told
$relayPorts = $DefaultPorts
if ($Ports) { $relayPorts = $Ports.Trim() }
$isTestRelay = ($relayPorts -ne $DefaultPorts)

# ------------------------------------------------------------------ the actions
function Invoke-Status {
  Write-Mig '=== PLAY RELAY: STATUS (looks only, changes nothing) ===' 'STEP'
  $node = Find-Node
  if ($node) { Write-Mig ('Node.js found: ' + $node) 'OK' } else { Write-Mig 'Node.js was not found on this PC (the relay needs it). Install it, or tell Claude.' 'FAIL' }
  if (Test-Path -LiteralPath $RelayJs) { Write-Mig 'play-relay.mjs is in place.' 'OK' } else { Write-Mig ('play-relay.mjs is missing: ' + $RelayJs) 'FAIL' }

  $procs = Get-RelayProcs
  $st = Read-RelayStatus
  $running = ($procs.Count -gt 0)
  if ($running) {
    Write-Mig ('The relay is RUNNING (process ' + (($procs | ForEach-Object { $_.ProcessId }) -join ', ') + ').') 'OK'
  } else {
    Write-Mig 'The relay is not running.' 'INFO'
    if ($st) { Write-Mig 'An old status file from an earlier run is still there (harmless).' 'SKIP' }
  }
  $probePorts = $relayPorts
  if ($running -and $st -and $st.listen) {
    $probePorts = (@($st.listen) | ForEach-Object { [string]$_.listen + ':' + [string]$_.target }) -join ','
    Write-Mig ('  relays: ' + ((@($st.listen) | ForEach-Object { 'localhost:' + $_.listen + ' -> VM port ' + $_.target }) -join ', ')) 'INFO'
    if ($st.target) { Write-Mig ('  it forwards to the VM at ' + $st.target.ip + ' (found by: ' + $st.target.source + ')') 'INFO' }
    elseif ($st.targetProblem) { Write-Mig ('  it does not know the VM address yet: ' + $st.targetProblem) 'WARN' }
    if ($st.stats) { Write-Mig ('  so far: ' + $st.stats.accepted + ' connections, ' + $st.stats.active + ' open now, ' + $st.stats.upstreamFailures + ' could not reach the VM') 'INFO' }
    if ($st.lastError) { Write-Mig ('  last problem (' + $st.lastError.at + '): ' + $st.lastError.message) 'WARN' }
  }

  Write-Mig 'What answers on this PC right now:' 'STEP'
  foreach ($p in (Get-ListenPorts $probePorts)) {
    $open = Test-LocalPortOpen $p
    $label = 'nothing'
    if ($open) { if ($running) { $label = 'something (probably the relay)' } else { $label = 'something that is NOT the relay (the main PC''s own server, or the frozen party copy)' } }
    $lvl = 'INFO'
    if ($open -and -not $running) { $lvl = 'WARN' }
    Write-Mig ('  127.0.0.1:' + $p + ' : ' + $label) $lvl
  }
  if (Test-PartyCopyRunning) { Write-Mig 'The frozen PARTY COPY is serving on this PC (party-host-copy.ps1 -Status says more). The relay stays off while it runs.' 'INFO' }

  Write-Mig 'Can the relay reach the VM?' 'STEP'
  $probeOk = $false
  if ($node -and (Test-Path -LiteralPath $RelayJs)) {
    $probeArgs = @($RelayJs, '--probe', '--ports', $probePorts)
    if ($VmHost) { if (Test-HostToken $VmHost) { $probeArgs += @('--vm-host', $VmHost.Trim()) } }
    $lines = @()
    try { $lines = @(& $node @probeArgs 2>&1 | ForEach-Object { [string]$_ }) } catch { $lines = @('error=' + $_.Exception.Message) }
    $h = ConvertFrom-ProbeLines $lines
    if ($h.ContainsKey('vm')) {
      Write-Mig ('  the VM is at ' + $h['vm'] + ' (found by: ' + $h['source'] + ')') 'OK'
      foreach ($k in @($h.Keys | Where-Object { $_ -like 'port.*' } | Sort-Object)) {
        $pn = $k.Substring(5)
        $v = $h[$k]
        if ($v -eq 'open') { Write-Mig ('  VM port ' + $pn + ': answers') 'OK' }
        elseif ($v -eq 'refused') { Write-Mig ('  VM port ' + $pn + ': the VM is up but no game server listens there (start the servers in the VM)') 'WARN' }
        else { Write-Mig ('  VM port ' + $pn + ': no answer (' + $v + '). The VM may be off, or the rule "Pillagers pad route" is missing in the VM (vm-pad-route-firewall.ps1).') 'WARN' }
      }
      $probeOk = ($h['ok'] -eq 'yes')
    } else {
      $why = ''
      if ($h.ContainsKey('error')) { $why = $h['error'] }
      Write-Mig ('  the VM address could not be found (' + $why + '). Start the VM; the name VM_Oct2026.mshome.net is looked up on its own. If it still fails: run vm-address-report.ps1 in the VM, then here:  host-play-relay.ps1 -SetVmAddress <the address it printed>') 'WARN'
    }
  } else { Write-Mig '  skipped (Node.js or play-relay.mjs is missing)' 'SKIP' }

  Write-Mig 'What is installed:' 'STEP'
  if (Test-Path -LiteralPath $StartupLnk) { Write-Mig ('  Startup shortcut: yes (' + $StartupLnk + ') - the relay starts at every logon') 'OK' } else { Write-Mig '  Startup shortcut: not installed' 'INFO' }
  if ((Test-Path -LiteralPath $DesktopLnk) -or (Test-Path -LiteralPath $DesktopUrl)) { Write-Mig '  Desktop shortcut "Pillagers play": yes' 'OK' } else { Write-Mig '  Desktop shortcut "Pillagers play": not installed' 'INFO' }
  if (Test-Path -LiteralPath $AddrFile) {
    $first = @(Get-Content -LiteralPath $AddrFile -ErrorAction SilentlyContinue | Where-Object { $_ -match '^\s*(ip|address|host|computer|name|mshome)\s*=' } | Select-Object -First 3)
    Write-Mig ('  vm-address.txt: present (' + ($first -join '; ') + ')') 'INFO'
  } else { Write-Mig '  vm-address.txt: none (fine: the name VM_Oct2026.mshome.net is used)' 'INFO' }
  if ($env:PILLAGERS_VM_HOST) { Write-Mig ('  env PILLAGERS_VM_HOST is set to ' + $env:PILLAGERS_VM_HOST + ' (it is used before the file and the name)') 'INFO' }
  $ms = Test-MarkerSaysStopped
  if ($ms.Ok) { Write-Mig '  host-stopped.txt: valid, so the main PC is switched over' 'OK' } else { Write-Mig ('  host-stopped.txt: ' + $ms.Why) 'INFO' }

  Write-MigBlank
  if ($running -and $probeOk) { Write-Mig 'VERDICT: working. Chrome on this PC at http://localhost:8802/dark_raiders.html shows the game from the VM.' 'DONE' }
  elseif ($running) { Write-Mig 'VERDICT: the relay runs but the VM does not answer on every port yet (see above).' 'WARN' }
  else { Write-Mig 'VERDICT: the relay is not running. Start it with -Start (after the switch-over), or -Install to make it start at every logon.' 'INFO' }
  return 0
}

function Invoke-StopRelay {
  param([switch]$Quiet)
  $procs = Get-RelayProcs
  if ($procs.Count -eq 0) {
    if (-not $Quiet) { Write-Mig 'The relay is not running.' 'SKIP' }
    if ((Test-Path -LiteralPath $StatusFile) -and -not $DryRun) { Remove-Item -LiteralPath $StatusFile -Force -ErrorAction SilentlyContinue }
    return $true
  }
  foreach ($p in $procs) {
    if ($DryRun) { Write-Mig ('would stop the relay (process ' + $p.ProcessId + ')') 'DRY'; continue }
    try { Stop-Process -Id ([int]$p.ProcessId) -Force -ErrorAction Stop; Write-Mig ('Stopped the relay (process ' + $p.ProcessId + ').') 'OK' }
    catch { Write-Mig ('Could not stop process ' + $p.ProcessId + ': ' + $_.Exception.Message) 'FAIL'; return $false }
  }
  if (-not $DryRun) {
    Start-Sleep -Milliseconds 500
    if (Test-Path -LiteralPath $StatusFile) { Remove-Item -LiteralPath $StatusFile -Force -ErrorAction SilentlyContinue }
  }
  return $true
}

function Invoke-StartRelay {
  # returns 0 started or already running, 2 refused, 3 did not come up
  param([switch]$Quiet)
  $node = Find-Node
  if (-not $node) { Write-Mig 'Node.js was not found, so the relay cannot start.' 'FAIL'; return 3 }
  if (-not (Test-Path -LiteralPath $RelayJs)) { Write-Mig ('play-relay.mjs is missing: ' + $RelayJs) 'FAIL'; return 3 }
  if (-not (Test-PortSpecText $relayPorts)) { Write-Mig ('-Ports "' + $relayPorts + '" is not valid. Use for example 8802,8799 or 18802:8802.') 'FAIL'; return 2 }
  if ($VmHost -and -not (Test-HostToken $VmHost)) { Write-Mig '-VmHost must be an IPv4 address or a plain host name.' 'FAIL'; return 2 }
  if ($VmHost -and (Test-HostToken $VmHost) -and ($VmHost.Trim() -match '^\d') -and -not (Test-PrivateIPv4 $VmHost.Trim())) { Write-Mig ('-VmHost ' + $VmHost + ' is not a private address (10.x, 172.16-31.x, 192.168.x). Refusing.') 'FAIL'; return 2 }

  $procs = Get-RelayProcs
  if ($procs.Count -gt 0) {
    Write-Mig ('The relay is already running (process ' + $procs[0].ProcessId + '). Use -Status to see what it does, or -Stop first to start it with other settings.') 'OK'
    return 0
  }
  if (Test-PartyCopyRunning) {
    Write-Mig 'The frozen party copy is serving on this PC (party-host-copy.ps1). The relay stays off while it runs. Run party-host-copy.ps1 -Stop first if you want the VM route back.' 'WARN'
    return 2
  }
  if (-not $isTestRelay) {
    $ms = Test-MarkerSaysStopped
    if (-not $ms.Ok) {
      if ($AtLogon) { Write-Mig ('Not starting at logon: ' + $ms.Why + '. (The main PC still runs Pillagers itself, or it was switched back on.)') 'SKIP'; return 0 }
      if (-not $Force) {
        Write-Mig ('Not starting the relay on the real ports: ' + $ms.Why + '.') 'FAIL'
        Write-Mig 'The relay takes over localhost:8802 and :8799. On switch-over day run host-stop.ps1 first, then this. To try the route BEFORE that without touching 8802:  -Start -Ports 18802:8802' 'INFO'
        return 2
      }
      Write-Mig 'host-stopped.txt is not valid, but -Force was given. Going on (the ports must still be free).' 'WARN'
    }
  }
  foreach ($p in (Get-ListenPorts $relayPorts)) {
    if (Test-LocalPortOpen $p) {
      Write-Mig ('Port ' + $p + ' on this PC is already in use by something else. The relay will not take it over.') 'FAIL'
      Write-Mig '  Probably the main PC''s own play server (tools\serve.ps1) or collector is still running. host-stop.ps1 stops them. Nothing was changed.' 'INFO'
      return 2
    }
  }

  $argLine = '"' + $RelayJs + '" --ports ' + $relayPorts.Trim()
  if ($VmHost) { $argLine += ' --vm-host ' + $VmHost.Trim() }
  if ($DryRun) { Write-Mig ('would start hidden: "' + $node + '" ' + $argLine) 'DRY'; return 0 }
  Write-Mig ('Starting the relay (ports ' + $relayPorts.Trim() + ') ...') 'INFO'
  try {
    $proc = Start-Process -FilePath $node -ArgumentList $argLine -WorkingDirectory $PSScriptRoot -WindowStyle Hidden -PassThru
  } catch { Write-Mig ('Could not start node: ' + $_.Exception.Message) 'FAIL'; return 3 }
  $deadline = (Get-Date).AddSeconds(10)
  $up = $false
  while ((Get-Date) -lt $deadline) {
    Start-Sleep -Milliseconds 400
    $st = Read-RelayStatus
    if ($st -and ([int]$st.pid -eq [int]$proc.Id) -and ($st.state -eq 'running')) { $up = $true; break }
    if ($proc.HasExited) { break }
  }
  if (-not $up) {
    Write-Mig 'The relay did not come up. Its log says:' 'FAIL'
    foreach ($l in (Get-RelayLogTail 6)) { Write-Mig ('  ' + $l) 'INFO' }
    return 3
  }
  Write-Mig ('The relay is running (process ' + $proc.Id + '): ' + ((@($st.listen) | ForEach-Object { 'localhost:' + $_.listen + ' -> VM port ' + $_.target }) -join ', ') + '.') 'DONE'
  if ($st.target) { Write-Mig ('  The VM is at ' + $st.target.ip + ' (found by: ' + $st.target.source + ').') 'OK' }
  else { Write-Mig '  The VM address is not known yet. That is normal when the VM is still starting; the relay looks again whenever Chrome connects.' 'WARN' }
  if (-not $Quiet) {
    $first = (Get-ListenPorts $relayPorts)[0]
    Write-Mig ('  Open  http://localhost:' + $first + '/dark_raiders.html  in Chrome on this PC. If a page says "the vm is not answering", the VM is off or its firewall rule is missing.') 'INFO'
  }
  return 0
}

function Invoke-Install {
  Write-Mig '=== PLAY RELAY: INSTALL ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  if ($isTestRelay -or $VmHost) { Write-Mig '-Install always installs the normal relay (ports 8802,8799, the usual way of finding the VM). Use -Start -Ports ... for a test.' 'FAIL'; return 2 }
  if (-not (Test-HostProfileOk)) { return 1 }
  if (-not (Find-Node)) { Write-Mig 'Node.js was not found; the relay needs it.' 'FAIL'; return 1 }
  foreach ($f in @($RelayJs, $StartVbs)) { if (-not (Test-Path -LiteralPath $f)) { Write-Mig ('A file of the kit is missing: ' + $f) 'FAIL'; return 1 } }

  # the main PC must be switched over first
  $hs = Test-HostStopped
  $running = (Get-RelayProcs).Count -gt 0
  $busy = @()
  foreach ($p in (Get-ListenPorts $DefaultPorts)) { if (Test-LocalPortOpen $p) { $busy += $p } }
  if ($busy.Count -gt 0 -and -not $running) {
    Write-Mig ('Port ' + ($busy -join ', ') + ' on this PC is in use by something that is not the relay (the main PC''s own play server or collector, or the party copy).') 'FAIL'
    if (-not $hs.Ok) { Write-Mig 'The main PC is not switched over yet. Run host-stop.ps1 first (it stops those servers), then -Install.' 'INFO' }
    else { Write-Mig 'Stop that program first (party-host-copy.ps1 -Stop for the party copy), then -Install.' 'INFO' }
    return 2
  }
  if (-not $hs.Ok) {
    Write-Mig 'The main PC is not marked as switched over:' 'WARN'
    foreach ($w in $hs.Why) { Write-Mig ('  - ' + $w) 'WARN' }
    if (-not $Force) {
      Write-Mig 'Not installing. A Startup shortcut would make the relay grab localhost:8802 at the next logon and could block the main PC''s own play server while Pillagers still runs here.' 'FAIL'
      Write-Mig 'Do the switch-over (host-stop.ps1) first. -Force skips only this check and is for when you know the main PC no longer runs Pillagers.' 'INFO'
      return 2
    }
    Write-Mig '-Force given: going on.' 'WARN'
  } else { Write-Mig 'The main PC is switched over (host-stopped.txt is valid and nothing of Pillagers runs here).' 'OK' }

  $created = @{ startupLnk = ''; desktopLnk = ''; desktopUrl = '' }
  # 1. Startup shortcut -> wscript -> play-relay-start.vbs -> host-play-relay.ps1 -Start -AtLogon (no window flashes)
  if ($NoStartupShortcut) { Write-Mig 'Startup shortcut: skipped (-NoStartupShortcut).' 'SKIP' }
  else {
    $wscript = Join-Path $env:SystemRoot 'System32\wscript.exe'
    $want = '"' + $StartVbs + '"'
    $cur = $null
    if (Test-Path -LiteralPath $StartupLnk) { $cur = Read-Shortcut $StartupLnk }
    if ($cur -and ($cur.Args -eq $want) -and ($cur.Target -ieq $wscript)) { Write-Mig 'Startup shortcut: already there.' 'SKIP'; $created['startupLnk'] = $StartupLnk }
    elseif ($DryRun) { Write-Mig ('would create the Startup shortcut: ' + $StartupLnk + '  ->  wscript.exe ' + $want) 'DRY' }
    else {
      try {
        if (-not (Test-Path -LiteralPath $StartupDir)) { New-Item -ItemType Directory -Force -Path $StartupDir | Out-Null }
        New-ShortcutFile -Path $StartupLnk -Target $wscript -Arguments $want -WorkDir $PSScriptRoot -Style 7 -Description 'Starts the Pillagers play relay (the game address on this PC reaches the VM). Remove it with host-play-relay.ps1 -Uninstall.'
        Write-Mig ('Startup shortcut created: ' + $StartupLnk) 'DONE'
        $created['startupLnk'] = $StartupLnk
      } catch { Write-Mig ('Could not create the Startup shortcut: ' + $_.Exception.Message) 'FAIL'; return 1 }
    }
  }
  # 2. Desktop shortcut "Pillagers play": the same address you would type into Chrome
  if ($NoDesktopShortcut) { Write-Mig 'Desktop shortcut: skipped (-NoDesktopShortcut).' 'SKIP' }
  else {
    $chrome = Find-Chrome
    if ($chrome) {
      $cur = $null
      if (Test-Path -LiteralPath $DesktopLnk) { $cur = Read-Shortcut $DesktopLnk }
      if ($cur -and ($cur.Args -eq $PlayUrl) -and ($cur.Target -ieq $chrome)) { Write-Mig 'Desktop shortcut "Pillagers play": already there.' 'SKIP'; $created['desktopLnk'] = $DesktopLnk }
      elseif ((Test-Path -LiteralPath $DesktopLnk) -and -not $cur) { Write-Mig ('A file named "Pillagers play.lnk" exists on the Desktop and cannot be read. It is left alone.') 'WARN' }
      elseif ((Test-Path -LiteralPath $DesktopLnk) -and ($cur.Args -ne $PlayUrl)) { Write-Mig 'A different shortcut named "Pillagers play" already exists on the Desktop. It is left alone.' 'WARN' }
      elseif ($DryRun) { Write-Mig ('would create the Desktop shortcut "Pillagers play" -> Chrome ' + $PlayUrl) 'DRY' }
      else {
        try {
          New-ShortcutFile -Path $DesktopLnk -Target $chrome -Arguments $PlayUrl -WorkDir '' -Style 1 -Description 'Opens the Pillagers game in Chrome on this PC (so the Xbox pads work). The game itself runs in the VM.'
          Write-Mig 'Desktop shortcut "Pillagers play" created (opens Chrome at the game address).' 'DONE'
          $created['desktopLnk'] = $DesktopLnk
        } catch { Write-Mig ('Could not create the Desktop shortcut: ' + $_.Exception.Message) 'WARN' }
      }
    } else {
      if ((Test-Path -LiteralPath $DesktopUrl)) { Write-Mig 'Desktop shortcut "Pillagers play.url": already there.' 'SKIP'; $created['desktopUrl'] = $DesktopUrl }
      elseif ($DryRun) { Write-Mig ('Chrome was not found; would create an Internet shortcut "Pillagers play.url" for ' + $PlayUrl) 'DRY' }
      else {
        try { Write-AsciiFile -Path $DesktopUrl -Text ("[InternetShortcut]`r`nURL=" + $PlayUrl + "`r`n"); Write-Mig 'Chrome was not found; created an Internet shortcut "Pillagers play.url" (opens in your default browser).' 'DONE'; $created['desktopUrl'] = $DesktopUrl }
        catch { Write-Mig ('Could not create the Desktop shortcut: ' + $_.Exception.Message) 'WARN' }
      }
    }
  }
  Save-InstallState $created
  # 3. start it now
  if ($NoStart) { Write-Mig 'Not starting the relay now (-NoStart). It will start at the next logon.' 'SKIP'; return 0 }
  $rc = Invoke-StartRelay
  return $rc
}

function Invoke-Uninstall {
  Write-Mig '=== PLAY RELAY: UNINSTALL ===' 'STEP'
  if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }
  [void](Invoke-StopRelay)
  # only shortcuts that point at our own files / address are removed
  if (Test-Path -LiteralPath $StartupLnk) {
    $c = Read-Shortcut $StartupLnk
    if ($c -and ($c.Args -match 'play-relay-start\.vbs')) {
      if ($DryRun) { Write-Mig ('would remove ' + $StartupLnk) 'DRY' } else { Remove-Item -LiteralPath $StartupLnk -Force -ErrorAction SilentlyContinue; Write-Mig 'Startup shortcut removed.' 'DONE' }
    } else { Write-Mig 'A file "Play relay (VM).lnk" is in the Startup folder but does not start our relay, so it is left alone.' 'WARN' }
  } else { Write-Mig 'No Startup shortcut to remove.' 'SKIP' }
  if (Test-Path -LiteralPath $DesktopLnk) {
    $c = Read-Shortcut $DesktopLnk
    if ($c -and ($c.Args -eq $PlayUrl)) {
      if ($DryRun) { Write-Mig ('would remove ' + $DesktopLnk) 'DRY' } else { Remove-Item -LiteralPath $DesktopLnk -Force -ErrorAction SilentlyContinue; Write-Mig 'Desktop shortcut "Pillagers play" removed.' 'DONE' }
    } else { Write-Mig 'A Desktop shortcut "Pillagers play" exists but is not the one this script made, so it is left alone.' 'WARN' }
  } else { Write-Mig 'No Desktop shortcut "Pillagers play" to remove.' 'SKIP' }
  if (Test-Path -LiteralPath $DesktopUrl) {
    $t = ''
    try { $t = Get-Content -LiteralPath $DesktopUrl -Raw } catch { }
    if ($t -match [regex]::Escape($PlayUrl)) {
      if ($DryRun) { Write-Mig ('would remove ' + $DesktopUrl) 'DRY' } else { Remove-Item -LiteralPath $DesktopUrl -Force -ErrorAction SilentlyContinue; Write-Mig 'Desktop Internet shortcut removed.' 'DONE' }
    }
  }
  if ((Test-Path -LiteralPath $InstallFile) -and -not $DryRun) { Remove-Item -LiteralPath $InstallFile -Force -ErrorAction SilentlyContinue }
  Write-Mig 'Left as they are: vm-address.txt and the logs (harmless).' 'INFO'
  return 0
}

function Invoke-SetVmAddress {
  $a = $SetVmAddress.Trim()
  if (-not (Test-HostToken $a)) { Write-Mig 'That is not an IPv4 address or a plain host name.' 'FAIL'; return 2 }
  $isIp = ($a -match '^\d')
  if ($isIp -and -not (Test-PrivateIPv4 $a)) { Write-Mig ($a + ' is not a private address (10.x, 172.16-31.x, 192.168.x). The VM is never on the internet. Refusing.') 'FAIL'; return 2 }
  $key = 'ip'
  if (-not $isIp) { $key = 'computer' }
  $text = "# written by host-play-relay.ps1 -SetVmAddress on " + (Get-Date -Format 's') + "`r`n" + $key + '=' + $a + "`r`n"
  if ($DryRun) { Write-Mig ('would write ' + $AddrFile + ': ' + $key + '=' + $a) 'DRY'; return 0 }
  Write-AsciiFile -Path $AddrFile -Text $text
  Write-Mig ('Wrote ' + $AddrFile + ' (' + $key + '=' + $a + '). A running relay reads it again by itself the next time a connection to the VM fails.') 'DONE'
  return 0
}

# ------------------------------------------------------------------ choose the action
$chosen = @()
if ($Install) { $chosen += 'Install' }
if ($Uninstall) { $chosen += 'Uninstall' }
if ($Start) { $chosen += 'Start' }
if ($Stop) { $chosen += 'Stop' }
if ($Status) { $chosen += 'Status' }
if ($SetVmAddress) { $chosen += 'SetVmAddress' }
if ($chosen.Count -ne 1) {
  Write-Mig 'Choose exactly one of: -Status, -Install, -Uninstall, -Start, -Stop, -SetVmAddress <address>. Start with -Status (it changes nothing).' 'WARN'
  Exit-Mig 1
}
$rc = 0
switch ($chosen[0]) {
  'Status'       { $rc = Invoke-Status }
  'Install'      { $rc = Invoke-Install }
  'Uninstall'    { $rc = Invoke-Uninstall }
  'Start'        { Write-Mig '=== PLAY RELAY: START ===' 'STEP'; if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }; $rc = Invoke-StartRelay -Quiet:$AtLogon }
  'Stop'         { Write-Mig '=== PLAY RELAY: STOP ===' 'STEP'; if ($DryRun) { Write-Mig '(dry run: nothing will be changed)' 'DRY' }; if (Invoke-StopRelay) { $rc = 0 } else { $rc = 1 } }
  'SetVmAddress' { $rc = Invoke-SetVmAddress }
}
Exit-Mig $rc
