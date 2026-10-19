# unpack-session.ps1 : run INSIDE the VM (a normal PowerShell window, no administrator needed) after push-pack.ps1 has sent the session pack.
# It puts the Claude conversation, memory and move kit where Claude Code looks for them, installs the Claude Code command line if you agree,
# and opens a Claude window.
#
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1 -DryRun     (look first: nothing is written except the log)
#   powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1
#   -Zip PATH          the pack (default: next to this script, C:\PillagersMove, the Desktop, Downloads)
#   -DryRun            show what would be copied, kept or backed up; install nothing; open nothing
#   -Force             (a) go on without pack-manifest.json (the zip cannot be checked for damage), (b) resume the old conversation even though
#                      host-stopped.txt is not valid. A zip whose fingerprint is WRONG is never used, with or without -Force.
#   -InstallClaude     answer "yes" to the Claude Code install question
#   -NoOpen            do not open a Claude window at the end
#
# Safe to run twice. Per file: a file that is missing is copied; the same file is left alone; a file the VM already has in a NEWER version is kept;
# an older VM file is first moved to C:\PillagersMove\undo\unpack-<time>\ (same folder shape, drive letter as a folder) and then replaced.
# Nothing is deleted. Only files under three places are written: the Desktop\dark raiders folder, the Claude project folders, C:\PillagersMove\kit.
# Files with login-looking names are never written. host-stopped.txt and kit-manifest.json are never taken from the pack.
# The old conversation is resumed only when C:\PillagersMove\kit\host-stopped.txt is valid (status stopped, check= line right, from the main PC).
# Otherwise a fresh Claude window opens instead and you paste VM-CLAUDE-FIRST-MESSAGE.md, so nothing here thinks it may ship while the main PC still runs.
# Log: C:\PillagersMove\kit\logs\unpack-session-<time>.log (names only, never file contents).
# Exit codes: 0 done, 1 error, 2 refused.
# ASCII only (Windows PowerShell 5.1 reads scripts as ANSI).
param(
  [string]$Zip = '',
  [switch]$DryRun,
  [switch]$Force,
  [switch]$InstallClaude,
  [switch]$NoOpen
)
$ErrorActionPreference = 'Stop'
$SessionId  = '8a09e991-b4f4-4b23-b10f-ded92e837fc3'
$HostKey    = 'C--Users-User1-Desktop-dark-raiders'
$GuestStage = 'C:\PillagersMove'
$KitDir     = Join-Path $GuestStage 'kit'
$LogDir     = Join-Path $KitDir 'logs'
$Stamp      = Get-Date -Format 'yyyyMMdd-HHmmss'
$UndoRoot   = Join-Path $GuestStage ('undo\unpack-' + $Stamp)
$script:Log = ''

function Start-Log {
  try {
    if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
    $script:Log = Join-Path $LogDir ('unpack-session-' + $Stamp + '.log')
    Set-Content -LiteralPath $script:Log -Value ('# unpack-session started ' + (Get-Date -Format 's') + ' on ' + $env:COMPUTERNAME + ' as ' + $env:USERNAME) -Encoding ASCII
  } catch { $script:Log = '' }
}
function Write-Line([string]$Text, [string]$Color) {
  if ($Color) { Write-Host $Text -ForegroundColor $Color } else { Write-Host $Text }
  if ($script:Log) { try { Add-Content -LiteralPath $script:Log -Value ((Get-Date -Format 'HH:mm:ss') + ' ' + $Text) -Encoding ASCII } catch { } }
}
function Say([string]$m)  { Write-Line ('[pack] ' + $m) '' }
function Warn([string]$m) { Write-Line ('[pack] WARNING: ' + $m) 'Yellow' }
function Bad([string]$m)  { Write-Line ('[pack] PROBLEM: ' + $m) 'Red' }
function Dry([string]$m)  { Write-Line ('[pack] DRY: would ' + $m) 'Magenta' }

