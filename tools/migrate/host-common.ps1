# host-common.ps1 : shared helpers for host-vm-boost.ps1, host-push-files.ps1 and host-stop.ps1.
# It is loaded ("dot-sourced") by those three scripts. Do not run it on its own.
# ASCII only. Works in Windows PowerShell 5.1 and in PowerShell 7.
# Safety: every line shown on screen or written to a log goes through Protect-Text, which hides anything that looks like a key.
# This file never reads, copies or prints a secret value.

$script:MigRoot      = $PSScriptRoot
$script:HostProfile  = 'C:\Users\User1'
$script:RepoRoot     = 'C:\claudecode\dark raiders'
$script:CodexRoot    = 'C:\claudecode\pillagers-codex'
$script:ScratchPad   = 'C:\Users\User1\AppData\Local\Temp\claude\C--Users-User1-Desktop-dark-raiders\8a09e991-b4f4-4b23-b10f-ded92e837fc3\scratchpad'
$script:GuestStage   = 'C:\PillagersMove'
$script:DefaultVMName = 'Pillagers_Oct26'
$script:MarkerName   = 'host-stopped.txt'
$script:GitBash      = 'C:\Program Files\Git\bin\bash.exe'
$script:StateDir     = [System.IO.Path]::Combine($PSScriptRoot, 'state')
# Big staging files (driver zip, tar archives) live OUTSIDE the repository folder, so a ship (git add -A) can never commit them.
$script:HostStage    = 'C:\Users\User1\AppData\Local\PillagersMove\out'
# The personal look-and-feel export (wallpaper picture, Start layout, settings dump, app list) is written OUTSIDE the repository too.
$script:SettingsStage = 'C:\Users\User1\AppData\Local\PillagersMove\settings'
$script:MigLog       = ''

