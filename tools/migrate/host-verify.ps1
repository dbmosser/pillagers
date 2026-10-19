<#
host-verify.ps1  -  the main PC's half of the MUST-PASS checklist (VM name: Pillagers_Oct26)

WHAT IT IS
  A read-only check you run on the MAIN PC (JUL26), in a NORMAL PowerShell window (no administrator window needed). It answers: "is the main
  PC ready to be only my work PC, and is the VM set up to do Pillagers by itself?" It prints one line per item (PASS, FAIL, WAIT or WARN, and a
  plain "fix:" line under everything that is not PASS) and ends with a count and one verdict line.
  Its twin for the inside of the VM is vm-verify.ps1.

HOW TO RUN (main PC)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-verify.ps1"
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-verify.ps1" -DryRun     (lists the checks, tests nothing)
  Add -VMName "name" if the VM is not called Pillagers_Oct26, -NoNetwork to skip the two requests (relay, Ollama bridge).

WHAT IT CHECKS
   the VM         its Automatic Start Action is "Start" with a 60 second delay (so it comes back by itself after this PC restarts), and its state is
                  Running. A normal window is often NOT allowed to read Hyper-V; then this says so plainly (WAIT), shows the indirect evidence it can
                  see (the Hyper-V service, VM worker processes) and tells you how to read it (administrator window, or Hyper-V Manager).
   the pad route  the relay that makes http://localhost:8802/ and :8799 on this PC show the game that runs in the VM (only needed for the party
                  night, so "not running yet" is a WARN): who listens on 127.0.0.1 port 8802 and 8799, that it is the loopback address only and not the
                  old Pillagers server, and (only if it is the relay) that it answers.
   Ollama bridge  the user variable OLLAMA_HOST, the firewall rule "Pillagers Ollama for VM" (read from the registry), Ollama listening beyond
                  127.0.0.1, and a request to Ollama at this PC's Default Switch address (what the VM's audits use). Full detail: host-ollama-bridge.ps1 -Status.
   nothing here   no Pillagers runner, lane, helper run, ship, test run, server, dashboard or test Chrome runs on this PC (every process whose command line
                  points into C:\claudecode\dark raiders, C:\claudecode\pillagers-codex or Desktop\dark raiders is listed by name); the Pillagers
                  scheduled tasks are switched off; no Pillagers startup shortcut is active; no ship lock is held.
   the marker     tools\migrate\host-stopped.txt exists, says stopped, names THIS computer, and its check= line matches (the file the VM trusts).

WHAT THE WORDS MEAN
  PASS  right.   FAIL  wrong, fix it (the fix line says how).   WAIT  not done yet or cannot be read from here (a step that is yours, or that comes
  with switch-over day).   WARN  worth a look, not a failure (the pad route before the party; the repo moved after the stop).
  Exit code: 0 = no FAIL and no WAIT, 1 = at least one FAIL, 2 = no FAIL but something is WAIT.

WHAT IT NEVER DOES
  It never stops, starts or changes anything: no process is touched, no task, no file except its own log (tools\migrate\logs\host-verify-<time>.log),
  no setting, no firewall command (rules are read from the registry). It sends a request (one bare HEAD to 8802, one GET to 8799) ONLY to the
  relay itself: a node.exe running play-relay.mjs that listens on 127.0.0.1. Whatever else holds those ports (your own play server and collector
  today, which Windows lists as the System process because they use HTTP.sys, or the party copy) is never sent a request. No secret value is read, printed or logged; the only variable value read is
  OLLAMA_HOST (a host:port address). ASCII only. Works in Windows PowerShell 5.1.
#>
[CmdletBinding()]
param(
  [Alias('WhatIf')][switch]$DryRun,
  [string]$VMName = 'Pillagers_Oct26',
  [switch]$NoNetwork,
  [int]$TimeoutSec = 6
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$script:CommonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $script:CommonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $script:CommonPath); exit 1 }
. $script:CommonPath

$script:ScriptVersion = 'host-verify 1.0 (2026-10-19)'
$script:DryRun = [bool]$DryRun
$script:NoNet = [bool]$NoNetwork
$script:HttpTimeout = $TimeoutSec
$script:VmName = $VMName
$script:RelayPorts = @(8802, 8799)
$script:RelayProbes = @{ 8802 = @{ Method = 'HEAD'; Path = '/' }; 8799 = @{ Method = 'GET'; Path = '/' } }
$script:OllamaRuleName = 'Pillagers Ollama for VM'
$script:OllamaPort = 11434
$script:SwitchAlias = 'vEthernet (Default Switch)'
$script:FallbackSwitchIp = '192.168.160.1'
$script:StartupDir = [Environment]::GetFolderPath('Startup')
$script:RepoRx = '(?i)claudecode[\\/]dark raiders|Desktop[\\/]dark raiders|claudecode[\\/]pillagers-codex'

$script:Results = New-Object System.Collections.ArrayList
$script:Section = ''
$script:Marker = $null
$script:Stopped = $false
$script:Snap = $null

# ----------------------------------------------------------------------------------------------------------------------
# output
# ----------------------------------------------------------------------------------------------------------------------
function Clean-Ascii([string]$s) {
  if ($null -eq $s) { return '' }
  return [System.Text.RegularExpressions.Regex]::Replace($s, '[^\x20-\x7E]', '?')
}
function Out-Line([string]$Text, [string]$Color = 'Gray') {
  $t = Clean-Ascii (Protect-Text $Text)
  Write-Host $t -ForegroundColor $Color
  if ($script:MigLog) { try { Add-Content -LiteralPath $script:MigLog -Value $t -Encoding ASCII } catch { } }
}
function Out-Blank { Out-Line '' }
function Out-Section([string]$Title) { $script:Section = $Title; Out-Blank; Out-Line ('== ' + $Title) 'Cyan' }
function Add-Result([string]$State, [string]$Name, [string]$Detail = '', [string]$Fix = '') {
  $n = $script:Results.Count + 1
  [void]$script:Results.Add([pscustomobject]@{ N = $n; State = $State; Name = $Name; Detail = $Detail; Fix = $Fix; Section = $script:Section })
  $color = 'Gray'
  switch ($State) { 'PASS' { $color = 'Green' } 'FAIL' { $color = 'Red' } 'WAIT' { $color = 'Yellow' } 'WARN' { $color = 'DarkYellow' } }
  $line = '[' + $State + '] ' + $n.ToString().PadLeft(2) + '  ' + $Name
  if ($Detail) { $line += '  -  ' + $Detail }
  Out-Line $line $color
  if ($Fix -and $State -ne 'PASS') { Out-Line ('            fix: ' + $Fix) 'Gray' }
}
# a state that depends on the switch-over: WAIT before it, FAIL after it
function Get-GatedBad { if ($script:Stopped) { return 'FAIL' } return 'WAIT' }

