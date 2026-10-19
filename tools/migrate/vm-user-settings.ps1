<#
vm-user-settings.ps1  -  run INSIDE the VM, as your normal VM user. NO administrator window is needed (it only changes YOUR user settings).

WHAT IT DOES (four small steps; running it again is safe and changes nothing that is already right)
  1. Sets your user variable PILLAGERS_OLLAMA_URL to http://192.168.160.1:11434 (the main PC's Ollama, the local AI on its graphics card).
     tools\ship-review.ps1 and tools\llm-night.ps1 read that variable; without it they use the Ollama on the same PC, which the VM does not have.
     The address is the main PC on the Hyper-V Default Switch. If the VM is on that switch but the switch network ever changed, the script reads the
     right address from the VM's default gateway and says so. -HostIp 1.2.3.4 forces an address.
  2. Adds the Claude Code folder (C:\Users\<you>\.local\bin) to your user PATH if it is not there, so you can type  claude  in any new window.
  3. Prints the NAMES (never the values) of the helper keys that are still missing, and the command that asks you for each one (tools\ai-keys.ps1).
     Keys do not travel from the main PC; you type them here once.
  4. Asks http://192.168.160.1:11434/api/tags (3 seconds at most) and prints PASS, or "waiting for host-ollama-bridge.ps1" when the main PC has not
     been prepared yet (that script is run on the main PC, in an administrator window: host-ollama-bridge.ps1 -Install).

HOW TO RUN (inside the VM, normal Windows PowerShell 5.1 window)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\PillagersMove\kit\vm-user-settings.ps1" -DryRun     look first: changes nothing
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\PillagersMove\kit\vm-user-settings.ps1"             do it
  (the same file is also in the Pillagers folder: C:\claudecode\dark raiders\tools\migrate\vm-user-settings.ps1)

SWITCHES
  -DryRun        show what WOULD change, change nothing (the Ollama test in step 4 is only a read, so it still runs)
  -HostIp a.b.c.d  the main PC's address on the Default Switch (default: worked out, normally 192.168.160.1)
  -OllamaUrl url   the whole address, for testing (wins over -HostIp)
  -TimeoutSec n    how long step 4 waits for the answer (default 3)
  -Force           run even though this looks like the main PC (it has the Hyper-V service). Never use this on the main PC.

AFTER IT RAN: programs that were already running (the runner and its lanes) keep the old values until they restart; the runner starts its lanes
again by itself every 15 minutes. Open a NEW PowerShell window to see the new PATH, or sign out of the VM and in again to be sure.

EXIT CODES: 0 = done and PASS, 2 = done, but the main PC is not answering yet ("waiting for host-ollama-bridge.ps1"), 1 = could not do it.

NEVER DONE: no secret value is read, printed, copied or logged (key variables are only checked for "set / not set"); no administrator rights, no
firewall, Defender, UAC or Windows Update change. It never sets OPENAI_API_KEY, CODEX_API_KEY or ANTHROPIC_API_KEY.
This script is ASCII only and runs on Windows PowerShell 5.1.
Log: C:\PillagersMove\kit\logs\vm-user-settings-<time>.log
#>
[CmdletBinding()]
param(
  [Alias('WhatIf')][switch]$DryRun,
  [string]$HostIp = '',
  [string]$OllamaUrl = '',
  [int]$TimeoutSec = 3,
  [switch]$Force
)
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

$script:Port = 11434
$script:DocHostIp = '192.168.160.1'
$script:DocCidr = '192.168.160.0/20'
$script:UrlVar = 'PILLAGERS_OLLAMA_URL'
$script:ExpectedModels = @('qwen3.8:27b', 'qwen3.8:latest', 'qwen2.5-coder:32b')
$script:Warnings = 0
$script:DryRun = [bool]$DryRun

