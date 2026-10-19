# vm-address-report.ps1 : run INSIDE THE VM (a normal PowerShell window, no administrator needed). It says where this VM is on the network, writes
# that to C:\PillagersMove\kit\vm-address.txt, and checks the things the pad route depends on. Safe to run any number of times.
#
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-address-report.ps1
#   -Quiet     print one line only (for running at logon)
#   -DryRun    print everything, write nothing (no file, no log)
#   -OutFile P / -LogDir P   other places to write (default C:\PillagersMove\kit\vm-address.txt and C:\PillagersMove\kit\logs)
#
# HOW THE MAIN PC FINDS THE VM: the main PC looks the VM up by NAME, <computer name>.mshome.net. This works because the Hyper-V Default Switch
# runs a small name server that every VM registers with. It was checked on the main PC on 10/19: the name VM_Oct2026.mshome.net (this VM's
# name) resolved to the VM's address from a normal PowerShell and from Node (which is what the relay uses). The address changes now and then
# (the Default Switch hands it out by DHCP and can change it after a main-PC reboot); the name does not. So normally NOTHING has to be told to
# the main PC, and this script is only there to prove the name works and to give you the address for the rare case it does not.
# The main PC cannot read files inside the VM, so vm-address.txt is a note for you and for the VM's Claude, not something the main PC reads.
# If the main PC ever says it cannot find the VM, copy the one line this script prints under "ONLY IF THE MAIN PC CANNOT FIND THIS VM" and run it
# on the main PC.
#
# It never reads or prints a key or password. Exit codes: 0 done, 1 could not work out the VM address.
# ASCII only. Windows PowerShell 5.1.
param(
  [string]$OutFile = 'C:\PillagersMove\kit\vm-address.txt',
  [string]$LogDir = 'C:\PillagersMove\kit\logs',
  [switch]$DryRun,
  [switch]$Quiet
)
$ErrorActionPreference = 'Continue'
$HostScript = 'C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1'
$RuleName = 'Pillagers pad route'
$script:Log = ''

