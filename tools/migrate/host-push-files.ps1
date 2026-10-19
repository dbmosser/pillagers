# host-push-files.ps1 : packs the Pillagers files the VM needs into tar archives and sends them into the VM (C:\PillagersMove\payload).
#
# Run it in an ADMINISTRATOR PowerShell window (only -DryRun and -NoPush can run in a normal window):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -DryRun      (look first: sizes only, nothing is built)
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1"              (first pass, while Pillagers still runs here)
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -Final       (last pass, AFTER host-stop.ps1)
#   -IncludeOldBuilds     also send the older game builds (before v30, about 6 GB); do this last
#   -IncludeTranscripts   also send the Claude session transcripts (so /resume works in the VM; about 3.4 GB)
#   -Groups a,b           only these groups: memory, userfiles, scratch, repo, git, codexwork, builds, builds-old, transcripts
#   -NoPush               build the archives on this PC only (they are kept in the staging folder)
#   -PushOnly             do not rebuild; send what is already in the staging folder. It re-checks every archive's size AND sha256, and with -Final
#                         it also refuses a set that was not built by a -Final run, at the marker's git HEAD, after the marker was written
#   -NoKit                do not send the kit folder (tools\migrate) again. The look-and-feel export is sent from its own folder outside the repository
#   -CleanStaging         delete the staged archives after a successful send
#   -ChunkMB N            largest archive size, default 1024 (a few big files stay whole)
#   -MinHostFreeGB / -MinGuestFreeGB   safety room that must stay free on this PC and inside the VM (defaults 20 and 10)
#   -IgnoreVmDiskCheck    skip the VM disk check (only if you checked the free space inside the VM yourself)
#   -VMName NAME          the VM (default Pillagers_Oct26)
#
# What it never packs: sign-in files and keys (Claude, Codex, Gemini, GitHub, butler), browser profiles, node_modules, live lock and pid files,
# the stop signs, Ollama, test fixtures. Anything that looks like a key is left out and only its NAME is written to the log.
# Archives hold paths relative to C:\ so they unpack to the SAME paths in the VM:  tar.exe -xf <archive> -C C:\
# Files are staged OUTSIDE the repository (C:\Users\User1\AppData\Local\PillagersMove\out), so a ship can never commit them.
# Exit codes: 0 done, 2 refused or failed, 3 needs an administrator window, 1 error.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [string]$VMName = 'Pillagers_Oct26',
  [switch]$Final,
  [switch]$DryRun,
  [switch]$IncludeOldBuilds,
  [switch]$IncludeTranscripts,
  [string[]]$Groups = @(),
  [int]$ChunkMB = 1024,
  [int]$MinHostFreeGB = 20,
  [int]$MinGuestFreeGB = 10,
  [switch]$IgnoreVmDiskCheck,
  [switch]$NoPush,
  [switch]$PushOnly,
  [switch]$NoKit,
  [switch]$CleanStaging
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'host-push-files'

$t0 = Get-Date
$chunkBytes = [int64]$ChunkMB * 1MB
$payloadDir = Join-Path $script:HostStage 'payload'
$listDir = Join-Path $script:HostStage 'lists'
$overlayRoot = Join-Path $script:HostStage 'overlay'
$stagedManifest = Join-Path $payloadDir 'manifest.json'
$guestPayload = $script:GuestStage + '\payload'
$tarExe = Join-Path $env:SystemRoot 'System32\tar.exe'
$isAdmin = Test-IsAdmin
$script:Skipped = New-Object System.Collections.Generic.List[object]
$script:LeftOut = 0
$Groups = @($Groups | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })

Write-MigBlank
Write-Mig '=== PUSH FILES: pack the Pillagers files and send them into the VM ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: nothing is built, sent or changed; sizes only)' 'DRY' }
if ($Final) { Write-Mig 'FINAL pass: needs host-stopped.txt, and sends it into the VM last.' 'INFO' }
if (-not (Test-HostProfileOk)) { Exit-Mig 1 }
if ($ChunkMB -lt 64) { Write-Mig '-ChunkMB must be 64 or more.' 'FAIL'; Exit-Mig 1 }
if ($PushOnly -and ($NoPush -or $DryRun)) { Write-Mig '-PushOnly cannot be combined with -NoPush or -DryRun.' 'FAIL'; Exit-Mig 1 }
$needsAdmin = -not ($DryRun -or $NoPush)
if ($needsAdmin -and -not $isAdmin) {
  Write-Mig 'This step talks to Hyper-V, so it needs an administrator window.' 'FAIL'
  Write-Mig 'Right-click the PowerShell icon, choose "Run as administrator", and run the same command again.' 'FAIL'
  Write-Mig '(You can look first without one: add -DryRun.)' 'INFO'
  Exit-Mig 3
}
if (-not (Test-Path -LiteralPath $tarExe)) { Write-Mig ('tar.exe was not found at ' + $tarExe) 'FAIL'; Exit-Mig 1 }
try { $tv = @(& $tarExe --version 2>&1 | Select-Object -First 1); Write-Mig ('archiver: ' + [string]$tv[0]) 'INFO' } catch { }

# ------------------------------------------------------------------ the final pass needs a stopped host
if ($Final) {
  Write-MigBlank
  Write-Mig 'Checking that Pillagers is stopped on this PC' 'STEP'
  $hs = Test-HostStopped
  if (-not $hs.Ok) {
    foreach ($w in $hs.Why) { Write-Mig $w 'FAIL' }
    if ($DryRun) { Write-Mig 'A real -Final run would stop here. Run host-stop.ps1 first.' 'DRY' }
    else { Write-Mig 'Run host-stop.ps1 first, then try again.' 'FAIL'; Exit-Mig 2 }
  } else {
    $gh = [string]$hs.Marker['gitHead']
    if ($gh.Length -ge 8) { $gh = $gh.Substring(0, 8) }
    Write-Mig ('host-stopped.txt is valid (written ' + $hs.Marker['time'] + ', git ' + $gh + ')') 'OK'
  }
}