# ----------------------------------------------------------------------------------------------------------------------
# logging (plain words; the same lines go to the log file)
# ----------------------------------------------------------------------------------------------------------------------
$script:LogDir = ''
if (Test-Path -LiteralPath 'C:\PillagersMove\kit') { $script:LogDir = 'C:\PillagersMove\kit\logs' }
elseif ($PSScriptRoot) { $script:LogDir = Join-Path $PSScriptRoot 'logs' }
else { $script:LogDir = Join-Path (Get-Location).Path 'logs' }
$script:LogFile = Join-Path $script:LogDir ('vm-user-settings-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
try { if (-not (Test-Path -LiteralPath $script:LogDir)) { $null = New-Item -ItemType Directory -Force -Path $script:LogDir } } catch { }

function Write-Log {
  param([string]$Level, [string]$Text, [string]$Color = 'Gray')
  $clean = ($Text -replace '[^\x20-\x7E]', '?')
  $line = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $Level.PadRight(5) + ' ' + $clean
  try { [System.IO.File]::AppendAllText($script:LogFile, $line + "`r`n", [System.Text.Encoding]::ASCII) } catch { }
  Write-Host ((Get-Date -Format 'HH:mm:ss') + '  ' + $Level.PadRight(5) + ' ' + $clean) -ForegroundColor $Color
}
function Say([string]$t)  { Write-Log 'INFO' $t 'Gray' }
function Good([string]$t) { Write-Log 'OK' $t 'Green' }
function Warn([string]$t) { $script:Warnings++; Write-Log 'WARN' $t 'Yellow' }
function Bad([string]$t)  { Write-Log 'FAIL' $t 'Red' }
function Dry([string]$t)  { Write-Log 'DRY' ('WOULD ' + $t) 'Cyan' }
function Hd([string]$t)   { Write-Log 'STEP' $t 'White' }
function Blank { Write-Host '' }

# ----------------------------------------------------------------------------------------------------------------------
# small pure pieces (unit-tested)
# ----------------------------------------------------------------------------------------------------------------------
function Test-InCidr {
  param([string]$Ip, [string]$Cidr)
  try {
    $parts = $Cidr.Split('/')
    $net = [System.Net.IPAddress]::Parse($parts[0]).GetAddressBytes()
    $bits = [int]$parts[1]
    $ipb = [System.Net.IPAddress]::Parse($Ip).GetAddressBytes()
    if ($net.Length -ne 4 -or $ipb.Length -ne 4) { return $false }
    for ($i = 0; $i -lt 4; $i++) {
      $b = $bits - (8 * $i)
      if ($b -lt 0) { $b = 0 }
      if ($b -gt 8) { $b = 8 }
      $mask = (255 -shl (8 - $b)) -band 255
      if ((([int]$ipb[$i]) -band $mask) -ne (([int]$net[$i]) -band $mask)) { return $false }
    }
    return $true
  } catch { return $false }
}

function Resolve-HostIp {
  # Where is the main PC? Normally 192.168.160.1 (the Hyper-V Default Switch). If the VM sits on a different network, the default gateway is the best guess.
  param([string[]]$LocalIps, [string]$Gateway)
  $r = [ordered]@{ Ip = $script:DocHostIp; Note = ''; Warn = $false }
  $onDoc = (@($LocalIps | Where-Object { $_ -and (Test-InCidr -Ip $_ -Cidr $script:DocCidr) }).Count -gt 0)
  $gwOk = [bool]($Gateway -and ($Gateway -match '^\d{1,3}(\.\d{1,3}){3}$') -and ($Gateway -ne '0.0.0.0'))
  if ($onDoc) {
    if ($gwOk -and (Test-InCidr -Ip $Gateway -Cidr $script:DocCidr)) { $r.Ip = $Gateway; $r.Note = 'the main PC is this VM''s default gateway on the Default Switch network' }
    else { $r.Note = 'the usual Default Switch address of the main PC' }
  } elseif ($gwOk) {
    $r.Ip = $Gateway
    $r.Warn = $true
    $r.Note = 'this VM is not on the usual ' + $script:DocCidr + ' network, so its default gateway ' + $Gateway + ' is used. If the VM is not on the Hyper-V Default Switch that is the wrong address: run again with -HostIp <the main PC address>.'
  } else {
    $r.Warn = $true
    $r.Note = 'could not read this VM''s network, so the usual ' + $script:DocHostIp + ' is used'
  }
  return [pscustomobject]$r
}

function Test-UrlShape {
  param([string]$Url)
  return ([string]$Url).Trim() -match '^https?://[^\s/]+/*$'
}

function Add-PathEntry {
  # Raw = the user PATH as stored (%VARS% not expanded). Returns the new text and whether anything changed.
  param([string]$Raw, [string]$Entry)
  $want = ([Environment]::ExpandEnvironmentVariables($Entry)).Trim().TrimEnd('\')
  $parts = @()
  if ($Raw) { $parts = @($Raw.Split(';')) }
  foreach ($p in $parts) {
    $t = $p.Trim().Trim('"')
    if (-not $t) { continue }
    $x = ([Environment]::ExpandEnvironmentVariables($t)).TrimEnd('\')
    if ($x -ieq $want) { return [pscustomobject]@{ Changed = $false; New = $Raw } }
  }
  $clean = ''
  if ($Raw) { $clean = $Raw.TrimEnd(';') }
  $new = $Entry
  if ($clean) { $new = $clean + ';' + $Entry }
  return [pscustomobject]@{ Changed = $true; New = $new }
}

function Get-ModelNames {
  param([string]$Body)
  try { $j = $Body | ConvertFrom-Json; return @($j.models | ForEach-Object { [string]$_.name }) } catch { return @() }
}

# ----------------------------------------------------------------------------------------------------------------------
# readers and actions
# ----------------------------------------------------------------------------------------------------------------------
function Get-LocalIpv4 {
  $out = @()
  try {
    foreach ($a in @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop)) {
      $ip = [string]$a.IPAddress
      if ($ip -like '127.*' -or $ip -like '169.254.*') { continue }
      $out += $ip
    }
  } catch { }
  return @($out)
}

function Get-DefaultGateway {
  try {
    $routes = @(Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop | Where-Object { ([string]$_.NextHop) -ne '0.0.0.0' })
    if ($routes.Count -eq 0) { return '' }
    $best = $routes | Sort-Object { [int]$_.RouteMetric + [int]$_.InterfaceMetric } | Select-Object -First 1
    return [string]$best.NextHop
  } catch { return '' }
}

function Invoke-QuickGet {
  # One GET with a hard time limit and NO proxy.
  param([string]$Url, [int]$TimeoutMs = 3000)
  $r = [ordered]@{ Ok = $false; Code = 0; Body = ''; Error = ''; Ms = 0 }
  $clock = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $req = [System.Net.HttpWebRequest]::Create($Url)
    $req.Method = 'GET'
    $req.Timeout = $TimeoutMs
    $req.ReadWriteTimeout = $TimeoutMs
    $req.Proxy = $null
    $req.KeepAlive = $false
    $resp = $req.GetResponse()
    try {
      $r.Code = [int]$resp.StatusCode
      $sr = New-Object System.IO.StreamReader($resp.GetResponseStream())
      try { $r.Body = $sr.ReadToEnd() } finally { $sr.Dispose() }
    } finally { $resp.Close() }
    $r.Ok = ($r.Code -eq 200)
  } catch [System.Net.WebException] {
    $st = [string]$_.Exception.Status
    if ($st -eq 'Timeout') { $r.Error = 'timed out (the main PC may not have the firewall rule yet)' }
    elseif ($st -eq 'ConnectFailure') { $r.Error = 'refused (Ollama on the main PC does not listen on that address yet)' }
    else { $r.Error = $_.Exception.Message }
  } catch { $r.Error = $_.Exception.Message }
  $r.Ms = [int]$clock.ElapsedMilliseconds
  return [pscustomobject]$r
}

function Read-UserPath {
  # The user PATH exactly as stored (so %USERPROFILE% style entries are NOT expanded) and the kind of registry value it is.
  param([string]$SubKey = 'Environment')
  $r = [ordered]@{ Had = $false; Raw = ''; Kind = [Microsoft.Win32.RegistryValueKind]::ExpandString }
  $rk = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($SubKey, $false)
  if ($rk) {
    try {
      if (@($rk.GetValueNames()) -contains 'Path') {
        $r.Had = $true
        $r.Raw = [string]$rk.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        $r.Kind = $rk.GetValueKind('Path')
      }
    } finally { $rk.Close() }
  }
  return [pscustomobject]$r
}

function Write-UserPath {
  param([string]$New, $Kind, [string]$SubKey = 'Environment')
  $wk = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($SubKey, $true)
  if (-not $wk) { throw 'could not open your user environment for writing' }
  try { $wk.SetValue('Path', $New, $Kind) } finally { $wk.Close() }
}

function Send-EnvironmentChange {
  # Tells running programs (Explorer, new windows) that the user environment changed.
  try {
    if (-not ('PillagersEnvBroadcast' -as [type])) {
      Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PillagersEnvBroadcast {
  [DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
  static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
  public static void Send() {
    UIntPtr r;
    SendMessageTimeout((IntPtr)0xffff, 0x1A, UIntPtr.Zero, "Environment", 2, 5000, out r);
  }
}
'@
    }
    [PillagersEnvBroadcast]::Send()
  } catch { }
}

function Test-HyperVHost {
  # The main PC has the Hyper-V management service (vmms); the VM does not.
  try { return [bool](Get-Service -Name 'vmms' -ErrorAction SilentlyContinue) } catch { return $false }
}

# ----------------------------------------------------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------------------------------------------------
Hd ('vm-user-settings' + $(if ($script:DryRun) { ' (DRY RUN: nothing is changed)' } else { '' }))
$profileDir = [Environment]::GetFolderPath('UserProfile')
Say ('computer ' + $env:COMPUTERNAME + ', user ' + $env:USERNAME + ', profile ' + $profileDir)

if (Test-HyperVHost) {
  if ($script:DryRun) { Warn 'This looks like the MAIN PC (it has the Hyper-V service), not the VM. This is a dry run, so nothing is changed. Run the real thing only inside the VM.' }
  elseif (-not $Force) {
    Bad 'This looks like the MAIN PC (it has the Hyper-V service), not the VM. Nothing was changed. This script is for the VM only. (-Force overrides this; never use it on the main PC.)'
    Say ('log file: ' + $script:LogFile)
    exit 1
  } else { Warn '-Force was given on a PC that looks like the main PC. Going on because you asked.' }
}

# ---- which address is the main PC?
$hostIpUsed = ''
$url = ''
if ($OllamaUrl) {
  if (-not (Test-UrlShape $OllamaUrl)) { Bad ('-OllamaUrl must look like http://host:port (got: ' + $OllamaUrl + '). Nothing was changed.'); Say ('log file: ' + $script:LogFile); exit 1 }
  $url = $OllamaUrl.Trim().TrimEnd('/')
  Say ('using the address you gave: ' + $url)
} else {
  if ($HostIp) {
    if ($HostIp -notmatch '^\d{1,3}(\.\d{1,3}){3}$') { Bad ('-HostIp must be an address like 192.168.160.1 (got: ' + $HostIp + '). Nothing was changed.'); Say ('log file: ' + $script:LogFile); exit 1 }
    $hostIpUsed = $HostIp
    Say ('using the main PC address you gave: ' + $hostIpUsed)
  } else {
    $res = Resolve-HostIp -LocalIps (Get-LocalIpv4) -Gateway (Get-DefaultGateway)
    $hostIpUsed = $res.Ip
    if ($res.Warn) { Warn ('main PC address ' + $hostIpUsed + ': ' + $res.Note) } else { Say ('main PC address ' + $hostIpUsed + ': ' + $res.Note) }
  }
  $url = 'http://' + $hostIpUsed + ':' + $script:Port
}

# ---- step 1 of 4: PILLAGERS_OLLAMA_URL
Blank
Hd 'Step 1 of 4: your user variable PILLAGERS_OLLAMA_URL (where the helpers find the main PC''s Ollama)'
$cur = [Environment]::GetEnvironmentVariable($script:UrlVar, 'User')
if ($cur -eq $url) { Good ($script:UrlVar + ' is already ' + $url + ' (nothing to do)') }
else {
  if ($cur) { Say ($script:UrlVar + ' is now ' + $cur + ' and will be changed') }
  if ($script:DryRun) { Dry ('set your user variable ' + $script:UrlVar + ' = ' + $url) }
  else {
    try {
      [Environment]::SetEnvironmentVariable($script:UrlVar, $url, 'User')
      $env:PILLAGERS_OLLAMA_URL = $url
      Good ($script:UrlVar + ' set to ' + $url)
    } catch { Bad ('could not set the variable: ' + $_.Exception.Message); Say ('log file: ' + $script:LogFile); exit 1 }
  }
}

# ---- step 2 of 4: PATH
Blank
Hd 'Step 2 of 4: the Claude Code folder on your PATH'
$bin = Join-Path $profileDir '.local\bin'
$claudeExe = Join-Path $bin 'claude.exe'
if (Test-Path -LiteralPath $claudeExe) { Say ('claude.exe is there: ' + $claudeExe) }
else { Warn ('claude.exe is not in ' + $bin + ' yet (is Claude Code installed in this VM?). The folder is put on the PATH anyway, so it works as soon as it is installed.') }
$rawPath = ''
$kindPath = [Microsoft.Win32.RegistryValueKind]::ExpandString
try {
  $up = Read-UserPath
  $rawPath = $up.Raw
  $kindPath = $up.Kind
} catch { Warn ('could not read your user PATH: ' + $_.Exception.Message) }
$add = Add-PathEntry -Raw $rawPath -Entry $bin
if (-not $add.Changed) { Good ($bin + ' is already on your user PATH (nothing to do)') }
elseif ($script:DryRun) { Dry ('add ' + $bin + ' to the end of your user PATH') }
else {
  try {
    Write-UserPath -New $add.New -Kind $kindPath
    Send-EnvironmentChange
    if (($env:Path -split ';') -notcontains $bin) { $env:Path = $env:Path.TrimEnd(';') + ';' + $bin }
    Good ($bin + ' added to your user PATH. Open a NEW PowerShell window to use  claude  there.')
    try { [System.IO.File]::AppendAllText($script:LogFile, (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' INFO  user PATH before this change: ' + ($rawPath -replace '[^\x20-\x7E]', '?') + "`r`n", [System.Text.Encoding]::ASCII) } catch { }
  } catch { Bad ('could not write your user PATH: ' + $_.Exception.Message); Say ('log file: ' + $script:LogFile); exit 1 }
}

# ---- step 3 of 4: key names
Blank
Hd 'Step 3 of 4: helper keys (only the NAMES are checked, never the values)'
$aiKeys = 'C:\claudecode\dark raiders\tools\ai-keys.ps1'
if ($PSScriptRoot) {
  $near = Join-Path (Split-Path -Parent $PSScriptRoot) 'ai-keys.ps1'
  if (Test-Path -LiteralPath $near) { $aiKeys = $near }
}
$aiKeysFound = (Test-Path -LiteralPath $aiKeys)
$defs = @(
  @{ Name = 'PILLAGERS_API_KEY';        Svc = 'console';    Need = $true;  Use = 'the helpers on your Anthropic Console credit (console-lane.sh, console-worker.sh, review-nightly.sh, console-sdk\critic.mjs)' },
  @{ Name = 'PILLAGERS_ADMIN_KEY';      Svc = 'admin';      Need = $true;  Use = 'the real-spend number from the cost report (console-sdk\balance.mjs); without it the helpers fall back to a price estimate' },
  @{ Name = 'PILLAGERS_GEMINI_KEY';     Svc = 'gemini';     Need = $false; Use = 'only tools\ship-review.ps1 -Engine gemini' },
  @{ Name = 'PILLAGERS_OPENAI_KEY';     Svc = 'openai';     Need = $false; Use = 'nothing reads it yet' },
  @{ Name = 'PILLAGERS_XAI_KEY';        Svc = 'xai';        Need = $false; Use = 'nothing reads it yet' },
  @{ Name = 'PILLAGERS_OPENROUTER_KEY'; Svc = 'openrouter'; Need = $false; Use = 'nothing reads it yet' }
)
$missingNeeded = @()
foreach ($d in $defs) {
  $isSet = [bool]([Environment]::GetEnvironmentVariable($d.Name, 'User'))
  if ($isSet) { Good ($d.Name.PadRight(26) + ' is set') }
  elseif ($d.Need) { Warn ($d.Name.PadRight(26) + ' MISSING. Used by ' + $d.Use + '.'); $missingNeeded += $d }
  else { Say ($d.Name.PadRight(26) + ' not set (optional: ' + $d.Use + ')') }
}
if ($missingNeeded.Count -gt 0) {
  Say 'To add a missing key, run this yourself in a normal PowerShell window (the key you paste stays hidden, Claude never sees it):'
  foreach ($d in $missingNeeded) { Say ('   powershell -ExecutionPolicy Bypass -File "' + $aiKeys + '" ' + $d.Svc) }
  Say ('   (the command  powershell -ExecutionPolicy Bypass -File "' + $aiKeys + '"  with nothing after it only shows which keys are set)')
  if (-not $aiKeysFound) { Warn ('tools\ai-keys.ps1 is not in the VM yet (' + $aiKeys + '). It arrives with the Pillagers files (the files stage of vm-setup.ps1).') }
}
foreach ($vn in @('ANTHROPIC_API_KEY', 'OPENAI_API_KEY', 'CODEX_API_KEY')) {
  foreach ($sc in @('User', 'Machine')) {
    if ([Environment]::GetEnvironmentVariable($vn, $sc)) { Warn ($vn + ' is set at ' + $sc + ' level. It must NOT be (it makes tools bill by the token instead of using your sign-in). Remove it in the Environment Variables window; this script never touches it.') }
  }
}

# ---- step 4 of 4: does the main PC answer?
Blank
Hd ('Step 4 of 4: does the main PC answer at ' + $url + ' ?')
$t = Invoke-QuickGet -Url ($url + '/api/tags') -TimeoutMs ([int]($TimeoutSec * 1000))
$pass = $false
if ($t.Ok) {
  $models = @(Get-ModelNames -Body $t.Body)
  $pass = $true
  Good ('PASS: ' + $url + '/api/tags answered in ' + $t.Ms + ' ms with ' + $models.Count + ' model(s)' + $(if ($models.Count -gt 0) { ': ' + ($models -join ', ') } else { '' }))
  $have = @($script:ExpectedModels | Where-Object { $models -contains $_ })
  if ($have.Count -eq 0) { Warn ('None of the models the review lane looks for is there (' + ($script:ExpectedModels -join ', ') + '). On the main PC run  ollama pull qwen3.8:27b .') }
} else {
  Warn ('waiting for host-ollama-bridge.ps1 - ' + $url + '/api/tags did not answer: ' + $t.Error)
  Say 'On the MAIN PC, in an administrator PowerShell, run (add -DryRun first if you want to look):'
  Say '   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install'
  if ($script:DryRun) { Say 'Then run this script again. After a real run (without -DryRun) the settings above are saved, so this step is the only one that waits for the main PC.' }
  else { Say 'Then run this script again. The settings above are already saved, so this step is the only one still waiting.' }
}

Blank
if ($script:DryRun) { Say 'Dry run finished. Nothing was changed.' }
elseif ($pass) { Good 'All done. Programs that are already running keep the old values until they restart; open a NEW PowerShell window, or sign out of the VM and in again.' }
else { Say 'Settings are saved. Programs that are already running keep the old values until they restart; open a NEW PowerShell window, or sign out of the VM and in again.' }
Say ('log file: ' + $script:LogFile)
if ($pass) { exit 0 } else { exit 2 }