function Start-Log {
  if ($DryRun) { return }
  try {
    if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
    $script:Log = Join-Path $LogDir ('vm-address-report-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    Set-Content -LiteralPath $script:Log -Value ('# vm-address-report started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME) -Encoding ASCII
  } catch { $script:Log = '' }
}
function Say([string]$Text, [string]$Color) {
  if (-not $Quiet) { if ($Color) { Write-Host $Text -ForegroundColor $Color } else { Write-Host $Text } }
  if ($script:Log) { try { Add-Content -LiteralPath $script:Log -Value ((Get-Date -Format 'HH:mm:ss') + ' ' + $Text) -Encoding ASCII } catch { } }
}

function Test-UsableIPv4([string]$Ip) {
  if ($Ip -notmatch '^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$') { return $false }
  if ($Ip.StartsWith('127.') -or $Ip.StartsWith('169.254.') -or $Ip -eq '0.0.0.0') { return $false }
  return $true
}

function Get-VmNetwork {
  # the IPv4 address that has a default gateway (the Default Switch adapter); on the Default Switch the gateway is the main PC
  $r = [ordered]@{ Ip = ''; Adapter = ''; Gateway = ''; Source = '' }
  try {
    $cfgs = @(Get-NetIPConfiguration -ErrorAction Stop | Where-Object { $_.IPv4Address -and (Test-UsableIPv4 ([string]$_.IPv4Address[0].IPAddress)) })
    $best = $null
    foreach ($c in $cfgs) { if ($c.IPv4DefaultGateway -and ([string]$c.IPv4DefaultGateway.NextHop -match '^192\.168\.(16\d|17[0-5])\.')) { $best = $c; break } }
    if (-not $best) { $best = $cfgs | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1 }
    if (-not $best) { $best = $cfgs | Select-Object -First 1 }
    if ($best) {
      $r.Ip = [string]$best.IPv4Address[0].IPAddress
      $r.Adapter = [string]$best.InterfaceAlias
      if ($best.IPv4DefaultGateway) { $r.Gateway = [string]$best.IPv4DefaultGateway.NextHop }
      $r.Source = 'Get-NetIPConfiguration'
    }
  } catch { }
  if (-not $r.Ip) {
    try {
      $w = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true' -ErrorAction Stop |
        Where-Object { $_.IPAddress -and (Test-UsableIPv4 ([string]$_.IPAddress[0])) } | Select-Object -First 1
      if ($w) {
        $r.Ip = [string]$w.IPAddress[0]
        $r.Adapter = [string]$w.Description
        if ($w.DefaultIPGateway) { $r.Gateway = [string]$w.DefaultIPGateway[0] }
        $r.Source = 'WMI'
      }
    } catch { }
  }
  return $r
}

function Test-TcpOpen([string]$Addr, [int]$Port) {
  $c = New-Object System.Net.Sockets.TcpClient
  try {
    $iar = $c.BeginConnect($Addr, $Port, $null, $null)
    return [bool]($iar.AsyncWaitHandle.WaitOne(800) -and $c.Connected)
  } catch { return $false } finally { try { $c.Close() } catch { } }
}

Start-Log
$name = $env:COMPUTERNAME
$net = Get-VmNetwork
if (-not $net.Ip) {
  Say 'PROBLEM: this VM has no usable IPv4 address (no network, or the Default Switch has not given it one yet).' 'Red'
  Say '  Check that the VM is connected to the "Default Switch" (Hyper-V Manager > Settings > Network Adapter), wait a minute, run this again.' ''
  if ($Quiet) { Write-Host 'vm-address: NO ADDRESS' }
  exit 1
}
$fqdn = $name + '.mshome.net'

Say ''
Say '=== VM ADDRESS REPORT ===' 'Cyan'
Say ('computer name : ' + $name) ''
Say ('address       : ' + $net.Ip + '   (adapter "' + $net.Adapter + '")') ''
if ($net.Gateway) { Say ('main PC (as seen from here): ' + $net.Gateway + '   (this VM''s default gateway)') '' }
else { Say 'main PC (as seen from here): unknown (this VM has no default gateway)' 'Yellow' }
Say ('name the main PC uses : ' + $fqdn) ''

# does the Default Switch name server know this VM by that name? (the main PC asks the same name server)
$nameOk = $false
$resolved = ''
try {
  $rr = @(Resolve-DnsName -Name $fqdn -Type A -DnsOnly -ErrorAction Stop | Where-Object { $_.Type -eq 'A' })
  if ($rr.Count -gt 0) { $resolved = [string]$rr[0].IPAddress; $nameOk = ($resolved -eq $net.Ip) }
} catch { }
if (-not $resolved) {
  # the same kind of look-up Node uses (getaddrinfo), in case the DNS-only look-up above found nothing
  try {
    $ga = @([System.Net.Dns]::GetHostAddresses($fqdn) | Where-Object { $_.AddressFamily -eq 'InterNetwork' })
    if ($ga.Count -gt 0) { $resolved = $ga[0].ToString(); $nameOk = ($resolved -eq $net.Ip) }
  } catch { }
}
if ($nameOk) { Say ('name check   : OK  ' + $fqdn + ' -> ' + $resolved + '  (matches). The main PC finds this VM by name; nothing has to be told to it.') 'Green' }
elseif ($resolved) { Say ('name check   : the name gives ' + $resolved + ' but this VM''s address is ' + $net.Ip + '. A moment after a change that is normal; run this again in a minute.') 'Yellow' }
else { Say ('name check   : the name ' + $fqdn + ' did not resolve from inside the VM. The main PC may not find this VM by name. Use the line under "ONLY IF" below.') 'Yellow' }
if ($name -ne 'VM_Oct2026') {
  Say ('NOTE: the relay on the main PC expects the computer name VM_Oct2026 by default. This VM is called ' + $name + ', so give the main PC the line under "ONLY IF" below (it stores the right name or address).') 'Yellow'
}

# things the pad route needs here
Say 'The pad route needs, in this VM:' 'Cyan'
foreach ($p in @(8802, 8799)) {
  if (Test-TcpOpen '127.0.0.1' $p) { Say ('  port ' + $p + ' : a server answers here') 'Green' }
  else { Say ('  port ' + $p + ' : nothing answers yet (the game servers are not running; the "Pillagers dev services" task or tools\start-servers.ps1 starts them)') 'Yellow' }
}
$ruleSender = ''
try {
  $rule = @(Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue | Where-Object { $_.Enabled -eq 'True' })
  if ($rule.Count -gt 0) {
    $af = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule[0] -ErrorAction SilentlyContinue
    $ruleSender = ((@($af.RemoteAddress) -join ',') -replace '/(32|255\.255\.255\.255)$', '')
  }
} catch { }
if ($ruleSender) {
  if ($net.Gateway -and $ruleSender -ne $net.Gateway) { Say ('  firewall rule "' + $RuleName + '" : there, but it only lets ' + $ruleSender + ' in and the main PC now looks like ' + $net.Gateway + '. Run vm-pad-route-firewall.ps1 again (administrator).') 'Yellow' }
  else { Say ('  firewall rule "' + $RuleName + '" : there (lets only ' + $ruleSender + ' in)') 'Green' }
} else { Say ('  firewall rule "' + $RuleName + '" : not there (or not readable without administrator). The main PC cannot reach the game until vm-pad-route-firewall.ps1 has been run in an administrator window.') 'Yellow' }

# the file (a note; the main PC cannot read it)
$text = "# written by vm-address-report.ps1 inside the VM on " + (Get-Date -Format 's') + "`r`n" +
  "# The main PC finds this VM by name (mshome below). The relay on the main PC also understands these lines if they are put in its vm-address.txt.`r`n" +
  'computer=' + $name + "`r`n" +
  'ip=' + $net.Ip + "`r`n" +
  'mshome=' + $fqdn + "`r`n" +
  'hostAddress=' + $net.Gateway + "`r`n"
if ($DryRun) { Say ('(dry run) would write ' + $OutFile) 'Magenta' }
else {
  try {
    $dir = Split-Path -Path $OutFile -Parent
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($OutFile, $text, [System.Text.Encoding]::ASCII)
    Say ('written    : ' + $OutFile) ''
  } catch { Say ('Could not write ' + $OutFile + ': ' + $_.Exception.Message) 'Yellow' }
}

$fix = 'powershell -ExecutionPolicy Bypass -File "' + $HostScript + '" -SetVmAddress ' + $net.Ip
Say ''
Say 'ONLY IF THE MAIN PC CANNOT FIND THIS VM (host-play-relay.ps1 -Status there says "the VM address could not be found"):' 'Cyan'
Say '  run this one line in a normal PowerShell on the MAIN PC (in an Enhanced Session you can copy it from here and paste it there):' ''
Say ('  ' + $fix) ''
Say '  It writes the address into the relay''s vm-address.txt on the main PC. A running relay reads it by itself; no restart. If this address changes, run the line again.' ''
if ($script:Log) { Say ('      log file: ' + $script:Log) 'DarkGray' }
if ($Quiet) { Write-Host ('vm-address: ' + $net.Ip + ' (' + $name + '), main PC ' + $(if ($net.Gateway) { $net.Gateway } else { '?' }) + ', name check ' + $(if ($nameOk) { 'ok' } else { 'NOT ok' })) }
exit 0
