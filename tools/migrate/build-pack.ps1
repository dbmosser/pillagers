# build-pack.ps1 : builds the SESSION PACK on the main PC. One zip with the Claude conversation, the Claude memory, a few Desktop notes
# and the move kit (tools\migrate). It is the small starter that lets a Claude window in the VM pick up where this one stopped.
# (The big files - the repository, game builds, transcripts - go through host-push-files.ps1, not through this pack.)
#
# Run it in a NORMAL PowerShell window (no administrator needed):
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1" -DryRun    (look first: names and sizes, nothing is built)
#   powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1"
# Then push-pack.ps1 (administrator window) sends it into the VM. Build it again right before pushing: it is a snapshot of the conversation.
#
# Where it writes: the zip, pack-manifest.json (size + sha256 of the zip) and a copy of unpack-session.ps1 go to
#   C:\Users\User1\AppData\Local\PillagersMove\out\pack
# which is OUTSIDE the repository, so a ship (git add -A) can never commit the 100+ MB zip or the private conversation inside it.
#
# Safety: every file is first copied to a private snapshot (the live conversation file is still being written to), and the SNAPSHOT is scanned
# with the same secret rules as host-push-files.ps1. A file whose name looks like a login file, whose content looks like a key, or that cannot
# be read or scanned is LEFT OUT (fail closed). Only the file's name and the kind of pattern are printed and logged, never the matching text.
# Exit codes: 0 done (even when some files were left out; read the WARN lines), 1 error.
# ASCII only. Works in Windows PowerShell 5.1 and PowerShell 7.
param(
  [switch]$DryRun
)
$ErrorActionPreference = 'Continue'
if (-not $PSScriptRoot) { Write-Host 'Please run this from its file, not pasted into a window.'; exit 1 }
$commonPath = Join-Path $PSScriptRoot 'host-common.ps1'
if (-not (Test-Path -LiteralPath $commonPath)) { Write-Host ('host-common.ps1 is missing next to this script: ' + $commonPath); exit 1 }
. $commonPath
Start-MigLog -Name 'build-pack'

