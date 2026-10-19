# vm-pad-route-firewall.ps1 : run INSIDE THE VM, in an ADMINISTRATOR PowerShell (guide step 0C). *** THIS SCRIPT CHANGES THE VM'S FIREWALL. ***
# Claude never runs it. You read what it prints, and you decide.
#
# WHAT IT DOES, in one sentence: it adds ONE inbound Windows Firewall rule named "Pillagers pad route" that lets ONLY the main PC (its address on
# the Hyper-V Default Switch, normally 192.168.160.1) open TCP ports 8802 (the game) and 8799 (run reports) in this VM. Nothing else is changed.
# Why it is needed: the pad route plays the game in Chrome on the main PC (where the Xbox pads are) while the game server runs in this VM. The
# main PC's relay (play-relay.mjs) connects to those two ports. Windows Firewall blocks inbound connections to the VM by default.
# Why that is safe: the rule is TCP only, those two ports only, the main PC's address only (other machines, other VMs and the internet stay
# blocked), nothing is opened to "Any". The VM is behind the Default Switch's NAT. The undo is one command (below).
#
# The exact commands it runs (shown again before it asks, so you can read them):
#   New-NetFirewallRule -DisplayName 'Pillagers pad route' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8802,8799 -RemoteAddress 192.168.160.1 -Profile Any
# and to take it away again:
#   Remove-NetFirewallRule -DisplayName 'Pillagers pad route'
#
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1 -DryRun    look first: prints everything, changes nothing
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1            asks you to type YES, then adds (or updates) the rule
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1 -Undo      removes the rule again
#   -Status        only show whether the rule is there and what it says (changes nothing)
#   -Ports LIST    default 8802,8799. Whole numbers 1024-65535, at most 8.
#   -HostAddress A the main PC's address. Default: the VM's default gateway (on the Default Switch that IS the main PC), or 192.168.160.1 when
#                  the VM has none. Must be a private address. If the main PC's Default Switch address ever changes (after a reboot), run this again.
#   -Yes           do not ask (still prints everything)
# (the script may sit in C:\claudecode\dark raiders\tools\migrate\ as well; it does not matter where it is run from)
# Log: C:\PillagersMove\kit\logs\vm-pad-route-firewall-<time>.log   Exit codes: 0 done / nothing to do, 1 error, 2 refused or cancelled, 3 needs an administrator window.
# ASCII only. Windows PowerShell 5.1.
param(
  [switch]$DryRun,
  [switch]$Undo,
  [switch]$Status,
  [string]$Ports = '8802,8799',
  [string]$HostAddress = '',
  [switch]$Yes
)
$ErrorActionPreference = 'Stop'
$RuleName = 'Pillagers pad route'
$RuleDesc = 'Lets the main PC reach the Pillagers game and run-report ports in this VM (pad route).'
$LogDir   = 'C:\PillagersMove\kit\logs'
$script:Log = ''