# Same rule as Test-SecretFileName in host-common.ps1 (this script runs where that file does not exist; keep the two the same).
function Test-SecretFileName([string]$Path) {
  $n = [System.IO.Path]::GetFileName($Path).ToLowerInvariant()
  $bad = @('auth.json', '.credentials.json', 'credentials.json', '.claude.json', '.git-credentials', '.netrc', '.npmrc', '.pypirc', 'butler_creds', 'id_rsa', 'id_rsa.pub', 'id_ed25519', 'id_ed25519.pub', 'id_ecdsa', 'id_ecdsa.pub', 'id_dsa', 'id_dsa.pub', 'login data', 'cookies', 'local state', 'oauth_creds.json', 'google_accounts.json', 'hosts.yml', 'token.json', 'tokens.json', 'secrets.json', 'secret.json')
  if ($bad -contains $n) { return $true }
  if ($n -match '^\.?(credentials?|oauth[_\-]?creds?)([_\-.].*)?$') { return $true }
  if ($n -match '(^|[_\-.])(access|refresh|auth|api|bearer)[_\-]?tokens?\.(json|txt|yml|yaml)$') { return $true }
  if ($n -match 'service[_\-]?account[^/\\]*\.json$') { return $true }
  $ext = [System.IO.Path]::GetExtension($n)
  if (@('.pem', '.pfx', '.p12', '.ppk', '.key', '.kdbx', '.jks', '.keystore', '.gpg', '.pgp') -contains $ext) { return $true }
  return $false
}

# Same rule as Get-MarkerCheck / Get-MarkerInfo in vm-setup.ps1 (keep the three the same).
function Get-MarkerCheck([string[]]$Lines) {
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

function Get-MarkerState {
  $o = [pscustomobject]@{ Exists = $false; Stopped = $false; Why = @() }
  $f = Join-Path $KitDir 'host-stopped.txt'
  if (-not (Test-Path -LiteralPath $f)) { $o.Why = @('host-stopped.txt does not exist in ' + $KitDir + ' yet (the main PC sends it at the very end)'); return $o }
  $o.Exists = $true
  $t = ''
  try { $t = [System.IO.File]::ReadAllText($f) } catch { }
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
  if ($dupes.Count -gt 0) { [void]$why.Add('these lines appear twice: ' + ($dupes -join ', ')) }
  $status = 'unknown'
  if ($kv.ContainsKey('status')) { $status = $kv['status'].ToLowerInvariant() }
  if ($status -ne 'stopped') { [void]$why.Add('the status line says "' + $status + '" (it must say exactly stopped)') }
  if (-not $kv.ContainsKey('computer') -or -not $kv['computer']) { [void]$why.Add('there is no computer= line') }
  elseif ($kv['computer'] -ieq $env:COMPUTERNAME) { [void]$why.Add('the marker names THIS computer; it must come from the main PC') }
  if (-not ($kv.ContainsKey('githead') -and $kv['githead'] -match '^[0-9a-fA-F]{40}$')) { [void]$why.Add('there is no full 40-character gitHead= line') }
  if (-not ($kv.ContainsKey('shiplockclear') -and $kv['shiplockclear'].ToLowerInvariant() -eq 'yes')) { [void]$why.Add('the marker does not say shipLockClear=yes') }
  if (-not $kv.ContainsKey('check')) { [void]$why.Add('there is no check= line') }
  elseif ($kv['check'].ToLowerInvariant() -ne (Get-MarkerCheck $allLines)) { [void]$why.Add('the check= line does not match the other lines (edited by hand or cut short)') }
  $o.Why = $why.ToArray()
  $o.Stopped = ($why.Count -eq 0)
  return $o
}

function Get-FileSha256([string]$Path) { return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() }

function Get-EntrySha256($Entry) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $s = $null
  try { $s = $Entry.Open(); $h = $sha.ComputeHash($s) } finally { if ($null -ne $s) { $s.Dispose() }; $sha.Dispose() }
  return (($h | ForEach-Object { $_.ToString('x2') }) -join '')
}