# ------------------------------------------------------------------ logging
function Start-MigLog {
  param([Parameter(Mandatory = $true)][string]$Name)
  $dir = Join-Path $script:MigRoot 'logs'
  if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $script:MigLog = Join-Path $dir ($Name + '-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
  try { Set-Content -LiteralPath $script:MigLog -Value ('# ' + $Name + ' started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME) -Encoding ASCII } catch { }
}

function Protect-Text {
  param([string]$Text)
  if ([string]::IsNullOrEmpty($Text)) { return $Text }
  $rx = 'sk-ant-[A-Za-z0-9_\-]{20,}|AIza[0-9A-Za-z_\-]{35}|(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,}|xox[abprs]-[A-Za-z0-9\-]{20,}|\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_\-]{40,}'
  return [System.Text.RegularExpressions.Regex]::Replace($Text, $rx, '[hidden]')
}

function Write-Mig {
  param([string]$Text, [string]$Level = 'INFO')
  $t = Protect-Text $Text
  $color = 'Gray'
  switch ($Level) {
    'STEP' { $color = 'Cyan' }
    'OK'   { $color = 'Green' }
    'DONE' { $color = 'Green' }
    'WARN' { $color = 'Yellow' }
    'FAIL' { $color = 'Red' }
    'DRY'  { $color = 'Magenta' }
    'SKIP' { $color = 'DarkGray' }
    default { $color = 'Gray' }
  }
  Write-Host ($Level.PadRight(5) + ' ' + $t) -ForegroundColor $color
  if ($script:MigLog) {
    try { Add-Content -LiteralPath $script:MigLog -Value ((Get-Date -Format 'HH:mm:ss') + ' [' + $Level + '] ' + $t) -Encoding ASCII } catch { }
  }
}

function Write-MigBlank { Write-Host ''; if ($script:MigLog) { try { Add-Content -LiteralPath $script:MigLog -Value '' -Encoding ASCII } catch { } } }

function Exit-Mig {
  param([int]$Code = 0)
  if ($script:MigLog) { Write-Host ('      log file: ' + $script:MigLog) -ForegroundColor DarkGray }
  exit $Code
}

# ------------------------------------------------------------------ small helpers
function Test-IsAdmin {
  try {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
  } catch { return $false }
}

function Format-Bytes {
  param([double]$Bytes)
  if ($Bytes -ge 1GB) { return ('{0:N2} GB' -f ($Bytes / 1GB)) }
  if ($Bytes -ge 1MB) { return ('{0:N1} MB' -f ($Bytes / 1MB)) }
  if ($Bytes -ge 1KB) { return ('{0:N0} KB' -f ($Bytes / 1KB)) }
  return ('{0:N0} bytes' -f $Bytes)
}

function Get-DriveFreeBytes {
  param([string]$Path)
  try {
    $root = [System.IO.Path]::GetPathRoot($Path)
    $di = New-Object System.IO.DriveInfo($root)
    return [int64]$di.AvailableFreeSpace
  } catch { return [int64]-1 }
}

function Write-AsciiFile {
  param([string]$Path, [string]$Text)
  $dir = Split-Path -Path $Path -Parent
  if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  [System.IO.File]::WriteAllText($Path, $Text, [System.Text.Encoding]::ASCII)
}

function Test-HostProfileOk {
  # The Pillagers files and scripts hard-code C:\Users\User1. Warn if this window runs as somebody else.
  if (-not (Test-Path -LiteralPath $script:HostProfile)) {
    Write-Mig ('The folder ' + $script:HostProfile + ' does not exist on this PC, so this kit cannot find the Pillagers files.') 'FAIL'
    return $false
  }
  if ($env:USERPROFILE -and ($env:USERPROFILE -ine $script:HostProfile)) {
    Write-Mig ('This window runs as ' + $env:USERPROFILE + ', not ' + $script:HostProfile + '. Open an administrator PowerShell from your own (User1) desktop and run the script again.') 'WARN'
    return $false
  }
  return $true
}

# ------------------------------------------------------------------ secret rules (names only, never values)
$script:SecretRules = $null
function Initialize-SecretRules {
  if ($null -ne $script:SecretRules) { return }
  $defs = @(
    @{ Name = 'anthropic-key';    Generic = $false; Needles = @('sk-ant-');                                 Pattern = 'sk-ant-[A-Za-z0-9_\-]{20,}' },
    @{ Name = 'openai-key';       Generic = $false; Needles = @('sk-');                                     Pattern = '\bsk-(?:proj-|svcacct-)?[A-Za-z0-9_\-]{40,}' },
    @{ Name = 'google-api-key';   Generic = $false; Needles = @('AIza');                                    Pattern = 'AIza[0-9A-Za-z_\-]{35}' },
    @{ Name = 'github-token';     Generic = $false; Needles = @('ghp_', 'gho_', 'ghu_', 'ghs_', 'ghr_', 'github_pat_'); Pattern = '(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,}' },
    @{ Name = 'aws-access-key';   Generic = $false; Needles = @('AKIA');                                    Pattern = '\bAKIA[0-9A-Z]{16}\b' },
    @{ Name = 'slack-token';      Generic = $false; Needles = @('xox');                                     Pattern = 'xox[abprs]-[A-Za-z0-9\-]{20,}' },
    @{ Name = 'private-key';      Generic = $false; Needles = @('PRIVATE KEY');                             Pattern = '-----BEGIN [A-Z ]{0,30}PRIVATE KEY-----' },
    @{ Name = 'url-with-password'; Generic = $false; Needles = @('://');                                    Pattern = 'https?://[^/\s:@]{1,64}:[^/\s@]{4,}@[A-Za-z0-9.\-]+' },
    @{ Name = 'jwt';              Generic = $false; Needles = @('eyJ');                                     Pattern = 'eyJ[A-Za-z0-9_\-]{20,}\.eyJ[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{20,}' },
    @{ Name = 'key-assignment';   Generic = $true;  Needles = @();                                          Pattern = '(?i)\b(?:api[_\-]?key|secret|token|passw(?:or)?d|auth)\w{0,12}["'']?\s*[:=]\s*["''][A-Za-z0-9/+_\-=.]{28,}["'']' }
  )
  $list = New-Object System.Collections.Generic.List[object]
  foreach ($d in $defs) {
    $rx = New-Object System.Text.RegularExpressions.Regex($d.Pattern, ([System.Text.RegularExpressions.RegexOptions]::Compiled -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant))
    $list.Add([pscustomobject]@{ Name = $d.Name; Generic = [bool]$d.Generic; Needles = [string[]]$d.Needles; Rx = $rx })
  }
  $script:SecretRules = $list.ToArray()
}

function Add-SecretKinds {
  param([string]$Text, [bool]$Generic, $Kinds)
  Initialize-SecretRules
  foreach ($r in $script:SecretRules) {
    if ($r.Generic -and -not $Generic) { continue }
    if ($Kinds.Contains($r.Name)) { continue }
    if ($r.Needles.Length -gt 0) {
      $has = $false
      foreach ($n in $r.Needles) { if ($Text.IndexOf($n, [System.StringComparison]::Ordinal) -ge 0) { $has = $true; break } }
      if (-not $has) { continue }
    }
    if ($r.Rx.IsMatch($Text)) { [void]$Kinds.Add($r.Name) }
  }
}

function Find-SecretKindsInFile {
  # Returns the NAMES of the secret patterns found in a file (an empty list when clean). 'unreadable' when the file cannot be opened.
  param([string]$Path, [bool]$Generic = $false)
  $kinds = New-Object System.Collections.Generic.List[string]
  $enc = [System.Text.Encoding]::GetEncoding(28591)
  $fs = $null
  try {
    $fs = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    $sr = New-Object System.IO.StreamReader($fs, $enc, $false, 1048576)
    if ($fs.Length -le 41943040) {
      $text = $sr.ReadToEnd()
      Add-SecretKinds -Text $text -Generic $Generic -Kinds $kinds
    } else {
      $buf = New-Object 'char[]' 8388608
      $carry = ''
      while ($true) {
        $n = $sr.Read($buf, 0, $buf.Length)
        if ($n -le 0) { break }
        $chunk = $carry + [string]::new($buf, 0, $n)
        Add-SecretKinds -Text $chunk -Generic $Generic -Kinds $kinds
        if ($chunk.Length -gt 2048) { $carry = $chunk.Substring($chunk.Length - 2048) } else { $carry = $chunk }
      }
    }
  } catch {
    [void]$kinds.Add('unreadable')
  } finally {
    if ($null -ne $fs) { $fs.Dispose() }
  }
  return ,$kinds.ToArray()
}

function Test-SecretFileName {
  # True for file names that are credential files by name. These are never packed.
  param([string]$Path)
  $n = [System.IO.Path]::GetFileName($Path).ToLowerInvariant()
  $bad = @('auth.json', '.credentials.json', 'credentials.json', '.claude.json', '.git-credentials', '.netrc', '.npmrc', '.pypirc', 'butler_creds', 'id_rsa', 'id_rsa.pub', 'id_ed25519', 'id_ed25519.pub', 'id_ecdsa', 'id_ecdsa.pub', 'id_dsa', 'id_dsa.pub', 'login data', 'cookies', 'local state', 'oauth_creds.json', 'google_accounts.json', 'hosts.yml', 'token.json', 'tokens.json', 'secrets.json', 'secret.json')
  if ($bad -contains $n) { return $true }
  # login files of the tools (agy, gemini, codex, gh, claude) by a looser shape: anything called *credential*, *oauth* or *token*.json
  if ($n -match '^\.?(credentials?|oauth[_\-]?creds?)([_\-.].*)?$') { return $true }
  if ($n -match '(^|[_\-.])(access|refresh|auth|api|bearer)[_\-]?tokens?\.(json|txt|yml|yaml)$') { return $true }
  # Google service-account key files (service-account.json, my-project-service_account-1234.json, ...)
  if ($n -match 'service[_\-]?account[^/\\]*\.json$') { return $true }
  $ext = [System.IO.Path]::GetExtension($n)
  if (@('.pem', '.pfx', '.p12', '.ppk', '.key', '.kdbx', '.jks', '.keystore', '.gpg', '.pgp') -contains $ext) { return $true }
  return $false
}

# ------------------------------------------------------------------ git
$script:GitExe = $null
function Get-GitExe {
  if ($script:GitExe) { return $script:GitExe }
  $c = Get-Command git.exe -ErrorAction SilentlyContinue
  if ($c) { $script:GitExe = $c.Source; return $script:GitExe }
  foreach ($p in @('C:\Program Files\Git\cmd\git.exe', 'C:\Program Files\Git\bin\git.exe')) { if (Test-Path -LiteralPath $p) { $script:GitExe = $p; return $p } }
  return $null
}

function Invoke-GitRaw {
  param([Parameter(Mandatory = $true)][string[]]$GitArgs, [string]$Repo = $script:RepoRoot)
  $git = Get-GitExe
  if (-not $git) { return $null }
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  try { $out = & $git -C $Repo @GitArgs 2>$null } finally { $ErrorActionPreference = $old }
  return $out
}

function Get-RepoState {
  $s = [ordered]@{ Ok = $false; Head = ''; Origin = ''; Ahead = -1; DirtyCount = -1; Branch = '' }
  try {
    $h = @(Invoke-GitRaw @('rev-parse', 'HEAD'))
    if ($h.Count -gt 0) { $s.Head = ([string]$h[0]).Trim() }
    $o = @(Invoke-GitRaw @('rev-parse', 'origin/master'))
    if ($o.Count -gt 0) { $s.Origin = ([string]$o[0]).Trim() }
    $b = @(Invoke-GitRaw @('rev-parse', '--abbrev-ref', 'HEAD'))
    if ($b.Count -gt 0) { $s.Branch = ([string]$b[0]).Trim() }
    $a = @(Invoke-GitRaw @('rev-list', '--count', 'origin/master..HEAD'))
    if ($a.Count -gt 0 -and ([string]$a[0]).Trim() -match '^\d+$') { $s.Ahead = [int]([string]$a[0]).Trim() }
    $st = @(Invoke-GitRaw @('status', '--porcelain'))
    $s.DirtyCount = @($st | Where-Object { $_ }).Count
    $s.Ok = ($s.Head.Length -ge 40)
  } catch { }
  return [pscustomobject]$s
}

function Get-GitDir {
  $g = @(Invoke-GitRaw @('rev-parse', '--git-dir'))
  if ($g.Count -eq 0) { return (Join-Path $script:RepoRoot '.git') }
  $p = ([string]$g[0]).Trim()
  if ([System.IO.Path]::IsPathRooted($p)) { return $p }
  return (Join-Path $script:RepoRoot $p)
}

# ------------------------------------------------------------------ processes
function Get-ProcSnap { return @(Get-CimInstance -ClassName Win32_Process -ErrorAction SilentlyContinue) }

function Get-AncestorPids {
  # The process ids of this window and every process that started it (parent, grandparent, ...). They must never be stopped by this kit:
  # if a helper run (or the runner) is what started this window, stopping it would stop the script half way.
  param([object[]]$Snap)
  $set = New-Object 'System.Collections.Generic.HashSet[int]'
  $byId = @{}
  foreach ($p in $Snap) { $byId[[int]$p.ProcessId] = $p }
  $cur = [int]$PID
  $guard = 0
  while ($cur -gt 0 -and $guard -lt 60) {
    if (-not $set.Add($cur)) { break }
    if (-not $byId.ContainsKey($cur)) { break }
    $cur = [int]$byId[$cur].ParentProcessId
    $guard++
  }
  return , $set
}

function Select-Proc {
  param([object[]]$Snap, [string[]]$Names, [string]$Rx)
  $skip = Get-AncestorPids $Snap
  return @($Snap | Where-Object {
      (-not $skip.Contains([int]$_.ProcessId)) -and $_.CommandLine -and ($Names -contains $_.Name) -and ($_.CommandLine -match $Rx)
    })
}

function Select-HelperProc {
  # The helper runs (Claude, Codex or Gemini working on a job). Stricter than Select-Proc, because the owner's OWN Claude Code window is a
  # claude.exe too and its command line can carry long text that mentions the same file names:
  #   - a claude.exe only counts when it runs in print mode (-p / --print), which is how every helper job is started; his interactive window never does
  #   - this window and every process that started it are never matched (see Get-AncestorPids)
  param([object[]]$Snap)
  $skip = Get-AncestorPids $Snap
  return @($Snap | Where-Object {
      if ($skip.Contains([int]$_.ProcessId)) { return $false }
      if (-not $_.CommandLine) { return $false }
      if ($_.Name -eq 'node.exe') { return ($_.CommandLine -match $script:RxHelper) }
      if ($_.Name -eq 'claude.exe') { return (($_.CommandLine -match $script:RxHelper) -and ($_.CommandLine -match '(^|\s)(-p|--print)(\s|$)')) }
      return $false
    })
}

function Get-AncestorJobNames {
  # Names of Pillagers background jobs that this window was started from (empty = a normal window). Used to warn, never to stop.
  param([object[]]$Snap)
  $skip = Get-AncestorPids $Snap
  $rxAll = '(' + $script:RxRunner + ')|(' + $script:RxLane + ')|(' + $script:RxHelper + ')|(' + $script:RxShip + ')'
  $names = @()
  foreach ($p in $Snap) {
    if ([int]$p.ProcessId -eq [int]$PID) { continue }
    if (-not $skip.Contains([int]$p.ProcessId)) { continue }
    if ($p.CommandLine -and ($p.Name -in @('bash.exe', 'node.exe', 'claude.exe', 'powershell.exe', 'pwsh.exe')) -and ($p.CommandLine -match $rxAll)) { $names += $p.Name }
  }
  return @($names)
}

# Command-line shapes of the Pillagers background jobs (same shapes tools\party-stop.ps1 uses, plus the Codex lane).
$script:RxRunner  = '^(?!.*\s-c\s).*nightly\.sh"?\s*$'
$script:RxLane    = '^(?!.*\s-c\s).*(console-lane\.sh"? [a-z]|console-worker\.sh|codex-lane\.sh|start-codex-lane\.sh)"?(\s.*)?$'
$script:RxHelper  = 'gemini\.js|codex\.js|run-api\.mjs|review-batch\.mjs|critic\.mjs|balance\.mjs|Your task id is'
$script:RxShip    = '^(?!.*\s-c\s).*(shipq\.sh|shipone\.sh|shipdraft\.sh|fixq\.sh|preflight\.sh|preflight-i\.sh|[\\/]ship\.sh|gate\.ps1|mkfixture\.ps1|uishots\.ps1)'
$script:RxFuzz    = 'fuzz\.ps1'
$script:RxCorpus  = 'corpq\.sh|corpus-slices\.sh'
$script:RxReview  = 'llm-night\.ps1|ship-review\.ps1|review-nightly\.sh|itch-daily\.sh|stable\.sh|governor\.sh|waitship\.sh'
$script:RxServers = 'tools[\\/]serve\.ps1|tools[\\/]collector\.ps1|tools[\\/]capture\.ps1|tools[\\/]start-servers\.ps1'
$script:RxPyPages = 'http\.server\s+(8871|8872)\b'

function Get-TestChromes {
  # Only the test Chromes the tools start: a debugging port 93xx with --headless, or a throwaway pillagers-cdp profile.
  # His normal Chrome has neither, so it is never matched.
  param([object[]]$Snap)
  return @($Snap | Where-Object {
      $_.Name -eq 'chrome.exe' -and $_.CommandLine -and
      ( ($_.CommandLine -match '--headless' -and $_.CommandLine -match 'remote-debugging-port=93\d\d(\s|"|$)') -or ($_.CommandLine -match 'user-data-dir=("?)[^ ]*pillagers-cdp') )
    })
}

function Get-DashboardProcs {
  # The Pillagers Dev Console is the node process that listens on 8820.
  param([object[]]$Snap)
  $out = @()
  try {
    $conns = @(Get-NetTCPConnection -State Listen -LocalPort 8820 -ErrorAction Stop)
    foreach ($c in $conns) {
      $p = $Snap | Where-Object { $_.ProcessId -eq $c.OwningProcess -and $_.Name -eq 'node.exe' } | Select-Object -First 1
      if ($p) { $out += $p }
    }
  } catch { }
  return @($out)
}

function Stop-ProcList {
  # Stops the processes in the list. -Tree also stops everything they started.
  param([object[]]$Procs, [string]$What, [switch]$Tree, [switch]$DryRun)
  $Procs = @($Procs | Where-Object { $_ })
  if ($Procs.Count -eq 0) { Write-Mig ($What + ': not running') 'SKIP'; return 0 }
  if ($DryRun) { Write-Mig ($What + ': would stop ' + $Procs.Count + ' process(es)') 'DRY'; return $Procs.Count }
  foreach ($p in $Procs) {
    if ($Tree) { & taskkill.exe /F /T /PID $p.ProcessId 2>&1 | Out-Null }
    else { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue }
  }
  Write-Mig ($What + ': stopped ' + $Procs.Count + ' process(es)') 'OK'
  return $Procs.Count
}

# ------------------------------------------------------------------ ship lock and marker
function Get-ShipLock {
  $lk = Join-Path $script:ScratchPad 'shipq.lock'
  $r = [ordered]@{ Exists = $false; Owner = ''; AgeMin = 0 }
  if (Test-Path -LiteralPath $lk) {
    $r.Exists = $true
    try { $r.AgeMin = [int]((Get-Date) - (Get-Item -LiteralPath $lk).LastWriteTime).TotalMinutes } catch { }
    $of = Join-Path $script:ScratchPad 'shipq.owner'
    if (Test-Path -LiteralPath $of) { try { $r.Owner = (Get-Content -LiteralPath $of -TotalCount 1) } catch { } }
  }
  return [pscustomobject]$r
}

function Read-KeyValueFile {
  param([string]$Path)
  $h = @{}
  if (-not (Test-Path -LiteralPath $Path)) { return $h }
  foreach ($line in (Get-Content -LiteralPath $Path)) {
    $i = $line.IndexOf('=')
    if ($i -gt 0) { $h[$line.Substring(0, $i).Trim()] = $line.Substring($i + 1).Trim() }
  }
  return $h
}

function Get-MarkerPath { return (Join-Path $script:MigRoot $script:MarkerName) }

function Get-MarkerCheck {
  # SHA-256 (hex, lower case) over the marker's content lines: every non-empty line except the check= line itself, trimmed, joined with LF.
  # It catches a marker that was edited by hand, cut short, or glued together from two runs. It is NOT a password: anyone could recompute it.
  # vm-setup.ps1 has its own copy of this rule (it cannot load this file); keep the two the same.
  param([string[]]$Lines)
  $keep = @()
  foreach ($l in $Lines) {
    $t = ([string]$l).Trim()
    if (-not $t) { continue }
    if ($t -match '^check\s*=') { continue }
    $keep += $t
  }
  $bytes = [System.Text.Encoding]::ASCII.GetBytes(($keep -join "`n"))
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try { $h = $sha.ComputeHash($bytes) } finally { $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}

# What a Pillagers task or startup shortcut runs: a path inside this repository (or the Codex working copy) or one of the repository's own start scripts.
$script:RepoTaskRx = '(?i)claudecode[\\/]dark raiders|Desktop[\\/]dark raiders|pillagers-codex|runner-start\.vbs|party-start|start-servers'

function Get-PillagersTasks {
  # The scheduled tasks that start THIS Pillagers repository. A task counts only when its name mentions Pillagers or Dark Raiders AND what it runs
  # points into this repository (or the Codex working copy). A same-named task of another project (the 3D game) is left alone, with a warning.
  param([switch]$Report)
  $out = @()
  foreach ($t in @(Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match '(?i)pillagers|dark.?raiders' })) {
    $txt = ''
    try { foreach ($a in @($t.Actions)) { $txt += ' ' + [string]$a.Execute + ' ' + [string]$a.Arguments + ' ' + [string]$a.WorkingDirectory } } catch { }
    if ($txt -match $script:RepoTaskRx) { $out += $t }
    elseif ($Report) { Write-Mig ('task "' + $t.TaskName + '" has a Pillagers-like name but does not start this repository, so it is left alone. If it is yours to stop, switch it off by hand.') 'WARN' }
  }
  return @($out)
}

# ------------------------------------------------------------------ GPU facts (read-only, no admin needed)
function Get-HostBuildString {
  try {
    $k = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -ErrorAction Stop
    return ('{0}.{1}' -f $k.CurrentBuild, $k.UBR)
  } catch { return '' }
}

function Resolve-GpuPackagePath {
  param([string]$Service, [string]$InstanceId)
  $repo = (Join-Path $env:SystemRoot 'System32\DriverStore\FileRepository').TrimEnd('\')
  if ($Service) {
    try {
      $sys = Get-CimInstance -ClassName Win32_SystemDriver -Filter ("Name='{0}'" -f $Service.Replace("'", "''")) -ErrorAction Stop
      if ($sys -and $sys.PathName) {
        $p = ([string]$sys.PathName).Trim('"')
        $p = $p -replace '^\\\?\?\\', ''
        $p = $p -replace '^\\SystemRoot\\', ($env:SystemRoot + '\')
        $cur = Split-Path -Path $p -Parent
        $guard = 0
        while ($cur -and $guard -lt 10) {
          $par = Split-Path -Path $cur -Parent
          if ($par -and ($par.TrimEnd('\') -ieq $repo)) { if (Test-Path -LiteralPath $cur) { return $cur } }
          $cur = $par
          $guard++
        }
      }
    } catch { }
  }
  # Fallback: map the published name (oemNN.inf) to its original name with pnputil, then find the folder.
  try {
    $pub = [string](Get-PnpDeviceProperty -InstanceId $InstanceId -KeyName 'DEVPKEY_Device_DriverInfPath' -ErrorAction Stop).Data
    if ($pub) {
      $txt = (& pnputil.exe /enum-drivers 2>$null) -join "`n"
      $m = [regex]::Match($txt, '(?is)Published Name:\s*' + [regex]::Escape($pub) + '\s*\r?\n\s*Original Name:\s*([^\r\n]+)')
      if ($m.Success) {
        $orig = $m.Groups[1].Value.Trim()
        $hit = Get-ChildItem -LiteralPath $repo -Directory -Filter ($orig + '_*') -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($hit) { return $hit.FullName }
      }
    }
  } catch { }
  return ''
}

function Get-GpuHostFacts {
  $f = [ordered]@{ Ok = $false; Error = ''; Gpu = ''; InstanceId = ''; Driver = ''; DriverDate = ''; Service = ''; Package = ''; PackagePath = ''; HostBuild = (Get-HostBuildString); Dxgkrnl = '' }
  try {
    $dev = @(Get-PnpDevice -Class Display -ErrorAction Stop | Where-Object { $_.InstanceId -match 'VEN_1002' -and $_.Status -eq 'OK' })
    if ($dev.Count -eq 0) { throw 'No working AMD display adapter was found (looked for PCI vendor 1002).' }
    $d = $dev[0]
    $f.Gpu = [string]$d.FriendlyName
    $f.InstanceId = [string]$d.InstanceId
    $f.Driver = [string](Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName 'DEVPKEY_Device_DriverVersion' -ErrorAction Stop).Data
    try { $f.DriverDate = ([datetime](Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName 'DEVPKEY_Device_DriverDate' -ErrorAction Stop).Data).ToString('yyyy-MM-dd') } catch { }
    try { $f.Service = [string](Get-PnpDeviceProperty -InstanceId $d.InstanceId -KeyName 'DEVPKEY_Device_Service' -ErrorAction Stop).Data } catch { }
    $f.PackagePath = Resolve-GpuPackagePath -Service $f.Service -InstanceId $d.InstanceId
    if ($f.PackagePath) { $f.Package = Split-Path -Path $f.PackagePath -Leaf }
    try { $f.Dxgkrnl = [string](Get-Item (Join-Path $env:SystemRoot 'System32\drivers\dxgkrnl.sys')).VersionInfo.FileVersion } catch { }
    if (-not $f.PackagePath) { throw 'Could not find the AMD driver package folder in the Windows DriverStore.' }
    $f.Ok = $true
  } catch { $f.Error = $_.Exception.Message }
  return [pscustomobject]$f
}

function Get-GpuPackManifestPath { return (Join-Path $script:MigRoot 'gpu-pack-manifest.json') }

function Compare-GpuDrift {
  # Returns '' when nothing changed, a plain sentence when the host driver or Windows build changed since the last pack.
  param($Facts)
  $mf = Get-GpuPackManifestPath
  if (-not (Test-Path -LiteralPath $mf)) { return 'no driver pack has been built yet' }
  try {
    $old = Get-Content -LiteralPath $mf -Raw | ConvertFrom-Json
    $diff = @()
    if ([string]$old.Driver -ne [string]$Facts.Driver) { $diff += ('driver ' + $old.Driver + ' -> ' + $Facts.Driver) }
    if ([string]$old.Package -ne [string]$Facts.Package) { $diff += ('driver folder ' + $old.Package + ' -> ' + $Facts.Package) }
    if ([string]$old.HostBuild -ne [string]$Facts.HostBuild) { $diff += ('Windows build ' + $old.HostBuild + ' -> ' + $Facts.HostBuild) }
    if ([string]$old.Dxgkrnl -ne [string]$Facts.Dxgkrnl) { $diff += ('dxgkrnl ' + $old.Dxgkrnl + ' -> ' + $Facts.Dxgkrnl) }
    if ($diff.Count -gt 0) { return ('DRIFT: ' + ($diff -join '; ') + '. Rebuild the driver pack (run host-vm-boost.ps1 again) and update Windows in the VM to the same build.') }
    return ''
  } catch { return 'the last driver pack record could not be read' }
}

# ------------------------------------------------------------------ talking to the VM (all need an administrator window)
function Get-GuestKvp {
  # Best effort: what the VM tells the host about itself (name, OS version, IP). Empty when the VM is off.
  param([string]$VMName)
  $r = @{}
  try {
    $vmc = Get-CimInstance -Namespace 'root\virtualization\v2' -ClassName Msvm_ComputerSystem -Filter ("ElementName='{0}'" -f $VMName.Replace("'", "''")) -ErrorAction Stop | Select-Object -First 1
    $kvp = Get-CimAssociatedInstance -InputObject $vmc -ResultClassName Msvm_KvpExchangeComponent -ErrorAction Stop | Select-Object -First 1
    foreach ($item in @($kvp.GuestIntrinsicExchangeItems)) {
      $x = [xml]$item
      $nm = $x.SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Name']/VALUE")
      $dt = $x.SelectSingleNode("/INSTANCE/PROPERTY[@NAME='Data']/VALUE")
      if ($nm -and $dt) { $r[$nm.InnerText] = $dt.InnerText }
    }
  } catch { }
  return $r
}

function Wait-GuestReady {
  # Waits for the VM heartbeat, then for the Guest Service Interface (needed to copy files in). Returns $true when both are fine.
  param([string]$VMName, [int]$HeartbeatTimeoutSec = 300, [int]$GuestServiceTimeoutSec = 180)
  $t0 = Get-Date
  $okHb = $false
  $lastNote = 0
  while (((Get-Date) - $t0).TotalSeconds -lt $HeartbeatTimeoutSec) {
    $hb = Get-VMIntegrationService -VMName $VMName -Name 'Heartbeat' -ErrorAction SilentlyContinue
    if ($hb -and (($hb.PrimaryStatusDescription -eq 'OK') -or ([string]$hb.PrimaryOperationalStatus -eq 'Ok'))) { $okHb = $true; break }
    $el = [int]((Get-Date) - $t0).TotalSeconds
    if ($el - $lastNote -ge 20) { Write-Mig ('waiting for Windows in the VM to start ... ' + $el + ' s') 'INFO'; $lastNote = $el }
    Start-Sleep -Seconds 5
  }
  if (-not $okHb) { Write-Mig ('The VM did not report a heartbeat within ' + $HeartbeatTimeoutSec + ' seconds.') 'WARN'; return $false }
  Write-Mig 'Windows in the VM is up (heartbeat OK).' 'OK'
  $t1 = Get-Date
  $lastNote = 0
  while (((Get-Date) - $t1).TotalSeconds -lt $GuestServiceTimeoutSec) {
    $gs = Get-VMIntegrationService -VMName $VMName -Name 'Guest Service Interface' -ErrorAction SilentlyContinue
    if ($gs -and $gs.Enabled -and (($gs.PrimaryStatusDescription -eq 'OK') -or ([string]$gs.PrimaryOperationalStatus -eq 'Ok'))) {
      Write-Mig 'The file-copy channel to the VM (Guest Service Interface) is ready.' 'OK'
      return $true
    }
    $el = [int]((Get-Date) - $t1).TotalSeconds
    if ($el - $lastNote -ge 20) { Write-Mig ('waiting for the file-copy channel ... ' + $el + ' s') 'INFO'; $lastNote = $el }
    Start-Sleep -Seconds 5
  }
  Write-Mig 'The file-copy channel (Guest Service Interface) is not ready. Sign in to the VM once and wait a minute, then run this again.' 'WARN'
  return $false
}

function Copy-ToGuest {
  # Copies one host file into the VM at an exact path. Retries once. Returns $true on success.
  param([string]$VMName, [string]$Source, [string]$GuestPath, [int]$Tries = 2)
  for ($i = 1; $i -le $Tries; $i++) {
    try {
      Copy-VMFile -Name $VMName -SourcePath $Source -DestinationPath $GuestPath -CreateFullPath -FileSource Host -Force -ErrorAction Stop
      return $true
    } catch {
      $m = $_.Exception.Message
      Write-Mig ('copy of ' + (Split-Path -Path $Source -Leaf) + ' failed (try ' + $i + ' of ' + $Tries + '): ' + $m) 'WARN'
      if ($m -match 'Guest Service|0x80070005|not enabled|integration') {
        Write-Mig 'Hint: the VM must be running, and the "Guest Service Interface" must be on. Sign in to the VM and wait a minute.' 'WARN'
      }
      if ($i -lt $Tries) { Start-Sleep -Seconds 8 }
    }
  }
  return $false
}

$script:SettingsFileRx = '^(host-settings\.json|host-apps\.json|start-layout\.json|start2\.bin|wallpaper\.[A-Za-z0-9]+)$'

function Get-SettingsExportInfo {
  # Where the look-and-feel export is. The exporter writes into $script:SettingsStage (outside the repository); a copy inside the kit folder is an old one.
  $r = [ordered]@{ Exists = $false; Legacy = $false; Path = ''; AgeDays = -1 }
  $new = Join-Path $script:SettingsStage 'host-settings.json'
  $old = Join-Path $script:MigRoot 'host-settings.json'
  if (Test-Path -LiteralPath $new) { $r.Exists = $true; $r.Path = $new }
  elseif (Test-Path -LiteralPath $old) { $r.Exists = $true; $r.Legacy = $true; $r.Path = $old }
  if ($r.Exists) { try { $r.AgeDays = [int]((Get-Date) - (Get-Item -LiteralPath $r.Path).LastWriteTime).TotalDays } catch { } }
  return [pscustomobject]$r
}

function Get-KitFiles {
  # Every file in the kit folder except the host-only folders and the marker (the marker is pushed on purpose, separately),
  # plus the look-and-feel export from the settings folder outside the repository (it lands flat in kit\ in the VM, as before).
  $root = $script:MigRoot.TrimEnd('\')
  $out = @()
  $seen = @{}
  # A fresh export in the settings folder replaces EVERY look-and-feel file in the kit folder: an old tracked wallpaper.jpg next to a solid-colour
  # export would otherwise be sent too and shown in the VM as if it were the current desktop.
  $haveStaged = (Test-Path -LiteralPath (Join-Path $script:SettingsStage 'host-settings.json'))
  if (Test-Path -LiteralPath $script:SettingsStage) {
    foreach ($f in (Get-ChildItem -LiteralPath $script:SettingsStage -File -Force -ErrorAction SilentlyContinue)) {
      if ($f.Name -notmatch $script:SettingsFileRx) { continue }
      if (Test-SecretFileName $f.FullName) { continue }
      $seen[$f.Name.ToLowerInvariant()] = $true
      $out += [pscustomobject]@{ Full = $f.FullName; Rel = $f.Name; Size = $f.Length }
    }
  }
  foreach ($f in (Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue)) {
    $rel = $f.FullName.Substring($root.Length + 1)
    if ($rel -match '^(logs|state|out)\\') { continue }
    if ($rel -ieq $script:MarkerName) { continue }
    if ($rel -match '\.(tmp|lock|zip|tar|disabled)$' -or $rel -match '\.bak(-|$|\.)') { continue }
    if ($seen.ContainsKey($rel.ToLowerInvariant())) { continue }
    if ($haveStaged -and ($rel -match $script:SettingsFileRx)) { continue }
    if (Test-SecretFileName $f.FullName) { continue }
    $out += [pscustomobject]@{ Full = $f.FullName; Rel = $rel; Size = $f.Length }
  }
  return @($out)
}

function Send-KitToGuest {
  # Copies the kit into C:\PillagersMove\kit in the VM, plus a kit-manifest.json with a sha256 for every file.
  param([string]$VMName, [string]$StageDir)
  $files = @(Get-KitFiles)
  $si = Get-SettingsExportInfo
  if (-not $si.Exists) { Write-Mig 'No look-and-feel export found (host-settings.json). The VM would keep Windows defaults for the look. Run host-settings-export.ps1 (host-vm-boost.ps1 does it for you) and push again.' 'WARN' }
  elseif ($si.Legacy) { Write-Mig 'The look-and-feel export is an old copy inside the repository folder. Run host-settings-export.ps1 again: it now writes outside the repository.' 'WARN' }
  elseif ($si.AgeDays -gt 14) { Write-Mig ('The look-and-feel export is ' + $si.AgeDays + ' days old. Run host-settings-export.ps1 again if you changed your Windows look since.') 'INFO' }
  if (-not (Test-Path -LiteralPath $StageDir)) { New-Item -ItemType Directory -Force -Path $StageDir | Out-Null }
  $entries = @()
  foreach ($f in $files) {
    $h = (Get-FileHash -LiteralPath $f.Full -Algorithm SHA256).Hash.ToLowerInvariant()
    $entries += [ordered]@{ path = $f.Rel; size = $f.Size; sha256 = $h }
  }
  $man = [ordered]@{ created = (Get-Date).ToString('s'); host = $env:COMPUTERNAME; files = $entries }
  $manPath = Join-Path $StageDir 'kit-manifest.json'
  Write-AsciiFile -Path $manPath -Text ($man | ConvertTo-Json -Depth 6)
  $ok = 0; $bad = 0; $i = 0
  foreach ($f in $files) {
    $i++
    $dest = $script:GuestStage + '\kit\' + $f.Rel
    if (Copy-ToGuest -VMName $VMName -Source $f.Full -GuestPath $dest) { $ok++ } else { $bad++ }
  }
  if (Copy-ToGuest -VMName $VMName -Source $manPath -GuestPath ($script:GuestStage + '\kit\kit-manifest.json')) { $ok++ } else { $bad++ }
  Write-Mig ('kit: ' + $ok + ' file(s) copied to ' + $script:GuestStage + '\kit in the VM, ' + $bad + ' failed.') $(if ($bad -eq 0) { 'OK' } else { 'FAIL' })
  return ($bad -eq 0)
}

function Test-KitPathIgnored {
  # True when git (any .gitignore or .git/info/exclude) would leave this repo-relative path out of "git add -A". Read-only.
  param([string]$RelPath)
  $git = Get-GitExe
  if (-not $git) { return $false }
  $old = $ErrorActionPreference
  $ErrorActionPreference = 'Continue'
  $rc = 1
  try { & $git -C $script:RepoRoot check-ignore -q -- $RelPath 2>$null | Out-Null; $rc = $LASTEXITCODE } catch { $rc = 1 } finally { $ErrorActionPreference = $old }
  return ($rc -eq 0)
}

function Ensure-KitExcluded {
  # Keeps the kit's generated and personal files (the 120+ MB session pack, driver zip, logs, state, the host-stopped marker) out of every ship.
  # A ship runs "git add -A", which would commit and push every new file under tools/migrate to the PUBLIC repository dbmosser/pillagers.
  # 1. First line of defence: tools/migrate/.gitignore. It travels with the kit and needs nothing to be run. This function only CHECKS that it works.
  # 2. When a probe path is still not ignored (the .gitignore is missing), it adds NARROW lines to .git/info/exclude (a file that is never committed).
  #    It no longer adds the broad "tools/migrate/" line, so edits to the kit scripts themselves are not hidden.
  # 3. It warns about personal files that are ALREADY tracked (ignore rules do not apply to tracked files) and prints the one command that would
  #    stop tracking them. It never runs git add, git rm or any command that changes the repository index.
  param([switch]$DryRun)
  $ok = $true
  $probes = @('tools/migrate/out/probe.zip', 'tools/migrate/out/pillagers-session-pack.zip', 'tools/migrate/logs/probe.log', 'tools/migrate/state/probe.json', 'tools/migrate/host-stopped.txt', 'tools/migrate/gpu-pack-manifest.json', 'tools/migrate/kit-manifest.json')
  try {
    $open = @($probes | Where-Object { -not (Test-KitPathIgnored $_) })
    if ($open.Count -eq 0) {
      Write-Mig 'git already leaves the kit''s generated files out of every ship (tools/migrate/.gitignore)' 'SKIP'
    } else {
      $exclude = (Get-GitDir) + '\info\exclude'
      $want = @('tools/migrate/out/', 'tools/migrate/logs/', 'tools/migrate/state/', 'tools/migrate/host-stopped.txt', 'tools/migrate/gpu-pack-manifest.json', 'tools/migrate/kit-manifest.json', 'tools/migrate/*.zip')
      $have = @()
      if (Test-Path -LiteralPath $exclude) { $have = @(Get-Content -LiteralPath $exclude -ErrorAction SilentlyContinue | ForEach-Object { ([string]$_).Trim() }) }
      $add = @($want | Where-Object { $have -notcontains $_ })
      if ($DryRun) { Write-Mig ('would add ' + $add.Count + ' narrow line(s) to .git/info/exclude (tools/migrate/.gitignore is missing or incomplete)') 'DRY' }
      elseif ($add.Count -gt 0) {
        $dir = Split-Path -Path $exclude -Parent
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        [System.IO.File]::AppendAllText($exclude, ("`n# VM move kit: generated files, never commit`n" + ($add -join "`n") + "`n"), [System.Text.Encoding]::ASCII)
        Write-Mig ('added ' + $add.Count + ' narrow line(s) to .git/info/exclude (tools/migrate/.gitignore is missing or incomplete)') 'OK'
      }
      if (-not $DryRun) {
        $still = @($probes | Where-Object { -not (Test-KitPathIgnored $_) })
        if ($still.Count -gt 0) { Write-Mig ('STILL NOT IGNORED by git: ' + ($still -join ', ') + '. A ship could commit these. Do not ship until this is fixed.') 'FAIL'; $ok = $false }
      }
    }
    # Personal files that are already tracked (an earlier exporter run was shipped): ignore rules cannot hide them.
    $tracked = @(Invoke-GitRaw @('ls-files', '--', 'tools/migrate') | Where-Object { $_ })
    $bad = @($tracked | Where-Object { ([string]$_) -match '^tools/migrate/(start2\.bin|wallpaper\.[A-Za-z0-9]+|host-settings\.json|host-apps\.json|start-layout\.json|host-stopped\.txt|gpu-pack-manifest\.json|kit-manifest\.json|pillagers-runner-task\.xml|(out|logs|state)/.*)$' })
    if ($bad.Count -gt 0) {
      Write-Mig ('These personal or generated kit files are ALREADY tracked by git, so ignore rules do not stop a ship from committing changes to them: ' + (($bad | ForEach-Object { ([string]$_).Replace('tools/migrate/', '') }) -join ', ')) 'WARN'
      Write-Mig 'They are also already in the public history on GitHub. To stop tracking them from now on (the files stay on your disk), run this once yourself; the next ship then commits the removal:' 'WARN'
      Write-Mig ('   git -C "' + $script:RepoRoot + '" rm --cached -- ' + (($bad | ForEach-Object { '"' + [string]$_ + '"' }) -join ' ')) 'WARN'
      Write-Mig 'This kit never runs that command for you. The new look-and-feel exports are written outside the repository, so they no longer touch these tracked copies.' 'INFO'
    }
    return $ok
  } catch { Write-Mig ('could not check what git ignores: ' + $_.Exception.Message) 'WARN'; return $false }
}

# ------------------------------------------------------------------ host stopped check, VM disk, runner task export
function Test-HostStopped {
  # True when host-stopped.txt exists, says status=stopped, belongs to this PC and this git HEAD, and nothing of Pillagers runs here any more.
  # Strict on purpose: a marker with a blank status, no computer, no 40-character gitHead, no shipLockClear=yes or a wrong check= line is refused.
  $why = New-Object System.Collections.Generic.List[string]
  $kv = @{}
  $mp = Get-MarkerPath
  if (-not (Test-Path -LiteralPath $mp)) { $why.Add('host-stopped.txt does not exist (run host-stop.ps1 first)') }
  else {
    $kv = Read-KeyValueFile $mp
    if ($kv['status'] -ne 'stopped') { $why.Add('host-stopped.txt says status="' + $kv['status'] + '" (it must say stopped)') }
    if (-not $kv['computer']) { $why.Add('host-stopped.txt has no computer= line') }
    elseif ($kv['computer'] -ine $env:COMPUTERNAME) { $why.Add('host-stopped.txt was written on another PC (' + $kv['computer'] + ')') }
    if ($kv['shipLockClear'] -ne 'yes') { $why.Add('host-stopped.txt does not say shipLockClear=yes') }
    if (-not $kv['check']) { $why.Add('host-stopped.txt has no check= line (an older host-stop.ps1 wrote it): run host-stop.ps1 again') }
    else {
      $mlines = @(Get-Content -LiteralPath $mp -ErrorAction SilentlyContinue)
      if ($kv['check'] -ne (Get-MarkerCheck $mlines)) { $why.Add('host-stopped.txt check= does not match its content (edited by hand or cut short): run host-stop.ps1 again') }
    }
    $repo = Get-RepoState
    if (-not ($kv['gitHead'] -match '^[0-9a-f]{40}$')) { $why.Add('host-stopped.txt has no valid gitHead=') }
    elseif (-not $repo.Ok) { $why.Add('the repository state could not be read, so the marker cannot be compared with it') }
    elseif ($kv['gitHead'] -ne $repo.Head) {
      $why.Add('the repository moved since the stop (HEAD is now ' + $repo.Head.Substring(0, 8) + ', the marker says ' + $kv['gitHead'].Substring(0, 8) + ')')
    }
  }
  $snap = Get-ProcSnap
  if ((Select-Proc $snap @('bash.exe') $script:RxRunner).Count -gt 0) { $why.Add('the runner (nightly.sh) is running again') }
  if ((Select-Proc $snap @('bash.exe') $script:RxLane).Count -gt 0) { $why.Add('a helper lane is running again') }
  if ((Select-HelperProc $snap).Count -gt 0) { $why.Add('a helper run (Claude, Codex or Gemini on a job) is running again') }
  if ((Select-Proc $snap @('bash.exe', 'powershell.exe') $script:RxShip).Count -gt 0) { $why.Add('a ship is running') }
  if ((Select-Proc $snap @('powershell.exe', 'pwsh.exe') $script:RxFuzz).Count -gt 0) { $why.Add('the crash-hunting robot (fuzz.ps1) is running again') }
  if ((Select-Proc $snap @('bash.exe') $script:RxCorpus).Count -gt 0) { $why.Add('the full test run (corpus) is running again') }
  $lk = Get-ShipLock
  if ($lk.Exists) { $why.Add('the ship lock is held (' + $lk.Owner + ')') }
  try {
    foreach ($t in @(Get-PillagersTasks | Where-Object { $_.State -ne 'Disabled' })) { $why.Add('the scheduled task "' + $t.TaskName + '" is switched on again (it could start the runner)') }
  } catch { }
  return [pscustomobject]@{ Ok = ($why.Count -eq 0); Why = $why.ToArray(); Marker = $kv }
}

function Get-VmDiskInfo {
  # Needs an administrator window. GuestFreeAtLeast is a safe lower bound: virtual size minus the size of the .vhdx file now (-1 = unknown, fixed disk).
  param([string]$VMName)
  $r = [ordered]@{ Ok = $false; Error = ''; Path = ''; Type = ''; VirtualBytes = [int64]0; FileBytes = [int64]0; GuestFreeAtLeast = [int64]-1; HostVolumeFree = [int64]-1 }
  try {
    $drv = @(Get-VMHardDiskDrive -VMName $VMName -ErrorAction Stop | Where-Object { $_.Path })
    if ($drv.Count -eq 0) { throw 'The VM has no virtual hard disk.' }
    $vhd = Get-VHD -Path $drv[0].Path -ErrorAction Stop
    $r.Path = [string]$drv[0].Path
    $r.Type = [string]$vhd.VhdType
    $r.VirtualBytes = [int64]$vhd.Size
    $r.FileBytes = [int64]$vhd.FileSize
    if ($r.Type -ne 'Fixed') { $r.GuestFreeAtLeast = [Math]::Max([int64]0, ($r.VirtualBytes - $r.FileBytes)) }
    $r.HostVolumeFree = Get-DriveFreeBytes $r.Path
    $r.Ok = $true
  } catch { $r.Error = $_.Exception.Message }
  return [pscustomobject]$r
}

function Add-GpuEntryToManifest {
  # Puts (or refreshes) the gpu-driver.zip entry in payload\manifest.json so the VM can check the driver pack fingerprint.
  # With no manifest yet, writes a small one that lists only the driver pack. Returns $true when the manifest now has the entry.
  param([string]$ManifestPath, [string]$ZipPath)
  try {
    if (-not (Test-Path -LiteralPath $ZipPath)) { return $false }
    $len = [int64](Get-Item -LiteralPath $ZipPath).Length
    $sha = ''
    $pmPath = Get-GpuPackManifestPath
    if (Test-Path -LiteralPath $pmPath) {
      $pm = Get-Content -LiteralPath $pmPath -Raw | ConvertFrom-Json
      if (([int64]$pm.zipBytes -eq $len) -and ([string]$pm.zipSha256 -match '^[0-9a-f]{64}$')) { $sha = [string]$pm.zipSha256 }
    }
    if (-not $sha) { $sha = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant() }
    $entry = [ordered]@{
      file = 'gpu-driver.zip'; group = 'gpu'; part = 1; order = 5
      targetRoot = 'C:\Windows'; size = $len; sha256 = $sha; fileCount = 0; bytes = $len; optional = $true
      description = 'AMD driver pack for the GPU share; unpacked by vm-setup.ps1 stage gpu, NOT by the files stage'
    }
    $list = New-Object System.Collections.Generic.List[object]
    $mj = $null
    if (Test-Path -LiteralPath $ManifestPath) { $mj = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json }
    if ($null -ne $mj) {
      foreach ($a in @($mj.archives)) { if ([string]$a.file -ne 'gpu-driver.zip') { $list.Add($a) } }
      $list.Add([pscustomobject]$entry)
      $mj | Add-Member -NotePropertyName 'archives' -NotePropertyValue $list.ToArray() -Force
      Write-AsciiFile -Path $ManifestPath -Text ($mj | ConvertTo-Json -Depth 8)
    } else {
      $list.Add([pscustomobject]$entry)
      $skel = [ordered]@{
        schema = 1; created = (Get-Date).ToString('s'); host = $env:COMPUTERNAME; final = $false; gitHead = ''
        targetRoot = 'C:\'
        extract = 'tar.exe -xf <file> -C C:\   (check sha256 first; names inside are relative to C:\; extract in ascending order)'
        guestPayload = ($script:GuestStage + '\payload')
        archives = $list.ToArray(); skipped = @(); leftOutLiveStateCount = 0
      }
      Write-AsciiFile -Path $ManifestPath -Text ($skel | ConvertTo-Json -Depth 8)
    }
    return $true
  } catch {
    Write-Mig ('could not add the driver pack to manifest.json: ' + $_.Exception.Message) 'WARN'
    return $false
  }
}

function Export-RunnerTaskXml {
  # Saves the host task "Pillagers runner" as pillagers-runner-task.xml in the kit folder, with the user id replaced by a placeholder.
  param([string]$TaskName = 'Pillagers runner')
  $out = Join-Path $script:MigRoot 'pillagers-runner-task.xml'
  try {
    $xml = [string](Export-ScheduledTask -TaskName $TaskName -ErrorAction Stop)
    $xml = [regex]::Replace($xml, '<UserId>[^<]*</UserId>', '<UserId>S-1-5-21-REPLACE_WITH_VM_USER_SID</UserId>')
    $xml = [regex]::Replace($xml, '<Author>[^<]*</Author>', '<Author>Pillagers</Author>')
    $xml = [regex]::Replace($xml, '[^\x00-\x7F]', '')
    $xml = $xml.Replace('encoding="UTF-16"', 'encoding="UTF-8"')
    Write-AsciiFile -Path $out -Text $xml
    Write-Mig ('saved the "' + $TaskName + '" task as pillagers-runner-task.xml (user id replaced by a placeholder)') 'OK'
    return $true
  } catch {
    Write-Mig ('could not save the "' + $TaskName + '" task: ' + $_.Exception.Message + ' (the VM script will use its own copy of the task)') 'WARN'
    return $false
  }
}
