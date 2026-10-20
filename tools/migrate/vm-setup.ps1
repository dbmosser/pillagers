<#
vm-setup.ps1  -  the VM side of the Pillagers move (VM name: Pillagers_Oct26)

WHAT IT IS
  One script that makes the VM a working Pillagers development machine: it installs the tools, strips the Windows
  clutter, copies the look of the main PC, unpacks the Pillagers files at the SAME paths they had on the main PC,
  sets up the helpers that keep the game moving, and checks that everything is alive.

HOW TO RUN (inside the VM, in an ELEVATED Windows PowerShell 5.1 window, signed in as your normal VM user)
  cd C:\PillagersMove\kit
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -DryRun        (look first: changes nothing)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1                 (do everything)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only gpu,apps  (only some stages)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Skip gpu       (everything except some stages)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only apps -AcceptLicences   (installs programs: see -AcceptLicences)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -UndoGpu       (put back the Windows files the GPU stage replaced)

STAGES (always run in this order): preflight, gpu, apps, debloat, look, perf, files, services, health
  Every stage prints START, then ends with DONE, SKIP or FAIL and the reason. Running it again is safe.
  A failed stage does not stop the others unless the others depend on it.

SWITCHES
  -Only a,b      run just these stages           -Skip a,b     run all except these
  -DryRun        show what WOULD happen, change nothing (same as -WhatIf)
  -Force         override the safety stops (see below). It never overrides the secret-file refusal.
  -IncludeOptionalApps  debloat: also remove Phone Link, Sticky Notes, Mail/Calendar, Quick Assist, etc.
  -LeanVisuals   look: also switch off window and menu animations
  -DisableSysMain      perf: stop the SysMain (Superfetch) service (off by default, evidence is mixed)
  -RdpHardwareGraphics gpu: turn on "use hardware graphics for Remote Desktop sessions" (off by default, untested)
  -NoRunner      services: create the "Pillagers runner" task but leave it switched OFF
  -AcceptLicences apps: YOU accept the licence terms of the programs and of the winget package sources. Without this switch the apps
                 stage installs nothing (it only tells you what it would install). With it, the script passes winget's accept flags
                 for you. Read the list printed by -DryRun first.
  -UndoGpu       put back the original Windows files the gpu stage replaced (from C:\PillagersMove\undo\gpu-orig), then ask for a restart.
  -KitDir path   where the kit folder is (default: the folder this script is in)

WHAT -Force OVERRIDES: the "host not stopped" stop in services (marker, copied files not complete / not final / not at the marker commit),
  the "not a VM" stop, the "different user" stop, the "VM repo changed since the last unpack" stop, "already done" memory for gpu and
  files, files without a manifest, and a disk-space warning. It never overrides the secret-file refusal.

THE RUNNER GUARD: the "Pillagers runner" task does not start the runner directly. It runs C:\PillagersMove\launchers\runner-guard.ps1, which
  starts tools\runner-start.vbs only while C:\PillagersMove\kit\host-stopped.txt is a valid "stopped" marker (same checks as here). If the
  main PC is switched back on (host-stop.ps1 -Undo sends a "revoked" marker) the guard stops starting the runner at the next 15-minute tick.

WHAT IT READS (in the VM; every item is optional unless a stage says otherwise)
  C:\PillagersMove\kit\    host-settings.json, start2.bin, wallpaper.*, host-apps.json, keep-apps.txt (extra app names to keep),
                           gpu-pack-manifest.json (field HostBuild), host-stopped.txt (written by host-stop.ps1)
  C:\PillagersMove\payload\ manifest.json, gpu-driver.zip (or gpu-driver\), pillagers-<part>.tar|.zip (paths relative to C:\)
WHAT IT WRITES
  C:\PillagersMove\kit\logs\vm-setup-<yyyyMMdd-HHmmss>.log   C:\PillagersMove\undo\   C:\PillagersMove\state\   C:\PillagersMove\launchers\
  C:\PillagersMove\work\ (scratch; safe to delete)   scheduled tasks "Pillagers runner" and "Pillagers dev services"   desktop shortcuts

NEVER TOUCHED (hard rule): Microsoft Defender settings (no exclusion, no switch for one), the firewall, UAC, SmartScreen,
  Windows Update, BitLocker, Credential Guard / VBS. No secret value (API key, token, password, login file) is read,
  printed, copied or logged. Keys and sign-ins are entered by you afterwards (see the checklist at the end).
  This script is ASCII only and runs on Windows PowerShell 5.1.
#>
[CmdletBinding()]
param(
  [string[]]$Only = @(),
  [string[]]$Skip = @(),
  [Alias('WhatIf')][switch]$DryRun,
  [switch]$Force,
  [switch]$IncludeOptionalApps,
  [switch]$LeanVisuals,
  [switch]$DisableSysMain,
  [switch]$RdpHardwareGraphics,
  [switch]$NoRunner,
  [switch]$AcceptLicences,
  [switch]$UndoGpu,
  [string]$KitDir = ''
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }

# ----------------------------------------------------------------------------------------------------------------------
# constants (mirrors of the main PC: the VM keeps the files at the SAME absolute paths)
# ----------------------------------------------------------------------------------------------------------------------
$script:ScriptVersion = 'vm-setup 1.1 (2026-10-19)'
$script:AllStages = @('preflight', 'gpu', 'apps', 'debloat', 'look', 'perf', 'files', 'services', 'health')
$script:HostComputer = 'JUL26'
$script:RepoRoot = 'C:\claudecode\dark raiders'
$script:CodexTree = 'C:\claudecode\pillagers-codex'
$script:DevRoot = 'C:\claudecode'
$script:MirrorProfile = 'C:\Users\User1'
$script:Scratch = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$script:KeyDesktop = 'C--Users-User1-Desktop-dark-raiders'
$script:KeyRepo = 'C--claudecode-dark-raiders'
$script:PlayUrl = 'http://localhost:8802/dark_raiders.html'
$script:DevUrl = 'http://localhost:8820'
$script:HostNodeMajor = 24
$script:HostNodeVersion = '24.20.0'
$script:CodexVersion = '0.163.0'
$script:GeminiVersion = '0.64.0'
$script:RunnerTask = 'Pillagers runner'
$script:DevTask = 'Pillagers dev services'
$script:MinFreeRamNote = 6
# winget accept flags are passed only when the owner typed -AcceptLicences
$script:AcceptPkg = @()
if ($AcceptLicences) { $script:AcceptPkg = @('--accept-package-agreements', '--accept-source-agreements') }
$script:FilesFailed = $false