# Where does a zip member go? Returns the list of target files (more than one for the Claude project), or an empty list for a member that is not taken.
function Get-Targets([string]$Name, [string]$Cwd, [string[]]$ProjDirs) {
  $res = New-Object System.Collections.ArrayList
  $rel = ''
  $bases = @()
  if ($Name.StartsWith('desktop-dark-raiders/')) { $rel = $Name.Substring(21); $bases = @($Cwd) }
  elseif ($Name.StartsWith('claude-project/')) { $rel = $Name.Substring(15); $bases = @($ProjDirs) }
  elseif ($Name.StartsWith('kit/')) { $rel = $Name.Substring(4); $bases = @($KitDir) }
  else { return ,@() }
  if (-not $rel) { return ,@() }
  $parts = @($rel -split '/')
  foreach ($p in $parts) {
    if (-not $p -or $p -eq '.' -or $p -eq '..' -or $p -match '[<>:"|?*\x00-\x1f]' -or $p.EndsWith(' ') -or $p.EndsWith('.')) { return ,@() }
  }
  $relWin = $rel.Replace('/', '\')
  foreach ($b in $bases) {
    $baseFull = [System.IO.Path]::GetFullPath($b).TrimEnd('\')
    $dest = [System.IO.Path]::GetFullPath((Join-Path $baseFull $relWin))
    if (-not $dest.StartsWith($baseFull + '\', [System.StringComparison]::OrdinalIgnoreCase)) { return ,@() }
    [void]$res.Add($dest)
  }
  return ,$res.ToArray()
}

# copy | same | keep | replace | blocked
function Get-Action($Entry, [string]$Dest) {
  if (-not (Test-Path -LiteralPath $Dest)) { return 'copy' }
  if (-not (Test-Path -LiteralPath $Dest -PathType Leaf)) { return 'blocked' }
  $fi = Get-Item -LiteralPath $Dest -Force
  $eUtc = $Entry.LastWriteTime.UtcDateTime
  $dUtc = $fi.LastWriteTimeUtc
  if ($fi.Length -eq $Entry.Length) {
    if ([math]::Abs(($dUtc - $eUtc).TotalSeconds) -le 3) { return 'same' }
    # same size but a different time: the content decides (zip times are only exact to 2 seconds and carry no time zone)
    if ((Get-FileSha256 $Dest) -eq (Get-EntrySha256 $Entry)) { return 'same' }
  }
  if ($dUtc -gt $eUtc.AddSeconds(3)) { return 'keep' }
  return 'replace'
}

function Get-UndoPath([string]$Dest) {
  $d = $Dest
  if ($d.Length -ge 3 -and $d[1] -eq ':') { $d = $d.Substring(0, 1) + '\' + $d.Substring(3) }
  return (Join-Path $UndoRoot $d)
}

$exit = 0
try {
  Start-Log
  Say ('start' + $(if ($DryRun) { ' (dry run: nothing is written except this log)' } else { '' }))
  Add-Type -AssemblyName System.IO.Compression.FileSystem

  # ---- find the zip
  if (-not $Zip) {
    $cands = @()
    if ($PSScriptRoot) { $cands += (Join-Path $PSScriptRoot 'pillagers-session-pack.zip') }
    $cands += (Join-Path $GuestStage 'pillagers-session-pack.zip')
    $cands += (Join-Path $env:USERPROFILE 'Desktop\pillagers-session-pack.zip')
    $cands += (Join-Path $env:USERPROFILE 'OneDrive\Desktop\pillagers-session-pack.zip')
    $cands += (Join-Path $env:USERPROFILE 'Downloads\pillagers-session-pack.zip')
    foreach ($c in $cands) { if (Test-Path -LiteralPath $c) { $Zip = $c; break } }
  }
  if (-not $Zip -or -not (Test-Path -LiteralPath $Zip)) { Bad 'pillagers-session-pack.zip not found. On the main PC run build-pack.ps1 and then push-pack.ps1, or pass -Zip <path>.'; $exit = 2; throw 'stop' }
  $Zip = (Get-Item -LiteralPath $Zip).FullName
  Say ('using ' + $Zip)

  # ---- the zip must match what the main PC built
  $manPath = Join-Path (Split-Path -Path $Zip -Parent) 'pack-manifest.json'
  $man = $null
  if (Test-Path -LiteralPath $manPath) { try { $man = Get-Content -LiteralPath $manPath -Raw | ConvertFrom-Json } catch { $man = $null } }
  if ($null -ne $man -and $null -ne $man.zip -and $man.zip.sha256) {
    Say 'checking the fingerprint (SHA-256) of the zip against pack-manifest.json ...'
    $zh = Get-FileSha256 $Zip
    $zl = (Get-Item -LiteralPath $Zip).Length
    if ($zh -ne ([string]$man.zip.sha256).ToLowerInvariant() -or [int64]$man.zip.size -ne [int64]$zl) {
      Bad 'The zip is damaged or is not the one the main PC built (size or fingerprint differs). Push it again from the main PC (build-pack.ps1, then push-pack.ps1). Not used.'
      $exit = 2; throw 'stop'
    }
    Say ('zip is intact (built ' + $man.created + ' on ' + $man.host + ')')
  } elseif ($Force) {
    Warn 'There is no readable pack-manifest.json next to the zip, so the zip cannot be checked for damage. Going on because of -Force.'
  } else {
    Bad ('There is no readable pack-manifest.json next to the zip (' + $manPath + '), so the zip cannot be checked for damage. Push it again with push-pack.ps1, or add -Force to use it anyway.')
    $exit = 2; throw 'stop'
  }

  # ---- where things go (same working folder as on the main PC when the user name matches)
  if ($env:USERNAME -eq 'User1') { $cwd = 'C:\Users\User1\Desktop\dark raiders' } else { $cwd = Join-Path $env:USERPROFILE 'Desktop\dark raiders' }
  $key = ($cwd -replace '[^A-Za-z0-9]', '-')
  $projRoot = Join-Path $env:USERPROFILE '.claude\projects'
  $projDirs = @()
  foreach ($k in @($key, $HostKey) | Select-Object -Unique) { $projDirs += (Join-Path $projRoot $k) }
  Say ('working folder: ' + $cwd)

  # ---- go through the members
  $cnt = @{ copy = 0; same = 0; keep = 0; replace = 0; blocked = 0; secret = 0; unsafe = 0; ignored = 0 }
  $zf = [System.IO.Compression.ZipFile]::OpenRead($Zip)
  try {
    foreach ($e in $zf.Entries) {
      $name = $e.FullName.Replace('\', '/')
      if ($name.EndsWith('/')) { continue }
      if (Test-SecretFileName $name) { $cnt.secret++; Say ('left out (login-looking name): ' + $name); continue }
      $leaf = $name.Substring($name.LastIndexOf('/') + 1)
      if ($name.StartsWith('kit/') -and ($leaf -ieq 'host-stopped.txt' -or $leaf -ieq 'kit-manifest.json')) { $cnt.ignored++; Say ('not taken from the pack (the main PC sends it on its own): ' + $name); continue }
      $targets = Get-Targets $name $cwd $projDirs
      if ($null -eq $targets -or $targets.Count -eq 0) {
        if ($name.StartsWith('desktop-dark-raiders/') -or $name.StartsWith('claude-project/') -or $name.StartsWith('kit/')) { $cnt.unsafe++; Warn ('refused a member with an unsafe path: ' + $name) } else { $cnt.ignored++ }
        continue
      }
      foreach ($dest in $targets) {
        $act = Get-Action $e $dest
        if ($act -eq 'same') { $cnt.same++; continue }
        if ($act -eq 'keep') { $cnt.keep++; Say ('kept the VM copy (it is newer): ' + $dest); continue }
        if ($act -eq 'blocked') { $cnt.blocked++; Warn ('not written, a folder is in the way: ' + $dest); continue }
        if ($DryRun) {
          if ($act -eq 'copy') { $cnt.copy++; if ($cnt.copy -le 25) { Dry ('copy ' + $dest) } }
          else { $cnt.replace++; Dry ('back up the older VM file to ' + (Get-UndoPath $dest) + ' and replace ' + $dest) }
          continue
        }
        $dir = Split-Path -Path $dest -Parent
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        $part = $dest + '.unpack-part'
        $undo = ''
        try {
          [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $part, $true)
          if ($act -eq 'replace') {
            $undo = Get-UndoPath $dest
            $udir = Split-Path -Path $undo -Parent
            if (-not (Test-Path -LiteralPath $udir)) { New-Item -ItemType Directory -Force -Path $udir | Out-Null }
            Move-Item -LiteralPath $dest -Destination $undo -Force
          }
          Move-Item -LiteralPath $part -Destination $dest -Force
          if ($act -eq 'replace') { $cnt.replace++; Say ('replaced (old file backed up): ' + $dest) } else { $cnt.copy++ }
        } catch {
          # a file in use, a full disk, a path that is too long: leave the VM file as it was and go on with the next member
          $cnt.blocked++
          Warn ('could not write ' + $dest + ' - ' + $_.Exception.Message)
          if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force -ErrorAction SilentlyContinue }
          if ($undo -and (Test-Path -LiteralPath $undo) -and -not (Test-Path -LiteralPath $dest)) { try { Move-Item -LiteralPath $undo -Destination $dest -Force } catch { Warn ('the old file is safe at ' + $undo) } }
        }
      }
    }
  } finally { $zf.Dispose() }
  if ($DryRun -and $cnt.copy -gt 25) { Say ('... and ' + ($cnt.copy - 25) + ' more file(s) to copy') }
  Say ('files: ' + $cnt.copy + ' ' + $(if ($DryRun) { 'to copy' } else { 'copied' }) + ', ' + $cnt.replace + ' ' + $(if ($DryRun) { 'to replace (old one backed up first)' } else { 'replaced (old one backed up)' }) + ', ' + $cnt.same + ' already the same, ' + $cnt.keep + ' kept (VM copy newer), ' + $cnt.secret + ' left out by name, ' + $cnt.unsafe + ' refused (unsafe path), ' + $cnt.blocked + ' blocked, ' + $cnt.ignored + ' not taken')
  if ($cnt.replace -gt 0 -and -not $DryRun) { Say ('old versions are in ' + $UndoRoot) }
  Say ('working folder: ' + $cwd + '; conversation + memory in: ' + ($projDirs -join ', ') + '; move kit in: ' + $KitDir)

  # ---- Claude Code
  $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
  if (-not (Test-Path -LiteralPath $claude)) {
    $onPath = Get-Command claude -ErrorAction SilentlyContinue
    if ($onPath) { $claude = $onPath.Source }
  }
  if (-not (Test-Path -LiteralPath $claude)) {
    if ($DryRun) { Dry 'ask whether to install Claude Code (official installer from claude.ai, or winget Anthropic.ClaudeCode)' }
    else {
      $go = [bool]$InstallClaude
      if (-not $go) {
        $ans = ''
        try { $ans = Read-Host 'Claude Code is not installed in this VM. Install it from the official installer at https://claude.ai/install.ps1 ? Type Y to install, anything else to skip' } catch { $ans = '' }
        $go = ($ans.Trim() -ieq 'y')
      }
      if ($go) {
        Say 'installing Claude Code: downloading the official installer to a file first'
        try {
          [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
          $work = Join-Path $GuestStage 'work'
          if (-not (Test-Path -LiteralPath $work)) { New-Item -ItemType Directory -Force -Path $work | Out-Null }
          $inst = Join-Path $work 'claude-install.ps1'
          Invoke-WebRequest -UseBasicParsing -Uri 'https://claude.ai/install.ps1' -OutFile $inst
          Say ('installer saved: ' + $inst + ' (' + (Get-Item -LiteralPath $inst).Length + ' bytes, sha256 ' + (Get-FileSha256 $inst).Substring(0, 16) + '...)')
          & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $inst
        } catch { Warn ('the official installer did not finish: ' + $_.Exception.Message) }
        $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
        if (-not (Test-Path -LiteralPath $claude)) {
          $onPath = Get-Command claude -ErrorAction SilentlyContinue
          if ($onPath) { $claude = $onPath.Source }
        }
        if (-not (Test-Path -LiteralPath $claude)) {
          $wg = Get-Command winget -ErrorAction SilentlyContinue
          if ($wg) {
            Say 'trying winget (Anthropic.ClaudeCode); winget shows its own licence questions, answer them yourself'
            try { & $wg.Source install --id Anthropic.ClaudeCode --exact --source winget } catch { Warn ('winget did not finish: ' + $_.Exception.Message) }
            $claude = Join-Path $env:USERPROFILE '.local\bin\claude.exe'
            if (-not (Test-Path -LiteralPath $claude)) {
              $onPath = Get-Command claude -ErrorAction SilentlyContinue
              if ($onPath) { $claude = $onPath.Source }
            }
          }
        }
      } else { Say 'Claude Code was not installed (you chose not to). Run this script again with -InstallClaude when you want it.' }
    }
  }
  $haveClaude = (Test-Path -LiteralPath $claude)
  if (-not $haveClaude -and -not $DryRun) { Warn 'Claude Code is not installed, so no Claude window is opened.' }

  # ---- open a Claude window: resume the old conversation only when the main PC is stopped
  $mk = Get-MarkerState
  $resume = $false
  if ($mk.Stopped) { $resume = $true; Say 'host-stopped.txt is valid: the main PC says it is stopped, so the old conversation may be resumed.' }
  elseif ($Force) { $resume = $true; Warn 'host-stopped.txt is not valid, but -Force was given. Do NOT start the runner, the helper lanes or any ship from the resumed conversation until the main PC is stopped.'; foreach ($w in @($mk.Why)) { Warn ('   ' + $w) } }
  else {
    Say 'NOT resuming the old conversation yet (the main PC is not confirmed stopped):'
    foreach ($w in @($mk.Why)) { Say ('   ' + $w) }
    Say 'A fresh Claude window is opened instead. Paste the text of C:\PillagersMove\kit\VM-CLAUDE-FIRST-MESSAGE.md as its first message.'
    Say 'To resume the old conversation anyway, run this script again with -Force.'
  }
  if ($DryRun) { Dry $(if ($resume) { 'open Claude and resume the old conversation' } else { 'open a fresh Claude window' }) }
  elseif ($NoOpen) { Say 'not opening a Claude window (-NoOpen)' }
  elseif ($haveClaude) {
    $cwdQ = $cwd.Replace("'", "''")
    $claudeQ = $claude.Replace("'", "''")
    if ($resume) { $cmd = "Set-Location -LiteralPath '$cwdQ'; & '$claudeQ' --resume $SessionId" }
    else { $cmd = "Set-Location -LiteralPath '$cwdQ'; & '$claudeQ'" }
    Say 'opening a Claude window (sign in there if it asks; you sign in yourself)'
    Start-Process powershell.exe -ArgumentList @('-NoExit', '-Command', $cmd) -WorkingDirectory $cwd
  }
  Say 'done'
} catch {
  if ($exit -eq 0) { $exit = 1; Bad ($_.Exception.Message) }
}
if ($script:Log) { Write-Host ('      log file: ' + $script:Log) -ForegroundColor DarkGray }
exit $exit