function Start-Log {
  try {
    if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
    $script:Log = Join-Path $LogDir ('vm-pad-route-firewall-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    Set-Content -LiteralPath $script:Log -Value ('# vm-pad-route-firewall started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME) -Encoding ASCII
  } catch { $script:Log = '' }
}
function Say([string]$Text, [string]$Color) {
  if ($Color) { Write-Host $Text -ForegroundColor $Color } else { Write-Host $Text }
  if ($script:Log) { try { Add-Content -LiteralPath $script:Log -Value ((Get-Date -Format 'HH:mm:ss') + ' ' + $Text) -Encoding ASCII } catch { } }
}
function Ok([string]$t)   { Say ('OK    ' + $t) 'Green' }
function Info([string]$t) { Say ('      ' + $t) '' }
function Warn([string]$t) { Say ('WARN  ' + $t) 'Yellow' }
function Bad([string]$t)  { Say ('FAIL  ' + $t) 'Red' }
function Dry([string]$t)  { Say ('DRY   would ' + $t) 'Magenta' }
function Show-LogPath { if ($script:Log) { Say ('      log file: ' + $script:Log) 'DarkGray' } }

function Test-IsAdmin {
  try {
    $p = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

function Test-PrivateIPv4([string]$Text) {
  if ($Text -notmatch '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') { return $false }
  $a = [int]$Matches[1]; $b = [int]$Matches[2]; $c = [int]$Matches[3]; $d = [int]$Matches[4]
  if ($a -gt 255 -or $b -gt 255 -or $c -gt 255 -or $d -gt 255 -or $a -eq 0) { return $false }
  if ($a -eq 10) { return $true }
  if ($a -eq 172 -and $b -ge 16 -and $b -le 31) { return $true }
  if ($a -eq 192 -and $b -eq 168) { return $true }
  return $false
}

function ConvertTo-PortList([string]$Text) {
  # returns an int[] or $null when the text is not a clean list of ports 1024-65535 (at most 8, no repeats)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
  $out = @()
  foreach ($part in ($Text -split ',')) {
    $p = $part.Trim()
    if ($p -notmatch '^\d{1,5}$') { return $null }
    $n = [int]$p
    if ($n -lt 1024 -or $n -gt 65535) { return $null }
    if ($out -contains $n) { return $null }
    $out += $n
  }
  if ($out.Count -lt 1 -or $out.Count -gt 8) { return $null }
  return , @($out)
}

function Get-VmGateway {
  # On the Default Switch the VM's default gateway is the main PC. Returns '' when the VM has none.
  try {
    $r = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop |
      Where-Object { $_.NextHop -and $_.NextHop -ne '0.0.0.0' } |
      Sort-Object { [int]$_.RouteMetric + [int]$_.InterfaceMetric } | Select-Object -First 1
    if ($r) { return [string]$r.NextHop }
  } catch { }
  return ''
}

function Get-RuleFacts {
  # what the rule(s) named 'Pillagers pad route' say right now
  $out = @()
  $rules = @(Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)
  foreach ($r in $rules) {
    $pf = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $r -ErrorAction SilentlyContinue
    $af = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $r -ErrorAction SilentlyContinue
    $remote = ((@($af.RemoteAddress) -join ',') -replace '/(32|255\.255\.255\.255)$', '')
    $out += [pscustomobject]@{
      Name = [string]$r.Name; Enabled = [string]$r.Enabled; Direction = [string]$r.Direction; Action = [string]$r.Action; Profile = [string]$r.Profile
      Protocol = [string]$pf.Protocol; LocalPort = (@($pf.LocalPort) -join ','); RemoteAddress = $remote
    }
  }
  return @($out)
}

function Show-Facts($facts) {
  foreach ($f in $facts) {
    Info ('rule "' + $RuleName + '": ' + $f.Direction + ' ' + $f.Action + ', enabled=' + $f.Enabled + ', protocol ' + $f.Protocol + ', local ports ' + $f.LocalPort + ', only from ' + $f.RemoteAddress + ', profiles ' + $f.Profile)
  }
}

Start-Log
Say ''
Say '=== PILLAGERS PAD ROUTE: VM FIREWALL RULE ===' 'Cyan'
if ($Status) { Say '(status only: nothing is changed)' 'DarkGray' }
elseif ($DryRun) { Say '(dry run: nothing is changed)' 'Magenta' }
elseif ($Undo) { Say 'This removes the rule again.' 'Yellow' }
else { Say '*** THIS CHANGES THE VM''S FIREWALL (one inbound allow rule). Read what follows. ***' 'Yellow' }

$portList = ConvertTo-PortList $Ports
if (-not $portList) { Bad ('-Ports "' + $Ports + '" is not valid. Use for example 8802,8799 (whole numbers 1024-65535, at most 8, no repeats).'); exit 2 }
$portsText = ($portList -join ',')

# the main PC's address as the VM sees it
$hostAddr = $HostAddress.Trim()
$hostNote = 'given with -HostAddress'
if (-not $hostAddr) {
  $gw = Get-VmGateway
  if ($gw -and (Test-PrivateIPv4 $gw)) { $hostAddr = $gw; $hostNote = 'the VM''s default gateway = the main PC on the Default Switch' }
  else {
    $hostAddr = '192.168.160.1'
    $hostNote = 'the usual Default Switch address of the main PC (the VM has no usable default gateway to ask)'
    if ($gw) { Warn ('The default gateway (' + $gw + ') is not a private address, so it is not used.') }
  }
}
if (-not (Test-PrivateIPv4 $hostAddr)) { Bad ('The main PC address "' + $hostAddr + '" is not a private IPv4 address (10.x, 172.16-31.x, 192.168.x). Refusing.'); exit 2 }

$facts = @()
try { $facts = @(Get-RuleFacts) } catch { Warn ('Could not read the firewall rules: ' + $_.Exception.Message) }

if ($Status) {
  if ($facts.Count -eq 0) { Info ('The rule "' + $RuleName + '" does not exist (nothing from the main PC can reach the VM''s game ports).') }
  else { Show-Facts $facts }
  Info ('The main PC would be: ' + $hostAddr + ' (' + $hostNote + ')')
  if ($facts.Count -gt 0 -and $facts[0].RemoteAddress -ne $hostAddr) { Warn ('The rule allows ' + $facts[0].RemoteAddress + ' but the main PC is now ' + $hostAddr + '. Run this script again (administrator) to update the rule.') }
  Say ''
  Show-LogPath
  exit 0
}

# ---- the undo
if ($Undo) {
  Say 'Going to REMOVE the rule:' 'Cyan'
  Info ('Remove-NetFirewallRule -DisplayName ''' + $RuleName + '''')
  if ($facts.Count -eq 0) { Ok ('There is no rule named "' + $RuleName + '". Nothing to undo.'); Show-LogPath; exit 0 }
  Show-Facts $facts
  if ($DryRun) { Dry ('remove ' + $facts.Count + ' rule(s)'); Show-LogPath; exit 0 }
  if (-not (Test-IsAdmin)) { Bad 'This needs an administrator window (guide step 0C). Close this window, open "Windows PowerShell" with Run as administrator, run the same line again.'; exit 3 }
  try {
    Remove-NetFirewallRule -DisplayName $RuleName -ErrorAction Stop
    Ok 'The rule is removed. The main PC can no longer reach the VM''s game ports (the pad route will show "the vm is not answering").'
  } catch { Bad ('Could not remove the rule: ' + $_.Exception.Message); exit 1 }
  Show-LogPath
  exit 0
}

# ---- add or update
Say 'What will be set up:' 'Cyan'
Info ('rule name      : ' + $RuleName)
Info ('direction      : inbound, allow, TCP')
Info ('VM ports       : ' + $portsText + '   (8802 = the game, 8799 = run reports)')
Info ('allowed sender : ' + $hostAddr + ' ONLY  (' + $hostNote + ')')
Info ('profiles       : Any (the Default Switch network can be labelled Public or Private)')
Say 'The command:' 'Cyan'
Info ('New-NetFirewallRule -DisplayName ''' + $RuleName + ''' -Description ''' + $RuleDesc + ''' -Direction Inbound -Action Allow -Protocol TCP -LocalPort ' + $portsText + ' -RemoteAddress ' + $hostAddr + ' -Profile Any')
Say 'To undo it later:' 'Cyan'
Info ('Remove-NetFirewallRule -DisplayName ''' + $RuleName + '''     (or run this script again with -Undo)')

$same = $false
if ($facts.Count -eq 1) {
  $f = $facts[0]
  $havePorts = (@($f.LocalPort -split ',' | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ } | Sort-Object) -join ',')
  $wantPorts = (@($portList | Sort-Object) -join ',')
  if ($f.Enabled -eq 'True' -and $f.Direction -eq 'Inbound' -and $f.Action -eq 'Allow' -and $f.Protocol -eq 'TCP' -and $havePorts -eq $wantPorts -and $f.RemoteAddress -eq $hostAddr) { $same = $true }
}
if ($facts.Count -gt 0) { Say 'The rule exists already:' 'Cyan'; Show-Facts $facts }
if ($same) { Ok 'It is already exactly as described. Nothing to do.'; Show-LogPath; exit 0 }
if ($facts.Count -gt 0) { Info 'It differs from the description above, so it will be replaced (the old one is removed first).' }

if ($DryRun) {
  if ($facts.Count -gt 0) { Dry ('remove the old rule(s) named "' + $RuleName + '"') }
  Dry 'add the rule above'
  Say ''
  Show-LogPath
  exit 0
}
if (-not (Test-IsAdmin)) { Bad 'This needs an administrator window (guide step 0C). Close this window, open "Windows PowerShell" with Run as administrator, run the same line again.'; exit 3 }
if (-not $Yes) {
  $a = Read-Host 'Type YES (in capitals) to make this firewall change, anything else cancels'
  if ($a -cne 'YES') { Say 'Cancelled. Nothing was changed.' ''; exit 2 }
}
try {
  if ($facts.Count -gt 0) { Remove-NetFirewallRule -DisplayName $RuleName -ErrorAction Stop; Info 'old rule removed' }
  [void](New-NetFirewallRule -DisplayName $RuleName -Description $RuleDesc -Direction Inbound -Action Allow -Protocol TCP -LocalPort $portList -RemoteAddress $hostAddr -Profile Any -ErrorAction Stop)
} catch { Bad ('Could not add the rule: ' + $_.Exception.Message); exit 1 }

# read it back
$after = @()
try { $after = @(Get-RuleFacts) } catch { }
if ($after.Count -eq 1) { Ok 'The rule is in place. Read back from Windows:'; Show-Facts $after }
else { Warn ('Windows reports ' + $after.Count + ' rules named "' + $RuleName + '" (expected 1). Run with -Status to look.') }
Say ''
Info 'Next: on the main PC run  host-play-relay.ps1 -Status  (it should say the VM''s ports answer).'
Info 'To take the rule away again: run this script with -Undo.'
Show-LogPath
exit 0