# ----------------------------------------------------------------------------------------------------------------------
# readers (all read-only)
# ----------------------------------------------------------------------------------------------------------------------
function Test-HttpEndpoint {
  param([string]$Url, [string]$Method = 'GET', [int]$Seconds = 6, [switch]$ReadBody)
  $o = [pscustomobject]@{ Answered = $false; Status = 0; Body = ''; Error = '' }
  $resp = $null
  try {
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Method = $Method
    $req.Timeout = $Seconds * 1000
    $req.ReadWriteTimeout = $Seconds * 1000
    $req.KeepAlive = $false
    $req.Proxy = $null
    $req.AllowAutoRedirect = $false
    $req.UserAgent = 'pillagers-host-verify'
    try { $resp = $req.GetResponse() }
    catch [System.Net.WebException] {
      if ($_.Exception.Response) { $resp = $_.Exception.Response } else { throw }
    }
    $o.Answered = $true
    $o.Status = [int]$resp.StatusCode
    if ($ReadBody -and $Method -eq 'GET') {
      $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
      try { $o.Body = $sr.ReadToEnd() } finally { $sr.Close() }
    }
  } catch { $o.Error = $_.Exception.Message }
  finally { if ($resp) { try { $resp.Close() } catch { } } }
  return $o
}

function Get-VmFacts([string]$Name) {
  $o = [pscustomobject]@{ Readable = $false; Denied = $false; NoModule = $false; Exists = $false; State = ''; AutoStart = ''; AutoDelay = -1; StopAction = ''; MemoryGB = 0; Err = '' }
  if (-not (Get-Command Get-VM -ErrorAction SilentlyContinue)) { $o.NoModule = $true; $o.Err = 'the Hyper-V PowerShell module is not installed here'; return $o }
  try {
    $vm = Get-VM -Name $Name -ErrorAction Stop
    $o.Readable = $true
    $o.Exists = $true
    $o.State = [string]$vm.State
    $o.AutoStart = [string]$vm.AutomaticStartAction
    $o.AutoDelay = [int]$vm.AutomaticStartDelay
    $o.StopAction = [string]$vm.AutomaticStopAction
    try { $o.MemoryGB = [math]::Round(([double]$vm.MemoryStartup) / 1GB, 1) } catch { }
  } catch {
    $m = $_.Exception.Message
    $o.Err = $m
    if ($m -match '(?i)permission|authoriz|access is denied|privilege|0x80070005|0x80041008') { $o.Denied = $true }
    elseif ($m -match '(?i)unable to find|no virtual machine|cannot find') {
      # a normal (non-administrator) window often sees NO virtual machines at all, so "not found" is ambiguous there
      if (Test-IsAdmin) { $o.Readable = $true; $o.Exists = $false } else { $o.Denied = $true }
    }
  }
  return $o
}

function Get-IndirectVmEvidence {
  # what a normal window can still see: the Hyper-V management service and the per-VM worker processes
  $svc = ''
  try { $s = Get-Service -Name vmms -ErrorAction Stop; $svc = [string]$s.Status } catch { $svc = 'not found' }
  $workers = 0
  try { $workers = @(Get-Process -Name vmwp -ErrorAction SilentlyContinue).Count } catch { }
  return [pscustomobject]@{ Service = $svc; Workers = $workers }
}

function Get-SwitchIp {
  $o = [pscustomobject]@{ Ip = $script:FallbackSwitchIp; Live = $false }
  try {
    $a = @(Get-NetIPAddress -InterfaceAlias $script:SwitchAlias -AddressFamily IPv4 -ErrorAction Stop | Select-Object -First 1)
    if ($a.Count -gt 0 -and $a[0].IPAddress) { $o.Ip = [string]$a[0].IPAddress; $o.Live = $true }
  } catch { }
  return $o
}
function Get-OllamaHostVar { return [string][Environment]::GetEnvironmentVariable('OLLAMA_HOST', 'User') }

function Get-PortListeners {
  # who listens on these TCP ports (Get-NetTCPConnection works without administrator rights); one object per address+port
  param([int[]]$Ports, [object[]]$Snap)
  $out = New-Object System.Collections.ArrayList
  $conns = @()
  try { $conns = @(Get-NetTCPConnection -State Listen -ErrorAction Stop | Where-Object { $Ports -contains [int]$_.LocalPort }) } catch { $conns = @() }
  foreach ($c in $conns) {
    $p = $null
    if ($Snap) { $p = $Snap | Where-Object { [int]$_.ProcessId -eq [int]$c.OwningProcess } | Select-Object -First 1 }
    $name = ''
    $cmd = ''
    if ($p) { $name = [string]$p.Name; $cmd = [string]$p.CommandLine }
    else { try { $name = [string](Get-Process -Id ([int]$c.OwningProcess) -ErrorAction Stop).ProcessName } catch { } }
    $kind = 'other'
    $ownerPid = [int]$c.OwningProcess
    if ($ownerPid -eq 4) {
      # An HttpListener (tools\serve.ps1, tools\collector.ps1) is served by Windows HTTP.sys, so its socket belongs to the System process (pid 4), never to
      # powershell.exe. Find the script by its command line instead (it names its port with -Port). Nothing is ever sent to such a listener.
      $kind = 'httpsys'
      if ($Snap) {
        $rxPort = '(?i)-Port\s+["'']?' + [int]$c.LocalPort + '\b'
        $owner = $Snap | Where-Object { $_.CommandLine -and ([string]$_.CommandLine -match $script:RxServers) -and ([string]$_.CommandLine -match $rxPort) } | Select-Object -First 1
        if ($owner) { $kind = 'old'; $name = [string]$owner.Name; $cmd = [string]$owner.CommandLine; $ownerPid = [int]$owner.ProcessId }
      }
    }
    elseif ($cmd -and $cmd -match $script:RxServers) { $kind = 'old' }
    elseif ($cmd -and $cmd -match $script:RxPyPages) { $kind = 'old' }
    [void]$out.Add([pscustomobject]@{ Port = [int]$c.LocalPort; Address = [string]$c.LocalAddress; Pid = $ownerPid; Name = $name; Cmd = $cmd; Kind = $kind })
  }
  return $out.ToArray()
}
function Test-IsLoopback([string]$a) { return ($a -eq '127.0.0.1' -or $a -eq '::1' -or $a -eq 'localhost') }