# ------------------------------------------------------------------ the groups
$allGroups = @(
  @{ Id = 'memory';      Order = 10; Optional = $false; Title = 'Claude memory (the rulebook)' },
  @{ Id = 'userfiles';   Order = 20; Optional = $false; Title = 'Desktop folder, Claude and Codex settings, backups, feedback, butler' },
  @{ Id = 'scratch';     Order = 30; Optional = $false; Title = 'ship pipeline scripts (the session scratchpad)' },
  @{ Id = 'repo';        Order = 40; Optional = $false; Title = 'Pillagers repository files' },
  @{ Id = 'git';         Order = 50; Optional = $false; Title = 'repository history (.git)' },
  @{ Id = 'codexwork';   Order = 60; Optional = $false; Title = 'Codex lane notes (.codex-work)' },
  @{ Id = 'builds';      Order = 70; Optional = $false; Title = 'game builds v30 and newer' },
  @{ Id = 'builds-old';  Order = 80; Optional = $true;  Title = 'older game builds (before v30)' },
  @{ Id = 'transcripts'; Order = 90; Optional = $true;  Title = 'Claude session transcripts' }
)
$selected = @()
if ($Groups.Count -gt 0) {
  foreach ($id in $Groups) {
    $g = $allGroups | Where-Object { $_.Id -eq $id } | Select-Object -First 1
    if (-not $g) { Write-Mig ('unknown group "' + $id + '". Choose from: ' + (($allGroups | ForEach-Object { $_.Id }) -join ', ')) 'FAIL'; Exit-Mig 1 }
    $selected += $g
  }
} else {
  foreach ($g in $allGroups) {
    if (-not $g.Optional) { $selected += $g }
    elseif (($g.Id -eq 'builds-old') -and $IncludeOldBuilds) { $selected += $g }
    elseif (($g.Id -eq 'transcripts') -and $IncludeTranscripts) { $selected += $g }
  }
}

$script:BinExt = @('.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico', '.bmp', '.mp3', '.ogg', '.wav', '.mp4', '.webm', '.woff', '.woff2', '.ttf', '.otf', '.zip', '.gz', '.tar', '.7z', '.exe', '.dll', '.pack', '.idx', '.bundle', '.sqlite', '.lnk', '.bin')
# repo files that are live state of THIS PC or belong to the kit: never sent.
# The kit scripts themselves (tools/migrate/*.ps1, host-settings.json, start2.bin) were swept into git by an earlier ship (commit c721a3ca), so they travel
# with the repo; otherwise the VM would show them as deleted and its first ship would delete them from master. Only generated files are left out.
$rxRepoLeftOut = '^(tools/migrate/(logs/|state/|out/|host-stopped\.txt$|host-apps\.json$|gpu-pack-manifest\.json$|kit-manifest\.json$|pillagers-runner-task\.xml$|start-layout\.json$)|tools/handoff/console/lane-[^/]+\.lock(/|$)|tools/handoff/console/pick\.lock(/|$)|tools/handoff/console/STOP$|tools/handoff/codex/STOP$|tools/handoff/stable\.freeze$|tools/handoff/(nightly/)?runner\.heartbeat$|\.claude/scheduled_tasks\.(lock|json)$)|(^|/)node_modules/|\.pid$|(^|/)\.git/'
# git-ignored files that are still worth sending
$rxIgnoredWanted = '^(\.claude/(settings\.local\.json|dark_raiders_run[^/]*\.txt)|dark_raiders_run[^/]*\.txt|stable\.html|exports/feedback-.*)$'

# ------------------------------------------------------------------ helpers
function Add-Skip {
  param([string]$Group, [string]$Path, [string]$Reason)
  $script:Skipped.Add([pscustomobject]@{ group = $Group; path = $Path; reason = $Reason })
}