$sessionId  = '8a09e991-b4f4-4b23-b10f-ded92e837fc3'
$hostKey    = 'C--Users-User1-Desktop-dark-raiders'
$projDir    = Join-Path $script:HostProfile ('.claude\projects\' + $hostKey)
$deskDir    = Join-Path $script:HostProfile 'Desktop\dark raiders'
$packDir    = Join-Path $script:HostStage 'pack'
$snapDir    = Join-Path $packDir 'snap'
$zipFinal   = Join-Path $packDir 'pillagers-session-pack.zip'
$zipTmp     = $zipFinal + '.tmp'
$manFinal   = Join-Path $packDir 'pack-manifest.json'
$unpackSrc  = Join-Path $PSScriptRoot 'unpack-session.ps1'
$unpackCopy = Join-Path $packDir 'unpack-session.ps1'
$binExt     = @('.jpg', '.jpeg', '.png', '.gif', '.bmp', '.ico', '.bin', '.zip', '.exe', '.dll')

$items   = New-Object System.Collections.ArrayList
$leftOut = New-Object System.Collections.ArrayList

function Add-PackFile {
  param([System.IO.FileInfo]$File, [string]$EntryName)
  if (($File.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { [void]$leftOut.Add([pscustomobject]@{ Name = $EntryName; Why = 'a link, not a plain file' }); return }
  if ($File.Name -match '\.(lock|tmp)$') { return }
  if (Test-SecretFileName $File.FullName) { [void]$leftOut.Add([pscustomobject]@{ Name = $EntryName; Why = 'the file name looks like a login or key file' }); return }
  [void]$items.Add([pscustomobject]@{ Full = $File.FullName; Entry = $EntryName; Size = [int64]$File.Length; Time = $File.LastWriteTime })
}

function Add-PackTree {
  param([string]$Root, [string]$Prefix)
  if (-not (Test-Path -LiteralPath $Root -PathType Container)) { Write-Mig ('not found, skipped: ' + $Root) 'WARN'; return }
  $rootFull = (Get-Item -LiteralPath $Root -Force).FullName.TrimEnd('\')
  foreach ($f in @(Get-ChildItem -LiteralPath $rootFull -Recurse -File -Force -ErrorAction SilentlyContinue)) {
    $rel = $f.FullName.Substring($rootFull.Length + 1).Replace('\', '/')
    Add-PackFile -File $f -EntryName ($Prefix + '/' + $rel)
  }
}

function Copy-Snapshot {
  # Copies a file that may be open for writing elsewhere (the live conversation) into a private file. Returns $true when the copy is complete.
  param([string]$Src, [string]$Dst)
  $in = $null
  $out = $null
  $ok = $false
  try {
    $in = [System.IO.File]::Open($Src, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, ([System.IO.FileShare]::ReadWrite -bor [System.IO.FileShare]::Delete))
    $out = [System.IO.File]::Open($Dst, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
    $in.CopyTo($out, 1048576)
    $ok = $true
  } catch { $ok = $false } finally {
    if ($null -ne $out) { $out.Dispose() }
    if ($null -ne $in) { $in.Dispose() }
  }
  return $ok
}

Write-MigBlank
Write-Mig '=== BUILD PACK: the session pack (conversation, memory, notes, move kit) ===' 'STEP'
if ($DryRun) { Write-Mig '(dry run: nothing is built or written except this log)' 'DRY' }
if (-not (Test-HostProfileOk)) { Exit-Mig 1 }

# ------------------------------------------------------------------ what goes in
Write-Mig 'Collecting the file list' 'STEP'
$n0 = $items.Count
if (Test-Path -LiteralPath $projDir -PathType Container) {
  $jl = Join-Path $projDir ($sessionId + '.jsonl')
  if (Test-Path -LiteralPath $jl) { Add-PackFile -File (Get-Item -LiteralPath $jl -Force) -EntryName ('claude-project/' + $sessionId + '.jsonl') }
  else { Write-Mig ('the conversation file ' + $sessionId + '.jsonl was not found, so the VM cannot resume it') 'WARN' }
  Add-PackTree -Root (Join-Path $projDir $sessionId) -Prefix ('claude-project/' + $sessionId)
  Add-PackTree -Root (Join-Path $projDir 'memory') -Prefix 'claude-project/memory'
} else { Write-Mig ('Claude project folder not found: ' + $projDir) 'WARN' }
Write-Mig ('conversation and memory: ' + ($items.Count - $n0) + ' file(s)') 'INFO'

$n1 = $items.Count
if (Test-Path -LiteralPath $deskDir -PathType Container) {
  foreach ($f in @(Get-ChildItem -LiteralPath $deskDir -File -Force -Filter '*.md' -ErrorAction SilentlyContinue)) { Add-PackFile -File $f -EntryName ('desktop-dark-raiders/' + $f.Name) }
}
Write-Mig ('Desktop notes (*.md): ' + ($items.Count - $n1) + ' file(s)') 'INFO'

$n2 = $items.Count
foreach ($k in @(Get-KitFiles)) {
  $fi = $null
  try { $fi = Get-Item -LiteralPath $k.Full -Force } catch { }
  if ($fi) { Add-PackFile -File $fi -EntryName ('kit/' + ([string]$k.Rel).Replace('\', '/')) }
}
Write-Mig ('move kit: ' + ($items.Count - $n2) + ' file(s)') 'INFO'

[int64]$total = 0
[int64]$biggest = 0
foreach ($it in $items) { $total += $it.Size; if ($it.Size -gt $biggest) { $biggest = $it.Size } }
Write-Mig ('in total ' + $items.Count + ' file(s), ' + (Format-Bytes $total) + ' before compression') 'INFO'
foreach ($lo in $leftOut) { Write-Mig ('left out: ' + $lo.Name + ' (' + $lo.Why + ')') 'WARN' }

if (-not (Test-Path -LiteralPath $unpackSrc)) { Write-Mig ('unpack-session.ps1 is missing next to this script: ' + $unpackSrc) 'FAIL'; Exit-Mig 1 }
if ($items.Count -eq 0) { Write-Mig 'nothing to pack' 'FAIL'; Exit-Mig 1 }

$free = Get-DriveFreeBytes $packDir
$need = $total + $biggest + 512MB
if ($free -ge 0 -and $free -lt $need) { Write-Mig ('not enough free space on the drive of ' + $packDir + ' (' + (Format-Bytes $free) + ' free, about ' + (Format-Bytes $need) + ' needed)') 'FAIL'; Exit-Mig 1 }

if ($DryRun) {
  Write-Mig ('would scan every file for key patterns, then write ' + $zipFinal) 'DRY'
  Write-Mig ('would also write ' + $manFinal + ' and a copy of unpack-session.ps1 in the same folder (outside the repository)') 'DRY'
  Write-Mig 'Dry run finished. Nothing was built.' 'DONE'
  Exit-Mig 0
}

# ------------------------------------------------------------------ build
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Force -Path $snapDir | Out-Null
$snap = Join-Path $snapDir 'current.snap'
if (Test-Path -LiteralPath $zipTmp) { Remove-Item -LiteralPath $zipTmp -Force -ErrorAction SilentlyContinue }

Write-Mig 'Scanning and packing (this reads every file once)' 'STEP'
$zfs = $null
$za = $null
$packed = 0
$failed = $false
$i = 0
try {
  $zfs = [System.IO.File]::Open($zipTmp, [System.IO.FileMode]::Create, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
  $za = New-Object System.IO.Compression.ZipArchive($zfs, [System.IO.Compression.ZipArchiveMode]::Create, $false)
  foreach ($it in $items) {
    $i++
    if (($i % 100) -eq 0) { Write-Mig ('... ' + $i + ' of ' + $items.Count + ' files') 'INFO' }
    if (-not (Copy-Snapshot -Src $it.Full -Dst $snap)) { [void]$leftOut.Add([pscustomobject]@{ Name = $it.Entry; Why = 'could not be read (left out)' }); Write-Mig ('left out: ' + $it.Entry + ' (could not be read)') 'WARN'; continue }
    $ext = [System.IO.Path]::GetExtension($it.Entry).ToLowerInvariant()
    $generic = ($binExt -notcontains $ext)
    # the function returns its list wrapped (return ,$arr); @() around it would make every file count as 1 hit
    $kinds = Find-SecretKindsInFile -Path $snap -Generic $generic
    if ($null -eq $kinds) { $kinds = @() }
    if ($kinds.Count -gt 0) {
      $why = 'looks like it holds a key or password: ' + ($kinds -join ', ')
      if ($kinds -contains 'unreadable') { $why = 'could not be scanned (left out)' }
      [void]$leftOut.Add([pscustomobject]@{ Name = $it.Entry; Why = $why })
      Write-Mig ('left out: ' + $it.Entry + ' (' + $why + ')') 'WARN'
      continue
    }
    $entry = $za.CreateEntry($it.Entry, [System.IO.Compression.CompressionLevel]::Optimal)
    try { $entry.LastWriteTime = [System.DateTimeOffset]$it.Time } catch { }
    $es = $null
    $ss = $null
    try {
      $es = $entry.Open()
      $ss = [System.IO.File]::Open($snap, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
      $ss.CopyTo($es, 1048576)
    } finally {
      if ($null -ne $ss) { $ss.Dispose() }
      if ($null -ne $es) { $es.Dispose() }
    }
    $packed++
  }
} catch {
  $failed = $true
  Write-Mig ('building the zip failed: ' + $_.Exception.Message) 'FAIL'
} finally {
  if ($null -ne $za) { $za.Dispose() }
  if ($null -ne $zfs) { $zfs.Dispose() }
  if (Test-Path -LiteralPath $snap) { Remove-Item -LiteralPath $snap -Force -ErrorAction SilentlyContinue }
}
if ($failed) {
  if (Test-Path -LiteralPath $zipTmp) { Remove-Item -LiteralPath $zipTmp -Force -ErrorAction SilentlyContinue }
  Exit-Mig 1
}

# the finished zip must open and hold exactly the files that were packed
$zr = $null
$count = -1
try { $zr = [System.IO.Compression.ZipFile]::OpenRead($zipTmp); $count = $zr.Entries.Count } catch { $count = -1 } finally { if ($null -ne $zr) { $zr.Dispose() } }
if ($count -ne $packed) {
  Write-Mig ('the finished zip does not check out (it holds ' + $count + ' entries, ' + $packed + ' were written). Nothing was kept.') 'FAIL'
  Remove-Item -LiteralPath $zipTmp -Force -ErrorAction SilentlyContinue
  Exit-Mig 1
}
if (Test-Path -LiteralPath $zipFinal) { Remove-Item -LiteralPath $zipFinal -Force }
Move-Item -LiteralPath $zipTmp -Destination $zipFinal -Force
Copy-Item -LiteralPath $unpackSrc -Destination $unpackCopy -Force

$zipHash = (Get-FileHash -LiteralPath $zipFinal -Algorithm SHA256).Hash.ToLowerInvariant()
$unpHash = (Get-FileHash -LiteralPath $unpackCopy -Algorithm SHA256).Hash.ToLowerInvariant()
$zipLen = (Get-Item -LiteralPath $zipFinal).Length
$head = ''
try { $rs = Get-RepoState; if ($rs.Ok) { $head = [string]$rs.Head } } catch { }
$loList = @()
foreach ($x in $leftOut) { $loList += [ordered]@{ name = [string]$x.Name; why = [string]$x.Why } }
$man = [ordered]@{
  created   = (Get-Date).ToString('s')
  host      = $env:COMPUTERNAME
  sessionId = $sessionId
  gitHead   = $head
  entries   = $packed
  zip       = [ordered]@{ file = 'pillagers-session-pack.zip'; size = $zipLen; sha256 = $zipHash }
  unpack    = [ordered]@{ file = 'unpack-session.ps1'; sha256 = $unpHash }
  leftOut   = $loList
}
Write-AsciiFile -Path $manFinal -Text ($man | ConvertTo-Json -Depth 6)

Write-MigBlank
Write-Mig ('pack built: ' + $packed + ' file(s), ' + (Format-Bytes $zipLen) + ', sha256 ' + $zipHash.Substring(0, 12) + '...') 'OK'
Write-Mig ('folder: ' + $packDir) 'INFO'
if ($leftOut.Count -gt 0) { Write-Mig ($leftOut.Count.ToString() + ' file(s) were left out because of the secret rules (see the WARN lines above). Only names were logged.') 'WARN' }
else { Write-Mig 'no file was left out by the secret rules' 'OK' }
if (@($leftOut | Where-Object { $_.Name -like 'claude-project/*.jsonl' }).Count -gt 0) { Write-Mig 'The conversation file itself was left out, so a Claude window in the VM cannot resume this conversation.' 'WARN' }
Write-Mig 'NEXT: push-pack.ps1 in an administrator window sends it into the VM.' 'DONE'
Exit-Mig 0
