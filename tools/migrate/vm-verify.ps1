<#
vm-verify.ps1  -  the MUST-PASS checklist for the Pillagers VM (VM name: Pillagers_Oct26)

WHAT IT IS
  A read-only health check you run INSIDE THE VM. It looks at everything that has to be true before the VM can replace the main PC
  (JUL26) for Pillagers, and prints one line per item: PASS, FAIL, WAIT or WARN, with a plain "fix:" line under every item that is not PASS.
  At the end it prints a count and one verdict line. Run it after Step 6 of MOVE-TO-VM.md, again after switch-over (S5), and any time
  something feels wrong. It is safe to run as often as you like.

HOW TO RUN (inside the VM, in a NORMAL Windows PowerShell window; no administrator window is needed)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-verify.ps1
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-verify.ps1 -DryRun      (lists the checks, tests nothing)
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-verify.ps1 -NoNetwork   (skips GitHub and Ollama)
  (the same file is also in the repo at C:\claudecode\dark raiders\tools\migrate\vm-verify.ps1)

WHAT THE WORDS MEAN
  PASS  this is right.
  FAIL  this is wrong and must be fixed. The fix line says how. After the switch-over nothing may FAIL.
  WAIT  this is not wrong yet: it is a step that is yours, or that cannot happen until an earlier step is done (a sign-in, a key, the
        switch-over itself). Everything that depends on "the main PC is stopped" shows WAIT until host-stopped.txt is valid, and FAIL after.
  WARN  only for the graphics card and the pad-route rule. Neither is needed to keep the helpers working; they matter for the party night.
  Exit code: 0 = no FAIL and no WAIT, 1 = at least one FAIL, 2 = no FAIL but something is still WAIT.

WHAT IT CHECKS (in this order)
   this machine     the computer name is not JUL26; C:\Users\User1 resolves to the real profile
   files and git    the repo is at C:\claudecode\dark raiders and git can read it; no leftover .git\index.lock (a restart can leave one); GitHub answers (git ls-remote, nothing is downloaded);
                    git can push (credential manager present and a GitHub sign-in stored, checked by NAME only; no push is made); commit identity
   tools            git, Git bash, node, python, Chrome (standard path), the Codex bundle and Gemini bundle beside node, agy, Claude Code, with versions
   packages         tools\console-sdk\node_modules is present (every dependency of its package.json)
   keys             which PILLAGERS_* variables exist (NAMES only; a value is never read, shown or logged); that OPENAI_API_KEY, CODEX_API_KEY and
                    ANTHROPIC_API_KEY do NOT exist; that PILLAGERS_OLLAMA_URL answers; that the Claude and Codex sign-in files exist (existence only)
   servers          8800, 8799, 8803, 8820 answer; 8802 answers to a bare HEAD request (no test traffic goes near the play port)
   always-on        the "Pillagers runner" task and its guard, the "Pillagers dev services" task, automatic sign-in after a restart (Autologon),
                    whether a Windows restart is already waiting
   switch-over      host-stopped.txt (the same strict rules as vm-setup.ps1: the code is copied from it), runner heartbeat age (under 20 minutes,
                    as health.sh), the last ship (under 180 minutes, as health.sh)
   resources        free disk space, free memory (the runner holds new jobs under 6 GB free), the graphics card (WARN only), the pad-route
                    firewall rule (WARN only; read from the registry, no firewall command is run)

WHAT IT NEVER DOES
  It never starts a lane, a ship, a server, the runner or a browser. It never changes a setting, a task, a file in the repo or the firewall.
  It writes only its own log (C:\PillagersMove\kit\logs\vm-verify-<time>.log). No secret value is read, printed or logged: key variables are
  looked at by NAME in the registry; the only value read is PILLAGERS_OLLAMA_URL (a web address, shown without any user:password part).
  git is run with --no-optional-locks (so it cannot collide with a ship), GIT_TERMINAL_PROMPT=0 and GCM_INTERACTIVE=never (so no sign-in window can pop up).
  ASCII only. Windows PowerShell 5.1.