function Get-TreeFiles {
  param([string]$Root, [bool]$IncludeDirs = $false, [string]$SkipFileRegex = '', [string[]]$SkipDirFull = @())
  $out = New-Object System.Collections.Generic.List[object]
  if (-not [System.IO.Directory]::Exists($Root)) { Write-Mig ('folder not found, skipped: ' + $Root) 'WARN'; return @() }
  $skipDirs = @($SkipDirFull | ForEach-Object { $_.TrimEnd('\').ToLowerInvariant() })
  $stack = New-Object System.Collections.Generic.Stack[string]
  $stack.Push($Root.TrimEnd('\'))
  while ($stack.Count -gt 0) {
    $d = $stack.Pop()
    $items = $null
    try { $items = (New-Object System.IO.DirectoryInfo($d)).GetFileSystemInfos() }
    catch { Write-Mig ('cannot read folder ' + $d + ': ' + $_.Exception.Message) 'WARN'; continue }
    foreach ($it in $items) {
      if (($it.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { Write-Mig ('link not followed: ' + $it.FullName) 'WARN'; continue }
      if ($it -is [System.IO.DirectoryInfo]) {
        if ($skipDirs -contains $it.FullName.ToLowerInvariant()) { continue }
        if ($IncludeDirs) { $out.Add([pscustomobject]@{ Full = $it.FullName; Src = $it.FullName; Size = [int64]0; IsDir = $true }) }
        $stack.Push($it.FullName)
      } else {
        if ($SkipFileRegex -and ($it.FullName -match $SkipFileRegex)) { $script:LeftOut++; continue }
        $out.Add([pscustomobject]@{ Full = $it.FullName; Src = $it.FullName; Size = [int64]$it.Length; IsDir = $false })
      }
    }
  }
  return @($out.ToArray() | Sort-Object Full)
}

function Add-OneFile {
  param($List, [string]$Path)
  $fi = New-Object System.IO.FileInfo($Path)
  if ($fi.Exists) { $List.Add([pscustomobject]@{ Full = $fi.FullName; Src = $fi.FullName; Size = [int64]$fi.Length; IsDir = $false }) }
}

function Get-GitFileList {
  # Paths relative to the repository, with forward slashes. Normal = tracked plus untracked-not-ignored. Ignored = ignored files.
  param([string]$Mode = 'Normal')
  $git = Get-GitExe
  if (-not $git) { throw 'git.exe was not found' }
  $a = '-C "' + $script:RepoRoot + '" ls-files -z -c -o --exclude-standard'
  if ($Mode -eq 'Ignored') { $a = '-C "' + $script:RepoRoot + '" ls-files -z -o -i --exclude-standard' }
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $git
  $psi.Arguments = $a
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.CreateNoWindow = $true
  $p = [System.Diagnostics.Process]::Start($psi)
  $ms = New-Object System.IO.MemoryStream
  $p.StandardOutput.BaseStream.CopyTo($ms)
  $p.WaitForExit()
  if ($p.ExitCode -ne 0) { throw ('git ls-files failed with exit code ' + $p.ExitCode) }
  $text = [System.Text.Encoding]::UTF8.GetString($ms.ToArray())
  return @($text.Split([char]0) | Where-Object { $_ })
}

# ---- one function per group; each returns a list of "sets" (a base folder, its files, and how they are scanned)
function Get-SetsMemory {
  $mem = $script:HostProfile + '\.claude\projects\C--Users-User1-Desktop-dark-raiders\memory'
  $sets = New-Object System.Collections.Generic.List[object]
  $files = @(Get-TreeFiles -Root $mem)
  $sets.Add(@{ Base = 'C:\'; Files = $files; Scan = 'full'; Generic = $true; ScanSkip = '' })
  # the one useful file that only the stale old-key memory folder has
  $stale = $script:HostProfile + '\.claude\projects\C--claudecode-dark-raiders\memory\pillagers-desktop-folder-retired.md'
  $dest = $mem + '\pillagers-desktop-folder-retired.md'
  if ((Test-Path -LiteralPath $stale) -and -not (Test-Path -LiteralPath $dest)) {
    $ov = $overlayRoot + '\Users\User1\.claude\projects\C--Users-User1-Desktop-dark-raiders\memory\pillagers-desktop-folder-retired.md'
    $len = (Get-Item -LiteralPath $stale).Length
    $one = @([pscustomobject]@{ Full = $ov; Src = $stale; Size = [int64]$len; IsDir = $false })
    $sets.Add(@{ Base = $overlayRoot; Files = $one; Scan = 'full'; Generic = $true; ScanSkip = '' })
  }
  return $sets.ToArray()
}

function Get-SetsUserFiles {
  $u = $script:HostProfile
  $f = New-Object System.Collections.Generic.List[object]
  foreach ($x in @(Get-TreeFiles -Root ($u + '\Desktop\dark raiders') -SkipFileRegex '(?i)scheduled_tasks\.lock$')) { $f.Add($x) }
  Add-OneFile $f ($u + '\Desktop\Pillagers Dev.lnk')
  # Claude Code settings: copied only when its env block has no key-like names
  $sj = $u + '\.claude\settings.json'
  if (Test-Path -LiteralPath $sj) {
    $okCopy = $true
    try {
      $j = Get-Content -LiteralPath $sj -Raw | ConvertFrom-Json
      if ($j.env) {
        foreach ($p in $j.env.PSObject.Properties) {
          if ($p.Name -match '(?i)key|token|secret|passw|auth|credential|bearer') { $okCopy = $false; Add-Skip 'userfiles' $sj ('env block has a key-like name: ' + $p.Name) }
        }
      }
    } catch { $okCopy = $false; Add-Skip 'userfiles' $sj 'settings.json could not be read' }
    if ($okCopy) { Add-OneFile $f $sj }
  }
  $st = $u + '\.claude\scheduled-tasks'
  if (Test-Path -LiteralPath $st) {
    foreach ($d in @(Get-ChildItem -LiteralPath $st -Directory -ErrorAction SilentlyContinue)) { Add-OneFile $f ($d.FullName + '\SKILL.md') }
  }
  Add-OneFile $f ($u + '\.codex\config.toml')
  foreach ($x in @(Get-TreeFiles -Root ($u + '\Documents\dark-raiders-backups'))) { $f.Add($x) }
  $dl = $u + '\Downloads'
  if (Test-Path -LiteralPath $dl) {
    foreach ($x in @(Get-ChildItem -LiteralPath $dl -File -ErrorAction SilentlyContinue | Where-Object { ($_.Name -like 'pillagers_feedback_*.txt') -or ($_.Name -like 'salvagerun-backup*') })) { Add-OneFile $f $x.FullName }
  }
  $bin = $u + '\bin'
  if (Test-Path -LiteralPath $bin) {
    foreach ($x in @(Get-ChildItem -LiteralPath $bin -File -ErrorAction SilentlyContinue)) { Add-OneFile $f $x.FullName }
  }
  return @(@{ Base = 'C:\'; Files = @($f.ToArray() | Sort-Object Full); Scan = 'full'; Generic = $true; ScanSkip = '' })
}

function Get-SetsScratch {
  $S = $script:ScratchPad
  $okExt = @('.sh', '.ps1', '.js', '.mjs', '.cjs', '.pl', '.py', '.md', '.json', '.txt', '.cmd', '.vbs', '.bat', '.xml', '.toml')
  $f = New-Object System.Collections.Generic.List[object]
  if (-not [System.IO.Directory]::Exists($S)) { Write-Mig ('scratchpad folder not found: ' + $S) 'WARN'; return @() }
  foreach ($fi in (New-Object System.IO.DirectoryInfo($S)).GetFiles()) {
    if ($okExt -notcontains $fi.Extension.ToLowerInvariant()) { continue }
    if ($fi.Length -gt 8MB) { continue }
    if ($fi.Name -match '(?i)^(shipq\.(owner|clearing|log)|corpus\.lock)$|\.(pid|lock|heartbeat)$|^heartbeat\.(txt|json)$') { $script:LeftOut++; continue }
    $f.Add([pscustomobject]@{ Full = $fi.FullName; Src = $fi.FullName; Size = [int64]$fi.Length; IsDir = $false })
  }
  foreach ($d in @('qpage', 'art-survey-page', 'menu-survey-page')) {
    foreach ($x in @(Get-TreeFiles -Root ($S + '\' + $d))) { $f.Add($x) }
  }
  return @(@{ Base = 'C:\'; Files = @($f.ToArray() | Sort-Object Full); Scan = 'full'; Generic = $true; ScanSkip = '' })
}

function Get-SetsRepo {
  $f = New-Object System.Collections.Generic.List[object]
  $seen = @{}
  $names = @(Get-GitFileList -Mode 'Normal')
  Write-Mig ('   git lists ' + $names.Count + ' tracked or new files') 'INFO'
  foreach ($rel in $names) {
    if ($rel -match $rxRepoLeftOut) { $script:LeftOut++; continue }
    $full = $script:RepoRoot + '\' + $rel.Replace('/', '\')
    $fi = New-Object System.IO.FileInfo($full)
    if (-not $fi.Exists) { continue }
    $seen[$rel] = $true
    $f.Add([pscustomobject]@{ Full = $fi.FullName; Src = $fi.FullName; Size = [int64]$fi.Length; IsDir = $false })
  }
  $extra = @(Get-GitFileList -Mode 'Ignored')
  $nExtra = 0
  foreach ($rel in $extra) {
    if ($seen.ContainsKey($rel)) { continue }
    if ($rel -notmatch $rxIgnoredWanted) { continue }
    if ($rel -match $rxRepoLeftOut) { continue }
    $full = $script:RepoRoot + '\' + $rel.Replace('/', '\')
    $fi = New-Object System.IO.FileInfo($full)
    if (-not $fi.Exists) { continue }
    $f.Add([pscustomobject]@{ Full = $fi.FullName; Src = $fi.FullName; Size = [int64]$fi.Length; IsDir = $false })
    $nExtra++
  }
  Write-Mig ('   plus ' + $nExtra + ' git-ignored files worth keeping (saved runs, feedback exports, stable.html)') 'INFO'
  return @(@{ Base = 'C:\'; Files = @($f.ToArray() | Sort-Object Full); Scan = 'full'; Generic = $false; ScanSkip = '' })
}

function Get-SetsGit {
  $gd = $script:RepoRoot + '\.git'
  $skip = '(?i)\\\.git\\(PILLAGERS_MOVED_TO_VM\.txt|index\.lock|gc\.pid)$|\.lock$|\\objects\\pack\\tmp_[^\\]*$'
  $files = @(Get-TreeFiles -Root $gd -IncludeDirs $true -SkipFileRegex $skip)
  # objects and logs are history (public on GitHub); everything else in .git (config, hooks, info) is checked for keys
  return @(@{ Base = 'C:\'; Files = $files; Scan = 'full'; Generic = $true; ScanSkip = '(?i)\\\.git\\(objects|logs)\\' })
}

function Get-SetsCodexWork {
  $files = @(Get-TreeFiles -Root ($script:CodexRoot + '\.codex-work'))
  return @(@{ Base = 'C:\'; Files = $files; Scan = 'full'; Generic = $true; ScanSkip = '' })
}

$script:BuildsAll = $null
function Get-SetsBuilds {
  param([bool]$Old)
  if ($null -eq $script:BuildsAll) { $script:BuildsAll = @(Get-TreeFiles -Root ($script:RepoRoot + '\builds')) }
  $pick = New-Object System.Collections.Generic.List[object]
  foreach ($x in $script:BuildsAll) {
    $leaf = [System.IO.Path]::GetFileName($x.Full)
    $isOld = $false
    if ($leaf -match '^v(\d+)\.(\d+)\.html$') { $isOld = ([int]$Matches[1] -lt 30) }
    if ($isOld -eq $Old) { $pick.Add($x) }
  }
  # builds are the game's own generated html (the same text as the scanned repo files): only file names are checked
  return @(@{ Base = 'C:\'; Files = $pick.ToArray(); Scan = 'none'; Generic = $false; ScanSkip = '' })
}

function Get-SetsTranscripts {
  $root = $script:HostProfile + '\.claude\projects\C--Users-User1-Desktop-dark-raiders'
  $files = @(Get-TreeFiles -Root $root -SkipDirFull @(($root + '\memory')))
  return @(@{ Base = 'C:\'; Files = $files; Scan = 'full'; Generic = $true; ScanSkip = '' })
}

function Get-GroupSets {
  param([string]$Id)
  switch ($Id) {
    'memory'      { return @(Get-SetsMemory) }
    'userfiles'   { return @(Get-SetsUserFiles) }
    'scratch'     { return @(Get-SetsScratch) }
    'repo'        { return @(Get-SetsRepo) }
    'git'         { return @(Get-SetsGit) }
    'codexwork'   { return @(Get-SetsCodexWork) }
    'builds'      { return @(Get-SetsBuilds -Old $false) }
    'builds-old'  { return @(Get-SetsBuilds -Old $true) }
    'transcripts' { return @(Get-SetsTranscripts) }
  }
  return @()
}

# ---- checks every file: plain ASCII name, not a credential file name, no key inside; returns the files that may be packed
function Invoke-ScanSet {
  param($Set, [string]$GroupId)
  $kept = New-Object System.Collections.Generic.List[object]
  $base = ([string]$Set.Base).TrimEnd('\')
  $total = @($Set.Files).Count
  $i = 0
  foreach ($f in @($Set.Files)) {
    $i++
    if (($i % 3000) -eq 0) { Write-Mig ('   ' + $GroupId + ': checked ' + $i + ' of ' + $total + ' files') 'INFO' }
    if (-not $f.Full.StartsWith($base + '\', [System.StringComparison]::OrdinalIgnoreCase)) { Add-Skip $GroupId $f.Full 'is outside its base folder'; continue }
    $rel = $f.Full.Substring($base.Length + 1)
    if ($rel -match '[^\x20-\x7E]') { Add-Skip $GroupId $f.Full 'the name has characters other than plain ASCII'; continue }
    if (-not $f.IsDir) {
      if (Test-SecretFileName $f.Full) { Add-Skip $GroupId $f.Full 'credential file name'; continue }
      if ($Set.Scan -eq 'full') {
        $ext = [System.IO.Path]::GetExtension($f.Full).ToLowerInvariant()
        $doScan = ($script:BinExt -notcontains $ext)
        if ($doScan -and $Set.ScanSkip -and ($f.Full -match $Set.ScanSkip)) { $doScan = $false }
        if ($doScan) {
          $k = Find-SecretKindsInFile -Path $f.Src -Generic ([bool]$Set.Generic)
          if ($k.Count -gt 0) {
            if ($k -contains 'unreadable') { Add-Skip $GroupId $f.Full 'could not be read (in use?)' }
            else { Add-Skip $GroupId $f.Full ('looks like it holds a key: ' + ($k -join ', ')) }
            continue
          }
        }
      }
    }
    $kept.Add([pscustomobject]@{ Full = $f.Full; Src = $f.Src; Size = $f.Size; IsDir = $f.IsDir; Rel = $rel })
  }
  return $kept.ToArray()
}

function Split-Parts {
  param([object[]]$Files, [int64]$ChunkBytes)
  $cur = New-Object System.Collections.Generic.List[object]
  $curBytes = [int64]0
  foreach ($f in $Files) {
    if (($cur.Count -gt 0) -and (($curBytes + $f.Size) -gt $ChunkBytes)) {
      [pscustomobject]@{ Files = $cur.ToArray(); Bytes = $curBytes }
      $cur = New-Object System.Collections.Generic.List[object]
      $curBytes = [int64]0
    }
    $cur.Add($f)
    $curBytes += $f.Size
  }
  if ($cur.Count -gt 0) { [pscustomobject]@{ Files = $cur.ToArray(); Bytes = $curBytes } }
}

function New-Archive {
  # Builds one tar archive from a part. Returns an object with Ok, Code, Note.
  param($Part, [string]$OutFile)
  $res = [ordered]@{ Ok = $false; Code = -1; Note = '' }
  foreach ($f in $Part.Files) {
    if (($f.Src -ne $f.Full) -and -not $f.IsDir) {
      $dir = Split-Path -Path $f.Full -Parent
      if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
      Copy-Item -LiteralPath $f.Src -Destination $f.Full -Force
    }
  }
  $listFile = Join-Path $listDir ($Part.File + '.list')
  $errFile = Join-Path $listDir ($Part.File + '.err')
  $sb = New-Object System.Text.StringBuilder
  foreach ($f in $Part.Files) { [void]$sb.Append($f.Rel.Replace('\', '/')).Append("`n") }
  [System.IO.File]::WriteAllText($listFile, $sb.ToString(), [System.Text.Encoding]::ASCII)
  $baseArg = ([string]$Part.Base).Replace('\', '/').TrimEnd('/') + '/'
  if (Test-Path -LiteralPath $OutFile) { Remove-Item -LiteralPath $OutFile -Force }
  & $tarExe --no-recursion -cf $OutFile -C $baseArg -T $listFile 2> $errFile
  $res.Code = $LASTEXITCODE
  $errLines = @()
  if (Test-Path -LiteralPath $errFile) { $errLines = @(Get-Content -LiteralPath $errFile -TotalCount 4 -ErrorAction SilentlyContinue) }
  if ($res.Code -ne 0) { $res.Note = (($errLines | ForEach-Object { [string]$_ }) -join ' | ') }
  $res.Ok = ((Test-Path -LiteralPath $OutFile) -and ($res.Code -eq 0))
  return [pscustomobject]$res
}

# ------------------------------------------------------------------ PUSH ONLY: use what is already staged
$archives = New-Object System.Collections.Generic.List[object]
$totalBytes = [int64]0
$repoState = Get-RepoState

if ($PushOnly) {
  Write-MigBlank
  Write-Mig 'Using the archives already staged on this PC' 'STEP'
  if (-not (Test-Path -LiteralPath $stagedManifest)) { Write-Mig ('no staged manifest at ' + $stagedManifest + '. Run without -PushOnly first.') 'FAIL'; Exit-Mig 2 }
  $mj = Get-Content -LiteralPath $stagedManifest -Raw | ConvertFrom-Json
  # A staged set only fits a -Final push when it was built by a -Final run, at the git HEAD the marker names, after host-stop wrote the marker.
  # (Otherwise a first-pass set, built while Pillagers still ran here, could be sent as if it were the final copy.)
  if ($Final) {
    if (-not [bool]$mj.final) { Write-Mig 'The staged archives come from a first pass (not -Final), built while Pillagers still ran here. Build them again: host-push-files.ps1 -Final (without -PushOnly).' 'FAIL'; Exit-Mig 2 }
    if ($repoState.Ok -and ([string]$mj.gitHead -ne $repoState.Head)) { Write-Mig ('The staged archives were built at git ' + ([string]$mj.gitHead).Substring(0, [Math]::Min(8, ([string]$mj.gitHead).Length)) + ' but HEAD is now ' + $repoState.Head.Substring(0, 8) + '. Build them again: host-push-files.ps1 -Final (without -PushOnly).') 'FAIL'; Exit-Mig 2 }
    $mk = Read-KeyValueFile (Get-MarkerPath)
    $mkTime = $null
    if ($mk['time']) { $mkTime = $mk['time'] -as [datetime] }
    $builtTime = $mj.created -as [datetime]
    if ($mkTime -and $builtTime -and ($builtTime -lt $mkTime)) { Write-Mig 'The staged archives are older than host-stopped.txt, so they may miss the last changes. Build them again: host-push-files.ps1 -Final (without -PushOnly).' 'FAIL'; Exit-Mig 2 }
  }
  foreach ($a in @($mj.archives)) {
    if ([string]$a.group -eq 'gpu') { continue }   # the driver pack is sent by host-vm-boost.ps1 and re-added to the manifest below
    $p = Join-Path $payloadDir $a.file
    if (-not (Test-Path -LiteralPath $p)) { Write-Mig ('staged archive is missing: ' + $a.file) 'FAIL'; Exit-Mig 2 }
    $len = (Get-Item -LiteralPath $p).Length
    if ($len -ne [int64]$a.size) { Write-Mig ('staged archive changed size: ' + $a.file) 'FAIL'; Exit-Mig 2 }
    # same size is not enough: check the fingerprint too, so a damaged or swapped archive is never sent
    $hNow = (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hNow -ne ([string]$a.sha256).ToLowerInvariant()) { Write-Mig ('staged archive does not match its fingerprint (sha256): ' + $a.file + '. Build the archives again without -PushOnly.') 'FAIL'; Exit-Mig 2 }
    $archives.Add($a)
    $totalBytes += [int64]$a.size
  }
  Write-Mig ($archives.Count.ToString() + ' staged archive(s), ' + (Format-Bytes $totalBytes)) 'OK'
  $manifestObj = $mj
}
else {
  # ---------------------------------------------------------------- enumerate and check
  Write-MigBlank
  Write-Mig ('Step 1: find the files (' + $selected.Count + ' groups)') 'STEP'
  Write-Mig ('groups: ' + (($selected | ForEach-Object { $_.Id }) -join ', ')) 'INFO'
  if (-not $Final) { Write-Mig 'First pass: Pillagers still runs on this PC, so the repository copy is a moving target. Run this again with -Final after host-stop.ps1.' 'WARN' }
  [void](Ensure-KitExcluded -DryRun:$DryRun)
  $plan = New-Object System.Collections.Generic.List[object]
  $summary = New-Object System.Collections.Generic.List[object]
  foreach ($g in $selected) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Mig ('[' + $g.Id + '] ' + $g.Title) 'STEP'
    $sets = @(Get-GroupSets -Id $g.Id)
    $skipBefore = $script:Skipped.Count
    $partNo = 0
    $gFiles = 0
    $gBytes = [int64]0
    foreach ($set in $sets) {
      $kept = @(Invoke-ScanSet -Set $set -GroupId $g.Id)
      $pieces = @(Split-Parts -Files $kept -ChunkBytes $chunkBytes)
      foreach ($pc in $pieces) {
        $partNo++
        $plan.Add([pscustomobject]@{
            Group = $g.Id; Order = $g.Order; Title = $g.Title; Optional = [bool]$g.Optional; Part = $partNo
            File = ('pillagers-' + $g.Id + '-' + $partNo.ToString('00') + '.tar')
            Base = [string]$set.Base; Files = $pc.Files; Bytes = [int64]$pc.Bytes; FileCount = @($pc.Files).Count
          })
        $gFiles += @($pc.Files).Count
        $gBytes += [int64]$pc.Bytes
      }
    }
    $nSkip = $script:Skipped.Count - $skipBefore
    Write-Mig ('   ' + $gFiles + ' files, ' + (Format-Bytes $gBytes) + ', ' + $partNo + ' archive(s), ' + $nSkip + ' left out, ' + [int]$sw.Elapsed.TotalSeconds + ' s') 'OK'
    $summary.Add([pscustomobject]@{ Id = $g.Id; Files = $gFiles; Bytes = $gBytes; Parts = $partNo; Skipped = $nSkip })
    $totalBytes += $gBytes
  }
  Write-MigBlank
  Write-Mig 'Left out on purpose' 'STEP'
  Write-Mig ('   ' + $script:LeftOut + ' live-state, lock, pid, node_modules and kit files (not listed)') 'INFO'
  if ($script:Skipped.Count -eq 0) { Write-Mig '   nothing looked like a key or a sign-in file' 'OK' }
  else {
    Write-Mig ('   ' + $script:Skipped.Count + ' file(s) were not packed (names only, never contents):') 'WARN'
    foreach ($s in ($script:Skipped | Select-Object -First 40)) { Write-Mig ('   [' + $s.group + '] ' + $s.path + '  (' + $s.reason + ')') 'WARN' }
    if ($script:Skipped.Count -gt 40) { Write-Mig ('   ... and ' + ($script:Skipped.Count - 40) + ' more, see the log') 'WARN'; foreach ($s in ($script:Skipped | Select-Object -Skip 40)) { Add-Content -LiteralPath $script:MigLog -Value ('   [' + $s.group + '] ' + $s.path + '  (' + $s.reason + ')') -Encoding ASCII } }
  }

  # ---------------------------------------------------------------- disk checks
  Write-MigBlank
  Write-Mig 'Step 2: disk space' 'STEP'
  $needGuest = ([int64]2 * $totalBytes) + ([int64]$MinGuestFreeGB * 1GB)
  $stageFree = Get-DriveFreeBytes $script:HostStage
  $stageDrive = [System.IO.Path]::GetPathRoot($script:HostStage)
  Write-Mig ('to send: ' + (Format-Bytes $totalBytes) + ' in ' + $plan.Count + ' archive(s) (the VM needs about twice that while it unpacks)') 'INFO'
  $diskOk = $true
  if ($stageFree -ge 0) {
    $leftStage = $stageFree - $totalBytes
    Write-Mig ('staging on ' + $stageDrive + ': ' + (Format-Bytes $stageFree) + ' free, ' + (Format-Bytes $leftStage) + ' would be left') $(if ($leftStage -ge ([int64]$MinHostFreeGB * 1GB)) { 'OK' } else { 'FAIL' })
    if ($leftStage -lt ([int64]$MinHostFreeGB * 1GB)) { $diskOk = $false }
  }
  $vmInfo = $null
  if ($isAdmin) {
    $vmInfo = Get-VmDiskInfo -VMName $VMName
    if (-not $vmInfo.Ok) { Write-Mig ('could not read the VM disk (' + $vmInfo.Error + ')') 'WARN'; if (-not $NoPush -and -not $DryRun -and -not $IgnoreVmDiskCheck) { $diskOk = $false } }
    else {
      $sameVol = ([System.IO.Path]::GetPathRoot($vmInfo.Path) -ieq $stageDrive)
      $hostNeed = [int64]2 * $totalBytes
      if ($sameVol) { $hostNeed += $totalBytes }
      $hostLeft = $vmInfo.HostVolumeFree - $hostNeed
      Write-Mig ('VM disk file ' + $vmInfo.Path + ' (' + $vmInfo.Type + ', ' + (Format-Bytes $vmInfo.FileBytes) + ' now of ' + (Format-Bytes $vmInfo.VirtualBytes) + ')') 'INFO'
      Write-Mig ('host volume of the VM disk: ' + (Format-Bytes $vmInfo.HostVolumeFree) + ' free, ' + (Format-Bytes $hostLeft) + ' would be left if the disk grows by ' + (Format-Bytes ([int64]2 * $totalBytes))) $(if ($hostLeft -ge ([int64]$MinHostFreeGB * 1GB)) { 'OK' } else { 'FAIL' })
      if ($hostLeft -lt ([int64]$MinHostFreeGB * 1GB)) { $diskOk = $false }
      if ($vmInfo.GuestFreeAtLeast -lt 0) { Write-Mig 'the VM disk is fixed-size, so its free space cannot be read from here; check inside the VM' 'WARN' }
      else {
        $okG = ($vmInfo.GuestFreeAtLeast -ge $needGuest)
        Write-Mig ('inside the VM at least ' + (Format-Bytes $vmInfo.GuestFreeAtLeast) + ' is free (safe lower bound); need ' + (Format-Bytes $needGuest)) $(if ($okG) { 'OK' } else { 'FAIL' })
        if (-not $okG -and -not $IgnoreVmDiskCheck) { $diskOk = $false }
      }
    }
  } else { Write-Mig 'not an administrator window, so the VM disk was not checked' 'SKIP' }
  if (-not $diskOk) {
    if ($DryRun) { Write-Mig 'A real run would stop here: not enough room (see FAIL lines).' 'DRY' }
    else { Write-Mig 'Stopping: not enough free space. Free some room, send fewer groups (-Groups), or lower -MinHostFreeGB / use -IgnoreVmDiskCheck if you have checked inside the VM.' 'FAIL'; Exit-Mig 2 }
  }

  # ---------------------------------------------------------------- dry run table
  if ($DryRun) {
    Write-MigBlank
    Write-Mig 'Dry run: what would be sent' 'STEP'
    foreach ($s in $summary) { Write-Mig (('   {0,-12} {1,7} files {2,12} {3,3} archive(s) {4,4} left out' -f $s.Id, $s.Files, (Format-Bytes $s.Bytes), $s.Parts, $s.Skipped)) 'DRY' }
    Write-Mig ('   {0,-12} {1,7} files {2,12} {3,3} archive(s)' -f 'TOTAL', (($summary | Measure-Object Files -Sum).Sum), (Format-Bytes $totalBytes), $plan.Count) 'DRY'
    $big = @($plan | ForEach-Object { $_.Files } | Sort-Object Size -Descending | Select-Object -First 6)
    Write-Mig 'largest single files:' 'DRY'
    foreach ($b in $big) { Write-Mig ('   ' + (Format-Bytes $b.Size) + '  ' + $b.Rel) 'DRY' }
    Write-Mig ('staging folder (not in the repository): ' + $script:HostStage) 'DRY'
    Write-Mig ('they would be sent to ' + $guestPayload + ' inside ' + $VMName) 'DRY'
    if (-not $NoKit) { Write-Mig ('the kit folder would be sent to ' + $script:GuestStage + '\kit') 'DRY' }
    if ($Final) { Write-Mig ('host-stopped.txt would be sent last to ' + $script:GuestStage + '\kit\host-stopped.txt') 'DRY' }
    Write-MigBlank
    Write-Mig 'Dry run finished. Nothing was built or sent.' 'DONE'
    Exit-Mig 0
  }

  # ---------------------------------------------------------------- build
  Write-MigBlank
  Write-Mig 'Step 3: build the archives (staged in a folder outside the repository)' 'STEP'
  if (Test-Path -LiteralPath $overlayRoot) { Remove-Item -LiteralPath $overlayRoot -Recurse -Force -ErrorAction SilentlyContinue }
  foreach ($d in @($payloadDir, $listDir)) { if (-not (Test-Path -LiteralPath $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null } }
  Get-ChildItem -LiteralPath $payloadDir -Filter 'pillagers-*.tar' -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $stagedManifest -Force -ErrorAction SilentlyContinue
  $built = 0
  foreach ($pt in $plan) {
    $built++
    $out = Join-Path $payloadDir $pt.File
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Mig ('[' + $built + '/' + $plan.Count + '] ' + $pt.File + ' (' + $pt.FileCount + ' files, ' + (Format-Bytes $pt.Bytes) + ')') 'INFO'
    $r = New-Archive -Part $pt -OutFile $out
    if (-not $r.Ok) {
      if ((-not $Final) -and (Test-Path -LiteralPath $out) -and ($r.Code -eq 1)) {
        Write-Mig ('   tar finished with warnings (files may have changed while being read): ' + $r.Note) 'WARN'
      } else {
        Write-Mig ('   tar failed with code ' + $r.Code + ': ' + $r.Note) 'FAIL'
        Write-Mig '   Nothing was sent. Fix the problem and run again.' 'FAIL'
        Exit-Mig 2
      }
    }
    $alen = (Get-Item -LiteralPath $out).Length
    if ($alen -lt $pt.Bytes) {
      if ($Final) { Write-Mig ('   the archive is smaller than its files (' + (Format-Bytes $alen) + ' < ' + (Format-Bytes $pt.Bytes) + '): a file changed while being read') 'FAIL'; Exit-Mig 2 }
      else { Write-Mig ('   the archive is smaller than its files (' + (Format-Bytes $alen) + ' < ' + (Format-Bytes $pt.Bytes) + '): a file changed while being read; the final pass will fix this') 'WARN' }
    }
    $hash = (Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToLowerInvariant()
    $archives.Add([ordered]@{
        file = $pt.File; group = $pt.Group; part = $pt.Part; order = ($pt.Order * 100 + $pt.Part)
        targetRoot = 'C:\'; size = [int64]$alen; sha256 = $hash; fileCount = $pt.FileCount; bytes = [int64]$pt.Bytes
        optional = [bool]$pt.Optional; description = $pt.Title
      })
    Write-Mig ('   done in ' + [int]$sw.Elapsed.TotalSeconds + ' s, sha256 ' + $hash.Substring(0, 12) + '...') 'OK'
  }
  if ($archives.Count -eq 0) { Write-Mig 'There was nothing to pack.' 'FAIL'; Exit-Mig 2 }
  # The authoritative list of repository files in THIS copy (paths only, relative to the repository). After a first pass and a -Final pass the VM can
  # then report files it still has from the first pass (or made itself) that are not in the final copy. Nothing is ever deleted from that list.
  $repoListName = ''
  $repoListSha = ''
  $repoListCount = 0
  $repoListFile = Join-Path $payloadDir 'repo-files.txt'
  Remove-Item -LiteralPath $repoListFile -Force -ErrorAction SilentlyContinue
  if (@($plan | Where-Object { $_.Group -eq 'repo' }).Count -gt 0) {
    try {
      $prefix = 'claudecode/dark raiders/'
      $sbL = New-Object System.Text.StringBuilder
      foreach ($pt in $plan) {
        if (@('repo', 'builds', 'builds-old') -notcontains [string]$pt.Group) { continue }
        foreach ($f in $pt.Files) {
          if ($f.IsDir) { continue }
          $rl = ([string]$f.Rel).Replace('\', '/')
          if ($rl.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { [void]$sbL.Append($rl.Substring($prefix.Length)).Append("`n"); $repoListCount++ }
        }
      }
      Write-AsciiFile -Path $repoListFile -Text $sbL.ToString()
      $repoListName = 'repo-files.txt'
      $repoListSha = (Get-FileHash -LiteralPath $repoListFile -Algorithm SHA256).Hash.ToLowerInvariant()
      Write-Mig ('wrote the list of ' + $repoListCount + ' repository files in this copy (repo-files.txt; the VM uses it to report leftovers)') 'OK'
    } catch { Write-Mig ('could not write repo-files.txt (' + $_.Exception.Message + '); the VM will skip the leftover-file report') 'WARN'; $repoListName = '' }
  }
  $skippedOut = @($script:Skipped.ToArray() | ForEach-Object { [ordered]@{ group = $_.group; path = $_.path; reason = $_.reason } })
  $manifestObj = [ordered]@{
    schema = 1
    created = (Get-Date).ToString('s')
    host = $env:COMPUTERNAME
    final = [bool]$Final
    gitHead = $repoState.Head
    targetRoot = 'C:\'
    extract = 'tar.exe -xf <file> -C C:\   (check sha256 first; names inside are relative to C:\; extract in ascending order)'
    guestPayload = $guestPayload
    archives = $archives.ToArray()
    repoFileList = $repoListName
    repoFileListSha256 = $repoListSha
    repoFileCount = $repoListCount
    skipped = $skippedOut
    leftOutLiveStateCount = $script:LeftOut
  }
  Write-AsciiFile -Path $stagedManifest -Text ($manifestObj | ConvertTo-Json -Depth 8)
  Write-Mig ('wrote ' + $stagedManifest) 'OK'
}

# the GPU driver pack (built by host-vm-boost.ps1) is listed in the manifest too, so the VM can check its fingerprint; this script does not send the zip itself
$gpuZipStaged = Join-Path $payloadDir 'gpu-driver.zip'
if (Test-Path -LiteralPath $gpuZipStaged) {
  if (Add-GpuEntryToManifest -ManifestPath $stagedManifest -ZipPath $gpuZipStaged) { Write-Mig 'listed gpu-driver.zip in manifest.json (the VM checks its fingerprint; host-vm-boost.ps1 sends the zip)' 'OK' }
}

if ($NoPush) {
  Write-MigBlank
  Write-Mig ('Built and staged in ' + $payloadDir + '. Send them later with:  host-push-files.ps1 -PushOnly' + $(if ($Final) { ' -Final' } else { '' })) 'DONE'
  Exit-Mig 0
}

# ------------------------------------------------------------------ push into the VM
Write-MigBlank
Write-Mig 'Step 4: send everything into the VM' 'STEP'
$vm = $null
try { $vm = Get-VM -Name $VMName -ErrorAction Stop } catch { Write-Mig ('The VM "' + $VMName + '" was not found: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
if ($vm.State -ne 'Running') {
  Write-Mig ('The VM is ' + $vm.State + '; starting it so files can be copied in.') 'INFO'
  try { Start-VM -Name $VMName -ErrorAction Stop | Out-Null } catch { Write-Mig ('Could not start the VM: ' + $_.Exception.Message) 'FAIL'; Exit-Mig 2 }
}
$gsi = Get-VMIntegrationService -VMName $VMName -Name 'Guest Service Interface' -ErrorAction SilentlyContinue
if ($gsi -and -not $gsi.Enabled) {
  try { Enable-VMIntegrationService -VMName $VMName -Name 'Guest Service Interface' -ErrorAction Stop; Write-Mig 'switched the VM file-copy channel (Guest Service Interface) on' 'OK' } catch { Write-Mig ('could not switch the file-copy channel on: ' + $_.Exception.Message) 'WARN' }
}
if (-not (Wait-GuestReady -VMName $VMName)) { Write-Mig 'The VM is not ready for file copies. Nothing was sent. Sign in to the VM, wait a minute, and run this again with -PushOnly.' 'FAIL'; Exit-Mig 2 }

if (-not $NoKit) {
  Write-Mig 'sending the kit folder (scripts) and the look-and-feel export (settings, wallpaper, Start layout) ...' 'INFO'
  [void](Ensure-KitExcluded)
  [void](Export-RunnerTaskXml)
  $kitStage = Join-Path $script:HostStage 'kitstage'
  if (-not (Send-KitToGuest -VMName $VMName -StageDir $kitStage)) { Write-Mig 'The kit did not arrive completely. Run again.' 'FAIL'; Exit-Mig 2 }
}

$sent = 0
$failed = $false
$n = 0
foreach ($a in $archives) {
  $n++
  $src = Join-Path $payloadDir $a.file
  Write-Mig ('[' + $n + '/' + $archives.Count + '] sending ' + $a.file + ' (' + (Format-Bytes ([double]$a.size)) + '); big files take a few minutes ...') 'INFO'
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  if (Copy-ToGuest -VMName $VMName -Source $src -GuestPath ($guestPayload + '\' + $a.file)) {
    $sent++
    Write-Mig ('   sent in ' + [int]$sw.Elapsed.TotalSeconds + ' s') 'OK'
  } else { $failed = $true; Write-Mig ('   FAILED: ' + $a.file) 'FAIL'; break }
}
if ($failed) {
  Write-Mig ('Stopped after ' + $sent + ' of ' + $archives.Count + ' archives. Nothing else was sent (no manifest, no marker). Fix the problem and run again with -PushOnly.') 'FAIL'
  Exit-Mig 2
}
if ([string]$manifestObj.repoFileList) {
  $rfSrc = Join-Path $payloadDir ([string]$manifestObj.repoFileList)
  if (Test-Path -LiteralPath $rfSrc) {
    $rfNow = (Get-FileHash -LiteralPath $rfSrc -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($rfNow -ne ([string]$manifestObj.repoFileListSha256).ToLowerInvariant()) { Write-Mig 'repo-files.txt does not match its fingerprint in the manifest. Build again without -PushOnly.' 'FAIL'; Exit-Mig 2 }
    if (Copy-ToGuest -VMName $VMName -Source $rfSrc -GuestPath ($guestPayload + '\' + [string]$manifestObj.repoFileList)) { Write-Mig 'sent repo-files.txt (the list of repository files in this copy)' 'OK' }
    else { Write-Mig 'repo-files.txt did not arrive. Run again with -PushOnly.' 'FAIL'; Exit-Mig 2 }
  } else { Write-Mig 'repo-files.txt is not staged any more, so the VM will skip its leftover-file report.' 'WARN' }
}
if (-not (Copy-ToGuest -VMName $VMName -Source $stagedManifest -GuestPath ($guestPayload + '\manifest.json'))) { Write-Mig 'The manifest did not arrive. Run again with -PushOnly.' 'FAIL'; Exit-Mig 2 }
Write-Mig ('sent manifest.json (' + $archives.Count + ' archives) to ' + $guestPayload) 'OK'

if ($Final) {
  $hs2 = Test-HostStopped
  if (-not $hs2.Ok) {
    foreach ($w in $hs2.Why) { Write-Mig $w 'FAIL' }
    Write-Mig 'Pillagers is not stopped any more, so host-stopped.txt was NOT sent. Run host-stop.ps1 again, then host-push-files.ps1 -Final.' 'FAIL'
    Exit-Mig 2
  }
  if (Copy-ToGuest -VMName $VMName -Source (Get-MarkerPath) -GuestPath ($script:GuestStage + '\kit\host-stopped.txt')) {
    Write-Mig ('sent host-stopped.txt to ' + $script:GuestStage + '\kit\host-stopped.txt - the VM may now start the runner and helpers') 'OK'
  } else { Write-Mig 'host-stopped.txt did not arrive. Run again with -PushOnly -Final.' 'FAIL'; Exit-Mig 2 }
}

# remember what was sent
try {
  $stateOut = [ordered]@{ time = (Get-Date).ToString('s'); vm = $VMName; final = [bool]$Final; archives = @($archives | ForEach-Object { [ordered]@{ file = $_.file; sha256 = $_.sha256 } }) }
  Write-AsciiFile -Path (Join-Path $script:StateDir 'push-state.json') -Text ($stateOut | ConvertTo-Json -Depth 5)
} catch { }
if ($CleanStaging) {
  Get-ChildItem -LiteralPath $payloadDir -Filter 'pillagers-*.tar' -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Write-Mig 'staged archives deleted from this PC' 'OK'
}

Write-MigBlank
Write-Mig ('DONE in ' + [int]((Get-Date) - $t0).TotalMinutes + ' min: ' + $archives.Count + ' archive(s), ' + (Format-Bytes $totalBytes) + ' sent to ' + $guestPayload) 'DONE'
if ($Final) {
  Write-Mig 'Next, inside the VM: run vm-setup.ps1 (stages files, services, health). It checks sha256 against manifest.json, unpacks to the same paths, and may start the runner because host-stopped.txt is there.' 'INFO'
} else {
  Write-Mig 'Next, inside the VM: run vm-setup.ps1 -Only files to unpack and look around. When you are ready to move for good: host-stop.ps1, then host-push-files.ps1 -Final.' 'INFO'
}
Exit-Mig 0