# firewall rules read from the registry (no firewall command is run; the key is readable without administrator rights)
function ConvertFrom-FirewallRuleText([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
  $r = @{ Name = ''; Action = ''; Active = ''; Dir = ''; Protocol = ''; LPort = @(); RA4 = @(); RA6 = @(); App = ''; IfAlias = @() }
  foreach ($tok in ($Text -split '\|')) {
    $ix = $tok.IndexOf('=')
    if ($ix -lt 1) { continue }
    $k = $tok.Substring(0, $ix)
    $v = $tok.Substring($ix + 1)
    switch -Regex ($k) {
      '^Name$' { $r.Name = $v }
      '^Action$' { $r.Action = $v }
      '^Active$' { $r.Active = $v }
      '^Dir$' { $r.Dir = $v }
      '^Protocol$' { $r.Protocol = $v }
      '^App$' { $r.App = $v }
      '^LPort' { $r.LPort += @($v -split ',' | Where-Object { $_ }) }
      '^RA4$' { $r.RA4 += @($v -split ',' | Where-Object { $_ }) }
      '^RA6$' { $r.RA6 += @($v -split ',' | Where-Object { $_ }) }
      '^IFName$' { $r.IfAlias += @($v) }
    }
  }
  return [pscustomobject]$r
}
function Get-FirewallRules {
  $out = New-Object System.Collections.ArrayList
  $key = $null
  try {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules')
    if ($null -ne $key) {
      foreach ($vn in $key.GetValueNames()) {
        $raw = ''
        try { $raw = [string]$key.GetValue($vn) } catch { }
        $rule = ConvertFrom-FirewallRuleText $raw
        if ($rule) { [void]$out.Add($rule) }
      }
    }
  } catch { }
  finally { if ($null -ne $key) { try { $key.Close() } catch { } } }
  return $out.ToArray()
}
function Test-WideRemote($Rule) {
  $ra = @($Rule.RA4 + $Rule.RA6 | ForEach-Object { [string]$_ })
  if ($ra.Count -eq 0) { return $true }
  foreach ($a in $ra) { if ($a -match '^(\*|Any|0\.0\.0\.0/0|0\.0\.0\.0-255\.255\.255\.255|::/0)$') { return $true } }
  return $false
}

function Get-StartupItems {
  # Startup entries that start THIS repository: the name mentions Pillagers or Dark Raiders AND the shortcut points into the repository (or cannot be read).
  # An entry that host-stop.ps1 renamed (it ends in .disabled) is switched off and does not count.
  $out = @()
  if (-not (Test-Path -LiteralPath $script:StartupDir)) { return @() }
  $sh = $null
  try { $sh = New-Object -ComObject WScript.Shell } catch { }
  foreach ($f in (Get-ChildItem -LiteralPath $script:StartupDir -File -Force -ErrorAction SilentlyContinue)) {
    if ($f.Name -notmatch '(?i)pillagers|dark.?raiders') { continue }
    if ($f.Extension -ieq '.disabled') { continue }
    $txt = ''
    if ($sh -and $f.Extension -ieq '.lnk') {
      try { $lnk = $sh.CreateShortcut($f.FullName); $txt = [string]$lnk.TargetPath + ' ' + [string]$lnk.Arguments + ' ' + [string]$lnk.WorkingDirectory } catch { }
    }
    if ((-not $txt.Trim()) -or ($txt -match $script:RepoTaskRx)) { $out += $f }
  }
  return @($out)
}

# ----------------------------------------------------------------------------------------------------------------------
# the marker (read the way the VM reads it, but without needing the VM's location rules)
# ----------------------------------------------------------------------------------------------------------------------
function Get-HostMarker {
  $o = [pscustomobject]@{ Exists = $false; Valid = $false; Status = ''; Computer = ''; Time = ''; Head = ''; Kept = ''; Why = @() }
  $f = Get-MarkerPath
  if (-not (Test-Path -LiteralPath $f)) { return $o }
  $o.Exists = $true
  $lines = @()
  try { $lines = @(Get-Content -LiteralPath $f -ErrorAction Stop) } catch { $o.Why = @('the file cannot be read'); return $o }
  $kv = @{}
  $dupes = @()
  foreach ($l in $lines) {
    if ($l -match '^\s*([A-Za-z][A-Za-z0-9]*)\s*=\s*(.*?)\s*$') {
      $k = $Matches[1].ToLowerInvariant()
      if ($kv.ContainsKey($k)) { if ($dupes -notcontains $k) { $dupes += $k } } else { $kv[$k] = $Matches[2] }
    }
  }
  $why = @()
  if ($dupes.Count -gt 0) { $why += ('these lines appear twice (two runs glued together?): ' + ($dupes -join ', ')) }
  if ($kv.ContainsKey('status')) { $o.Status = $kv['status'].ToLowerInvariant() } else { $o.Status = 'unknown' }
  if ($kv.ContainsKey('computer')) { $o.Computer = $kv['computer'] }
  if ($kv.ContainsKey('time')) { $o.Time = $kv['time'] }
  if ($kv.ContainsKey('githead') -and $kv['githead'] -match '^[0-9a-fA-F]{40}$') { $o.Head = $kv['githead'].ToLowerInvariant() }
  if ($kv.ContainsKey('playserverskept')) { $o.Kept = $kv['playserverskept'].ToLowerInvariant() }
  if ($o.Status -ne 'stopped') { $why += ('the status line says "' + $o.Status + '" (it must say exactly stopped)') }
  if (-not $o.Computer) { $why += 'there is no computer= line' }
  elseif ($o.Computer -ine $env:COMPUTERNAME) { $why += ('the marker was written on ' + $o.Computer + ', not on this PC (' + $env:COMPUTERNAME + ')') }
  if (-not $o.Head) { $why += 'there is no full 40-character gitHead= line' }
  if (-not $kv.ContainsKey('shiplockclear') -or $kv['shiplockclear'].ToLowerInvariant() -ne 'yes') { $why += 'the marker does not say shipLockClear=yes' }
  if (-not $kv.ContainsKey('check')) { $why += 'there is no check= line' }
  elseif ($kv['check'].ToLowerInvariant() -ne (Get-MarkerCheck $lines)) { $why += 'the check= line does not match the other lines (edited by hand, cut short or glued together)' }
  $o.Why = $why
  $o.Valid = ($why.Count -eq 0)
  return $o
}

# ----------------------------------------------------------------------------------------------------------------------
# the checks
# ----------------------------------------------------------------------------------------------------------------------
function Check-Vm {
  Out-Section ('THE VM  (' + $script:VmName + ')')
  $vf = Get-VmFacts $script:VmName
  $gb = Get-GatedBad
  if ($vf.Readable -and $vf.Exists) {
    if ($vf.AutoStart -eq 'Start' -and $vf.AutoDelay -eq 60) {
      Add-Result 'PASS' 'the VM starts by itself when this PC starts' ('Automatic Start Action = Start, delay 60 seconds (' + $vf.MemoryGB + ' GB memory, automatic stop action ' + $vf.StopAction + ')')
    } else {
      Add-Result 'FAIL' 'the VM starts by itself when this PC starts' ('Automatic Start Action = ' + $vf.AutoStart + ', delay ' + $vf.AutoDelay + ' s (wanted: Start, 60 s)') ('In an administrator window run: host-vm-boost.ps1 (it sets it, nothing else is needed), or by hand: Hyper-V Manager > right-click ' + $script:VmName + ' > Settings > Management > Automatic Start Action > "Always start this virtual machine automatically", delay 60 seconds.')
    }
    if ($vf.State -eq 'Running') { Add-Result 'PASS' 'the VM is running' 'state Running' }
    else { Add-Result $gb 'the VM is running' ('state ' + $vf.State) ('Start it: Hyper-V Manager > right-click ' + $script:VmName + ' > Start (or in an administrator window: Start-VM -Name ' + $script:VmName + '). Then wait a few minutes and run vm-verify.ps1 inside it.') }
  } elseif ($vf.Readable -and -not $vf.Exists) {
    Add-Result 'FAIL' 'the VM starts by itself when this PC starts' ('no virtual machine named ' + $script:VmName + ' exists') 'Pass the right name with -VMName, or check Hyper-V Manager.'
  } else {
    $ev = Get-IndirectVmEvidence
    $why = ''
    if ($vf.NoModule) { $why = 'the Hyper-V PowerShell module is not installed here' }
    elseif ($vf.Denied) { $why = 'Hyper-V does not let this window read virtual machines (it needs an administrator window, or the Hyper-V Administrators group)' }
    else { $why = 'Hyper-V could not be read: ' + (Clean-Ascii $vf.Err) }
    $evTxt = 'what a normal window can still see: the Hyper-V service is ' + $ev.Service + ', ' + $ev.Workers + ' virtual machine worker process(es) are running'
    Add-Result 'WAIT' 'the VM starts by itself when this PC starts' ($why + '; ' + $evTxt) ('Run this script again in an ADMINISTRATOR PowerShell window (Step 0A of the guide), or look by hand: Hyper-V Manager > ' + $script:VmName + ' > Settings > Management: Automatic Start Action must be "Always start this virtual machine automatically" with a 60 second delay.')
    $st = 'WAIT'
    $dd = 'cannot be read from this window; ' + $evTxt
    if ($ev.Workers -gt 0) { $dd += ' (a VM is running, but this window cannot tell which one)' }
    Add-Result $st 'the VM is running' $dd 'Run this script again in an administrator window, or look at Hyper-V Manager (the VM must say Running).'
  }
}

function Check-Relay {
  Out-Section 'THE PAD ROUTE (relay from this PC to the game in the VM; only needed for the party night)'
  $keptOn = ($script:Marker -and $script:Marker.Kept -eq 'yes')
  $ls = @(Get-PortListeners -Ports $script:RelayPorts -Snap $script:Snap)
  $found = @(Get-ChildItem -LiteralPath $script:MigRoot -Filter '*relay*' -File -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
  $foundTxt = ''
  if ($found.Count -gt 0) { $foundTxt = ' (relay script(s) in tools\migrate: ' + ($found -join ', ') + ')' }
  foreach ($port in $script:RelayPorts) {
    $name = 'port ' + $port + ' on this PC is served by the relay'
    $mine = @($ls | Where-Object { $_.Port -eq $port })
    if ($mine.Count -eq 0) {
      Add-Result 'WARN' $name ('nothing listens on port ' + $port + ' on this PC; the pad route is not running' + $foundTxt) 'Only needed on the party night. Tell Claude in the VM: "build the pad route"; it gives you the short commands to run here. Not running is fine until then.'
      continue
    }
    $old = @($mine | Where-Object { $_.Kind -eq 'old' })
    if ($old.Count -gt 0) {
      if ($keptOn) { Add-Result 'PASS' $name ('the OLD Pillagers server (pid ' + $old[0].Pid + ') still holds port ' + $port + ' on purpose (the marker says playServersKept=yes); stop it before you start the relay') }
      else { Add-Result 'WARN' $name ('the OLD Pillagers server (' + $old[0].Name + ' pid ' + $old[0].Pid + ') still holds port ' + $port + ', so a relay cannot use it; no request was sent to it') 'Stop it (host-stop.ps1 does, unless you used -KeepPlayServers). If this is the party copy (party-host-copy.ps1 -Start), that is expected on the party night. The "nothing runs here" section below lists it too.' }
      continue
    }
    $hs = @($mine | Where-Object { $_.Kind -eq 'httpsys' })
    if ($hs.Count -gt 0) {
      Add-Result 'WARN' $name ('a program that uses Windows HTTP.sys (Windows lists it as the System process, pid ' + $hs[0].Pid + ') holds port ' + $port + ' on this PC; it is not the relay, and no request was sent to it') 'If it is a Pillagers server you still need, fine. Otherwise stop whatever holds the port before you start the relay.'
      continue
    }
    $isRelay = @($mine | Where-Object { $_.Name -match '(?i)^node(\.exe)?$' -and $_.Cmd -match 'play-relay\.mjs' }).Count -gt 0
    if (-not $isRelay) {
      Add-Result 'WARN' $name ($mine[0].Name + ' pid ' + $mine[0].Pid + ' holds port ' + $port + ' on this PC; it is not recognised as the relay, and no request was sent to it') 'If it is not something you started on purpose, stop it before you start the relay (host-play-relay.ps1 -Status says more).'
      continue
    }
    $wide = @($mine | Where-Object { -not (Test-IsLoopback $_.Address) })
    $who = $mine[0].Name + ' pid ' + $mine[0].Pid
    $probe = $script:RelayProbes[$port]
    $reply = $null
    if (-not $script:NoNet -and $probe) { $reply = Test-HttpEndpoint -Url ('http://127.0.0.1:' + $port + $probe.Path) -Method $probe.Method -Seconds $script:HttpTimeout }
    if ($wide.Count -gt 0) {
      Add-Result 'WARN' $name ($who + ' listens on ' + $wide[0].Address + ':' + $port + ', i.e. beyond this PC; the relay should listen on 127.0.0.1 only') 'Restart the relay bound to 127.0.0.1 only. Anything on your network could reach the game otherwise.'
    } elseif ($script:NoNet) {
      Add-Result 'WAIT' $name ($who + ' listens on 127.0.0.1:' + $port + '; not asked because of -NoNetwork') 'Run again without -NoNetwork.'
    } elseif ($reply -and $reply.Answered) {
      Add-Result 'PASS' $name ($who + ' listens on 127.0.0.1:' + $port + ' only and answers ' + $probe.Method + ' -> HTTP ' + $reply.Status)
    } else {
      Add-Result 'WARN' $name ($who + ' listens on 127.0.0.1:' + $port + ' but does not answer (' + (Clean-Ascii $(if ($reply) { $reply.Error } else { 'no request made' })) + ')') 'The VM may be off, or its address changed since the relay started (it changes after a restart of this PC). Restart the relay; Claude in the VM looks up the current address each time.'
    }
  }
}

function Check-OllamaBridge {
  Out-Section 'THE OLLAMA BRIDGE (the VM uses the AI that runs on this PC)'
  $envVal = (Get-OllamaHostVar).Trim()
  $rules = @(Get-FirewallRules)
  $mine = @($rules | Where-Object { [string]$_.Name -eq $script:OllamaRuleName })
  $sw = Get-SwitchIp
  $ls = @(Get-PortListeners -Ports @($script:OllamaPort) -Snap $script:Snap)
  $installHint = 'In an ADMINISTRATOR window on this PC: host-ollama-bridge.ps1 -Install -DryRun first (it prints exactly what it changes), then host-ollama-bridge.ps1 -Install.'

  if ($envVal -eq ('0.0.0.0:' + $script:OllamaPort)) { Add-Result 'PASS' 'OLLAMA_HOST lets Ollama listen beyond this PC' ('your user variable OLLAMA_HOST is ' + $envVal) }
  elseif (-not $envVal) { Add-Result 'WAIT' 'OLLAMA_HOST lets Ollama listen beyond this PC' 'your user variable OLLAMA_HOST is not set (the bridge is not installed yet)' $installHint }
  else { Add-Result 'FAIL' 'OLLAMA_HOST lets Ollama listen beyond this PC' ('OLLAMA_HOST is "' + (Clean-Ascii $envVal) + '", not 0.0.0.0:' + $script:OllamaPort) ('If you did not set this on purpose: ' + $installHint) }

  if ($mine.Count -eq 0) {
    Add-Result 'WAIT' ('firewall rule "' + $script:OllamaRuleName + '" exists') 'no such rule (read from the registry; no firewall command was run)' $installHint
  } else {
    $r = $mine[0]
    $probs = @()
    if ($mine.Count -gt 1) { $probs += ($mine.Count.ToString() + ' rules with this name') }
    if ([string]$r.Active -ne 'TRUE') { $probs += 'switched off' }
    if ([string]$r.Dir -ne 'In') { $probs += 'not an inbound rule' }
    if ([string]$r.Action -ne 'Allow') { $probs += 'not Allow' }
    if ([string]$r.Protocol -ne '6') { $probs += 'not TCP' }
    if (@($r.LPort) -notcontains [string]$script:OllamaPort -or @($r.LPort).Count -ne 1) { $probs += ('ports: ' + (@($r.LPort) -join ',')) }
    if (Test-WideRemote $r) { $probs += 'lets in every address (it should allow only the Default Switch network)' }
    if ($probs.Count -eq 0) { Add-Result 'PASS' ('firewall rule "' + $script:OllamaRuleName + '" exists') ('inbound TCP ' + $script:OllamaPort + ' only from ' + ((@($r.RA4) + @($r.RA6)) -join ', ')) }
    else { Add-Result 'FAIL' ('firewall rule "' + $script:OllamaRuleName + '" exists') ('the rule exists but: ' + ($probs -join '; ')) 'In an administrator window: host-ollama-bridge.ps1 -Undo, then host-ollama-bridge.ps1 -Install (the Undo removes only this one rule).' }
  }

  # The whole protection is the Windows Firewall: it must really be on and block inbound by default, and no other rule may open or block Ollama.
  $bridgeOn = ($envVal -eq ('0.0.0.0:' + $script:OllamaPort))
  $fwProblems = @()
  $fwRead = $false
  try {
    $profs = @(Get-NetFirewallProfile -PolicyStore ActiveStore -ErrorAction Stop)
    $fwRead = ($profs.Count -gt 0)
    foreach ($pf in $profs) {
      if ([string]$pf.Enabled -ne 'True') { $fwProblems += ('the firewall is off or not set for the ' + $pf.Name + ' profile') }
      if ([string]$pf.DefaultInboundAction -eq 'Allow') { $fwProblems += ('the ' + $pf.Name + ' profile allows inbound connections by default') }
    }
  } catch { }
  if (-not $fwRead) { Add-Result 'WAIT' 'the Windows Firewall is on and blocks inbound by default' 'the firewall state could not be read from this window' 'Look at Windows Security > Firewall & network protection: Domain, Private and Public must all be on. host-ollama-bridge.ps1 -Install checks this itself and refuses if it is not.' }
  elseif ($fwProblems.Count -gt 0) { Add-Result $(if ($bridgeOn) { 'FAIL' } else { 'WARN' }) 'the Windows Firewall is on and blocks inbound by default' (($fwProblems -join '; ') + '. Ollama listens on every card once the bridge is on, so the firewall is what keeps your network out.') 'Switch the firewall back on in Windows Security (this script never changes it). host-ollama-bridge.ps1 -Install refuses while it is not.' }
  else { Add-Result 'PASS' 'the Windows Firewall is on and blocks inbound by default' 'Domain, Private and Public are on and block inbound by default' }
  $otherRules = @($rules | Where-Object { [string]$_.Name -ne $script:OllamaRuleName -and [string]$_.Active -eq 'TRUE' -and [string]$_.Dir -eq 'In' -and ((([string]$_.App) -match '(?i)ollama') -or (@($_.LPort) -contains [string]$script:OllamaPort)) })
  $otherBlocks = @($otherRules | Where-Object { [string]$_.Action -eq 'Block' })
  $otherWide = @($otherRules | Where-Object { [string]$_.Action -eq 'Allow' -and (Test-WideRemote $_) })
  if ($otherBlocks.Count -gt 0) { Add-Result 'FAIL' 'no block rule stops the Ollama bridge' ('block rule(s) for Ollama or port ' + $script:OllamaPort + ': ' + ((@($otherBlocks | ForEach-Object { [string]$_.Name }) | Select-Object -First 3) -join ', ') + '. A block beats the allow rule, so the VM cannot get through.') 'Windows adds one when the "Allow Ollama on networks?" window is closed with Cancel. host-ollama-bridge.ps1 -Status (administrator window) prints the exact command that removes it.' }
  else { Add-Result 'PASS' 'no block rule stops the Ollama bridge' 'no enabled inbound block rule names Ollama or port 11434' }
  if ($otherWide.Count -gt 0) { Add-Result 'FAIL' 'no other rule opens Ollama to the whole network' ('allow rule(s) that let other computers in: ' + ((@($otherWide | ForEach-Object { [string]$_.Name }) | Select-Object -First 3) -join ', ')) 'Remove it if you did not make it on purpose. host-ollama-bridge.ps1 -Status (administrator window) prints the exact command.' }
  else { Add-Result 'PASS' 'no other rule opens Ollama to the whole network' 'no other enabled inbound allow rule for Ollama or port 11434 lets in every address' }

  $beyond = @($ls | Where-Object { -not (Test-IsLoopback $_.Address) })
  $loop = @($ls | Where-Object { Test-IsLoopback $_.Address })
  if ($ls.Count -eq 0) {
    Add-Result $(if ($envVal -and $mine.Count -gt 0) { 'FAIL' } else { 'WAIT' }) 'Ollama is listening' ('nothing listens on port ' + $script:OllamaPort + ' on this PC (Ollama is not running)') 'Start Ollama from the Start menu (as yourself, not as administrator). The audits in the VM wait for it.'
  } elseif ($beyond.Count -eq 0 -and $loop.Count -gt 0) {
    Add-Result $(if ($envVal -eq ('0.0.0.0:' + $script:OllamaPort)) { 'FAIL' } else { 'WAIT' }) 'Ollama is listening beyond 127.0.0.1' ('Ollama (' + $ls[0].Name + ' pid ' + $ls[0].Pid + ') listens on ' + $loop[0].Address + ' only, so the VM cannot reach it') 'Quit Ollama from the tray icon and start it again from the Start menu as yourself, so it picks up OLLAMA_HOST (host-ollama-bridge.ps1 -Install does this for you).'
  } else {
    Add-Result 'PASS' 'Ollama is listening beyond 127.0.0.1' ('Ollama (' + $ls[0].Name + ' pid ' + $ls[0].Pid + ') listens on ' + $beyond[0].Address + ':' + $script:OllamaPort)
  }

  $url = 'http://' + $sw.Ip + ':' + $script:OllamaPort + '/api/tags'
  $swNote = $(if ($sw.Live) { 'this PC address on the Default Switch is ' + $sw.Ip } else { 'the Default Switch address could not be read, so ' + $sw.Ip + ' was assumed' })
  if ($script:NoNet) { Add-Result 'WAIT' 'a request to Ollama at the Default Switch address works' ('not asked because of -NoNetwork (' + $swNote + ')') 'Run again without -NoNetwork.' }
  else {
    $rq = Test-HttpEndpoint -Url $url -Method 'GET' -Seconds $script:HttpTimeout -ReadBody
    if ($rq.Answered -and $rq.Status -eq 200) {
      $n = -1
      try { $n = @(($rq.Body | ConvertFrom-Json).models).Count } catch { }
      Add-Result 'PASS' 'a request to Ollama at the Default Switch address works' ('http://' + $sw.Ip + ':' + $script:OllamaPort + ' answers' + $(if ($n -ge 0) { ', ' + $n + ' model(s) listed' } else { '' }) + '; ' + $swNote + '. In the VM set PILLAGERS_OLLAMA_URL to http://' + $sw.Ip + ':' + $script:OllamaPort)
    } elseif ($rq.Answered) {
      Add-Result 'FAIL' 'a request to Ollama at the Default Switch address works' ('http://' + $sw.Ip + ':' + $script:OllamaPort + ' replied HTTP ' + $rq.Status) 'host-ollama-bridge.ps1 -Status shows the whole picture.'
    } else {
      Add-Result $(if ($envVal -and $mine.Count -gt 0) { 'FAIL' } else { 'WAIT' }) 'a request to Ollama at the Default Switch address works' ('http://' + $sw.Ip + ':' + $script:OllamaPort + ' does not answer (' + (Clean-Ascii $rq.Error) + '); ' + $swNote) 'host-ollama-bridge.ps1 -Status shows the whole picture. The address can change after a restart of this PC.'
    }
  }
}

function Get-RunningPillagers {
  # every process that belongs to Pillagers, from its command line: the known job shapes (named by kind) plus anything whose command line points into the repo
  param([object[]]$Snap)
  $skip = Get-AncestorPids $Snap
  $seen = New-Object 'System.Collections.Generic.HashSet[int]'
  $out = New-Object System.Collections.ArrayList
  $add = {
    param($p, [string]$kind)
    if ($null -eq $p) { return }
    if ($skip.Contains([int]$p.ProcessId)) { return }
    if (-not $seen.Add([int]$p.ProcessId)) { return }
    [void]$out.Add([pscustomobject]@{ Pid = [int]$p.ProcessId; Name = [string]$p.Name; Kind = $kind; Cmd = [string]$p.CommandLine })
  }
  foreach ($p in (Select-Proc $Snap @('bash.exe') $script:RxRunner)) { & $add $p 'runner (nightly.sh)' }
  foreach ($p in (Select-Proc $Snap @('bash.exe') $script:RxLane)) { & $add $p 'helper lane' }
  foreach ($p in (Select-HelperProc $Snap)) { & $add $p 'helper run (Claude, Codex or Gemini on a job)' }
  foreach ($p in (Select-Proc $Snap @('bash.exe', 'powershell.exe', 'pwsh.exe') $script:RxShip)) { & $add $p 'ship or ship test' }
  foreach ($p in (Select-Proc $Snap @('powershell.exe', 'pwsh.exe') $script:RxFuzz)) { & $add $p 'crash-hunting robot (fuzz)' }
  foreach ($p in (Select-Proc $Snap @('bash.exe') $script:RxCorpus)) { & $add $p 'full test run (corpus)' }
  foreach ($p in (Select-Proc $Snap @('powershell.exe', 'pwsh.exe', 'bash.exe') $script:RxReview)) { & $add $p 'review or audit job' }
  foreach ($p in (Select-Proc $Snap @('powershell.exe', 'pwsh.exe', 'cmd.exe') $script:RxServers)) { & $add $p 'Pillagers server script' }
  foreach ($p in (Select-Proc $Snap @('python.exe', 'py.exe') $script:RxPyPages)) { & $add $p 'survey page server' }
  foreach ($p in (Get-DashboardProcs $Snap)) { & $add $p 'Dev Console server (port 8820)' }
  foreach ($p in (Get-TestChromes $Snap)) { & $add $p 'test Chrome' }
  # anything else that points into the repository folder (an editor, a stray script...)
  foreach ($p in $Snap) {
    if (-not $p.CommandLine) { continue }
    # the move kit itself (host-vm-boost.ps1, host-stop.ps1, this script ... open in another window) is not Pillagers work
    if ([string]$p.CommandLine -match 'tools[\\/]migrate[\\/]') { continue }
    if ([string]$p.CommandLine -match $script:RepoRx) { & $add $p 'other process pointing into the Pillagers folder' }
  }
  return $out.ToArray()
}

function Check-NothingRuns {
  Out-Section 'NOTHING OF PILLAGERS RUNS ON THIS PC'
  $snap = $script:Snap
  $keptOn = ($script:Marker -and $script:Marker.Kept -eq 'yes')
  $run = @(Get-RunningPillagers $snap)
  $allowed = @()
  if ($keptOn) { $allowed = @($run | Where-Object { $_.Kind -eq 'Pillagers server script' -and $_.Cmd -match '(?i)serve\.ps1|collector\.ps1' }) }
  $bad = @($run | Where-Object { $allowed -notcontains $_ })
  if ($bad.Count -eq 0) {
    Add-Result 'PASS' 'no Pillagers program runs on this PC' $(if ($allowed.Count -gt 0) { $allowed.Count.ToString() + ' play server process(es) kept on purpose (the marker says playServersKept=yes)' } else { 'no runner, lane, helper run, ship, test, server, dashboard or test Chrome found' })
  } else {
    $kinds = @($bad | ForEach-Object { $_.Kind } | Sort-Object -Unique)
    Add-Result 'FAIL' 'no Pillagers program runs on this PC' ($bad.Count.ToString() + ' process(es): ' + ($kinds -join '; ')) 'Close the Pillagers Claude Code window first (S1 of the guide), then run host-stop.ps1 again. It stops the lot and tells you what it could not. The list below says exactly which.'
    foreach ($b in @($bad | Select-Object -First 14)) {
      $c = Clean-Ascii (Protect-Text $b.Cmd)
      if ($c.Length -gt 120) { $c = $c.Substring(0, 120) + '...' }
      Out-Line ('            pid ' + $b.Pid + ' ' + $b.Name + ' [' + $b.Kind + '] ' + $c) 'Red'
    }
    if ($bad.Count -gt 14) { Out-Line ('            ... and ' + ($bad.Count - 14) + ' more') 'Red' }
  }

  $tasks = @()
  try { $tasks = @(Get-PillagersTasks) } catch { }
  $on = @($tasks | Where-Object { [string]$_.State -ne 'Disabled' })
  if ($on.Count -eq 0) { Add-Result 'PASS' 'the Pillagers scheduled tasks are switched off' $(if ($tasks.Count -gt 0) { $tasks.Count.ToString() + ' task(s) found, all disabled' } else { 'no Pillagers task exists on this PC' }) }
  else { Add-Result 'FAIL' 'the Pillagers scheduled tasks are switched off' ('still on: ' + (($on | ForEach-Object { '"' + $_.TaskName + '" (' + $_.State + ')' }) -join ', ')) 'Run host-stop.ps1 again (it disables them), or: Disable-ScheduledTask -TaskName "<name>" in an administrator window. A task that is on can start the runner at any 15-minute tick.' }

  $su = @(Get-StartupItems)
  if ($su.Count -eq 0) { Add-Result 'PASS' 'no Pillagers startup shortcut is active' 'the Startup folder has none that starts this repository' }
  else { Add-Result 'FAIL' 'no Pillagers startup shortcut is active' ('active: ' + (($su | ForEach-Object { $_.Name }) -join ', ')) 'Run host-stop.ps1 again (it renames them so Windows ignores them), or delete them from the Startup folder.' }

  $lk = Get-ShipLock
  if (-not $lk.Exists) { Add-Result 'PASS' 'no ship lock is held' 'the ship lock file is not there' }
  else { Add-Result 'FAIL' 'no ship lock is held' ('a ship lock exists (owner "' + (Clean-Ascii ([string]$lk.Owner)) + '", ' + $lk.AgeMin + ' minute(s) old)') 'A ship may be running, or the lock is left over from a dead session. Run host-stop.ps1 (it waits for or clears it).' }
}

function Check-Marker {
  Out-Section 'THE HOST-STOPPED MARKER'
  $m = $script:Marker
  $path = Get-MarkerPath
  if (-not $m.Exists) {
    Add-Result 'WAIT' 'host-stopped.txt exists and is valid' ('there is no ' + $path) 'Normal until switch-over day. host-stop.ps1 (S2 of the guide) writes it; host-push-files.ps1 -Final sends a copy to the VM.'
    return
  }
  if ($m.Valid) {
    $now = ''
    $h = @(Invoke-GitRaw @('rev-parse', 'HEAD'))
    if ($h.Count -gt 0) { $now = ([string]$h[0]).Trim().ToLowerInvariant() }
    $d = 'status stopped, written on ' + $m.Computer + $(if ($m.Time) { ' at ' + $m.Time } else { '' }) + ', repo commit ' + $m.Head.Substring(0, 12) + ', check line matches' + $(if ($m.Kept) { ', playServersKept=' + $m.Kept } else { '' })
    Add-Result 'PASS' 'host-stopped.txt exists and is valid' $d
    if ($now -and $now -ne $m.Head) { Add-Result 'WARN' 'this PC repo is still at the commit of the stop' ('the repo here is at ' + $now.Substring(0, 12) + ' but the marker says ' + $m.Head.Substring(0, 12)) 'Fine if you pulled the VM work on purpose (the party fallback). If not, something shipped on this PC after the stop: two machines must never ship at once; run host-stop.ps1 again.' }
    else { Add-Result 'PASS' 'this PC repo is still at the commit of the stop' ('HEAD ' + $(if ($now) { $now.Substring(0, 12) } else { '(unreadable)' }) + ', unchanged since the stop') }
  } elseif ($m.Status -eq 'revoked') {
    Add-Result 'FAIL' 'host-stopped.txt exists and is valid' 'the marker says "revoked": Pillagers was switched back on on this PC (host-stop.ps1 -Undo)' 'If you really are working in the VM: run host-stop.ps1 again, then host-push-files.ps1 -Final. Never let both machines work.'
  } else {
    Add-Result 'FAIL' 'host-stopped.txt exists and is valid' ('the marker is not accepted: ' + ((@($m.Why) | Select-Object -First 3) -join '; ')) 'Run host-stop.ps1 again (never edit the file by hand), then host-push-files.ps1 -Final.'
  }
}

# ----------------------------------------------------------------------------------------------------------------------
function Get-Plan {
  return @(
    'THE VM: Automatic Start Action is Start with a 60 second delay; the VM is Running (if a normal window may not read Hyper-V, it says so and shows the indirect evidence)',
    'THE PAD ROUTE: who listens on 127.0.0.1 ports 8802 and 8799, that it is not the old server, loopback only, and (only if it is the relay) that it answers (WARN while not built; nothing is ever sent to any other listener)',
    'THE OLLAMA BRIDGE: OLLAMA_HOST, the firewall rule "Pillagers Ollama for VM" (registry), the Windows Firewall on for all three profiles and blocking inbound by default, no block rule or wide allow rule for Ollama, Ollama listening beyond 127.0.0.1, a request at the Default Switch address',
    'NOTHING RUNS HERE: no Pillagers process (command lines into C:\claudecode\dark raiders), tasks off, no startup shortcut, no ship lock',
    'THE MARKER: tools\migrate\host-stopped.txt exists, stopped, this computer, check line matches; the repo is still at its commit'
  )
}

function Show-Summary {
  $c = @{ PASS = 0; FAIL = 0; WAIT = 0; WARN = 0 }
  foreach ($r in $script:Results) { $c[$r.State]++ }
  Out-Blank
  Out-Line '======================================================================' 'Cyan'
  Out-Line ('SUMMARY: ' + $c.PASS + ' PASS, ' + $c.FAIL + ' FAIL, ' + $c.WAIT + ' WAIT, ' + $c.WARN + ' WARN   (' + $script:Results.Count + ' items)') 'White'
  $todo = @($script:Results | Where-Object { $_.State -eq 'FAIL' }) + @($script:Results | Where-Object { $_.State -eq 'WAIT' })
  if ($todo.Count -gt 0) {
    Out-Blank
    Out-Line 'STILL TO DO (FAIL first, then WAIT):' 'White'
    foreach ($r in $todo) { Out-Line ('   [' + $r.State + '] ' + $r.N.ToString().PadLeft(2) + '  ' + $r.Name) 'Gray' }
  }
  Out-Blank
  if ($c.FAIL -gt 0) { Out-Line ('VERDICT: NOT READY. ' + $c.FAIL + ' item(s) FAIL. Fix them with the "fix:" lines above, then run this again.') 'Red' }
  elseif ($c.WAIT -gt 0) { Out-Line ('VERDICT: NOTHING IS WRONG, BUT ' + $c.WAIT + ' ITEM(S) ARE STILL WAITING (not done yet, or cannot be read from this window). Run it again in an administrator window if the VM could not be read.') 'Yellow' }
  else { Out-Line 'VERDICT: ALL CLEAR. This PC is ready to be only your work PC.' 'Green' }
  if ($c.WARN -gt 0) { Out-Line ('(' + $c.WARN + ' WARN item(s) are worth a look but are not failures.)') 'DarkYellow' }
  if ($script:MigLog) { Out-Line ('log: ' + $script:MigLog) 'Gray' }
  if ($c.FAIL -gt 0) { return 1 }
  if ($c.WAIT -gt 0) { return 2 }
  return 0
}

function Invoke-Check([string]$Label, [scriptblock]$Body) {
  try { & $Body }
  catch { Add-Result 'FAIL' ($Label + ' (the check itself crashed)') (Clean-Ascii $_.Exception.Message) 'Run it again; if it repeats tell Claude.' }
}

function Invoke-Main {
  Start-MigLog -Name 'host-verify'
  Out-Line ('=== ' + $script:ScriptVersion + '   ' + (Get-Date).ToString('s') + '   computer ' + $env:COMPUTERNAME + '   user ' + $env:USERNAME + '   window ' + $(if (Test-IsAdmin) { 'administrator' } else { 'normal' }) + $(if ($script:DryRun) { '   DRY RUN: nothing is tested' } else { '' })) 'White'
  Out-Line 'Read-only checklist for the MAIN PC. It stops nothing and changes nothing. PASS = right, FAIL = fix it, WAIT = not done yet or cannot be read from here, WARN = worth a look.' 'Gray'
  if ($script:DryRun) {
    Out-Blank
    Out-Line 'DRY RUN: these are the checks a real run makes (nothing was tested, nothing was probed):' 'Magenta'
    foreach ($p in (Get-Plan)) { Out-Line ('   ' + $p) 'Magenta' }
    return 0
  }
  if ($env:COMPUTERNAME -ine 'JUL26') { Out-Line ('Note: this PC is called ' + $env:COMPUTERNAME + ', not JUL26. This checklist is meant for the main PC; vm-verify.ps1 is the one for the VM.') 'Yellow' }
  try { $script:Marker = Get-HostMarker } catch { $script:Marker = [pscustomobject]@{ Exists = $false; Valid = $false; Status = ''; Computer = ''; Time = ''; Head = ''; Kept = ''; Why = @('could not read the marker') } }
  $script:Stopped = [bool]$script:Marker.Valid
  try { $script:Snap = @(Get-ProcSnap) } catch { $script:Snap = @() }
  Out-Line ('switch-over done on this PC (valid host-stopped.txt): ' + $(if ($script:Stopped) { 'yes' } else { 'no' })) 'Gray'
  Invoke-Check 'the VM' { Check-Vm }
  Invoke-Check 'the pad route' { Check-Relay }
  Invoke-Check 'the Ollama bridge' { Check-OllamaBridge }
  Invoke-Check 'nothing runs here' { Check-NothingRuns }
  Invoke-Check 'the marker' { Check-Marker }
  return (Show-Summary)
}

if ($MyInvocation.InvocationName -ne '.') {
  $script:ExitCode = Invoke-Main
  exit $script:ExitCode
}