# kit and staging folders (the host push puts the kit in C:\PillagersMove\kit and archives in C:\PillagersMove\payload)
$script:Kit = $KitDir
if (-not $script:Kit) { $script:Kit = $PSScriptRoot }
if (-not $script:Kit) { $script:Kit = (Get-Location).Path }
$script:Kit = $script:Kit.TrimEnd('\')
$script:StageRoot = 'C:\PillagersMove'
if ((Split-Path -Leaf $script:Kit) -ieq 'kit') { $script:StageRoot = Split-Path -Parent $script:Kit }
$script:Payload = Join-Path $script:StageRoot 'payload'
$script:WorkDir = Join-Path $script:StageRoot 'work'
$script:StateDir = Join-Path $script:StageRoot 'state'
$script:UndoDir = Join-Path $script:StageRoot 'undo'
$script:LaunchDir = Join-Path $script:StageRoot 'launchers'
$script:LogDir = Join-Path $script:Kit 'logs'
$script:LogFile = Join-Path $script:LogDir ('vm-setup-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')

# run-time state
$script:DryRun = [bool]$DryRun
$script:CurStage = ''
$script:StageWarn = 0
$script:Results = New-Object System.Collections.ArrayList
$script:RestartReasons = New-Object System.Collections.ArrayList
$script:UndoRegs = New-Object System.Collections.ArrayList
$script:UndoApps = New-Object System.Collections.ArrayList
$script:UndoOther = New-Object System.Collections.ArrayList
$script:RegSet = 0
$script:RegSame = 0
$script:RegFail = 0
$script:Online = $false
$script:IsUser1 = $false
$script:VmProfile = $env:USERPROFILE
$script:VmUser = $env:USERNAME
$script:NodeDir = ''

# ----------------------------------------------------------------------------------------------------------------------
# logging (plain words; the same lines go to the log file)
# ----------------------------------------------------------------------------------------------------------------------
function Write-Log {
  param([string]$Level, [string]$Text, [string]$Color = 'Gray')
  $clean = ($Text -replace '[^\x20-\x7E]', '?')
  $pre = ''
  if ($script:CurStage) { $pre = '[' + $script:CurStage + '] ' }
  $line = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') + ' ' + $Level.PadRight(5) + ' ' + $pre + $clean
  try { [System.IO.File]::AppendAllText($script:LogFile, $line + "`r`n", [System.Text.Encoding]::ASCII) } catch { }
  Write-Host ((Get-Date -Format 'HH:mm:ss') + '  ' + $pre + $clean) -ForegroundColor $Color
}
function Say([string]$t)  { Write-Log 'INFO' $t 'Gray' }
function Good([string]$t) { Write-Log 'OK' $t 'Green' }
function Warn([string]$t) { $script:StageWarn++; Write-Log 'WARN' $t 'Yellow' }
function Bad([string]$t)  { Write-Log 'FAIL' $t 'Red' }
function Dry([string]$t)  { Write-Log 'DRY' ('WOULD ' + $t) 'Cyan' }
function Hd([string]$t)   { Write-Log 'STAGE' $t 'White' }
function Blank { Write-Host '' }

function ResDone([string]$why) { return [pscustomobject]@{ Status = 'DONE'; Reason = $why } }
function ResSkip([string]$why) { return [pscustomobject]@{ Status = 'SKIP'; Reason = $why } }
function ResFail([string]$why) { return [pscustomobject]@{ Status = 'FAIL'; Reason = $why } }

function Add-Restart([string]$reason) {
  if (-not ($script:RestartReasons -contains $reason)) { [void]$script:RestartReasons.Add($reason) }
}

# one change = one call. In a dry run it only says what it WOULD do. Returns $true when it worked (or would).
function Do-Change {
  param([string]$DoWhat, [scriptblock]$DoAct)
  if ($script:DryRun) { Dry $DoWhat; return $true }
  try {
    $null = & $DoAct
    Say ('done: ' + $DoWhat)
    return $true
  } catch {
    Warn ('could not ' + $DoWhat + ' - ' + $_.Exception.Message)
    return $false
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# small helpers
# ----------------------------------------------------------------------------------------------------------------------
function Ensure-Dir([string]$p) {
  if (-not (Test-Path -LiteralPath $p)) { try { $null = New-Item -ItemType Directory -Force -Path $p -ErrorAction Stop } catch { } }
}
function Fmt-GB([double]$bytes) { return ('{0:N1} GB' -f ($bytes / 1GB)) }
function Q([string]$s) {
  if ($s -match '[\s"]') { return '"' + ($s -replace '"', '\"') + '"' }
  return $s
}
function Read-JsonFile([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return $null }
  try { return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { Warn ('could not read ' + $path + ' as JSON - ' + $_.Exception.Message); return $null }
}
function Write-JsonFile([string]$path, $obj) {
  try { Ensure-Dir (Split-Path -Parent $path); ($obj | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $path -Encoding ASCII } catch { Warn ('could not write ' + $path) }
}
# read a property by any of several spellings (the manifest field names are not fixed)
function Get-Prop($o, [string[]]$names) {
  if ($null -eq $o) { return $null }
  foreach ($n in $names) {
    $p = $o.PSObject.Properties | Where-Object { $_.Name -ieq $n } | Select-Object -First 1
    if ($p -and $null -ne $p.Value -and ([string]$p.Value) -ne '') { return $p.Value }
  }
  return $null
}
function Get-FileSha256([string]$f) { return (Get-FileHash -LiteralPath $f -Algorithm SHA256).Hash.ToLowerInvariant() }

function Test-Url([string]$Url, [int]$TimeoutMs = 8000) {
  try {
    $r = [System.Net.WebRequest]::Create($Url)
    $r.Method = 'HEAD'
    $r.Timeout = $TimeoutMs
    $resp = $r.GetResponse()
    $resp.Close()
    return $true
  } catch [System.Net.WebException] {
    if ($_.Exception.Response) { return $true }   # any HTTP answer, even an error code, proves the road is open
    return $false
  } catch { return $false }
}
function Get-Web([string]$Url, [string]$OutFile) {
  Ensure-Dir (Split-Path -Parent $OutFile)
  Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 120 -ErrorAction Stop
}

# ----------------------------------------------------------------------------------------------------------------------
# running programs: output goes to files (no deadlocks), time limit, exit code, cleaned ASCII lines back
# ----------------------------------------------------------------------------------------------------------------------
function Clean-Lines([string[]]$lines) {
  $out = New-Object System.Collections.ArrayList
  foreach ($l in $lines) {
    if ($null -eq $l) { continue }
    $c = ($l -replace '[^\x20-\x7E]', '').TrimEnd()
    if ($c.Trim() -eq '') { continue }
    if ($c -match '^[\s\-\\|/]+$') { continue }   # spinner characters
    [void]$out.Add($c)
  }
  return ,$out.ToArray()
}
function Read-TextFileSafe([string]$f) {
  try { if (Test-Path -LiteralPath $f) { return [System.IO.File]::ReadAllLines($f, [System.Text.Encoding]::UTF8) } } catch { }
  return @()
}
function Run-Proc {
  param([string]$File, [string]$ArgLine = '', [int]$TimeoutSec = 600, [string]$WorkingDirectory = '', [switch]$KeepFiles)
  Ensure-Dir $script:WorkDir
  $id = [guid]::NewGuid().ToString('N')
  $of = Join-Path $script:WorkDir ($id + '.out')
  $ef = Join-Path $script:WorkDir ($id + '.err')
  $nf = Join-Path $script:WorkDir 'empty-stdin.txt'
  if (-not (Test-Path -LiteralPath $nf)) { try { Set-Content -LiteralPath $nf -Value '' -Encoding ASCII } catch { } }
  $sp = @{ FilePath = $File; NoNewWindow = $true; PassThru = $true; RedirectStandardOutput = $of; RedirectStandardError = $ef; RedirectStandardInput = $nf }
  if ($ArgLine) { $sp['ArgumentList'] = $ArgLine }
  if ($WorkingDirectory) { $sp['WorkingDirectory'] = $WorkingDirectory }
  $timedOut = $false
  $code = -1
  $errText = ''
  try {
    $p = Start-Process @sp -ErrorAction Stop
    $null = $p.Handle
    if (-not $p.WaitForExit($TimeoutSec * 1000)) {
      $timedOut = $true
      try { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null } catch { }
    } else {
      $p.WaitForExit()
      $code = $p.ExitCode
    }
  } catch { $errText = $_.Exception.Message }
  $lines = @()
  if (-not $KeepFiles) {
    $lines = Clean-Lines @((Read-TextFileSafe $of) + (Read-TextFileSafe $ef))
    Remove-Item -LiteralPath $of, $ef -Force -ErrorAction SilentlyContinue
  }
  if ($errText) { $lines = @($lines) + @('start failed: ' + $errText) }
  return [pscustomobject]@{ ExitCode = $code; TimedOut = $timedOut; Lines = $lines; OutFile = $of; ErrFile = $ef }
}
function Show-Tail($lines, [int]$n = 8) {
  $arr = @($lines)
  if ($arr.Count -eq 0) { return }
  $start = [Math]::Max(0, $arr.Count - $n)
  for ($i = $start; $i -lt $arr.Count; $i++) { Say ('   | ' + $arr[$i]) }
}

# ----------------------------------------------------------------------------------------------------------------------
# PATH and environment helpers
# ----------------------------------------------------------------------------------------------------------------------
function Update-SessionPath {
  $parts = New-Object System.Collections.ArrayList
  foreach ($scope in @('Machine', 'User')) {
    $v = [Environment]::GetEnvironmentVariable('Path', $scope)
    if ($v) { foreach ($x in ($v -split ';')) { if ($x) { [void]$parts.Add([Environment]::ExpandEnvironmentVariables($x)) } } }
  }
  foreach ($x in ($env:Path -split ';')) { if ($x -and -not ($parts -contains $x)) { [void]$parts.Add($x) } }
  $extras = @('C:\Program Files\Git\cmd', 'C:\Program Files\Git\bin', (Join-Path $script:VmProfile '.local\bin'), (Join-Path $env:LOCALAPPDATA 'agy\bin'))
  foreach ($x in $extras) { if ((Test-Path -LiteralPath $x) -and -not ($parts -contains $x)) { [void]$parts.Add($x) } }
  $env:Path = (($parts.ToArray() | Where-Object { $_ }) -join ';')
}
function Add-UserPath([string]$dir) {
  if (-not (Test-Path -LiteralPath $dir)) { return }
  $cur = [Environment]::GetEnvironmentVariable('Path', 'User')
  $items = @()
  if ($cur) { $items = @($cur -split ';' | Where-Object { $_ }) }
  foreach ($i in $items) { if ($i.TrimEnd('\') -ieq $dir.TrimEnd('\')) { return } }
  Do-Change ('add ' + $dir + ' to your PATH') { [Environment]::SetEnvironmentVariable('Path', ((@($items) + $dir) -join ';'), 'User') } | Out-Null
}
function Initialize-Native {
  if ('PilNative' -as [type]) { return }
  Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class PilNative {
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SystemParametersInfo(uint action, uint param, IntPtr value, uint flags);
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  public static extern bool SystemParametersInfo(uint action, uint param, string value, uint flags);
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SystemParametersInfo(uint action, uint param, int[] value, uint flags);
  [DllImport("user32.dll", SetLastError = true)]
  public static extern bool SetSysColors(int cElements, int[] lpaElements, int[] lpaRgbValues);
  [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
  public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint msg, UIntPtr wParam, string lParam, uint flags, uint timeout, out UIntPtr result);
}
'@
}
function Send-SettingChange([string]$what) {
  if ($script:DryRun) { return }
  try {
    Initialize-Native
    $res = [UIntPtr]::Zero
    [void][PilNative]::SendMessageTimeout([IntPtr]0xFFFF, 0x1A, [UIntPtr]::Zero, $what, 2, 5000, [ref]$res)
  } catch { }
}

# ----------------------------------------------------------------------------------------------------------------------
# registry: every change is checked against a do-not-touch list, compared first, and remembered for the undo file
# ----------------------------------------------------------------------------------------------------------------------
$script:ProtectedRegex = '(?i)(Windows Defender|\\SharedAccess|FirewallPolicy|\\WindowsUpdate|\\UpdatePolicy|\\Policies\\System(\\|$)|SmartScreen|\\FVE(\\|$)|DeviceGuard|\\Control\\Lsa(\\|$)|\\Control\\CI(\\|$)|VirtualizationBasedSecurity|\\SecurityProviders|Security Center|SecurityHealth|\\Services\\(wuauserv|UsoSvc|WaaSMedicSvc|WinDefend|mpssvc|BFE)|EnableLUA|ConsentPromptBehavior)'

function Get-RegRoot([string]$hive) {
  if ($hive -eq 'HKCU') { return [Microsoft.Win32.Registry]::CurrentUser }
  return [Microsoft.Win32.Registry]::LocalMachine
}
# returns 'set', 'same', 'dry' or 'fail'
function Set-RegValueX {
  param([string]$Path, [string]$Name, $Value, [string]$Kind = 'DWord', [string]$Why = '')
  if ($Path -match $script:ProtectedRegex) { Warn ('refused to change a protected security setting: ' + $Path); return 'fail' }
  $m = [regex]::Match($Path, '^(HKCU|HKLM):?\\(.*)$')
  if (-not $m.Success) { Warn ('not a registry path this script changes: ' + $Path); return 'fail' }
  $hive = $m.Groups[1].Value
  $sub = $m.Groups[2].Value
  $root = Get-RegRoot $hive
  $want = $null
  switch ($Kind) {
    'DWord' { $u = [uint32]([int64]$Value -band 0xFFFFFFFFL); $want = [BitConverter]::ToInt32([BitConverter]::GetBytes($u), 0) }
    'QWord' { $want = [int64]$Value }
    'Binary' { $want = [byte[]]$Value }
    default { $want = [string]$Value }
  }
  $had = $false
  $oldKind = ''
  $old = $null
  try {
    $key = $root.OpenSubKey($sub)
    if ($key) {
      if (@($key.GetValueNames()) -contains $Name) {
        $had = $true
        $oldKind = $key.GetValueKind($Name).ToString()
        $old = $key.GetValue($Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
      }
      $key.Close()
    }
  } catch { }
  $same = $false
  if ($had -and $oldKind -eq $Kind) {
    if ($Kind -eq 'Binary') { $same = ([Convert]::ToBase64String([byte[]]$old) -eq [Convert]::ToBase64String($want)) }
    else { $same = ([string]$old -ceq [string]$want) }
  }
  if ($same) { return 'same' }
  $label = $hive + ':\' + $sub + '\' + $Name
  if ($script:DryRun) {
    $oldTxt = '(not set)'
    if ($had) { if ($oldKind -eq 'Binary') { $oldTxt = '(binary)' } else { $oldTxt = [string]$old } }
    $newTxt = [string]$want
    if ($Kind -eq 'Binary') { $newTxt = '(binary)' }
    Dry ('set ' + $label + ' from ' + $oldTxt + ' to ' + $newTxt + $(if ($Why) { '   [' + $Why + ']' } else { '' }))
    return 'dry'
  }
  try {
    $k = $root.CreateSubKey($sub)
    $k.SetValue($Name, $want, [Microsoft.Win32.RegistryValueKind]$Kind)
    $k.Close()
  } catch {
    Warn ('could not set ' + $label + ' - ' + $_.Exception.Message)
    return 'fail'
  }
  $oldStore = $old
  if ($had -and $oldKind -eq 'Binary') { $oldStore = [Convert]::ToBase64String([byte[]]$old) }
  $newStore = $want
  if ($Kind -eq 'Binary') { $newStore = [Convert]::ToBase64String($want) }
  [void]$script:UndoRegs.Add([pscustomobject]@{ Hive = $hive; Sub = $sub; Name = $Name; HadOld = $had; OldKind = $oldKind; OldValue = $oldStore; NewKind = $Kind; NewValue = $newStore; Why = $Why; Stage = $script:CurStage })
  return 'set'
}
function RegX {
  param([string]$Path, [string]$Name, $Value, [string]$Kind = 'DWord', [string]$Why = '')
  $r = Set-RegValueX -Path $Path -Name $Name -Value $Value -Kind $Kind -Why $Why
  if ($r -eq 'set' -or $r -eq 'dry') { $script:RegSet++ } elseif ($r -eq 'same') { $script:RegSame++ } else { $script:RegFail++ }
}
function Reset-RegCounters { $script:RegSet = 0; $script:RegSame = 0; $script:RegFail = 0 }

function Format-RegUndo($items) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine('Windows Registry Editor Version 5.00')
  [void]$sb.AppendLine('; Undo file written by vm-setup.ps1. Double-click it to put the old values back.')
  [void]$sb.AppendLine('; A line that ends with =- means the value did not exist before, so it is deleted.')
  [void]$sb.AppendLine('')
  $seen = @{}
  $groups = @{}
  $order = New-Object System.Collections.ArrayList
  foreach ($i in $items) {
    $k = $i.Hive + '|' + $i.Sub
    $vk = $k + '|' + $i.Name.ToLowerInvariant()
    if ($seen.ContainsKey($vk)) { continue }      # keep the FIRST record: that is the original value
    $seen[$vk] = $true
    if (-not $groups.ContainsKey($k)) { $groups[$k] = New-Object System.Collections.ArrayList; [void]$order.Add($k) }
    [void]$groups[$k].Add($i)
  }
  foreach ($k in $order) {
    $first = $groups[$k][0]
    $rootName = 'HKEY_CURRENT_USER'
    if ($first.Hive -eq 'HKLM') { $rootName = 'HKEY_LOCAL_MACHINE' }
    [void]$sb.AppendLine('[' + $rootName + '\' + $first.Sub + ']')
    foreach ($i in $groups[$k]) {
      $n = '"' + $i.Name.Replace('\', '\\').Replace('"', '\"') + '"'
      if (-not $i.HadOld) { [void]$sb.AppendLine($n + '=-'); continue }
      switch ($i.OldKind) {
        'DWord' { [void]$sb.AppendLine($n + '=dword:' + ('{0:x8}' -f [uint32]([int64]$i.OldValue -band 0xFFFFFFFFL))) }
        'String' { [void]$sb.AppendLine($n + '="' + ([string]$i.OldValue).Replace('\', '\\').Replace('"', '\"') + '"') }
        'Binary' {
          $bytes = [Convert]::FromBase64String([string]$i.OldValue)
          [void]$sb.AppendLine($n + '=hex:' + (($bytes | ForEach-Object { $_.ToString('x2') }) -join ','))
        }
        'QWord' {
          $qb = [BitConverter]::GetBytes([int64]$i.OldValue)
          [void]$sb.AppendLine($n + '=hex(b):' + (($qb | ForEach-Object { $_.ToString('x2') }) -join ','))
        }
        default { [void]$sb.AppendLine('; ' + $n + ' had a value of kind ' + $i.OldKind + ' - see the .json undo file') }
      }
    }
    [void]$sb.AppendLine('')
  }
  return $sb.ToString()
}
# write the undo files for the stage that just ran, then start fresh lists
function Save-Undo([string]$Tag) {
  if ($script:DryRun) { return }
  if ($script:UndoRegs.Count -eq 0 -and $script:UndoApps.Count -eq 0 -and $script:UndoOther.Count -eq 0) { return }
  Ensure-Dir $script:UndoDir
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $base = Join-Path $script:UndoDir ('undo-' + $Tag + '-' + $stamp)
  $obj = [pscustomobject]@{
    written = (Get-Date).ToString('s'); stage = $Tag; computer = $env:COMPUTERNAME; user = $script:VmUser
    howToUndo = 'Registry: double-click the .reg file next to this one. Removed apps: reinstall from the Microsoft Store by name, or winget. Other items: see the notes below.'
    registry = @($script:UndoRegs.ToArray()); removedApps = @($script:UndoApps.ToArray()); other = @($script:UndoOther.ToArray())
  }
  Write-JsonFile ($base + '.json') $obj
  if ($script:UndoRegs.Count -gt 0) {
    try { [System.IO.File]::WriteAllText(($base + '.reg'), (Format-RegUndo $script:UndoRegs.ToArray()), [System.Text.Encoding]::ASCII) } catch { Warn 'could not write the .reg undo file' }
  }
  Say ('undo file written: ' + $base + '.json' + $(if ($script:UndoRegs.Count -gt 0) { ' (and .reg)' } else { '' }))
  $script:UndoRegs.Clear(); $script:UndoApps.Clear(); $script:UndoOther.Clear()
}

# ----------------------------------------------------------------------------------------------------------------------
# the person and the machine
# ----------------------------------------------------------------------------------------------------------------------
function Get-BuildString {
  try {
    $k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
    return ([string]$k.CurrentBuild + '.' + [string]$k.UBR)
  } catch { return 'unknown' }
}
function Get-RealDesktop {
  try { $d = [Environment]::GetFolderPath('Desktop'); if ($d) { return $d } } catch { }
  return (Join-Path $script:VmProfile 'Desktop')
}
function Convert-ToClaudeKey([string]$path) { return ($path -replace '[^A-Za-z0-9]', '-') }
function Find-GitExe {
  foreach ($p in @('C:\Program Files\Git\cmd\git.exe', 'C:\Program Files\Git\bin\git.exe')) { if (Test-Path -LiteralPath $p) { return $p } }
  $c = Get-Command git.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.Source }
  return ''
}
function Find-BashExe {
  if (Test-Path -LiteralPath 'C:\Program Files\Git\bin\bash.exe') { return 'C:\Program Files\Git\bin\bash.exe' }
  return ''
}
function Find-NodeExe {
  $c = Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.Source }
  foreach ($p in @('C:\Program Files\nodejs\node.exe')) { if (Test-Path -LiteralPath $p) { return $p } }
  $pk = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages'
  if (Test-Path -LiteralPath $pk) {
    $f = Get-ChildItem -LiteralPath $pk -Filter 'node.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($f) { return $f.FullName }
  }
  return ''
}
function Invoke-Git {
  param([string[]]$GitArgs, [int]$TimeoutSec = 120)
  $g = Find-GitExe
  if (-not $g) { return [pscustomobject]@{ ExitCode = -1; TimedOut = $false; Lines = @('git is not installed') } }
  return (Run-Proc -File $g -ArgLine (($GitArgs | ForEach-Object { Q $_ }) -join ' ') -TimeoutSec $TimeoutSec)
}
function Test-TcpPort([int]$port, [int]$ms = 1500) {
  try {
    $c = New-Object System.Net.Sockets.TcpClient
    $iar = $c.BeginConnect('127.0.0.1', $port, $null, $null)
    $ok = $iar.AsyncWaitHandle.WaitOne($ms) -and $c.Connected
    $c.Close()
    return $ok
  } catch { return $false }
}

# make C:\Users\User1 point at the real profile when the VM user has another name
function Ensure-UserJunction {
  if ($script:VmProfile -ieq $script:MirrorProfile) { return $true }
  if (Test-Path -LiteralPath $script:MirrorProfile) {
    $it = Get-Item -LiteralPath $script:MirrorProfile -Force
    if ($it.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      $tgt = ''
      try { $tgt = [string]($it.Target | Select-Object -First 1) } catch { }
      if ($tgt -and ($tgt.TrimEnd('\') -ieq $script:VmProfile.TrimEnd('\'))) { Say ('the link ' + $script:MirrorProfile + ' -> ' + $script:VmProfile + ' is already in place'); return $true }
      Warn ($script:MirrorProfile + ' is a link to ' + $tgt + ', not to ' + $script:VmProfile + '. Remove that link by hand and run again.')
      return $false
    }
    $kids = @(Get-ChildItem -LiteralPath $script:MirrorProfile -Force -ErrorAction SilentlyContinue)
    if ($kids.Count -gt 0) { Warn ($script:MirrorProfile + ' is a real, non-empty folder (another account?), so a link cannot be made there.'); return $false }
    if (-not $script:DryRun) { Remove-Item -LiteralPath $script:MirrorProfile -Force -ErrorAction SilentlyContinue }
  }
  return (Do-Change ('make the link ' + $script:MirrorProfile + ' -> ' + $script:VmProfile + ' so every path that says User1 lands in your real profile') {
    New-Item -ItemType Junction -Path $script:MirrorProfile -Value $script:VmProfile -ErrorAction Stop | Out-Null
  })
}

# ----------------------------------------------------------------------------------------------------------------------
# start-up: admin, VM check, user, folders, log
# ----------------------------------------------------------------------------------------------------------------------
function Initialize-Context {
  Ensure-Dir $script:LogDir
  $banner = '=== ' + $script:ScriptVersion + '   ' + (Get-Date).ToString('s') + $(if ($script:DryRun) { '   DRY RUN: nothing will be changed' } else { '' })
  Write-Log 'INFO' $banner 'White'
  Say ('log file: ' + $script:LogFile)
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $isAdmin = ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Bad 'This window is not elevated. Right-click Windows PowerShell, choose Run as administrator, and start the script again.'
    return $false
  }
  if ($PSVersionTable.PSEdition -eq 'Core') { Warn 'You are in PowerShell 7. This script is made for Windows PowerShell 5.1 (powershell.exe); the app-removal commands may not work here.' }
  $script:VmUser = $env:USERNAME
  $script:VmProfile = $env:USERPROFILE
  $script:UserSid = $id.User.Value
  $script:UserFull = $env:USERDOMAIN + '\' + $env:USERNAME
  $script:IsUser1 = ($script:VmProfile -ieq $script:MirrorProfile)
  # never run on the real PC
  if ($env:COMPUTERNAME -ieq $script:HostComputer) {
    Bad ('This is ' + $script:HostComputer + ', the main PC. This script is for the VM only and will not run here.')
    return $false
  }
  $isVm = $false
  try {
    $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
    if ($cs.Model -match 'Virtual') { $isVm = $true }
    $script:ConsoleUser = [string]$cs.UserName
    $script:RamTotal = [double]$cs.TotalPhysicalMemory
    $script:CpuLogical = [int]$cs.NumberOfLogicalProcessors
  } catch { }
  if (-not $isVm -and -not $Force) {
    Bad 'This does not look like a virtual machine, so the script stops. (Add -Force only if you are sure.)'
    return $false
  }
  $hs = Join-Path $script:Kit 'host-stopped.txt'
  if (Test-Path -LiteralPath $hs) {
    $txt = (Get-Content -LiteralPath $hs -Raw -ErrorAction SilentlyContinue)
    if ($txt -and $txt -match ('(?im)^\s*computer(name)?\s*[:=]\s*' + [regex]::Escape($env:COMPUTERNAME) + '\s*$')) {
      Bad 'The host-stopped marker says it was written on this very computer. Refusing.'
      return $false
    }
  }
  if ($script:ConsoleUser -and ($script:ConsoleUser -ine $script:UserFull) -and -not $Force) {
    Bad ('You are signed in as ' + $script:ConsoleUser + ' but this window runs as ' + $script:UserFull + '. Look settings and files must go to the signed-in user. Open an elevated window while signed in as the user you will work as (or use -Force).')
    return $false
  }
  return $true
}

function Resolve-StageList {
  $norm = {
    param($list)
    $o = New-Object System.Collections.ArrayList
    foreach ($e in @($list)) { foreach ($p in ([string]$e -split '[,;\s]+')) { if ($p) { [void]$o.Add($p.ToLowerInvariant()) } } }
    return ,$o.ToArray()
  }
  $onlyL = & $norm $Only
  $skipL = & $norm $Skip
  foreach ($s in @($onlyL) + @($skipL)) {
    if (-not ($script:AllStages -contains $s)) {
      Bad ('Unknown stage name "' + $s + '". Valid names: ' + ($script:AllStages -join ', '))
      return $null
    }
  }
  $run = New-Object System.Collections.ArrayList
  foreach ($s in $script:AllStages) {
    if (@($onlyL).Count -gt 0 -and -not (@($onlyL) -contains $s)) { continue }
    if (@($skipL) -contains $s) { continue }
    [void]$run.Add($s)
  }
  return ,$run.ToArray()
}


# ======================================================================================================================
# STAGE preflight : look around, check the basics, print the plan
# ======================================================================================================================
function Stage-preflight {
  $build = Get-BuildString
  $caption = ''
  try { $caption = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption } catch { }
  Say ('Windows: ' + $caption + ', build ' + $build)
  Say ('computer: ' + $env:COMPUTERNAME + '    signed-in user: ' + $script:UserFull + '    profile folder: ' + $script:VmProfile)
  if ($script:IsUser1) {
    Say 'Your profile is already C:\Users\User1, so every path in the Pillagers scripts works as it is.'
  } else {
    Say ('Your profile is ' + $script:VmProfile + ', not C:\Users\User1. The files stage makes the link C:\Users\User1 -> ' + $script:VmProfile + ' so the scripts that say User1 still find your files.')
  }
  $ramGB = 0
  if ($script:RamTotal) { $ramGB = [Math]::Round($script:RamTotal / 1GB, 1) }
  Say ('memory: ' + $ramGB + ' GB    processors: ' + $script:CpuLogical)
  if ($ramGB -gt 0 -and $ramGB -lt 14) {
    Warn ('This VM has ' + $ramGB + ' GB of memory. The Pillagers helpers wait until ' + $script:MinFreeRamNote + ' GB is free before they start a job, so they will rarely run. Give the VM more memory from the host (host-vm-boost.ps1).')
  }
  if ($script:CpuLogical -gt 0 -and $script:CpuLogical -lt 6) { Warn ('Only ' + $script:CpuLogical + ' processors in this VM. 8 or more is better for the test robots.') }

  # disk space
  $freeBytes = 0
  try { $freeBytes = (Get-PSDrive -Name C -ErrorAction Stop).Free } catch { }
  Say ('free space on C: ' + (Fmt-GB $freeBytes))
  $need = 0
  $man = Get-PayloadManifest
  if ($man.Found) { foreach ($e in $man.Entries) { $need += [double]$e.Size } }
  if ($need -gt 0) { Say ('the payload archives add up to ' + (Fmt-GB $need) + ' (they are unpacked to about the same size again)') }
  if ($freeBytes -gt 0 -and $freeBytes -lt 5GB) {
    $script:Abort = $true
    return (ResFail ('only ' + (Fmt-GB $freeBytes) + ' free on C:, not enough to do anything useful. Free some space (or grow the VM disk from the host) and run again.'))
  }
  if ($freeBytes -gt 0 -and $need -gt 0 -and $freeBytes -lt ($need * 1.3 + 8GB)) {
    if ($Force) { Warn 'Free space is lower than the payload needs plus room for the apps (continuing because of -Force).' }
    else { Warn ('Free space (' + (Fmt-GB $freeBytes) + ') looks tight for ' + (Fmt-GB $need) + ' of files plus about 8 GB of apps. The files stage will check again.') }
  }

  # internet
  $urls = @('https://cdn.winget.microsoft.com', 'https://claude.ai', 'https://registry.npmjs.org', 'https://antigravity.google', 'https://github.com')
  $okN = 0
  foreach ($u in $urls) {
    if (Test-Url $u) { Say ('internet: ' + $u + ' answers'); $okN++ } else { Warn ('internet: ' + $u + ' does not answer') }
  }
  $script:Online = ($okN -ge 2)
  if (-not $script:Online) { Warn 'The VM does not seem to have internet. The apps stage needs it; the other stages do not.' }

  # kit and payload
  foreach ($f in @('host-settings.json', 'start2.bin', 'host-apps.json', 'host-stopped.txt', 'gpu-pack-manifest.json', 'keep-apps.txt')) {
    $p = Join-Path $script:Kit $f
    if (Test-Path -LiteralPath $p) { Say ('kit: ' + $f + ' is here') } else { Say ('kit: ' + $f + ' is not here' + $(if ($f -eq 'host-stopped.txt') { ' (the services stage will refuse to start the helpers until it is)' } else { '' })) }
  }
  Test-KitManifest
  Show-MarkerFacts
  $wp = @(Get-ChildItem -LiteralPath $script:Kit -Filter 'wallpaper.*' -File -ErrorAction SilentlyContinue)
  if ($wp.Count -gt 0) { Say ('kit: wallpaper file ' + $wp[0].Name + ' is here') } else { Say 'kit: no wallpaper file' }
  $gz = Join-Path $script:Payload 'gpu-driver.zip'
  $gd = Join-Path $script:Payload 'gpu-driver'
  if (Test-Path -LiteralPath $gz) { Say ('payload: gpu-driver.zip (' + (Fmt-GB (Get-Item -LiteralPath $gz).Length) + ')') }
  elseif (Test-Path -LiteralPath $gd) { Say 'payload: gpu-driver folder is here' }
  else { Say 'payload: no GPU driver pack (the gpu stage will skip)' }
  if ($man.Found) {
    Say ('payload: manifest.json lists ' + @($man.Entries).Count + ' archive(s); ' + $(if ($man.Final) { 'it is the FINAL copy' } else { 'it is a first-pass copy (not final)' }) + $(if ($man.GitHead) { ', main PC commit ' + $man.GitHead.Substring(0, [math]::Min(12, $man.GitHead.Length)) } else { '' }))
    foreach ($e in $man.Entries) { Say ('   ' + $e.Name + '  ' + (Fmt-GB ([double]$e.Size))) }
  } else { Say 'payload: no manifest.json (the files stage will stop without it unless -Force)' }

  $pend = $false
  try { if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $pend = $true } } catch { }
  if ($pend) { Warn 'Windows says a restart is already pending. Restart the VM when this run is over.' }

  $gm = Read-JsonFile (Join-Path $script:Kit 'gpu-pack-manifest.json')
  if ($gm) {
    $hb = [string](Get-Prop $gm @('HostBuild'))
    if ($hb -and $hb -ne $build) { Warn ('The main PC is on Windows build ' + $hb + ' and this VM is on ' + $build + '. The GPU only works when they match: update Windows in the VM (Settings, Windows Update) first.') }
  }

  # the plan
  Blank
  Say 'PLAN (stages run in this order):'
  $desc = @{
    preflight = 'look around and check the basics (this stage)'
    gpu       = 'put the AMD graphics driver files into the VM (needs a restart after)'
    apps      = 'install Chrome, Git, Node, Python, PowerShell 7, 7-Zip, Claude, Claude Code, Codex, Gemini, agy'
    debloat   = 'remove consumer apps and nags (an undo file is written); never touches Defender, firewall, UAC, SmartScreen, Windows Update, BitLocker'
    look      = 'copy the main PC look: dark theme, accent, taskbar, wallpaper, mouse, keyboard, time zone, language'
    perf      = 'performance power plan, no sleep, search index leaves C:\claudecode alone, background apps off'
    files     = 'check and unpack the Pillagers files to the same paths as on the main PC'
    services  = 'scheduled tasks, servers, dev console, desktop shortcuts (refuses until the main PC is stopped)'
    health    = 'run the Pillagers health check and print the sign-in checklist'
  }
  foreach ($s in $script:AllStages) {
    $mark = '   '
    if ($script:Selected -contains $s) { $mark = ' > ' }
    Say ($mark + $s.PadRight(10) + $desc[$s])
  }
  if ($script:DryRun) { Say 'DRY RUN: nothing below will change anything.' }
  return (ResDone ('checks finished, ' + $script:StageWarn + ' warning(s)'))
}

# ======================================================================================================================
# STAGE gpu : AMD driver files into the guest (GPU partition), restart, then verify
# ======================================================================================================================
function Get-VideoAdapters {
  $o = @()
  try {
    $o = @(Get-CimInstance Win32_VideoController -ErrorAction Stop | ForEach-Object {
      [pscustomobject]@{ Name = [string]$_.Name; Status = [string]$_.Status; Code = [int]$_.ConfigManagerErrorCode; Driver = [string]$_.DriverVersion; Pnp = [string]$_.PNPDeviceID }
    })
  } catch { }
  return ,$o
}
function Show-VideoAdapters($list) {
  foreach ($a in @($list)) { Say ('   display adapter: ' + $a.Name + '  status=' + $a.Status + '  problem code=' + $a.Code + '  driver=' + $a.Driver) }
}
function Test-RadeonWorking($list) {
  foreach ($a in @($list)) { if ($a.Name -match 'Radeon|AMD' -and $a.Name -notmatch 'Microsoft' -and $a.Code -eq 0 -and $a.Status -eq 'OK') { return $a } }
  return $null
}
function Copy-TreeRobo([string]$src, [string]$dst) {
  $r = Run-Proc -File 'robocopy.exe' -ArgLine ((Q $src) + ' ' + (Q $dst) + ' /E /R:1 /W:1 /NFL /NDL /NJH /NP /XJ') -TimeoutSec 3600
  return $r
}

# ---- GPU safety net: the original of every Windows file the pack replaces is saved first, so -UndoGpu can put it back
$script:GpuOrigDir = Join-Path $script:UndoDir 'gpu-orig'

function Get-GpuOrigRecord {
  $o = [pscustomobject]@{ Saved = @(); Added = @(); Packages = @() }
  $j = Read-JsonFile (Join-Path $script:GpuOrigDir 'gpu-orig.json')
  if ($j) {
    $o.Saved = @($j.Saved | Where-Object { $_ })
    $o.Added = @($j.Added | Where-Object { $_ })
    $o.Packages = @($j.Packages | Where-Object { $_ })
  }
  return $o
}

# copies the original of each file the pack would replace to undo\gpu-orig\<System32|SysWOW64>\<same path>. A file saved on an earlier run is
# never saved again (so the copy stays the TRUE original). Files the pack adds (nothing there before) are listed as Added.
# Returns the number of originals that could NOT be saved (the caller must then copy nothing).
function Backup-GpuOriginals([string]$sysSrc, [string]$wowSrc, [string[]]$pkgNames) {
  $root = $script:GpuOrigDir
  Ensure-Dir $root
  $rec = Get-GpuOrigRecord
  $saved = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  $added = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  $pk = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($x in $rec.Saved) { [void]$saved.Add([string]$x) }
  foreach ($x in $rec.Added) { [void]$added.Add([string]$x) }
  foreach ($x in $rec.Packages) { [void]$pk.Add([string]$x) }
  foreach ($x in @($pkgNames)) { if ($x) { [void]$pk.Add([string]$x) } }
  $nSaved = 0; $nAdded = 0; $nFail = 0
  $log = New-Object System.Collections.ArrayList
  [void]$log.Add('gpu-orig log ' + (Get-Date).ToString('s'))
  foreach ($pair in @(@('System32', $sysSrc, (Join-Path $env:SystemRoot 'System32')), @('SysWOW64', $wowSrc, (Join-Path $env:SystemRoot 'SysWOW64')))) {
    if (-not $pair[1] -or -not (Test-Path -LiteralPath $pair[1])) { continue }
    $srcRoot = (Get-Item -LiteralPath $pair[1]).FullName.TrimEnd('\')
    foreach ($f in @(Get-ChildItem -LiteralPath $srcRoot -Recurse -File -Force -ErrorAction SilentlyContinue)) {
      $rel = $f.FullName.Substring($srcRoot.Length + 1)
      $key = $pair[0] + '\' + $rel
      if ($saved.Contains($key) -or $added.Contains($key)) { continue }
      $dst = Join-Path $pair[2] $rel
      if (Test-Path -LiteralPath $dst -PathType Leaf) {
        $bk = Join-Path $root $key
        try {
          Ensure-Dir (Split-Path -Parent $bk)
          Copy-Item -LiteralPath $dst -Destination $bk -Force -ErrorAction Stop
          [void]$saved.Add($key); $nSaved++; [void]$log.Add('saved original: ' + $key)
        } catch { $nFail++; [void]$log.Add('COULD NOT SAVE: ' + $key + ' - ' + $_.Exception.Message) }
      } else { [void]$added.Add($key); $nAdded++; [void]$log.Add('new file (nothing there before): ' + $key) }
    }
  }
  Write-JsonFile (Join-Path $root 'gpu-orig.json') ([pscustomobject]@{ Written = (Get-Date).ToString('s'); Saved = [string[]]@($saved | Sort-Object); Added = [string[]]@($added | Sort-Object); Packages = [string[]]@($pk | Sort-Object) })
  try { [System.IO.File]::AppendAllText((Join-Path $root 'gpu-orig.log'), (($log -join "`r`n") + "`r`n"), [System.Text.Encoding]::ASCII) } catch { }
  Say ('GPU originals: ' + $nSaved + ' saved now, ' + $nAdded + ' new files noted, ' + $nFail + ' could not be saved (list: ' + (Join-Path $root 'gpu-orig.log') + ')')
  return $nFail
}

function Test-GpuKeySafe([string]$key) {
  return ($key -match '^(System32|SysWOW64)\\[^:*?"<>|]+$' -and $key -notmatch '(^|\\)\.\.(\\|$)')
}

function Invoke-UndoGpu {
  Blank
  Hd 'undo of the gpu stage (-UndoGpu)'
  $root = $script:GpuOrigDir
  $rec = Get-GpuOrigRecord
  if ($rec.Saved.Count -eq 0 -and $rec.Added.Count -eq 0 -and $rec.Packages.Count -eq 0 -and -not (Test-Path -LiteralPath (Join-Path $root 'System32'))) {
    Warn ('there is no record to undo (' + (Join-Path $root 'gpu-orig.json') + ' is missing or empty). Nothing was changed.')
    return 1
  }
  Say ('record: ' + $rec.Saved.Count + ' original file(s) to put back, ' + $rec.Added.Count + ' file(s) the pack added, ' + $rec.Packages.Count + ' driver package folder(s)')
  $fail = 0
  $win = $env:SystemRoot
  foreach ($key in $rec.Saved) {
    if (-not (Test-GpuKeySafe ([string]$key))) { Warn ('skipped an unsafe name in the record: ' + $key); $fail++; continue }
    $bk = Join-Path $root $key
    $dst = Join-Path $win $key
    if (-not (Test-Path -LiteralPath $bk -PathType Leaf)) { Warn ('the saved original is missing: ' + $key); $fail++; continue }
    if (-not (Do-Change ('put back the original ' + $key) { Copy-Item -LiteralPath $bk -Destination $dst -Force -ErrorAction Stop })) { $fail++ }
  }
  $fr = Join-Path $win 'System32\HostDriverStore\FileRepository'
  foreach ($pn in $rec.Packages) {
    if ([string]$pn -notmatch '^[A-Za-z0-9_.\-]+\.inf_amd64_[0-9a-fA-F]+$') { Warn ('skipped a driver folder name that looks wrong: ' + $pn); continue }
    $pd = Join-Path $fr $pn
    if (Test-Path -LiteralPath $pd) { if (-not (Do-Change ('remove the driver folder the pack added: ' + $pn) { Remove-Item -LiteralPath $pd -Recurse -Force -ErrorAction Stop })) { $fail++ } }
  }
  foreach ($key in $rec.Added) {
    if (-not (Test-GpuKeySafe ([string]$key))) { continue }
    if ($key -like 'System32\HostDriverStore\FileRepository\*') { continue }   # inside a package folder: handled above
    $dst = Join-Path $win $key
    if (Test-Path -LiteralPath $dst -PathType Leaf) { if (-not (Do-Change ('remove the file the pack added: ' + $key) { Remove-Item -LiteralPath $dst -Force -ErrorAction Stop })) { $fail++ } }
  }
  $movedRoot = Join-Path $root 'System32\HostDriverStore\FileRepository'
  if (Test-Path -LiteralPath $movedRoot) {
    foreach ($d in @(Get-ChildItem -LiteralPath $movedRoot -Directory -ErrorAction SilentlyContinue)) {
      $to = Join-Path $fr $d.Name
      if (Test-Path -LiteralPath $to) { Say ('driver folder ' + $d.Name + ' is already back'); continue }
      if (-not (Do-Change ('move the original driver folder back: ' + $d.Name) { Move-Item -LiteralPath $d.FullName -Destination $to -Force -ErrorAction Stop })) { $fail++ }
    }
  }
  if (-not $script:DryRun) {
    Remove-Item -LiteralPath (Join-Path $script:StateDir 'gpu-installed.json') -Force -ErrorAction SilentlyContinue
    if ($fail -eq 0 -and (Test-Path -LiteralPath $root)) {
      $done = $root + '-undone-' + (Get-Date -Format 'yyyyMMdd-HHmmss')
      try { Rename-Item -LiteralPath $root -NewName (Split-Path -Leaf $done) -ErrorAction Stop; Say ('the record was kept as ' + $done) } catch { }
    }
  }
  Add-Restart 'the original Windows graphics files were put back; restart the VM'
  if ($fail -gt 0) { Warn ($fail + ' step(s) did not work (files in use are the usual reason). Restart the VM and run -UndoGpu again; the record is kept.'); return 1 }
  Good 'GPU files are back to what they were before the gpu stage. Restart the VM. (To remove the GPU adapter itself, use host-vm-boost.ps1 on the main PC.)'
  return 0
}

function Stage-gpu {
  Ensure-Dir $script:StateDir
  $stateFile = Join-Path $script:StateDir 'gpu-installed.json'
  $adapters = Get-VideoAdapters
  Show-VideoAdapters $adapters
  $radeon = Test-RadeonWorking $adapters
  $zip = Join-Path $script:Payload 'gpu-driver.zip'
  $dir = Join-Path $script:Payload 'gpu-driver'
  $kind = ''
  if (Test-Path -LiteralPath $zip) { $kind = 'zip' } elseif (Test-Path -LiteralPath $dir -PathType Container) { $kind = 'dir' }
  $state = Read-JsonFile $stateFile

  if ($kind -eq '') {
    if ($radeon) { Good ('The Radeon is already visible: ' + $radeon.Name); return (ResDone 'Radeon already visible, no pack needed') }
    return (ResSkip 'there is no payload\gpu-driver.zip (or folder). Run host-vm-boost.ps1 on the main PC (it builds the pack), or ignore this if you do not want the GPU in the VM.')
  }

  # signature of the pack (hash when the manifest has one, else size and time)
  $sig = ''
  $expected = ''
  $man = Get-PayloadManifest
  if ($man.Found) { $me = $man.Entries | Where-Object { $_.Name -like 'gpu-driver*' } | Select-Object -First 1; if ($me -and $me.Sha) { $expected = $me.Sha } }
  if ($kind -eq 'zip') {
    $it = Get-Item -LiteralPath $zip
    if ($expected) {
      Say 'checking the GPU pack fingerprint (a minute for a big file)...'
      $h = Get-FileSha256 $zip
      if ($h -ne $expected) { return (ResFail ('gpu-driver.zip does not match the fingerprint in manifest.json (got ' + $h.Substring(0, 12) + '..., wanted ' + $expected.Substring(0, 12) + '...). The copy is damaged; push it again from the main PC.')) }
      $sig = 'sha256:' + $h
    } else { $sig = 'zip:' + $it.Length + ':' + $it.LastWriteTimeUtc.Ticks }
  } else {
    $files = @(Get-ChildItem -LiteralPath $dir -Recurse -File -ErrorAction SilentlyContinue)
    $total = 0; foreach ($f in $files) { $total += $f.Length }
    $sig = 'dir:' + $files.Count + ':' + $total
  }

  $boot = $null
  try { $boot = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).LastBootUpTime } catch { }

  # already installed on an earlier run: only verify
  if ($state -and ([string]$state.Pack -eq $sig) -and -not $Force) {
    $when = [datetime]::MinValue
    try { $when = [datetime]$state.InstalledAt } catch { }
    if ($radeon) { Good ('The Radeon is visible and working: ' + $radeon.Name + ' (driver ' + $radeon.Driver + ')'); Say 'Next: open Chrome in the VM, go to chrome://gpu and check that Canvas and WebGL say Hardware accelerated. dxdiag (Display tab) should list the Radeon too.'; return (ResDone ('Radeon visible and working: ' + $radeon.Name)) }
    if ($boot -and $boot -lt $when) {
      Add-Restart 'the AMD graphics driver files were copied in; the VM must restart before the Radeon appears'
      return (ResSkip 'the driver files are in place but the VM has not restarted since. Restart it, then run: vm-setup.ps1 -Only gpu')
    }
    $bad = @($adapters | Where-Object { $_.Name -match 'Radeon|AMD' -and $_.Code -ne 0 })
    foreach ($b in $bad) {
      if ($b.Code -eq 43) { Warn ('Windows stopped ' + $b.Name + ' (problem code 43). Often the host and VM Windows builds differ, or the AMD driver on the main PC changed after the pack was made. Rebuild the pack on the main PC.') }
      elseif ($b.Code -eq 12) { Warn ('Windows says ' + $b.Name + ' has no room (problem code 12). The host side needs a bigger High MMIO space (host-vm-boost.ps1, 48 GB).') }
      else { Warn ('Problem code ' + $b.Code + ' on ' + $b.Name) }
    }
    return (ResFail 'the VM restarted but the Radeon is not working. The party can still be played on the main PC. To undo: remove the GPU adapter from the VM on the main PC (host-vm-boost.ps1, its GPU undo option) and delete the u0*.inf_amd64_* folders in C:\Windows\System32\HostDriverStore\FileRepository.')
  }

  # nothing to copy if the radeon is already fine and no new pack was pushed
  if ($radeon -and -not $Force -and -not $state) {
    Good ('The Radeon is already visible and working: ' + $radeon.Name + ' (nothing to copy)')
    return (ResDone 'Radeon already visible and working')
  }

  $freeBytes = 0
  try { $freeBytes = (Get-PSDrive -Name C -ErrorAction Stop).Free } catch { }
  if ($freeBytes -gt 0 -and $freeBytes -lt 4GB) { return (ResFail ('only ' + (Fmt-GB $freeBytes) + ' free on C:. The GPU pack needs about 4 GB while it is unpacked.')) }

  # build check against the pack manifest
  $gm = Read-JsonFile (Join-Path $script:Kit 'gpu-pack-manifest.json')
  $build = Get-BuildString
  if ($gm) {
    $hb = [string](Get-Prop $gm @('HostBuild'))
    if ($hb -and $hb -ne $build) { Warn ('Host build ' + $hb + ' and VM build ' + $build + ' differ. GPU partitioning has broken before when they differ. Update Windows in the VM first (Settings, Windows Update).') }
  }

  $tmp = Join-Path $script:WorkDir 'gpu-pack'
  if ($script:DryRun) {
    Dry ('unpack ' + $(if ($kind -eq 'zip') { 'gpu-driver.zip' } else { 'the gpu-driver folder' }) + ' and copy System32 and SysWOW64 files into C:\Windows (including HostDriverStore\FileRepository)')
    Dry ('save the original of every Windows file the pack replaces to ' + $script:GpuOrigDir + ' first (undo: vm-setup.ps1 -UndoGpu)')
    Dry 'move older u0*.inf_amd64_* folders in the VM HostDriverStore into that undo folder, so only the new AMD driver is there'
    Dry 'ask for a restart afterwards'
    return (ResDone '(dry run) would copy the AMD driver pack and ask for a restart')
  }
  Ensure-Dir $script:WorkDir
  if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
  if ($kind -eq 'zip') {
    Say 'unpacking the GPU pack (about 750 MB, a minute or two)...'
    try {
      Add-Type -AssemblyName System.IO.Compression.FileSystem
      [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $tmp)
    } catch { return (ResFail ('could not unpack gpu-driver.zip - ' + $_.Exception.Message)) }
  } else {
    $tmp = $dir
  }
  $sysSrc = Join-Path $tmp 'System32'
  $repo = Join-Path $sysSrc 'HostDriverStore\FileRepository'
  $pkgs = @()
  if (Test-Path -LiteralPath $repo) { $pkgs = @(Get-ChildItem -LiteralPath $repo -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\.inf_amd64_' }) }
  $hasInf = $false
  foreach ($p in $pkgs) { if (@(Get-ChildItem -LiteralPath $p.FullName -Filter '*.inf' -File -ErrorAction SilentlyContinue).Count -gt 0) { $hasInf = $true } }
  if (-not $hasInf) { return (ResFail 'the pack does not contain System32\HostDriverStore\FileRepository\<driver>.inf_amd64_...\*.inf, so it is not a GPU driver pack.') }
  Say ('the pack holds driver package: ' + (($pkgs | ForEach-Object { $_.Name }) -join ', '))

  # save the originals BEFORE anything is replaced; if one cannot be saved, nothing is copied
  $wowSave = Join-Path $tmp 'SysWOW64'
  $saveFails = Backup-GpuOriginals $sysSrc $wowSave @($pkgs | ForEach-Object { $_.Name })
  if ($saveFails -gt 0) {
    if ($kind -eq 'zip') { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
    return (ResFail ($saveFails + ' original Windows file(s) could not be saved to ' + $script:GpuOrigDir + ', so NOTHING was replaced. Free some space or close what uses them, then run the gpu stage again.'))
  }
  $hds = Join-Path $env:SystemRoot 'System32\HostDriverStore\FileRepository'
  if (Test-Path -LiteralPath $hds) {
    $ourPkgs = @((Get-GpuOrigRecord).Packages)
    foreach ($old in @(Get-ChildItem -LiteralPath $hds -Directory -Filter 'u0*.inf_amd64_*' -ErrorAction SilentlyContinue)) {
      $bk = Join-Path $script:GpuOrigDir ('System32\HostDriverStore\FileRepository\' + $old.Name)
      if (($ourPkgs -contains $old.Name) -or (Test-Path -LiteralPath $bk)) {
        # a copy from an earlier run of this pack (or already saved): just replace it
        Do-Change ('remove the earlier copy of the driver folder ' + $old.Name + ' (it came from the pack; the original is saved)') { Remove-Item -LiteralPath $old.FullName -Recurse -Force -ErrorAction Stop } | Out-Null
      } else {
        Do-Change ('move the older driver folder ' + $old.Name + ' into ' + $script:GpuOrigDir) { Ensure-Dir (Split-Path -Parent $bk); Move-Item -LiteralPath $old.FullName -Destination $bk -Force -ErrorAction Stop } | Out-Null
      }
    }
  }
  $copyFail = $false
  $r1 = Copy-TreeRobo $sysSrc (Join-Path $env:SystemRoot 'System32')
  if ($r1.ExitCode -ge 8 -or $r1.TimedOut) { $copyFail = $true; Warn ('copying the System32 files had problems (robocopy code ' + $r1.ExitCode + ')'); Show-Tail $r1.Lines 6 } else { Good 'System32 driver files copied' }
  $wowSrc = Join-Path $tmp 'SysWOW64'
  if (Test-Path -LiteralPath $wowSrc) {
    $r2 = Copy-TreeRobo $wowSrc (Join-Path $env:SystemRoot 'SysWOW64')
    if ($r2.ExitCode -ge 8 -or $r2.TimedOut) { $copyFail = $true; Warn ('copying the SysWOW64 files had problems (robocopy code ' + $r2.ExitCode + ')'); Show-Tail $r2.Lines 6 } else { Good 'SysWOW64 driver files copied' }
  }
  $listFile = Join-Path $tmp 'files.txt'
  if (Test-Path -LiteralPath $listFile) { Copy-Item -LiteralPath $listFile -Destination (Join-Path $script:StateDir 'gpu-files.txt') -Force -ErrorAction SilentlyContinue }
  if ($kind -eq 'zip') { Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue }
  if ($copyFail) { return (ResFail 'some driver files could not be copied (see the lines above). Nothing was recorded as installed, so running the stage again retries.') }

  if ($RdpHardwareGraphics) {
    Reset-RegCounters
    RegX 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' 'bEnumerateHWBeforeSW' 1 'DWord' 'use hardware graphics for Remote Desktop sessions (optional, untested)'
    Warn 'Remote Desktop hardware graphics policy turned on (-RdpHardwareGraphics). If Enhanced Session freezes, undo it with the .reg file in C:\PillagersMove\undo.'
    Save-Undo 'gpu'
  }

  Write-JsonFile $stateFile ([pscustomobject]@{ Pack = $sig; InstalledAt = (Get-Date).ToString('s'); GuestBuild = $build; Kind = $kind })
  Add-Restart 'the AMD graphics driver files were copied in; restart the VM, then run: vm-setup.ps1 -Only gpu   (to verify the Radeon)'
  return (ResDone 'driver files copied. RESTART THE VM now, then run vm-setup.ps1 -Only gpu to check the Radeon shows up.')
}

# ======================================================================================================================
# STAGE apps : install the tools (winget, the official Claude Code and agy installers, npm globals at the main PC versions)
# ======================================================================================================================
$script:Winget = ''

function Get-WingetExe {
  $c = Get-Command winget.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.Source }
  $p = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
  if (Test-Path -LiteralPath $p) { return $p }
  return ''
}
function Test-WingetHas([string]$id) {
  if (-not $script:Winget) { return $false }
  $srcAccept = ''
  if ($script:AcceptPkg.Count -gt 0) { $srcAccept = ' --accept-source-agreements' }
  $r = Run-Proc -File $script:Winget -ArgLine ('list --id ' + $id + ' --exact --source winget' + $srcAccept + ' --disable-interactivity') -TimeoutSec 180
  if ($r.ExitCode -ne 0) { return $false }
  return (@($r.Lines | Where-Object { $_ -match [regex]::Escape($id) }).Count -gt 0)
}
function Install-WingetApp($app) {
  $base = @('install', '--id', $app.Id, '--exact', '--source', 'winget', '--silent') + @($script:AcceptPkg) + @('--disable-interactivity')
  $full = @($base)
  if ($app.Version) { $full += @('--version', $app.Version) }
  if ($app.Scope) { $full += @('--scope', $app.Scope) }
  if ($app.InstallerType) { $full += @('--installer-type', $app.InstallerType) }
  $attempts = New-Object System.Collections.ArrayList
  [void]$attempts.Add($full)
  if ($app.Version) { $a = @($base); if ($app.Scope) { $a += @('--scope', $app.Scope) }; if ($app.InstallerType) { $a += @('--installer-type', $app.InstallerType) }; [void]$attempts.Add($a) }
  if ($app.Scope) { $a = @($base); if ($app.InstallerType) { $a += @('--installer-type', $app.InstallerType) }; [void]$attempts.Add($a) }
  if ($app.InstallerType) { [void]$attempts.Add(@($base)) }
  $tried = @{}
  foreach ($a in $attempts) {
    $line = ($a | ForEach-Object { Q $_ }) -join ' '
    if ($tried.ContainsKey($line)) { continue }
    $tried[$line] = $true
    Say ('winget ' + $line.Replace('--accept-package-agreements --accept-source-agreements --disable-interactivity', '...'))
    $r = Run-Proc -File $script:Winget -ArgLine $line -TimeoutSec 1800
    $ok = ($r.ExitCode -eq 0 -or $r.ExitCode -eq -1978335189 -or $r.ExitCode -eq -1978335135)
    if ($r.TimedOut) { Warn ($app.Name + ': winget took longer than 30 minutes and was stopped') }
    if ($ok) { return $true }
    Warn ($app.Name + ': winget finished with code ' + $r.ExitCode)
    Show-Tail $r.Lines 5
    try { if ([bool](& $app.Test)) { Say ($app.Name + ' is there anyway'); return $true } } catch { }
  }
  return $false
}
function Test-PythonReal {
  $c = Get-Command python.exe -ErrorAction SilentlyContinue | Where-Object { $_.Source -notmatch 'WindowsApps' } | Select-Object -First 1
  if ($c) { return $true }
  foreach ($p in @((Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'), 'C:\Program Files\Python312\python.exe')) { if (Test-Path -LiteralPath $p) { return $true } }
  return $false
}
function Get-NodeDirReal {
  $n = Find-NodeExe
  if (-not $n) { return '' }
  try {
    $it = Get-Item -LiteralPath $n -Force
    if ($it.LinkType -and $it.Target) { $t = [string]($it.Target | Select-Object -First 1); if ($t -and (Test-Path -LiteralPath $t)) { $n = $t } }
  } catch { }
  return (Split-Path -Parent $n)
}
function Set-FirstUserPath([string]$dir) {
  if (-not (Test-Path -LiteralPath $dir)) { return }
  $cur = [Environment]::GetEnvironmentVariable('Path', 'User')
  $items = @()
  if ($cur) { $items = @($cur -split ';' | Where-Object { $_ }) }
  if ($items.Count -gt 0 -and ($items[0].TrimEnd('\') -ieq $dir.TrimEnd('\'))) { return }
  $rest = @($items | Where-Object { $_.TrimEnd('\') -ine $dir.TrimEnd('\') })
  $new = (@($dir) + $rest) -join ';'
  Do-Change ('put ' + $dir + ' first in your PATH, so the scripts find node and its tools there (as on the main PC)') { [Environment]::SetEnvironmentVariable('Path', $new, 'User') } | Out-Null
  if (-not $script:DryRun -and -not ($env:Path.ToLowerInvariant().StartsWith($dir.ToLowerInvariant() + ';'))) { $env:Path = $dir + ';' + $env:Path }
}
function Get-InstalledNpmVersion([string]$nodeDir, [string]$rel) {
  $pj = Join-Path $nodeDir ('node_modules\' + $rel + '\package.json')
  if (-not (Test-Path -LiteralPath $pj)) { return '' }
  try { return [string]((Get-Content -LiteralPath $pj -Raw | ConvertFrom-Json).version) } catch { return '' }
}

function Stage-apps {
  # ---- licence gate: accepting licence terms is the owner's act, so winget's accept flags are passed only with -AcceptLicences
  Blank
  Say 'LICENCES: this stage installs programs with the Windows Package Manager (winget) and with the official installers of'
  Say 'Claude Code and Google agy. Each program has its own licence, and the winget package sources have terms of use.'
  Say 'It installs (when missing): Git for Windows, Node.js LTS, Google Chrome, Python 3.12, PowerShell 7 (MSI), 7-Zip, the Claude desktop app,'
  Say 'Claude Code (official installer), Codex CLI and Gemini CLI (npm, pinned to the main PC versions), and Google agy (official installer).'
  Blank
  if ($script:AcceptPkg.Count -eq 0) {
    if (-not $script:DryRun) {
      Warn 'REFUSED: nothing was installed, because you did not type -AcceptLicences. Read the list above, and the licences if you want to, then run:'
      Warn '   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only apps -AcceptLicences'
      return (ResSkip 'no programs installed: add -AcceptLicences to the command to accept the programs'' licences yourself (dry run first if you want to see the list).')
    }
    Say '(dry run) a real run needs -AcceptLicences before it installs anything.'
  } else { Say 'You typed -AcceptLicences, so winget is told that you accept those licences and package-source terms.' }
  if (-not $script:Online) {
    # one more try: preflight may have been skipped
    $script:Online = ((Test-Url 'https://cdn.winget.microsoft.com') -or (Test-Url 'https://registry.npmjs.org'))
  }
  if (-not $script:Online -and -not $script:DryRun) { return (ResFail 'the VM has no internet, so nothing can be downloaded. Check the VM network (Default Switch) and run: vm-setup.ps1 -Only apps') }

  # winget itself
  $script:Winget = Get-WingetExe
  if (-not $script:Winget) {
    Do-Change 'register the Windows Package Manager (winget) that comes with Windows' { Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe' -ErrorAction Stop } | Out-Null
    if (-not $script:DryRun) { Start-Sleep -Seconds 6 }
    $script:Winget = Get-WingetExe
  }
  if (-not $script:Winget) {
    if ($script:DryRun) { Warn 'winget was not found; a real run would try to register it.' }
    else { return (ResFail 'winget is missing and could not be registered. Open the Microsoft Store, update "App Installer", then run: vm-setup.ps1 -Only apps') }
  } else {
    $wv = Run-Proc -File $script:Winget -ArgLine '--version' -TimeoutSec 60
    Say ('winget: ' + $script:Winget + '  version ' + (($wv.Lines | Select-Object -First 1)))
  }

  $apps = @(
    @{ Name = 'Git for Windows'; Id = 'Git.Git'; Scope = 'machine'; Required = $true; Test = { Test-Path -LiteralPath 'C:\Program Files\Git\bin\bash.exe' } },
    @{ Name = ('Node.js LTS ' + $script:HostNodeMajor + ' (same major as the main PC)'); Id = 'OpenJS.NodeJS.LTS'; Version = $script:HostNodeVersion; Required = $true; Test = { [bool](Find-NodeExe) } },
    @{ Name = 'Google Chrome'; Id = 'Google.Chrome'; Scope = 'machine'; Required = $true; Test = { Test-Path -LiteralPath 'C:\Program Files\Google\Chrome\Application\chrome.exe' } },
    @{ Name = 'Python 3.12'; Id = 'Python.Python.3.12'; Required = $false; Test = { Test-PythonReal } },
    @{ Name = 'PowerShell 7 (MSI build, not the Store build)'; Id = 'Microsoft.PowerShell'; InstallerType = 'wix'; Required = $false; Test = { Test-Path -LiteralPath 'C:\Program Files\PowerShell\7\pwsh.exe' } },
    @{ Name = '7-Zip'; Id = '7zip.7zip'; Required = $false; Test = { Test-Path -LiteralPath 'C:\Program Files\7-Zip\7z.exe' } },
    @{ Name = 'Claude desktop app'; Id = 'Anthropic.Claude'; Required = $false; Test = { (Test-Path -LiteralPath (Join-Path $env:LOCALAPPDATA 'AnthropicClaude\claude.exe')) -or (@(Get-AppxPackage -Name '*Claude*' -ErrorAction SilentlyContinue | Where-Object { $_.Publisher -match 'Anthropic' }).Count -gt 0) } }
  )
  $installed = New-Object System.Collections.ArrayList
  $already = New-Object System.Collections.ArrayList
  $failed = New-Object System.Collections.ArrayList
  foreach ($app in $apps) {
    $has = $false
    try { $has = [bool](& $app.Test) } catch { $has = $false }
    if (-not $has -and $script:Winget -and (Test-WingetHas $app.Id)) { $has = $true }
    if ($has) { Say ($app.Name + ': already installed, skipping'); [void]$already.Add($app.Name); continue }
    if ($script:DryRun) { Dry ('install ' + $app.Name + ' (winget id ' + $app.Id + ')'); continue }
    Say ('installing ' + $app.Name + ' (this can take a few minutes)...')
    $ok = Install-WingetApp $app
    Update-SessionPath
    $now = $false
    try { $now = [bool](& $app.Test) } catch { }
    if ($ok -and $now) { Good ($app.Name + ' installed'); [void]$installed.Add($app.Name) }
    elseif ($ok) { Warn ($app.Name + ': winget said OK but the program is not where it is expected yet (a restart or sign-out may be needed)'); [void]$installed.Add($app.Name) }
    else { Bad ($app.Name + ' could not be installed'); [void]$failed.Add($app.Name + $(if ($app.Required) { ' (REQUIRED)' } else { '' })) }
  }
  Say 'GitHub CLI: not installed on purpose - none of the Pillagers scripts use it.'
  Say 'Ollama: not installed in the VM on purpose - the VM GPU share cannot run it. The model audits keep using Ollama on the main PC.'

  if (-not $script:DryRun) { Update-SessionPath }

  # Node: version and the folder the scripts expect
  $nodeExe = Find-NodeExe
  if ($nodeExe) {
    $nv = Run-Proc -File $nodeExe -ArgLine '--version' -TimeoutSec 30
    $nvs = [string]($nv.Lines | Select-Object -First 1)
    Say ('node: ' + $nodeExe + '  ' + $nvs)
    if ($nvs -match '^v(\d+)\.' -and [int]$Matches[1] -ne $script:HostNodeMajor) { Warn ('Node major version is ' + $Matches[1] + ' but the main PC uses ' + $script:HostNodeMajor + '. Some scripts may behave differently.') }
    $script:NodeDir = Get-NodeDirReal
    if ($script:NodeDir) { Set-FirstUserPath $script:NodeDir }
  } elseif (-not $script:DryRun) { Warn 'node is not available yet; the npm tools below are skipped.' }

  # Claude Code: the official native installer (puts claude.exe in your .local\bin, which the dev console looks for)
  $claudeExe = Join-Path $script:VmProfile '.local\bin\claude.exe'
  if (Test-Path -LiteralPath $claudeExe) {
    $cv = Run-Proc -File $claudeExe -ArgLine '--version' -TimeoutSec 60
    Say ('Claude Code: already installed (' + ($cv.Lines | Select-Object -First 1) + ')')
  } elseif ($script:DryRun) {
    Dry 'install Claude Code with the official installer https://claude.ai/install.ps1 (puts claude.exe in ~\.local\bin)'
  } else {
    Say 'installing Claude Code (official installer)...'
    $ok = Do-Change 'run the official Claude Code installer' {
      $f = Join-Path $script:WorkDir 'claude-install.ps1'
      Get-Web 'https://claude.ai/install.ps1' $f
      $r = Run-Proc -File 'powershell.exe' -ArgLine ('-NoProfile -ExecutionPolicy Bypass -File ' + (Q $f)) -TimeoutSec 900
      Show-Tail $r.Lines 6
    }
    if (-not (Test-Path -LiteralPath $claudeExe) -and $script:Winget) {
      Warn 'The official installer did not leave claude.exe where the dev console expects it. Trying winget (Anthropic.ClaudeCode) as a second way.'
      $r = Run-Proc -File $script:Winget -ArgLine ('install --id Anthropic.ClaudeCode --exact --source winget --silent ' + ($script:AcceptPkg -join ' ') + ' --disable-interactivity') -TimeoutSec 900
      Show-Tail $r.Lines 5
    }
    Add-UserPath (Join-Path $script:VmProfile '.local\bin')
    Update-SessionPath
    if (Test-Path -LiteralPath $claudeExe) { Good 'Claude Code installed' }
    else { Bad 'Claude Code is not installed'; [void]$failed.Add('Claude Code') }
  }

  # npm globals at the exact main-PC versions, placed beside node.exe (the lane scripts look there)
  $npmList = @(
    @{ Pkg = '@openai/codex'; Ver = $script:CodexVersion; Rel = '@openai\codex'; Name = 'Codex CLI' },
    @{ Pkg = '@google/gemini-cli'; Ver = $script:GeminiVersion; Rel = '@google\gemini-cli'; Name = 'Gemini CLI' }
  )
  foreach ($n in $npmList) {
    if (-not $script:NodeDir) {
      if ($script:DryRun) { Dry ('install ' + $n.Name + ' ' + $n.Ver + ' with npm, beside node.exe') }
      else { Warn ($n.Name + ': skipped because node is not installed'); [void]$failed.Add($n.Name) }
      continue
    }
    $have = Get-InstalledNpmVersion $script:NodeDir $n.Rel
    if ($have -eq $n.Ver) { Say ($n.Name + ' ' + $n.Ver + ': already installed, skipping'); continue }
    if ($have) { Say ($n.Name + ': version ' + $have + ' found, the main PC has ' + $n.Ver + ' - installing that one') }
    if ($script:DryRun) { Dry ('npm install -g --prefix "' + $script:NodeDir + '" ' + $n.Pkg + '@' + $n.Ver); continue }
    $npmCli = Join-Path $script:NodeDir 'node_modules\npm\bin\npm-cli.js'
    if (-not (Test-Path -LiteralPath $npmCli)) { Warn ($n.Name + ': npm was not found at ' + $npmCli); [void]$failed.Add($n.Name); continue }
    Say ('installing ' + $n.Name + ' ' + $n.Ver + ' with npm...')
    $r = Run-Proc -File (Find-NodeExe) -ArgLine ((Q $npmCli) + ' install -g --prefix ' + (Q $script:NodeDir) + ' ' + $n.Pkg + '@' + $n.Ver + ' --no-audit --no-fund') -TimeoutSec 900
    $got = Get-InstalledNpmVersion $script:NodeDir $n.Rel
    if ($got -eq $n.Ver) { Good ($n.Name + ' ' + $got + ' installed') }
    else { Bad ($n.Name + ' did not install (npm code ' + $r.ExitCode + ')'); Show-Tail $r.Lines 6; [void]$failed.Add($n.Name) }
  }

  # agy (Google Antigravity CLI): official installer, lands in %LOCALAPPDATA%\agy\bin like on the main PC
  $agyExe = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
  if (Test-Path -LiteralPath $agyExe) { Say 'agy: already installed, skipping' }
  elseif ($script:DryRun) { Dry 'install agy with the official installer https://antigravity.google/cli/install.ps1' }
  else {
    Say 'installing agy (official installer)...'
    $null = Do-Change 'run the official agy installer' {
      $f = Join-Path $script:WorkDir 'agy-install.ps1'
      Get-Web 'https://antigravity.google/cli/install.ps1' $f
      $r = Run-Proc -File 'powershell.exe' -ArgLine ('-NoProfile -ExecutionPolicy Bypass -File ' + (Q $f)) -TimeoutSec 600
      Show-Tail $r.Lines 6
    }
    if (-not (Test-Path -LiteralPath $agyExe) -and $script:Winget) {
      Warn 'The agy installer did not leave agy.exe in the expected place. Trying winget (Google.AntigravityCLI).'
      $r = Run-Proc -File $script:Winget -ArgLine ('install --id Google.AntigravityCLI --exact --source winget --silent ' + ($script:AcceptPkg -join ' ') + ' --disable-interactivity') -TimeoutSec 900
      Show-Tail $r.Lines 5
    }
    Update-SessionPath
    if (Test-Path -LiteralPath $agyExe) { Good 'agy installed' }
    else { Warn 'agy is not at the expected path (ship-review.ps1 looks for %LOCALAPPDATA%\agy\bin\agy.exe). Install it by hand from the Antigravity page.'; [void]$failed.Add('agy') }
  }

  if (-not $script:DryRun) { Send-SettingChange 'Environment' }
  Add-Restart 'new programs were added to PATH; sign out and in (or restart) once so every window sees them'
  $summary = ($installed.Count.ToString() + ' installed, ' + $already.Count + ' already there')
  if ($failed.Count -gt 0) {
    $req = @($failed | Where-Object { $_ -match 'REQUIRED' })
    if ($req.Count -gt 0) { return (ResFail ($summary + '; FAILED: ' + ($failed -join ', '))) }
    return (ResDone ($summary + '; could not install: ' + ($failed -join ', ')))
  }
  if ($script:DryRun) { return (ResDone '(dry run) listed what would be installed') }
  return (ResDone $summary)
}


# ======================================================================================================================
# STAGE debloat : remove consumer apps, switch off nags. Never touches Defender, firewall, UAC, SmartScreen, Update, BitLocker, VBS.
# ======================================================================================================================
function Get-HostKeepIds {
  $ids = New-Object System.Collections.ArrayList
  $j = Read-JsonFile (Join-Path $script:Kit 'host-apps.json')
  if ($j) {
    foreach ($src in @($j.Sources)) {
      foreach ($p in @($src.Packages)) { if ($p.PackageIdentifier) { [void]$ids.Add([string]$p.PackageIdentifier) } }
    }
  }
  return ,$ids.ToArray()
}
function Get-KeepFilePatterns {
  $f = Join-Path $script:Kit 'keep-apps.txt'
  $o = New-Object System.Collections.ArrayList
  if (Test-Path -LiteralPath $f) {
    foreach ($l in (Get-Content -LiteralPath $f -ErrorAction SilentlyContinue)) {
      $t = ([string]$l).Trim()
      if ($t -and -not $t.StartsWith('#')) { [void]$o.Add($t) }
    }
  }
  return ,$o.ToArray()
}
function Test-InsiderOrPrerelease {
  # UNVERIFIED heuristic: the Insider program leaves these values; build numbers above 26200 (25H2) are pre-release branches.
  try {
    $a = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\WindowsSelfHost\Applicability' -ErrorAction Stop
    if ([string]$a.BranchName -match 'ReleasePreview|Beta|Dev|Canary|Insider') { return $true }
    if ($a.PSObject.Properties['EnablePreviewBuilds'] -and [int]$a.EnablePreviewBuilds -gt 0) { return $true }
  } catch { }
  try {
    $b = [int](Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop).CurrentBuild
    if ($b -gt 26200) { return $true }
  } catch { }
  return $false
}

function Stage-debloat {
  Reset-RegCounters
  $script:UndoRegs.Clear(); $script:UndoApps.Clear(); $script:UndoOther.Clear()

  # things that are NEVER removed
  $keepStatic = @('Microsoft.WindowsStore', 'Microsoft.StorePurchaseApp', 'Microsoft.DesktopAppInstaller', 'Microsoft.WindowsTerminal',
    'Microsoft.WindowsNotepad', 'Microsoft.WindowsCalculator', 'Microsoft.Windows.Photos', 'Microsoft.ScreenSketch', 'Microsoft.Paint',
    'Microsoft.SecHealthUI', 'Microsoft.ZuneMusic', 'Microsoft.MicrosoftEdge*', 'Microsoft.WebpImageExtension', 'Microsoft.HEIFImageExtension',
    'Microsoft.VP9VideoExtensions', 'Microsoft.WebMediaExtensions', 'Microsoft.RawImageExtension', 'Microsoft.AV1VideoExtension',
    'Microsoft.HEVCVideoExtension', 'Microsoft.XboxIdentityProvider', 'Microsoft.GamingServices', 'Microsoft.Xbox.TCUI',
    'Microsoft.XboxGameOverlay', 'Microsoft.XboxGamingOverlay', 'Microsoft.GamingApp', 'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.VCLibs*', 'Microsoft.UI.Xaml*', 'Microsoft.NET.Native*', 'Microsoft.WindowsAppRuntime*', 'MicrosoftWindows.Client.*',
    'Microsoft.Windows.ShellExperienceHost', 'Microsoft.Windows.StartMenuExperienceHost', 'Microsoft.LockApp', 'Microsoft.AAD.BrokerPlugin',
    'Microsoft.WindowsAppRuntime*', 'Microsoft.Getstarted', 'Microsoft.StartExperiencesApp', 'Microsoft.Windows.Search*', 'windows.immersivecontrolpanel')
  $hostIds = Get-HostKeepIds
  $keepFile = Get-KeepFilePatterns
  if ($hostIds.Count -gt 0) {
    Say ('host-apps.json: the main PC has ' + $hostIds.Count + ' programs; any app here with the same name stays')
    $storeIds = @($hostIds | Where-Object { $_ -match '^[0-9A-Za-z]{12}$' }).Count
    if ($storeIds -gt 0) { Say ('   ' + $storeIds + ' of them are Store IDs that cannot be matched to app names. If you use one of them on the VM, put its app name in kit\keep-apps.txt (one per line).') }
  } else { Say 'host-apps.json is not in the kit (or empty), so only the built-in keep list protects apps.' }
  if ($keepFile.Count -gt 0) { Say ('keep-apps.txt: ' + $keepFile.Count + ' extra name(s) to keep') }
  $isKept = {
    param($name, $family)
    foreach ($k in $keepStatic) { if ($name -like $k) { return $true } }
    foreach ($k in $keepFile) { if ($name -like $k) { return $true } }
    foreach ($h in $hostIds) { if ($name -ieq $h -or ($family -and $family -ieq $h)) { return $true } }
    return $false
  }

  $core = @('Clipchamp.Clipchamp', 'Microsoft.549981C3F5F10', 'Microsoft.BingFinance', 'Microsoft.BingFoodAndDrink', 'Microsoft.BingHealthAndFitness',
    'Microsoft.BingNews', 'Microsoft.BingSports', 'Microsoft.BingTranslator', 'Microsoft.BingTravel', 'Microsoft.BingWeather',
    'Microsoft.Copilot', 'Microsoft.Windows.AIHub', 'Microsoft.PCManager', 'Microsoft.Messaging', 'Microsoft.3DBuilder', 'Microsoft.Microsoft3DViewer',
    'Microsoft.MicrosoftJournal', 'Microsoft.MicrosoftOfficeHub', 'Microsoft.MicrosoftPowerBIForWindows', 'Microsoft.MicrosoftSolitaireCollection',
    'Microsoft.MixedReality.Portal', 'Microsoft.NetworkSpeedTest', 'Microsoft.Office.OneNote', 'Microsoft.Office.Sway', 'Microsoft.OneConnect',
    'Microsoft.Print3D', 'Microsoft.PowerAutomateDesktop', 'Microsoft.SkypeApp', 'Microsoft.Todos', 'Microsoft.Windows.DevHome',
    'Microsoft.WindowsMaps', 'Microsoft.XboxApp', 'Microsoft.ZuneVideo', 'MicrosoftCorporationII.MicrosoftFamily', 'MicrosoftTeams', 'MSTeams',
    '*Spotify*', '*Disney*', '*Netflix*', '*TikTok*', '*Facebook*', '*Instagram*', '*LinkedIn*', '*CandyCrush*', 'king.com.*', '*PrimeVideo*',
    'Amazon.com.Amazon', '*Twitter*', '*Hulu*')
  $optional = @('MicrosoftWindows.Client.WebExperience', 'Microsoft.WidgetsPlatformRuntime', 'Microsoft.YourPhone', 'MicrosoftWindows.CrossDevice',
    'Microsoft.OutlookForWindows', 'Microsoft.windowscommunicationsapps', 'Microsoft.People', 'Microsoft.GetHelp', 'Microsoft.BingSearch',
    'Microsoft.M365Companions', 'Microsoft.Whiteboard', 'Microsoft.MicrosoftStickyNotes', 'Microsoft.WindowsAlarms',
    'Microsoft.WindowsSoundRecorder', 'Microsoft.WindowsFeedbackHub', 'MicrosoftCorporationII.QuickAssist')
  $patterns = @($core)
  if ($IncludeOptionalApps) { $patterns += $optional; Say 'optional apps (Phone Link, Sticky Notes, Mail, Quick Assist, ...) are included because of -IncludeOptionalApps' }
  else { Say 'optional apps (Phone Link, Sticky Notes, Mail, Quick Assist, ...) are left alone; add -IncludeOptionalApps to remove them too' }

  # ---- 1. apps
  Say 'looking at the installed apps (this takes a little while)...'
  $installed = @()
  $prov = @()
  try { $installed = @(Get-AppxPackage -AllUsers -ErrorAction Stop) } catch { Warn ('could not list installed apps - ' + $_.Exception.Message) }
  try { $prov = @(Get-AppxProvisionedPackage -Online -ErrorAction Stop) } catch { Warn ('could not list the apps new users would get - ' + $_.Exception.Message) }
  $instTargets = @{}
  $provTargets = @{}
  foreach ($pat in $patterns) {
    foreach ($p in $installed) {
      if ($p.Name -like $pat -and -not (& $isKept $p.Name $p.PackageFamilyName)) {
        if ($p.NonRemovable -or $p.IsFramework) { continue }
        if ([string]$p.SignatureKind -eq 'System') { continue }
        $instTargets[$p.PackageFullName] = $p
      }
    }
    foreach ($q in $prov) {
      if ($q.DisplayName -like $pat -and -not (& $isKept $q.DisplayName '')) { $provTargets[$q.PackageName] = $q }
    }
  }
  Say ('apps to remove: ' + $instTargets.Count + ' installed, ' + $provTargets.Count + ' in the new-user list')
  $removed = 0
  $appFail = 0
  foreach ($full in @($instTargets.Keys | Sort-Object)) {
    $p = $instTargets[$full]
    if ($script:DryRun) { Dry ('remove app ' + $p.Name); continue }
    $okRemove = $false
    try { Remove-AppxPackage -Package $full -AllUsers -ErrorAction Stop; $okRemove = $true } catch {
      try { Remove-AppxPackage -Package $full -ErrorAction Stop; $okRemove = $true } catch { }
    }
    if ($okRemove) {
      $removed++
      Say ('removed app ' + $p.Name)
      [void]$script:UndoApps.Add([pscustomobject]@{ Kind = 'installed'; Name = $p.Name; PackageFullName = $full; PackageFamilyName = $p.PackageFamilyName; HowToGetBack = 'search the name in the Microsoft Store, or: winget search ' + $p.Name })
    } else { $appFail++; Warn ('could not remove ' + $p.Name + ' (Windows may protect it)') }
  }
  foreach ($pn in @($provTargets.Keys | Sort-Object)) {
    $q = $provTargets[$pn]
    if ($script:DryRun) { Dry ('remove new-user copy of ' + $q.DisplayName); continue }
    try {
      Remove-AppxProvisionedPackage -Online -PackageName $pn -ErrorAction Stop | Out-Null
      $removed++
      [void]$script:UndoApps.Add([pscustomobject]@{ Kind = 'provisioned'; Name = $q.DisplayName; PackageFullName = $pn; PackageFamilyName = ''; HowToGetBack = 'new users get it again after you reinstall it from the Store' })
    } catch { $appFail++; Warn ('could not remove the new-user copy of ' + $q.DisplayName) }
  }

  # ---- 2. OneDrive
  $odSetup = Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe'
  if (-not (Test-Path -LiteralPath $odSetup)) { $odSetup = Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe' }
  $odRunning = @(Get-Process -Name OneDrive -ErrorAction SilentlyContinue).Count -gt 0
  $odThere = (Test-Path -LiteralPath $odSetup) -or (Test-Path -LiteralPath (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe'))
  if ($odThere -or $odRunning) {
    $null = Do-Change 'uninstall OneDrive (nothing to sync on a dev machine)' {
      Get-Process -Name OneDrive -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
      if (Test-Path -LiteralPath $odSetup) { $r = Run-Proc -File $odSetup -ArgLine '/uninstall' -TimeoutSec 300; Show-Tail $r.Lines 3 }
    }
    [void]$script:UndoOther.Add('OneDrive was uninstalled. To get it back: winget install --id Microsoft.OneDrive')
  } else { Say 'OneDrive: already gone' }

  # ---- 3. policies and per-user switches
  $PolWin = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows'
  $prerelease = Test-InsiderOrPrerelease
  if ($prerelease) {
    Say 'This Windows build looks like a pre-release / Insider build. The diagnostic-data LEVEL is left alone so Windows updates keep arriving (the VM must stay on the same build as the main PC).'
  } else {
    RegX ($PolWin + '\DataCollection') 'AllowTelemetry' 1 'DWord' 'diagnostic data: Required only (Pro treats 0 as 1)'
  }
  RegX ($PolWin + '\DataCollection') 'LimitDiagnosticLogCollection' 1 'DWord' 'less diagnostic log collection'
  RegX ($PolWin + '\DataCollection') 'LimitDumpCollection' 1 'DWord' 'less crash dump collection'
  RegX ($PolWin + '\DataCollection') 'DoNotShowFeedbackNotifications' 1 'DWord' 'no feedback pop-ups'
  RegX 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0 'DWord' 'Widgets / news off'
  RegX ($PolWin + '\WindowsAI') 'AllowRecallEnablement' 0 'DWord' 'Recall off'
  RegX ($PolWin + '\WindowsAI') 'DisableAIDataAnalysis' 1 'DWord' 'AI data analysis off'
  RegX ($PolWin + '\WindowsAI') 'DisableClickToDo' 1 'DWord' 'Click to Do off'
  RegX 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1 'DWord' 'Copilot off'
  RegX ($PolWin + '\CloudContent') 'DisableThirdPartySuggestions' 1 'DWord' 'no third-party suggestions'
  RegX ($PolWin + '\CloudContent') 'DisableTailoredExperiencesWithDiagnosticData' 1 'DWord' 'no tailored tips'
  RegX ($PolWin + '\CloudContent') 'DisableWindowsConsumerFeatures' 1 'DWord' 'no consumer features (Enterprise-only on some editions, harmless)'
  RegX ($PolWin + '\CloudContent') 'DisableSoftLanding' 1 'DWord' 'no tips (Enterprise-only, harmless)'
  RegX ($PolWin + '\CloudContent') 'DisableWindowsSpotlightFeatures' 1 'DWord' 'no Spotlight (Enterprise-only, harmless)'
  RegX ($PolWin + '\CloudContent') 'DisableCloudOptimizedContent' 1 'DWord' 'no cloud-optimized content (Enterprise-only, harmless)'
  RegX ($PolWin + '\CloudContent') 'DisableConsumerAccountStateContent' 1 'DWord' 'no consumer account content (Enterprise-only, harmless)'
  RegX 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' 'DisableSpotlightCollectionOnDesktop' 1 'DWord' 'no Spotlight on the desktop'
  RegX 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 'DWord' 'no web results in Start and search (Bing in Start)'
  RegX 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0 'DWord' 'no Bing in Start'
  RegX 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'CortanaConsent' 0 'DWord' 'no Cortana consent'
  RegX ($PolWin + '\OneDrive') 'DisableFileSyncNGSC' 1 'DWord' 'OneDrive sync off'
  $cdm = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
  foreach ($n in @('SubscribedContent-310093Enabled', 'SubscribedContent-338387Enabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled',
      'SubscribedContent-338393Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SubscribedContent-353698Enabled',
      'SystemPaneSuggestionsEnabled', 'SoftLandingEnabled', 'SilentInstalledAppsEnabled', 'RotatingLockScreenOverlayEnabled', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled')) {
    RegX $cdm $n 0 'DWord' 'no ads or suggestions'
  }
  $adv = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
  RegX $adv 'ShowSyncProviderNotifications' 0 'DWord' 'no sync-provider ads in File Explorer'
  RegX $adv 'Start_IrisRecommendations' 0 'DWord' 'no recommendations in Start'
  RegX $adv 'Start_AccountNotifications' 0 'DWord' 'no account nags in Start'
  RegX 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' 'ScoobeSystemSettingEnabled' 0 'DWord' 'no "finish setting up" nag'
  RegX 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested' 'Enabled' 0 'DWord' 'no suggested-app notifications'

  # ---- 4. Recall (only if the feature exists; it normally does not in a VM)
  if (-not $script:DryRun) {
    try {
      $rf = Get-WindowsOptionalFeature -Online -FeatureName 'Recall' -ErrorAction Stop
      if ($rf -and [string]$rf.State -ne 'Disabled') {
        $null = Do-Change 'switch off the Windows Recall feature' { Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -NoRestart -ErrorAction Stop | Out-Null }
        [void]$script:UndoOther.Add('Recall feature was disabled. To undo: Enable-WindowsOptionalFeature -Online -FeatureName Recall')
      }
    } catch { Say 'Recall: the feature is not on this Windows (normal for a VM)' }
  } else { Dry 'check for the Windows Recall feature and switch it off if present' }

  Save-Undo 'debloat'
  $msg = $removed.ToString() + ' app item(s) removed, ' + $script:RegSet + ' setting(s) changed, ' + $script:RegSame + ' already right'
  if ($script:DryRun) { $msg = '(dry run) ' + $instTargets.Count + ' installed apps and ' + $provTargets.Count + ' new-user copies would be removed; ' + $script:RegSet + ' setting(s) would change' }
  if ($appFail -gt 0 -or $script:RegFail -gt 0) { return (ResDone ($msg + '; ' + ($appFail + $script:RegFail) + ' item(s) could not be changed (see warnings)')) }
  return (ResDone $msg)
}

# ======================================================================================================================
# STAGE look : copy the main PC look-and-feel (host-settings.json, wallpaper, start2.bin, language, time zone)
# ======================================================================================================================
function Test-LookKeyAllowed([string]$p) {
  return ($p -match '(?i)^HKCU:\\(Software\\Microsoft\\Windows\\CurrentVersion\\(Themes\\Personalize|Explorer\\(Accent|Advanced|CabinetState|Wallpapers|VisualEffects)|Search)|Software\\Microsoft\\Windows\\DWM|Control Panel\\(Desktop|Mouse|Keyboard|International|Cursors|Colors|Accessibility))')
}
function Get-CfgValue($cfg, [string]$keyPath, [string]$name) {
  try {
    $prop = $cfg.registry.PSObject.Properties | Where-Object { $_.Name -ieq $keyPath } | Select-Object -First 1
    if ($prop) { $vp = $prop.Value.PSObject.Properties | Where-Object { $_.Name -ieq $name } | Select-Object -First 1; if ($vp) { return $vp.Value } }
  } catch { }
  return $null
}

function Get-CfgKind($cfg, [string]$keyPath, [string]$name) {
  # the exporter (v3) records the real registry value kind of each value in "registryKinds"; '' when it did not
  try {
    if ($null -eq $cfg.registryKinds) { return '' }
    $prop = $cfg.registryKinds.PSObject.Properties | Where-Object { $_.Name -ieq $keyPath } | Select-Object -First 1
    if ($prop) { $vp = $prop.Value.PSObject.Properties | Where-Object { $_.Name -ieq $name } | Select-Object -First 1; if ($vp) { return [string]$vp.Value } }
  } catch { }
  return ''
}

# writes every allowed value of one section ("registry" or "registryExtra") of host-settings.json, using the recorded kind
function Apply-CfgRegistry($cfg, [string]$section) {
  $sec = $null
  $sp = $cfg.PSObject.Properties | Where-Object { $_.Name -ieq $section } | Select-Object -First 1
  if ($sp) { $sec = $sp.Value }
  if ($null -eq $sec) { return }
  foreach ($prop in $sec.PSObject.Properties) {
    $keyPath = [string]$prop.Name
    if ($keyPath -match 'StuckRects3') { Say ('skipping ' + $keyPath + ' (it holds the 4K screen geometry of the main PC)'); continue }
    if (-not (Test-LookKeyAllowed $keyPath)) { Warn ('skipping ' + $keyPath + ' (not a look-and-feel key this script is allowed to write)'); continue }
    foreach ($v in $prop.Value.PSObject.Properties) {
      $n = [string]$v.Name
      $val = $v.Value
      if ($n -eq 'LocaleName' -or $n -eq '(default)') { continue }
      if ($null -eq $val) { continue }
      $kind = Get-CfgKind $cfg $keyPath $n
      if ($val -is [pscustomobject] -and $val.PSObject.Properties['bin']) {
        $bytes = [Convert]::FromBase64String([string]$val.bin)
        RegX $keyPath $n $bytes 'Binary' 'copied from the main PC'
      } elseif ($kind -eq 'String' -or $kind -eq 'ExpandString') {
        RegX $keyPath $n ([string]$val) $kind 'copied from the main PC'
      } elseif ($kind -eq 'DWord' -or $kind -eq 'QWord') {
        RegX $keyPath $n ([int64]$val) $kind 'copied from the main PC'
      } elseif ($kind -eq '') {
        # an older export without kinds: guess from the JSON type
        if ($val -is [string]) { RegX $keyPath $n $val 'String' 'copied from the main PC' }
        elseif ($val -is [bool]) { RegX $keyPath $n ([int]$val) 'DWord' 'copied from the main PC' }
        else { RegX $keyPath $n ([int64]$val) 'DWord' 'copied from the main PC' }
      } else {
        Say ('skipping ' + $keyPath + '\' + $n + ' (value kind ' + $kind + ' is not copied by this script)')
      }
    }
  }
}

function Stage-look {
  Reset-RegCounters
  $script:UndoRegs.Clear(); $script:UndoApps.Clear(); $script:UndoOther.Clear()
  $cfgPath = Join-Path $script:Kit 'host-settings.json'
  $cfg = Read-JsonFile $cfgPath
  if (-not $cfg) { return (ResSkip 'host-settings.json is not in the kit (run host-settings-export.ps1 on the main PC, then push the kit again).') }
  Say ('settings from ' + [string]$cfg.computer + ', exported ' + [string]$cfg.exported)
  $changed = $false

  # ---- registry look (registry = the main look keys, registryExtra = visual-effects mode and wallpaper type)
  Apply-CfgRegistry $cfg 'registry'
  Apply-CfgRegistry $cfg 'registryExtra'
  if ($script:RegSet -gt 0) { $changed = $true }
  Say ($script:RegSet.ToString() + ' look setting(s) ' + $(if ($script:DryRun) { 'would change' } else { 'changed' }) + ', ' + $script:RegSame + ' already matched, ' + $script:RegFail + ' failed')

  # ---- live apply (so no sign-out is needed for mouse, keyboard, menus)
  if (-not $script:DryRun) {
    try { Initialize-Native } catch { Warn ('could not load the Windows helper code - ' + $_.Exception.Message) }
    if ('PilNative' -as [type]) {
      $deskKey = 'HKCU:\Control Panel\Desktop'
      $kbKey = 'HKCU:\Control Panel\Keyboard'
      $msKey = 'HKCU:\Control Panel\Mouse'
      $kd = Get-CfgValue $cfg $kbKey 'KeyboardDelay'
      $ks = Get-CfgValue $cfg $kbKey 'KeyboardSpeed'
      $msd = Get-CfgValue $cfg $deskKey 'MenuShowDelay'
      $dfw = Get-CfgValue $cfg $deskKey 'DragFullWindows'
      $dcs = Get-CfgValue $cfg $msKey 'DoubleClickSpeed'
      $msens = Get-CfgValue $cfg $msKey 'MouseSensitivity'
      $t1 = Get-CfgValue $cfg $msKey 'MouseThreshold1'
      $t2 = Get-CfgValue $cfg $msKey 'MouseThreshold2'
      $acc = Get-CfgValue $cfg $msKey 'MouseSpeed'
      try {
        if ($null -ne $kd) { [void][PilNative]::SystemParametersInfo(0x0017, [uint32][int]$kd, [IntPtr]::Zero, 3) }
        if ($null -ne $ks) { [void][PilNative]::SystemParametersInfo(0x000B, [uint32][int]$ks, [IntPtr]::Zero, 3) }
        if ($null -ne $msd) { [void][PilNative]::SystemParametersInfo(0x006B, [uint32][int]$msd, [IntPtr]::Zero, 3) }
        if ($null -ne $dfw) { [void][PilNative]::SystemParametersInfo(0x0025, [uint32][int]$dfw, [IntPtr]::Zero, 3) }
        if ($null -ne $dcs) { [void][PilNative]::SystemParametersInfo(0x0020, [uint32][int]$dcs, [IntPtr]::Zero, 3) }
        if ($null -ne $msens) { [void][PilNative]::SystemParametersInfo(0x0071, 0, [IntPtr][int]$msens, 3) }
        if ($null -ne $t1 -and $null -ne $t2 -and $null -ne $acc) { [void][PilNative]::SystemParametersInfo(0x0004, 0, [int[]]@([int]$t1, [int]$t2, [int]$acc), 3) }
        Say 'mouse, keyboard and menu settings applied to the running session'
      } catch { Warn ('could not apply mouse/keyboard settings live (a sign-out will do it) - ' + $_.Exception.Message) }
      if ($LeanVisuals) {
        try {
          [void][PilNative]::SystemParametersInfo(0x1043, 0, [IntPtr]::Zero, 3)
          [void][PilNative]::SystemParametersInfo(0x1003, 0, [IntPtr]::Zero, 3)
          Say 'window and menu animations switched off (-LeanVisuals)'
        } catch { Warn 'could not switch animations off' }
      }
    }
  } else {
    Dry 'apply mouse speed, keyboard repeat, double-click time and menu delay to the running session'
    if ($LeanVisuals) { Dry 'switch window and menu animations off (-LeanVisuals)' }
  }

  # ---- wallpaper: the exporter says whether the main PC shows a picture or a solid colour (wallpaperMode)
  $wpMode = ([string]$cfg.wallpaperMode).ToLowerInvariant()
  $wpName = ''
  if ($wpMode -eq 'picture' -or $wpMode -eq 'slideshow-or-spotlight') {
    $wpName = [string]$cfg.wallpaper
    if (-not $wpName) { $found = @(Get-ChildItem -LiteralPath $script:Kit -Filter 'wallpaper.*' -File -ErrorAction SilentlyContinue | Select-Object -First 1); if ($found.Count -gt 0) { $wpName = $found[0].Name } }
  }
  if ($wpMode -eq 'solid') {
    $bg = ([string]$cfg.backgroundColor).Trim()
    if ($bg -notmatch '^\d{1,3} \d{1,3} \d{1,3}$') { $bg = '' }
    $beforeWp = $script:RegSet
    RegX 'HKCU:\Control Panel\Desktop' 'WallPaper' '' 'String' 'the main PC desktop is a solid colour, not a picture'
    if ($bg) { RegX 'HKCU:\Control Panel\Colors' 'Background' $bg 'String' 'desktop colour of the main PC' } else { Warn 'wallpaper: the export has no valid desktop colour, so the colour was left as it is' }
    RegX 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' 'BackgroundType' 1 'DWord' 'background type: solid colour'
    if ($script:RegSet -gt $beforeWp) {
      $changed = $true
      if (-not $script:DryRun) {
        try {
          Initialize-Native
          [void][PilNative]::SystemParametersInfo(20, 0, '', 3)
          if ($bg) { $pp = $bg -split ' '; $col = [int]$pp[0] + 256 * [int]$pp[1] + 65536 * [int]$pp[2]; [void][PilNative]::SetSysColors(1, [int[]]@(1), [int[]]@($col)) }
          Say ('wallpaper: solid colour ' + $bg + ' (as on the main PC); a picture set earlier is gone from the desktop')
        } catch { Warn ('could not apply the solid desktop colour live (a sign-out will do it) - ' + $_.Exception.Message) }
      }
    } else { Say 'wallpaper: already the solid colour of the main PC' }
  } elseif ($wpMode -ne 'picture' -and $wpMode -ne 'slideshow-or-spotlight') {
    Warn 'wallpaper: host-settings.json is an older export (it has no wallpaperMode), so the wallpaper is left alone. Run host-settings-export.ps1 on the main PC and push the kit again. (Any wallpaper.* file in the kit is ignored on purpose; it can be an old picture.)'
  } elseif ($wpName) {
    if ($wpMode -ne 'picture') { Say 'wallpaper: the main PC uses a slideshow or Spotlight; one still picture is set here instead' }
    $src = Join-Path $script:Kit $wpName
    if (Test-Path -LiteralPath $src) {
      $dst = Join-Path $script:VmProfile ('Pictures\pillagers-wallpaper' + [IO.Path]::GetExtension($src))
      $same = $false
      if (Test-Path -LiteralPath $dst) { try { $same = ((Get-FileSha256 $src) -eq (Get-FileSha256 $dst)) } catch { } }
      $cur = ''
      try { $cur = [string](Get-ItemProperty 'HKCU:\Control Panel\Desktop' -ErrorAction Stop).WallPaper } catch { }
      if ($same -and ($cur -ieq $dst)) { Say 'wallpaper: already set' }
      else {
        $ok = Do-Change ('set the wallpaper to ' + $wpName) {
          Ensure-Dir (Split-Path -Parent $dst)
          Copy-Item -LiteralPath $src -Destination $dst -Force -ErrorAction Stop
          Initialize-Native
          if (-not [PilNative]::SystemParametersInfo(20, 0, $dst, 3)) { throw 'Windows refused the wallpaper (are you in the signed-in desktop session?)' }
        }
        if ($ok) { $changed = $true }
      }
    } else { Warn ('wallpaper file ' + $wpName + ' is not in the kit') }
  } else { Say 'wallpaper: none in the kit' }

  # ---- time zone, language, region
  $tz = [string]$cfg.timeZone
  if ($tz) {
    $curTz = ''
    try { $curTz = (Get-TimeZone).Id } catch { }
    if ($curTz -eq $tz) { Say ('time zone: already ' + $tz) }
    else { $null = Do-Change ('set the time zone to ' + $tz) { Set-TimeZone -Id $tz -ErrorAction Stop } }
  }
  $cul = [string]$cfg.culture
  $intlChanged = $false
  if ($cul) {
    if ((Get-Culture).Name -eq $cul) { Say ('region format: already ' + $cul) }
    else { if (Do-Change ('set the region format to ' + $cul) { Set-Culture -CultureInfo $cul -ErrorAction Stop }) { $intlChanged = $true } }
  }
  # system locale (needs a restart): the main PC value from the export, else the region format
  $sysLoc = [string]$cfg.systemLocale
  if (-not $sysLoc) { $sysLoc = $cul }
  if ($sysLoc) {
    try {
      if ((Get-WinSystemLocale).Name -ne $sysLoc) {
        if (Do-Change ('set the system locale to ' + $sysLoc + ' (needs a restart)') { Set-WinSystemLocale -SystemLocale $sysLoc -ErrorAction Stop }) { $intlChanged = $true; Add-Restart 'the system locale was changed' }
      } else { Say ('system locale: already ' + $sysLoc) }
    } catch { }
  }
  # home location (GeoId) as on the main PC
  $geo = 0
  if ($null -ne $cfg.geoId -and ([string]$cfg.geoId) -match '^\d+$') { $geo = [int]$cfg.geoId }
  if ($geo -le 0 -and $cul -eq 'en-US') { $geo = 244 }
  if ($geo -gt 0) {
    try {
      if ((Get-WinHomeLocation).GeoId -ne $geo) { $null = Do-Change ('set the home location (GeoId ' + $geo + ') as on the main PC') { Set-WinHomeLocation -GeoId $geo -ErrorAction Stop } }
      else { Say ('home location: already GeoId ' + $geo) }
    } catch { }
  }
  Say 'not copied on purpose: the main PC power plan text (the perf stage sets the power plan) and start-layout.json (Windows 11 reads start2.bin, below)'
  $langs = @($cfg.languages | Where-Object { $_ })
  if ($langs.Count -gt 0) {
    $haveTags = @()
    try { $haveTags = @(Get-WinUserLanguageList | ForEach-Object { $_.LanguageTag }) } catch { }
    if (($haveTags -join ',') -eq ($langs -join ',')) { Say ('language list: already ' + ($langs -join ', ')) }
    else {
      $ok = Do-Change ('set the language list to ' + ($langs -join ', ')) {
        $ll = New-WinUserLanguageList -Language $langs[0]
        for ($i = 1; $i -lt $langs.Count; $i++) { $null = $ll.Add($langs[$i]) }
        Set-WinUserLanguageList -LanguageList $ll -Force -ErrorAction Stop
      }
      if ($ok) { $intlChanged = $true }
    }
  }
  if ($intlChanged -and (Get-Command Copy-UserInternationalSettingsToSystem -ErrorAction SilentlyContinue)) {
    $null = Do-Change 'copy the language settings to the sign-in screen and to new users' { Copy-UserInternationalSettingsToSystem -WelcomeScreen $true -NewUser $true -ErrorAction Stop }
    Add-Restart 'language settings were copied to the sign-in screen'
  }

  # ---- Start menu layout (best effort; the file is the main PC pin list)
  $startSrc = Join-Path $script:Kit 'start2.bin'
  $startDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState'
  if (Test-Path -LiteralPath $startSrc) {
    if (Test-Path -LiteralPath $startDir) {
      $startDst = Join-Path $startDir 'start2.bin'
      $same = $false
      if (Test-Path -LiteralPath $startDst) { try { $same = ((Get-FileSha256 $startSrc) -eq (Get-FileSha256 $startDst)) } catch { } }
      if ($same) { Say 'Start menu layout: already the same as the main PC' }
      else {
        $ok = Do-Change 'copy the Start menu layout (start2.bin) from the main PC (best effort; pins for programs missing here will be blank)' {
          if ((Test-Path -LiteralPath $startDst) -and -not (Test-Path -LiteralPath ($startDst + '.before-vm-setup'))) { Copy-Item -LiteralPath $startDst -Destination ($startDst + '.before-vm-setup') -Force }
          Copy-Item -LiteralPath $startSrc -Destination $startDst -Force -ErrorAction Stop
          Get-Process -Name StartMenuExperienceHost -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        if ($ok) { $changed = $true; [void]$script:UndoOther.Add('Start menu layout replaced. The old file was saved as start2.bin.before-vm-setup in ' + $startDir) }
      }
    } else { Warn 'Start menu layout: the Start menu data folder does not exist yet (sign out and in once, then run -Only look)' }
  } else { Say 'Start menu layout: no start2.bin in the kit' }

  # ---- taskbar pins (best effort)
  $pins = @($cfg.taskbarPins | Where-Object { $_ })
  if ($pins.Count -eq 0) {
    Say 'taskbar pins: the main PC list is empty (the exporter found none), so nothing to pin. Tell me what you pinned there and I will add it.'
  } else {
    $tbDir = Join-Path $env:APPDATA 'Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar'
    $menus = @((Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs'), (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'))
    $pinned = 0
    foreach ($pin in $pins) {
      $pn = [string]$pin.name
      $pt = [string]$pin.target
      $lnk = $null
      foreach ($m in $menus) { if (-not $lnk -and (Test-Path -LiteralPath $m)) { $lnk = Get-ChildItem -LiteralPath $m -Filter ($pn + '.lnk') -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1 } }
      if (-not $lnk -and $pt -and (Test-Path -LiteralPath $pt)) { $lnk = [pscustomobject]@{ FullName = ''; Target = $pt; Name = ($pn + '.lnk') } }
      if (-not $lnk) { Say ('taskbar pin "' + $pn + '": that program is not on the VM, skipped'); continue }
      $ok = Do-Change ('pin ' + $pn + ' to the taskbar (best effort)') {
        Ensure-Dir $tbDir
        $destLnk = Join-Path $tbDir ($pn + '.lnk')
        if ($lnk.FullName) { Copy-Item -LiteralPath $lnk.FullName -Destination $destLnk -Force -ErrorAction Stop }
        else {
          $ws = New-Object -ComObject WScript.Shell
          $sc = $ws.CreateShortcut($destLnk)
          $sc.TargetPath = $lnk.Target
          $sc.Save()
        }
      }
      if ($ok) { $pinned++ }
    }
    if ($pinned -gt 0) { Say ($pinned.ToString() + ' pin file(s) placed. Windows 11 keeps its own pin list, so if they do not show, right-click the program and choose Pin to taskbar.'); $changed = $true }
  }

  # ---- make Windows and Explorer notice
  if ($changed -or $script:RegSet -gt 0) {
    if ($script:DryRun) { Dry 'tell running programs the theme changed and restart Explorer' }
    else {
      Send-SettingChange 'ImmersiveColorSet'
      Send-SettingChange 'WindowMetrics'
      $null = Do-Change 'restart Explorer so the taskbar, Start and accent colour pick everything up (the desktop flickers once)' {
        Get-Process -Name explorer -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        # Windows restarts the shell by itself (as you, not elevated); give it time before starting one by hand
        for ($w = 0; $w -lt 20; $w++) {
          Start-Sleep -Seconds 1
          if (@(Get-Process -Name explorer -ErrorAction SilentlyContinue).Count -gt 0) { break }
        }
        if (@(Get-Process -Name explorer -ErrorAction SilentlyContinue).Count -eq 0) {
          Start-Process -FilePath 'explorer.exe'
          Warn 'Explorer did not come back by itself, so it was started from this elevated window. If the taskbar looks odd, sign out and in once.'
        }
      }
      Add-Restart 'sign out and in once so every look setting is fully read'
    }
  } else { Say 'nothing changed, so Explorer is left alone' }
  Save-Undo 'look'
  if ($script:DryRun) { return (ResDone ('(dry run) ' + $script:RegSet + ' look setting(s) would change')) }
  if ($script:RegFail -gt 0) { return (ResDone ($script:RegSet.ToString() + ' setting(s) changed; ' + $script:RegFail + ' could not be written (see warnings; some taskbar keys are protected by Windows)')) }
  return (ResDone ($script:RegSet.ToString() + ' setting(s) changed, ' + $script:RegSame + ' already matched'))
}

# ======================================================================================================================
# STAGE perf : power plan, no sleep, search index, background apps
# ======================================================================================================================
function Stage-perf {
  Reset-RegCounters
  $script:UndoRegs.Clear(); $script:UndoApps.Clear(); $script:UndoOther.Clear()

  # power plan: Ultimate Performance (as on the main PC), else High performance
  $cur = Run-Proc -File 'powercfg.exe' -ArgLine '/getactivescheme' -TimeoutSec 30
  $curLine = [string]($cur.Lines | Select-Object -First 1)
  Say ('power plan now: ' + $curLine)
  if ($curLine -match 'Ultimate Performance|High performance') { Say 'power plan: already a performance plan' }
  else {
    $lst = Run-Proc -File 'powercfg.exe' -ArgLine '/list' -TimeoutSec 30
    $guid = ''
    foreach ($l in $lst.Lines) { if ($l -match '([0-9a-fA-F\-]{36})\s+\((Ultimate Performance)\)') { $guid = $Matches[1] } }
    if ($script:DryRun) { Dry $(if ($guid) { 'switch to the Ultimate Performance plan ' + $guid } else { 'create and switch to the Ultimate Performance plan (fallback: High performance)' }) }
    else {
      if (-not $guid) {
        $dup = Run-Proc -File 'powercfg.exe' -ArgLine '-duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61' -TimeoutSec 30
        foreach ($l in $dup.Lines) { if ($l -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') { $guid = $Matches[1] } }
      }
      if (-not $guid) { $guid = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'; Say 'Ultimate Performance is not available here; using High performance' }
      $sa = Run-Proc -File 'powercfg.exe' -ArgLine ('-setactive ' + $guid) -TimeoutSec 30
      if ($sa.ExitCode -eq 0) { Good ('power plan set: ' + $guid); [void]$script:UndoOther.Add('Power plan changed. Before: ' + $curLine) }
      else { Warn ('could not switch the power plan (code ' + $sa.ExitCode + ')'); Show-Tail $sa.Lines 3 }
    }
  }
  # never sleep, never switch the display off, never hibernate (on AC power = always, in a VM)
  foreach ($t in @('standby-timeout-ac', 'monitor-timeout-ac', 'disk-timeout-ac', 'hibernate-timeout-ac')) {
    if ($script:DryRun) { Dry ('powercfg /change ' + $t + ' 0') }
    else { $r = Run-Proc -File 'powercfg.exe' -ArgLine ('/change ' + $t + ' 0') -TimeoutSec 30; if ($r.ExitCode -ne 0) { Warn ('powercfg ' + $t + ' returned ' + $r.ExitCode) } }
  }
  Say 'sleep, display-off, disk-off and hibernate timeouts set to Never (on AC)'
  if (Test-Path -LiteralPath 'C:\hiberfil.sys') {
    $null = Do-Change 'turn hibernation off (frees the hibernation file)' { $r = Run-Proc -File 'powercfg.exe' -ArgLine '/hibernate off' -TimeoutSec 60; if ($r.ExitCode -ne 0) { throw ('powercfg code ' + $r.ExitCode) } }
  } else { Say 'hibernation: already off' }
  RegX 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0 'DWord' 'Fast Startup off'

  # background apps off (Store apps only)
  RegX 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy' 'LetAppsRunInBackground' 2 'DWord' 'Store apps do not run in the background'

  # SysMain
  if ($DisableSysMain) {
    $null = Do-Change 'stop and disable SysMain (Superfetch) because of -DisableSysMain' { Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue; Set-Service -Name SysMain -StartupType Disabled -ErrorAction Stop }
    [void]$script:UndoOther.Add('SysMain was disabled. To undo: Set-Service SysMain -StartupType Automatic; Start-Service SysMain')
  } else { Say 'SysMain: left on (the evidence for switching it off is mixed; add -DisableSysMain after measuring)' }

  # Windows Search: classic mode only indexes your profile folders, so C:\claudecode is not indexed. Mark it "not content indexed" as well.
  # (BEST EFFORT and UNVERIFIED: the supported exclusion API was not used because it could not be tested without running it.)
  if (-not (Test-Path -LiteralPath $script:DevRoot)) { Do-Change ('create ' + $script:DevRoot) { New-Item -ItemType Directory -Path $script:DevRoot -Force -ErrorAction Stop | Out-Null } | Out-Null }
  if ($script:DryRun) { Dry ('mark ' + $script:DevRoot + ' as not content indexed (attrib +I)') }
  elseif (Test-Path -LiteralPath $script:DevRoot) {
    $r = Run-Proc -File 'attrib.exe' -ArgLine ('+I ' + (Q $script:DevRoot)) -TimeoutSec 30
    if ($r.ExitCode -eq 0) { Say ('search index: ' + $script:DevRoot + ' marked not content indexed; classic search mode does not index it anyway') } else { Warn 'could not mark C:\claudecode as not indexed' }
  }

  # Defender is never touched by this script (antivirus settings are the owner's own decision).
  Say 'Defender: not touched. It stays fully on.'

  Save-Undo 'perf'
  if ($script:DryRun) { return (ResDone '(dry run) listed the performance changes') }
  return (ResDone ('performance settings applied (' + $script:RegSet + ' registry value(s) changed)'))
}


# ======================================================================================================================
# payload manifest (the exact manifest.json layout was not fixed in advance, so this reads several spellings)
# ======================================================================================================================
$script:Abort = $false
$script:AbortKeepHealth = $false
$script:Selected = @()

function ConvertTo-ManifestEntry($o, [string]$keyName) {
  if ($null -eq $o) { return $null }
  $name = ''
  $nv = Get-Prop $o @('name', 'file', 'archive', 'fileName', 'filename', 'archiveName', 'path')
  if ($nv) { $name = [string]$nv }
  if (-not $name -and $keyName) { $name = $keyName }
  if (-not $name) { return $null }
  $name = (($name -replace '\\', '/') -split '/')[-1]
  $size = 0.0
  $sv = Get-Prop $o @('size', 'bytes', 'length', 'sizeBytes', 'size_bytes')
  if ($sv) { try { $size = [double]$sv } catch { $size = 0.0 } }
  $sha = ''
  $hv = Get-Prop $o @('sha256', 'sha', 'hash', 'checksum', 'sha_256')
  if ($hv) { $sha = ([string]$hv).ToLowerInvariant() -replace '^sha-?256[:=]', ''; $sha = $sha.Trim() }
  if ($sha -and $sha -notmatch '^[0-9a-f]{64}$') { $sha = '' }
  $target = 'C:\'
  $tv = Get-Prop $o @('target', 'targetRoot', 'target_root', 'root', 'extractTo', 'extract_to', 'dest', 'destination', 'extractRoot')
  if ($tv) { $target = [string]$tv }
  $opt = $false
  $ov = Get-Prop $o @('optional')
  if ($null -ne $ov) { $opt = ([string]$ov -match '^(true|1|yes)$') }
  $grp = [string](Get-Prop $o @('group'))
  return [pscustomobject]@{ Name = $name; Path = (Join-Path $script:Payload $name); Size = $size; Sha = $sha; Target = $target; Optional = $opt; Group = $grp }
}

function Get-PayloadManifest {
  $res = [pscustomobject]@{ Found = $false; Entries = @(); Path = (Join-Path $script:Payload 'manifest.json'); Problem = ''; Final = $false; GitHead = ''; Created = ''; RepoFileList = ''; RepoFileListSha = '' }
  if (-not (Test-Path -LiteralPath $res.Path)) { return $res }
  $j = Read-JsonFile $res.Path
  if ($null -eq $j) { $res.Problem = 'manifest.json could not be read'; return $res }
  if ($j -isnot [System.Array]) {
    # written by host-push-files.ps1: final = built by a -Final run, gitHead = the commit the copied repo was at
    $fv = Get-Prop $j @('final')
    if ($null -ne $fv) { $res.Final = ([string]$fv -match '^(true|1|yes)$') }
    $gv = Get-Prop $j @('gitHead')
    if ($gv) { $res.GitHead = ([string]$gv).Trim().ToLowerInvariant() }
    $cv = Get-Prop $j @('created')
    if ($cv) { $res.Created = [string]$cv }
    $rlv = Get-Prop $j @('repoFileList')
    if ($rlv) { $res.RepoFileList = ([string]$rlv) -replace '[\\/:]', '' }
    $rsv = Get-Prop $j @('repoFileListSha256')
    if ($rsv) { $res.RepoFileListSha = ([string]$rsv).ToLowerInvariant() }
  }
  $raw = New-Object System.Collections.ArrayList
  if ($j -is [System.Array]) {
    foreach ($o in $j) { [void]$raw.Add((ConvertTo-ManifestEntry $o '')) }
  } else {
    $list = $null
    foreach ($n in @('archives', 'files', 'parts', 'entries', 'items', 'packages', 'payload')) {
      $p = $j.PSObject.Properties | Where-Object { $_.Name -ieq $n } | Select-Object -First 1
      if ($p -and $null -ne $p.Value) { $list = $p.Value; break }
    }
    if ($null -ne $list -and $list -is [System.Array]) {
      foreach ($o in $list) { [void]$raw.Add((ConvertTo-ManifestEntry $o '')) }
    } elseif ($null -eq $list -and (Get-Prop $j @('name', 'file', 'archive', 'fileName', 'filename', 'archiveName'))) {
      # a one-item array comes back from Read-JsonFile as the item itself
      [void]$raw.Add((ConvertTo-ManifestEntry $j ''))
    } else {
      $dict = $j
      if ($null -ne $list) { $dict = $list }
      foreach ($kp in $dict.PSObject.Properties) {
        if ($kp.Value -is [pscustomobject]) { [void]$raw.Add((ConvertTo-ManifestEntry $kp.Value ([string]$kp.Name))) }
      }
    }
  }
  $keep = New-Object System.Collections.ArrayList
  foreach ($e in $raw) {
    if ($null -eq $e) { continue }
    if ($e.Name -match '(?i)\.(tar|zip|tgz|tar\.gz)$' -or $e.Name -like 'gpu-driver*') { [void]$keep.Add($e) }
  }
  $res.Found = $true
  $res.Entries = $keep.ToArray()
  return $res
}

function Get-MarkerCheck([string[]]$Lines) {
  # Same rule as Get-MarkerCheck in host-common.ps1 (this script cannot load that file; keep the two identical):
  # SHA-256 (lower-case hex) over every non-empty line except the check= line, each trimmed, joined with LF.
  $keep = New-Object System.Collections.ArrayList
  foreach ($l in $Lines) {
    $t = ([string]$l).Trim()
    if (-not $t) { continue }
    if ($t -match '^check\s*=') { continue }
    [void]$keep.Add($t)
  }
  $bytes = [System.Text.Encoding]::ASCII.GetBytes(($keep -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}

function Get-MarkerInfo {
  # host-stopped.txt is written by host-stop.ps1 as key=value lines (status, computer, time, gitHead, shipLockClear, unpushedCommits, ..., check).
  # STRICT: Stopped is $true only when ALL of these hold: status is exactly "stopped", computer is present and is not this VM,
  # gitHead is a full 40-character commit id, shipLockClear is yes, the check= line matches the other lines, and no key appears twice.
  # A marker that is missing, cut short, edited by hand, glued together from two runs, or in an older format is NOT stopped; Why says what is wrong.
  $o = [pscustomobject]@{ Exists = $false; Stopped = $false; Text = ''; Status = ''; Head = ''; ShipLockClear = $null; Computer = ''; Time = ''; Unpushed = ''; Changed = ''; GpuPack = ''; Why = @() }
  $f = Join-Path $script:Kit 'host-stopped.txt'
  if (-not (Test-Path -LiteralPath $f)) { $o.Why = @('host-stopped.txt does not exist in the kit folder'); return $o }
  $o.Exists = $true
  $t = ''
  try { $t = [System.IO.File]::ReadAllText($f) } catch { }
  $o.Text = $t
  $why = New-Object System.Collections.ArrayList
  if (-not $t.Trim()) { [void]$why.Add('host-stopped.txt is empty') }
  $kv = @{}
  $dupes = New-Object System.Collections.ArrayList
  $allLines = @($t -split "`r?`n")
  foreach ($l in $allLines) {
    if ($l -match '^\s*([A-Za-z][A-Za-z0-9]*)\s*=\s*(.*?)\s*$') {
      $k = $Matches[1].ToLowerInvariant()
      if ($kv.ContainsKey($k)) { if ($dupes -notcontains $k) { [void]$dupes.Add($k) } } else { $kv[$k] = $Matches[2] }
    }
  }
  if ($dupes.Count -gt 0) { [void]$why.Add('these lines appear twice (a file glued together from two runs?): ' + ($dupes -join ', ')) }
  if ($kv.ContainsKey('status')) { $o.Status = $kv['status'].ToLowerInvariant() } else { $o.Status = 'unknown' }
  if ($kv.ContainsKey('githead') -and $kv['githead'] -match '^[0-9a-fA-F]{40}$') { $o.Head = $kv['githead'].ToLowerInvariant() }
  if ($kv.ContainsKey('shiplockclear')) {
    $v = $kv['shiplockclear'].ToLowerInvariant()
    if ($v -eq 'yes') { $o.ShipLockClear = $true } elseif ($v -eq 'no') { $o.ShipLockClear = $false }
  }
  if ($kv.ContainsKey('computer')) { $o.Computer = $kv['computer'] }
  if ($kv.ContainsKey('time')) { $o.Time = $kv['time'] }
  if ($kv.ContainsKey('unpushedcommits')) { $o.Unpushed = $kv['unpushedcommits'] }
  if ($kv.ContainsKey('changedfiles')) { $o.Changed = $kv['changedfiles'] }
  if ($kv.ContainsKey('gpupack')) { $o.GpuPack = $kv['gpupack'] }
  if ($o.Status -ne 'stopped') { [void]$why.Add('the status line says "' + $o.Status + '" (it must say exactly stopped)') }
  if (-not $o.Computer) { [void]$why.Add('there is no computer= line') }
  elseif ($o.Computer -ieq $env:COMPUTERNAME) { [void]$why.Add('the marker names THIS computer (' + $o.Computer + '); it must come from the main PC') }
  if (-not $o.Head) { [void]$why.Add('there is no full 40-character gitHead= line') }
  if ($o.ShipLockClear -ne $true) { [void]$why.Add('the marker does not say shipLockClear=yes') }
  if (-not $kv.ContainsKey('check')) { [void]$why.Add('there is no check= line (older host-stop.ps1, or the file was cut short): run host-stop.ps1 again and push again') }
  elseif ($kv['check'].ToLowerInvariant() -ne (Get-MarkerCheck $allLines)) { [void]$why.Add('the check= line does not match the other lines (edited by hand, cut short, or copied half-written)') }
  $o.Why = $why.ToArray()
  $o.Stopped = ($why.Count -eq 0)
  return $o
}

function Show-MarkerFacts {
  $mk = Get-MarkerInfo
  if (-not $mk.Exists) { return }
  Say ('host-stopped.txt: status ' + $(if ($mk.Status) { $mk.Status } else { '(none)' }) + $(if ($mk.Computer) { ', written on ' + $mk.Computer } else { '' }) + $(if ($mk.Time) { ' at ' + $mk.Time } else { '' }))
  if ($mk.Status -eq 'revoked') { Warn 'The marker says the main PC is RUNNING AGAIN (status revoked). The services stage will refuse until the host is stopped again and the kit is pushed again.' }
  elseif (-not $mk.Stopped) { foreach ($w in @($mk.Why)) { Warn ('host-stopped.txt is not accepted: ' + $w) } }
  if ($mk.Head) { Say ('   main PC repo commit at stop: ' + $mk.Head.Substring(0, [math]::Min(12, $mk.Head.Length))) }
  if ($mk.Unpushed -match '^\d+$' -and [int]$mk.Unpushed -gt 0) { Say ('   ' + $mk.Unpushed + ' commit(s) were not on GitHub yet; they travel inside the copied .git') }
  if ($mk.Changed -match '^\d+$' -and [int]$mk.Changed -gt 0) { Say ('   ' + $mk.Changed + ' changed file(s) in the working tree at stop; they travel in the copied files') }
  if ($mk.GpuPack -and $mk.GpuPack -ne 'ok') { Warn ('the host reports the GPU pack as: ' + $mk.GpuPack) }
}

function Test-KitManifest {
  $mf = Join-Path $script:Kit 'kit-manifest.json'
  if (-not (Test-Path -LiteralPath $mf)) { Say 'kit: no kit-manifest.json (the kit files cannot be checked for damage)'; return }
  $j = Read-JsonFile $mf
  if ($null -eq $j) { return }
  $ok = 0; $bad = 0; $miss = 0
  foreach ($f in @($j.files)) {
    $rel = [string](Get-Prop $f @('path', 'name'))
    if (-not $rel) { continue }
    $p = Join-Path $script:Kit $rel
    if (-not (Test-Path -LiteralPath $p)) { $miss++; Warn ('kit file is missing: ' + $rel); continue }
    $want = [string](Get-Prop $f @('sha256', 'sha', 'hash'))
    if (-not $want) { continue }
    $h = ''
    try { $h = Get-FileSha256 $p } catch { }
    if ($h -and $h -eq $want.ToLowerInvariant()) { $ok++ } else { $bad++; Warn ('kit file differs from the pushed copy (changed or damaged): ' + $rel) }
  }
  Say ('kit check against kit-manifest.json: ' + $ok + ' match, ' + $bad + ' differ, ' + $miss + ' missing')
}

# ======================================================================================================================
# archive checks: fast scan of the member list (C# so a million names take seconds)
# ======================================================================================================================
function Initialize-ScanType {
  if ('PilScan' -as [type]) { return }
  Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
public class PilScanResult {
  public long Total;
  public long Files;
  public long SecretCount;
  public long UnsafeCount;
  public long OutsideCount;
  public long RepoCount;
  public long MainRepoCount;
  public long ProfileCount;
  public List<string> Secrets = new List<string>();
  public List<string> Unsafe = new List<string>();
  public List<string> Outside = new List<string>();
  public List<string> Sample = new List<string>();
}
public static class PilScan {
  public static PilScanResult Run(string listFile, string strict, string loose, string[] okPrefixes, int keep, int sampleEvery) {
    PilScanResult r = new PilScanResult();
    Regex rs = new Regex(strict, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
    Regex rl = new Regex(loose, RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);
    Regex ru = new Regex(@"(^/)|(^|/)\.\.(/|$)|:|[\x00-\x1f]", RegexOptions.CultureInvariant);
    long fileNo = 0;
    using (StreamReader sr = new StreamReader(listFile, Encoding.UTF8)) {
      string line;
      while ((line = sr.ReadLine()) != null) {
        if (line.Length == 0) continue;
        string n = line.Replace('\\', '/');
        if (n.StartsWith("./")) n = n.Substring(2);
        r.Total++;
        if (ru.IsMatch(n)) { r.UnsafeCount++; if (r.Unsafe.Count < keep) r.Unsafe.Add(n); continue; }
        bool ok = false;
        foreach (string p in okPrefixes) {
          if (n.StartsWith(p, StringComparison.OrdinalIgnoreCase) || (n + "/").Equals(p, StringComparison.OrdinalIgnoreCase)) { ok = true; break; }
        }
        if (!ok) { r.OutsideCount++; if (r.Outside.Count < keep) r.Outside.Add(n); continue; }
        bool secret = rs.IsMatch(n);
        if (!secret && n.IndexOf("/node_modules/", StringComparison.OrdinalIgnoreCase) < 0 && n.IndexOf("/.git/", StringComparison.OrdinalIgnoreCase) < 0) secret = rl.IsMatch(n);
        if (secret) { r.SecretCount++; if (r.Secrets.Count < keep) r.Secrets.Add(n); continue; }
        if (n.StartsWith("claudecode/", StringComparison.OrdinalIgnoreCase)) r.RepoCount++;
        if (n.StartsWith("claudecode/dark raiders/", StringComparison.OrdinalIgnoreCase)) r.MainRepoCount++;
        if (n.StartsWith("Users/", StringComparison.OrdinalIgnoreCase)) r.ProfileCount++;
        if (!n.EndsWith("/")) {
          r.Files++;
          fileNo++;
          if (r.Sample.Count < 400 && (fileNo <= 20 || fileNo % sampleEvery == 0)) r.Sample.Add(n);
        }
      }
    }
    return r;
  }
}
'@
}

# names that must never be unpacked from a payload (names only; values are never read). Strict = everywhere. Loose = not inside node_modules or .git.
$script:SecretStrict = '(^|/)(' + (@(
  '\.codex/auth\.json',
  '\.codex/[^/]*(token|credential|secret)[^/]*',
  '\.claude/\.credentials\.json',
  '\.claude\.json',
  '\.claude\.json\.backup[^/]*',
  '\.git-credentials',
  '\.gemini/(oauth_creds\.json|google_accounts\.json|mcp-oauth-tokens[^/]*|[^/]*token[^/]*)',
  '\.config/gh/hosts\.yml',
  '\.ssh/.*',
  '\.aws/(credentials|config)',
  '\.azure/.*',
  '\.npmrc',
  '\.pypirc',
  '\.netrc',
  '_netrc',
  'oauth[_-]?creds?[^/]*',
  'google_accounts\.json',
  '[^/]*service[_-]?account[^/]*\.json',
  '[^/]*\.(p12|pfx|ppk|kdbx|jks|keystore|gpg|pgp)',
  '\.docker/config\.json',
  '\.kube/config',
  'butler_creds',
  'Local State',
  '(Cookies|Login Data|Web Data)(-journal)?',
  'id_(rsa|dsa|ecdsa|ed25519)',
  'AppData/(Local|Roaming)/Microsoft/(Credentials|Protect|Vault|Crypto)/.*',
  'AppData/Local/(Google/Chrome|Microsoft/Edge|BraveSoftware|Chromium|Vivaldi)[^/]*/User Data/.*',
  'AppData/Roaming/Mozilla/Firefox/Profiles/[^/]+/(logins\.json|key[34]\.db|cookies\.sqlite|formhistory\.sqlite)',
  'AppData/[^/]+/(agy|antigravity)/[^\n]*(oauth|token|credential|session|auth)[^/]*',
  '(Default|Profile [^/]+)/(Login Data[^/]*|Web Data[^/]*|Account Web Data[^/]*|Sync Data/.*|Network/Cookies[^/]*|Cookies[^/]*)'
) -join '|') + ')$'
$script:SecretLoose = '(^|/)(' + (@(
  '\.env(\.(?!example$|sample$|template$|dist$)[^/]*)?',
  'ai-keys[^/]*\.(json|txt|env|dat|xml|ini|cfg|key|clixml)',
  '(secrets?|credentials?|auth|passwords?)\.(json|ya?ml|txt|ini|env|dat|xml|clixml)',
  '(access|refresh|auth|api|bearer)?[_-]?tokens?\.(json|ya?ml|txt)',
  '[^/]*(api[-_]?key|apikey)[^/]*\.(txt|json|env|key|dat|ini|xml|clixml|ya?ml)',
  '[^/]*\.(pfx|p12|ppk|kdbx|pem|key)'
) -join '|') + ')$'

function Escape-TarPattern([string]$s) {
  return ($s -replace '([\\\[\]\*\?])', '\$1')
}

# like Run-Proc, but prints a "still working" line every minute (long unpacks) and can keep the output files
function Run-ProcBeat {
  param([string]$File, [string]$ArgLine = '', [int]$TimeoutSec = 3600, [string]$Label = 'working', [int]$BeatSec = 60, [string]$WorkingDirectory = '', [switch]$KeepFiles)
  Ensure-Dir $script:WorkDir
  $id = [guid]::NewGuid().ToString('N')
  $of = Join-Path $script:WorkDir ($id + '.out')
  $ef = Join-Path $script:WorkDir ($id + '.err')
  $nf = Join-Path $script:WorkDir 'empty-stdin.txt'
  if (-not (Test-Path -LiteralPath $nf)) { try { Set-Content -LiteralPath $nf -Value '' -Encoding ASCII } catch { } }
  $sp = @{ FilePath = $File; NoNewWindow = $true; PassThru = $true; RedirectStandardOutput = $of; RedirectStandardError = $ef; RedirectStandardInput = $nf }
  if ($ArgLine) { $sp['ArgumentList'] = $ArgLine }
  if ($WorkingDirectory) { $sp['WorkingDirectory'] = $WorkingDirectory }
  $t0 = Get-Date
  $timedOut = $false
  $code = -1
  $errText = ''
  try {
    $p = Start-Process @sp -ErrorAction Stop
    $null = $p.Handle
    while (-not $p.WaitForExit($BeatSec * 1000)) {
      $min = [int]((Get-Date) - $t0).TotalMinutes
      Say ($Label + ' ... still going (' + $min + ' min)')
      if (((Get-Date) - $t0).TotalSeconds -gt $TimeoutSec) {
        $timedOut = $true
        try { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null } catch { }
        break
      }
    }
    if (-not $timedOut) { $p.WaitForExit(); $code = $p.ExitCode }
  } catch { $errText = $_.Exception.Message }
  $errLines = @()
  $outLines = @()
  if (-not $KeepFiles) {
    $outLines = Clean-Lines @(Read-TextFileSafe $of)
    $errLines = Clean-Lines @(Read-TextFileSafe $ef)
    Remove-Item -LiteralPath $of, $ef -Force -ErrorAction SilentlyContinue
  } else {
    $errLines = Clean-Lines @(Read-TextFileSafe $ef)
  }
  if ($errText) { $errLines = @($errLines) + @('start failed: ' + $errText) }
  return [pscustomobject]@{ ExitCode = $code; TimedOut = $timedOut; Lines = (@($outLines) + @($errLines)); ErrLines = $errLines; OutFile = $of; ErrFile = $ef }
}

function Map-ToReal([string]$p) {
  if (-not $script:IsUser1 -and $p.StartsWith($script:MirrorProfile, [StringComparison]::OrdinalIgnoreCase)) {
    return ($script:VmProfile.TrimEnd('\') + $p.Substring($script:MirrorProfile.Length))
  }
  return $p
}
function Entry-TargetPath([string]$name) {
  $n = $name.Replace('\', '/')
  if ($n.StartsWith('./')) { $n = $n.Substring(2) }
  $full = 'C:\' + ($n -replace '/', '\')
  return (Map-ToReal $full)
}

function Get-RepoDirtyCount {
  if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot '.git'))) { return -1 }
  $r = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'status', '--porcelain') -TimeoutSec 180
  if ($r.ExitCode -ne 0) { return -1 }
  return @($r.Lines).Count
}

# A short fingerprint of the VM repo: HEAD plus a SHA-256 of "git status --porcelain" (sorted). Ok is $false when git cannot read the repo.
function Get-RepoFingerprint {
  $r = [pscustomobject]@{ Ok = $false; Head = ''; StatusSha = ''; Count = -1 }
  if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot '.git'))) { return $r }
  if (-not (Find-GitExe)) { return $r }
  $h = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'rev-parse', 'HEAD') -TimeoutSec 60
  if ($h.ExitCode -ne 0) { return $r }
  $st = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'status', '--porcelain') -TimeoutSec 600
  if ($st.ExitCode -ne 0 -or $st.TimedOut) { return $r }
  $lines = @($st.Lines | Where-Object { $_ -match '^[ MADRCUT?!]{2} ' } | Sort-Object)
  $bytes = [System.Text.Encoding]::ASCII.GetBytes(($lines -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $hash = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
  $r.Head = ([string]($h.Lines | Select-Object -First 1)).Trim().ToLowerInvariant()
  $r.StatusSha = (($hash | ForEach-Object { $_.ToString('x2') }) -join '')
  $r.Count = $lines.Count
  $r.Ok = ($r.Head -match '^[0-9a-f]{40}$')
  return $r
}

function Short-Id([string]$s) { if ($s.Length -gt 12) { return $s.Substring(0, 12) }; return $s }
function Get-RepoBaselinePath { return (Join-Path $script:StateDir 'repo-baseline.json') }

# remembers what the repo looked like right after THIS script unpacked into it; the next unpack compares against it
function Save-RepoBaseline([string]$why) {
  if ($script:DryRun) { return }
  $fp = Get-RepoFingerprint
  Write-JsonFile (Get-RepoBaselinePath) ([pscustomobject]@{ Ok = $fp.Ok; Head = $fp.Head; StatusSha = $fp.StatusSha; Count = $fp.Count; Written = (Get-Date).ToString('s'); Why = $why })
  if ($fp.Ok) { Say ('remembered the VM repo as unpacked: commit ' + $fp.Head.Substring(0, 12) + ', ' + $fp.Count + ' changed file(s). The next unpack is allowed only while the repo is still exactly like this.') }
  else { Warn 'git could not read the VM repo after unpacking, so the next unpack has nothing exact to compare with.' }
}

# Is it safe to unpack the repo archives over the repo that is already in the VM? Decided ONCE per run, before this run touches the repo,
# and reused for every repo archive (repo-01, repo-02, git, ...), so a later archive can never extract over a repo the first one refused.
# Rule: allowed when the repo is exactly as this script left it last time (same HEAD, same changed-file list), or when it has no changes at all and
# this script never unpacked into it. Otherwise the VM holds its own work and nothing is overwritten.
$script:RepoVerdict = $null
$script:RepoForceWarned = $false
function Get-RepoVerdict {
  if ($null -ne $script:RepoVerdict) { return $script:RepoVerdict }
  $v = [pscustomobject]@{ Allowed = $false; Why = '' }
  $cur = Get-RepoFingerprint
  $base = Read-JsonFile (Get-RepoBaselinePath)
  if ($base) {
    if ($cur.Ok -and [bool]$base.Ok) {
      if (($cur.Head -eq [string]$base.Head) -and ($cur.StatusSha -eq [string]$base.StatusSha)) { $v.Allowed = $true; $v.Why = 'the VM repo is exactly as the last unpack left it' }
      else {
        $parts = @()
        if ($cur.Head -ne [string]$base.Head) { $parts += ('its commit changed (' + ([string]$base.Head).Substring(0, 12) + ' -> ' + $cur.Head.Substring(0, 12) + '): commits were made in the VM') }
        if ($cur.StatusSha -ne [string]$base.StatusSha) { $parts += ('its list of changed files is different (' + [string]$base.Count + ' at the last unpack, ' + $cur.Count + ' now): files were edited, added or deleted in the VM') }
        $v.Why = 'the VM repo is no longer as the last unpack left it - ' + ($parts -join '; ')
      }
    } elseif ((-not $cur.Ok) -and (-not [bool]$base.Ok)) { $v.Allowed = $true; $v.Why = 'git could not read the repo at the last unpack either (a half copy), so there is nothing of yours to lose' }
    elseif ($cur.Ok -and $cur.Count -eq 0) { $v.Allowed = $true; $v.Why = 'the VM repo has no changes' }
    else { $v.Why = 'git can no longer read the VM repo (it could at the last unpack), or it could not then and has changes now' }
  } else {
    if ($cur.Ok -and $cur.Count -eq 0) { $v.Allowed = $true; $v.Why = 'the VM repo has no changes and this script never unpacked into it' }
    elseif ($cur.Ok) { $v.Why = 'the VM repo has ' + $cur.Count + ' changed or new file(s) and this script has not unpacked into it before, so they are somebody''s own work' }
    else { $v.Why = 'there is a repo folder in the VM that git cannot read, and this script has not unpacked into it before' }
  }
  $script:RepoVerdict = $v
  return $v
}

# Everything that must be true before the runner, helpers or the scheduled runner task may start (services stage, and the live mode of the health sweep).
function Test-ServicesAllowed {
  $why = New-Object System.Collections.ArrayList
  $mk = Get-MarkerInfo
  if (-not $mk.Exists) { [void]$why.Add('host-stopped.txt is not in ' + $script:Kit + ' (host-stop.ps1 on the main PC writes it and host-push-files.ps1 -Final sends it)') }
  elseif ($mk.Status -eq 'revoked') { [void]$why.Add('host-stopped.txt says the main PC Pillagers is running again (status revoked)') }
  elseif (-not $mk.Stopped) { foreach ($w in @($mk.Why)) { [void]$why.Add('host-stopped.txt is not accepted: ' + $w) } }
  if ($script:FilesFailed) { [void]$why.Add('the files stage failed in this run, so the copied files may be half-unpacked') }
  $man = Get-PayloadManifest
  if (-not $man.Found) { [void]$why.Add('payload\manifest.json is missing or unreadable, so nobody can say which copy of the files is in the VM') }
  else {
    if (-not $man.Final) { [void]$why.Add('the copied files are a FIRST-PASS copy (manifest.json says final=false). On the main PC run host-stop.ps1, then host-push-files.ps1 -Final; then here: vm-setup.ps1 -Only files,services,health') }
    if ($mk.Head -and $man.GitHead -and ($man.GitHead -ne $mk.Head)) { [void]$why.Add('the copied files were built at commit ' + (Short-Id $man.GitHead) + ' but host-stopped.txt names ' + $mk.Head.Substring(0, 12) + ' (the files and the marker come from different moments; push again with -Final)') }
    $state = Read-JsonFile (Join-Path $script:StateDir 'files-done.json')
    foreach ($e in @($man.Entries)) {
      if ($e.Name -like 'gpu-driver*') { continue }
      if ($e.Optional) { continue }
      $rec = $null
      if ($state) { $rec = $state.PSObject.Properties | Where-Object { $_.Name -ieq $e.Name } | Select-Object -First 1 }
      if (-not $rec) { [void]$why.Add('the archive ' + $e.Name + ' has not been unpacked yet (run: vm-setup.ps1 -Only files)'); continue }
      if (-not $e.Sha) { [void]$why.Add($e.Name + ' has no fingerprint in the manifest, so "unpacked and unchanged" cannot be shown'); continue }
      if ([string]$rec.Value.Sha -ne $e.Sha) { [void]$why.Add($e.Name + ' was unpacked from a different copy than the one in the payload now (run: vm-setup.ps1 -Only files)') }
    }
  }
  if ($mk.Head) {
    $h = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'rev-parse', 'HEAD') -TimeoutSec 60
    if ($h.ExitCode -ne 0) { [void]$why.Add('git cannot read the VM repo at ' + $script:RepoRoot) }
    else {
      $hv = ([string]($h.Lines | Select-Object -First 1)).Trim().ToLowerInvariant()
      if ($hv -ne $mk.Head) {
        $anc = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'merge-base', '--is-ancestor', $mk.Head, 'HEAD') -TimeoutSec 60
        if ($anc.ExitCode -ne 0) { [void]$why.Add('the VM repo is at commit ' + $hv.Substring(0, [math]::Min(12, $hv.Length)) + ', which does not include the commit in host-stopped.txt (' + $mk.Head.Substring(0, 12) + '). The wrong or an old copy of the repo is in the VM.') }
      }
    }
  }
  return [pscustomobject]@{ Ok = ($why.Count -eq 0); Why = $why.ToArray() }
}

# Reports (never deletes) files in the VM repo that the FINAL copy from the main PC does not contain: leftovers from the first pass,
# or files made in the VM. The list is payload\repo-files.txt (written by host-push-files.ps1); the answer goes to state\extra-files.txt.
$script:RxLeftOut = '^(tools/migrate/(logs/|state/|out/|host-stopped\.txt$|host-apps\.json$|gpu-pack-manifest\.json$|kit-manifest\.json$|pillagers-runner-task\.xml$|start-layout\.json$)|tools/handoff/console/lane-[^/]+\.lock(/|$)|tools/handoff/console/pick\.lock(/|$)|tools/handoff/console/STOP$|tools/handoff/codex/STOP$|tools/handoff/stable\.freeze$|tools/handoff/(nightly/)?runner\.heartbeat$|\.claude/scheduled_tasks\.(lock|json)$)|(^|/)node_modules/|\.pid$|(^|/)\.git/'
function Report-ExtraFiles($man) {
  if (-not $man.Found -or -not $man.Final) { return }
  if (-not $man.RepoFileList) { Say 'leftover-file report: skipped (the manifest has no file list; the main PC push is from an older host-push-files.ps1)'; return }
  $lf = Join-Path $script:Payload $man.RepoFileList
  if (-not (Test-Path -LiteralPath $lf)) { Warn ('leftover-file report: skipped (' + $lf + ' was not copied)'); return }
  if ($man.RepoFileListSha) {
    $hh = ''
    try { $hh = Get-FileSha256 $lf } catch { }
    if ($hh -ne $man.RepoFileListSha) { Warn 'leftover-file report: skipped (the file list does not match its fingerprint)'; return }
  }
  $want = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($l in [System.IO.File]::ReadAllLines($lf)) { $t = $l.Trim(); if ($t) { [void]$want.Add($t) } }
  $a = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'ls-files', '-c', '-o', '--exclude-standard') -TimeoutSec 900
  $d = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'ls-files', '-d') -TimeoutSec 900
  if ($a.ExitCode -ne 0 -or $d.ExitCode -ne 0) { Warn 'leftover-file report: skipped (git could not list the VM repo files)'; return }
  $gone = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
  foreach ($l in @($d.Lines)) { [void]$gone.Add([string]$l) }
  $extras = New-Object System.Collections.ArrayList
  foreach ($l in @($a.Lines)) {
    $f = [string]$l
    if ($gone.Contains($f) -or $want.Contains($f)) { continue }
    if ($f -match $script:RxLeftOut) { continue }
    [void]$extras.Add($f)
  }
  $outFile = Join-Path $script:StateDir 'extra-files.txt'
  try { [System.IO.File]::WriteAllLines($outFile, [string[]]$extras.ToArray(), [System.Text.Encoding]::ASCII) } catch { }
  if ($extras.Count -eq 0) { Good ('leftover-file report: the VM repo has no file that is missing from the final copy (' + $want.Count + ' files listed by the main PC)'); return }
  Warn ('leftover-file report: ' + $extras.Count + ' file(s) in the VM repo are NOT in the final copy from the main PC (left over from the first pass, or made in the VM). Nothing was deleted. Full list: ' + $outFile)
  foreach ($f in @($extras | Select-Object -First 25)) { Say ('     extra: ' + $f) }
  Say '   Look at them. Delete the ones you do not want BEFORE the first ship, because a ship commits everything it finds (git add -A).'
}

function Ensure-GitSafe {
  $roots = @($script:RepoRoot, $script:CodexTree) | Where-Object { Test-Path -LiteralPath $_ }
  $g = Find-GitExe
  if (-not $g) { Warn 'git is not installed yet, so the "safe directory" entries are not set. Run the apps stage, then: vm-setup.ps1 -Only files'; return }
  $have = Invoke-Git -GitArgs @('config', '--global', '--get-all', 'safe.directory') -TimeoutSec 30
  foreach ($r in $roots) {
    $fwd = $r.Replace('\', '/')
    if (@($have.Lines) -contains $fwd) { Say ('git already trusts ' + $fwd); continue }
    $null = Do-Change ('tell git that ' + $fwd + ' is a safe folder (the files were unpacked by an elevated window)') {
      $x = Invoke-Git -GitArgs @('config', '--global', '--add', 'safe.directory', $fwd) -TimeoutSec 30
      if ($x.ExitCode -ne 0) { throw ('git config returned ' + $x.ExitCode) }
    }
  }
  if ($script:DryRun) { return }
  foreach ($r in $roots) {
    $t = Invoke-Git -GitArgs @('-C', $r, 'rev-parse', 'HEAD') -TimeoutSec 60
    if ($t.ExitCode -ne 0 -and (($t.Lines -join ' ') -match 'dubious')) {
      Say ('git still reports a different owner for ' + $r + '; handing the folder to ' + $script:UserFull)
      $null = Run-Proc -File 'icacls.exe' -ArgLine ((Q $r) + ' /setowner ' + (Q $script:UserFull) + ' /C /Q') -TimeoutSec 300
      $gd = Join-Path $r '.git'
      if (Test-Path -LiteralPath $gd -PathType Container) { $null = Run-Proc -File 'icacls.exe' -ArgLine ((Q $gd) + ' /setowner ' + (Q $script:UserFull) + ' /T /C /Q') -TimeoutSec 900 }
      $t = Invoke-Git -GitArgs @('-C', $r, 'rev-parse', 'HEAD') -TimeoutSec 60
    }
    if ($t.ExitCode -ne 0) { Warn ('git cannot read ' + $r + ' : ' + (($t.Lines | Select-Object -First 2) -join ' / ')) }
  }
}

function Restore-CodexWorktree {
  $W = $script:CodexTree
  $R = $script:RepoRoot
  if (-not (Test-Path -LiteralPath (Join-Path $R '.git'))) { return }
  if (-not (Find-GitExe)) { return }
  if (Test-Path -LiteralPath (Join-Path $W '.git')) {
    $t = Invoke-Git -GitArgs @('-C', $W, 'rev-parse', '--short', 'HEAD') -TimeoutSec 60
    if ($t.ExitCode -eq 0) { Say ('codex worktree: ok at ' + ($t.Lines | Select-Object -First 1)); return }
    Warn ('codex worktree at ' + $W + ' exists but git cannot use it: ' + (($t.Lines | Select-Object -First 2) -join ' / '))
    return
  }
  $aside = ''
  if (Test-Path -LiteralPath $W) {
    $kids = @(Get-ChildItem -LiteralPath $W -Force -ErrorAction SilentlyContinue)
    $onlyWork = (@($kids | Where-Object { $_.Name -ne '.codex-work' }).Count -eq 0)
    if ($kids.Count -gt 0 -and -not $onlyWork) { Warn ($W + ' has files but is not a git worktree. Left alone. To rebuild it: move that folder away and run: bash tools/codex-lane.sh --setup'); return }
    if ($kids.Count -gt 0) { $aside = $W + '.codex-work-aside' }
  }
  $null = Do-Change 'rebuild the Codex helper worktree (git worktree add) because it is missing' {
    if ($aside) { Move-Item -LiteralPath (Join-Path $W '.codex-work') -Destination $aside -Force -ErrorAction Stop; Remove-Item -LiteralPath $W -Force -ErrorAction SilentlyContinue }
    $x = Invoke-Git -GitArgs @('-C', $R, 'worktree', 'prune') -TimeoutSec 120
    $y = Invoke-Git -GitArgs @('-C', $R, 'worktree', 'add', '--detach', $W, 'master') -TimeoutSec 600
    if ($y.ExitCode -ne 0) { throw ('git worktree add returned ' + $y.ExitCode + ': ' + (($y.Lines | Select-Object -Last 2) -join ' / ')) }
    if ($aside -and (Test-Path -LiteralPath $aside)) { Move-Item -LiteralPath $aside -Destination (Join-Path $W '.codex-work') -Force -ErrorAction SilentlyContinue }
  }
}

function Copy-ClaudeMemory {
  $src = Join-Path $script:VmProfile ('.claude\projects\' + $script:KeyDesktop + '\memory')
  $dst = Join-Path $script:VmProfile ('.claude\projects\' + $script:KeyRepo + '\memory')
  if (-not (Test-Path -LiteralPath $src)) { Say 'Claude memory: none in the unpacked profile (nothing to copy)'; return }
  Say ('Claude memory is in the same place as on the main PC (project folder ' + $script:KeyDesktop + '); the helper lanes read it from there.')
  if (Test-Path -LiteralPath (Join-Path $dst 'MEMORY.md')) { Say 'Claude memory: the repo-folder copy already exists, left alone'; return }
  $null = Do-Change ('copy the Claude memory to the project folder for C:\claudecode\dark raiders too (' + $script:KeyRepo + '), so Claude Code opened inside the repo sees it') {
    $r = Run-Proc -File 'robocopy.exe' -ArgLine ((Q $src) + ' ' + (Q $dst) + ' /E /XO /R:1 /W:1 /NFL /NDL /NJH /NP') -TimeoutSec 300
    if ($r.ExitCode -ge 8) { throw ('robocopy returned ' + $r.ExitCode) }
  }
}

function Test-RemoteHasEmbeddedLogin {
  if (-not (Find-GitExe)) { return }
  foreach ($r in @($script:RepoRoot, $script:CodexTree)) {
    if (-not (Test-Path -LiteralPath (Join-Path $r '.git'))) { continue }
    $x = Invoke-Git -GitArgs @('-C', $r, 'config', '--get-regexp', '^remote\..*\.url$') -TimeoutSec 30
    foreach ($l in @($x.Lines)) {
      if ($l -match '://[^/\s@]+@') { Warn ('a git remote in ' + $r + ' has a login embedded in its web address (the address is NOT printed). Fix it with: git remote set-url origin <plain https address>   and sign in to GitHub when asked.') ; break }
    }
  }
}

# ======================================================================================================================
# STAGE files : check, scan and unpack the payload archives to the same absolute paths as on the main PC
# ======================================================================================================================
function Stage-files {
  Ensure-Dir $script:StateDir
  Ensure-Dir $script:WorkDir
  $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
  if (-not (Test-Path -LiteralPath $tar)) { return (ResFail 'tar.exe is missing from Windows (System32\tar.exe), so archives cannot be unpacked. Update Windows or install 7-Zip and unpack by hand.') }
  $man = Get-PayloadManifest
  $entries = @()
  if ($man.Found) { $entries = @($man.Entries | Where-Object { $_.Name -notlike 'gpu-driver*' }) }
  else {
    if ($man.Problem) { Warn $man.Problem }
    if (-not $Force) { return (ResFail 'payload\manifest.json is missing (or unreadable), so the archives cannot be checked. Run host-push-files.ps1 again on the main PC (it writes the manifest). To unpack without a check anyway, add -Force.') }
    Warn 'No manifest.json: unpacking every payload\pillagers-*.tar/.zip WITHOUT a size or fingerprint check (-Force).'
    $entries = @(Get-ChildItem -LiteralPath $script:Payload -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^pillagers-.*\.(tar|zip)$' } | ForEach-Object {
      [pscustomobject]@{ Name = $_.Name; Path = $_.FullName; Size = [double]$_.Length; Sha = ''; Target = 'C:\' } })
  }
  if ($entries.Count -eq 0) { return (ResSkip 'there are no pillagers-*.tar or .zip archives listed in the payload (nothing to unpack). Run host-push-files.ps1 on the main PC first.') }

  Ensure-Dir $script:DevRoot
  if (-not $script:IsUser1) {
    Say ('The VM user is ' + $script:UserFull + ' with profile ' + $script:VmProfile + '. Profile files go into that profile, and C:\Users\User1 becomes a link to it.')
    if (-not (Ensure-UserJunction)) { Warn 'The C:\Users\User1 link could not be made, so scripts that name C:\Users\User1 will not find your profile files.' }
  }

  $state = Read-JsonFile (Join-Path $script:StateDir 'files-done.json')
  $stateMap = [ordered]@{}
  if ($state) { foreach ($p in $state.PSObject.Properties) { $stateMap[$p.Name] = $p.Value } }
  $marker = Get-MarkerInfo
  $script:RepoVerdict = $null
  $script:RepoForceWarned = $false

  $okList = New-Object System.Collections.ArrayList
  $skipList = New-Object System.Collections.ArrayList
  $failList = New-Object System.Collections.ArrayList
  $secretsTotal = 0
  $repoTouched = $false
  $repoPreexisting = (Test-Path -LiteralPath (Join-Path $script:RepoRoot '.git'))
  $repoAttempted = $false
  if ($repoPreexisting) { Ensure-GitSafe }
  Initialize-ScanType
  if ($script:DryRun -and $repoPreexisting) {
    $rv0 = Get-RepoVerdict
    if ($rv0.Allowed) { Dry ('the repo already in the VM would be overwritten by the repo archives: ' + $rv0.Why) } else { Warn ('a real run would REFUSE to unpack the repo archives: ' + $rv0.Why) }
  }

  foreach ($e in $entries) {
    Blank
    Say ('archive ' + $e.Name + '  (' + (Fmt-GB $e.Size) + ' listed)')
    if (-not (Test-Path -LiteralPath $e.Path)) { Bad ($e.Name + ' is not in ' + $script:Payload + ' (not copied yet?)'); [void]$failList.Add($e.Name + ': file missing'); continue }
    $it = Get-Item -LiteralPath $e.Path
    if ($e.Size -gt 0 -and [math]::Abs($it.Length - $e.Size) -gt 0.5) {
      Bad ($e.Name + ' is ' + $it.Length + ' bytes but the manifest says ' + [int64]$e.Size + '. The copy is incomplete or changed.')
      [void]$failList.Add($e.Name + ': size does not match the manifest'); continue
    }
    $tgt = [string]$e.Target
    if ($tgt -and ($tgt.TrimEnd('\', '/') -ine 'C:')) { Warn ('manifest says target root "' + $tgt + '" for ' + $e.Name + '; this script only unpacks to the C: drive root, so that is what is used.') }

    $prev = $null
    if ($stateMap.Contains($e.Name)) { $prev = $stateMap[$e.Name] }
    if ($prev -and -not $Force) {
      $sameSha = ($e.Sha -and ([string]$prev.Sha -eq $e.Sha))
      $sameNoSha = ((-not $e.Sha) -and ([double]$prev.Size -eq [double]$it.Length) -and ([string]$prev.Stamp -eq [string]$it.LastWriteTimeUtc.Ticks))
      if ($sameSha -or $sameNoSha) {
        Say ('already unpacked on ' + [string]$prev.ExtractedAt + ' (same archive). Skipping, so work done in the VM since then is not overwritten. -Force unpacks again.')
        [void]$skipList.Add($e.Name); continue
      }
    }

    $free = 0
    try { $free = (Get-PSDrive -Name C -ErrorAction Stop).Free } catch { }
    $factor = 1.3
    if ($e.Name -match '(?i)\.zip$') { $factor = 2.5 }
    $needB = [double]$it.Length * $factor + 1GB
    if ($free -gt 0 -and $free -lt $needB) {
      if ($Force) { Warn ('free space ' + (Fmt-GB $free) + ' is below the ' + (Fmt-GB $needB) + ' estimated for this archive; continuing because of -Force') }
      else { Bad ('not enough free space on C: (' + (Fmt-GB $free) + ' free, about ' + (Fmt-GB $needB) + ' needed). Grow the VM disk or free space, then run again.'); [void]$failList.Add($e.Name + ': not enough disk space'); continue }
    }

    if ($script:DryRun) {
      Dry ('check the fingerprint of ' + $e.Name + ($(if ($e.Sha) { '' } else { ' (the manifest has none, so size only)' })))
      Dry ('list its members, refuse paths outside C:\claudecode and C:\Users\User1, leave out any secret-looking file names, and unpack with tar.exe to C:\'); if ($e.Name -match '(?i)repo|git') { Dry ('if a repo archive lands on an existing repo: clear the read-only flag inside ' + $script:RepoRoot + '\.git (attrib -R) first, and refuse when the VM repo has its own unsent work') }
      [void]$okList.Add($e.Name); continue
    }

    if ($e.Sha) {
      Say ('checking the fingerprint (SHA-256) of ' + $e.Name + ' ...')
      $h = ''
      try { $h = Get-FileSha256 $e.Path } catch { Bad ('could not read ' + $e.Name + ' - ' + $_.Exception.Message); [void]$failList.Add($e.Name + ': unreadable'); continue }
      if ($h -ne $e.Sha) { Bad ($e.Name + ' is damaged: its fingerprint is ' + $h.Substring(0, 12) + '... but the manifest says ' + $e.Sha.Substring(0, 12) + '... Push it again from the main PC.'); [void]$failList.Add($e.Name + ': fingerprint mismatch'); continue }
      Good 'fingerprint matches'
    } else { Warn ($e.Name + ': the manifest has no fingerprint for it, so only the size was checked') }

    # list the members and scan them
    $listRes = Run-ProcBeat -File $tar -ArgLine ('-t -f ' + (Q $e.Path)) -TimeoutSec 3600 -Label 'listing the archive' -KeepFiles
    if ($listRes.ExitCode -ne 0 -or $listRes.TimedOut) {
      Bad ('tar could not read ' + $e.Name + ' (code ' + $listRes.ExitCode + ')'); Show-Tail $listRes.ErrLines 4
      Remove-Item -LiteralPath $listRes.OutFile, $listRes.ErrFile -Force -ErrorAction SilentlyContinue
      [void]$failList.Add($e.Name + ': tar cannot read it'); continue
    }
    $scan = $null
    try { $scan = [PilScan]::Run($listRes.OutFile, $script:SecretStrict, $script:SecretLoose, [string[]]@('claudecode/', 'Users/User1/'), 100000, 997) }
    catch { Bad ('could not scan the member list - ' + $_.Exception.Message); Remove-Item -LiteralPath $listRes.OutFile, $listRes.ErrFile -Force -ErrorAction SilentlyContinue; [void]$failList.Add($e.Name + ': scan failed'); continue }
    Remove-Item -LiteralPath $listRes.OutFile, $listRes.ErrFile -Force -ErrorAction SilentlyContinue
    Say ('members: ' + $scan.Total + '  files: ' + $scan.Files + '  under C:\claudecode: ' + $scan.RepoCount + '  under C:\Users\User1: ' + $scan.ProfileCount)
    if ($scan.UnsafeCount -gt 0) {
      Bad ($e.Name + ' contains ' + $scan.UnsafeCount + ' unsafe member name(s) (absolute path, "..", or a drive letter). It is NOT unpacked. First names: ' + (($scan.Unsafe | Select-Object -First 3) -join ' | '))
      [void]$failList.Add($e.Name + ': unsafe paths inside'); continue
    }
    if ($scan.OutsideCount -gt 0) { Warn ($scan.OutsideCount + ' member(s) are outside C:\claudecode and C:\Users\User1 and will NOT be unpacked. First names: ' + (($scan.Outside | Select-Object -First 3) -join ' | ')) }
    $exclFile = ''
    if ($scan.SecretCount -gt 0) {
      $secretsTotal += $scan.SecretCount
      Warn ('SECRET-LOOKING FILE NAMES in ' + $e.Name + ': ' + $scan.SecretCount + '. They will NOT be unpacked (this is never overridden by -Force). Their contents were not read. First names:')
      foreach ($s in @($scan.Secrets | Select-Object -First 25)) { Say ('     not unpacked: ' + $s) }
      Warn 'The main PC push should not contain these. Fix host-push-files.ps1 and delete this archive from C:\PillagersMove\payload after unpacking.'
      $exclFile = Join-Path $script:WorkDir ('exclude-' + [guid]::NewGuid().ToString('N') + '.txt')
      $lines = @($scan.Secrets | ForEach-Object { Escape-TarPattern $_ })
      [System.IO.File]::WriteAllLines($exclFile, [string[]]$lines, (New-Object System.Text.UTF8Encoding($false)))
    }

    # the VM repo must not hold work that this archive would overwrite. The verdict is made once (Get-RepoVerdict) and applies to EVERY
    # archive that writes into C:\claudecode\dark raiders (repo-01, repo-02, git, builds, ...), so a later archive can never extract over a repo
    # that the first one refused.
    if ($scan.RepoCount -gt 0) { $repoTouched = $true }
    if ($scan.MainRepoCount -gt 0 -and $repoPreexisting) {
      $rv = Get-RepoVerdict
      if (-not $rv.Allowed) {
        if (-not $Force) {
          Bad ('REFUSED to unpack ' + $e.Name + ': ' + $rv.Why + '.')
          Say '   Nothing in the repo was overwritten. If you have work in the VM repo that you want to keep, commit and push it first. If the changes are only test runs or nothing you need, run again with -Force to overwrite them.'
          if ($exclFile) { Remove-Item -LiteralPath $exclFile -Force -ErrorAction SilentlyContinue }
          [void]$failList.Add($e.Name + ': VM repo changed since the last unpack')
          continue
        }
        if (-not $script:RepoForceWarned) { Warn ('-Force: unpacking over the VM repo although ' + $rv.Why); $script:RepoForceWarned = $true }
      }
    }

    # unpack
    if ($scan.MainRepoCount -gt 0) {
      $repoAttempted = $true
      # git keeps its pack and object files read-only, and tar cannot replace a read-only file ("Could not unlink"): clear the flag first
      $gitDirNow = Join-Path $script:RepoRoot '.git'
      if (Test-Path -LiteralPath $gitDirNow -PathType Container) {
        $null = Do-Change ('clear the read-only flag on the files inside ' + $gitDirNow + ' so the new copy can replace them (a minute or two)') {
          $ar = Run-Proc -File 'attrib.exe' -ArgLine ('-R ' + (Q ($gitDirNow + '\*')) + ' /S /D') -TimeoutSec 1800
          if ($ar.ExitCode -ne 0) { throw ('attrib returned ' + $ar.ExitCode + ' ' + (($ar.Lines | Select-Object -First 1))) }
        }
      }
    }
    $ok = $true
    $why = ''
    $warnLines = @()
    $passes = New-Object System.Collections.ArrayList
    if ($script:IsUser1) {
      $inc = @()
      if ($scan.RepoCount -gt 0) { $inc += 'claudecode' }
      if ($scan.ProfileCount -gt 0) { $inc += 'Users/User1' }
      if ($inc.Count -gt 0) { [void]$passes.Add(@{ Dir = 'C:/'; Strip = 0; Inc = $inc; Label = 'C:\' }) }
    } else {
      if ($scan.RepoCount -gt 0) { [void]$passes.Add(@{ Dir = 'C:/'; Strip = 0; Inc = @('claudecode'); Label = 'C:\claudecode' }) }
      if ($scan.ProfileCount -gt 0) { [void]$passes.Add(@{ Dir = $script:VmProfile.Replace('\', '/'); Strip = 2; Inc = @('Users/User1'); Label = $script:VmProfile }) }
    }
    foreach ($ps in $passes) {
      $a = @('-x', '-f', $e.Path, '-C', $ps.Dir, '-U')
      if ($ps.Strip -gt 0) { $a += ('--strip-components=' + [string]$ps.Strip) }
      if ($exclFile) { $a += @('-X', $exclFile) }
      $a += $ps.Inc
      $line = ($a | ForEach-Object { Q ([string]$_) }) -join ' '
      Say ('unpacking into ' + $ps.Label + ' (large folders take many minutes; Defender scans every file, which is normal) ...')
      $x = Run-ProcBeat -File $tar -ArgLine $line -TimeoutSec 14400 -Label ('unpacking ' + $e.Name)
      if ($x.TimedOut) { $ok = $false; $why = 'unpacking took longer than 4 hours and was stopped'; break }
      if ($x.ExitCode -ne 0) {
        # object and pack files of .git are named after their content, so one that is already there (and cannot be replaced) is the same file
        $real = @($x.Lines | Where-Object { $_ -notmatch "(?i)can't restore (time|mode|owner|extended)|utime|chmod|not supported|time stamp" -and $_ -notmatch '(?i)\.git/objects/.*unlink' -and $_ -notmatch '(?i)unlink.*\.git/objects/' })
        if ($real.Count -gt 0) { $ok = $false; $why = 'tar returned ' + $x.ExitCode; Show-Tail $real 8; break }
        $warnLines += $x.Lines
        Warn ('tar returned ' + $x.ExitCode + ' but only about file times/modes (' + @($x.Lines).Count + ' message(s)); treated as fine')
      }
    }
    if ($exclFile) { Remove-Item -LiteralPath $exclFile -Force -ErrorAction SilentlyContinue }
    if (-not $ok) { Bad ($e.Name + ': ' + $why); [void]$failList.Add($e.Name + ': ' + $why); continue }

    # did the sampled files really land?
    $missing = 0
    $checked = 0
    foreach ($s in $scan.Sample) {
      $checked++
      $dest = Entry-TargetPath $s
      if (-not (Test-Path -LiteralPath $dest)) { $missing++; if ($missing -le 3) { Warn ('missing after unpacking: ' + $dest) } }
    }
    if ($checked -gt 0 -and $missing -gt [math]::Floor($checked / 20)) {
      Bad ($e.Name + ': ' + $missing + ' of ' + $checked + ' sampled files are not on disk after unpacking.')
      [void]$failList.Add($e.Name + ': ' + $missing + ' sampled files missing'); continue
    }
    Good ($e.Name + ' unpacked (' + $scan.Files + ' files; ' + ($checked - $missing) + ' of ' + $checked + ' sampled files verified on disk)')
    $stateMap[$e.Name] = [pscustomobject]@{ Sha = $e.Sha; Size = [double]$it.Length; Stamp = [string]$it.LastWriteTimeUtc.Ticks; ExtractedAt = (Get-Date).ToString('s'); Files = $scan.Files; SecretNamesLeftOut = $scan.SecretCount }
    Write-JsonFile (Join-Path $script:StateDir 'files-done.json') $stateMap
    [void]$okList.Add($e.Name)
  }

  # ---- after-unpack fixes (once)
  Blank
  if (-not $script:DryRun -and ($okList.Count -gt 0 -or $skipList.Count -gt 0 -or $repoTouched -or (Test-Path -LiteralPath (Join-Path $script:RepoRoot '.git')))) {
    Say 'finishing touches ...'
    Ensure-GitSafe
    Restore-CodexWorktree
    Copy-ClaudeMemory
    Ensure-Dir (Map-ToReal $script:Scratch)
    Test-RemoteHasEmbeddedLogin
    if ($repoAttempted) { Save-RepoBaseline 'right after the files stage unpacked the repo archives' }
    if (Test-Path -LiteralPath $script:RepoRoot) {
      $head = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'rev-parse', 'HEAD') -TimeoutSec 60
      $hv = ''
      if ($head.ExitCode -eq 0) { $hv = ([string]($head.Lines | Select-Object -First 1)).Trim().ToLowerInvariant() }
      if ($hv) {
        Say ('repo HEAD in the VM: ' + $hv.Substring(0, [math]::Min(12, $hv.Length)))
        if ($marker.Head) {
          if ($hv -eq $marker.Head) { Good 'the VM repo is at the same commit the main PC had when it was stopped' }
          else {
            $anc = Invoke-Git -GitArgs @('-C', $script:RepoRoot, 'merge-base', '--is-ancestor', $marker.Head, 'HEAD') -TimeoutSec 60
            if ($anc.ExitCode -eq 0) { Say ('the VM repo is AHEAD of the commit in host-stopped.txt (' + $marker.Head.Substring(0, 12) + '): commits were made in the VM since; fine') }
            elseif ($man.Final -and $marker.Stopped) {
              Bad ('the VM repo HEAD (' + $hv.Substring(0, 12) + ') is NOT the commit in host-stopped.txt (' + $marker.Head.Substring(0, 12) + ') and does not contain it. The final copy did not land completely; run: vm-setup.ps1 -Only files -Force (after checking nothing of yours is in the VM repo).')
              [void]$failList.Add('VM repo HEAD is not the commit named in host-stopped.txt')
            }
            else { Warn ('the VM repo HEAD (' + $hv.Substring(0, 12) + ') differs from the commit in host-stopped.txt (' + $marker.Head.Substring(0, [math]::Min(12, $marker.Head.Length)) + '). Expected until the final copy has been pushed.') }
          }
        }
        $dc = Get-RepoDirtyCount
        if ($dc -ge 0) { Say ('changed files in the VM repo right now: ' + $dc) }
        Report-ExtraFiles $man
      } else { Warn 'git cannot read the VM repo HEAD (see the lines above).' }
    }
    foreach ($must in @('dark_raiders.html', 'tools\nightly.sh', 'tools\health.sh', 'tools\start-servers.ps1')) {
      if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot $must))) { Warn ('expected file is missing: ' + (Join-Path $script:RepoRoot $must)) }
    }
  }

  $msg = $okList.Count.ToString() + ' archive(s) unpacked, ' + $skipList.Count + ' already done'
  if ($secretsTotal -gt 0) { $msg += '; ' + $secretsTotal + ' secret-looking file name(s) were left out' }
  if ($script:DryRun) { return (ResDone ('(dry run) ' + $entries.Count + ' archive(s) would be checked and unpacked')) }
  if ($failList.Count -gt 0) { return (ResFail ($msg + '; FAILED: ' + ($failList -join ' | '))) }
  return (ResDone $msg)
}


# ======================================================================================================================
# STAGE services : launchers, scheduled tasks, servers, dev console, shortcuts. Refuses until the main PC is stopped.
# ======================================================================================================================
function Xml-Esc([string]$s) { return [System.Security.SecurityElement]::Escape($s) }

function Build-TaskXml {
  param([string]$Desc, [string]$TriggerXml, [string]$Cmd, [string]$CmdArgs, [bool]$Enabled, [string]$Limit)
  $en = 'true'
  if (-not $Enabled) { $en = 'false' }
  $x = '<?xml version="1.0" encoding="UTF-16"?>' + "`r`n"
  $x += '<Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">' + "`r`n"
  $x += '  <RegistrationInfo><Description>' + (Xml-Esc $Desc) + '</Description></RegistrationInfo>' + "`r`n"
  if ($TriggerXml) { $x += '  <Triggers>' + $TriggerXml + '</Triggers>' + "`r`n" }
  $x += '  <Principals><Principal id="Author"><UserId>' + (Xml-Esc $script:UserSid) + '</UserId><LogonType>InteractiveToken</LogonType><RunLevel>LeastPrivilege</RunLevel></Principal></Principals>' + "`r`n"
  $x += '  <Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>'
  $x += '<AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>true</StartWhenAvailable><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>' + $en + '</Enabled><Hidden>false</Hidden>'
  $x += '<ExecutionTimeLimit>' + $Limit + '</ExecutionTimeLimit></Settings>' + "`r`n"
  $x += '  <Actions Context="Author"><Exec><Command>' + (Xml-Esc $Cmd) + '</Command>'
  if ($CmdArgs) { $x += '<Arguments>' + (Xml-Esc $CmdArgs) + '</Arguments>' }
  $x += '</Exec></Actions>' + "`r`n"
  $x += '</Task>'
  return $x
}

function Write-LauncherFile([string]$name, [string]$text) {
  Ensure-Dir $script:LaunchDir
  $f = Join-Path $script:LaunchDir $name
  $t = ($text -replace "`r?`n", "`r`n")
  $same = $false
  if (Test-Path -LiteralPath $f) { try { $same = ([System.IO.File]::ReadAllText($f) -ceq $t) } catch { } }
  if ($same) { Say ('launcher ' + $name + ': already right'); return $f }
  $null = Do-Change ('write the launcher ' + $f) { [System.IO.File]::WriteAllText($f, $t, [System.Text.Encoding]::ASCII) }
  return $f
}

function Set-PilShortcut([string]$Path, [string]$Target, [string]$ArgLine, [string]$WorkDir, [string]$Icon, [string]$Desc) {
  try {
    $ws = New-Object -ComObject WScript.Shell
    if (Test-Path -LiteralPath $Path) {
      $l = $ws.CreateShortcut($Path)
      if ($l.TargetPath -ieq $Target -and $l.Arguments -eq $ArgLine) { Say ('shortcut ' + (Split-Path -Leaf $Path) + ': already there'); return }
    }
    $null = Do-Change ('make the desktop shortcut ' + (Split-Path -Leaf $Path)) {
      $l2 = $ws.CreateShortcut($Path)
      $l2.TargetPath = $Target
      $l2.Arguments = $ArgLine
      if ($WorkDir) { $l2.WorkingDirectory = $WorkDir }
      if ($Icon) { $l2.IconLocation = $Icon }
      $l2.Description = $Desc
      $l2.Save()
    }
  } catch { Warn ('could not make the shortcut ' + $Path + ' - ' + $_.Exception.Message) }
}

function Clear-StaleLocks {
  # Old runtime markers that came over with the files. The SHIP LOCK is never deleted by this script: tools\handoff\shipkit\clearstale.sh is the
  # only way to clear it (it tells an owner that is still alive from one that is gone). Nothing here is touched unless host-stopped.txt is a valid
  # "stopped" marker that says the ship lock was clear on the main PC.
  $mk = Get-MarkerInfo
  if (-not ($mk.Stopped -and $mk.ShipLockClear -eq $true)) {
    if (-not $Force) { Say 'old lock files and the heartbeat are left alone: host-stopped.txt does not say the main PC stopped cleanly with the ship lock clear'; return }
    Warn 'clearing old lock files although the marker is not valid, only because of -Force'
  }
  $busy = @()
  try {
    $busy = @(Get-CimInstance Win32_Process -ErrorAction Stop | Where-Object { $_.CommandLine -and ($_.CommandLine -match 'nightly\.sh|console-lane\.sh|console-worker\.sh|corpq\.sh|corpus-slices\.sh|shipq\.sh|shipone\.sh|codex-lane\.sh|fixq\.sh') })
  } catch { Warn 'could not list running programs, so old lock files are left alone'; return }
  if ($busy.Count -gt 0) { Say ('helpers are already running here (' + $busy.Count + ' process(es)); old lock files are left alone'); return }
  $h = Join-Path $script:RepoRoot 'tools\handoff'
  $sc = Map-ToReal $script:Scratch

  # ---- the ship lock: look at it, and let clearstale.sh judge it
  $lk = Join-Path $sc 'shipq.lock'
  $ow = Join-Path $sc 'shipq.owner'
  if (Test-Path -LiteralPath $lk) {
    $ageMin = -1
    try { $ageMin = [int]((Get-Date) - (Get-Item -LiteralPath $lk -Force).LastWriteTime).TotalMinutes } catch { }
    $ownerTxt = ''
    if (Test-Path -LiteralPath $ow) { try { $ownerTxt = ([System.IO.File]::ReadAllText($ow)).Trim() } catch { } }
    Say ('ship lock found: ' + $lk + '   age ' + $ageMin + ' min   owner file: ' + $(if ($ownerTxt) { $ownerTxt } else { '(none)' }))
    if ($script:DryRun) { Dry 'ask tools\handoff\shipkit\clearstale.sh about that lock (it clears it only when the owner is gone); the lock folder itself is never deleted by this script' }
    else {
      $cs = Join-Path $sc 'clearstale.sh'
      if (-not (Test-Path -LiteralPath $cs)) { $cs = Join-Path $h 'shipkit\clearstale.sh' }
      $bashX = Find-BashExe
      if (-not $bashX -or -not (Test-Path -LiteralPath $cs)) { Warn 'the ship lock was left in place: Git bash or clearstale.sh was not found, and the lock is never deleted by hand' }
      else {
        $r = Run-Proc -File $bashX -ArgLine (Q ($cs -replace '\\', '/')) -TimeoutSec 120
        $ans = (@($r.Lines | Select-Object -First 3)) -join ' / '
        if ($r.ExitCode -eq 0) { Say ('clearstale.sh says: ' + $ans) }
        elseif ($r.ExitCode -eq 1) { Warn ('the ship lock is HELD and was left alone. clearstale.sh says: ' + $ans + '   The runner will wait for it; if it never frees, ask for help instead of deleting the folder.') }
        else { Warn ('clearstale.sh could not clear the ship lock (code ' + $r.ExitCode + '): ' + $ans + '   It was left in place.') }
      }
    }
  } else { Say 'no ship lock to clear' }

  # ---- the other runtime markers that came over with the files
  $targets = New-Object System.Collections.ArrayList
  foreach ($p in @((Join-Path $h 'nightly\runner.heartbeat'), (Join-Path $sc 'corpus.lock'), (Join-Path $h 'console\pick.lock'))) { [void]$targets.Add($p) }
  $cd = Join-Path $h 'console'
  if (Test-Path -LiteralPath $cd) { foreach ($d in @(Get-ChildItem -LiteralPath $cd -Filter 'lane-*.lock' -Force -ErrorAction SilentlyContinue)) { [void]$targets.Add($d.FullName) } }
  $n = 0
  foreach ($t in $targets) {
    if (-not (Test-Path -LiteralPath $t)) { continue }
    $null = Do-Change ('remove the old runtime marker ' + $t + ' (it came from the main PC; nothing is running here)') { Remove-Item -LiteralPath $t -Recurse -Force -ErrorAction Stop }
    $n++
  }
  if ($n -eq 0) { Say 'no old lock files or heartbeats to clear' }
}

function Show-StopSigns {
  $h = Join-Path $script:RepoRoot 'tools\handoff'
  foreach ($pair in @(@('console\STOP', 'all Console helpers are PAUSED'), @('codex\STOP', 'the ChatGPT helper is PAUSED'), @('stable.freeze', 'the stable build is frozen'))) {
    $f = Join-Path $h $pair[0]
    if (Test-Path -LiteralPath $f) { Say ('NOTE: ' + $pair[0] + ' exists, so ' + $pair[1] + '. It came with the files. Delete ' + $f + ' when you want them to work.') }
  }
}

function Test-HttpAnswers([string]$url) {
  try {
    $null = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
    return $true
  } catch {
    # any HTTP answer (even 404 or 405) proves the server is listening; a refused connection has no response
    if ($_.Exception.Response) { return $true }
    return $false
  }
}
function Wait-Url([string]$url, [int]$seconds) {
  $t0 = Get-Date
  while (((Get-Date) - $t0).TotalSeconds -lt $seconds) {
    if (Test-HttpAnswers $url) { return $true }
    Start-Sleep -Seconds 3
  }
  return $false
}

function Get-HeartbeatAge {
  $hb = Join-Path $script:RepoRoot 'tools\handoff\nightly\runner.heartbeat'
  if (-not (Test-Path -LiteralPath $hb)) { return -1 }
  try {
    $v = [long](([System.IO.File]::ReadAllText($hb)).Trim())
    $now = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
    return ($now - $v)
  } catch { return -1 }
}

function Stage-services {
  $marker = Get-MarkerInfo
  if ($marker.Exists) { Show-MarkerFacts }
  $gate = Test-ServicesAllowed
  if (-not $gate.Ok) {
    foreach ($w in $gate.Why) { Warn ('REFUSED: ' + $w) }
    if (-not $Force) {
      return (ResSkip ('the runner and helpers were NOT set up or started: ' + @($gate.Why).Count + ' check(s) failed (listed above). Two copies must never run, and the VM must start from the final copy of the files. Fix what is listed, then run: vm-setup.ps1 -Only files,services,health   (-Force overrides, at your own risk).'))
    }
    Warn 'Continuing only because of -Force. Make sure the main PC runner and helpers are really off, and that the files in the VM are the final ones.'
  } else { Good 'start check passed: the main PC is marked stopped, the copied files are the final ones, fully unpacked, and the repo is at the marker commit' }

  $problems = New-Object System.Collections.ArrayList
  if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot 'tools\nightly.sh'))) { [void]$problems.Add('the repo is not at ' + $script:RepoRoot + ' (run the files stage)') }
  $bash = Find-BashExe
  if (-not $bash) { [void]$problems.Add('Git for Windows (bash.exe) is not installed (run the apps stage)') }
  if (-not (Find-NodeExe)) { [void]$problems.Add('Node.js is not installed (run the apps stage)') }
  if ($problems.Count -gt 0) { return (ResFail ('cannot set up the services: ' + ($problems -join '; '))) }
  if (-not $script:DryRun) { Update-SessionPath }

  Ensure-Dir $script:LaunchDir
  Clear-StaleLocks
  Show-StopSigns

  # ---- launchers
  $vbs = @'
' dev-services.vbs : written by vm-setup.ps1. Starts the local servers (tools\start-servers.ps1) and the dev console server, hidden.
' Safe to run again: start-servers.ps1 leaves a port alone when it already answers.
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\claudecode\dark raiders\tools\start-servers.ps1""", 0, False
ok = False
On Error Resume Next
Set x = CreateObject("MSXML2.ServerXMLHTTP.6.0")
x.setTimeouts 1000, 1000, 1000, 1000
x.Open "GET", "http://127.0.0.1:8820/api", False
x.Send
If Err.Number = 0 Then
  If x.Status = 200 Then ok = True
End If
Err.Clear
On Error GoTo 0
If Not ok Then
  sh.Run "cmd /c cd /d ""C:\claudecode\dark raiders\tools\devdash"" && node server.mjs", 0, False
End If
'@
  $devVbs = Write-LauncherFile 'dev-services.vbs' $vbs

  # ---- the runner guard: the "Pillagers runner" task starts THIS, not the runner. It starts the runner only while host-stopped.txt is a valid
  # "stopped" marker, so switching the main PC back on (host-stop.ps1 -Undo sends a "revoked" marker) stops the VM runner at the next tick.
  $guard = @'
# runner-guard.ps1 : written by vm-setup.ps1. The "Pillagers runner" task runs this (through runner-guard.vbs) every 15 minutes.
# It starts the runner (tools\runner-start.vbs) ONLY while C:\PillagersMove\kit\host-stopped.txt is a valid "stopped" marker from the main PC.
# Otherwise it does nothing and writes one line to runner-guard.log. It never changes the marker. To pause the runner by hand, create the
# file C:\PillagersMove\launchers\RUNNER-OFF.txt (delete it to let the runner start again).
$ErrorActionPreference = 'Continue'
$here = 'C:\PillagersMove\launchers'
$log = Join-Path $here 'runner-guard.log'
function Log([string]$t) {
  try {
    if ((Test-Path -LiteralPath $log) -and ((Get-Item -LiteralPath $log).Length -gt 200000)) { Move-Item -LiteralPath $log -Destination ($log + '.old') -Force }
    Add-Content -LiteralPath $log -Value ((Get-Date).ToString('s') + ' ' + $t)
  } catch { }
}
function Get-Check([string[]]$Lines) {
  $keep = @()
  foreach ($l in $Lines) { $t = ([string]$l).Trim(); if (-not $t) { continue }; if ($t -match '^check\s*=') { continue }; $keep += $t }
  $bytes = [System.Text.Encoding]::ASCII.GetBytes(($keep -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}
$why = @()
if (Test-Path -LiteralPath (Join-Path $here 'RUNNER-OFF.txt')) { $why += 'RUNNER-OFF.txt exists' }
$f = 'C:\PillagersMove\kit\host-stopped.txt'
if (-not (Test-Path -LiteralPath $f)) { $why += 'there is no host-stopped.txt' }
else {
  $lines = @()
  try { $lines = @(Get-Content -LiteralPath $f -ErrorAction Stop) } catch { $why += 'host-stopped.txt cannot be read' }
  $kv = @{}
  foreach ($l in $lines) {
    if ($l -match '^\s*([A-Za-z][A-Za-z0-9]*)\s*=\s*(.*?)\s*$') {
      $k = $Matches[1].ToLowerInvariant()
      if ($kv.ContainsKey($k)) { $why += ('the line ' + $k + ' appears twice') } else { $kv[$k] = $Matches[2] }
    }
  }
  if ($kv['status'] -ne 'stopped') { $why += ('status is "' + $kv['status'] + '"') }
  if (-not $kv['computer']) { $why += 'no computer line' } elseif ($kv['computer'] -ieq $env:COMPUTERNAME) { $why += 'the marker names this computer' }
  if ($kv['githead'] -notmatch '^[0-9a-fA-F]{40}$') { $why += 'no full gitHead' }
  if ($kv['shiplockclear'] -ne 'yes') { $why += 'shipLockClear is not yes' }
  if (-not $kv['check']) { $why += 'no check line' } elseif ($kv['check'].ToLowerInvariant() -ne (Get-Check $lines)) { $why += 'check line does not match' }
}
if ($why.Count -gt 0) { Log ('runner NOT started: ' + ($why -join '; ')); exit 0 }
$vbs = 'C:\claudecode\dark raiders\tools\runner-start.vbs'
if (-not (Test-Path -LiteralPath $vbs)) { Log 'runner NOT started: tools\runner-start.vbs is missing'; exit 0 }
Start-Process -FilePath 'wscript.exe' -ArgumentList ('"' + $vbs + '"') -WindowStyle Hidden
exit 0
'@
  $null = Write-LauncherFile 'runner-guard.ps1' $guard
  $guardVbsText = @'
' runner-guard.vbs : written by vm-setup.ps1. Runs runner-guard.ps1 without a window (the "Pillagers runner" task starts this).
Set sh = CreateObject("WScript.Shell")
sh.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\PillagersMove\launchers\runner-guard.ps1""", 0, False
'@
  $guardVbs = Write-LauncherFile 'runner-guard.vbs' $guardVbsText
  $out = Join-Path $script:WorkDir 'health-out.txt'
  $done = Join-Path $script:WorkDir 'health-done.txt'
  $cmd = '@echo off' + "`r`n" + 'rem written by vm-setup.ps1: runs the Pillagers health sweep and saves what it printed' + "`r`n"
  $cmd += 'if exist "' + $done + '" del "' + $done + '"' + "`r`n"
  $cmd += '"' + $bash + '" "/c/claudecode/dark raiders/tools/health.sh" %1 > "' + $out + '" 2>&1' + "`r`n"
  $cmd += 'echo done> "' + $done + '"' + "`r`n"
  $healthCmd = Write-LauncherFile 'health-once.cmd' $cmd

  # ---- scheduled tasks
  $start = (Get-Date).ToString('s')
  $runnerArgs = '"' + $guardVbs + '"'
  $existing = Get-ScheduledTask -TaskName $script:RunnerTask -ErrorAction SilentlyContinue
  $runnerOk = $false
  if ($existing) { try { $runnerOk = ($existing.Actions[0].Execute -ieq 'wscript.exe' -and $existing.Actions[0].Arguments -eq $runnerArgs) } catch { } }
  if ($runnerOk) { Say ('scheduled task "' + $script:RunnerTask + '": already set up (state ' + $existing.State + ')') }
  else {
    $trig = '<TimeTrigger><Repetition><Interval>PT15M</Interval></Repetition><StartBoundary>' + $start + '</StartBoundary><Enabled>true</Enabled></TimeTrigger>'
    $xml = Build-TaskXml -Desc 'PILLAGERS always-on runner: every 15 min runner-guard.ps1 starts tools\nightly.sh hidden (a live copy makes the new one exit) - but only while host-stopped.txt says the main PC is stopped. Created by vm-setup.ps1.' -TriggerXml $trig -Cmd 'wscript.exe' -CmdArgs $runnerArgs -Enabled (-not $NoRunner) -Limit 'PT5M'
    $null = Do-Change ('create the scheduled task "' + $script:RunnerTask + '" (every 15 minutes' + $(if ($NoRunner) { ', created OFF because of -NoRunner' } else { '' }) + ')') { Register-ScheduledTask -TaskName $script:RunnerTask -Xml $xml -Force -ErrorAction Stop | Out-Null }
  }
  if ($NoRunner -and $runnerOk -and $existing.State -ne 'Disabled') {
    $null = Do-Change ('switch the task "' + $script:RunnerTask + '" off (-NoRunner)') { Disable-ScheduledTask -TaskName $script:RunnerTask -ErrorAction Stop | Out-Null }
  }

  $devArgs = '"' + $devVbs + '"'
  $existing2 = Get-ScheduledTask -TaskName $script:DevTask -ErrorAction SilentlyContinue
  $devOk = $false
  if ($existing2) { try { $devOk = ($existing2.Actions[0].Execute -ieq 'wscript.exe' -and $existing2.Actions[0].Arguments -eq $devArgs) } catch { } }
  if ($devOk) { Say ('scheduled task "' + $script:DevTask + '": already set up') }
  else {
    $trig2 = '<LogonTrigger><Enabled>true</Enabled><UserId>' + (Xml-Esc $script:UserFull) + '</UserId><Delay>PT30S</Delay></LogonTrigger>'
    $xml2 = Build-TaskXml -Desc 'Starts the Pillagers local servers and the dev console server when you sign in. Created by vm-setup.ps1.' -TriggerXml $trig2 -Cmd 'wscript.exe' -CmdArgs $devArgs -Enabled $true -Limit 'PT10M'
    $null = Do-Change ('create the scheduled task "' + $script:DevTask + '" (runs at sign-in)') { Register-ScheduledTask -TaskName $script:DevTask -Xml $xml2 -Force -ErrorAction Stop | Out-Null }
  }

  # ---- the helpers' own npm packages (only when the unpacked files did not bring node_modules)
  $sdk = Join-Path $script:RepoRoot 'tools\console-sdk'
  if ((Test-Path -LiteralPath (Join-Path $sdk 'package.json')) -and -not (Test-Path -LiteralPath (Join-Path $sdk 'node_modules'))) {
    $nd = Get-NodeDirReal
    $npmCli = ''
    if ($nd) { $npmCli = Join-Path $nd 'node_modules\npm\bin\npm-cli.js' }
    if ($script:DryRun) { Dry 'run npm ci in tools\console-sdk (node_modules was not in the unpacked files)' }
    elseif ($npmCli -and (Test-Path -LiteralPath $npmCli)) {
      Say 'tools\console-sdk has no node_modules; running npm ci ...'
      $r = Run-ProcBeat -File (Find-NodeExe) -ArgLine ((Q $npmCli) + ' ci --no-audit --no-fund') -WorkingDirectory $sdk -TimeoutSec 900 -Label 'npm ci'
      if ($r.ExitCode -eq 0) { Good 'npm ci finished' } else { Warn ('npm ci returned ' + $r.ExitCode + '; the Console helpers will not work until it succeeds'); Show-Tail $r.Lines 6 }
    } else { Warn 'cannot run npm ci (npm was not found beside node.exe)' }
  } else { Say 'tools\console-sdk packages: already present' }

  # ---- desktop shortcuts
  $desk = Get-RealDesktop
  Set-PilShortcut (Join-Path $desk 'Pillagers Dev.lnk') (Join-Path $env:SystemRoot 'System32\wscript.exe') ('"' + $script:RepoRoot + '\tools\devdash\open.vbs"') ($script:RepoRoot + '\tools\devdash') ((Join-Path $env:SystemRoot 'System32\imageres.dll') + ',144') 'Pillagers dev console (live dashboard)'
  $claudeExe = Join-Path $script:VmProfile '.local\bin\claude.exe'
  $coord = Join-Path $script:MirrorProfile 'Desktop\dark raiders'
  if (-not (Test-Path -LiteralPath (Map-ToReal $coord))) { $coord = $script:RepoRoot }
  if (Test-Path -LiteralPath $claudeExe) {
    Set-PilShortcut (Join-Path $desk 'Claude Code - Pillagers.lnk') (Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe') ('-NoExit -Command "Set-Location -LiteralPath ' + [char]39 + $coord + [char]39 + '; claude"') $coord $claudeExe 'Claude Code opened in the Pillagers folder'
  } else { Say 'shortcut "Claude Code - Pillagers": skipped (Claude Code is not installed yet)' }

  # ---- start things now
  $upList = New-Object System.Collections.ArrayList
  if ($script:DryRun) {
    Dry ('start the task "' + $script:DevTask + '" and wait for the play server (8802) and the dev console server (8820)')
    if (-not $NoRunner) { Dry ('start the task "' + $script:RunnerTask + '" and wait for the runner heartbeat') }
    return (ResDone '(dry run) listed the launchers, tasks, shortcuts and starts')
  }
  Say ('starting the servers through the task "' + $script:DevTask + '" (runs as you, not elevated) ...')
  try { Start-ScheduledTask -TaskName $script:DevTask -ErrorAction Stop } catch { Warn ('could not start the task - ' + $_.Exception.Message) }
  $urls = @(@('play server 8802', 'http://localhost:8802/dark_raiders.html'), @('dev console server 8820', 'http://127.0.0.1:8820/api'), @('collector 8799', 'http://localhost:8799/'))
  foreach ($u in $urls) {
    if (Wait-Url $u[1] 90) { Good ($u[0] + ' answers'); [void]$upList.Add($u[0]) } else { Warn ($u[0] + ' is not answering after 90 seconds (check the sign-in state: tasks only run while you are signed in on the VM console)') }
  }

  $hbNote = ''
  if ($NoRunner) { $hbNote = 'runner task left OFF (-NoRunner)'; Say 'The runner is NOT started (-NoRunner). Start it later with:  Start-ScheduledTask -TaskName "Pillagers runner"' }
  else {
    $rt = Get-ScheduledTask -TaskName $script:RunnerTask -ErrorAction SilentlyContinue
    if ($rt -and $rt.State -eq 'Disabled') { Warn ('the task "' + $script:RunnerTask + '" is switched off (an earlier party-stop or -NoRunner). Switch it on with: Enable-ScheduledTask -TaskName "' + $script:RunnerTask + '"'); $hbNote = 'runner task is disabled' }
    else {
      Say 'starting the runner (tools\runner-start.vbs through its guard and its task) ...'
      try { Start-ScheduledTask -TaskName $script:RunnerTask -ErrorAction Stop } catch { Warn ('could not start the runner task - ' + $_.Exception.Message) }
      $ok = $false
      for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 3
        $age = Get-HeartbeatAge
        if ($age -ge 0 -and $age -lt 120) { $ok = $true; break }
      }
      if ($ok) { Good 'the runner is alive (fresh heartbeat). It starts the robots, helpers and test runs by itself within about 5 minutes.'; $hbNote = 'runner alive' }
      else { Warn 'no fresh runner heartbeat after 90 seconds. Look at C:\PillagersMove\launchers\runner-guard.log (it says why the guard did not start the runner), then tools\handoff\nightly\nightly.log, and make sure Git bash and node work in a normal window.'; $hbNote = 'runner heartbeat not seen' }
    }
  }
  if ($upList.Count -lt 2) { return (ResFail ('tasks and launchers are set up, but only ' + $upList.Count + ' server(s) answered. ' + $hbNote)) }
  return (ResDone ('tasks, launchers and shortcuts set up; ' + ($upList -join ', ') + ' up; ' + $hbNote))
}

# ======================================================================================================================
# STAGE health : tools, key variable NAMES, the Pillagers health sweep, sign-in checklist
# ======================================================================================================================
function Get-FirstLine($lines) { $a = @($lines); if ($a.Count -gt 0) { return [string]$a[0] }; return '' }

function Stage-health {
  if (-not $script:DryRun) { Update-SessionPath }
  $missingReq = New-Object System.Collections.ArrayList
  $row = {
    param([string]$n, [string]$state, [string]$detail)
    Say ('   ' + $n.PadRight(24) + $state.PadRight(9) + $detail)
  }
  Say 'tools:'
  $git = Find-GitExe
  if ($git) { $v = Run-Proc -File $git -ArgLine '--version' -TimeoutSec 30; & $row 'Git' 'ok' (Get-FirstLine $v.Lines) } else { & $row 'Git' 'MISSING' ''; [void]$missingReq.Add('Git') }
  $bash = Find-BashExe
  if ($bash) { & $row 'Git bash (bash.exe)' 'ok' $bash } else { & $row 'Git bash (bash.exe)' 'MISSING' 'lane scripts need C:\Program Files\Git\bin\bash.exe'; [void]$missingReq.Add('bash.exe') }
  $node = Find-NodeExe
  $nd = ''
  if ($node) {
    $v = Run-Proc -File $node -ArgLine '--version' -TimeoutSec 30
    $nv = Get-FirstLine $v.Lines
    $flag = 'ok'
    if ($nv -match '^v(\d+)\.' -and [int]$Matches[1] -ne $script:HostNodeMajor) { $flag = 'differs' }
    & $row 'Node.js' $flag ($nv + '  main PC: v' + $script:HostNodeVersion)
    $nd = Get-NodeDirReal
    $first = ''
    $up = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($up) { $first = ($up -split ';' | Select-Object -First 1) }
    if ($nd -and ($first.TrimEnd('\') -ine $nd.TrimEnd('\'))) { Warn ('the node folder ' + $nd + ' is not first in your user PATH; run the apps stage again (it puts it first, as on the main PC).') }
  } else { & $row 'Node.js' 'MISSING' ''; [void]$missingReq.Add('Node.js') }
  if ($nd) {
    $npmv = Get-InstalledNpmVersion $nd 'npm'
    if ($npmv) { & $row 'npm' 'ok' $npmv } else { & $row 'npm' 'MISSING' '' }
    $codexJs = Join-Path $nd 'node_modules\@openai\codex\bin\codex.js'
    $cv = Get-InstalledNpmVersion $nd '@openai\codex'
    if (Test-Path -LiteralPath $codexJs) { & $row 'Codex CLI' 'ok' ($cv + '  main PC: ' + $script:CodexVersion) } else { & $row 'Codex CLI' 'MISSING' 'expected beside node.exe: node_modules\@openai\codex\bin\codex.js'; [void]$missingReq.Add('Codex CLI') }
    $gemJs = Join-Path $nd 'node_modules\@google\gemini-cli\bundle\gemini.js'
    $gv = Get-InstalledNpmVersion $nd '@google\gemini-cli'
    if (Test-Path -LiteralPath $gemJs) { & $row 'Gemini CLI' 'ok' ($gv + '  main PC: ' + $script:GeminiVersion) } else { & $row 'Gemini CLI' 'MISSING' 'expected beside node.exe: node_modules\@google\gemini-cli\bundle\gemini.js'; [void]$missingReq.Add('Gemini CLI') }
  }
  $claudeExe = Join-Path $script:VmProfile '.local\bin\claude.exe'
  if (Test-Path -LiteralPath $claudeExe) { $v = Run-Proc -File $claudeExe -ArgLine '--version' -TimeoutSec 60; & $row 'Claude Code' 'ok' (Get-FirstLine $v.Lines) } else { & $row 'Claude Code' 'MISSING' '~\.local\bin\claude.exe'; [void]$missingReq.Add('Claude Code') }
  $cd = Join-Path $env:LOCALAPPDATA 'AnthropicClaude\claude.exe'
  $cdApp = @(Get-AppxPackage -Name '*Claude*' -ErrorAction SilentlyContinue | Where-Object { $_.Publisher -match 'Anthropic' })
  if ((Test-Path -LiteralPath $cd) -or $cdApp.Count -gt 0) { & $row 'Claude desktop app' 'ok' '' } else { & $row 'Claude desktop app' 'MISSING' 'not essential for the helpers' }
  $agy = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
  if (Test-Path -LiteralPath $agy) { & $row 'agy (Google checker)' 'ok' $agy } else { & $row 'agy (Google checker)' 'MISSING' 'ship-review.ps1 looks for %LOCALAPPDATA%\agy\bin\agy.exe'; [void]$missingReq.Add('agy') }
  $chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
  if (Test-Path -LiteralPath $chrome) { & $row 'Google Chrome' 'ok' ((Get-Item -LiteralPath $chrome).VersionInfo.ProductVersion) } else { & $row 'Google Chrome' 'MISSING' $chrome; [void]$missingReq.Add('Chrome') }
  if (Test-PythonReal) { & $row 'Python' 'ok' '' } else { & $row 'Python' 'MISSING' 'optional' }
  if (Test-Path -LiteralPath 'C:\Program Files\PowerShell\7\pwsh.exe') { & $row 'PowerShell 7 (MSI)' 'ok' '' } else { & $row 'PowerShell 7 (MSI)' 'MISSING' 'optional' }
  if (Test-Path -LiteralPath 'C:\Program Files\7-Zip\7z.exe') { & $row '7-Zip' 'ok' '' } else { & $row '7-Zip' 'MISSING' 'optional' }
  foreach ($pair in @(@('repo', $script:RepoRoot), @('codex worktree', $script:CodexTree))) {
    if (Test-Path -LiteralPath $pair[1]) { & $row $pair[0] 'ok' $pair[1] } else { & $row $pair[0] 'MISSING' $pair[1] }
  }

  # ---- key variable NAMES (never values)
  Blank
  Say 'key variables (names only, values are never read or shown):'
  $bad = 0
  foreach ($vn in @('OPENAI_API_KEY', 'CODEX_API_KEY', 'ANTHROPIC_API_KEY')) {
    foreach ($sc in @('Process', 'User', 'Machine')) {
      $val = [Environment]::GetEnvironmentVariable($vn, $sc)
      if ($val) { Warn ($vn + ' is set at ' + $sc + ' level. It must NOT be: it makes the helpers bill an API account instead of your sign-ins. Remove it (System Properties, Environment Variables); this script never sets or removes it.'); $bad++ }
    }
  }
  if ($bad -eq 0) { Say '   none of OPENAI_API_KEY, CODEX_API_KEY, ANTHROPIC_API_KEY is set (good)' }
  $cfgFiles = @((Join-Path $script:VmProfile '.claude\settings.json'), (Join-Path $script:VmProfile '.claude\settings.local.json'), (Join-Path $script:RepoRoot '.claude\settings.json'), (Join-Path $script:RepoRoot '.claude\settings.local.json'), (Join-Path $script:VmProfile '.codex\config.toml'))
  foreach ($cf in $cfgFiles) {
    if (-not (Test-Path -LiteralPath $cf)) { continue }
    foreach ($vn in @('OPENAI_API_KEY', 'CODEX_API_KEY', 'ANTHROPIC_API_KEY')) {
      $hit = $false
      try { $hit = [bool](Select-String -LiteralPath $cf -Pattern $vn -SimpleMatch -Quiet -ErrorAction Stop) } catch { }
      if ($hit) { Warn ($cf + ' mentions ' + $vn + ' (the line is not shown). Remove that entry by hand.') }
    }
  }
  foreach ($pn in @('PILLAGERS_GEMINI_KEY', 'PILLAGERS_OPENAI_KEY', 'PILLAGERS_OPENROUTER_KEY', 'PILLAGERS_XAI_KEY')) {
    $isSet = [bool]([Environment]::GetEnvironmentVariable($pn, 'User'))
    Say ('   ' + $pn.PadRight(26) + $(if ($isSet) { 'is set' } else { 'not set yet (you enter it with tools\ai-keys.ps1)' }))
  }

  # ---- the Pillagers health sweep
  Blank
  $gate = Test-ServicesAllowed
  $mode = ''
  if (-not $gate.Ok -and -not $Force) { $mode = '--dry'; foreach ($w in $gate.Why) { Say ('   report-only mode, because: ' + $w) } }
  $sweepProblems = -1
  $sweepNote = ''
  if (-not (Test-Path -LiteralPath (Join-Path $script:RepoRoot 'tools\health.sh')) -or -not (Find-BashExe)) {
    Warn 'tools\health.sh or Git bash is missing, so the health sweep is skipped.'
    $sweepNote = 'health sweep skipped'
  } elseif ($script:DryRun) {
    Dry ('run tools\health.sh ' + $mode + ' through a one-shot scheduled task (non-elevated) and print what it says')
  } else {
    $healthCmd = Join-Path $script:LaunchDir 'health-once.cmd'
    $out = Join-Path $script:WorkDir 'health-out.txt'
    $done = Join-Path $script:WorkDir 'health-done.txt'
    if (-not (Test-Path -LiteralPath $healthCmd)) {
      Ensure-Dir $script:LaunchDir
      $cmd = '@echo off' + "`r`n" + 'if exist "' + $done + '" del "' + $done + '"' + "`r`n" + '"' + (Find-BashExe) + '" "/c/claudecode/dark raiders/tools/health.sh" %1 > "' + $out + '" 2>&1' + "`r`n" + 'echo done> "' + $done + '"' + "`r`n"
      [System.IO.File]::WriteAllText($healthCmd, $cmd, [System.Text.Encoding]::ASCII)
    }
    if ($mode -eq '--dry') { Say 'The start check did not pass (see above), so the sweep runs in report-only mode (health.sh --dry): it will not start anything.' }
    Remove-Item -LiteralPath $out, $done -Force -ErrorAction SilentlyContinue
    $tn = 'Pillagers health once'
    $xml = Build-TaskXml -Desc 'One-shot Pillagers health sweep. Created and deleted by vm-setup.ps1.' -TriggerXml '' -Cmd $healthCmd -CmdArgs $mode -Enabled $true -Limit 'PT15M'
    $reg = $false
    try { Register-ScheduledTask -TaskName $tn -Xml $xml -Force -ErrorAction Stop | Out-Null; $reg = $true } catch { Warn ('could not create the one-shot task - ' + $_.Exception.Message) }
    if ($reg) {
      Say 'running tools\health.sh (up to 5 minutes) ...'
      try { Start-ScheduledTask -TaskName $tn -ErrorAction Stop } catch { Warn ('could not start the one-shot task - ' + $_.Exception.Message) }
      $t0 = Get-Date
      while (-not (Test-Path -LiteralPath $done) -and ((Get-Date) - $t0).TotalSeconds -lt 300) { Start-Sleep -Seconds 3 }
      try { Unregister-ScheduledTask -TaskName $tn -Confirm:$false -ErrorAction SilentlyContinue } catch { }
      if (Test-Path -LiteralPath $done) {
        $lines = Clean-Lines @(Read-TextFileSafe $out)
        $sweepProblems = 0
        $shown = 0
        foreach ($l in $lines) {
          if ($l -match '^PROBLEM:') { $sweepProblems++; Warn ('health.sh ' + $l) }
          elseif ($shown -lt 60) { Say ('   | ' + $l); $shown++ }
        }
        if (@($lines).Count -eq 0) { Warn 'health.sh printed nothing.' }
        $sweepNote = $sweepProblems.ToString() + ' problem line(s) from health.sh'
      } else { Warn 'health.sh did not finish in 5 minutes (or the task could not run: tasks only run while you are signed in on the VM console).'; $sweepNote = 'health sweep did not finish' }
    }
  }

  # ---- sign-in checklist (existence of files only; contents are never read)
  Blank
  Say 'SIGN-IN CHECKLIST (you do these; this script never signs in for you and never touches the login files):'
  $items = @(
    @('Claude Code', (Join-Path $script:VmProfile '.claude\.credentials.json'), 'open a terminal, run: claude   then type /login'),
    @('Claude desktop app', '', 'open Claude from the Start menu and sign in'),
    @('ChatGPT / Codex', (Join-Path $script:VmProfile '.codex\auth.json'), 'run: codex   and choose Sign in with ChatGPT (NOT an API key)'),
    @('Google agy', '', 'run: agy   once and sign in with your Google account'),
    @('GitHub', '', 'the first git push opens a sign-in window (Git Credential Manager)'),
    @('API keys (Console, Gemini, ...)', '', 'run  tools\ai-keys.ps1  yourself; it stores them under PILLAGERS_* names')
  )
  foreach ($it in $items) {
    $st = 'to do'
    if ($it[1]) { if (Test-Path -LiteralPath $it[1]) { $st = 'login file present' } else { $st = 'NOT signed in' } }
    Say ('   ' + $it[0].PadRight(34) + $st.PadRight(20) + $it[2])
  }
  $gh = $false
  try { $cm = Run-Proc -File 'cmdkey.exe' -ArgLine '/list' -TimeoutSec 20; $gh = (@($cm.Lines | Where-Object { $_ -match 'git:https://github\.com' }).Count -gt 0) } catch { }
  Say ('   GitHub stored sign-in'.PadRight(37) + $(if ($gh) { 'present' } else { 'none yet' }).PadRight(20) + '(checked by name only)')
  Say 'Also in the VM: open Chrome, go to chrome://gpu, and check Canvas and WebGL say Hardware accelerated.'

  if ($missingReq.Count -gt 0) { return (ResFail ('missing tools: ' + ($missingReq -join ', ') + '. Run vm-setup.ps1 -Only apps -AcceptLicences')) }
  if ($script:DryRun) { return (ResDone '(dry run) tools checked; the health sweep was not run') }
  return (ResDone ('all required tools are there; ' + $(if ($sweepNote) { $sweepNote } else { 'health sweep not run' }) + '; sign-ins are yours to do (list above)'))
}

# ======================================================================================================================
# the run
# ======================================================================================================================
function Invoke-Main {
  if (-not (Initialize-Context)) { return 1 }
  if ($UndoGpu) {
    Ensure-Dir $script:StateDir
    Ensure-Dir $script:UndoDir
    Ensure-Dir $script:WorkDir
    $rcU = Invoke-UndoGpu
    if ($script:RestartReasons.Count -gt 0) { Blank; Write-Log 'WARN' 'RESTART THE VM now (this script never restarts it for you).' 'Yellow' }
    Say ('log file: ' + $script:LogFile)
    return $rcU
  }
  $stages = Resolve-StageList
  if ($null -eq $stages) { return 2 }
  $script:Selected = @($stages)
  if ($script:Selected.Count -eq 0) { Say 'No stages selected (check -Only / -Skip).'; return 2 }
  Say ('stages to run: ' + ($script:Selected -join ', '))
  if ($script:DryRun) { Say 'DRY RUN: every stage only says what it would do.' }
  Ensure-Dir $script:StageRoot
  Ensure-Dir $script:WorkDir
  Ensure-Dir $script:StateDir
  Update-SessionPath

  foreach ($s in $script:AllStages) {
    if ($script:Selected -notcontains $s) { continue }
    if ($script:Abort -and -not ($script:AbortKeepHealth -and $s -eq 'health')) {
      $script:CurStage = $s
      [void]$script:Results.Add([pscustomobject]@{ Stage = $s; Status = 'SKIP'; Reason = 'an earlier stage stopped the run'; Seconds = 0 })
      Write-Log 'SKIP' 'SKIP: an earlier stage stopped the run' 'Yellow'
      continue
    }
    $script:CurStage = $s
    $script:StageWarn = 0
    $script:UndoRegs.Clear(); $script:UndoApps.Clear(); $script:UndoOther.Clear()
    Blank
    Write-Log 'START' ('START ' + $s) 'White'
    $t0 = Get-Date
    $res = $null
    try {
      $raw = & ('Stage-' + $s)
      $res = @($raw) | Where-Object { $_ -and $_.PSObject.Properties['Status'] } | Select-Object -Last 1
    } catch {
      $res = ResFail ('stopped by an unexpected error: ' + $_.Exception.Message)
      Write-Log 'FAIL' ('at ' + $_.InvocationInfo.ScriptLineNumber + ': ' + $_.InvocationInfo.Line.Trim()) 'Red'
    }
    if (-not $res) { $res = ResFail 'the stage returned no result (script bug)' }
    $secs = [int]((Get-Date) - $t0).TotalSeconds
    $warnTxt = ''
    if ($script:StageWarn -gt 0) { $warnTxt = '  (' + $script:StageWarn + ' warning(s))' }
    $col = 'Green'
    if ($res.Status -eq 'SKIP') { $col = 'Yellow' } elseif ($res.Status -eq 'FAIL') { $col = 'Red' }
    Write-Log $res.Status ($res.Status + ': ' + $res.Reason + $warnTxt + '  [' + $secs + ' s]') $col
    [void]$script:Results.Add([pscustomobject]@{ Stage = $s; Status = $res.Status; Reason = $res.Reason; Seconds = $secs })
    if ($s -eq 'files' -and $res.Status -eq 'FAIL') {
      # a half-unpacked tree must never be started: services stops, the health sweep still runs (report-only)
      $script:FilesFailed = $true
      $script:Abort = $true
      $script:AbortKeepHealth = $true
      Write-Log 'WARN' 'The files stage failed, so the services stage will not start anything. The health stage still runs, in report-only mode.' 'Yellow'
    }
  }

  # ---- summary
  $script:CurStage = ''
  Blank
  Write-Log 'INFO' '================ SUMMARY ================' 'White'
  $nFail = 0
  foreach ($r in $script:Results) {
    $c = 'Green'
    if ($r.Status -eq 'SKIP') { $c = 'Yellow' } elseif ($r.Status -eq 'FAIL') { $c = 'Red'; $nFail++ }
    Write-Log $r.Status ($r.Stage.PadRight(10) + ' ' + $r.Status.PadRight(5) + ' ' + $r.Reason) $c
  }
  if ($script:RestartReasons.Count -gt 0) {
    Blank
    Write-Log 'WARN' 'RESTART THE VM when this run is over (this script never restarts it for you). Reasons:' 'Yellow'
    foreach ($why in $script:RestartReasons) { Write-Log 'WARN' ('   - ' + $why) 'Yellow' }
  }
  Blank
  Write-Log 'INFO' 'NEXT:' 'White'
  if ($script:DryRun) { Say '   That was a dry run. Run again without -DryRun to do it.' }
  else {
    Say '   1. Restart the VM if it was asked for above, then run:  vm-setup.ps1 -Only gpu,health   (checks the Radeon and the tools)'
    Say '   2. Do the sign-ins in the checklist (health stage), and run tools\ai-keys.ps1 yourself for the API keys.'
    Say '   3. Open "Pillagers Dev" on the VM desktop. Work from now on only inside the VM.'
    Say '   4. To go back to the main PC: host-stop.ps1 -Undo there (and stop the runner here: Disable-ScheduledTask -TaskName "Pillagers runner").'
  }
  Say ('log file: ' + $script:LogFile)
  Say ('undo files (registry .reg and app lists): ' + $script:UndoDir)
  if ($nFail -gt 0) { return 1 }
  return 0
}

$script:ExitCode = 1
try { $script:ExitCode = [int](Invoke-Main | Select-Object -Last 1) }
catch {
  Write-Host ('The script stopped on an unexpected error: ' + $_.Exception.Message) -ForegroundColor Red
  try { [System.IO.File]::AppendAllText($script:LogFile, ('UNEXPECTED ERROR: ' + $_.Exception.Message + ' at line ' + $_.InvocationInfo.ScriptLineNumber + "`r`n"), [System.Text.Encoding]::ASCII) } catch { }
  $script:ExitCode = 1
}
exit $script:ExitCode