#>
[CmdletBinding()]
param(
  [Alias('WhatIf')][switch]$DryRun,
  [switch]$NoNetwork,
  [string]$KitDir = '',
  [int]$TimeoutSec = 6
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# ----------------------------------------------------------------------------------------------------------------------
# constants (the VM keeps the files at the SAME absolute paths as the main PC)
# ----------------------------------------------------------------------------------------------------------------------
$script:ScriptVersion = 'vm-verify 1.0 (2026-10-19)'
$script:HostComputer = 'JUL26'
$script:RepoRoot = 'C:\claudecode\dark raiders'
$script:MirrorProfile = 'C:\Users\User1'
$script:Scratch = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$script:StageRoot = 'C:\PillagersMove'
$script:RunnerTask = 'Pillagers runner'
$script:DevTask = 'Pillagers dev services'
$script:HostNodeMajor = 24
$script:MinFreeRamGB = 6
# 10-19: the same floor the runner and the lanes use (RAM_FLOOR_GB in console\caps.txt; 3 in the 10 GB VM, 6 is the main PC's)
try { $m = Select-String -Path (Join-Path $script:RepoRoot 'tools\handoff\console\caps.txt') -Pattern '^RAM_FLOOR_GB=(\d+)' -ErrorAction Stop | Select-Object -First 1
  if ($m) { $script:MinFreeRamGB = [int]$m.Matches[0].Groups[1].Value } } catch { }
$script:MinFreeDiskGB = 15
$script:HeartbeatMaxMin = 20
$script:ShipMaxMin = 180
$script:PadRulePrefix = 'Pillagers pad route'
$script:DryRun = [bool]$DryRun
$script:NoNet = [bool]$NoNetwork
$script:HttpTimeout = $TimeoutSec

$script:Kit = $KitDir
if (-not $script:Kit) {
  if ($PSScriptRoot -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'host-stopped.txt'))) { $script:Kit = $PSScriptRoot }
  else { $script:Kit = Join-Path $script:StageRoot 'kit' }
}
$script:Kit = $script:Kit.TrimEnd('\')
$script:LogDir = Join-Path $script:Kit 'logs'
$script:LogFile = Join-Path $script:LogDir ('vm-verify-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
$script:LogOk = $false

# the servers (port, how to ask, what it is). 8802 is the play port: HEAD only, "any reply" counts, nothing else is ever sent to it.
$script:ServerSpecs = @(
  # 8800 and 8803 serve the tools folder. They are probed with tools\serve.ps1, a file that is always in the repo.
  # (tools\fixture.html is gitignored and only exists after mkfixture.ps1 has run, so on a fresh VM it would answer 404.)
  @{ Port = 8800; Method = 'HEAD'; Path = '/serve.ps1'; HostName = 'localhost'; What = 'test fixture server (tools folder)'; AnyReply = $false },
  @{ Port = 8799; Method = 'GET';  Path = '/';             HostName = 'localhost'; What = 'run-report collector'; AnyReply = $false },
  @{ Port = 8803; Method = 'HEAD'; Path = '/serve.ps1'; HostName = 'localhost'; What = 'test shard server'; AnyReply = $false },
  @{ Port = 8820; Method = 'GET';  Path = '/';             HostName = '127.0.0.1'; What = 'dev console server'; AnyReply = $false },
  @{ Port = 8802; Method = 'HEAD'; Path = '/';             HostName = 'localhost'; What = 'play server (HEAD only)'; AnyReply = $true }
)

$script:Results = New-Object System.Collections.ArrayList
$script:Section = ''
$script:Marker = $null
$script:SwitchDone = $false

# ----------------------------------------------------------------------------------------------------------------------
# output and log
# ----------------------------------------------------------------------------------------------------------------------
function Clean-Ascii([string]$s) {
  if ($null -eq $s) { return '' }
  return [System.Text.RegularExpressions.Regex]::Replace($s, '[^\x20-\x7E]', '?')
}
function Protect-Url([string]$u) {
  if (-not $u) { return '' }
  return [System.Text.RegularExpressions.Regex]::Replace($u, '://[^/@\s]+@', '://***@')
}
function Start-Log {
  # no log (and no folder) on a dry run, or if this is run on the main PC by mistake
  if ($script:DryRun -or ([string]$env:COMPUTERNAME -ieq $script:HostComputer)) { $script:LogOk = $false; return }
  try {
    if (-not (Test-Path -LiteralPath $script:LogDir)) { New-Item -ItemType Directory -Force -Path $script:LogDir -ErrorAction Stop | Out-Null }
    [System.IO.File]::WriteAllText($script:LogFile, ('# ' + $script:ScriptVersion + ' started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME + "`r`n"), [System.Text.Encoding]::ASCII)
    $script:LogOk = $true
  } catch { $script:LogOk = $false }
}
function Out-Line([string]$Text, [string]$Color = 'Gray') {
  $t = Clean-Ascii $Text
  Write-Host $t -ForegroundColor $Color
  if ($script:LogOk) { try { [System.IO.File]::AppendAllText($script:LogFile, $t + "`r`n", [System.Text.Encoding]::ASCII) } catch { } }
}
function Out-Blank { Out-Line '' }
function Out-Section([string]$Title) {
  $script:Section = $Title
  Out-Blank
  Out-Line ('== ' + $Title) 'Cyan'
}
function Add-Result([string]$State, [string]$Name, [string]$Detail = '', [string]$Fix = '') {
  $n = $script:Results.Count + 1
  $r = [pscustomobject]@{ N = $n; State = $State; Name = $Name; Detail = $Detail; Fix = $Fix; Section = $script:Section }
  [void]$script:Results.Add($r)
  $color = 'Gray'
  switch ($State) { 'PASS' { $color = 'Green' } 'FAIL' { $color = 'Red' } 'WAIT' { $color = 'Yellow' } 'WARN' { $color = 'DarkYellow' } }
  $line = '[' + $State + '] ' + $n.ToString().PadLeft(2) + '  ' + $Name
  if ($Detail) { $line += '  -  ' + $Detail }
  Out-Line $line $color
  if ($Fix -and $State -ne 'PASS') { Out-Line ('            fix: ' + $Fix) 'Gray' }
}
# a state that depends on the switch-over: WAIT before it, FAIL after it
function Get-GatedBad { if ($script:SwitchDone) { return 'FAIL' } return 'WAIT' }

# ----------------------------------------------------------------------------------------------------------------------
# small readers (all read-only)
# ----------------------------------------------------------------------------------------------------------------------
function Invoke-Tool {
  # runs one program with a time limit; returns Lines (stdout then stderr), ExitCode, TimedOut, Started, Error. No window, stdin closed.
  param([string]$File, [string]$ArgLine = '', [int]$Seconds = 30, [string]$WorkDir = '', [hashtable]$EnvVars = @{})
  $o = [pscustomobject]@{ Started = $false; ExitCode = -1; TimedOut = $false; Lines = @(); Error = '' }
  $p = $null
  try {
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $File
    $psi.Arguments = $ArgLine
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    $psi.CreateNoWindow = $true
    if ($WorkDir) { $psi.WorkingDirectory = $WorkDir }
    foreach ($k in $EnvVars.Keys) { $psi.EnvironmentVariables[[string]$k] = [string]$EnvVars[$k] }
    $p = [System.Diagnostics.Process]::Start($psi)
    $o.Started = $true
    try { $p.StandardInput.Close() } catch { }
    $so = $p.StandardOutput.ReadToEndAsync()
    $se = $p.StandardError.ReadToEndAsync()
    if (-not $p.WaitForExit($Seconds * 1000)) {
      $o.TimedOut = $true
      try { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null } catch { }
    } else {
      $p.WaitForExit()
      $o.ExitCode = $p.ExitCode
    }
    $txt = ''
    try { if ($so.Wait(3000)) { $txt += $so.Result } } catch { }
    try { if ($se.Wait(3000)) { $txt += "`n" + $se.Result } } catch { }
    $o.Lines = @($txt -split "`r?`n" | Where-Object { $_ -ne '' })
  } catch { $o.Error = $_.Exception.Message }
  finally { if ($p) { try { $p.Dispose() } catch { } } }
  return $o
}

function Test-HttpEndpoint {
  # one HTTP request; any reply at all (even 404) means "something answers". Returns Answered, Status, Body, Error.
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
    $req.UserAgent = 'pillagers-vm-verify'
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

function Find-GitExe {
  foreach ($p in @('C:\Program Files\Git\cmd\git.exe', 'C:\Program Files\Git\bin\git.exe')) { if (Test-Path -LiteralPath $p) { return $p } }
  $c = Get-Command git.exe -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.Source }
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
function Get-NodeDirReal {
  $n = Find-NodeExe
  if (-not $n) { return '' }
  try {
    $it = Get-Item -LiteralPath $n -Force
    if ($it.LinkType -and $it.Target) { $t = [string]($it.Target | Select-Object -First 1); if ($t -and (Test-Path -LiteralPath $t)) { $n = $t } }
  } catch { }
  return (Split-Path -Parent $n)
}
function Get-PackageVersion([string]$Dir, [string]$Rel) {
  $pj = Join-Path $Dir ('node_modules\' + $Rel + '\package.json')
  if (-not (Test-Path -LiteralPath $pj)) { return '' }
  try { return [string]((Get-Content -LiteralPath $pj -Raw | ConvertFrom-Json).version) } catch { return '' }
}
function Find-PythonReal {
  $c = Get-Command python.exe -ErrorAction SilentlyContinue | Where-Object { $_.Source -notmatch 'WindowsApps' } | Select-Object -First 1
  if ($c) { return $c.Source }
  foreach ($p in @((Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'), 'C:\Program Files\Python312\python.exe')) { if (Test-Path -LiteralPath $p) { return $p } }
  return ''
}
function Get-GitEnv { return @{ GIT_TERMINAL_PROMPT = '0'; GCM_INTERACTIVE = 'never'; GIT_OPTIONAL_LOCKS = '0' } }
function Get-GitProcessCount {
  # how many git commands are running right now (counted by process name only)
  try { return @(Get-Process -Name 'git' -ErrorAction SilentlyContinue).Count } catch { return 0 }
}
function Invoke-Git([string[]]$GitArgs, [int]$Seconds = 60) {
  $g = Find-GitExe
  if (-not $g) { return [pscustomobject]@{ Started = $false; ExitCode = -1; TimedOut = $false; Lines = @('git is not installed'); Error = 'git is not installed' } }
  $q = ($GitArgs | ForEach-Object { if ($_ -match '[\s"]') { '"' + ($_ -replace '"', '\"') + '"' } else { $_ } }) -join ' '
  return (Invoke-Tool -File $g -ArgLine $q -Seconds $Seconds -EnvVars (Get-GitEnv))
}
function Get-FirstLine($lines) { $a = @($lines); if ($a.Count -gt 0) { return ([string]$a[0]).Trim() } return '' }

# registry NAMES only (a value is never read here)
function Get-RegValueNames([string]$Hive, [string]$SubKey) {
  $key = $null
  $names = @()
  try {
    if ($Hive -eq 'HKCU') { $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($SubKey) }
    else { $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($SubKey) }
    if ($null -ne $key) { $names = @($key.GetValueNames()) }
  } catch { $names = @() }
  finally { if ($null -ne $key) { try { $key.Close() } catch { } } }
  return $names
}
function Get-OllamaUrl {
  # PILLAGERS_OLLAMA_URL is a web address, not a secret. User variable first (what ship-review.ps1 reads), then this window's own.
  $u = [string][Environment]::GetEnvironmentVariable('PILLAGERS_OLLAMA_URL', 'User')
  if (-not $u) { $u = [string]$env:PILLAGERS_OLLAMA_URL }
  return $u
}
function Get-AutologonFacts {
  # Winlogon settings that Sysinternals Autologon writes. The password is NOT in the registry (it is an LSA secret); a DefaultPassword value
  # would be the plain-text kind, so only its NAME is looked for. HelloBuild is the "Windows Hello only" switch (non-zero blocks automatic sign-in).
  $o = [pscustomobject]@{ AutoAdminLogon = ''; DefaultUserName = ''; HasPlainPassword = $false; HelloBuild = $null; LegalNotice = $false }
  $wl = 'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  $o.HasPlainPassword = (@(Get-RegValueNames 'HKLM' $wl) -contains 'DefaultPassword')
  try {
    $k = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($wl)
    if ($null -ne $k) { $o.AutoAdminLogon = [string]$k.GetValue('AutoAdminLogon'); $o.DefaultUserName = [string]$k.GetValue('DefaultUserName'); $k.Close() }
  } catch { }
  try {
    $hk = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device')
    if ($null -ne $hk) { $o.HelloBuild = $hk.GetValue('DevicePasswordLessBuildVersion'); $hk.Close() }
  } catch { }
  try {
    # a sign-in "legal notice" waits for a click before any sign-in, automatic or not (the text is policy text, not a secret; only whether it is set is kept)
    $pk = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System')
    if ($null -ne $pk) { if (([string]$pk.GetValue('legalnoticecaption')).Trim([char]0,' ') -or ([string]$pk.GetValue('legalnoticetext')).Trim([char]0,' ')) { $o.LegalNotice = $true }; $pk.Close() }
  } catch { }
  return $o
}
function Get-PendingRestartReasons {
  $pend = New-Object System.Collections.ArrayList
  try { if (Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { [void]$pend.Add('Windows servicing') } } catch { }
  try { if (Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { [void]$pend.Add('Windows Update') } } catch { }
  return $pend.ToArray()
}
function Get-EnvNames([string]$Scope) {
  if ($Scope -eq 'User') { return @(Get-RegValueNames 'HKCU' 'Environment') }
  return @(Get-RegValueNames 'HKLM' 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment')
}

# ----------------------------------------------------------------------------------------------------------------------
# firewall rules, read from the registry (no firewall command is run; the key can be read without administrator rights)
# ----------------------------------------------------------------------------------------------------------------------
function ConvertFrom-FirewallRuleText([string]$Text) {
  if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
  $r = @{ Name = ''; Action = ''; Active = ''; Dir = ''; Protocol = ''; LPort = @(); RPort = @(); RA4 = @(); RA6 = @(); App = '' }
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
      '^RPort' { $r.RPort += @($v -split ',' | Where-Object { $_ }) }
      '^RA4$' { $r.RA4 += @($v -split ',' | Where-Object { $_ }) }
      '^RA6$' { $r.RA6 += @($v -split ',' | Where-Object { $_ }) }
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
function Test-PadRule($Rule) {
  # Returns Ok and Problems for one rule named "Pillagers pad route...": inbound, allow, TCP, on 8802 and 8799 only, from named addresses only.
  $prob = New-Object System.Collections.ArrayList
  if ([string]$Rule.Active -ne 'TRUE') { [void]$prob.Add('the rule is switched off') }
  if ([string]$Rule.Dir -ne 'In') { [void]$prob.Add('it is not an inbound rule') }
  if ([string]$Rule.Action -ne 'Allow') { [void]$prob.Add('it does not say Allow') }
  if ([string]$Rule.Protocol -ne '6') { [void]$prob.Add('it is not TCP-only') }
  $ports = @($Rule.LPort | ForEach-Object { [string]$_ })
  if ($ports.Count -eq 0 -or $ports -contains '*') { [void]$prob.Add('it covers every port') }
  else {
    foreach ($need in @('8802', '8799')) { if ($ports -notcontains $need) { [void]$prob.Add('port ' + $need + ' is missing') } }
    $extra = @($ports | Where-Object { $_ -ne '8802' -and $_ -ne '8799' })
    if ($extra.Count -gt 0) { [void]$prob.Add('it also opens: ' + ($extra -join ', ')) }
  }
  $ra = @($Rule.RA4 + $Rule.RA6 | ForEach-Object { [string]$_ })
  if ($ra.Count -eq 0) { [void]$prob.Add('it lets in every address') }
  else {
    foreach ($a in $ra) {
      if ($a -match '^(\*|Any|LocalSubnet|0\.0\.0\.0/0|0\.0\.0\.0-255\.255\.255\.255|::/0)$') { [void]$prob.Add('it lets in ' + $a) }
    }
  }
  return [pscustomobject]@{ Ok = ($prob.Count -eq 0); Problems = $prob.ToArray(); Remote = ($ra -join ', ') }
}

# ----------------------------------------------------------------------------------------------------------------------
# host-stopped.txt : COPIED from vm-setup.ps1 (Get-MarkerCheck and Get-MarkerInfo). Keep the two identical; they are the strict rules the
# runner guard and the services stage use, so this checklist and the runner can never disagree about whether the main PC is stopped.
# ----------------------------------------------------------------------------------------------------------------------
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

# ----------------------------------------------------------------------------------------------------------------------
# the checks
# ----------------------------------------------------------------------------------------------------------------------
function Check-Machine {
  Out-Section 'THIS MACHINE'
  $cn = [string]$env:COMPUTERNAME
  $model = ''
  try { $model = [string](Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).Model } catch { }
  if ($cn -ieq $script:HostComputer) {
    Add-Result 'FAIL' 'this is the VM, not the main PC' ('computer name is ' + $cn) 'You are on the MAIN PC. Run this inside the VM window (Hyper-V Manager > Pillagers_Oct26 > Connect). Nothing was changed.'
  } else {
    $d = 'computer ' + $cn + ', user ' + $env:USERNAME
    if ($model) { $d += ', model "' + $model + '"' }
    if ($model -and $model -notmatch 'Virtual') { $d += ' (this does not look like a Hyper-V VM; fine if you built the VM another way)' }
    Add-Result 'PASS' 'this is the VM, not the main PC' $d
  }

  $mirror = $script:MirrorProfile
  $real = [string]$env:USERPROFILE
  if ($real -ieq $mirror) {
    Add-Result 'PASS' 'C:\Users\User1 is the real profile' 'the VM user is User1 itself, so no link is needed'
  } elseif (-not (Test-Path -LiteralPath $mirror)) {
    Add-Result 'FAIL' 'C:\Users\User1 resolves to the real profile' ('C:\Users\User1 does not exist; your profile is ' + $real) 'Scripts and helper paths say C:\Users\User1. In an administrator window run: vm-setup.ps1 -Only files   (it makes the link).'
  } else {
    $it = $null
    try { $it = Get-Item -LiteralPath $mirror -Force -ErrorAction Stop } catch { }
    $isLink = ($null -ne $it) -and (($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0)
    $tgt = ''
    if ($isLink) { try { $tgt = [string]($it.Target | Select-Object -First 1) } catch { } }
    if (-not $isLink) {
      Add-Result 'FAIL' 'C:\Users\User1 resolves to the real profile' ('C:\Users\User1 is a plain folder, not a link to ' + $real) 'It must be a link (junction) to your profile. Rename or remove the empty folder, then in an administrator window run: vm-setup.ps1 -Only files'
    } elseif ($tgt -and ($tgt.TrimEnd('\') -ine $real.TrimEnd('\'))) {
      Add-Result 'FAIL' 'C:\Users\User1 resolves to the real profile' ('the link points to ' + $tgt + ' but your profile is ' + $real) 'Remove the wrong link by hand (rmdir C:\Users\User1) and run vm-setup.ps1 -Only files in an administrator window.'
    } elseif (-not (Test-Path -LiteralPath (Join-Path $mirror 'AppData\Local'))) {
      Add-Result 'FAIL' 'C:\Users\User1 resolves to the real profile' 'the link exists but C:\Users\User1\AppData\Local cannot be opened through it' 'Run vm-setup.ps1 -Only files in an administrator window to remake the link.'
    } else {
      Add-Result 'PASS' 'C:\Users\User1 resolves to the real profile' ('link to ' + $real)
    }
  }
  if (Test-Path -LiteralPath $script:Scratch) { Add-Result 'PASS' 'the helper scratch folder exists' 'the scratchpad path the lane scripts use is there' }
  else { Add-Result 'FAIL' 'the helper scratch folder exists' 'the scratchpad folder named in the lane scripts is missing' 'Run vm-setup.ps1 -Only files in an administrator window (it creates it), or create the folder by hand.' }
}

function Check-Repo {
  Out-Section 'FILES AND GIT'
  $repo = $script:RepoRoot
  $git = Find-GitExe
  if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) {
    Add-Result 'FAIL' 'the repo is at C:\claudecode\dark raiders' 'there is no .git folder there' 'The Pillagers files are not unpacked. Run vm-setup.ps1 -Only files in an administrator window (Step 4 / S5 of the guide).'
  } elseif (-not $git) {
    Add-Result 'FAIL' 'the repo is at C:\claudecode\dark raiders' 'git is not installed, so the repo cannot be read' 'Run vm-setup.ps1 -Only apps -AcceptLicences in an administrator window.'
  } else {
    $h = Invoke-Git @('-C', $repo, 'rev-parse', 'HEAD') 60
    $headLine = Get-FirstLine $h.Lines
    if ($h.ExitCode -ne 0 -or $headLine -notmatch '^[0-9a-f]{40}$') {
      $why = Clean-Ascii ((@($h.Lines) | Select-Object -First 2) -join ' / ')
      $fixText = 'Run vm-setup.ps1 -Only files in an administrator window.'
      if ($why -match 'dubious') { $fixText = 'git says the folder has another owner. Run vm-setup.ps1 -Only files in an administrator window (it marks the folder safe).' }
      Add-Result 'FAIL' 'the repo is at C:\claudecode\dark raiders' ('git cannot read HEAD: ' + $why) $fixText
    } else {
      $br = Invoke-Git @('-C', $repo, '--no-optional-locks', 'rev-parse', '--abbrev-ref', 'HEAD') 60
      $branch = Get-FirstLine $br.Lines
      $st = Invoke-Git @('-C', $repo, '--no-optional-locks', 'status', '--porcelain') 240
      if ($st.ExitCode -ne 0) {
        Add-Result 'FAIL' 'the repo is at C:\claudecode\dark raiders' ('HEAD ' + $headLine.Substring(0, 12) + ' reads fine but "git status" failed: ' + (Clean-Ascii ((@($st.Lines) | Select-Object -First 1) -join ''))) 'Run vm-setup.ps1 -Only files in an administrator window; if it persists tell Claude in the VM.'
      } else {
        $changed = @($st.Lines).Count
        Add-Result 'PASS' 'the repo is at C:\claudecode\dark raiders' ('branch ' + $branch + ', HEAD ' + $headLine.Substring(0, 12) + ', git status works, ' + $changed + ' changed/untracked file(s) right now')
      }
    }
  }

  # a restart (Windows Update, power cut) or crash in the middle of a git command leaves .git\index.lock behind; every later commit then fails until it is deleted
  if (Test-Path -LiteralPath (Join-Path $repo '.git')) {
    $il = Join-Path $repo '.git\index.lock'
    if (-not (Test-Path -LiteralPath $il)) {
      Add-Result 'PASS' 'no leftover git lock (.git\index.lock)' 'there is none'
    } else {
      $ageMin = 0
      try { $ageMin = [int][math]::Floor(((Get-Date) - (Get-Item -LiteralPath $il -Force).LastWriteTime).TotalMinutes) } catch { }
      $gitRunning = [int](Get-GitProcessCount)
      if ($gitRunning -gt 0 -or $ageMin -lt 10) {
        Add-Result 'PASS' 'no leftover git lock (.git\index.lock)' ('index.lock exists but is ' + $ageMin + ' minute(s) old' + $(if ($gitRunning -gt 0) { ' and ' + $gitRunning + ' git command(s) are running, so it is in use' } else { ', young enough to be in use' }))
      } else {
        Add-Result 'FAIL' 'no leftover git lock (.git\index.lock)' ('index.lock is ' + $ageMin + ' minutes old and no git command is running: a restart or crash left it behind, and every ship will fail on it') 'Make sure no ship is running (vm-verify and the log say), then delete only that one file: del "C:\claudecode\dark raiders\.git\index.lock". Never delete anything else inside .git, and never the ship lock (that one is cleared only by tools/handoff/shipkit/clearstale.sh).'
      }
    }
  }

  # GitHub answers: ls-remote only reads the list of branches; nothing is downloaded or changed, no sign-in is needed for a public repo
  $origin = ''
  if ($git -and (Test-Path -LiteralPath (Join-Path $repo '.git'))) { $origin = Get-FirstLine (Invoke-Git @('-C', $repo, 'config', '--get', 'remote.origin.url') 30).Lines }
  $originShown = Protect-Url $origin
  if ($script:NoNet) {
    Add-Result 'WAIT' 'GitHub answers (git ls-remote origin)' 'not tested because of -NoNetwork' 'Run again without -NoNetwork.'
  } elseif (-not $git -or -not $origin) {
    Add-Result 'FAIL' 'GitHub answers (git ls-remote origin)' $(if (-not $git) { 'git is not installed' } else { 'the repo has no remote called origin' }) 'Tell Claude in the VM; origin must be https://github.com/dbmosser/pillagers.'
  } else {
    $lr = Invoke-Git @('-C', $repo, 'ls-remote', '--heads', 'origin', 'master') 60
    $ref = Get-FirstLine $lr.Lines
    if ($lr.TimedOut) { Add-Result 'FAIL' 'GitHub answers (git ls-remote origin)' ('no reply from ' + $originShown + ' in 60 seconds') 'Check the VM has internet (open a web page in Chrome). If Chrome works, tell Claude in the VM.' }
    elseif ($lr.ExitCode -eq 0 -and $ref -match '^([0-9a-f]{40})\s+refs/heads/master') { Add-Result 'PASS' 'GitHub answers (git ls-remote origin)' ('origin ' + $originShown + ', master is at ' + $Matches[1].Substring(0, 12)) }
    elseif ($lr.ExitCode -eq 0) { Add-Result 'FAIL' 'GitHub answers (git ls-remote origin)' ('origin ' + $originShown + ' answers but has no branch called master') 'Tell Claude in the VM; the ships push to master.' }
    else { Add-Result 'FAIL' 'GitHub answers (git ls-remote origin)' ('git could not reach ' + $originShown + ': ' + (Clean-Ascii ((@($lr.Lines) | Select-Object -First 1) -join ''))) 'Check the VM has internet and that the origin address is right (git remote -v in the repo).' }
  }
  if ($origin -match '://[^/@\s]+@') { Add-Result 'FAIL' 'no password or token inside the remote address' 'the origin address contains user information (shown hidden)' 'Remove it: git remote set-url origin https://github.com/dbmosser/pillagers.git   (tokens in an address leak into logs). Use the credential manager sign-in instead.' }

  # push sign-in: checked by NAME only; no push is made, because a push attempt is what opens the sign-in window
  if (-not $git) {
    Add-Result 'FAIL' 'git can push (credential manager and a stored sign-in)' 'git is not installed' 'Run vm-setup.ps1 -Only apps -AcceptLicences in an administrator window.'
  } else {
    $helpers = @((Invoke-Git @('config', '--get-all', 'credential.helper') 30).Lines | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ })
    $gcm = Invoke-Git @('credential-manager', '--version') 30
    $gcmOk = ($gcm.ExitCode -eq 0 -and (Get-FirstLine $gcm.Lines) -match '\d+\.\d+')
    $stored = $false
    try { $cm = Invoke-Tool -File 'cmdkey.exe' -ArgLine '/list' -Seconds 20; $stored = (@($cm.Lines | Where-Object { $_ -match 'git:https://github\.com' }).Count -gt 0) } catch { }
    $helperTxt = ($helpers -join ', ')
    if ($helpers.Count -eq 0 -or -not $gcmOk) {
      Add-Result 'FAIL' 'git can push (credential manager and a stored sign-in)' ('credential helper: ' + $(if ($helperTxt) { $helperTxt } else { 'none' }) + '; Git Credential Manager: ' + $(if ($gcmOk) { Get-FirstLine $gcm.Lines } else { 'not found' })) 'Reinstall Git for Windows (it brings the credential manager): vm-setup.ps1 -Only apps -AcceptLicences in an administrator window.'
    } elseif (-not $stored) {
      Add-Result 'WAIT' 'git can push (credential manager and a stored sign-in)' ('helper ' + $helperTxt + ' is set up (Git Credential Manager ' + (Get-FirstLine $gcm.Lines) + '); no GitHub sign-in is stored yet') 'Sign in to GitHub once: ask Claude in the VM to do the first push (a window opens, you sign in). Note "git fetch" never asks for a login on a public repo, so it does not prove anything.'
    } else {
      Add-Result 'PASS' 'git can push (credential manager and a stored sign-in)' ('helper ' + $helperTxt + ', Git Credential Manager ' + (Get-FirstLine $gcm.Lines) + ', a GitHub sign-in is stored (checked by name only; no push was made)')
    }
    $nm = Get-FirstLine (Invoke-Git @('-C', $repo, 'config', '--get', 'user.name') 30).Lines
    $em = Get-FirstLine (Invoke-Git @('-C', $repo, 'config', '--get', 'user.email') 30).Lines
    if ($nm -and $em) { Add-Result 'PASS' 'git has a commit name and email' 'user.name and user.email are set (not shown)' }
    else { Add-Result 'FAIL' 'git has a commit name and email' ('missing: ' + $(if (-not $nm) { 'user.name ' }) + $(if (-not $em) { 'user.email' })) 'Without them every ship fails with "Author identity unknown". Copy the main PC values: git config --global user.name "..." and git config --global user.email "..."  (ask Claude in the VM).' }
  }
}

function Check-Tools {
  Out-Section 'TOOLS'
  $git = Find-GitExe
  if ($git) { Add-Result 'PASS' 'git' (Get-FirstLine (Invoke-Tool -File $git -ArgLine '--version' -Seconds 30).Lines) }
  else { Add-Result 'FAIL' 'git' 'not found' 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }

  $bash = 'C:\Program Files\Git\bin\bash.exe'
  if (Test-Path -LiteralPath $bash) { Add-Result 'PASS' 'Git bash (the lane scripts run in it)' $bash }
  else { Add-Result 'FAIL' 'Git bash (the lane scripts run in it)' 'C:\Program Files\Git\bin\bash.exe is missing' 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }

  $node = Find-NodeExe
  $nd = ''
  if ($node) {
    $nv = Get-FirstLine (Invoke-Tool -File $node -ArgLine '--version' -Seconds 30).Lines
    $note = ''
    if ($nv -match '^v(\d+)\.' -and [int]$Matches[1] -ne $script:HostNodeMajor) { $note = ' (the main PC runs v' + $script:HostNodeMajor + '; a different major version can change how the helpers behave)' }
    Add-Result 'PASS' 'node' ($nv + ' at ' + $node + $note)
    $nd = Get-NodeDirReal
  } else { Add-Result 'FAIL' 'node' 'not found' 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }

  $py = Find-PythonReal
  if ($py) { Add-Result 'PASS' 'python' ((Get-FirstLine (Invoke-Tool -File $py -ArgLine '--version' -Seconds 30).Lines) + ' at ' + $py) }
  else { Add-Result 'WAIT' 'python' 'not installed (no lane needs it; it is only for ad-hoc page servers such as the survey pages)' 'When you want it: vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }

  $chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
  if (Test-Path -LiteralPath $chrome) { Add-Result 'PASS' 'Chrome at the standard path' ('version ' + (Get-Item -LiteralPath $chrome).VersionInfo.ProductVersion) }
  else { Add-Result 'FAIL' 'Chrome at the standard path' ('not at ' + $chrome + ' (the test scripts look exactly there)') 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }

  if ($nd) {
    $codexJs = Join-Path $nd 'node_modules\@openai\codex\bin\codex.js'
    if (Test-Path -LiteralPath $codexJs) { Add-Result 'PASS' 'Codex bundle beside node' ('version ' + (Get-PackageVersion $nd '@openai\codex') + ' in ' + $nd) }
    else { Add-Result 'FAIL' 'Codex bundle beside node' ('missing: ' + $codexJs) 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window); it installs the same version as the main PC.' }
    $gemJs = Join-Path $nd 'node_modules\@google\gemini-cli\bundle\gemini.js'
    if (Test-Path -LiteralPath $gemJs) { Add-Result 'PASS' 'Gemini bundle beside node' ('version ' + (Get-PackageVersion $nd '@google\gemini-cli') + ' in ' + $nd) }
    else { Add-Result 'FAIL' 'Gemini bundle beside node' ('missing: ' + $gemJs) 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }
  } else {
    Add-Result 'FAIL' 'Codex bundle beside node' 'cannot look: node was not found' 'Install node first (see above).'
    Add-Result 'FAIL' 'Gemini bundle beside node' 'cannot look: node was not found' 'Install node first (see above).'
  }

  $agy = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
  if (Test-Path -LiteralPath $agy) {
    $av = ''
    try { $av = [string](Get-Item -LiteralPath $agy).VersionInfo.ProductVersion } catch { }
    Add-Result 'PASS' 'agy (the Google bug checker)' $(if ($av) { 'version ' + $av + ' at ' + $agy } else { $agy })
  } else { Add-Result 'FAIL' 'agy (the Google bug checker)' ('missing: ' + $agy + ' (ship-review.ps1 looks exactly there)') 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window); then run agy once and sign in with your Google account.' }

  $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
  if (Test-Path -LiteralPath $claude) {
    $cv = Invoke-Tool -File $claude -ArgLine '--version' -Seconds 60
    if ($cv.TimedOut -or $cv.ExitCode -ne 0) { Add-Result 'FAIL' 'Claude Code' ('claude.exe is there but "--version" failed (' + $(if ($cv.TimedOut) { 'timed out' } else { 'exit ' + $cv.ExitCode }) + ')') 'Reinstall Claude Code with the official installer (vm-setup.ps1 -Only apps -AcceptLicences).' }
    else { Add-Result 'PASS' 'Claude Code' (Get-FirstLine $cv.Lines) }
  } else { Add-Result 'FAIL' 'Claude Code' ('missing: ' + $claude) 'vm-setup.ps1 -Only apps -AcceptLicences (administrator window).' }
}

function Check-Packages {
  Out-Section 'PACKAGES'
  $sdk = Join-Path $script:RepoRoot 'tools\console-sdk'
  $pj = Join-Path $sdk 'package.json'
  if (-not (Test-Path -LiteralPath $pj)) { Add-Result 'FAIL' 'console-sdk packages (node_modules)' 'tools\console-sdk\package.json is missing' 'The repo files are not unpacked: vm-setup.ps1 -Only files (administrator window).'; return }
  $deps = @()
  try { $j = Get-Content -LiteralPath $pj -Raw | ConvertFrom-Json; if ($j.dependencies) { $deps = @($j.dependencies.PSObject.Properties | ForEach-Object { $_.Name }) } } catch { }
  $nm = Join-Path $sdk 'node_modules'
  if (-not (Test-Path -LiteralPath $nm)) { Add-Result 'FAIL' 'console-sdk packages (node_modules)' 'tools\console-sdk\node_modules is missing; the Console helper lanes cannot start' 'In an administrator window: vm-setup.ps1 -Only services   (it runs npm ci there), or in tools\console-sdk run: npm ci'; return }
  $missing = @()
  foreach ($d in $deps) { if (-not (Test-Path -LiteralPath (Join-Path $nm ($d + '\package.json')))) { $missing += $d } }
  if ($missing.Count -gt 0) { Add-Result 'FAIL' 'console-sdk packages (node_modules)' ('node_modules exists but these packages are missing: ' + ($missing -join ', ')) 'In tools\console-sdk run: npm ci' }
  else { Add-Result 'PASS' 'console-sdk packages (node_modules)' ('present; ' + $deps.Count + ' dependency(ies) from package.json found') }
}

function Check-Keys {
  Out-Section 'KEYS AND SIGN-INS (names only; no value is read or shown)'
  $userNames = @(Get-EnvNames 'User')
  $machNames = @(Get-EnvNames 'Machine')
  $all = @($userNames + $machNames)
  $pil = @($all | Where-Object { $_ -like 'PILLAGERS_*' } | Sort-Object -Unique)
  Out-Line ('            PILLAGERS_* variables found (names): ' + $(if ($pil.Count -gt 0) { $pil -join ', ' } else { '(none)' })) 'Gray'
  $need = @(
    @{ N = 'PILLAGERS_API_KEY'; W = 'the Console helper lanes (console-lane.sh, review-nightly.sh, critic.mjs)'; How = 'tools\ai-keys.ps1 console' },
    @{ N = 'PILLAGERS_ADMIN_KEY'; W = 'the real-spend report (balance.mjs)'; How = 'tools\ai-keys.ps1 admin' }
  )
  foreach ($k in $need) {
    if ($all -contains $k.N) { Add-Result 'PASS' ($k.N + ' exists') ('set, for ' + $k.W) }
    else { Add-Result 'WAIT' ($k.N + ' exists') ('not set yet (needed for ' + $k.W + ')') ('Keys do not travel with the files. YOU run, in a normal window in the VM: powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\' + $k.How + '"  and paste the key when it asks.') }
  }
  $opt = @('PILLAGERS_GEMINI_KEY', 'PILLAGERS_OPENAI_KEY', 'PILLAGERS_OPENROUTER_KEY', 'PILLAGERS_XAI_KEY')
  $have = @($opt | Where-Object { $all -contains $_ })
  $lack = @($opt | Where-Object { $all -notcontains $_ })
  Add-Result 'PASS' 'other AI service keys (optional)' ('set: ' + $(if ($have.Count -gt 0) { $have -join ', ' } else { 'none' }) + '; not set: ' + $(if ($lack.Count -gt 0) { $lack -join ', ' } else { 'none' }) + ' (the same as on the main PC? add what you used there with tools\ai-keys.ps1)')

  # the three names that must NOT exist (they make the helpers bill an API account instead of using the sign-ins)
  $bad = @()
  foreach ($vn in @('OPENAI_API_KEY', 'CODEX_API_KEY', 'ANTHROPIC_API_KEY')) {
    if (($all -contains $vn) -or (Test-Path -LiteralPath ('Env:\' + $vn))) { $bad += $vn }
  }
  if ($bad.Count -gt 0) { Add-Result 'FAIL' 'OPENAI_API_KEY, CODEX_API_KEY, ANTHROPIC_API_KEY do not exist' ('these exist: ' + ($bad -join ', ')) 'Remove them (Start > "Edit environment variables for your account"), then open new windows. They make the helpers bill an API account instead of your plan. This checklist never sets or removes them.' }
  else { Add-Result 'PASS' 'OPENAI_API_KEY, CODEX_API_KEY, ANTHROPIC_API_KEY do not exist' 'none of the three is set (good)' }

  # PILLAGERS_OLLAMA_URL is a web address, not a secret; it is the one value read here
  $url = ([string](Get-OllamaUrl)).Trim()
  $gw = ''
  try { $gw = [string](Get-NetRoute -DestinationPrefix '0.0.0.0/0' -ErrorAction Stop | Sort-Object RouteMetric | Select-Object -First 1).NextHop } catch { }
  $setHint = 'On the MAIN PC run host-ollama-bridge.ps1 -Install (administrator window), then in the VM: [Environment]::SetEnvironmentVariable(''PILLAGERS_OLLAMA_URL'', ''http://' + $(if ($gw) { $gw } else { '192.168.160.1' }) + ':11434'', ''User'')   and open new windows.'
  if (-not $url) {
    Add-Result 'WAIT' 'PILLAGERS_OLLAMA_URL answers' 'the variable is not set yet (the local-AI audits would run on nothing)' $setHint
  } elseif ($url -notmatch '^https?://(localhost|127(\.\d{1,3}){3}|10(\.\d{1,3}){3}|192\.168(\.\d{1,3}){2}|172\.(1[6-9]|2\d|3[01])(\.\d{1,3}){2})(:\d{1,5})?/*$') {
    Add-Result 'FAIL' 'PILLAGERS_OLLAMA_URL answers' ('the value is not a plain http://<private address>:port address (ship-review.ps1 and llm-night.ps1 ignore anything else and use this VM instead): ' + (Protect-Url $url)) $setHint
  } elseif ($script:NoNet) {
    Add-Result 'WAIT' 'PILLAGERS_OLLAMA_URL answers' ('set to ' + (Protect-Url $url) + '; not tested because of -NoNetwork') 'Run again without -NoNetwork.'
  } else {
    $base = $url.TrimEnd('/')
    $r = Test-HttpEndpoint -Url ($base + '/api/tags') -Method 'GET' -Seconds $script:HttpTimeout -ReadBody
    if ($r.Answered -and $r.Status -eq 200) {
      $n = -1
      try { $n = @(($r.Body | ConvertFrom-Json).models).Count } catch { }
      Add-Result 'PASS' 'PILLAGERS_OLLAMA_URL answers' ((Protect-Url $base) + ' answers' + $(if ($n -ge 0) { ', ' + $n + ' model(s) listed' } else { '' }))
    } elseif ($r.Answered) {
      Add-Result 'FAIL' 'PILLAGERS_OLLAMA_URL answers' ((Protect-Url $base) + ' replied with HTTP ' + $r.Status + ' (not Ollama?)') ('Check the address. ' + $setHint)
    } else {
      Add-Result 'FAIL' 'PILLAGERS_OLLAMA_URL answers' ((Protect-Url $base) + ' does not answer (' + (Clean-Ascii $r.Error) + ')') 'On the MAIN PC: Ollama must be running and host-ollama-bridge.ps1 -Status must say the bridge is on; the main PC address may have changed after a restart (look at the address above).'
    }
  }

  # sign-in files: existence only, contents never read
  $cc = Join-Path $env:USERPROFILE '.claude\.credentials.json'
  if (Test-Path -LiteralPath $cc) { Add-Result 'PASS' 'Claude Code is signed in' 'the login file exists (contents not read)' }
  else { Add-Result 'WAIT' 'Claude Code is signed in' 'no login file yet' 'YOU: open "Claude Code - Pillagers" from the desktop, type /login and sign in with your Claude account.' }
  $cx = Join-Path $env:USERPROFILE '.codex\auth.json'
  if (Test-Path -LiteralPath $cx) { Add-Result 'PASS' 'Codex (ChatGPT) is signed in' 'the login file exists (contents not read)' }
  else { Add-Result 'WAIT' 'Codex (ChatGPT) is signed in' 'no login file yet' 'YOU: run  codex  in a window and choose "Sign in with ChatGPT" (never an API key).' }
}

function Check-Servers {
  Out-Section 'SERVERS (this VM only; nothing is sent to 8802 except a bare HEAD)'
  foreach ($s in $script:ServerSpecs) {
    $url = 'http://' + $s.HostName + ':' + $s.Port + $s.Path
    $name = 'port ' + $s.Port + ' answers'
    $r = Test-HttpEndpoint -Url $url -Method $s.Method -Seconds $script:HttpTimeout
    if ($r.Answered -and ($r.Status -eq 200 -or $s.AnyReply)) {
      Add-Result 'PASS' $name ($s.What + ': ' + $s.Method + ' ' + $s.Path + ' -> HTTP ' + $r.Status)
    } elseif ($r.Answered) {
      Add-Result 'FAIL' $name ($s.What + ': answers with HTTP ' + $r.Status + ' instead of 200 (wrong folder served?)') 'Stop that server and start it again from the right folder: powershell -File "C:\claudecode\dark raiders\tools\start-servers.ps1" (it leaves working ports alone).'
    } else {
      $fixText = 'Start the servers: Start-ScheduledTask -TaskName "' + $script:DevTask + '"   (or run tools\start-servers.ps1). They only start while you are signed in on the VM console.'
      if ($s.Port -eq 8820) { $fixText = 'Start the dev console: Start-ScheduledTask -TaskName "' + $script:DevTask + '"  (it runs tools\devdash\server.mjs).' }
      Add-Result (Get-GatedBad) $name ($s.What + ': nothing answers on ' + $s.HostName + ':' + $s.Port + $(if (-not $script:SwitchDone) { ' (not expected until the main PC is marked stopped)' } else { '' })) $fixText
    }
  }
}

function Check-AlwaysOn {
  Out-Section 'ALWAYS-ON PIECES'
  $gb = Get-GatedBad
  # --- the runner task and its guard
  $t = $null
  try { $t = Get-ScheduledTask -TaskName $script:RunnerTask -ErrorAction Stop } catch { }
  if (-not $t) {
    Add-Result $gb ('scheduled task "' + $script:RunnerTask + '" exists, with its guard') 'the task is not there (vm-setup.ps1 creates it in the services stage, which waits for a valid host-stopped.txt)' 'After the switch-over, in an administrator window: vm-setup.ps1 -Only files,services,health'
  } else {
    $probs = New-Object System.Collections.ArrayList
    $act = $null
    try { $act = $t.Actions | Select-Object -First 1 } catch { }
    $exe = ''
    $arg = ''
    if ($act) { $exe = [string]$act.Execute; $arg = [string]$act.Arguments }
    if ($exe -notmatch '(?i)wscript(\.exe)?$' -or $arg -notmatch '(?i)runner-guard\.vbs') { [void]$probs.Add('it does not start runner-guard.vbs (it would start the runner without the "main PC is stopped" check)') }
    foreach ($gf in @('runner-guard.vbs', 'runner-guard.ps1')) {
      if (-not (Test-Path -LiteralPath (Join-Path $script:StageRoot ('launchers\' + $gf)))) { [void]$probs.Add('C:\PillagersMove\launchers\' + $gf + ' is missing') }
    }
    $every = ''
    try { $rep = $t.Triggers | Select-Object -First 1; if ($rep.Repetition -and $rep.Repetition.Interval) { $every = [string]$rep.Repetition.Interval } } catch { }
    if ($every -and $every -ne 'PT15M') { [void]$probs.Add('it repeats every ' + $every + ', not every 15 minutes') }
    $state = [string]$t.State
    if ($state -eq 'Disabled') { [void]$probs.Add('the task is switched OFF') }
    $info = $null
    try { $info = Get-ScheduledTaskInfo -TaskName $script:RunnerTask -ErrorAction Stop } catch { }
    $last = ''
    if ($info) { $last = 'last run ' + $info.LastRunTime.ToString('s') + ' result ' + $info.LastTaskResult }
    $runnerOff = Test-Path -LiteralPath (Join-Path $script:StageRoot 'launchers\RUNNER-OFF.txt')
    if ($runnerOff) { [void]$probs.Add('RUNNER-OFF.txt exists: the guard is told to keep the runner OFF')}
    if ($probs.Count -eq 0) { Add-Result 'PASS' ('scheduled task "' + $script:RunnerTask + '" exists, with its guard') ('state ' + $state + ', runs runner-guard.vbs every 15 minutes, guard files present' + $(if ($last) { ', ' + $last } else { '' })) }
    else {
      $fx = 'Run vm-setup.ps1 -Only services in an administrator window (it repairs the task and the guard).'
      if ($state -eq 'Disabled') { $fx = 'Switch it on: Enable-ScheduledTask -TaskName "' + $script:RunnerTask + '"   (an administrator window may be needed). It was switched off by a party-stop or -NoRunner.' }
      if ($runnerOff) { $fx = 'Delete C:\PillagersMove\launchers\RUNNER-OFF.txt to let the runner start again. ' + $fx }
      Add-Result $(if ($runnerOff -and $probs.Count -eq 1) { 'WAIT' } else { 'FAIL' }) ('scheduled task "' + $script:RunnerTask + '" exists, with its guard') (($probs -join '; ') + $(if ($last) { ' (' + $last + ')' } else { '' })) $fx
    }
  }
  # --- the dev services task (servers at sign-in)
  $d = $null
  try { $d = Get-ScheduledTask -TaskName $script:DevTask -ErrorAction Stop } catch { }
  if (-not $d) { Add-Result $gb ('scheduled task "' + $script:DevTask + '" exists') 'the task is not there' 'After the switch-over, in an administrator window: vm-setup.ps1 -Only files,services,health' }
  elseif ([string]$d.State -eq 'Disabled') { Add-Result 'FAIL' ('scheduled task "' + $script:DevTask + '" exists') 'the task is switched OFF, so the servers will not start after a restart' ('Enable-ScheduledTask -TaskName "' + $script:DevTask + '"') }
  else {
    $logon = $false
    try { $logon = (@($d.Triggers | Where-Object { $_.CimClass.CimClassName -match 'Logon' }).Count -gt 0) } catch { }
    if ($logon) { Add-Result 'PASS' ('scheduled task "' + $script:DevTask + '" exists') ('state ' + $d.State + ', starts the servers when you sign in') }
    else { Add-Result 'FAIL' ('scheduled task "' + $script:DevTask + '" exists') 'the task has no sign-in trigger' 'Run vm-setup.ps1 -Only services in an administrator window.' }
  }
  # --- Autologon: the tasks above are "run only when the user is signed in" tasks, so after a restart nothing starts until somebody signs in
  $af = Get-AutologonFacts
  $auto = [string]$af.AutoAdminLogon
  $defUser = [string]$af.DefaultUserName
  $hello = $af.HelloBuild
  $plain = [bool]$af.HasPlainPassword
  if ($plain) {
    Add-Result 'FAIL' 'the VM signs in by itself after a restart (Autologon)' 'a plain-text DefaultPassword value exists in the Winlogon registry key (value not read)' 'That stores your password readable by anyone on the VM. Run vm-autologon.ps1 -Undo, then vm-autologon.ps1 again (Autologon keeps the password in the protected LSA store instead).'
  } elseif ($auto -eq '1' -and $defUser -and ($defUser -ieq $env:USERNAME)) {
    $blk = @()
    $hb = 0
    if ($null -ne $hello -and [int]::TryParse([string]$hello, [ref]$hb) -and $hb -ne 0) { $blk += 'Windows Hello-only sign-in is switched ON' }
    if ([bool]$af.LegalNotice) { $blk += 'a sign-in legal notice is set' }
    if ($blk.Count -eq 0) {
      Add-Result 'PASS' 'the VM signs in by itself after a restart (Autologon)' ('automatic sign-in is on for ' + $defUser + ' (password kept by Autologon in the protected store, none in the registry)')
    } else {
      $bfx = 'Automatic sign-in is set up, but Windows ignores it while this is so.'
      if ($hb -ne 0) { $bfx += ' Switch OFF Settings > Accounts > Sign-in options > "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device".' }
      if ([bool]$af.LegalNotice) { $bfx += ' Remove the sign-in legal notice (Local Security Policy > Security Options > Interactive logon: Message title/text).' }
      $bfx += ' Then restart the VM once while you watch and run this checklist again. vm-autologon.ps1 -Status shows the same.'
      Add-Result 'WAIT' 'the VM signs in by itself after a restart (Autologon)' ('automatic sign-in is on for ' + $defUser + ', but ' + ($blk -join ' and ') + ', so Windows will ignore it') $bfx
    }
  } elseif ($auto -eq '1') {
    Add-Result 'FAIL' 'the VM signs in by itself after a restart (Autologon)' ('automatic sign-in is on, but for "' + $defUser + '", not for ' + $env:USERNAME) 'Run vm-autologon.ps1 as the user the helpers should run as.'
  } elseif ($(try { $lu = Get-LocalUser -Name $env:USERNAME -ErrorAction Stop; (-not $lu.PasswordRequired) -and (-not $lu.PasswordLastSet) } catch { $false })) {
    # 10-19: the VM's local account has NO password, so Autologon refuses ("does not support NULL passwords") and is not needed:
    # Windows signs a password-less local account in by itself. Only a sign-in legal notice stops that (it waits for a click).
    if ([bool]$af.LegalNotice) {
      Add-Result 'WAIT' 'the VM signs in by itself after a restart (Autologon)' 'your account has no password, so Windows would sign in by itself, but a sign-in legal notice is set and waits for a click' 'Remove the sign-in legal notice (Local Security Policy > Local Policies > Security Options > empty "Interactive logon: Message text..." and "Interactive logon: Message title..."), then restart the VM once while you watch.'
    } else {
      Add-Result 'PASS' 'the VM signs in by itself after a restart (Autologon)' 'your account has no password and no sign-in notice is set, so Windows signs in by itself (Autologon not needed); confirm it on the next restart'
    }
  } else {
    $fx = 'YOU run, inside the VM: powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1   (it opens Sysinternals Autologon; you type the password into ITS window, the script never sees it).'
    if ($null -ne $hello -and [int]$hello -ne 0) { $fx += ' First switch OFF Settings > Accounts > Sign-in options > "For improved security, only allow Windows Hello sign-in for Microsoft accounts on this device".' }
    Add-Result 'WAIT' 'the VM signs in by itself after a restart (Autologon)' 'automatic sign-in is not set up; after any restart (Windows Update, power cut, host reboot) the runner, servers and Claude would wait for you to sign in' $fx
  }
  # --- a restart that is already waiting
  $pend = @(Get-PendingRestartReasons)
  if ($pend.Count -eq 0) { Add-Result 'PASS' 'no Windows restart is waiting' 'no restart is pending (Windows Update and servicing checked)' }
  else { Add-Result 'WAIT' 'no Windows restart is waiting' ('a restart is waiting for: ' + ($pend -join ', ')) 'Restart the VM when it suits you, while you are watching, and confirm it comes back signed in with the servers up (run this checklist again). Windows may also do it by itself at night; that is fine once Autologon is on.' }
}

function Check-Switch {
  Out-Section 'THE SWITCH-OVER'
  $mk = $script:Marker
  if (-not $mk.Exists) {
    Add-Result 'WAIT' 'the main PC is marked stopped (host-stopped.txt)' 'there is no host-stopped.txt in the kit folder yet' 'That is normal until switch-over day. On the main PC: host-stop.ps1, then host-push-files.ps1 -Final (steps S2 and S4 of the guide).'
  } elseif ($mk.Stopped) {
    $hd = ''
    if ($mk.Head) { $hd = ', main PC repo commit ' + $mk.Head.Substring(0, 12) }
    Add-Result 'PASS' 'the main PC is marked stopped (host-stopped.txt)' ('valid "stopped" marker written on ' + $mk.Computer + $(if ($mk.Time) { ' at ' + $mk.Time } else { '' }) + $hd + '; every strict rule of the runner guard holds')
  } elseif ($mk.Status -eq 'revoked') {
    Add-Result 'FAIL' 'the main PC is marked stopped (host-stopped.txt)' 'the marker says "revoked": the main PC Pillagers has been switched back on' 'The VM must not run lanes while the main PC does. If you really are moving to the VM: on the main PC run host-stop.ps1 again, then host-push-files.ps1 -Final.'
  } else {
    Add-Result 'FAIL' 'the main PC is marked stopped (host-stopped.txt)' ('the marker is not accepted: ' + ((@($mk.Why) | Select-Object -First 3) -join '; ')) 'On the main PC run host-stop.ps1 again and push again (host-push-files.ps1 -Final). Do not edit the file by hand.'
  }

  $gb = Get-GatedBad
  $hb = Join-Path $script:RepoRoot 'tools\handoff\nightly\runner.heartbeat'
  if (Test-Path -LiteralPath $hb) {
    $mins = [int][math]::Floor(((Get-Date) - (Get-Item -LiteralPath $hb).LastWriteTime).TotalMinutes)
    if ($mins -le $script:HeartbeatMaxMin) { Add-Result 'PASS' 'the runner heartbeat is fresh' ('last beat ' + $mins + ' minute(s) ago (limit ' + $script:HeartbeatMaxMin + ')') }
    else { Add-Result $gb 'the runner heartbeat is fresh' ('last beat ' + $mins + ' minutes ago (limit ' + $script:HeartbeatMaxMin + ')' + $(if (-not $script:SwitchDone) { '; this is the copied file, the VM runner has not started yet' } else { '' })) ('Look at C:\PillagersMove\launchers\runner-guard.log (it says why the guard did not start the runner), then tools\handoff\nightly\nightly.log. Starting it by hand is not needed: the task tries every 15 minutes.') }
  } else {
    Add-Result $gb 'the runner heartbeat is fresh' 'there is no runner.heartbeat file' 'The runner has never run here. After the switch-over: vm-setup.ps1 -Only services,health (administrator window); see runner-guard.log.'
  }

  $now = [long]([DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
  $ct = 0
  $subject = ''
  $git = Find-GitExe
  if ($git -and (Test-Path -LiteralPath (Join-Path $script:RepoRoot '.git'))) {
    $c = Invoke-Git @('-C', $script:RepoRoot, 'log', '-1', '--format=%ct|%s', 'master') 60
    $l = Get-FirstLine $c.Lines
    if ($c.ExitCode -eq 0 -and $l -match '^(\d{9,12})\|(.*)$') { $ct = [long]$Matches[1]; $subject = $Matches[2] }
  }
  if ($ct -gt 0) {
    $age = [int][math]::Floor(($now - $ct) / 60)
    $shown = Clean-Ascii $subject
    if ($shown.Length -gt 60) { $shown = $shown.Substring(0, 60) }
    if ($age -le $script:ShipMaxMin) { Add-Result 'PASS' 'a ship happened recently' ('last ship "' + $shown + '" ' + $age + ' minute(s) ago (limit ' + $script:ShipMaxMin + ')') }
    else { Add-Result $gb 'a ship happened recently' ('last ship "' + $shown + '" was ' + [int][math]::Floor($age / 60) + ' hours ago (limit ' + ($script:ShipMaxMin / 60) + ')') 'Just switched over? Give the lanes an hour. Otherwise look at tools\handoff\nightly\nightly.log and the lane status files in tools\handoff\console (the Dev Console on port 8820 shows them).' }
  } else {
    Add-Result 'FAIL' 'a ship happened recently' 'git could not read the newest commit on master' 'See the repo item above.'
  }
}

function Check-Resources {
  Out-Section 'RESOURCES'
  $free = -1
  try { $free = [math]::Round(([System.IO.DriveInfo]'C').AvailableFreeSpace / 1GB, 1) } catch { }
  if ($free -lt 0) { Add-Result 'FAIL' 'free disk space on C:' 'could not read the drive' 'Open File Explorer and look at the C: drive.' }
  elseif ($free -lt $script:MinFreeDiskGB) { Add-Result 'FAIL' 'free disk space on C:' ([string]$free + ' GB free (needs ' + $script:MinFreeDiskGB + ' GB or more; the test runs, logs and browsers fill it)') 'Free space inside the VM (Disk Cleanup, empty the Recycle Bin), or make the VM disk bigger on the main PC (Hyper-V Manager > Edit Disk).' }
  else { Add-Result 'PASS' 'free disk space on C:' ([string]$free + ' GB free (needs ' + $script:MinFreeDiskGB + ' GB or more)') }

  $os = $null
  try { $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop } catch { }
  if ($os) {
    $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $totGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    # 10-19: under the floor while the helpers and robots are the ones using it is normal work, not a fault (new jobs just wait)
    $busy = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'console-lane\.sh|codex-lane\.sh|fuzz\.ps1' }).Count
    if ($freeGB -ge $script:MinFreeRamGB) { Add-Result 'PASS' 'free memory (RAM)' ([string]$freeGB + ' GB free of ' + $totGB + ' GB (the runner starts no new job under ' + $script:MinFreeRamGB + ' GB free)') }
    elseif ($busy -gt 0 -and $freeGB -ge 1.5) { Add-Result 'PASS' 'free memory (RAM)' ([string]$freeGB + ' GB free of ' + $totGB + ' GB: the running helpers and robots use the rest (' + $busy + ' process(es)); new jobs wait until ' + $script:MinFreeRamGB + ' GB are free') }
    else { Add-Result 'FAIL' 'free memory (RAM)' ([string]$freeGB + ' GB free of ' + $totGB + ' GB; the runner starts no new job under ' + $script:MinFreeRamGB + ' GB free') 'Close programs you are not using inside the VM (the floor is RAM_FLOOR_GB in tools\handoff\console\caps.txt). If it stays low with nothing open, give the VM more memory on the main PC: host-vm-boost.ps1 -MemoryGB 14 (the main PC must keep 6 GB free).' }
  } else { Add-Result 'FAIL' 'free memory (RAM)' 'could not read memory figures' 'Run the checklist again; if it repeats tell Claude in the VM.' }

  $vc = @()
  try { $vc = @(Get-CimInstance -ClassName Win32_VideoController -ErrorAction Stop) } catch { }
  $names = @($vc | ForEach-Object { [string]$_.Name })
  $real = @($vc | Where-Object { [string]$_.Name -notmatch '(?i)Hyper-V|Basic Display|Remote Display|Basic Render' })
  if ($vc.Count -eq 0) { Add-Result 'WARN' 'a graphics card shows up in Windows' 'Windows lists no video controller at all' 'Not needed by the helpers. For the party see the graphics steps of the guide (Step 5).' }
  elseif ($real.Count -eq 0) { Add-Result 'WARN' 'a graphics card shows up in Windows' ('only the plain Hyper-V screen: ' + (($names | ForEach-Object { Clean-Ascii $_ }) -join ', ')) 'The shared graphics card is not in the VM (yet). The helpers do not need it; the game runs slower without it. Step 1 and Step 5 of the guide cover it.' }
  else {
    $badCode = @($real | Where-Object { $_.ConfigManagerErrorCode -and [int]$_.ConfigManagerErrorCode -ne 0 })
    if ($badCode.Count -gt 0) { Add-Result 'WARN' 'a graphics card shows up in Windows' ((($real | ForEach-Object { Clean-Ascii ([string]$_.Name) }) -join ', ') + ' is listed but Device Manager reports an error on it') 'Step 5 of the guide (restart the VM for the graphics card; check Device Manager).' }
    else { Add-Result 'PASS' 'a graphics card shows up in Windows' (($real | ForEach-Object { Clean-Ascii ([string]$_.Name) }) -join ', ') }
  }

  $rules = @(Get-FirewallRules)
  $pad = @($rules | Where-Object { [string]$_.Name -like ($script:PadRulePrefix + '*') })
  if ($pad.Count -eq 0) {
    Add-Result 'WARN' 'the pad-route firewall rule exists' ('no rule named "' + $script:PadRulePrefix + '..." (read from the registry; no firewall command was run)') 'Only needed on the party night. Tell Claude in the VM: "build the pad route". It writes the rule text; YOU run it in an administrator window.'
  } else {
    $res = @($pad | ForEach-Object { Test-PadRule $_ })
    $good = @($res | Where-Object { $_.Ok })
    if ($good.Count -gt 0) { Add-Result 'PASS' 'the pad-route firewall rule exists' ('"' + (Clean-Ascii ([string]$pad[0].Name)) + '": inbound TCP 8802 and 8799 only, from ' + $good[0].Remote) }
    else { Add-Result 'WARN' 'the pad-route firewall rule exists' ('"' + (Clean-Ascii ([string]$pad[0].Name)) + '" exists but: ' + (($res[0].Problems | Select-Object -First 4) -join '; ')) 'Ask Claude in the VM to rewrite the rule text (narrow: only the main PC address, only TCP 8802 and 8799) and remove the wide one yourself.' }
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# the plan (shown by -DryRun), the summary, the main routine
# ----------------------------------------------------------------------------------------------------------------------
function Get-Plan {
  return @(
    'THIS MACHINE: the computer name is not JUL26; C:\Users\User1 resolves; the helper scratch folder exists',
    'FILES AND GIT: repo at C:\claudecode\dark raiders, git HEAD and git status; no leftover .git\index.lock; GitHub answers (git ls-remote, nothing downloaded); no token in the remote address; git push set-up (credential manager + stored sign-in, by name, no push); commit name and email',
    'TOOLS: git, Git bash, node, python, Chrome (standard path), Codex bundle, Gemini bundle, agy, Claude Code (with versions)',
    'PACKAGES: tools\console-sdk node_modules',
    'KEYS (names only): PILLAGERS_API_KEY, PILLAGERS_ADMIN_KEY, the optional PILLAGERS_* names, the three forbidden names, PILLAGERS_OLLAMA_URL answers, Claude and Codex sign-in files exist',
    'SERVERS: 8800, 8799, 8803, 8820 answer; 8802 answers a bare HEAD',
    'ALWAYS-ON: "Pillagers runner" task + guard files; "Pillagers dev services" task; Autologon; no restart waiting',
    'SWITCH-OVER: host-stopped.txt (strict rules); runner heartbeat age; last ship age',
    'RESOURCES: free disk, free RAM, graphics card (WARN only), pad-route firewall rule (WARN only)'
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
  elseif ($c.WAIT -gt 0) { Out-Line ('VERDICT: NOTHING IS WRONG, BUT ' + $c.WAIT + ' STEP(S) ARE STILL WAITING. Do them (they are yours or come with the switch-over), then run this again.') 'Yellow' }
  else { Out-Line 'VERDICT: ALL CLEAR. The VM passes every item.' 'Green' }
  if ($c.WARN -gt 0) { Out-Line ('(' + $c.WARN + ' WARN item(s) are for the party night only and do not stop the helpers.)') 'DarkYellow' }
  if ($script:LogOk) { Out-Line ('log: ' + $script:LogFile) 'Gray' }
  if ($c.FAIL -gt 0) { return 1 }
  if ($c.WAIT -gt 0) { return 2 }
  return 0
}

function Invoke-Check([string]$Label, [scriptblock]$Body) {
  try { & $Body }
  catch { Add-Result 'FAIL' ($Label + ' (the check itself crashed)') (Clean-Ascii $_.Exception.Message) 'Run the checklist again; if it repeats tell Claude in the VM.' }
}

function Invoke-Main {
  Start-Log
  Out-Line ('=== ' + $script:ScriptVersion + '   ' + (Get-Date).ToString('s') + '   computer ' + $env:COMPUTERNAME + '   user ' + $env:USERNAME + $(if ($script:DryRun) { '   DRY RUN: nothing is tested' } else { '' })) 'White'
  Out-Line 'Read-only checklist. It starts nothing and changes nothing. PASS = right, FAIL = fix it, WAIT = a step that is not done yet, WARN = party night only.' 'Gray'
  if ($script:DryRun) {
    Out-Blank
    Out-Line 'DRY RUN: these are the checks a real run makes (nothing was tested, nothing was started):' 'Magenta'
    foreach ($p in (Get-Plan)) { Out-Line ('   ' + $p) 'Magenta' }
    Out-Line ('kit folder: ' + $script:Kit + '    log would go to: ' + $script:LogDir) 'Magenta'
    return 0
  }
  try { $script:Marker = Get-MarkerInfo } catch { $script:Marker = [pscustomobject]@{ Exists = $false; Stopped = $false; Status = ''; Head = ''; Computer = ''; Time = ''; Why = @('could not read the marker') } }
  $script:SwitchDone = [bool]$script:Marker.Stopped
  Out-Line ('kit folder: ' + $script:Kit + '    switch-over done (valid host-stopped.txt): ' + $(if ($script:SwitchDone) { 'yes' } else { 'no' })) 'Gray'
  Invoke-Check 'this machine' { Check-Machine }
  Invoke-Check 'files and git' { Check-Repo }
  Invoke-Check 'tools' { Check-Tools }
  Invoke-Check 'packages' { Check-Packages }
  Invoke-Check 'keys' { Check-Keys }
  Invoke-Check 'servers' { Check-Servers }
  Invoke-Check 'always-on' { Check-AlwaysOn }
  Invoke-Check 'switch-over' { Check-Switch }
  Invoke-Check 'resources' { Check-Resources }
  return (Show-Summary)
}

if ($MyInvocation.InvocationName -ne '.') {
  $script:ExitCode = Invoke-Main
  exit $script:ExitCode
}
